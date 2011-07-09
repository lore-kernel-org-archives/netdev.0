From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC 43/72] a2065/ariadne: Move the a2065/ariadne drivers
Date: Sat, 09 Jul 2011 07:30:26 -0700
Message-ID: <1310221836.26989.11.camel@jtkirshe-mobl>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1309010363-22750-44-git-send-email-jeffrey.t.kirsher@intel.com>
	 <BANLkTin_SRhrd4dnfBH48b1aTikw5-mjtg@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-rGnhDBd+FMvhkRSZtIjo"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26250 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753509Ab1GIOah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 10:30:37 -0400
In-Reply-To: <BANLkTin_SRhrd4dnfBH48b1aTikw5-mjtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rGnhDBd+FMvhkRSZtIjo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-06-28 at 13:33 -0700, Geert Uytterhoeven wrote:
> On Sat, Jun 25, 2011 at 15:58, Jeff Kirsher <jeffrey.t.kirsher@intel.com>=
 wrote:
> > --- a/drivers/net/ethernet/Kconfig
> > +++ b/drivers/net/ethernet/Kconfig
> > @@ -12,8 +12,31 @@ menuconfig ETHERNET
> >  if ETHERNET
> >
> >  source "drivers/net/ethernet/3com/Kconfig"
> > +
> > +config A2065
> > +       tristate "A2065 support"
> > +       depends on ZORRO
> > +       select CRC32
> > +       ---help---
> > +         If you have a Commodore A2065 Ethernet adapter, say Y. Otherw=
ise,
> > +         say N.
> > +
> > +         To compile this driver as a module, choose M here: the module
> > +         will be called a2065.
> > +
> >  source "drivers/net/ethernet/amd/Kconfig"
> >  source "drivers/net/ethernet/apple/Kconfig"
> > +
> > +config ARIADNE
> > +       tristate "Ariadne support"
> > +       depends on ZORRO
> > +       ---help---
> > +         If you have a Village Tronic Ariadne Ethernet adapter, say Y.
> > +         Otherwise, say N.
> > +
> > +         To compile this driver as a module, choose M here: the module
> > +         will be called ariadne.
> > +
> >  source "drivers/net/ethernet/arm/Kconfig"
> >  source "drivers/net/ethernet/atheros/Kconfig"
>=20
> What's the rationale behind this "restructuring"?

In short to better organize drivers/net/.  There are a large number of
drivers in drivers/net/ so we are trying to organize the directory
structure to make it easier to maintain in the future.

> FWIW, both the A2065 and Ariadne drivers are for AMD LANCE variants
> (that is Am7990 and Am79C960)?

I saw that they were LANCE variants, yet did not use the "common" LANCE
code like the other LANCE drivers.  Based on suggestions from Arnd
Bergmann and Joe Perches, I am moving these into the AMD LANCE driver
directory.

>=20
> And (in some other patch) 82596.c is an Intel driver, not a Motorola driv=
er.

82596.c is not an Intel driver, it is an Intel part.  The driver was
written and support by someone other than Intel.  I am looking at how to
better organize the 82596.c, lasi_82596.c, lib82596.c, and sni_82596.c
which all use an Intel Ethernet chip but were written and supported by
someone other than Intel.

--=-rGnhDBd+FMvhkRSZtIjo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOGGYCAAoJECTsCADr/EWU9OIH/3PD1+XvR6013ejki+PF1NNG
KAifZMJhaAB8ew2bOQk0kpijv2iKBZiE47ZtJo4h1xvgIoSAWUjP7lfj/jVQ9yh/
voWWRiHQHnSGqtb+mVDWD9zxPL6257hX83JYbzbz4lj/HHhG7kENIi56b/RPF9W4
KkQwy4UqGqLkCe1RTS2L0LWlT9Mqav7drfNGqnaEKIZsmCkfq6xlBB9gV9jGoaHh
z/rBf+t00/5Qc26YyLRKunIBcIacQTsOBgd/yfMH2O2ScHXyfUrgGLe1PofsTFdc
AWFAD0Q7HrDzjKnwCgYXHALxtk0cc5d5hkBD08G3NamA+weV4I64Nf+Yuockd7s=
=YKNf
-----END PGP SIGNATURE-----

--=-rGnhDBd+FMvhkRSZtIjo--

