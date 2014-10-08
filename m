From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v3 net 1/2] ipv6: Remove the
 net->ipv6.ip6_null_entry check
Date: Wed, 08 Oct 2014 15:08:38 -0400 (EDT)
Message-ID: <20141008.150838.2078642969379360127.davem@davemloft.net>
References: <1412640315-22472-1-git-send-email-kafai@fb.com>
	<1412640315-22472-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753358AbaJHTIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 15:08:41 -0400
In-Reply-To: <1412640315-22472-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Mon, 6 Oct 2014 17:05:14 -0700

> The above BACKTRACK have already caught the rt == net->ipv6.ip6_null_entry case
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
 ...
> @@ -936,8 +936,7 @@ restart:
>  	if (rt->rt6i_nsiblings)
>  		rt = rt6_multipath_select(rt, fl6, oif, strict | reachable);
>  	BACKTRACK(net, &fl6->saddr);
> -	if (rt == net->ipv6.ip6_null_entry ||
> -	    rt->rt6i_flags & RTF_CACHE)
> +	if (rt->rt6i_flags & RTF_CACHE)
>  		goto out;
>  
>  	dst_hold(&rt->dst);

I think this is sort of going in the wrong direction.

The BACKTRACK() macro hides a lot of side effects inside of it's
implementation, and worst of all it hides a change of control flow
with it's "goto out;" and "goto restart;"

I'd rather see us clean this up in some way that someone auditing this
code won't be tricked into missing the control flow side effects, than
adding more dependencies upon BACKTRACK()'s implementation.

Thanks.
