From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH: 2.6.12-rc1] mii: GigE support bug fixes
Date: Tue, 22 Mar 2005 16:15:08 -0700
Message-ID: <20050322231508.GA27373@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes a couple bugs in mii.c GigE support.

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
Acked-by: James Chapman <jchapman@katalix.com>

Index: linux-2.5-enet/drivers/net/mii.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mii.c
+++ linux-2.5-enet/drivers/net/mii.c
@@ -43,6 +43,9 @@
 	    (SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
 	     SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 	     SUPPORTED_Autoneg | SUPPORTED_TP | SUPPORTED_MII);
+	if (mii->supports_gmii)
+		ecmd->supported |= SUPPORTED_1000baseT_Half |
+			SUPPORTED_1000baseT_Full;
 
 	/* only supports twisted-pair */
 	ecmd->port = PORT_MII;
@@ -100,7 +103,7 @@
 	} else {
 		ecmd->autoneg = AUTONEG_DISABLE;
 
-		ecmd->speed = ((bmcr2 & BMCR_SPEED1000 && 
+		ecmd->speed = ((bmcr & BMCR_SPEED1000 && 
 				(bmcr & BMCR_SPEED100) == 0) ? SPEED_1000 :
 			       (bmcr & BMCR_SPEED100) ? SPEED_100 : SPEED_10);
 		ecmd->duplex = (bmcr & BMCR_FULLDPLX) ? DUPLEX_FULL : DUPLEX_HALF;
@@ -163,9 +166,9 @@
 			tmp |= ADVERTISE_100FULL;
 		if (mii->supports_gmii) {
 			if (ecmd->advertising & ADVERTISED_1000baseT_Half)
-				advert2 |= ADVERTISE_1000HALF;
+				tmp2 |= ADVERTISE_1000HALF;
 			if (ecmd->advertising & ADVERTISED_1000baseT_Full)
-				advert2 |= ADVERTISE_1000FULL;
+				tmp2 |= ADVERTISE_1000FULL;
 		}
 		if (advert != tmp) {
 			mii->mdio_write(dev, mii->phy_id, MII_ADVERTISE, tmp);
