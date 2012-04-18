From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] net/l2tp: add support for L2TP over IPv6 UDP encap
Date: Wed, 18 Apr 2012 14:30:57 -0400 (EDT)
Message-ID: <20120418.143057.38880609278817544.davem@davemloft.net>
References: <20120418134438.GA5162@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281Ab2DRSbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 14:31:06 -0400
In-Reply-To: <20120418134438.GA5162@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Wed, 18 Apr 2012 09:44:38 -0400

> +#if IS_ENABLED(CONFIG_IPV6)
> +	if (sk->sk_family == PF_INET6) {
> +		if (!uh->check) {
> +			LIMIT_NETDEBUG(KERN_INFO "L2TP: IPv6: checksum is 0\n");
> +			return 1;
> +		}
> +		if ((skb->ip_summed == CHECKSUM_COMPLETE) &&
> +		    !csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> +				     &ipv6_hdr(skb)->daddr, ulen,
> +				     IPPROTO_UDP, skb->csum)) {
> +			skb->ip_summed = CHECKSUM_UNNECESSARY;
> +			return 0;
> +		}
> +		skb->csum = ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> +							 &ipv6_hdr(skb)->daddr,
> +							 skb->len, IPPROTO_UDP,
> +							 0));

Both the csum_ipv6_magic() calls should either use "ulen" or both
should use "skb->len".
