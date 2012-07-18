From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 07/15] ipv4: Adjust semantics of rt->rt_gateway.
Date: Wed, 18 Jul 2012 11:57:14 -0700
Message-ID: <1342637834.2013.4.camel@joe2Laptop>
References: <20120718.112346.920698833832945112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:47646 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755574Ab2GRS5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 14:57:15 -0400
In-Reply-To: <20120718.112346.920698833832945112.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 11:23 -0700, David Miller wrote:
> In order to allow prefixed routes, we have to adjust how rt_gateway
> is set an interpreted.

typo an/and and a trivial style note:

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
[]
> @@ -1079,8 +1079,10 @@ void ip_rt_get_source(u8 *addr, struct sk_buff *skb, struct rtable *rt)
>  		if (fib_lookup(dev_net(rt->dst.dev), &fl4, &res) == 0)
>  			src = FIB_RES_PREFSRC(dev_net(rt->dst.dev), res);
>  		else
> -			src = inet_select_addr(rt->dst.dev, rt->rt_gateway,
> -					RT_SCOPE_UNIVERSE);
> +			src = inet_select_addr(rt->dst.dev, (rt->rt_gateway ?
> +							     rt->rt_gateway :
> +							     iph->daddr),
> +					       RT_SCOPE_UNIVERSE);

maybe use the moderately common gcc ?: extension

			src = inet_select_addr(rt->dst.dev,
					       rt->rt_gateway ?: iph->daddr,
					       RT_SCOPE_UNIVERSE);
