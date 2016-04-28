From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: [PATCH] net: macb: do not scan PHYs manually
Date: Thu, 28 Apr 2016 09:19:47 -0500
Message-ID: <1461853187-31715-1-git-send-email-nathan.sullivan@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nathan Sullivan <nathan.sullivan@ni.com>
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:37415 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752270AbcD1OUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 10:20:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since of_mdiobus_register and mdiobus_register will scan automatically,
do not manually scan for PHY devices in the macb ethernet driver. Doing
so will result in many nonexistent PHYs on the MDIO bus if the MDIO
lines are floating or grounded, such as when they are not used.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---
 drivers/net/ethernet/cadence/macb.c |   17 -----------------
 1 file changed, 17 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 48a7d7d..e80e487 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -450,23 +450,6 @@ static int macb_mii_init(struct macb *bp)
 	if (np) {
 		/* try dt phy registration */
 		err = of_mdiobus_register(bp->mii_bus, np);
-
-		/* fallback to standard phy registration if no phy were
-		   found during dt phy registration */
-		if (!err && !phy_find_first(bp->mii_bus)) {
-			for (i = 0; i < PHY_MAX_ADDR; i++) {
-				struct phy_device *phydev;
-
-				phydev = mdiobus_scan(bp->mii_bus, i);
-				if (IS_ERR(phydev)) {
-					err = PTR_ERR(phydev);
-					break;
-				}
-			}
-
-			if (err)
-				goto err_out_unregister_bus;
-		}
 	} else {
 		if (pdata)
 			bp->mii_bus->phy_mask = pdata->phy_mask;
-- 
1.7.10.4
