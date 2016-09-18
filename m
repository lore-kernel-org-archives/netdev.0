From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: ethernet: broadcom: bcmgenet: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 18 Sep 2016 17:16:45 +0200
Message-ID: <1474211805-5703-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: f.fainelli@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36741 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932796AbcIRPQy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 11:16:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 46f9043..2013474 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -450,8 +450,8 @@ static inline void bcmgenet_rdma_ring_writel(struct bcmgenet_priv *priv,
 			genet_dma_ring_regs[r]);
 }
 
-static int bcmgenet_get_settings(struct net_device *dev,
-				 struct ethtool_cmd *cmd)
+static int bcmgenet_get_link_ksettings(struct net_device *dev,
+				       struct ethtool_link_ksettings *cmd)
 {
 	if (!netif_running(dev))
 		return -EINVAL;
@@ -459,11 +459,11 @@ static int bcmgenet_get_settings(struct net_device *dev,
 	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_gset(dev->phydev, cmd);
+	return phy_ethtool_ksettings_get(dev->phydev, cmd);
 }
 
-static int bcmgenet_set_settings(struct net_device *dev,
-				 struct ethtool_cmd *cmd)
+static int bcmgenet_set_link_ksettings(struct net_device *dev,
+				       const struct ethtool_link_ksettings *cmd)
 {
 	if (!netif_running(dev))
 		return -EINVAL;
@@ -471,7 +471,7 @@ static int bcmgenet_set_settings(struct net_device *dev,
 	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_sset(dev->phydev, cmd);
+	return phy_ethtool_ksettings_set(dev->phydev, cmd);
 }
 
 static int bcmgenet_set_rx_csum(struct net_device *dev,
@@ -977,8 +977,6 @@ static const struct ethtool_ops bcmgenet_ethtool_ops = {
 	.get_strings		= bcmgenet_get_strings,
 	.get_sset_count		= bcmgenet_get_sset_count,
 	.get_ethtool_stats	= bcmgenet_get_ethtool_stats,
-	.get_settings		= bcmgenet_get_settings,
-	.set_settings		= bcmgenet_set_settings,
 	.get_drvinfo		= bcmgenet_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_msglevel		= bcmgenet_get_msglevel,
@@ -990,6 +988,8 @@ static const struct ethtool_ops bcmgenet_ethtool_ops = {
 	.nway_reset		= bcmgenet_nway_reset,
 	.get_coalesce		= bcmgenet_get_coalesce,
 	.set_coalesce		= bcmgenet_set_coalesce,
+	.get_link_ksettings	= bcmgenet_get_link_ksettings,
+	.set_link_ksettings	= bcmgenet_set_link_ksettings,
 };
 
 /* Power down the unimac, based on mode. */
-- 
1.7.4.4
