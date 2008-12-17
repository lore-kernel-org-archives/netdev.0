From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 17:04:48 +0100
Message-ID: <1229529888.13305.57.camel@nathan.suse.cz>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi>
	 <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au>
	 <20081217103129.GA17248@gondor.apana.org.au>
	 <20081217104254.GA17407@gondor.apana.org.au>
	 <1229511143.13305.23.camel@nathan.suse.cz>
	 <20081217112600.GA19106@gondor.apana.org.au>
	 <20081217114138.GA20976@gondor.apana.org.au>
	 <20081217125505.GA8379@ms2.inr.ac.ru>
	 <20081217153015.GA17903@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:35569 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751689AbYLQQEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 11:04:51 -0500
In-Reply-To: <20081217153015.GA17903@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Kuznetsov p=C3=AD=C5=A1e v St 17. 12. 2008 v 18:30 +0300:
> Hello!
>=20
> > Probably, netbsd/openbsd have some another quirk to work this aroun=
d.
> > I do not see how, though.
>=20
> F.e. this could be totally safe if we do this only in the case
> when octet seq+0xFFFF has not yet been sent.
>=20
> When we send segment with 0xFFFF inside urg_ptr is advanced and so on=
,
> so that receiver has no chances to corrupt stream.
>=20
> I.e. we set URG and urg_ptr to fake scb->seq + 0xFFFF only when:
>=20
> 	after(scb->seq + 0xFFFF, tp->snd_nxt)
>=20
> My brains are rusty, so take this critically. :-)

This is all nice, but it still does not solve those series of SIGURGs o=
n
the receiving side. My suggestion is to not generate a new SIGURG until
the data for the latest one have arrived. There can be only one byte of
urgent data, so if somebody sends more than one, it cannot be handled b=
y
the receiver, anyway, so that use case is broken and need not be taken
into account.

Oh, and since SIGURG is not a real-time signal, there is no requirement
to send as many of them as there were urgent data. Of course, this does
not help other OSes, but I'm not sure how they behave in these
situations.

Petr

