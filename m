From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 03/12] amd-xgbe: Add check to be sure
 amd-xgbe-phy driver is used
Date: Fri, 16 Jan 2015 12:46:34 -0600
Message-ID: <20150116184634.18809.25423.stgit@tlendack-t1.amdoffice.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44025 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756794AbbAPSy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:29 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The amd-xgbe driver relies on the amd-xgbe-phy phylib driver. Add a
check to be sure that if any errors occur during probing of the
amd-xgbe-phy driver then the amd-xgbe driver returns an error.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 7eeb03d..41e29e2 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -260,10 +260,14 @@ int xgbe_mdio_register(struct xgbe_prv_data *pdata)
 		of_node_put(phy_node);
 		goto err_phy_device;
 	}
+	if (!phydev->dev.driver) {
+		dev_err(pdata->dev, "phy driver probe failed\n");
+		ret = -EIO;
+		goto err_phy_device;
+	}
 
 	/* Add a reference to the PHY driver so it can't be unloaded */
-	pdata->phy_module = phydev->dev.driver ?
-			    phydev->dev.driver->owner : NULL;
+	pdata->phy_module = phydev->dev.driver->owner;
 	if (!try_module_get(pdata->phy_module)) {
 		dev_err(pdata->dev, "try_module_get failed\n");
 		ret = -EIO;
