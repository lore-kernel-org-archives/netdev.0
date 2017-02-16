From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] ixgbe: Support 2.5Gb and 5Gb speed
Date: Thu, 16 Feb 2017 04:50:28 -0800
Message-ID: <20170216125041.46668-2-jeffrey.t.kirsher@intel.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:18210 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754216AbdBPMup (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:45 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

Though not advertised through ethtool, if the link partner advertises a
2.5Gb or 5Gb connection, and the adapter supports it, allow the speed to be
used.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  3 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     | 10 +++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index ee28e54a4f75..04f15092ae31 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -340,6 +340,9 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		case IXGBE_LINK_SPEED_10GB_FULL:
 			ethtool_cmd_speed_set(ecmd, SPEED_10000);
 			break;
+		case IXGBE_LINK_SPEED_5GB_FULL:
+			ethtool_cmd_speed_set(ecmd, SPEED_5000);
+			break;
 		case IXGBE_LINK_SPEED_2_5GB_FULL:
 			ethtool_cmd_speed_set(ecmd, SPEED_2500);
 			break;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 2fcde8777a29..e55b2602f371 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -768,9 +768,7 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
 				       ixgbe_link_speed speed,
 				       bool autoneg_wait_to_complete)
 {
-
-	/*
-	 * Clear autoneg_advertised and set new values based on input link
+	/* Clear autoneg_advertised and set new values based on input link
 	 * speed.
 	 */
 	hw->phy.autoneg_advertised = 0;
@@ -778,6 +776,12 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
 	if (speed & IXGBE_LINK_SPEED_10GB_FULL)
 		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_10GB_FULL;
 
+	if (speed & IXGBE_LINK_SPEED_5GB_FULL)
+		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_5GB_FULL;
+
+	if (speed & IXGBE_LINK_SPEED_2_5GB_FULL)
+		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_2_5GB_FULL;
+
 	if (speed & IXGBE_LINK_SPEED_1GB_FULL)
 		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_1GB_FULL;
 
-- 
2.11.0
