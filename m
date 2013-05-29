From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 06/11] net: emaclite: Report failures in mdio setup
Date: Wed, 29 May 2013 17:33:06 +0200
Message-ID: <eaeecf9ad936704028401e97b315d2bfc18ad175.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-27621-1369841611-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
In-Reply-To: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-27621-1369841611-0001

Be more verbose when any problem happens.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 919b983..a16dc35 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -852,8 +852,10 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 	/* Don't register the MDIO bus if the phy_node or its parent node
 	 * can't be found.
 	 */
-	if (!np)
+	if (!np) {
+		dev_err(dev, "Failed to register mdio bus.\n");
 		return -ENODEV;
+	}

 	/* Enable the MDIO bus by asserting the enable bit in MDIO Control
 	 * register.
@@ -862,8 +864,10 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 		 XEL_MDIOCTRL_MDIOEN_MASK);

 	bus = mdiobus_alloc();
-	if (!bus)
+	if (!bus) {
+		dev_err(dev, "Failed to allocal mdiobus\n");
 		return -ENOMEM;
+	}

 	of_address_to_resource(np, 0, &res);
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%.8llx",
@@ -879,8 +883,10 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 	lp->mii_bus = bus;

 	rc = of_mdiobus_register(bus, np);
-	if (rc)
+	if (rc) {
+		dev_err(dev, "Failed to register mdio bus.\n");
 		goto err_register;
+	}

 	return 0;

--
1.8.2.3


--=_mimegpg-monstr-desktop-27621-1369841611-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGmH8sACgkQykllyylKDCFx2wCcDMGJ7P96nYDCyVw/TFXl9Fr4
OecAoJbu2p2vjc+1PDjHriHv3PgNdwlM
=1kUD
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-27621-1369841611-0001--
