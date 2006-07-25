From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPROUTE]: Add support for multipath route realms
Date: Tue, 25 Jul 2006 18:19:33 +1000
Message-ID: <E1G5I8b-00063u-00@gondolin.me.apana.org.au>
References: <44C596EC.905@trash.net>
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:29455 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932136AbWGYITm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 04:19:42 -0400
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <44C596EC.905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
> 
> [IPROUTE]: Add support for multipath route realms
> 
> Routing realms exist per nexthop, but iproute currently only allows to send
> a single route realm, which is refused by the kernel for multipath routes.
> Add support for specifying per nexthop realms. Old kernels only return the
> first realm back to userspace when dumping, so the others can't be displayed,
> besides that it will also behave correctly on old kernels.
> 
> old kernel:
> 
> 1.2.3.4 realm 1
>        nexthop dev dummy0 weight 1
>        nexthop dev dummy1 weight 1
>        nexthop dev dummy2 weight 1
>        nexthop dev dummy3 weight 1
> 
> new kernel:
> 
> 1.2.3.4
>        nexthop realm 1 dev dummy0 weight 1
>        nexthop realm 2 dev dummy1 weight 1
>        nexthop realm 3 dev dummy2 weight 1
>        nexthop realm 4 dev dummy3 weight 1

This really looks like papering over fundamental brokenness of
IP_ROUTE_MULTIPATH_CACHED since you wouldn't otherwise get these
entries in the routing cache.

This reminds me that I better revisit the reasons that people gave
for actually using IP_ROUTE_MULTIPATH_CACHED the last time we tried
to get rid of it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
