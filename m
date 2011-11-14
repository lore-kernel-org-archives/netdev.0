From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] net: fsl_pq_mdio: fix non tbi phy access
Date: Mon, 14 Nov 2011 08:21:30 +0200
Message-ID: <b693b45a689d42b60a8a9e29dcdd2fb27e20df82.1321251618.git.baruch@tkos.co.il>
Cc: Baruch Siach <baruch@tkos.co.il>,
	Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:37719 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054Ab1KNGWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 01:22:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 952c5ca1 (fsl_pq_mdio: Clean up tbi address configuration) .probe returns
-EBUSY when the "tbi-phy" node is missing. Fix this.

Cc: Andy Fleming <afleming@freescale.com>
Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 4d9f84b..8dee1ae 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -356,16 +356,16 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 
 		if (prop)
 			tbiaddr = *prop;
-	}
 
-	if (tbiaddr == -1) {
-		err = -EBUSY;
+		if (tbiaddr == -1) {
+			err = -EBUSY;
 
-		goto err_free_irqs;
+			goto err_free_irqs;
+		} else {
+			out_be32(tbipa, tbiaddr);
+		}
 	}
 
-	out_be32(tbipa, tbiaddr);
-
 	err = of_mdiobus_register(new_bus, np);
 	if (err) {
 		printk (KERN_ERR "%s: Cannot register as MDIO bus\n",
-- 
1.7.7.1
