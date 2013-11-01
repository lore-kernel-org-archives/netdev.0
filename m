From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: host should probe those non-reachable router
Date: Fri, 1 Nov 2013 12:19:57 +0100
Message-ID: <20131101111957.GA30284@order.stressinduktion.org>
References: <52731633.2030101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43055 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812Ab3KALT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 07:19:59 -0400
Content-Disposition: inline
In-Reply-To: <52731633.2030101@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Duan!

On Fri, Nov 01, 2013 at 10:47:15AM +0800, Duan Jiong wrote:
> 
> rather than those routers that the return value of rt6_score_route()
> is RT6_NUD_SUCCEED.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>  net/ipv6/route.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 1ac0b6e..b7bf5c7 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -623,12 +623,11 @@ static struct rt6_info *find_match(struct rt6_info *rt, int oif, int strict,
>  		match_do_rr = true;
>  		m = 0; /* lowest valid score */
>  	} else if (m < 0) {
> +		if (strict & RT6_LOOKUP_F_REACHABLE)
> +			rt6_probe(rt);
>  		goto out;
>  	}
>  
> -	if (strict & RT6_LOOKUP_F_REACHABLE)
> -		rt6_probe(rt);
> -

I don't think this is correct. m < 0 are the routers we really don't want to
use, e.g. because we get a failure signaled from rt6_check_dev. E.g. we want
to query a route where a specified interface id is given.

In case router preference is enabled we mostly give back RT6_NUD_SUCCEED for
routes which are somewhat reachable. Really broken routers in NUD_FAILED state
are waiting for cleanup and recreation. We also do not accept new NAs on
neighbours in NUD_FAILED state IIRC.

Greetings,

  Hannes
