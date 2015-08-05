From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e/i40evf: Add device ids for X722
Date: Wed,  5 Aug 2015 16:52:01 -0700
Message-ID: <1438818735-38115-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36603 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753103AbbHEXwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 19:52:18 -0400
In-Reply-To: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Adding device ids for new hardware X722

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 10 ++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c     |  3 +++
 drivers/net/ethernet/intel/i40e/i40e_type.h     | 10 +++++++++-
 drivers/net/ethernet/intel/i40evf/i40e_common.c |  9 +++++++++
 drivers/net/ethernet/intel/i40evf/i40e_type.h   | 10 +++++++++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |  1 +
 6 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 167ca0d..11ec264 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -54,6 +54,15 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_20G_KR2:
 			hw->mac.type = I40E_MAC_XL710;
 			break;
+		case I40E_DEV_ID_SFP_X722:
+		case I40E_DEV_ID_1G_BASE_T_X722:
+		case I40E_DEV_ID_10G_BASE_T_X722:
+			hw->mac.type = I40E_MAC_X722;
+			break;
+		case I40E_DEV_ID_X722_VF:
+		case I40E_DEV_ID_X722_VF_HV:
+			hw->mac.type = I40E_MAC_X722_VF;
+			break;
 		case I40E_DEV_ID_VF:
 		case I40E_DEV_ID_VF_HV:
 			hw->mac.type = I40E_MAC_VF;
@@ -769,6 +778,7 @@ i40e_status i40e_init_shared_code(struct i40e_hw *hw)
 
 	switch (hw->mac.type) {
 	case I40E_MAC_XL710:
+	case I40E_MAC_X722:
 		break;
 	default:
 		return I40E_ERR_DEVICE_NOT_SUPPORTED;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 857d294..9c96706 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -76,6 +76,9 @@ static const struct pci_device_id i40e_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_C), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_10G_BASE_T), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_20G_KR2), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_SFP_X722), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_1G_BASE_T_X722), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_10G_BASE_T_X722), 0},
 	/* required last entry */
 	{0, }
 };
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index a20128b..778266f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -47,6 +47,11 @@
 #define I40E_DEV_ID_20G_KR2		0x1587
 #define I40E_DEV_ID_VF			0x154C
 #define I40E_DEV_ID_VF_HV		0x1571
+#define I40E_DEV_ID_SFP_X722		0x37D0
+#define I40E_DEV_ID_1G_BASE_T_X722	0x37D1
+#define I40E_DEV_ID_10G_BASE_T_X722	0x37D2
+#define I40E_DEV_ID_X722_VF		0x37CD
+#define I40E_DEV_ID_X722_VF_HV		0x37D9
 
 #define i40e_is_40G_device(d)		((d) == I40E_DEV_ID_QSFP_A  || \
 					 (d) == I40E_DEV_ID_QSFP_B  || \
@@ -120,6 +125,8 @@ enum i40e_mac_type {
 	I40E_MAC_X710,
 	I40E_MAC_XL710,
 	I40E_MAC_VF,
+	I40E_MAC_X722,
+	I40E_MAC_X722_VF,
 	I40E_MAC_GENERIC,
 };
 
@@ -502,7 +509,8 @@ struct i40e_hw {
 
 static inline bool i40e_is_vf(struct i40e_hw *hw)
 {
-	return hw->mac.type == I40E_MAC_VF;
+	return (hw->mac.type == I40E_MAC_VF ||
+		hw->mac.type == I40E_MAC_X722_VF);
 }
 
 struct i40e_driver_version {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 56c7e75..eb54e8d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -54,6 +54,15 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_20G_KR2:
 			hw->mac.type = I40E_MAC_XL710;
 			break;
+		case I40E_DEV_ID_SFP_X722:
+		case I40E_DEV_ID_1G_BASE_T_X722:
+		case I40E_DEV_ID_10G_BASE_T_X722:
+			hw->mac.type = I40E_MAC_X722;
+			break;
+		case I40E_DEV_ID_X722_VF:
+		case I40E_DEV_ID_X722_VF_HV:
+			hw->mac.type = I40E_MAC_X722_VF;
+			break;
 		case I40E_DEV_ID_VF:
 		case I40E_DEV_ID_VF_HV:
 			hw->mac.type = I40E_MAC_VF;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 4ba9a01..c50536b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -47,6 +47,11 @@
 #define I40E_DEV_ID_20G_KR2		0x1587
 #define I40E_DEV_ID_VF			0x154C
 #define I40E_DEV_ID_VF_HV		0x1571
+#define I40E_DEV_ID_SFP_X722		0x37D0
+#define I40E_DEV_ID_1G_BASE_T_X722	0x37D1
+#define I40E_DEV_ID_10G_BASE_T_X722	0x37D2
+#define I40E_DEV_ID_X722_VF		0x37CD
+#define I40E_DEV_ID_X722_VF_HV		0x37D9
 
 #define i40e_is_40G_device(d)		((d) == I40E_DEV_ID_QSFP_A  || \
 					 (d) == I40E_DEV_ID_QSFP_B  || \
@@ -120,6 +125,8 @@ enum i40e_mac_type {
 	I40E_MAC_X710,
 	I40E_MAC_XL710,
 	I40E_MAC_VF,
+	I40E_MAC_X722,
+	I40E_MAC_X722_VF,
 	I40E_MAC_GENERIC,
 };
 
@@ -496,7 +503,8 @@ struct i40e_hw {
 
 static inline bool i40e_is_vf(struct i40e_hw *hw)
 {
-	return hw->mac.type == I40E_MAC_VF;
+	return (hw->mac.type == I40E_MAC_VF ||
+		hw->mac.type == I40E_MAC_X722_VF);
 }
 
 struct i40e_driver_version {
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 1503cad..642944e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -49,6 +49,7 @@ static const char i40evf_copyright[] =
  */
 static const struct pci_device_id i40evf_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_VF), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_X722_VF), 0},
 	/* required last entry */
 	{0, }
 };
-- 
2.4.3
