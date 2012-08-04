From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Sat, 04 Aug 2012 01:25:43 -0700 (PDT)
Message-ID: <20120804.012543.1386784515867824475.davem@davemloft.net>
References: <1343972729.9299.596.camel@edumazet-glaptop>
	<20120803.165611.1832423445730269834.davem@davemloft.net>
	<1344064240.9299.1470.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446Ab2HDIZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 04:25:45 -0400
In-Reply-To: <1344064240.9299.1470.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 04 Aug 2012 09:10:40 +0200

> On Fri, 2012-08-03 at 16:56 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 03 Aug 2012 07:45:29 +0200
>> 
>> > @@ -1587,13 +1587,11 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>> >  	if (ipv4_is_zeronet(daddr))
>> >  		goto martian_destination;
>> >  
>> > -	if (likely(!IN_DEV_ROUTE_LOCALNET(in_dev))) {
>> > -		if (ipv4_is_loopback(daddr))
>> > -			goto martian_destination;
>> > +	if (ipv4_is_loopback(daddr) && !IN_DEV_NET_ROUTE_LOCALNET(in_dev, net))
>> > +		goto martian_destination;
>> >  
>> > -		if (ipv4_is_loopback(saddr))
>> > -			goto martian_source;
>> > -	}
>> > +	if (ipv4_is_loopback(saddr) && !IN_DEV_NET_ROUTE_LOCALNET(in_dev, net))
>> > +		goto martian_source;
>> 
>> Maybe clearer as:
>> 
>> 	if ((ipv4_is_loopback(daddr) || ipv4_is_loopback(saddr)) &&
>> 	    !IN_DEV_NET_ROUTE_LOCALNET(in_dev, net))
>> 		goto martian_source;
> 
> Clearer, but handling of a martian destination is different of the
> martian source ;)

Duh, I missed that, too many martians :-)
