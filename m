From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] e1000e: convert to stats64
Date: Fri, 21 Jan 2011 14:19:05 -0800
Message-ID: <1295648345.2825.60.camel@jtkirshe-MOBL1>
References: <1292358735-32089-1-git-send-email-fleitner@redhat.com>
	 <1292362173.2478.6.camel@edumazet-laptop>
	 <20101216123131.GA3070@redhat.com>
	 <AANLkTi=y4u1DTtOX9-70CeDGhWGu4bBKK0Y32Js41=bK@mail.gmail.com>
	 <20110121170340.GA3087@redhat.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-TeJ4bZnF+C+UkCckSH8e"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7858 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754162Ab1AUWTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 17:19:07 -0500
In-Reply-To: <20110121170340.GA3087@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TeJ4bZnF+C+UkCckSH8e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-01-21 at 09:03 -0800, Flavio Leitner wrote:
> On Thu, Dec 16, 2010 at 07:14:35PM -0800, Jeff Kirsher wrote:
> > On Thu, Dec 16, 2010 at 04:31, Flavio Leitner <fleitner@redhat.com> wro=
te:
> > > On Tue, Dec 14, 2010 at 10:29:33PM +0100, Eric Dumazet wrote:
> > >> Le mardi 14 d=C3=A9cembre 2010 =C3=A0 18:32 -0200, Flavio Leitner a =
=C3=A9crit :
> > >> > Provides accurate stats at the time user reads them.
> > >> >
> > >> > Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> > >> > ---
> > >> >  drivers/net/e1000e/e1000.h   |    5 ++-
> > >> >  drivers/net/e1000e/ethtool.c |   27 +++++++++-------
> > >> >  drivers/net/e1000e/netdev.c  |   68 ++++++++++++++++++++++++-----=
------------
> > >> >  3 files changed, 59 insertions(+), 41 deletions(-)
> > >> >
> > >> > diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000=
.h
> > >> > index fdc67fe..5a5e944 100644
> > >> > --- a/drivers/net/e1000e/e1000.h
> > >> > +++ b/drivers/net/e1000e/e1000.h
> > >> > @@ -363,6 +363,8 @@ struct e1000_adapter {
> > >> >     /* structs defined in e1000_hw.h */
> > >> >     struct e1000_hw hw;
> > >> >
> > >> > +   spinlock_t stats64_lock;
> > >> > +   struct rtnl_link_stats64 stats64;
> > >>
> > >> I am not sure why you add this stats64 in e1000_adapter ?
> > >>
> > >> Why isnt it provided by callers (automatic variable, or provided to
> > >> ndo_get_stats64()). I dont see accumulators, only a full rewrite of =
this
> > >> structure in e1000e_update_stats() ?
> > >
> > > Good point. I have modified the patch to fix that.
> > > thanks!
> > >
> > > From 3487bd7dacd0c23bba315270139dab6e00e5ff02 Mon Sep 17 00:00:00 200=
1
> > > From: Flavio Leitner <fleitner@redhat.com>
> > > Date: Thu, 16 Dec 2010 10:26:03 -0200
> > > Subject: [PATCH] e1000e: convert to stats64
> > >
> > > Provides accurate stats at the time user reads them.
> > >
> > > Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> > > ---
> > >  drivers/net/e1000e/e1000.h   |    3 ++
> > >  drivers/net/e1000e/ethtool.c |   25 ++++++++-------
> > >  drivers/net/e1000e/netdev.c  |   68 ++++++++++++++++++++++++++++++++=
+--------
> > >  3 files changed, 70 insertions(+), 26 deletions(-)
> > >
> >=20
> > I have dropped you previous version of the patch and applied v2 to my
> > tree for review and testing.
> > Thanks Flavio!
>=20
> Hi Jeff,
>=20
> Do you have any feedback on this patch?
> thanks,

I have the patch ready to push to Dave for net-next, along with a few
other e1000e patches.  I was just waiting for net-next to open (which it
did a few days ago).

--=-TeJ4bZnF+C+UkCckSH8e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNOgZZAAoJECTsCADr/EWUBuYIAKau0rtF0zz99yuy2XXdE5s5
wSw1qwYHcoikervYvV3tIq8m2XtfzXC9ft1GzMWXg4mQWimVsbnOxosCdHUM++Vj
dWA40Ctxx1pSwARXj+VVwc8bPTZg1ADqEyRWfEbEFY7RS9NZF1wqfcI8SKQJocHB
nq8bHi57Zu68jNG8c97g9tRIh5/tJEj80iDYxB7Ff2xaMnxAWeLWALG8tONiGYAT
MOQOqHdt7r59KmxGL+RFz8XXj4Jk9ZPbOExFh/VNdLYC5n8SIYhICBnaHOr1dqCc
d1ubPQOH5608xqWBtoQzbyEjy1UjiNdBmOcD7eqd4QKjRHjFExPMkXwNAJItZrc=
=9GmK
-----END PGP SIGNATURE-----

--=-TeJ4bZnF+C+UkCckSH8e--

