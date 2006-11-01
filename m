From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 10/18] e1000: New hardware support
Date: Wed, 01 Nov 2006 09:51:51 -0800
Message-ID: <20061101175151.2356.80946.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:19472 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946967AbWKARoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:44:39 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add support for a Low Profile quad-port PCI-E adapter and 2 variants
of the ICH8 systems' onboard NIC's.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    1 +
 drivers/net/e1000/e1000_hw.c      |    3 +++
 drivers/net/e1000/e1000_hw.h      |    3 +++
 drivers/net/e1000/e1000_main.c    |    4 ++++
 4 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index b9c0927..dbac71b 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1725,6 +1725,7 @@ static int e1000_wol_exclusion(struct e1
 		retval = 0;
 		break;
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
+	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		/* quad port adapters only support WoL on port A */
 		if (!adapter->quad_port_a) {
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index a45685c..fd7d09d 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -385,6 +385,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
     case E1000_DEV_ID_82571EB_FIBER:
     case E1000_DEV_ID_82571EB_SERDES:
     case E1000_DEV_ID_82571EB_QUAD_COPPER:
+    case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
             hw->mac_type = e1000_82571;
         break;
     case E1000_DEV_ID_82572EI_COPPER:
@@ -408,6 +409,8 @@ e1000_set_mac_type(struct e1000_hw *hw)
     case E1000_DEV_ID_ICH8_IGP_AMT:
     case E1000_DEV_ID_ICH8_IGP_C:
     case E1000_DEV_ID_ICH8_IFE:
+    case E1000_DEV_ID_ICH8_IFE_GT:
+    case E1000_DEV_ID_ICH8_IFE_G:
     case E1000_DEV_ID_ICH8_IGP_M:
         hw->mac_type = e1000_ich8lan;
         break;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index f247f26..93c1e26 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -475,6 +475,7 @@ int32_t e1000_check_phy_reset_block(stru
 #define E1000_DEV_ID_82571EB_FIBER       0x105F
 #define E1000_DEV_ID_82571EB_SERDES      0x1060
 #define E1000_DEV_ID_82571EB_QUAD_COPPER 0x10A4
+#define E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE  0x10BC
 #define E1000_DEV_ID_82572EI_COPPER      0x107D
 #define E1000_DEV_ID_82572EI_FIBER       0x107E
 #define E1000_DEV_ID_82572EI_SERDES      0x107F
@@ -492,6 +493,8 @@ int32_t e1000_check_phy_reset_block(stru
 #define E1000_DEV_ID_ICH8_IGP_AMT        0x104A
 #define E1000_DEV_ID_ICH8_IGP_C          0x104B
 #define E1000_DEV_ID_ICH8_IFE            0x104C
+#define E1000_DEV_ID_ICH8_IFE_GT         0x10C4
+#define E1000_DEV_ID_ICH8_IFE_G          0x10C5
 #define E1000_DEV_ID_ICH8_IGP_M          0x104D
 
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 2cd5009..f078f6b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -103,6 +103,9 @@ static struct pci_device_id e1000_pci_tb
 	INTEL_E1000_ETHERNET_DEVICE(0x10B9),
 	INTEL_E1000_ETHERNET_DEVICE(0x10BA),
 	INTEL_E1000_ETHERNET_DEVICE(0x10BB),
+	INTEL_E1000_ETHERNET_DEVICE(0x10BC),
+	INTEL_E1000_ETHERNET_DEVICE(0x10C4),
+	INTEL_E1000_ETHERNET_DEVICE(0x10C5),
 	/* required last entry */
 	{0,}
 };
@@ -961,6 +964,7 @@ e1000_probe(struct pci_dev *pdev,
 		break;
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
+	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
 		/* if quad port adapter, disable WoL on all but port A */
 		if (global_quad_port_a != 0)
 			adapter->eeprom_wol = 0;



---
Auke Kok <auke-jan.h.kok@intel.com>
