From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2] ipv6: only static routes qualify for equal cost multipathing
Date: Fri, 12 Jul 2013 18:56:53 +0200
Message-ID: <20130712165652.GK12611@order.stressinduktion.org>
References: <20130712023731.GE12611@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:41906 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965065Ab3GLQ4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 12:56:54 -0400
Content-Disposition: inline
In-Reply-To: <20130712023731.GE12611@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 04:37:31AM +0200, Hannes Frederic Sowa wrote:
> Static routes in this case are non-expiring routes which did not get
> configured by autoconf or by icmpv6 redirects.
> 
> To make sure we actually get an ecmp route while searching for the first
> one in this fib6_node's leafs, also make sure it matches the ecmp route
> assumptions.
> 
> v2:
> a) Removed RTF_EXPIRE check in dst.from chain. The check of RTF_ADDRCONF
>    already ensures that this route, even if added manually again without
>    RTF_EXPIRES (or RA switches to infinite timeout), does not cause the
>    rt6i_nsiblings logic to go wrong if a later RA updates the expiration
>    time later.
> 
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_fib.c | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> index 192dd1a..662b90c 100644
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
> @@ -632,6 +632,13 @@ insert_above:
>  	return ln;
>  }
>  
> +static inline bool rt6_qualify_for_ecmp(struct rt6_info *rt)
> +{
> +	return (rt->rt6i_flags &
> +		(RTF_EXPIRES|RTF_GATEWAY|RTF_ADDRCONF|RTF_DYNAMIC)) ==
> +	       RTF_GATEWAY;
> +}

I am in progress to revisit this patch if RTF_EXPIRES is necessary. Please
defer this patch until then.

Thanks,

  Hannes
