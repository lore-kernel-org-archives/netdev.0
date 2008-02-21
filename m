From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] Don't create tunnels with '%' in name.
Date: Thu, 21 Feb 2008 15:17:27 +0300
Message-ID: <47BD6BD7.1060200@openvz.org>
References: <47BD6907.7050303@openvz.org> <47BD6A28.1030007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47363 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912AbYBUMRa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 07:17:30 -0500
In-Reply-To: <47BD6A28.1030007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Pavel Emelyanov wrote:
>> Four tunnel drivers (ip_gre, ipip, ip6_tunnel and sit) can
>> receive a pre-defined name for a device from the userspace.
>> Since these drivers call the register_netdevice() after this 
>> (rtnl_lock is held), the device's name may contain a '%' 
>> character.
>>
>> Not sure how bad is this to have a device with a '%' in its
>> name, but all the other places either use the register_netdev(),
>> or explicitly call dev_alloc_name() before registering, i.e. 
>> do not allow for such names.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>>
>> ---
>>
>> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
>> index 63f6917..6b9744f 100644
>> --- a/net/ipv4/ip_gre.c
>> +++ b/net/ipv4/ip_gre.c
>> @@ -274,19 +274,24 @@ static struct ip_tunnel * ipgre_tunnel_locate(struct ip_tunnel_parm *parms, int
>>  	if (!dev)
>>  	  return NULL;
>>  
>> +	if (strchr(name, '%')) {
>> +		if (dev_alloc_name(dev, name) < 0)
>> +			goto failed_free;
>> +	}
>> +
> 
> 
> It would be nicer to replace the entire hand-made name
> allocation to remove the 100 device limit.
> 

Actually, I thought the same, but fixing % in names looks like a 
BUG-fix for 2.6.25, while removing the hand-made name allocation 
looks like an enhancement for 2.6.26. No?

Thanks,
Pavel
