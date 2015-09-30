From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/17] i40e/i40evf: add new device id 1588
Date: Wed, 30 Sep 2015 05:52:35 -0700
Message-ID: <1443617561-40490-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8321 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932407AbbI3Mwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:45 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add new device id and support for another 20Gb device.

Change-ID: Ib1b61e5bb6201d84953f97cade39a6e3369c2cf2
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c  | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 ++
 drivers/net/ethernet/intel/i40e/i40e_type.h     | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h   | 1 +
 6 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 114dc64..80c354c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -52,6 +52,7 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_QSFP_C:
 		case I40E_DEV_ID_10G_BASE_T:
 		case I40E_DEV_ID_20G_KR2:
+		case I40E_DEV_ID_20G_KR2_A:
 			hw->mac.type = I40E_MAC_XL710;
 			break;
 		case I40E_DEV_ID_SFP_X722:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index e972b5e..dd2b620 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -437,6 +437,7 @@ static void i40e_get_settings_link_down(struct i40e_hw *hw,
 			ecmd->advertising |= ADVERTISED_100baseT_Full;
 		break;
 	case I40E_DEV_ID_20G_KR2:
+	case I40E_DEV_ID_20G_KR2_A:
 		/* backplane 20G */
 		ecmd->supported = SUPPORTED_20000baseKR2_Full;
 		ecmd->advertising = ADVERTISED_20000baseKR2_Full;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 032df6d..8952ab7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -79,6 +79,8 @@ static const struct pci_device_id i40e_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_SFP_X722), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_1G_BASE_T_X722), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_10G_BASE_T_X722), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_20G_KR2), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_20G_KR2_A), 0},
 	/* required last entry */
 	{0, }
 };
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index af48290..c5b6a65 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -45,6 +45,7 @@
 #define I40E_DEV_ID_QSFP_C		0x1585
 #define I40E_DEV_ID_10G_BASE_T		0x1586
 #define I40E_DEV_ID_20G_KR2		0x1587
+#define I40E_DEV_ID_20G_KR2_A		0x1588
 #define I40E_DEV_ID_VF			0x154C
 #define I40E_DEV_ID_VF_HV		0x1571
 #define I40E_DEV_ID_SFP_X722		0x37D0
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index d45d0ae..1950db1 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -52,6 +52,7 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_QSFP_C:
 		case I40E_DEV_ID_10G_BASE_T:
 		case I40E_DEV_ID_20G_KR2:
+		case I40E_DEV_ID_20G_KR2_A:
 			hw->mac.type = I40E_MAC_XL710;
 			break;
 		case I40E_DEV_ID_SFP_X722:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index ed71666..37bacc3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -45,6 +45,7 @@
 #define I40E_DEV_ID_QSFP_C		0x1585
 #define I40E_DEV_ID_10G_BASE_T		0x1586
 #define I40E_DEV_ID_20G_KR2		0x1587
+#define I40E_DEV_ID_20G_KR2_A		0x1588
 #define I40E_DEV_ID_VF			0x154C
 #define I40E_DEV_ID_VF_HV		0x1571
 #define I40E_DEV_ID_SFP_X722		0x37D0
-- 
2.4.3
