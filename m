From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/17] ixgbe: Add fdir support for SCTP on X550
Date: Tue, 22 Sep 2015 16:54:22 -0700
Message-ID: <1442966076-14359-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:63267 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934846AbbIVXyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:39 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

X550 has HW support for SCTP flow director filters SCTP mask. This
patch adds it like we do for UDP and TCP.

Signed-off-by: Donald C Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 10 ++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |  1 +
 2 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index dd7062f..85156fb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1766,6 +1766,16 @@ s32 ixgbe_fdir_set_input_mask_82599(struct ixgbe_hw *hw,
 	IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM, ~fdirtcpm);
 	IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM, ~fdirtcpm);
 
+	/* also use it for SCTP */
+	switch (hw->mac.type) {
+	case ixgbe_mac_X550:
+	case ixgbe_mac_X550EM_x:
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRSCTPM, ~fdirtcpm);
+		break;
+	default:
+		break;
+	}
+
 	/* store source and destination IP masks (big-enian) */
 	IXGBE_WRITE_REG_BE32(hw, IXGBE_FDIRSIP4M,
 			     ~input_mask->formatted.src_ip[0]);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 6368919..4e16d14 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -402,6 +402,7 @@ struct ixgbe_thermal_sensor_data {
 #define IXGBE_FDIRSIP4M 0x0EE40
 #define IXGBE_FDIRTCPM  0x0EE44
 #define IXGBE_FDIRUDPM  0x0EE48
+#define IXGBE_FDIRSCTPM	0x0EE78
 #define IXGBE_FDIRIP6M  0x0EE74
 #define IXGBE_FDIRM     0x0EE70
 
-- 
2.4.3
