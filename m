From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: tbench wrt. loopback TSO
Date: Mon, 27 Oct 2008 17:13:32 +0300
Message-ID: <20081027141332.GA4691@ioremap.net>
References: <20081015.171408.193701292.davem@davemloft.net> <20081026123442.GA31506@ioremap.net> <20081026.185911.193696873.davem@davemloft.net> <Pine.LNX.4.64.0810270942430.1290@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, Herbert Xu <herbert@gondor.apana.org.au>
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:53519 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695AbYJ0ONf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 10:13:35 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810270942430.1290@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 27, 2008 at 09:49:21AM +0200, Ilpo J=C3=A4rvinen (ilpo.jarv=
inen@helsinki.fi) wrote:
> > > That's what I got with the current tree for 8 threads on a 4-way =
32-bit
> > > Xeons (2 physical CPUs) and 8gb of ram:
> > > gso/tso off: 361.367
> > > tso/gso on:  354.635
> >=20
> > Yes, it might do this, in which case tcp_tso_should_defer() simply =
needs
> > some tweaking.
>=20
> Good point, could you Evgeniy verify first if simple goto send_now; i=
n=20
> beginning there recovers it all...

With direct goto at the begining of the tcp_tso_should_defer()
and 4403b406 commit git tree (was current yesterday night)
I got following numbers:=20

with goto:
tso/gso  on: 358.976, 357.699
tso/gso off: 368.016, 367.079

no goto
tso/gso  on: 353.656, 354.791
tso/gso off: 364.8, 365.85

So tcp_tso_should_defer() adds additional problems not counted in
tso/gso changes.

--=20
	Evgeniy Polyakov
