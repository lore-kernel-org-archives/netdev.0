From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 18 Dec 2008 08:30:52 +1100
Message-ID: <20081217213052.GB27243@gondor.apana.org.au>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi> <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au> <20081217103129.GA17248@gondor.apana.org.au> <20081217104254.GA17407@gondor.apana.org.au> <1229511143.13305.23.camel@nathan.suse.cz> <20081217112600.GA19106@gondor.apana.org.au> <20081217114138.GA20976@gondor.apana.org.au> <20081217125505.GA8379@ms2.inr.ac.ru> <20081217153015.GA17903@ms2.inr.ac.ru> <1229529888.13305.57.camel@nathan.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Petr Tesarik <ptesarik@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57096 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751871AbYLQVbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:31:09 -0500
Content-Disposition: inline
In-Reply-To: <1229529888.13305.57.camel@nathan.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 05:04:48PM +0100, Petr Tesarik wrote:
>
> This is all nice, but it still does not solve those series of SIGURGs on
> the receiving side. My suggestion is to not generate a new SIGURG until
> the data for the latest one have arrived. There can be only one byte of
> urgent data, so if somebody sends more than one, it cannot be handled by
> the receiver, anyway, so that use case is broken and need not be taken
> into account.

No we need to send a SIGURG as soon as we enter urgent mode.  The
whole point of urgent mode is to inform the receiver ASAP.  As the
urgent data itself cannot be expedited due to the in-order nature
of TCP, setting the flag and sending the signal is the best we can
do.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
