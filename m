From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: xilinx: axienet: use phy_ethtool_{get|set}_link_ksettings
Date: Thu, 14 Jul 2016 19:45:58 +0200
Message-ID: <1468518358-28735-2-git-send-email-tremyfr@gmail.com>
References: <1468518358-28735-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: anirudh@xilinx.com, John.Linn@xilinx.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468518358-28735-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |   47 +--------------------
 1 files changed, 2 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 71abd00..9c82993 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1077,49 +1077,6 @@ static const struct net_device_ops axienet_netdev_ops = {
 };
 
 /**
- * axienet_ethtools_get_settings - Get Axi Ethernet settings related to PHY.
- * @ndev:	Pointer to net_device structure
- * @ecmd:	Pointer to ethtool_cmd structure
- *
- * This implements ethtool command for getting PHY settings. If PHY could
- * not be found, the function returns -ENODEV. This function calls the
- * relevant PHY ethtool API to get the PHY settings.
- * Issue "ethtool ethX" under linux prompt to execute this function.
- *
- * Return: 0 on success, -ENODEV if PHY doesn't exist
- */
-static int axienet_ethtools_get_settings(struct net_device *ndev,
-					 struct ethtool_cmd *ecmd)
-{
-	struct phy_device *phydev = ndev->phydev;
-	if (!phydev)
-		return -ENODEV;
-	return phy_ethtool_gset(phydev, ecmd);
-}
-
-/**
- * axienet_ethtools_set_settings - Set PHY settings as passed in the argument.
- * @ndev:	Pointer to net_device structure
- * @ecmd:	Pointer to ethtool_cmd structure
- *
- * This implements ethtool command for setting various PHY settings. If PHY
- * could not be found, the function returns -ENODEV. This function calls the
- * relevant PHY ethtool API to set the PHY.
- * Issue e.g. "ethtool -s ethX speed 1000" under linux prompt to execute this
- * function.
- *
- * Return: 0 on success, -ENODEV if PHY doesn't exist
- */
-static int axienet_ethtools_set_settings(struct net_device *ndev,
-					 struct ethtool_cmd *ecmd)
-{
-	struct phy_device *phydev = ndev->phydev;
-	if (!phydev)
-		return -ENODEV;
-	return phy_ethtool_sset(phydev, ecmd);
-}
-
-/**
  * axienet_ethtools_get_drvinfo - Get various Axi Ethernet driver information.
  * @ndev:	Pointer to net_device structure
  * @ed:		Pointer to ethtool_drvinfo structure
@@ -1341,8 +1298,6 @@ static int axienet_ethtools_set_coalesce(struct net_device *ndev,
 }
 
 static struct ethtool_ops axienet_ethtool_ops = {
-	.get_settings   = axienet_ethtools_get_settings,
-	.set_settings   = axienet_ethtools_set_settings,
 	.get_drvinfo    = axienet_ethtools_get_drvinfo,
 	.get_regs_len   = axienet_ethtools_get_regs_len,
 	.get_regs       = axienet_ethtools_get_regs,
@@ -1351,6 +1306,8 @@ static struct ethtool_ops axienet_ethtool_ops = {
 	.set_pauseparam = axienet_ethtools_set_pauseparam,
 	.get_coalesce   = axienet_ethtools_get_coalesce,
 	.set_coalesce   = axienet_ethtools_set_coalesce,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 /**
-- 
1.7.4.4
