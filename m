From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 6/7] tcp: cache result of earlier divides when mss-aligning things
Date: Sun, 15 Mar 2009 12:08:51 +0300
Message-ID: <20090315090851.GA1053@ioremap.net>
References: <1237075675426-git-send-email-ilpo.jarvinen@helsinki.fi> <12370756753599-git-send-email-ilpo.jarvinen@helsinki.fi> <12370756754094-git-send-email-ilpo.jarvinen@helsinki.fi> <12370756752410-git-send-email-ilpo.jarvinen@helsinki.fi> <12370756751028-git-send-email-ilpo.jarvinen@helsinki.fi> <12370756752721-git-send-email-ilpo.jarvinen@helsinki.fi> <20090315083642.GA31423@ioremap.net> <Pine.LNX.4.64.0903151041350.23360@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:52944 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752911AbZCOJJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 05:09:05 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903151041350.23360@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2009 at 10:45:16AM +0200, Ilpo J=C3=A4rvinen (ilpo.jarv=
inen@helsinki.fi) wrote:
> > > @@ -676,7 +676,17 @@ static unsigned int tcp_xmit_size_goal(struc=
t sock *sk, u32 mss_now,
> > >  				  tp->tcp_header_len);
> > > =20
> > >  		xmit_size_goal =3D tcp_bound_to_half_wnd(tp, xmit_size_goal);
> > > -		xmit_size_goal -=3D (xmit_size_goal % mss_now);
> > > +
> > > +		/* We try hard to avoid divides here */
> > > +		old_size_goal =3D tp->xmit_size_goal_segs * mss_now;
> > > +
> > > +		if (old_size_goal <=3D xmit_size_goal &&
> > > +		    old_size_goal + mss_now > xmit_size_goal) {
> > > +			xmit_size_goal =3D old_size_goal;
> >=20
> > If this is way more likely condition than changed xmit size, what a=
bout
> > wrapping it into likely()?
>=20
> So gcc won't read my comment? :-)

I heared the next gcc version will be linked with the libastral.so, but
we have to maintain backward compatibility.

> Updated below.

The whole series looks good.

--=20
	Evgeniy Polyakov
