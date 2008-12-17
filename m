From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 18 Dec 2008 08:29:07 +1100
Message-ID: <20081217212907.GA27243@gondor.apana.org.au>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi> <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au> <20081217103129.GA17248@gondor.apana.org.au> <20081217104254.GA17407@gondor.apana.org.au> <1229511143.13305.23.camel@nathan.suse.cz> <20081217112600.GA19106@gondor.apana.org.au> <20081217114138.GA20976@gondor.apana.org.au> <20081217125505.GA8379@ms2.inr.ac.ru> <20081217153015.GA17903@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petr Tesarik <ptesarik@suse.cz>,
	Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57081 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751666AbYLQV3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:29:24 -0500
Content-Disposition: inline
In-Reply-To: <20081217153015.GA17903@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 06:30:15PM +0300, Alexey Kuznetsov wrote:
> Hello!
> 
> > Probably, netbsd/openbsd have some another quirk to work this around.
> > I do not see how, though.
> 
> F.e. this could be totally safe if we do this only in the case
> when octet seq+0xFFFF has not yet been sent.
> 
> When we send segment with 0xFFFF inside urg_ptr is advanced and so on,
> so that receiver has no chances to corrupt stream.
> 
> I.e. we set URG and urg_ptr to fake scb->seq + 0xFFFF only when:
> 
> 	after(scb->seq + 0xFFFF, tp->snd_nxt)
> 
> My brains are rusty, so take this critically. :-)

Indeed that's a great idea!

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
