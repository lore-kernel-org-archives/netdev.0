From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool 1/3] ethtool/ixgbe: Add device ID and mac_type definitions
Date: Wed,  4 May 2016 09:44:51 -0700
Message-ID: <1462380293-4132-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Preethi Banala <preethi.banala@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58281 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752423AbcEDQoz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:44:55 -0400
In-Reply-To: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Preethi Banala <preethi.banala@intel.com>

Add device id macro definitions, mac_type enum definition and update
get_mac_type() accordingly.

Signed-off-by: Preethi Banala <preethi.banala@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ixgbe.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/ixgbe.c b/ixgbe.c
index 3928d77..a375782 100644
--- a/ixgbe.c
+++ b/ixgbe.c
@@ -63,6 +63,23 @@
 #define IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ  0x000C
 #define IXGBE_DEV_ID_82599_LS            0x154F
 #define IXGBE_DEV_ID_X540T               0x1528
+#define IXGBE_DEV_ID_82599_SFP_SF_QP     0x154A
+#define IXGBE_DEV_ID_82599_QSFP_SF_QP    0x1558
+#define IXGBE_DEV_ID_X540T1              0x1560
+
+#define IXGBE_DEV_ID_X550T		0x1563
+#define IXGBE_DEV_ID_X550T1		0x15D1
+#define IXGBE_DEV_ID_X550EM_X_KX4	0x15AA
+#define IXGBE_DEV_ID_X550EM_X_KR	0x15AB
+#define IXGBE_DEV_ID_X550EM_X_SFP	0x15AC
+#define IXGBE_DEV_ID_X550EM_X_10G_T	0x15AD
+#define IXGBE_DEV_ID_X550EM_X_1G_T	0x15AE
+#define IXGBE_DEV_ID_X550EM_A_KR	0x15C2
+#define IXGBE_DEV_ID_X550EM_A_KR_L	0x15C3
+#define IXGBE_DEV_ID_X550EM_A_SFP_N	0x15C4
+#define IXGBE_DEV_ID_X550EM_A_SGMII	0x15C6
+#define IXGBE_DEV_ID_X550EM_A_SGMII_L	0x15C7
+#define IXGBE_DEV_ID_X550EM_A_SFP	0x15CE
 
 /*
  * Enumerated types specific to the ixgbe hardware
@@ -73,6 +90,9 @@ enum ixgbe_mac_type {
 	ixgbe_mac_82598EB,
 	ixgbe_mac_82599EB,
 	ixgbe_mac_X540,
+	ixgbe_mac_x550,
+	ixgbe_mac_x550em_x,
+	ixgbe_mac_x550em_a,
 	ixgbe_num_macs
 };
 
@@ -112,11 +132,33 @@ ixgbe_get_mac_type(u16 device_id)
 	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
 	case IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ:
 	case IXGBE_DEV_ID_82599_LS:
+	case IXGBE_DEV_ID_82599_SFP_SF_QP:
+	case IXGBE_DEV_ID_82599_QSFP_SF_QP:
 		mac_type = ixgbe_mac_82599EB;
 		break;
 	case IXGBE_DEV_ID_X540T:
+	case IXGBE_DEV_ID_X540T1:
 		mac_type = ixgbe_mac_X540;
 		break;
+	case IXGBE_DEV_ID_X550T:
+	case IXGBE_DEV_ID_X550T1:
+		mac_type = ixgbe_mac_x550;
+		break;
+	case IXGBE_DEV_ID_X550EM_X_KX4:
+	case IXGBE_DEV_ID_X550EM_X_KR:
+	case IXGBE_DEV_ID_X550EM_X_SFP:
+	case IXGBE_DEV_ID_X550EM_X_10G_T:
+	case IXGBE_DEV_ID_X550EM_X_1G_T:
+		mac_type = ixgbe_mac_x550em_x;
+		break;
+	case IXGBE_DEV_ID_X550EM_A_KR:
+	case IXGBE_DEV_ID_X550EM_A_KR_L:
+	case IXGBE_DEV_ID_X550EM_A_SFP_N:
+	case IXGBE_DEV_ID_X550EM_A_SGMII:
+	case IXGBE_DEV_ID_X550EM_A_SGMII_L:
+	case IXGBE_DEV_ID_X550EM_A_SFP:
+		mac_type = ixgbe_mac_x550em_a;
+		break;
 	default:
 		mac_type = ixgbe_mac_82598EB;
 		break;
-- 
2.5.5
