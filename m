From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [GIT PATCH] IPv6 Updates for net-2.6.19
Date: Fri, 25 Aug 2006 19:50:46 +0200
Message-ID: <20060825175046.GT3470@postel.suug.ch>
References: <20060825.030034.68559899.yoshfuji@linux-ipv6.org> <20060825.172130.112746083.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52181 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750805AbWHYRu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 13:50:26 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20060825.172130.112746083.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2006-08-25 17:21
> commit 10204d532f5f8bb379009ba0bee2113bafda72be
> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date:   Mon Aug 21 19:22:01 2006 +0900
> 
>     [IPV6] ROUTE: Routing by FWMARK.
>     
>     Based on patch by Jean Lorchat <lorchat@sfc.wide.ad.jp>.
>     
>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
> index 19a82b6..2987549 100644
> --- a/include/linux/fib_rules.h
> +++ b/include/linux/fib_rules.h
> @@ -34,7 +34,7 @@ enum
>  	FRA_UNUSED3,
>  	FRA_UNUSED4,
>  	FRA_UNUSED5,
> -	FRA_FWMARK,	/* netfilter mark (IPv4) */
> +	FRA_FWMARK,	/* netfilter mark (IPv4/IPv6) */
>  	FRA_FLOW,	/* flow/class id */
>  	FRA_UNUSED6,
>  	FRA_UNUSED7,

You're missing the validation policy entry for FRA_FWMARK
in the IPv6 policy.

> diff --git a/include/net/flow.h b/include/net/flow.h
> index e052291..3ca210e 100644
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
> @@ -26,6 +26,7 @@ struct flowi {
>  		struct {
>  			struct in6_addr		daddr;
>  			struct in6_addr		saddr;
> +			__u32			fwmark;
>  			__u32			flowlabel;
>  		} ip6_u;

Since all flowi users now use fwmark it can be moved out
of the union.

> diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
> index 91f6233..aebd9e2 100644
> --- a/net/ipv6/fib6_rules.c
> +++ b/net/ipv6/fib6_rules.c
> @@ -26,6 +26,9 @@ struct fib6_rule
>  	struct fib_rule		common;
>  	struct rt6key		src;
>  	struct rt6key		dst;
> +#ifdef CONFIG_IPV6_ROUTE_FWMARK
> +	u8			fwmark;
> +#endif
>  	u8			tclass;
>  };

This doesn't look right.
