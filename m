From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-2.6] 3c59x: Remove incorrect locking; correct
 documented lock hierarchy
Date: Wed, 01 Sep 2010 22:47:11 +0100
Message-ID: <1283377631.5323.285.camel@localhost>
References: <1283213733.7653.180.camel@localhost>
	 <20100901.143815.215547115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-7P8wafnjMSVQOizv5PeI"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:32880 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755326Ab0IAVrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 17:47:17 -0400
In-Reply-To: <20100901.143815.215547115.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7P8wafnjMSVQOizv5PeI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-09-01 at 14:38 -0700, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Tue, 31 Aug 2010 01:15:33 +0100
>=20
> > vortex_ioctl() was grabbing vortex_private::lock around its call to
> > generic_mii_ioctl().  This is no longer necessary since there are more
> > specific locks which the mdio_{read,write}() functions will obtain.
> > Worse, those functions do not save and restore IRQ flags when locking
> > the MII state, so interrupts will be enabled when generic_mii_ioctl()
> > returns.
> >=20
> > Since there is currently no need for any function to call
> > mdio_{read,write}() while holding another spinlock, do not change them
> > to save and restore IRQ flags but remove the specification of ordering
> > between vortex_private::lock and vortex_private::mii_lock.
> >=20
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > ---
> > I've now borrowed a card to test 3c59x on.  I've seen another regressio=
n
> > reported <http://bugs.debian.org/586967> after my locking changes, whic=
h
> > I can't reproduce.
>=20
> I think the lock is necessary, in some form.
>=20
> Nothing otherwise protects vp->mii, which is accessed and modified by
> not just this ioctl, but also ethtool operation calls.
>=20
> So we can't apply your patch as-is.

Hmm, yes, I forgot that mii caches information in struct mii_if_info.
Let me rethink this.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-7P8wafnjMSVQOizv5PeI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATH7J2ue/yOyVhhEJAQJxjQ//cnZEzDjyiHsSl3Fi8Nz9NxU1wMgDy04J
29xO2dCTzbtmqryr0jstzeq9lNDp912IVX+sRlralkHve+vaeUMA1QF+pIQE8NOX
QmW2BulEqiY2FdgUFGCraVWay8BLfbLR9jpNo9n7QF/5X1qdL4a0h1grxmBgdbc7
cVAW+jGn9Z5EfAd+trWZTgXyPdp9PErz77xwAHymH671CvM+grq46KlIY93gvO+9
FNfvv9SA915N/lo9gB/Jm3O9PBuHr8Zo8UkEARd2rtgWUUBv8Iy2dTpHWTLDfITo
QA9WENwj5m8XDwvKidlOCXrCjQVLSYBs7p8K7PPImWrpxRLYAxKNTWLjaC0iX8wI
hObtRhsMEv/4Ib5lhuRfj2ztBI4JFyN4s/TPwWbH87LZPcmYzsrulItYOz/Ey7Ep
6g8QmpgIYtziPGON1I6Zh+nGExzH1K32Y38eu/l4cFavOU9rCv+8ATcN4jgIIAPP
fhxEGmEnAPyevdMrFOKzCB2dyj1dbdGBKqNfXD1ynrEeN+VNqYoX8A6CZx3IEA1V
vogu1R1M4p9KzevN7vO2Ag8jGJ/qijjVTG3H/aSxEUvlxbJ49FmUrdb61NnMAwLZ
rCgJ/r1N3WeusP8U/7wRtABPSKqN/IIrQzIFmMGn9f3q+L0O7stL7CDMoSfjyLK8
XrR2l5g2Kug=
=Bwjx
-----END PGP SIGNATURE-----

--=-7P8wafnjMSVQOizv5PeI--
