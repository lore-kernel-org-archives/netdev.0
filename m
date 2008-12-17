From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 21:17:11 +1100
Message-ID: <E1LCtSp-0004Rc-Lb@gondolin.me.apana.org.au>
References: <1229501899.13305.12.camel@nathan.suse.cz>
Cc: herbert@gondor.apana.org.au, ilpo.jarvinen@helsinki.fi,
	davem@davemloft.net, netdev@vger.kernel.org
To: ptesarik@suse.cz (Petr Tesarik)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40303 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752453AbYLQKRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 05:17:23 -0500
In-Reply-To: <1229501899.13305.12.camel@nathan.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Petr Tesarik <ptesarik@suse.cz> wrote:
> 
>  1. Currently this code path will never get run, because large
>     offloads are avoided both for hardware TSO and software GSO.
>     You'd also have to modify the conditionals that guard calls
>     to tcp_mss_split_point().

Obviously one would revert the existing fixes after this is applied.

>  2. Is it worth the trouble?
>     This slows down the software GSO slightly. I mean, urgent
>     data should be quite rare, so it makes sense to treat
>     non-urgent data as "fast path" and urgent data as "slow
>     path". While Ilpo's approach only slows down the slow path,
>     your patch slows down both.

Well it might slow down the GSO path slightly, but it speeds
up the TSO generation path accordingly :) I think the cost is
negligible in either case so the benefit of TSO dominates.
 
> Anyway, we have to keep the code that avoids large offloads with URG,
> because many NICs are broken in this regard (at least all Intel NICs
> I've seen so far), so why treat software GSO specially?

That's not a problem.  Unless the NIC sets NETIF_F_TSO_URG (which
nobody does currently because it's a new flag), we'll do the
segmentation in software, but only if the packet is marked as URG.

This is identical to how we handle ECN which most NICs get wrong
as well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
