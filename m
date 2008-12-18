From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 18 Dec 2008 09:58:12 +0100
Message-ID: <1229590692.12322.2.camel@nathan.suse.cz>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi>
	 <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au>
	 <20081217103129.GA17248@gondor.apana.org.au>
	 <20081217104254.GA17407@gondor.apana.org.au>
	 <1229511143.13305.23.camel@nathan.suse.cz>
	 <20081217112600.GA19106@gondor.apana.org.au>
	 <20081217114138.GA20976@gondor.apana.org.au>
	 <20081217125505.GA8379@ms2.inr.ac.ru>
	 <20081217153015.GA17903@ms2.inr.ac.ru>
	 <1229529888.13305.57.camel@nathan.suse.cz>
	 <20081217213052.GB27243@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42270 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750927AbYLRI6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 03:58:14 -0500
In-Reply-To: <20081217213052.GB27243@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu p=C3=AD=C5=A1e v =C4=8Ct 18. 12. 2008 v 08:30 +1100:
> On Wed, Dec 17, 2008 at 05:04:48PM +0100, Petr Tesarik wrote:
> >
> > This is all nice, but it still does not solve those series of SIGUR=
Gs on
> > the receiving side. My suggestion is to not generate a new SIGURG u=
ntil
> > the data for the latest one have arrived. There can be only one byt=
e of
> > urgent data, so if somebody sends more than one, it cannot be handl=
ed by
> > the receiver, anyway, so that use case is broken and need not be ta=
ken
> > into account.
>=20
> No we need to send a SIGURG as soon as we enter urgent mode.  The
> whole point of urgent mode is to inform the receiver ASAP.  As the
> urgent data itself cannot be expedited due to the in-order nature
> of TCP, setting the flag and sending the signal is the best we can
> do.

That doesn't contradict my suggestion, which is: "Send the SIGURG as
soon as possible, but do not send _more_ SIGURGs until the urgent data
arrives."  I'm going to send a patch to make it clear.

Petr Tesarik


