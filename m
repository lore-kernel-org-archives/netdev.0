From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: adi: bfin_mac: use phy_ethtool_{get|set}_link_ksettings
Date: Sun, 17 Jul 2016 01:10:15 +0200
Message-ID: <1468710615-31951-2-git-send-email-tremyfr@gmail.com>
References: <1468710615-31951-1-git-send-email-tremyfr@gmail.com>
Cc: adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, andrew@lunn.ch, sudipm.mukherjee@gmail.com,
	mugunthanvnm@ti.com, felipe.balbi@linux.intel.com,
	treding@nvidia.com, fw@strlen.de, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35699 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbcGPXK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 19:10:26 -0400
In-Reply-To: <1468710615-31951-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

There was a check on CAP_NET_ADMIN in bfin_mac_ethtool_setsettings,
but this check is already done in dev_ethtool, so no need to repeat
it before calling the generic function.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/adi/bfin_mac.c |   25 ++-----------------------
 1 files changed, 2 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 32af9d2..38eaea1 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -449,27 +449,6 @@ static irqreturn_t bfin_mac_wake_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static int
-bfin_mac_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	if (dev->phydev)
-		return phy_ethtool_gset(dev->phydev, cmd);
-
-	return -EINVAL;
-}
-
-static int
-bfin_mac_ethtool_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	if (dev->phydev)
-		return phy_ethtool_sset(dev->phydev, cmd);
-
-	return -EINVAL;
-}
-
 static void bfin_mac_ethtool_getdrvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *info)
 {
@@ -547,8 +526,6 @@ static int bfin_mac_ethtool_get_ts_info(struct net_device *dev,
 #endif
 
 static const struct ethtool_ops bfin_mac_ethtool_ops = {
-	.get_settings = bfin_mac_ethtool_getsettings,
-	.set_settings = bfin_mac_ethtool_setsettings,
 	.get_link = ethtool_op_get_link,
 	.get_drvinfo = bfin_mac_ethtool_getdrvinfo,
 	.get_wol = bfin_mac_ethtool_getwol,
@@ -556,6 +533,8 @@ static const struct ethtool_ops bfin_mac_ethtool_ops = {
 #ifdef CONFIG_BFIN_MAC_USE_HWSTAMP
 	.get_ts_info = bfin_mac_ethtool_get_ts_info,
 #endif
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 /**************************************************************************/
-- 
1.7.4.4
