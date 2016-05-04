From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next] vrf: add exit function and allow module unload
Date: Wed, 4 May 2016 10:05:28 -0600
Message-ID: <572A1DC8.8040204@cumulusnetworks.com>
References: <1462357236-6297-1-git-send-email-jiri@resnulli.us>
 <1462357422.1666076.597731009.4C5E1305@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, shm@cumulusnetworks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36634 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbcEDQFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 12:05:31 -0400
Received: by mail-ig0-f177.google.com with SMTP id u10so152304658igr.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 09:05:31 -0700 (PDT)
In-Reply-To: <1462357422.1666076.597731009.4C5E1305@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/16 4:23 AM, Hannes Frederic Sowa wrote:
> Hello Jiri,
>
> On Wed, May 4, 2016, at 12:20, Jiri Pirko wrote:
>>   drivers/net/vrf.c | 7 +++++++
>>   1 file changed, 7 insertions(+)
>>
>> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
>> index 8a8f1e5..b217c2d 100644
>> --- a/drivers/net/vrf.c
>> +++ b/drivers/net/vrf.c
>> @@ -839,7 +839,14 @@ error:
>>   	return rc;
>>   }
>>
>> +static void __exit vrf_exit_module(void)
>> +{
>> +       rtnl_link_unregister(&vrf_link_ops);
>> +       unregister_netdevice_notifier(&vrf_notifier_block);
>> +}
>> +
>>   module_init(vrf_init_module);
>> +module_exit(vrf_exit_module);
>
> The dst_entries created by vrf don't carry a reference to THIS_MODULE
> but have a code dependency to the vrf module (e.g. via
> vrf_output/vrf_output6) that gets published. This is exactly the same
> why ipv6 cannot be unloaded.

exactly. The module exit was removed recently by 9ab179d83b4e ("net: 
vrf: Fix dst reference counting")
