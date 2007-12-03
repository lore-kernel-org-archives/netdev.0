From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: [PATCH][RESEND] PHY: Add the phy_device_release device method.
Date: Mon, 3 Dec 2007 09:35:11 +0100
Message-ID: <20071203083511.GA9396@avionic-tr-basi.adnet.avionic-design.de>
References: <20071119.214215.207388094.davem@davemloft.net> <4751D9F3.5090502@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xHFwDpU9dbj6ez1V"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:61870 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828AbXLCIfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 03:35:36 -0500
Content-Disposition: inline
In-Reply-To: <4751D9F3.5090502@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

In cases where more than a single PHY is found on the MDIO bus, the kernel
will print a warning that this method is missing for each PHY device that
is not attached to a networking device.

Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>
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
+ * @dev: device that's been disconnected
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

--xHFwDpU9dbj6ez1V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHU7+//94dvhCMILwRAtZWAJ9CB1t7QnprCohUuFFckB6ROFDSlQCdEOoe
RG/yz8YSAfkmXI46qjC+24w=
=Kh1/
-----END PGP SIGNATURE-----

--xHFwDpU9dbj6ez1V--
