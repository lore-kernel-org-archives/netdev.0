From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6 08/12] ixgbe: convert to ethtool set_phys_id
Date: Mon, 04 Apr 2011 11:43:48 -0700
Message-ID: <20110404184502.007626879@linuxplumber.net>
References: <20110404184340.604594357@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce A
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52818 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755187Ab1DDSvJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:51:09 -0400
Content-Disposition: inline; filename=ixgbe-set-phys-id.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert ixgbe driver to use new set_phys_id ethtool interface.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ixgbe/ixgbe_ethtool.c	2011-04-04 10:48:11.641481015 -0700
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c	2011-04-04 10:50:57.979778947 -0700
@@ -1999,25 +1999,29 @@ static int ixgbe_nway_reset(struct net_d
 	return 0;
 }
 
-static int ixgbe_phys_id(struct net_device *netdev, u32 data)
+static int ixgbe_set_phys_id(struct net_device *netdev,
+			     enum ethtool_phys_id_state state)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
-	u32 i;
 
-	if (!data || data > 300)
-		data = 300;
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		return -1;
 
-	for (i = 0; i < (data * 1000); i += 400) {
+	case ETHTOOL_ID_ON:
 		hw->mac.ops.led_on(hw, IXGBE_LED_ON);
-		msleep_interruptible(200);
+		break;
+
+	case ETHTOOL_ID_OFF:
 		hw->mac.ops.led_off(hw, IXGBE_LED_ON);
-		msleep_interruptible(200);
-	}
+		break;
 
-	/* Restore LED settings */
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_LEDCTL, led_reg);
+	case ETHTOOL_ID_INACTIVE:
+		/* Restore LED settings */
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_LEDCTL, led_reg);
+	}
 
 	return 0;
 }
@@ -2465,7 +2469,7 @@ static const struct ethtool_ops ixgbe_et
 	.set_tso                = ixgbe_set_tso,
 	.self_test              = ixgbe_diag_test,
 	.get_strings            = ixgbe_get_strings,
-	.phys_id                = ixgbe_phys_id,
+	.set_phys_id            = ixgbe_set_phys_id,
 	.get_sset_count         = ixgbe_get_sset_count,
 	.get_ethtool_stats      = ixgbe_get_ethtool_stats,
 	.get_coalesce           = ixgbe_get_coalesce,


