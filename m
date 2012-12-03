From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] net: call notifiers for mtu change even if
 iface is not up
Date: Mon, 3 Dec 2012 15:22:29 +0100
Message-ID: <20121203142229.GA3054@minipsycho.orion>
References: <1354533392-9308-1-git-send-email-jiri@resnulli.us>
 <20121203141823.GA21816@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, psimerda@redhat.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49562 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480Ab2LCOWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 09:22:34 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so1604139eek.19
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 06:22:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121203141823.GA21816@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Dec 03, 2012 at 03:18:23PM CET, nhorman@tuxdriver.com wrote:
>On Mon, Dec 03, 2012 at 12:16:32PM +0100, Jiri Pirko wrote:
>> Do the same thing as in set mac. Call notifiers every time.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/core/dev.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 2f94df2..0685a72 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -4971,7 +4971,7 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
>>  	else
>>  		dev->mtu = new_mtu;
>>  
>> -	if (!err && dev->flags & IFF_UP)
>> +	if (!err)
>>  		call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
>>  	return err;
>>  }
>
>I'm not opposed to this change, but is there something that it expressly fixes?

This is about a consistency. To have the same behaviour as set_mac
for example.

>While it doesn't hurt to send around mtu change events, one would presume that
>listeners would pick up mtu changes when the NETDEV_UP event went' around.
>
>Neil
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
