From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: davinci_emac: use phy_ethtool_{get|set}_link_ksettings
Date: Sat,  2 Jul 2016 00:02:35 +0200
Message-ID: <1467410555-19514-2-git-send-email-tremyfr@gmail.com>
References: <1467410555-19514-1-git-send-email-tremyfr@gmail.com>
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36522 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbcGAWCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:02:46 -0400
In-Reply-To: <1467410555-19514-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/ti/davinci_emac.c |   39 +------------------------------
 1 files changed, 2 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 76683c7..c6c5465 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -485,41 +485,6 @@ static void emac_get_drvinfo(struct net_device *ndev,
 }
 
 /**
- * emac_get_settings - Get EMAC settings
- * @ndev: The DaVinci EMAC network adapter
- * @ecmd: ethtool command
- *
- * Executes ethool get command
- *
- */
-static int emac_get_settings(struct net_device *ndev,
-			     struct ethtool_cmd *ecmd)
-{
-	if (ndev->phydev)
-		return phy_ethtool_gset(ndev->phydev, ecmd);
-	else
-		return -EOPNOTSUPP;
-
-}
-
-/**
- * emac_set_settings - Set EMAC settings
- * @ndev: The DaVinci EMAC network adapter
- * @ecmd: ethtool command
- *
- * Executes ethool set command
- *
- */
-static int emac_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
-{
-	if (ndev->phydev)
-		return phy_ethtool_sset(ndev->phydev, ecmd);
-	else
-		return -EOPNOTSUPP;
-
-}
-
-/**
  * emac_get_coalesce - Get interrupt coalesce settings for this device
  * @ndev : The DaVinci EMAC network adapter
  * @coal : ethtool coalesce settings structure
@@ -622,12 +587,12 @@ static int emac_set_coalesce(struct net_device *ndev,
  */
 static const struct ethtool_ops ethtool_ops = {
 	.get_drvinfo = emac_get_drvinfo,
-	.get_settings = emac_get_settings,
-	.set_settings = emac_set_settings,
 	.get_link = ethtool_op_get_link,
 	.get_coalesce = emac_get_coalesce,
 	.set_coalesce =  emac_set_coalesce,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 /**
-- 
1.7.4.4
