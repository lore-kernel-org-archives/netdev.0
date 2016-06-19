From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: bgmac: use phy_ethtool_{get|set}_link_ksettings
Date: Sun, 19 Jun 2016 22:37:06 +0200
Message-ID: <1466368626-28985-2-git-send-email-tremyfr@gmail.com>
References: <1466368626-28985-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, f.fainelli@gmail.com, zajec5@gmail.com,
	fabio.estevam@freescale.com, jkosina@suse.cz, andrew@lunn.ch,
	nbd@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34476 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbcFSUj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 16:39:28 -0400
In-Reply-To: <1466368626-28985-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |   20 ++------------------
 1 files changed, 2 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 90ed244..e6e74ca 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1511,22 +1511,6 @@ static void bgmac_get_ethtool_stats(struct net_device *dev,
 	}
 }
 
-static int bgmac_get_settings(struct net_device *net_dev,
-			      struct ethtool_cmd *cmd)
-{
-	struct bgmac *bgmac = netdev_priv(net_dev);
-
-	return phy_ethtool_gset(net_dev->phydev, cmd);
-}
-
-static int bgmac_set_settings(struct net_device *net_dev,
-			      struct ethtool_cmd *cmd)
-{
-	struct bgmac *bgmac = netdev_priv(net_dev);
-
-	return phy_ethtool_sset(net_dev->phydev, cmd);
-}
-
 static void bgmac_get_drvinfo(struct net_device *net_dev,
 			      struct ethtool_drvinfo *info)
 {
@@ -1538,9 +1522,9 @@ static const struct ethtool_ops bgmac_ethtool_ops = {
 	.get_strings		= bgmac_get_strings,
 	.get_sset_count		= bgmac_get_sset_count,
 	.get_ethtool_stats	= bgmac_get_ethtool_stats,
-	.get_settings		= bgmac_get_settings,
-	.set_settings		= bgmac_set_settings,
 	.get_drvinfo		= bgmac_get_drvinfo,
+	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
 };
 
 /**************************************************
-- 
1.7.4.4
