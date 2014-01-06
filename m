From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source
 addresses in echo reply
Date: Mon, 06 Jan 2014 15:11:52 -0500 (EST)
Message-ID: <20140106.151152.229689152907259833.davem@davemloft.net>
References: <1388767411-17818-1-git-send-email-fx.lebail@yahoo.com>
	<20140105230505.GA29910@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fx.lebail@yahoo.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754806AbaAFUL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 15:11:57 -0500
In-Reply-To: <20140105230505.GA29910@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 6 Jan 2014 00:05:05 +0100

> On Fri, Jan 03, 2014 at 05:43:31PM +0100, Francois-Xavier Le Bail wrote:
>> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
>> index 5d42009..65c8619 100644
>> --- a/net/ipv6/icmp.c
>> +++ b/net/ipv6/icmp.c
>> @@ -556,7 +556,9 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
>>  
>>  	saddr = &ipv6_hdr(skb)->daddr;
>>  
>> -	if (!ipv6_unicast_destination(skb))
>> +	if (!ipv6_unicast_destination(skb) &&
>> +	    !(net->ipv6.anycast_src_echo_reply &&
>> +	      ipv6_chk_acast_addr(net, NULL, saddr)))
>>  		saddr = NULL;
> 
> I am not sure why you left out the device at ipv6_chk_acast_addr?
> 
> IMHO this logic is a bit more complex, we can pass NULL for ipv6 addresses of
> scope global but need to check the interface for scope link.
> 
> It is already possible via setsockopt JOIN_ANYCAST that an ll address is
> anycast on another interface which may not be checked here.

I think we should pass a valid device in unless it breaks something
obvious.

Thanks.
