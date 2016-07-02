From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: lantiq_etop: use phy_ethtool_{get|set}_link_ksettings
Date: Sun,  3 Jul 2016 00:05:05 +0200
Message-ID: <1467497105-19935-2-git-send-email-tremyfr@gmail.com>
References: <1467497105-19935-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, andrew@lunn.ch, sudipm.mukherjee@gmail.com,
	mugunthanvnm@ti.com, felipe.balbi@linux.intel.com, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34523 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbcGBWFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 18:05:15 -0400
In-Reply-To: <1467497105-19935-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/lantiq_etop.c |   16 ++--------------
 1 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index ad715a4..91e09d6 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -304,18 +304,6 @@ ltq_etop_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 }
 
 static int
-ltq_etop_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_gset(dev->phydev, cmd);
-}
-
-static int
-ltq_etop_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_sset(dev->phydev, cmd);
-}
-
-static int
 ltq_etop_nway_reset(struct net_device *dev)
 {
 	return phy_start_aneg(dev->phydev);
@@ -323,9 +311,9 @@ ltq_etop_nway_reset(struct net_device *dev)
 
 static const struct ethtool_ops ltq_etop_ethtool_ops = {
 	.get_drvinfo = ltq_etop_get_drvinfo,
-	.get_settings = ltq_etop_get_settings,
-	.set_settings = ltq_etop_set_settings,
 	.nway_reset = ltq_etop_nway_reset,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 static int
-- 
1.7.4.4
