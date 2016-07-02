From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: arc: emac: use phy_ethtool_{get|set}_link_ksettings
Date: Sat,  2 Jul 2016 20:06:52 +0200
Message-ID: <1467482812-13917-2-git-send-email-tremyfr@gmail.com>
References: <1467482812-13917-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, wxt@rock-chips.com, heiko@sntech.de,
	al.kochet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467482812-13917-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/arc/emac_main.c |   40 +--------------------------------
 1 files changed, 2 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index a8a1dc9..586beda 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -80,42 +80,6 @@ static void arc_emac_adjust_link(struct net_device *ndev)
 }
 
 /**
- * arc_emac_get_settings - Get PHY settings.
- * @ndev:	Pointer to net_device structure.
- * @cmd:	Pointer to ethtool_cmd structure.
- *
- * This implements ethtool command for getting PHY settings. If PHY could
- * not be found, the function returns -ENODEV. This function calls the
- * relevant PHY ethtool API to get the PHY settings.
- * Issue "ethtool ethX" under linux prompt to execute this function.
- */
-static int arc_emac_get_settings(struct net_device *ndev,
-				 struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_gset(ndev->phydev, cmd);
-}
-
-/**
- * arc_emac_set_settings - Set PHY settings as passed in the argument.
- * @ndev:	Pointer to net_device structure.
- * @cmd:	Pointer to ethtool_cmd structure.
- *
- * This implements ethtool command for setting various PHY settings. If PHY
- * could not be found, the function returns -ENODEV. This function calls the
- * relevant PHY ethtool API to set the PHY.
- * Issue e.g. "ethtool -s ethX speed 1000" under linux prompt to execute this
- * function.
- */
-static int arc_emac_set_settings(struct net_device *ndev,
-				 struct ethtool_cmd *cmd)
-{
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	return phy_ethtool_sset(ndev->phydev, cmd);
-}
-
-/**
  * arc_emac_get_drvinfo - Get EMAC driver information.
  * @ndev:	Pointer to net_device structure.
  * @info:	Pointer to ethtool_drvinfo structure.
@@ -133,10 +97,10 @@ static void arc_emac_get_drvinfo(struct net_device *ndev,
 }
 
 static const struct ethtool_ops arc_emac_ethtool_ops = {
-	.get_settings	= arc_emac_get_settings,
-	.set_settings	= arc_emac_set_settings,
 	.get_drvinfo	= arc_emac_get_drvinfo,
 	.get_link	= ethtool_op_get_link,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 #define FIRST_OR_LAST_MASK	(FIRST_MASK | LAST_MASK)
-- 
1.7.4.4
