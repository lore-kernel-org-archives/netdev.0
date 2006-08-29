From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 10/26] e1000: Add PCI ID 0x10a4 for our new 4-port PCI-Express device
Date: Tue, 29 Aug 2006 09:44:37 -0700
Message-ID: <20060829164436.6872.89483.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:37898 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965084AbWH2QgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:23 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Device 0x10a4 is a double 82571 on a single PCI-Express card and
has 4 gigabit capable ports.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    1 +
 drivers/net/e1000/e1000_hw.c      |    1 +
 drivers/net/e1000/e1000_hw.h      |    1 +
 drivers/net/e1000/e1000_main.c    |    2 ++
 4 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 0403072..3fccffd 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1705,6 +1705,7 @@ static int e1000_wol_exclusion(struct e1
 		/* return success for non excluded adapter ports */
 		retval = 0;
 		break;
+	case E1000_DEV_ID_82571EB_QUAD_COPPER:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		/* quad port adapters only support WoL on port A */
 		if (!adapter->quad_port_a) {
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index f56d4cd..4b54c48 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -389,6 +389,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
     case E1000_DEV_ID_82571EB_COPPER:
     case E1000_DEV_ID_82571EB_FIBER:
     case E1000_DEV_ID_82571EB_SERDES:
+    case E1000_DEV_ID_82571EB_QUAD_COPPER:
             hw->mac_type = e1000_82571;
         break;
     case E1000_DEV_ID_82572EI_COPPER:
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 4f74242..a170e96 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -470,6 +470,7 @@ int32_t e1000_check_phy_reset_block(stru
 #define E1000_DEV_ID_82571EB_COPPER      0x105E
 #define E1000_DEV_ID_82571EB_FIBER       0x105F
 #define E1000_DEV_ID_82571EB_SERDES      0x1060
+#define E1000_DEV_ID_82571EB_QUAD_COPPER 0x10A4
 #define E1000_DEV_ID_82572EI_COPPER      0x107D
 #define E1000_DEV_ID_82572EI_FIBER       0x107E
 #define E1000_DEV_ID_82572EI_SERDES      0x107F
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 6dbafb1..87a562f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -98,6 +98,7 @@ static struct pci_device_id e1000_pci_tb
 	INTEL_E1000_ETHERNET_DEVICE(0x1098),
 	INTEL_E1000_ETHERNET_DEVICE(0x1099),
 	INTEL_E1000_ETHERNET_DEVICE(0x109A),
+	INTEL_E1000_ETHERNET_DEVICE(0x10A4),
 	INTEL_E1000_ETHERNET_DEVICE(0x10B5),
 	INTEL_E1000_ETHERNET_DEVICE(0x10B9),
 	INTEL_E1000_ETHERNET_DEVICE(0x10BA),
@@ -922,6 +923,7 @@ e1000_probe(struct pci_dev *pdev,
 			adapter->eeprom_wol = 0;
 		break;
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
+	case E1000_DEV_ID_82571EB_QUAD_COPPER:
 		/* if quad port adapter, disable WoL on all but port A */
 		if (global_quad_port_a != 0)
 			adapter->eeprom_wol = 0;



---
Auke Kok <auke-jan.h.kok@intel.com>
