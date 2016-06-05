From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC net-next 1/1] ethtool: Add support for set eeprom metadata.
Date: Sun, 05 Jun 2016 17:36:36 +0100
Message-ID: <1465144596.2847.241.camel@decadent.org.uk>
References: <1464269615-4937-1-git-send-email-sudarsana.kalluru@qlogic.com>
	 <CO2PR11MB00887A3F4C8ABB71421B1651975B0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <1465130957.2847.195.camel@decadent.org.uk>
	 <CO2PR11MB00889DA9200C03CA3F940D21975B0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-B9+XBfKDg33e2yibLNhG"
Cc: netdev <netdev@vger.kernel.org>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39606 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750971AbcFEQgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 12:36:46 -0400
In-Reply-To: <CO2PR11MB00889DA9200C03CA3F940D21975B0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-B9+XBfKDg33e2yibLNhG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-06-05 at 13:29 +0000, Yuval Mintz wrote:
> >=20
> > > > Currently ethtool implementation does not have a way to pass the
> > > > metadata for eeprom related operations. Some adapters have a
> > > > complicated non-volatile memory implementation that requires
> > > > additional information =E2=80=93 there are drivers [bnx2x and bnxt]=
 that use
> > > > the =E2=80=98magic=E2=80=99 field in the {G,S}EEPROM=C2=A0=C2=A0for=
 that purpose, although that=E2=80=99s not
> > its intended usage.
> > > >=20
> > > > This patch adds a provision to pass the eeprom metadata for
> > > > %ETHTOOL_SEEPROM/%ETHTOOL_GEEPROM implementations. User
> > provided
> > > > metadata will be cached by the driver and assigns a magic value
> > > > which the application need to use for the subsequent {G,S}EEPROM
> > command.
> > >=20
> > > Hi Dave,
> > >=20
> > > This got no comments at all.
> > > What do you want us to with it next? Should we re-send it as a patch?
> >=20
> > Here's a comment: I really dislike this.
> :-)
>=20
> > - It doesn't specify any semantics for the 'metadata'. =C2=A0The commen=
t hints that
> > they are driver-specific identifiers for different NVRAM partitions.
> Not exactly, but close [in our use case there are 2 'methods' of accessin=
g the
> flash - either according to addresses or logical 'files'].
>=20
> > - It doesn't provide a way for userland to enumerate the valid metadata=
 values.
> I agree; I can't think of any good way of enumerating device-specific val=
ues.
>=20
> > - It's not clear whether the driver is supposed to maintain just one
> > metadata:magic mapping, or more than that.
> Theoretically, I guess it could maintain multiple, but that wasn't the in=
tention.
> One should do.
>=20
> > Is the ethtool API really the right interface for access to flash? =C2=
=A0The sfc driver
> > exposes a large number of flash partitions using MTD instead. =C2=A0The=
se can be
> > enumerated (through /proc/mtd or sysfs) and they can be read and writte=
n
> > through block devices.
>=20
> I think the better question then is 'what's the purpose of this ethtool A=
PI at all'?

I think it's a bit of an accident - MTD was designed for flash in
embedded systems, and it used to have a static limit on the number of
partitions. =C2=A0The ethtool API was then rather better suited to plug-in
cards that would have a single small EEPROM.

> I agree we can go and do everything via MTD; The reason we've tried using=
 this
> API was mainly... because it was there. And thus we thought this is the R=
IGHT
> method for providing users the way of reading their flash.
[...]

I think that MTD makes more sense for flash partitions, especially when
there are several of them. =C2=A0I already did the work of removing=20
the static limit on the number of partitions, and convincing
distributions to enable the MTD core drivers. =C2=A0(That said, you will
still find some users who need to change their custom kernel
configurations.)

Ben.

--=C2=A0
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Albert
Einstein


--=-B9+XBfKDg33e2yibLNhG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXVFUVAAoJEOe/yOyVhhEJbvEP+wbilK287ARAM9kCmxzR+B6C
g1AlpjfWcPjT5mEco3eycPHFoPUVIEi2mGz9bp2fI6V+zvF1dMDOoUiIN/ZLciNt
7TAvCDP/KToyqWpt/MDnMiGLJeaJlxYxirz8CpJOalG9e/M49jXuGiIIw/bnnfHQ
YQM6M+jugz810WHGyP8nxa2LADACjfT1QG5LhIvlUZVwNGHacVw2WPSd42rzizJn
4gTyK4MONqLOZycgAQ7WMmlBn2BjewcBSp8HbvXoAtYC4uiWRMuxhTzU35bWE7gr
19K9lb2hgw2N1gvemmGRajuSWSpv832ubNh8TYq5hmdpGzez1Dict1aSQ4KvkcF6
DhEdZOyUIuiew6CTOQFzLDi0boHmBAGeujiGYcb2+SeQ8tHT6DwC3ET1p1kcXeNp
Bhr/VEUHPcFlExz9Nr5xVLifyFOF9oEquIcgGcavvjSVNa848i/UF1hnEWZmX5bd
+9g1WBA20tkMlSrhg66pQwnmVXzDxfYxA0fsRWkYeqB5jPFpFwZlG8TazANOfnlI
sPtRPkd5VPHpD67gdkCKfAh8eRcGONeFPTSwChGMcmytvcJR7bQWkK0djy73uGxn
M5bdPVl548gQ63mUTaaB9N48jQehhzgjZzW8+TkDUYdsHYOmOgILN1/45jLSJdOG
vnqrveUdQEfH0NaJWAOh
=OaZd
-----END PGP SIGNATURE-----

--=-B9+XBfKDg33e2yibLNhG--
