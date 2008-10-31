From: David Miller <davem@davemloft.net>
Subject: Re: tbench wrt. loopback TSO
Date: Fri, 31 Oct 2008 01:14:11 -0700 (PDT)
Message-ID: <20081031.011411.238617852.davem@davemloft.net>
References: <Pine.LNX.4.64.0810271704530.7072@wrl-59.cs.helsinki.fi>
	<20081027170314.GA25148@ioremap.net>
	<Pine.LNX.4.64.0810272113280.13973@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zbr@ioremap.net, netdev@vger.kernel.org, efault@gmx.de,
	mingo@elte.hu, a.p.zijlstra@chello.nl, herbert@gondor.apana.org.au
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56981
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751753AbYJaIOg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 04:14:36 -0400
In-Reply-To: <Pine.LNX.4.64.0810272113280.13973@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 28 Oct 2008 00:17:00 +0200 (EET)

> On Mon, 27 Oct 2008, Evgeniy Polyakov wrote:
>=20
> > That's why when I see modulo something screams inside me...
> > I used following patch (without goto in the tcp_tso_should_defer():
> >=20
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index e4c5ac9..8ee7597 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -1075,7 +1075,6 @@ unsigned int tcp_current_mss(struct sock *sk,=
 int large_allowed)
> >  				  tp->tcp_header_len);
> > =20
> >  		xmit_size_goal =3D tcp_bound_to_half_wnd(tp, xmit_size_goal);
> > -		xmit_size_goal -=3D (xmit_size_goal % mss_now);
> >  	}
> >  	tp->xmit_size_goal =3D xmit_size_goal;
> > =20
> >=20
> > tso/gso  on: 361.866 362.662
> > tso/gso off: 370.038 368.768
> >=20
> > So this is another improvement hidden and not accounted in the tso/=
gso stuff.
> > Another modulo sits in tcp_mss_split_point().
>=20
> I know it's there but it should occur not that often.

It happens every sendmsg() call, and all tbench does is small send,
small recv, repeat.

So with TSO on, a small increase in performance is no surprise, as
we will save some cycles often enough.

