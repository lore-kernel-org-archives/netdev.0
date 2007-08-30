From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: Add device IDs of blade version of the 82571 quad port
Date: Thu, 30 Aug 2007 11:23:58 -0700
Message-ID: <20070830182357.14185.69495.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com,
	auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26741 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932608AbXH3SYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 14:24:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This blade-specific board form factor is identical to the 82571EB
board.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    1 +
 drivers/net/e1000/e1000_hw.c      |    1 +
 drivers/net/e1000/e1000_hw.h      |    1 +
 drivers/net/e1000/e1000_main.c    |    2 ++
 4 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 4c3785c..9ecc3ad 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1726,6 +1726,7 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter, struct ethtool_wol
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
 	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
+	case E1000_DEV_ID_82571PT_QUAD_COPPER:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		/* quad port adapters only support WoL on port A */
 		if (!adapter->quad_port_a) {
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index ba120f7..8604adb 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -387,6 +387,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
 	case E1000_DEV_ID_82571EB_SERDES_DUAL:
 	case E1000_DEV_ID_82571EB_SERDES_QUAD:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
+	case E1000_DEV_ID_82571PT_QUAD_COPPER:
 	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
 		hw->mac_type = e1000_82571;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index fe87146..07f0ea7 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -475,6 +475,7 @@ int32_t e1000_check_phy_reset_block(struct e1000_hw *hw);
 #define E1000_DEV_ID_82571EB_FIBER       0x105F
 #define E1000_DEV_ID_82571EB_SERDES      0x1060
 #define E1000_DEV_ID_82571EB_QUAD_COPPER 0x10A4
+#define E1000_DEV_ID_82571PT_QUAD_COPPER 0x10D5
 #define E1000_DEV_ID_82571EB_QUAD_FIBER  0x10A5
 #define E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE  0x10BC
 #define E1000_DEV_ID_82571EB_SERDES_DUAL 0x10D9
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4a22595..e7c8951 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -108,6 +108,7 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	INTEL_E1000_ETHERNET_DEVICE(0x10BC),
 	INTEL_E1000_ETHERNET_DEVICE(0x10C4),
 	INTEL_E1000_ETHERNET_DEVICE(0x10C5),
+	INTEL_E1000_ETHERNET_DEVICE(0x10D5),
 	INTEL_E1000_ETHERNET_DEVICE(0x10D9),
 	INTEL_E1000_ETHERNET_DEVICE(0x10DA),
 	/* required last entry */
@@ -1101,6 +1102,7 @@ e1000_probe(struct pci_dev *pdev,
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
 	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
+	case E1000_DEV_ID_82571PT_QUAD_COPPER:
 		/* if quad port adapter, disable WoL on all but port A */
 		if (global_quad_port_a != 0)
 			adapter->eeprom_wol = 0;
