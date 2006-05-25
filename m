From: Phil Dibowitz <phil@ipom.com>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 12:22:39 -0700
Message-ID: <20060525192239.GB29024@ipom.com>
References: <20060523.182217.59656237.davem@davemloft.net> <200605250805.38241.bcook@bpointsys.com> <20060525175947.GA29024@ipom.com> <200605251341.42204.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yEPQxsgoJgBvi8ip"
Cc: Bill Fink <billfink@mindspring.com>, Jeff Garzik <jeff@garzik.org>,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-24-24-245-191.socal.res.rr.com ([24.24.245.191]:63041 "EHLO
	alt") by vger.kernel.org with ESMTP id S1030366AbWEYTWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 15:22:42 -0400
To: Brent Cook <bcook@bpointsys.com>
Content-Disposition: inline
In-Reply-To: <200605251341.42204.bcook@bpointsys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--yEPQxsgoJgBvi8ip
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 25, 2006 at 01:41:41PM -0500, Brent Cook wrote:
> On Thursday 25 May 2006 12:59, Phil Dibowitz wrote:
> > On Thu, May 25, 2006 at 08:05:37AM -0500, Brent Cook wrote:
> > > > I'll admit to not knowing all the intricacies of the kernel coding
> > > > involved, but I don't offhand see how zeroing the stats would be
> > > > significantly more complex than updating the stats during normal us=
age.
> > > > But I'll have to leave that argument to the experts.
> > >
> > > What it boils down to is that currently, a single CPU or thread ever
> > > touches the stats concurrently, so it doesn't have to lock them or do
> > > anything special to ensure that the continue incrementing. If you wan=
t to
> > > make sure that the statistics actually reset when you want them to, y=
ou
> > > have to account for this case:
> > >
> > >   CPU0 reads current value from memory (increment)
> > >   CPU1 writes 0 to current value in memory (reset)
> > >   CPU0 writes incremented value to memory (increment complete)
> >
> > Perhaps I'm missing something here, but these counters are only incrime=
nted
> > in hardware... i.e. attomically.
> >
>=20
> No, you're right - I'm just thinking that once one driver has this abilit=
y,=20
> users are going to want it for all network devices, and implementation on=
=20
> some devices (namely virtual ones - lo, tun, tap, br, vlan) is trickier t=
han=20
> just setting a register. Some hardware devices too - mv643xx_eth.c just=
=20
> increments the network stats in software, for instance. Lockless software=
=20
> reset is fine though as long as people understand the consequences - it's=
=20
> absolutely fine, given the way I would use reset in my environment, MMV.

OK, good, I'm glad I was understanding things right.

Yes, if the framework gets accepted, I'll work on implimenting it in more
drivers. Only in ones I can get access to the hardware, obviously, but I
wasn't going to do work to impliment it in a ton of drivers if the framework
wasn't going to be accepted.

For virtual stuff, of course locking would be needed, and while this is
"performance degredation", it's only so when you choose to clear the stats.

So at least, for the _current_ implimentations, this should have no
performance impacts.

--=20
Phil Dibowitz                             phil@ipom.com
Freeware and Technical Pages              Insanity Palace of Metallica
http://www.phildev.net/                   http://www.ipom.com/

"They that can give up essential liberty to obtain a little temporary
safety deserve neither liberty nor safety."
 - Benjamin Franklin, 1759


--yEPQxsgoJgBvi8ip
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEdgP/N5XoxaHnMrsRAr+zAKCmWgdeurfsPbSXxDkFogx/A2N2pwCfbs2d
K+Ij+I2E41g0euJVSkMz9Xw=
=R+Fu
-----END PGP SIGNATURE-----

--yEPQxsgoJgBvi8ip--
