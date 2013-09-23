From: catab@embedromix.ro
Subject: Re: [PATCH] Do not drop DNATed 6to4/6rd packets
Date: Mon, 23 Sep 2013 21:36:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1309232135570.6779@mail.embedromix.ro>
References: <20130915131401.GA18477@order.stressinduktion.org>  <1379847513-10837-1-git-send-email-catab@embedromix.ro> <1379869266.2086.13.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.embedromix.ro ([5.9.41.220]:36862 "EHLO mail.embedromix.ro"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754170Ab3IWSgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 14:36:48 -0400
In-Reply-To: <1379869266.2086.13.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 22 Sep 2013, Joe Perches wrote:

> On Sun, 2013-09-22 at 13:58 +0300, Catalin(ux) M. BOIE wrote:
>> From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
>>
>> When a router is doing  DNAT for 6to4/6rd packets the latest anti-spoofing
>> patch (218774dc) will drop them because the IPv6 address embedded
>> does not match the IPv4 destination. This patch will allow them to
>> pass by testing if we have an address that matches on 6to4/6rd interface.
>> I have been hit by this problem using Fedora and IPV6TO4_IPV4ADDR.
>> Also, log the dropped packets (with rate limit).
>
> Thanks.  trivial nits which maybe fixed later:
>
>> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> []
>> +/* Returns true if a packet is spoofed
>> + */
>
> probably nicer as single line /* Returns true ... */
>
>> +static bool packet_is_spoofed(struct sk_buff *skb,
>> +			      const struct iphdr *iph,
>> +			      struct ip_tunnel *tunnel)
>> +{
>> +	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
>> +
>> +	if (tunnel->dev->priv_flags & IFF_ISATAP) {
>> +		if (!isatap_chksrc(skb, iph, tunnel))
>> +			return true;
>> +
>> +		return false;
>> +	}
>> +
>> +	if ((tunnel->dev->flags&IFF_POINTOPOINT))
>
> It'd be nicer with spaces around the &
>
>> +		return false;
>
> It'd be slightly faster code moving the ipv6_hdr(skb)
> assignment below these tests.

Sorry, v3 was missing the changes suggested.
v4 fill fix it.
Sorry.

--
Catalin(ux) M. BOIE
http://kernel.embedromix.ro/
