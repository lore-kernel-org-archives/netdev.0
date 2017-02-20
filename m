From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: qualcomm: qca: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 20 Feb 2017 22:59:13 +0100
Message-ID: <1487627953-18469-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/qualcomm/qca_debug.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_debug.c b/drivers/net/ethernet/qualcomm/qca_debug.c
index 8e28234..d145df9 100644
--- a/drivers/net/ethernet/qualcomm/qca_debug.c
+++ b/drivers/net/ethernet/qualcomm/qca_debug.c
@@ -188,14 +188,16 @@
 }
 
 static int
-qcaspi_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+qcaspi_get_link_ksettings(struct net_device *dev,
+			  struct ethtool_link_ksettings *cmd)
 {
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->supported = SUPPORTED_10baseT_Half;
-	ethtool_cmd_speed_set(cmd,  SPEED_10);
-	cmd->duplex = DUPLEX_HALF;
-	cmd->port = PORT_OTHER;
-	cmd->autoneg = AUTONEG_DISABLE;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, 10baseT_Half);
+
+	cmd->base.speed = SPEED_10;
+	cmd->base.duplex = DUPLEX_HALF;
+	cmd->base.port = PORT_OTHER;
+	cmd->base.autoneg = AUTONEG_DISABLE;
 
 	return 0;
 }
@@ -295,7 +297,6 @@
 static const struct ethtool_ops qcaspi_ethtool_ops = {
 	.get_drvinfo = qcaspi_get_drvinfo,
 	.get_link = ethtool_op_get_link,
-	.get_settings = qcaspi_get_settings,
 	.get_ethtool_stats = qcaspi_get_ethtool_stats,
 	.get_strings = qcaspi_get_strings,
 	.get_sset_count = qcaspi_get_sset_count,
@@ -303,6 +304,7 @@
 	.get_regs = qcaspi_get_regs,
 	.get_ringparam = qcaspi_get_ringparam,
 	.set_ringparam = qcaspi_set_ringparam,
+	.get_link_ksettings = qcaspi_get_link_ksettings,
 };
 
 void qcaspi_set_ethtool_ops(struct net_device *dev)
-- 
1.7.4.4
