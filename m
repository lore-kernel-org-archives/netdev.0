From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 18 Dec 2008 09:52:31 +1100
Message-ID: <20081217225231.GA28052@gondor.apana.org.au>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi> <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au> <20081217103129.GA17248@gondor.apana.org.au> <20081217104254.GA17407@gondor.apana.org.au> <1229511143.13305.23.camel@nathan.suse.cz> <20081217112600.GA19106@gondor.apana.org.au> <20081217114138.GA20976@gondor.apana.org.au> <20081217125505.GA8379@ms2.inr.ac.ru> <20081217153015.GA17903@ms2.inr.ac.ru> <20081217212907.GA27243@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petr Tesarik <ptesarik@suse.cz>,
	Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54546 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752402AbYLQWwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 17:52:50 -0500
Content-Disposition: inline
In-Reply-To: <20081217212907.GA27243@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 08:29:07AM +1100, Herbert Xu wrote:
>
> > I.e. we set URG and urg_ptr to fake scb->seq + 0xFFFF only when:
> > 
> > 	after(scb->seq + 0xFFFF, tp->snd_nxt)
> > 
> > My brains are rusty, so take this critically. :-)
> 
> Indeed that's a great idea!

OK, I think this is what we should do:

1) Fix fresh transmissions of urgent mode as Alexey suggested.

This is the safest way of ensuring that the urgent notification
is not delayed.  This is still not as "fast" as the BSD behaviour
but it is much safer with respect to broken^H^H^H^H^H^Hlegacy
applications.

2) Continue to use the current test for retransmissions.

3) Apply my original GSO patch and revert the existing URG fixes.

With Alexey's fix, the scenario that Ilpo identified would only
occur on retransmissions.  As we disable TSO on retransmissions,
it no longer affects my patch.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
