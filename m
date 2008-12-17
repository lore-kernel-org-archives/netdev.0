From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 18:30:15 +0300
Message-ID: <20081217153015.GA17903@ms2.inr.ac.ru>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi> <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au> <20081217103129.GA17248@gondor.apana.org.au> <20081217104254.GA17407@gondor.apana.org.au> <1229511143.13305.23.camel@nathan.suse.cz> <20081217112600.GA19106@gondor.apana.org.au> <20081217114138.GA20976@gondor.apana.org.au> <20081217125505.GA8379@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petr Tesarik <ptesarik@suse.cz>,
	Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:42660 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751964AbYLQPhN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 10:37:13 -0500
Content-Disposition: inline
In-Reply-To: <20081217125505.GA8379@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> Probably, netbsd/openbsd have some another quirk to work this around.
> I do not see how, though.

F.e. this could be totally safe if we do this only in the case
when octet seq+0xFFFF has not yet been sent.

When we send segment with 0xFFFF inside urg_ptr is advanced and so on,
so that receiver has no chances to corrupt stream.

I.e. we set URG and urg_ptr to fake scb->seq + 0xFFFF only when:

	after(scb->seq + 0xFFFF, tp->snd_nxt)

My brains are rusty, so take this critically. :-)


