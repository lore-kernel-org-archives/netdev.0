From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: net_netdev: use new api ethtool_{get|set}_link_ksettings
Date: Thu,  9 Mar 2017 23:10:13 +0100
Message-ID: <1489097413-4202-1-git-send-email-tremyfr@gmail.com>
Cc: linux-ntb@googlegroups.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: jdmason@kudzu.us, dave.jiang@intel.com, Allen.Hubbe@emc.com,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ntb_netdev.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ntb_netdev.c b/drivers/net/ntb_netdev.c
index 36877ba..4daf3d0 100644
--- a/drivers/net/ntb_netdev.c
+++ b/drivers/net/ntb_netdev.c
@@ -372,18 +372,19 @@ static void ntb_get_drvinfo(struct net_device *ndev,
 	strlcpy(info->bus_info, pci_name(dev->pdev), sizeof(info->bus_info));
 }
 
-static int ntb_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int ntb_get_link_ksettings(struct net_device *dev,
+				  struct ethtool_link_ksettings *cmd)
 {
-	cmd->supported = SUPPORTED_Backplane;
-	cmd->advertising = ADVERTISED_Backplane;
-	ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
-	cmd->duplex = DUPLEX_FULL;
-	cmd->port = PORT_OTHER;
-	cmd->phy_address = 0;
-	cmd->transceiver = XCVR_DUMMY1;
-	cmd->autoneg = AUTONEG_ENABLE;
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 0;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, Backplane);
+	ethtool_link_ksettings_zero_link_mode(cmd, advertising);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, Backplane);
+
+	cmd->base.speed = SPEED_UNKNOWN;
+	cmd->base.duplex = DUPLEX_FULL;
+	cmd->base.port = PORT_OTHER;
+	cmd->base.phy_address = 0;
+	cmd->base.autoneg = AUTONEG_ENABLE;
 
 	return 0;
 }
@@ -391,7 +392,7 @@ static int ntb_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static const struct ethtool_ops ntb_ethtool_ops = {
 	.get_drvinfo = ntb_get_drvinfo,
 	.get_link = ethtool_op_get_link,
-	.get_settings = ntb_get_settings,
+	.get_link_ksettings = ntb_get_link_ksettings,
 };
 
 static const struct ntb_queue_handlers ntb_netdev_handlers = {
-- 
1.7.4.4
