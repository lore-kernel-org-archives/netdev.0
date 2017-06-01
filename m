From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] i40evf: Add support for Adaptive Virtual Function
Date: Thu,  1 Jun 2017 14:38:39 -0700
Message-ID: <20170601213840.36286-14-jeffrey.t.kirsher@intel.com>
References: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Cc: Preethi Banala <preethi.banala@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20201 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751328AbdFAVjT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 17:39:19 -0400
In-Reply-To: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Preethi Banala <preethi.banala@intel.com>

Add device ID define and mac_type assignment needed for
Adaptive Virtual Function (VF Base Mode Support).

Also, update version to v3.0.0 in order to indicate
clearly that this is the first driver supporting the AVF
device ID.

Signed-off-by: Preethi Banala <preethi.banala@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig              | 10 ++++++----
 drivers/net/ethernet/intel/i40evf/i40e_common.c |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_devids.h |  1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |  7 ++++---
 4 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 1542a2158e96..1feb54b6d92e 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -236,12 +236,14 @@ config I40E_DCB
 	  If unsure, say N.
 
 config I40EVF
-	tristate "Intel(R) XL710 X710 Virtual Function Ethernet support"
+	tristate "Intel(R) Ethernet Adaptive Virtual Function support"
 	depends on PCI_MSI
 	---help---
-	  This driver supports Intel(R) XL710 and X710 virtual functions.
-	  For more information on how to identify your adapter, go to the
-	  Adapter & Driver ID Guide that can be located at:
+	  This driver supports virtual functions for Intel XL710,
+	  X710, X722, and all devices advertising support for Intel
+	  Ethernet Adaptive Virtual Function devices. For more
+	  information on how to identify your adapter, go to the Adapter
+	  & Driver ID Guide that can be located at:
 
 	  <http://support.intel.com>
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 9dec7753911c..1dd1938f594f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -68,6 +68,7 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 			break;
 		case I40E_DEV_ID_VF:
 		case I40E_DEV_ID_VF_HV:
+		case I40E_DEV_ID_ADAPTIVE_VF:
 			hw->mac.type = I40E_MAC_VF;
 			break;
 		default:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_devids.h b/drivers/net/ethernet/intel/i40evf/i40e_devids.h
index d76393c95056..0469e4bfd3ec 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_devids.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_devids.h
@@ -43,6 +43,7 @@
 #define I40E_DEV_ID_25G_SFP28		0x158B
 #define I40E_DEV_ID_VF			0x154C
 #define I40E_DEV_ID_VF_HV		0x1571
+#define I40E_DEV_ID_ADAPTIVE_VF		0x1889
 #define I40E_DEV_ID_SFP_X722		0x37D0
 #define I40E_DEV_ID_1G_BASE_T_X722	0x37D1
 #define I40E_DEV_ID_10G_BASE_T_X722	0x37D2
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 1b00274de530..3a3ca965b242 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -44,9 +44,9 @@ static const char i40evf_driver_string[] =
 
 #define DRV_KERN "-k"
 
-#define DRV_VERSION_MAJOR 2
-#define DRV_VERSION_MINOR 1
-#define DRV_VERSION_BUILD 14
+#define DRV_VERSION_MAJOR 3
+#define DRV_VERSION_MINOR 0
+#define DRV_VERSION_BUILD 0
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD) \
@@ -67,6 +67,7 @@ static const struct pci_device_id i40evf_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_VF), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_VF_HV), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_X722_VF), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_ADAPTIVE_VF), 0},
 	/* required last entry */
 	{0, }
 };
-- 
2.12.2
