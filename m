From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: [PATCH] Add the phy_device_release device method.
Date: Tue, 13 Nov 2007 11:21:40 +0100
Message-ID: <20071113102140.GA19820@avionic-tr-basi.adnet.avionic-design.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vkogqOf2sHV7VnPd"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:59725 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbXKMKVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 05:21:20 -0500
Received: from localhost (unknown [192.168.0.64])
	by benhur.intern.avionic-design.de (Postfix) with ESMTP id 283A72C4015
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 11:21:16 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

In cases where more than a single PHY is found on the MDIO bus, the kernel
will print a warning that this method is missing for each PHY device that
has not been attached to a networking device.
---
 drivers/net/phy/mdio_bus.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index fc2f0e6..cb7fb47 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -36,6 +36,23 @@
 #include <asm/uaccess.h>
=20
 /**
+ * phy_device_release - free a phy_device structure when all users of it a=
re
+ * 	finished.
+ *
+ * @dev: device that's been removed
+ *
+ * Will be called only by the device core when all users of this phy_device
+ * are done.
+ */
+static void phy_device_release(struct device *dev)
+{
+	struct phy_device *phy;
+
+	phy =3D to_phy_device(dev);
+	kfree(phy);
+}
+
+/**
  * mdiobus_register - bring up all the PHYs on a given bus and attach them=
 to bus
  * @bus: target mii_bus
  *
@@ -83,6 +100,7 @@ int mdiobus_register(struct mii_bus *bus)
 		if (phydev) {
 			phydev->irq =3D bus->irq[i];
=20
+			phydev->dev.release =3D phy_device_release;
 			phydev->dev.parent =3D bus->dev;
 			phydev->dev.bus =3D &mdio_bus_type;
 			snprintf(phydev->dev.bus_id, BUS_ID_SIZE, PHY_ID_FMT, bus->id, i);
@@ -112,7 +130,6 @@ void mdiobus_unregister(struct mii_bus *bus)
 	for (i =3D 0; i < PHY_MAX_ADDR; i++) {
 		if (bus->phy_map[i]) {
 			device_unregister(&bus->phy_map[i]->dev);
-			kfree(bus->phy_map[i]);
 		}
 	}
 }
--=20
1.5.3.5


--vkogqOf2sHV7VnPd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHOXq0/94dvhCMILwRAiOKAKC5AJzQrFqADSprLWH+oQWBVJU8VACdFWKG
//B3//CBSyZWD5rtb2wxkXU=
=3xtX
-----END PGP SIGNATURE-----

--vkogqOf2sHV7VnPd--
