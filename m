From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: Add device IDs of new 82571 board variants
Date: Thu, 09 Aug 2007 14:09:34 -0700
Message-ID: <20070809210934.19268.45172.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bruce.w.allan@intel.com,
	john.ronciak@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:31126 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753173AbXHIVJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 17:09:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for 2 new board variants:
- A Quad port fiber 82571 board
- A blade version of the 82571 quad copper board

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    2 ++
 drivers/net/e1000/e1000_hw.c      |    5 +++++
 drivers/net/e1000/e1000_hw.h      |    3 +++
 drivers/net/e1000/e1000_main.c    |    4 ++++
 4 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index c90c92e..4c3785c 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1706,6 +1706,7 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter, struct ethtool_wol
 	case E1000_DEV_ID_82545EM_COPPER:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER:
 	case E1000_DEV_ID_82546GB_PCIE:
+	case E1000_DEV_ID_82571EB_SERDES_QUAD:
 		/* these don't support WoL at all */
 		wol->supported = 0;
 		break;
@@ -1723,6 +1724,7 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter, struct ethtool_wol
 		retval = 0;
 		break;
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
+	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		/* quad port adapters only support WoL on port A */
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 9be4469..ba120f7 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -384,7 +384,10 @@ e1000_set_mac_type(struct e1000_hw *hw)
 	case E1000_DEV_ID_82571EB_COPPER:
 	case E1000_DEV_ID_82571EB_FIBER:
 	case E1000_DEV_ID_82571EB_SERDES:
+	case E1000_DEV_ID_82571EB_SERDES_DUAL:
+	case E1000_DEV_ID_82571EB_SERDES_QUAD:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
+	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
 		hw->mac_type = e1000_82571;
 		break;
@@ -485,6 +488,8 @@ e1000_set_media_type(struct e1000_hw *hw)
     case E1000_DEV_ID_82545GM_SERDES:
     case E1000_DEV_ID_82546GB_SERDES:
     case E1000_DEV_ID_82571EB_SERDES:
+    case E1000_DEV_ID_82571EB_SERDES_DUAL:
+    case E1000_DEV_ID_82571EB_SERDES_QUAD:
     case E1000_DEV_ID_82572EI_SERDES:
     case E1000_DEV_ID_80003ES2LAN_SERDES_DPT:
         hw->media_type = e1000_media_type_internal_serdes;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index bd000b8..fe87146 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -475,7 +475,10 @@ int32_t e1000_check_phy_reset_block(struct e1000_hw *hw);
 #define E1000_DEV_ID_82571EB_FIBER       0x105F
 #define E1000_DEV_ID_82571EB_SERDES      0x1060
 #define E1000_DEV_ID_82571EB_QUAD_COPPER 0x10A4
+#define E1000_DEV_ID_82571EB_QUAD_FIBER  0x10A5
 #define E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE  0x10BC
+#define E1000_DEV_ID_82571EB_SERDES_DUAL 0x10D9
+#define E1000_DEV_ID_82571EB_SERDES_QUAD 0x10DA
 #define E1000_DEV_ID_82572EI_COPPER      0x107D
 #define E1000_DEV_ID_82572EI_FIBER       0x107E
 #define E1000_DEV_ID_82572EI_SERDES      0x107F
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f48b659..4a22595 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -100,6 +100,7 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	INTEL_E1000_ETHERNET_DEVICE(0x1099),
 	INTEL_E1000_ETHERNET_DEVICE(0x109A),
 	INTEL_E1000_ETHERNET_DEVICE(0x10A4),
+	INTEL_E1000_ETHERNET_DEVICE(0x10A5),
 	INTEL_E1000_ETHERNET_DEVICE(0x10B5),
 	INTEL_E1000_ETHERNET_DEVICE(0x10B9),
 	INTEL_E1000_ETHERNET_DEVICE(0x10BA),
@@ -107,6 +108,8 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	INTEL_E1000_ETHERNET_DEVICE(0x10BC),
 	INTEL_E1000_ETHERNET_DEVICE(0x10C4),
 	INTEL_E1000_ETHERNET_DEVICE(0x10C5),
+	INTEL_E1000_ETHERNET_DEVICE(0x10D9),
+	INTEL_E1000_ETHERNET_DEVICE(0x10DA),
 	/* required last entry */
 	{0,}
 };
@@ -1096,6 +1099,7 @@ e1000_probe(struct pci_dev *pdev,
 		break;
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
+	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
 		/* if quad port adapter, disable WoL on all but port A */
 		if (global_quad_port_a != 0)
