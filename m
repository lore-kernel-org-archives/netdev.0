From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: sxgbe: use phy_ethtool_{get|set}_link_ksettings
Date: Sat, 25 Jun 2016 22:05:27 +0200
Message-ID: <1466885127-27794-2-git-send-email-tremyfr@gmail.com>
References: <1466885127-27794-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36516 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbcFYUFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 16:05:39 -0400
In-Reply-To: <1466885127-27794-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c |   21 +------------------
 1 files changed, 2 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
index 72c9108..542b67d 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
@@ -182,23 +182,6 @@ static void sxgbe_getdrvinfo(struct net_device *dev,
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 }
 
-static int sxgbe_getsettings(struct net_device *dev,
-			     struct ethtool_cmd *cmd)
-{
-	if (dev->phydev)
-		return phy_ethtool_gset(dev->phydev, cmd);
-
-	return -EOPNOTSUPP;
-}
-
-static int sxgbe_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	if (dev->phydev)
-		return phy_ethtool_sset(dev->phydev, cmd);
-
-	return -EOPNOTSUPP;
-}
-
 static u32 sxgbe_getmsglevel(struct net_device *dev)
 {
 	struct sxgbe_priv_data *priv = netdev_priv(dev);
@@ -495,8 +478,6 @@ static int sxgbe_get_regs_len(struct net_device *dev)
 
 static const struct ethtool_ops sxgbe_ethtool_ops = {
 	.get_drvinfo = sxgbe_getdrvinfo,
-	.get_settings = sxgbe_getsettings,
-	.set_settings = sxgbe_setsettings,
 	.get_msglevel = sxgbe_getmsglevel,
 	.set_msglevel = sxgbe_setmsglevel,
 	.get_link = ethtool_op_get_link,
@@ -512,6 +493,8 @@ static const struct ethtool_ops sxgbe_ethtool_ops = {
 	.get_regs_len = sxgbe_get_regs_len,
 	.get_eee = sxgbe_get_eee,
 	.set_eee = sxgbe_set_eee,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 void sxgbe_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
