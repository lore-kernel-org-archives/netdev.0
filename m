From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: fec-mpc52xx: use phy_ethtool_{get|set}_link_ksettings
Date: Tue, 17 May 2016 00:32:34 +0200
Message-ID: <1463437954-6014-2-git-send-email-tremyfr@gmail.com>
References: <1463437954-6014-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, treding@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36311 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbcEPWcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 18:32:45 -0400
In-Reply-To: <1463437954-6014-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/fec_mpc52xx.c |   26 ++------------------------
 1 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index bcf0600..446ae9d 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -762,28 +762,6 @@ static void mpc52xx_fec_reset(struct net_device *dev)
 
 /* ethtool interface */
 
-static int mpc52xx_fec_get_ksettings(struct net_device *dev,
-				     struct ethtool_link_ksettings *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_ksettings_get(phydev, cmd);
-}
-
-static int mpc52xx_fec_set_ksettings(struct net_device *dev,
-				     const struct ethtool_link_ksettings *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_ksettings_set(phydev, cmd);
-}
-
 static u32 mpc52xx_fec_get_msglevel(struct net_device *dev)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
@@ -801,8 +779,8 @@ static const struct ethtool_ops mpc52xx_fec_ethtool_ops = {
 	.get_msglevel = mpc52xx_fec_get_msglevel,
 	.set_msglevel = mpc52xx_fec_set_msglevel,
 	.get_ts_info = ethtool_op_get_ts_info,
-	.get_link_ksettings = mpc52xx_fec_get_ksettings,
-	.set_link_ksettings = mpc52xx_fec_set_ksettings,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 
-- 
1.7.4.4
