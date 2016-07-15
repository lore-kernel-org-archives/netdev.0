From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: ti: cpmac: use phy_ethtool_{get|set}_link_ksettings
Date: Fri, 15 Jul 2016 12:39:02 +0200
Message-ID: <1468579142-14138-2-git-send-email-tremyfr@gmail.com>
References: <1468579142-14138-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: florian@openwrt.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36152 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932422AbcGOKjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 06:39:11 -0400
In-Reply-To: <1468579142-14138-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

There was a check on CAP_NET_ADMIN in cpmac_set_settings, but this
check is already done in dev_ethtool, so no need to repeat it before
calling the generic function.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/ti/cpmac.c |   23 ++---------------------
 1 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index f48e43b..f86497c 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -837,25 +837,6 @@ static int cpmac_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return phy_mii_ioctl(dev->phydev, ifr, cmd);
 }
 
-static int cpmac_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	if (dev->phydev)
-		return phy_ethtool_gset(dev->phydev, cmd);
-
-	return -EINVAL;
-}
-
-static int cpmac_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
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
 static void cpmac_get_ringparam(struct net_device *dev,
 						struct ethtool_ringparam *ring)
 {
@@ -893,12 +874,12 @@ static void cpmac_get_drvinfo(struct net_device *dev,
 }
 
 static const struct ethtool_ops cpmac_ethtool_ops = {
-	.get_settings = cpmac_get_settings,
-	.set_settings = cpmac_set_settings,
 	.get_drvinfo = cpmac_get_drvinfo,
 	.get_link = ethtool_op_get_link,
 	.get_ringparam = cpmac_get_ringparam,
 	.set_ringparam = cpmac_set_ringparam,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 static void cpmac_adjust_link(struct net_device *dev)
-- 
1.7.4.4
