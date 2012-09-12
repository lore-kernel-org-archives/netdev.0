From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: replace write lock with read lock when get route
 info
Date: Wed, 12 Sep 2012 09:45:07 +0200
Message-ID: <1347435907.13103.693.camel@edumazet-glaptop>
References: <1347427553-17781-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49840 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654Ab2ILHpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 03:45:12 -0400
Received: by eekc1 with SMTP id c1so995768eek.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 00:45:11 -0700 (PDT)
In-Reply-To: <1347427553-17781-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-12 at 13:25 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> geting route info does not write rt->rt6i_table, so replace
> write lock with read lock
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/ipv6/route.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 399613b..8be1d86 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1837,7 +1837,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
>  	if (!table)
>  		return NULL;
>  
> -	write_lock_bh(&table->tb6_lock);
> +	read_lock_bh(&table->tb6_lock);
>  	fn = fib6_locate(&table->tb6_root, prefix ,prefixlen, NULL, 0);
>  	if (!fn)
>  		goto out;
> @@ -1853,7 +1853,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
>  		break;
>  	}
>  out:
> -	write_unlock_bh(&table->tb6_lock);
> +	read_unlock_bh(&table->tb6_lock);
>  	return rt;
>  }
>  
> @@ -1896,7 +1896,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
>  	if (!table)
>  		return NULL;
>  
> -	write_lock_bh(&table->tb6_lock);
> +	read_lock_bh(&table->tb6_lock);
>  	for (rt = table->tb6_root.leaf; rt; rt=rt->dst.rt6_next) {
>  		if (dev == rt->dst.dev &&
>  		    ((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT)) == (RTF_ADDRCONF | RTF_DEFAULT)) &&
> @@ -1905,7 +1905,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
>  	}
>  	if (rt)
>  		dst_hold(&rt->dst);
> -	write_unlock_bh(&table->tb6_lock);
> +	read_unlock_bh(&table->tb6_lock);
>  	return rt;
>  }
>  

Why dont you also change addrconf_get_prefix_route() ?
