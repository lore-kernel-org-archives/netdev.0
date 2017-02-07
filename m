From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: intel: ixgbevf: use new api ethtool_{get|set}_link_ksettings
Date: Tue,  7 Feb 2017 16:56:33 +0100
Message-ID: <1486482993-7818-1-git-send-email-tremyfr@gmail.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 1f6c0ec..6bf7409 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -91,18 +91,18 @@ struct ixgbe_stats {
 
 #define IXGBEVF_TEST_LEN (sizeof(ixgbe_gstrings_test) / ETH_GSTRING_LEN)
 
-static int ixgbevf_get_settings(struct net_device *netdev,
-				struct ethtool_cmd *ecmd)
+static int ixgbevf_get_link_ksettings(struct net_device *netdev,
+				      struct ethtool_link_ksettings *cmd)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 link_speed = 0;
 	bool link_up;
 
-	ecmd->supported = SUPPORTED_10000baseT_Full;
-	ecmd->autoneg = AUTONEG_DISABLE;
-	ecmd->transceiver = XCVR_DUMMY1;
-	ecmd->port = -1;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, 10000baseT_Full);
+	cmd->base.autoneg = AUTONEG_DISABLE;
+	cmd->base.port = -1;
 
 	hw->mac.get_link_status = 1;
 	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
@@ -122,11 +122,11 @@ static int ixgbevf_get_settings(struct net_device *netdev,
 			break;
 		}
 
-		ethtool_cmd_speed_set(ecmd, speed);
-		ecmd->duplex = DUPLEX_FULL;
+		cmd->base.speed = speed;
+		cmd->base.duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
-		ecmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 
 	return 0;
@@ -885,7 +885,6 @@ static int ixgbevf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 }
 
 static const struct ethtool_ops ixgbevf_ethtool_ops = {
-	.get_settings		= ixgbevf_get_settings,
 	.get_drvinfo		= ixgbevf_get_drvinfo,
 	.get_regs_len		= ixgbevf_get_regs_len,
 	.get_regs		= ixgbevf_get_regs,
@@ -905,6 +904,7 @@ static int ixgbevf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 	.get_rxfh_indir_size	= ixgbevf_get_rxfh_indir_size,
 	.get_rxfh_key_size	= ixgbevf_get_rxfh_key_size,
 	.get_rxfh		= ixgbevf_get_rxfh,
+	.get_link_ksettings	= ixgbevf_get_link_ksettings,
 };
 
 void ixgbevf_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
