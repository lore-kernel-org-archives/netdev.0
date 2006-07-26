From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] [IPV6]: Policy Routing Rules
Date: Wed, 26 Jul 2006 16:33:43 -0700 (PDT)
Message-ID: <20060726.163343.29813028.davem@davemloft.net>
References: <20060726221100.325687073@postel.suug.ch>
	<20060726221850.124450582@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45212
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750795AbWGZXdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 19:33:39 -0400
To: tgraf@suug.ch
In-Reply-To: <20060726221850.124450582@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 27 Jul 2006 00:00:04 +0200

> Index: net-2.6.git/include/net/ip6_route.h
> ===================================================================
> --- net-2.6.git.orig/include/net/ip6_route.h
> +++ net-2.6.git/include/net/ip6_route.h
> @@ -41,6 +41,11 @@ struct pol_chain {
>  
>  extern struct rt6_info	ip6_null_entry;
>  
> +#ifdef CONFIG_IPV6_MULTIPLE_TABLES
> +extern struct rt6_info	ip6_prohibit_entry;
> +extern struct rt6_info	ip6_blk_hole_entry;
> +#endif
> +
>  extern int ip6_rt_gc_interval;
>  
>  extern void			ip6_route_input(struct sk_buff *skb);

Because of my other suggestion, changing IPV6_MULTIPLE_TABLES
to tristate, the build will fail unless we add a second condition
to this ifdef, namely "CONFIG_IPV6_MULTIPLE_TABLES_MODULE".

In fact, all this doesn't look so nice.

All we want to do is make fib6_rules.o get built into ipv6-objs
if it is enabled.

Therfore, the better fix seems to be, to change the Makefile
rule to be:

ipv6-$(CONFIG_IPV6_MULTIPLE_TABLES) += fib6_rules.o

Ok?

