From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] ixgbe: add driver support for x520 OCP adapter.
Date: Sat, 20 Apr 2013 02:49:01 -0700
Message-ID: <1366451353-24714-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11476 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753666Ab3DTJtR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Apr 2013 05:49:17 -0400
In-Reply-To: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch adds support for the new OCP x520 adapter.  This support
includes WoL.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 8 ++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 1 +
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9afc959..783efbb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7216,6 +7216,14 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 			break;
 		}
 		break;
+	case IXGBE_DEV_ID_82599EN_SFP:
+		/* Only this subdevice supports WOL */
+		switch (subdevice_id) {
+		case IXGBE_SUBDEV_ID_82599EN_SFP_OCP1:
+			is_wol_supported = 1;
+			break;
+		}
+		break;
 	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
 		/* All except this subdevice support WOL */
 		if (subdevice_id != IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 402f1a2..2661dcf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -61,6 +61,7 @@
 #define IXGBE_DEV_ID_82599_SFP_EM        0x1507
 #define IXGBE_DEV_ID_82599_SFP_SF2       0x154D
 #define IXGBE_DEV_ID_82599EN_SFP         0x1557
+#define IXGBE_SUBDEV_ID_82599EN_SFP_OCP1 0x0001
 #define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC
 #define IXGBE_DEV_ID_82599_COMBO_BACKPLANE 0x10F8
 #define IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ  0x000C
-- 
1.7.11.7
