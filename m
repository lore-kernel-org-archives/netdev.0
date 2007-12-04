From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: [PATCH][RESEND] PHY: Add the phy_device_release device method.
Date: Tue, 4 Dec 2007 08:38:47 +0100
Message-ID: <20071204073847.GA881@avionic-tr-basi.adnet.avionic-design.de>
References: <20071119.214215.207388094.davem@davemloft.net> <4751D9F3.5090502@garzik.org> <20071203083511.GA9396@avionic-tr-basi.adnet.avionic-design.de> <20071203214440.78709615.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Dxnq1zWXvFF0Q93v"
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:53052 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbXLDHit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 02:38:49 -0500
Content-Disposition: inline
In-Reply-To: <20071203214440.78709615.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* Andrew Morton wrote:
> On Mon, 3 Dec 2007 09:35:11 +0100 Thierry Reding <thierry.reding@avionic-=
design.de> wrote:
>=20
> > In cases where more than a single PHY is found on the MDIO bus, the ker=
nel
> > will print a warning that this method is missing for each PHY device th=
at
> > is not attached to a networking device.
> >=20
> > Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>
> > ---
> >  drivers/net/phy/mdio_bus.c |   19 ++++++++++++++++++-
> >  1 files changed, 18 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> > index fc2f0e6..cb7fb47 100644
> > --- a/drivers/net/phy/mdio_bus.c
> > +++ b/drivers/net/phy/mdio_bus.c
> > @@ -36,6 +36,23 @@
> >  #include <asm/uaccess.h>
> > =20
> >  /**
> > + * phy_device_release - free a phy_device structure when all users of =
it are
> > + * 	finished.
> > + *
> > + * @dev: device that's been disconnected
> > + *
> > + * Will be called only by the device core when all users of this phy_d=
evice
> > + * are done.
> > + */
> > +static void phy_device_release(struct device *dev)
> > +{
> > +	struct phy_device *phy;
> > +
> > +	phy =3D to_phy_device(dev);
> > +	kfree(phy);
> > +}
> > +
> > +/**
> >   * mdiobus_register - bring up all the PHYs on a given bus and attach =
them to bus
> >   * @bus: target mii_bus
> >   *
> > @@ -83,6 +100,7 @@ int mdiobus_register(struct mii_bus *bus)
> >  		if (phydev) {
> >  			phydev->irq =3D bus->irq[i];
> > =20
> > +			phydev->dev.release =3D phy_device_release;
> >  			phydev->dev.parent =3D bus->dev;
> >  			phydev->dev.bus =3D &mdio_bus_type;
> >  			snprintf(phydev->dev.bus_id, BUS_ID_SIZE, PHY_ID_FMT, bus->id, i);
> > @@ -112,7 +130,6 @@ void mdiobus_unregister(struct mii_bus *bus)
> >  	for (i =3D 0; i < PHY_MAX_ADDR; i++) {
> >  		if (bus->phy_map[i]) {
> >  			device_unregister(&bus->phy_map[i]->dev);
> > -			kfree(bus->phy_map[i]);
> >  		}
> >  	}
> >  }
> >=20
>=20
> I've been sitting on
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc3/=
2.6.24-rc3-mm2/broken-out/phy-implement-release-function.patch
> for a few weeks.  For some reason I have it in my "nacked netdev patches"
> section but I think that was a mistake and it has not (yet ;)) been nacke=
d.
>=20
> Anyway, Anton's patch looks somewhat different from yours.  Please compare
> notes.

FWIW, I like Anton's patch better, especially since it plugs a possible
memory leak. I'm not sure it's useful or necessary to export the
phy_device_free symbol, though.

The only other difference that I can see is that Anton's patch sets the
release function in a different place, when the device is created, whereas =
my
patch only sets it before registering the device. Both should be identical
since the release function won't be needed unless the device is registered.

Thierry


--Dxnq1zWXvFF0Q93v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD4DBQFHVQQH/94dvhCMILwRAhS5AKDKDgrregmPxqR9y3FImz2Lhhz/+QCXUqxB
EORN4vRDSCY+0o3lRwP3cA==
=zOrw
-----END PGP SIGNATURE-----

--Dxnq1zWXvFF0Q93v--
