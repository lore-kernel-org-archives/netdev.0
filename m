From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] ixgbe: list X553 backplane speeds correctly
Date: Tue, 18 Apr 2017 16:01:56 -0700
Message-ID: <20170418230205.37223-7-jeffrey.t.kirsher@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:61886 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756161AbdDRXCN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:13 -0400
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We forgot to indicate some of the supported speed on the X553
backplane.  This patch attempts to correct for that.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  5 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 14 ++++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 22869aaec3d4..f5fdd9b17de2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3775,6 +3775,11 @@ struct ixgbe_info {
 
 #define IXGBE_NW_MNG_IF_SEL		0x00011178
 #define IXGBE_NW_MNG_IF_SEL_MDIO_ACT		BIT(1)
+#define IXGBE_NW_MNG_IF_SEL_PHY_SPEED_10M	BIT(17)
+#define IXGBE_NW_MNG_IF_SEL_PHY_SPEED_100M	BIT(18)
+#define IXGBE_NW_MNG_IF_SEL_PHY_SPEED_1G	BIT(19)
+#define IXGBE_NW_MNG_IF_SEL_PHY_SPEED_2_5G	BIT(20)
+#define IXGBE_NW_MNG_IF_SEL_PHY_SPEED_10G	BIT(21)
 #define IXGBE_NW_MNG_IF_SEL_ENABLE_10_100M	BIT(23)
 #define IXGBE_NW_MNG_IF_SEL_INT_PHY_MODE	BIT(24)
 #define IXGBE_NW_MNG_IF_SEL_MDIO_PHY_ADD_SHIFT	3
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 5127e5e759f2..af579c21e57f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2241,6 +2241,20 @@ static s32 ixgbe_get_link_capabilities_X550em(struct ixgbe_hw *hw,
 		case ixgbe_phy_sgmii:
 			*speed = IXGBE_LINK_SPEED_1GB_FULL;
 			break;
+		case ixgbe_phy_x550em_kr:
+			if (hw->mac.type == ixgbe_mac_x550em_a) {
+				/* check different backplane modes */
+				if (hw->phy.nw_mng_if_sel &
+				    IXGBE_NW_MNG_IF_SEL_PHY_SPEED_2_5G) {
+					*speed = IXGBE_LINK_SPEED_2_5GB_FULL;
+					break;
+				} else if (hw->device_id ==
+					   IXGBE_DEV_ID_X550EM_A_KR_L) {
+					*speed = IXGBE_LINK_SPEED_1GB_FULL;
+					break;
+				}
+			}
+			/* fall through */
 		default:
 			*speed = IXGBE_LINK_SPEED_10GB_FULL |
 				 IXGBE_LINK_SPEED_1GB_FULL;
-- 
2.12.2
