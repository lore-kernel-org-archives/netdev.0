From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: greth: use phy_ethtool_{get|set}_link_ksettings
Date: Sat, 30 Jul 2016 16:22:06 +0200
Message-ID: <1469888526-8089-2-git-send-email-tremyfr@gmail.com>
References: <1469888526-8089-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: andreas@gaisler.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33706 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbcG3OWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 10:22:15 -0400
In-Reply-To: <1469888526-8089-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/aeroflex/greth.c |   23 ++---------------------
 1 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 010978b..f8df824 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1105,25 +1105,6 @@ static void greth_set_msglevel(struct net_device *dev, u32 value)
 	struct greth_private *greth = netdev_priv(dev);
 	greth->msg_enable = value;
 }
-static int greth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phy = dev->phydev;
-
-	if (!phy)
-		return -ENODEV;
-
-	return phy_ethtool_gset(phy, cmd);
-}
-
-static int greth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phy = dev->phydev;
-
-	if (!phy)
-		return -ENODEV;
-
-	return phy_ethtool_sset(phy, cmd);
-}
 
 static int greth_get_regs_len(struct net_device *dev)
 {
@@ -1155,12 +1136,12 @@ static void greth_get_regs(struct net_device *dev, struct ethtool_regs *regs, vo
 static const struct ethtool_ops greth_ethtool_ops = {
 	.get_msglevel		= greth_get_msglevel,
 	.set_msglevel		= greth_set_msglevel,
-	.get_settings		= greth_get_settings,
-	.set_settings		= greth_set_settings,
 	.get_drvinfo		= greth_get_drvinfo,
 	.get_regs_len           = greth_get_regs_len,
 	.get_regs               = greth_get_regs,
 	.get_link		= ethtool_op_get_link,
+	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
+	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
 };
 
 static struct net_device_ops greth_netdev_ops = {
-- 
1.7.4.4
