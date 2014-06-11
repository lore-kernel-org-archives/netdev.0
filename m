From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] amd-xgbe: unwind on error in xgbe_mdio_register()
Date: Wed, 11 Jun 2014 09:56:26 +0300
Message-ID: <20140611065626.GC16443@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31597 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbaFKG4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 02:56:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a typo here so we return directly instead of unwinding.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 52bbdbf..ea7a5d6 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -367,7 +367,7 @@ int xgbe_mdio_register(struct xgbe_prv_data *pdata)
 
 	if (!phydev->drv || (phydev->drv->phy_id == 0)) {
 		netdev_err(netdev, "phy_id not valid\n");
-		return -ENODEV;
+		ret = -ENODEV;
 		goto err_phy_connect;
 	}
 	DBGPR("  phy_connect_direct succeeded for PHY %s, link=%d\n",
