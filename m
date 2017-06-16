From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: Re: [PATCH 1/3] dev: Prevent creating network devices with negative
 ifindex
Date: Fri, 16 Jun 2017 19:44:45 +0300
Message-ID: <02a31165-ad2f-fcdf-e7c5-f66a35712d4e@gmail.com>
References: <cover.1497621810.git.serhe.popovych@gmail.com>
 <d365b6f06598d041a177b91b15929285c2649935.1497621810.git.serhe.popovych@gmail.com>
 <20170616091806.2dd229e2@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33974 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751144AbdFPQos (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 12:44:48 -0400
Received: by mail-wr0-f193.google.com with SMTP id y25so4938910wrd.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 09:44:47 -0700 (PDT)
In-Reply-To: <20170616091806.2dd229e2@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Fri, 16 Jun 2017 17:23:51 +0300
> Serhey Popovych <serhe.popovych@gmail.com> wrote:
> 
>> Interface index is signed integer, we can pass ifm->ifi_index
>> from userspace via netlink and create network device with
>> negative ifindex value.
>>
>> Fixes: 9c7dafbfab15 ("net: Allow to create links with given ifindex")
>> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
>> ---
>>  net/core/dev.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 8658074..dae8010 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -7491,7 +7491,7 @@ int register_netdevice(struct net_device *dev)
>>  	}
>>  
>>  	ret = -EBUSY;
>> -	if (!dev->ifindex)
>> +	if (dev->ifindex <= 0)
>>  		dev->ifindex = dev_new_index(net);
>>  	else if (__dev_get_by_index(net, dev->ifindex))
>>  		goto err_uninit;
> 
> You should fix this by adding error check in the netlink portion
> that allows creating devices with given ifindex. Passing < 0
> should be an error.But should this break some setups if I add such check to netlink
portion? In my opinion it is better to choose silently different
ifindex rather than reporting failure. That's why I prefer doing
this in register_netdevice().

Also there is similar problem for drivers/net/veth.c, it might
happen that other places will be added later that setup
dev->ifindex and then call register_netdevice().

What do you think?

Thanks for quick review!

> 

-- 
Thanks, Serhey
