From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/18] i40e/i40evf: add driver support for new device ids
Date: Wed,  7 Oct 2015 15:46:58 -0700
Message-ID: <1444258032-41476-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8249 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753464AbbJGWrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:23 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Early addition of new a device id.

Change-ID: I61a8c8556fdf4f5714be4e4089689e374f30293c
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c  | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 1 +
 drivers/net/ethernet/intel/i40e/i40e_type.h     | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h   | 1 +
 6 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 1e81f4e..7a70abc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -51,6 +51,7 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_QSFP_B:
 		case I40E_DEV_ID_QSFP_C:
 		case I40E_DEV_ID_10G_BASE_T:
+		case I40E_DEV_ID_10G_BASE_T4:
 		case I40E_DEV_ID_20G_KR2:
 		case I40E_DEV_ID_20G_KR2_A:
 			hw->mac.type = I40E_MAC_XL710;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 1345de2..928bd5a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -425,6 +425,7 @@ static void i40e_get_settings_link_down(struct i40e_hw *hw,
 		ecmd->advertising = ADVERTISED_10000baseKR_Full;
 		break;
 	case I40E_DEV_ID_10G_BASE_T:
+	case I40E_DEV_ID_10G_BASE_T4:
 		ecmd->supported = SUPPORTED_10000baseT_Full |
 				  SUPPORTED_1000baseT_Full |
 				  SUPPORTED_100baseT_Full;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7fc5e2c..19eb14d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -75,6 +75,7 @@ static const struct pci_device_id i40e_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_B), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_C), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_10G_BASE_T), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_10G_BASE_T4), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_20G_KR2), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_SFP_X722), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_1G_BASE_T_X722), 0},
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index c5b6a65..34720e0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -46,6 +46,7 @@
 #define I40E_DEV_ID_10G_BASE_T		0x1586
 #define I40E_DEV_ID_20G_KR2		0x1587
 #define I40E_DEV_ID_20G_KR2_A		0x1588
+#define I40E_DEV_ID_10G_BASE_T4		0x1589
 #define I40E_DEV_ID_VF			0x154C
 #define I40E_DEV_ID_VF_HV		0x1571
 #define I40E_DEV_ID_SFP_X722		0x37D0
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 1950db1..96e48ee 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -51,6 +51,7 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_QSFP_B:
 		case I40E_DEV_ID_QSFP_C:
 		case I40E_DEV_ID_10G_BASE_T:
+		case I40E_DEV_ID_10G_BASE_T4:
 		case I40E_DEV_ID_20G_KR2:
 		case I40E_DEV_ID_20G_KR2_A:
 			hw->mac.type = I40E_MAC_XL710;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 37bacc3..bbb3886 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -46,6 +46,7 @@
 #define I40E_DEV_ID_10G_BASE_T		0x1586
 #define I40E_DEV_ID_20G_KR2		0x1587
 #define I40E_DEV_ID_20G_KR2_A		0x1588
+#define I40E_DEV_ID_10G_BASE_T4		0x1589
 #define I40E_DEV_ID_VF			0x154C
 #define I40E_DEV_ID_VF_HV		0x1571
 #define I40E_DEV_ID_SFP_X722		0x37D0
-- 
2.4.3
