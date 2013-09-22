From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Do not drop DNATed 6to4/6rd packets
Date: Sun, 22 Sep 2013 10:01:06 -0700
Message-ID: <1379869266.2086.13.camel@joe-AO722>
References: <20130915131401.GA18477@order.stressinduktion.org>
	 <1379847513-10837-1-git-send-email-catab@embedromix.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0050.hostedemail.com ([216.40.44.50]:35038 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752383Ab3IVRBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 13:01:10 -0400
In-Reply-To: <1379847513-10837-1-git-send-email-catab@embedromix.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-09-22 at 13:58 +0300, Catalin(ux) M. BOIE wrote:
> From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
> 
> When a router is doing  DNAT for 6to4/6rd packets the latest anti-spoofing
> patch (218774dc) will drop them because the IPv6 address embedded
> does not match the IPv4 destination. This patch will allow them to
> pass by testing if we have an address that matches on 6to4/6rd interface.
> I have been hit by this problem using Fedora and IPV6TO4_IPV4ADDR.
> Also, log the dropped packets (with rate limit).

Thanks.  trivial nits which maybe fixed later:

> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
[]
> +/* Returns true if a packet is spoofed
> + */

probably nicer as single line /* Returns true ... */

> +static bool packet_is_spoofed(struct sk_buff *skb,
> +			      const struct iphdr *iph,
> +			      struct ip_tunnel *tunnel)
> +{
> +	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
> +
> +	if (tunnel->dev->priv_flags & IFF_ISATAP) {
> +		if (!isatap_chksrc(skb, iph, tunnel))
> +			return true;
> +
> +		return false;
> +	}
> +
> +	if ((tunnel->dev->flags&IFF_POINTOPOINT))

It'd be nicer with spaces around the &

> +		return false;

It'd be slightly faster code moving the ipv6_hdr(skb)
assignment below these tests.
