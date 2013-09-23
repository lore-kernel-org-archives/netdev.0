From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Do not drop DNATed 6to4/6rd packets (v4)
Date: Mon, 23 Sep 2013 12:11:25 -0700
Message-ID: <1379963485.3575.53.camel@joe-AO722>
References: <1379869266.2086.13.camel@joe-AO722>
	 <1379961413-21005-1-git-send-email-catab@embedromix.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0142.hostedemail.com ([216.40.44.142]:52353 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752798Ab3IWTL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 15:11:29 -0400
In-Reply-To: <1379961413-21005-1-git-send-email-catab@embedromix.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 21:36 +0300, Catalin(ux) M. BOIE wrote:
> From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
> 
> When a router is doing  DNAT for 6to4/6rd packets the latest anti-spoofing
> patch (218774dc) will drop them because the IPv6 address embedded
> does not match the IPv4 destination. This patch will allow them to
> pass by testing if we have an address that matches on 6to4/6rd interface.
> I have been hit by this problem using Fedora and IPV6TO4_IPV4ADDR.
> Also, log the dropped packets (with rate limit).

A few more trivialities:

When you send revisions to patches, please put the
revision number inside the brackets like:

[PATCH V4] subject

Also, use a prefix for the patch like:

[PATCH V4] IPv6 NAT: Don't drop DNAT 6to4 or 6RD packets

> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
[]
> @@ -67,6 +67,10 @@ int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
>  int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr);
>  #endif
>  
> +extern bool ipv6_chk_custom_prefix(const struct in6_addr *addr,
> +				   const unsigned int prefix_len,
> +				   struct net_device *dev);
> +

extern isn't required.

> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
[]
> @@ -566,6 +566,70 @@ static inline bool is_spoofed_6rd(struct ip_tunnel *tunnel, const __be32 v4addr,
[]
> +/* Returns true if a packet is spoofed */
> +static bool packet_is_spoofed(struct sk_buff *skb,
> +			      const struct iphdr *iph,
> +			      struct ip_tunnel *tunnel)
> +{
[]
> +	if ((tunnel->dev->flags & IFF_POINTOPOINT))
> +		return false;

One too many parentheses

	if (tunnel->dev->flags & IFF_POINTTOPOINT)
		return false;
