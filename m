From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH v2] net: remove struct dst_ops::entry_size
Date: Tue, 11 Nov 2008 16:25:35 +0300
Message-ID: <20081111132535.GB14810@x200.localdomain>
References: <20081111132445.GA14810@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:63070 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755754AbYKKNWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 08:22:11 -0500
Received: by ug-out-1314.google.com with SMTP id 39so731859ugf.37
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 05:22:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081111132445.GA14810@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2008 at 04:24:45PM +0300, Alexey Dobriyan wrote:
> Unused after kmem_cache_zalloc() conversion.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  include/net/dst.h       |    1 -
>  net/decnet/dn_route.c   |    1 -
>  net/ipv4/route.c        |    2 --
>  net/ipv4/xfrm4_policy.c |    1 -
>  net/ipv6/route.c        |    2 --
>  net/ipv6/xfrm6_policy.c |    1 -
>  6 files changed, 8 deletions(-)
> 
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -104,7 +104,6 @@ struct dst_ops
>  	void			(*link_failure)(struct sk_buff *);
>  	void			(*update_pmtu)(struct dst_entry *dst, u32 mtu);
>  	int			(*local_out)(struct sk_buff *skb);
> -	int			entry_size;
>  
>  	atomic_t		entries;
>  	struct kmem_cache 		*kmem_cachep;
> --- a/net/decnet/dn_route.c
> +++ b/net/decnet/dn_route.c
> @@ -131,7 +131,6 @@ static struct dst_ops dn_dst_ops = {
>  	.negative_advice =	dn_dst_negative_advice,
>  	.link_failure =		dn_dst_link_failure,
>  	.update_pmtu =		dn_dst_update_pmtu,
> -	.entry_size =		sizeof(struct dn_route),
>  	.entries =		ATOMIC_INIT(0),
>  };
>  
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -160,7 +160,6 @@ static struct dst_ops ipv4_dst_ops = {
>  	.link_failure =		ipv4_link_failure,
>  	.update_pmtu =		ip_rt_update_pmtu,
>  	.local_out =		__ip_local_out,
> -	.entry_size =		sizeof(struct rtable),
>  	.entries =		ATOMIC_INIT(0),
>  };
>  
> @@ -2701,7 +2700,6 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
>  	.destroy		=	ipv4_dst_destroy,
>  	.check			=	ipv4_dst_check,
>  	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
> -	.entry_size		=	sizeof(struct rtable),
>  	.entries		=	ATOMIC_INIT(0),
>  };
>  
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -248,7 +248,6 @@ static struct dst_ops xfrm4_dst_ops = {
>  	.ifdown =		xfrm4_dst_ifdown,
>  	.local_out =		__ip_local_out,
>  	.gc_thresh =		1024,
> -	.entry_size =		sizeof(struct xfrm_dst),
>  	.entries =		ATOMIC_INIT(0),
>  };
>  
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -108,7 +108,6 @@ static struct dst_ops ip6_dst_ops_template = {
>  	.link_failure		=	ip6_link_failure,
>  	.update_pmtu		=	ip6_rt_update_pmtu,
>  	.local_out		=	__ip6_local_out,
> -	.entry_size		=	sizeof(struct rt6_info),
>  	.entries		=	ATOMIC_INIT(0),
>  };
>  
> @@ -122,7 +121,6 @@ static struct dst_ops ip6_dst_blackhole_ops = {
>  	.destroy		=	ip6_dst_destroy,
>  	.check			=	ip6_dst_check,
>  	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
> -	.entry_size		=	sizeof(struct rt6_info),
>  	.entries		=	ATOMIC_INIT(0),
>  };
>  
> --- a/net/ipv6/xfrm6_policy.c
> +++ b/net/ipv6/xfrm6_policy.c
> @@ -279,7 +279,6 @@ static struct dst_ops xfrm6_dst_ops = {
>  	.ifdown =		xfrm6_dst_ifdown,
>  	.local_out =		__ip6_local_out,
>  	.gc_thresh =		1024,
> -	.entry_size =		sizeof(struct xfrm_dst),
>  	.entries =		ATOMIC_INIT(0),
>  };
>  
