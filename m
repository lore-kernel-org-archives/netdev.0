From: Matt Porter <mporter@kernel.crashing.org>
Subject: [PATCH] emac: fix mdio delay
Date: Tue, 8 Feb 2005 22:43:45 -0700
Message-ID: <20050208224345.B12821@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralphs@netwinder.org, netdev@oss.sgi.com, linuxppc-embedded@ozlabs.org
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes MDIO delay. Please apply.

Signed-off-by: Ralph Siemsen <ralphs@netwinder.org>
Signed-off-by: Matt Porter <mporter@kernel.crashing.org>

--- linux-2.6.10-orig/drivers/net/ibm_emac/ibm_emac_core.c	2005-01-20 15:45:28.576226303 -0500
+++ linux-2.6.10/drivers/net/ibm_emac/ibm_emac_core.c	2005-01-20 15:25:10.430674655 -0500
@@ -475,8 +479,9 @@
 
 	out_be32(&emacp->em0stacr, stacr);
 
-	while (((stacr = in_be32(&emacp->em0stacr) & EMAC_STACR_OC) == 0)
-					&& (count++ < 5000))
+	count = 0;
+	while ((((stacr = in_be32(&emacp->em0stacr)) & EMAC_STACR_OC) == 0)
+					&& (count++ < MDIO_DELAY))
 		udelay(1);
 	MDIO_DEBUG((" (count was %d)\n", count));
