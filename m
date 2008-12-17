From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 14:31:25 +0100
Message-ID: <1229520685.13305.32.camel@nathan.suse.cz>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi>
	 <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au>
	 <20081217103129.GA17248@gondor.apana.org.au>
	 <20081217104254.GA17407@gondor.apana.org.au>
	 <1229511143.13305.23.camel@nathan.suse.cz>
	 <20081217112600.GA19106@gondor.apana.org.au>
	 <20081217114138.GA20976@gondor.apana.org.au>
	 <20081217125505.GA8379@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:54654 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751272AbYLQNb1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 08:31:27 -0500
In-Reply-To: <20081217125505.GA8379@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Kuznetsov p=C3=AD=C5=A1e v St 17. 12. 2008 v 15:55 +0300:
> Hello!
>=20
> > In other words what we do currently potentially makes urgent
> > mode completely useless since it may delay the sending of the
> > urgent notification indefinitely.  While the BSD behaviour would
> > only break "broken" applications.
>=20
> This is true.
>=20
> It definitely will work with correct application (those which
> use SO_OOBINLINE), and surely will kill those which treat
> urg data in _default_ __BSD__("BSD behaviour", you say, huh:-))
> way and withdraw octet at urgent pointer.=20
>=20
> Probably, netbsd/openbsd have some another quirk to work this around.
> I do not see how, though.
>=20
> I decided that this is a fatal conflict, which can be solved cleanly
> only in a painful way like you suggested. Current approach delaying
> URG is the way which does not spoil any data, breaking only in the
> case of aborts.
>=20
> If you are serious about this, also it would be a good idea
> to make SO_OOBINLINE default option. Consider this. At least this
> will allow to trap applications which will corrupt data stream
> earlier.

This might turn out to be a dangerous decision. I am aware at least of
one big application which uses urgent data and doesn't use SO_OOBINLINE=
:
Oracle.

Yes, of course it's broken, but do we really want to join the much-hate=
d
folks who are stuck with an only-we-do-it-correctly approach?

Just my 2 cents,
Petr Tesarik


