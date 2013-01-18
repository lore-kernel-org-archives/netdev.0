From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Fri, 18 Jan 2013 14:32:00 -0500 (EST)
Message-ID: <20130118.143200.1013561317240911918.davem@davemloft.net>
References: <20130117033258.GA23782@order.stressinduktion.org>
	<50F81C4B.3050406@linux-ipv6.org>
	<20130117200733.GA2055@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3ARTcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:32:02 -0500
In-Reply-To: <20130117200733.GA2055@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 17 Jan 2013 21:07:33 +0100

> +#ifdef CONFIG_IPV6_SIT_6RD
> +	if (ipv6_prefix_equal(addr6, &tunnel->ip6rd.prefix,
> +				tunnel->ip6rd.prefixlen) &&
> +		*addr != try_6rd(addr6, tunnel))
> +		return 0;
> +#else
> +	if (addr6->s6_addr16[0] == htons(0x2002) &&
> +		*addr != try_6rd(addr6, tunnel))
> +		return 0;
> +#endif
> +	return 1;
> +}
 ...
> +		} else if (!sit_chk_encap_addr(tunnel, &iph->saddr,
> +					&ipv6_hdr(skb)->saddr) ||
> +			!sit_chk_encap_addr(tunnel, &iph->daddr,
> +				&ipv6_hdr(skb)->daddr)) {

None of these conditionals are indented properly, please fix this up.
Both conditionals and function calls that span multiple lines must use
the column after the openning parenthesis of the initial line as the
left justification of subsequent lines.

I see what you're doing, just using TAB characters exclusively to
ident, don't do that.  You must use the appropriate combination of
TAB and space characters to achieve the correct indentaiton.
