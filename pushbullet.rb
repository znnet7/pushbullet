#encoding: utf-8
#!/usr/bin/ruby
require 'net/http'
require 'json'
require 'uri'

out_file = File.new("api_key.config", "r")
$api_key = out_file.read
out_file.close
$url_devices = 'https://api.pushbullet.com/v2/devices'
$url_push = 'https://api.pushbullet.com/v2/pushes'



def get_device_id
    uri = URI($url_devices)

    req = Net::HTTP::Get.new(uri)
    req.basic_auth $api_key, ''
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') {|http|
        http.request(req)
    }

    content = JSON.parse(res.body)
    devices = content['devices']
    devices.each do |device|
        if device['android_version'].nil? == false
            return device['iden']
        end
    end
end


def push (device_id, title = '', body)
    params = { 
        'device_iden' => device_id,
        'type' => 'note',
        'title' => title,
        'body' => body,
    }

    uri = URI($url_push)
    req = Net::HTTP::Post.new(uri.path)
    req.basic_auth $api_key, ''
    req.set_form_data(params)

    http_request = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme =='https'
        http_request.use_ssl = true
    end

    res = http_request.start {|http|
        http.request(req)
    }

    if res.code == '200'
        puts 'Push Success'
    end

end

device_id = get_device_id
push(device_id, '', "{query}")
