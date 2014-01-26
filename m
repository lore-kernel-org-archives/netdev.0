From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 3/4] ethtool: Support for configurable RSS hash
 key.
Date: Sun, 26 Jan 2014 02:37:27 +0000
Message-ID: <1390703847.2735.11.camel@deadeye.wl.decadent.org.uk>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8E5@CMEXMB1.ad.emulex.com>
	 <1390156048.16433.114.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C84C327@CMEXMB1.ad.emulex.com>
	 <1390224028.3651.72.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C84CFAE@CMEXMB1.ad.emulex.com>
	 <1390455540.3651.136.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C84D71E@CMEXMB1.ad.emulex.com>
	 <1390489756.1547.13.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C85E298@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-iWo7k9ucC4QjYPeCqMRP"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51678 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750840AbaAZChh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 21:37:37 -0500
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C85E298@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-iWo7k9ucC4QjYPeCqMRP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-01-24 at 12:00 +0000, Venkata Duvvuru wrote:
>=20
> > -----Original Message-----
> > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> > Sent: Thursday, January 23, 2014 8:39 PM
> > To: Venkata Duvvuru
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [PATCH net-next 3/4] ethtool: Support for configurable RSS=
 hash
> > key.
> >=20
> > On Thu, 2014-01-23 at 13:47 +0000, Venkata Duvvuru wrote:
> > > > -----Original Message-----
> > > > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> > > > Sent: Thursday, January 23, 2014 11:09 AM
> > > > To: Venkata Duvvuru
> > > > Cc: netdev@vger.kernel.org
> > > > Subject: Re: [PATCH net-next 3/4] ethtool: Support for configurable
> > > > RSS hash key.
> > > >
> > > > On Wed, 2014-01-22 at 12:12 +0000, Venkata Duvvuru wrote:
> > > > [...]
> > > > > > No, what I mean is:
> > > > > >
> > > > > > 1. An RX flow steering filter can specify use of RSS, in which
> > > > > > case the value looked up in the indirection is added to the
> > > > > > queue number specified in the filter.  This is not yet
> > > > > > controllable through RX NFC though there is room for extension
> > there.
> > > > > >
> > > > > > 2. Multi-function controllers need multiple RSS contexts (key +
> > > > > > indirection
> > > > > > table) to support independent use of RSS on each function.
> > > > > > But it may also be possible to allocate multiple contexts to a
> > > > > > single
> > > > function.
> > > > > > This could be useful in conjunction with 1.  But there would
> > > > > > need to be a way to allocate and configure extra contexts first=
.
> > > > > The proposed changes will be incremental so I think this can be
> > > > > done in a separate patch. Thoughts?
> > > >
> > > > The ethtool ABI (to userland) has to remain backward-compatible, an=
d
> > > > it is preferable if we don't add lots of different structures for t=
his.
> > > >
> > > > So please define the new command structure to include both the key
> > > > and indirection table, and some reserved space (documented as
> > > > 'userland must set to 0') for future extensions.
> > >
> > > I think it=E2=80=99s better to keep key and indirection table setting=
s as
> > > different ethtool commands. We can probably add rss contexts (reserve=
d
> > > space) to both the command structures.
> > > If we mix key and indirection table into one command structure then i=
t
> > > will hamper the compatibility.
> > [...]
> >=20
> > Right, there is no compatible way to extend struct ethtool_rxfh_indir.
> > I should have thought ahead when defining it!  But the new structure do=
esn't
> > need to have that problem.
>=20
> If any one of the operations (key or indirection table) is not
> supported by the driver, should we silently ignore that operation and
> process the other supported operation or should we fail the command.

It should fail completely.

>  If we fail the command then we are mandating the drivers to implement
> both the operations.

So far as I know, all the multiqueue NICs that include a flow hash
indirection table do so as part of the Microsoft RSS specification,
which requires the hash key to be configurable as well.  Do you know of
any cases where only one of the two is configurable?

Ben.

--=20
Ben Hutchings
If the facts do not conform to your theory, they must be disposed of.

--=-iWo7k9ucC4QjYPeCqMRP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuR05+e/yOyVhhEJAQqWqQ/+JJvwO4Fw1cJEwqZ/f9k9/8bg2r82JQ1S
ipXIaVQNuSt5i/b0nSwag3r9eZtsMEiNu09N2TnrdK6bTF2tivrqAvowwjGVnJjD
BVJBv5Dx9Et2sZE38qKhpDy0YhfnoQ4PGrX/pG7l8wl2y7iWFnOz/ICqW1PZLd+8
7XzeYoBFg40QbkzlJioyBQTdza46O3Vt0GQspKJvsSnPV6TWKcIFQK831so2/niC
uy8T4zPyogrTaoXMiByFIsNmRetoBka0+IPfZddTgYcFu2oubRfnKuk2Rl+lpvaQ
ig3rs46cNK7V4UTm2Ukt2nqP1WxxQwgYEMD22Qrim3kjfCJ/g3ppnJKF4H/S9Kls
UIywwqAzvJW8W0PHtyCUtfe6pTVp90Qtz9PDplyuwKsTZNIyzJ69dWaWHw3Uo727
AKu1Urxf7HjcXOzD8krZQrBSECUNrXXbkPX/TObJgc9gGY1KYArSEBuyG/sT/rJP
x8FJQXVFCsfQBzkAC3jT2UmmtvxoAn0W44TBCPt+NTqL9ZYuy2dLvNdUyt4CK0yw
Y/+BMVbsBN60dYLo2LqXPCK/xnk6O3uQbZ1Wp+O7TCLFOi8FRnPEx/yFGmRsWwcj
8G56biAAAy12WnQEVRoD/rEbu/PVY7JTQKquYWxqNEYFSU9Xb7v8LE7fOXaPNnEp
FTDU1Cvo1Yk=
=NrfV
-----END PGP SIGNATURE-----

--=-iWo7k9ucC4QjYPeCqMRP--
