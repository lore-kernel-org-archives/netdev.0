From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 02/10] amd-xgbe-phy: Use the phy_driver flags field
Date: Thu, 19 Mar 2015 12:12:37 -0500
Message-ID: <20150319171237.26446.67682.stgit@tlendack-t1.amdoffice.net>
References: <20150319171225.26446.36048.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0134.outbound.protection.outlook.com ([157.56.110.134]:2688
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751303AbbCSR1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 13:27:45 -0400
In-Reply-To: <20150319171225.26446.36048.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the setting of the transceiver type when retrieving the device
settings using ethtool and instead set the transceiver type in the
phy_driver structure flags field. Change the transceiver type to be
internal, also.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |    1 -
 drivers/net/phy/amd-xgbe-phy.c               |    1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index ebf4893..43e5571 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -291,7 +291,6 @@ static int xgbe_get_settings(struct net_device *netdev,
 		return -ENODEV;
 
 	ret = phy_ethtool_gset(pdata->phydev, cmd);
-	cmd->transceiver = XCVR_EXTERNAL;
 
 	DBGPR("<--xgbe_get_settings\n");
 
diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index acb4449..4b95caf 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -1816,6 +1816,7 @@ static struct phy_driver amd_xgbe_phy_driver[] = {
 		.phy_id_mask		= XGBE_PHY_MASK,
 		.name			= "AMD XGBE PHY",
 		.features		= 0,
+		.flags			= PHY_IS_INTERNAL,
 		.probe			= amd_xgbe_phy_probe,
 		.remove			= amd_xgbe_phy_remove,
 		.soft_reset		= amd_xgbe_phy_soft_reset,
