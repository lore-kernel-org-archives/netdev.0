From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 1/1] ipv6: add support of equal cost
 multipath (ECMP)
Date: Sun, 21 Oct 2012 20:41:46 -0400 (EDT)
Message-ID: <20121021.204146.1395047796384194358.davem@davemloft.net>
References: <1349194467.12401.810.camel@edumazet-glaptop>
	<1350638006-4213-1-git-send-email-nicolas.dichtel@6wind.com>
	<1350638006-4213-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, joe@perches.com, bernat@luffy.cx,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746Ab2JVAls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 20:41:48 -0400
In-Reply-To: <1350638006-4213-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Why do you go through all of the effort to create a nice
abstraction in a header file:

> +#ifdef CONFIG_IPV6_MULTIPATH
> +static inline unsigned int
> +ipv6_multipath_get_nsiblings(const struct rt6_info *rt)
> +{
> +	return rt->rt6i_nsiblings;
> +}
 ...

Only to screw it up by still plopping ifdef crap into foo.c files?

> +#ifdef CONFIG_IPV6_MULTIPATH
> +		INIT_LIST_HEAD(&rt->rt6i_siblings);
> +#endif
> +		ipv6_multipath_reset_nsiblings(rt);

I really don't want to see these ifdefs.

And if they are unavoidable, remove this configure option
altogether and make the code unconditionally included.
