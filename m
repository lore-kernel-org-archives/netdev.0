From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix problem with expired dst cache
Date: Fri, 24 Feb 2012 01:47:16 -0500 (EST)
Message-ID: <20120224.014716.2237525226945856862.davem@davemloft.net>
References: <1330064404-24763-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429Ab2BXGrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 01:47:24 -0500
In-Reply-To: <1330064404-24763-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Fri, 24 Feb 2012 14:20:04 +0800

> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
> index b26bb81..3da4d58c 100644
> --- a/include/net/ip6_fib.h
> +++ b/include/net/ip6_fib.h
> @@ -106,6 +106,7 @@ struct rt6_info {
>  	u32				rt6i_metric;
>  	u32				rt6i_peer_genid;
>  
> +	struct rt6_info			*rt6i_copy;
>  	struct inet6_dev		*rt6i_idev;
>  	struct inet_peer		*rt6i_peer;

This bloats up every route and cached entry in the machine, find
another way.

> +	if ((rt->rt6i_flags & RTF_EXPIRES) &&
> +		time_after(jiffies, rt->dst.expires))

Poorly formatted, correct way is:

	if ((rt->rt6i_flags & RTF_EXPIRES) &&
	    time_after(jiffies, rt->dst.expires))

> +	if (rt->rt6i_copy && (rt->rt6i_copy->rt6i_flags & RTF_EXPIRES) &&
> +		time_after(jiffies, rt->rt6i_copy->dst.expires))

Same problem.
