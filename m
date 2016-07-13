From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: ll_temac: use phy_ethtool_{get|set}_link_ksettings
Date: Thu, 14 Jul 2016 01:48:52 +0200
Message-ID: <1468453732-7370-2-git-send-email-tremyfr@gmail.com>
References: <1468453732-7370-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
	andrew@lunn.ch, davem@davemloft.net, f.fainelli@gmail.com,
	mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de,
	felipe.balbi@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35990 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbcGMXtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 19:49:12 -0400
In-Reply-To: <1468453732-7370-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 8d6a178..a9bd665 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -967,27 +967,17 @@ static const struct attribute_group temac_attr_group = {
 };
 
 /* ethtool support */
-static int temac_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_gset(ndev->phydev, cmd);
-}
-
-static int temac_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_sset(ndev->phydev, cmd);
-}
-
 static int temac_nway_reset(struct net_device *ndev)
 {
 	return phy_start_aneg(ndev->phydev);
 }
 
 static const struct ethtool_ops temac_ethtool_ops = {
-	.get_settings = temac_get_settings,
-	.set_settings = temac_set_settings,
 	.nway_reset = temac_nway_reset,
 	.get_link = ethtool_op_get_link,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 static int temac_of_probe(struct platform_device *op)
-- 
1.7.4.4
