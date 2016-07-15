From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: amd: au1000_eth: use phy_ethtool_{get|set}_link_ksettings
Date: Fri, 15 Jul 2016 12:05:12 +0200
Message-ID: <1468577112-7884-2-git-send-email-tremyfr@gmail.com>
References: <1468577112-7884-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, andrew@lunn.ch, f.fainelli@gmail.com,
	manuel.lauss@gmail.com, mugunthanvnm@ti.com, ivecera@redhat.com,
	xypron.glpk@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36749 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788AbcGOKFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 06:05:22 -0400
Received: by mail-wm0-f65.google.com with SMTP id x83so1647503wma.3
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 03:05:22 -0700 (PDT)
In-Reply-To: <1468577112-7884-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

There was a check on CAP_NET_ADMIN in au1000_set_settings, but this
check is already done in dev_ethtool, so no need to repeat it before
calling the generic function.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/amd/au1000_eth.c |   23 ++---------------------
 1 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 18fe333..df66418 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -677,25 +677,6 @@ au1000_setup_hw_rings(struct au1000_private *aup, void __iomem *tx_base)
  * ethtool operations
  */
 
-static int au1000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	if (dev->phydev)
-		return phy_ethtool_gset(dev->phydev, cmd);
-
-	return -EINVAL;
-}
-
-static int au1000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
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
 static void
 au1000_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
@@ -720,12 +701,12 @@ static u32 au1000_get_msglevel(struct net_device *dev)
 }
 
 static const struct ethtool_ops au1000_ethtool_ops = {
-	.get_settings = au1000_get_settings,
-	.set_settings = au1000_set_settings,
 	.get_drvinfo = au1000_get_drvinfo,
 	.get_link = ethtool_op_get_link,
 	.get_msglevel = au1000_get_msglevel,
 	.set_msglevel = au1000_set_msglevel,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 
-- 
1.7.4.4
