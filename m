From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: freescale: dpaa: use new api ethtool_{get|set}_link_ksettings
Date: Mon,  2 Jan 2017 23:49:15 +0100
Message-ID: <1483397355-18738-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: madalin.bucur@nxp.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:35898 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934372AbdABWtb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 17:49:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
index 27e7044..15571e2 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
@@ -72,8 +72,8 @@
 #define DPAA_STATS_PERCPU_LEN ARRAY_SIZE(dpaa_stats_percpu)
 #define DPAA_STATS_GLOBAL_LEN ARRAY_SIZE(dpaa_stats_global)
 
-static int dpaa_get_settings(struct net_device *net_dev,
-			     struct ethtool_cmd *et_cmd)
+static int dpaa_get_link_ksettings(struct net_device *net_dev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	int err;
 
@@ -82,13 +82,13 @@ static int dpaa_get_settings(struct net_device *net_dev,
 		return 0;
 	}
 
-	err = phy_ethtool_gset(net_dev->phydev, et_cmd);
+	err = phy_ethtool_ksettings_get(net_dev->phydev, cmd);
 
 	return err;
 }
 
-static int dpaa_set_settings(struct net_device *net_dev,
-			     struct ethtool_cmd *et_cmd)
+static int dpaa_set_link_ksettings(struct net_device *net_dev,
+				   const struct ethtool_link_ksettings *cmd)
 {
 	int err;
 
@@ -97,9 +97,9 @@ static int dpaa_set_settings(struct net_device *net_dev,
 		return -ENODEV;
 	}
 
-	err = phy_ethtool_sset(net_dev->phydev, et_cmd);
+	err = phy_ethtool_ksettings_set(net_dev->phydev, cmd);
 	if (err < 0)
-		netdev_err(net_dev, "phy_ethtool_sset() = %d\n", err);
+		netdev_err(net_dev, "phy_ethtool_ksettings_set() = %d\n", err);
 
 	return err;
 }
@@ -402,8 +402,6 @@ static void dpaa_get_strings(struct net_device *net_dev, u32 stringset,
 }
 
 const struct ethtool_ops dpaa_ethtool_ops = {
-	.get_settings = dpaa_get_settings,
-	.set_settings = dpaa_set_settings,
 	.get_drvinfo = dpaa_get_drvinfo,
 	.get_msglevel = dpaa_get_msglevel,
 	.set_msglevel = dpaa_set_msglevel,
@@ -414,4 +412,6 @@ static void dpaa_get_strings(struct net_device *net_dev, u32 stringset,
 	.get_sset_count = dpaa_get_sset_count,
 	.get_ethtool_stats = dpaa_get_ethtool_stats,
 	.get_strings = dpaa_get_strings,
+	.get_link_ksettings = dpaa_get_link_ksettings,
+	.set_link_ksettings = dpaa_set_link_ksettings,
 };
-- 
1.7.4.4
