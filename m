From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [UPDATED PATCH 7/7] igb: remove 82576 quad adapter
Date: Mon, 04 Aug 2008 15:00:40 -0700
Message-ID: <20080804220032.16188.65651.stgit@localhost.localdomain>
References: <20080804215531.16188.73257.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17968 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754922AbYHDWAm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 18:00:42 -0400
In-Reply-To: <20080804215531.16188.73257.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

removing the 82576 quad adapter as it will not have completed testing by
the time the kernel has been released.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    1 -
 drivers/net/igb/e1000_hw.h    |    1 -
 drivers/net/igb/igb_ethtool.c |    9 ---------
 drivers/net/igb/igb_main.c    |   11 -----------
 4 files changed, 0 insertions(+), 22 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index bb823ac..f5e2e72 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -87,7 +87,6 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	case E1000_DEV_ID_82576:
 	case E1000_DEV_ID_82576_FIBER:
 	case E1000_DEV_ID_82576_SERDES:
-	case E1000_DEV_ID_82576_QUAD_COPPER:
 		mac->type = e1000_82576;
 		break;
 	default:
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index a65ccc3..99504a6 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -41,7 +41,6 @@ struct e1000_hw;
 #define E1000_DEV_ID_82576                    0x10C9
 #define E1000_DEV_ID_82576_FIBER              0x10E6
 #define E1000_DEV_ID_82576_SERDES             0x10E7
-#define E1000_DEV_ID_82576_QUAD_COPPER        0x10E8
 #define E1000_DEV_ID_82575EB_COPPER           0x10A7
 #define E1000_DEV_ID_82575EB_FIBER_SERDES     0x10A9
 #define E1000_DEV_ID_82575GB_QUAD_COPPER      0x10D6
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 11aee13..6c0a8c2 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1746,15 +1746,6 @@ static int igb_wol_exclusion(struct igb_adapter *adapter,
 		/* return success for non excluded adapter ports */
 		retval = 0;
 		break;
-	case E1000_DEV_ID_82576_QUAD_COPPER:
-		/* quad port adapters only support WoL on port A */
-		if (!(adapter->flags & IGB_FLAG_QUAD_PORT_A)) {
-			wol->supported = 0;
-			break;
-		}
-		/* return success for non excluded adapter ports */
-		retval = 0;
-		break;
 	default:
 		/* dual port cards only support WoL on port A from now on
 		 * unless it was enabled in the eeprom for port B
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 8f66e15..4b19abb 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -61,7 +61,6 @@ static struct pci_device_id igb_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_FIBER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_SERDES), board_82575 },
-	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_QUAD_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575EB_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575EB_FIBER_SERDES), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575GB_QUAD_COPPER), board_82575 },
@@ -1217,16 +1216,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		if (rd32(E1000_STATUS) & E1000_STATUS_FUNC_1)
 			adapter->eeprom_wol = 0;
 		break;
-	case E1000_DEV_ID_82576_QUAD_COPPER:
-		/* if quad port adapter, disable WoL on all but port A */
-		if (global_quad_port_a != 0)
-			adapter->eeprom_wol = 0;
-		else
-			adapter->flags |= IGB_FLAG_QUAD_PORT_A;
-		/* Reset for multiple quad port adapters */
-		if (++global_quad_port_a == 4)
-			global_quad_port_a = 0;
-		break;
 	}
 
 	/* initialize the wol settings based on the eeprom settings */

