From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] fib_rules: add .suppress operation
Date: Sat, 27 Jul 2013 08:26:18 +0200
Message-ID: <20130727062618.GE20273@order.stressinduktion.org>
References: <20130725221116.GC10216@zirkel.wertarbyte.de> <20130726104657.GF10216@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Andrew Collins <bsderandrew@gmail.com>
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:42670 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725Ab3G0G0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jul 2013 02:26:19 -0400
Content-Disposition: inline
In-Reply-To: <20130726104657.GF10216@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh, I overlooked something.

On Fri, Jul 26, 2013 at 12:46:57PM +0200, Stefan Tomanek wrote:
> --- a/net/ipv6/fib6_rules.c
> +++ b/net/ipv6/fib6_rules.c
> @@ -111,6 +111,17 @@ out:
>  	return rt == NULL ? -EAGAIN : 0;
>  }
>  
> +static int fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg) {
> +	struct rt6_info *rt = (struct rt6_info *) arg->result;
> +	/*
> +	 * do not accept result if the route does
> +	 * not meet the required prefix length
> +	 */
> +	if (rt->rt6i_dst.plen < rule->table_prefixlen_min) {
> +		return 1;
> +	}
> +	return 0;
> +}

In case of IPv6 (we don't clone the result but merely return a reference to
the rt6_info), we also need to decrement the reference count if we suppress
the route. A ip6_rt_put should do the trick.

Greetings,

  Hannes
