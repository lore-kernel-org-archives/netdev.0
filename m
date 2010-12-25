From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 05/15] e1000e: checkpatch warnings - braces
Date: Fri, 24 Dec 2010 22:06:04 -0800
Message-ID: <1293257174-15498-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751271Ab0LYGG4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:06:56 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

WARNING: braces {} are not necessary for any arm of this statement
WARNING: braces {} are not necessary for single statement blocks

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ich8lan.c |    5 ++---
 drivers/net/e1000e/lib.c     |    6 ++----
 drivers/net/e1000e/netdev.c  |   19 +++++++------------
 drivers/net/e1000e/phy.c     |    3 +--
 4 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 5080372..d86cc08 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2309,11 +2309,10 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		 */
 		if (ret_val == 0) {
 			flash_data = er32flash(ICH_FLASH_FDATA0);
-			if (size == 1) {
+			if (size == 1)
 				*data = (u8)(flash_data & 0x000000FF);
-			} else if (size == 2) {
+			else if (size == 2)
 				*data = (u16)(flash_data & 0x0000FFFF);
-			}
 			break;
 		} else {
 			/*
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 8377523..7e55170 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -493,9 +493,8 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 	 * different link partner.
 	 */
 	ret_val = e1000e_config_fc_after_link_up(hw);
-	if (ret_val) {
+	if (ret_val)
 		e_dbg("Error configuring flow control\n");
-	}
 
 	return ret_val;
 }
@@ -1496,9 +1495,8 @@ s32 e1000e_setup_led_generic(struct e1000_hw *hw)
 {
 	u32 ledctl;
 
-	if (hw->mac.ops.setup_led != e1000e_setup_led_generic) {
+	if (hw->mac.ops.setup_led != e1000e_setup_led_generic)
 		return -E1000_ERR_CONFIG;
-	}
 
 	if (hw->phy.media_type == e1000_media_type_fiber) {
 		ledctl = er32(LEDCTL);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index ec7b77f..fe50242 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1806,9 +1806,8 @@ void e1000e_set_interrupt_capability(struct e1000_adapter *adapter)
 				err = pci_enable_msix(adapter->pdev,
 						      adapter->msix_entries,
 						      adapter->num_vectors);
-				if (err == 0) {
+				if (err == 0)
 					return;
-				}
 			}
 			/* MSI-X failed, so fall through and try MSI */
 			e_err("Failed to initialize MSI-X interrupts.  "
@@ -2198,9 +2197,8 @@ void e1000e_free_rx_resources(struct e1000_adapter *adapter)
 
 	e1000_clean_rx_ring(adapter);
 
-	for (i = 0; i < rx_ring->count; i++) {
+	for (i = 0; i < rx_ring->count; i++)
 		kfree(rx_ring->buffer_info[i].ps_pages);
-	}
 
 	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
@@ -2240,20 +2238,18 @@ static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
 		/* handle TSO and jumbo frames */
 		if (bytes/packets > 8000)
 			retval = bulk_latency;
-		else if ((packets < 5) && (bytes > 512)) {
+		else if ((packets < 5) && (bytes > 512))
 			retval = low_latency;
-		}
 		break;
 	case low_latency:  /* 50 usec aka 20000 ints/s */
 		if (bytes > 10000) {
 			/* this if handles the TSO accounting */
-			if (bytes/packets > 8000) {
+			if (bytes/packets > 8000)
 				retval = bulk_latency;
-			} else if ((packets < 10) || ((bytes/packets) > 1200)) {
+			else if ((packets < 10) || ((bytes/packets) > 1200))
 				retval = bulk_latency;
-			} else if ((packets > 35)) {
+			else if ((packets > 35))
 				retval = lowest_latency;
-			}
 		} else if (bytes/packets > 2000) {
 			retval = bulk_latency;
 		} else if (packets <= 2 && bytes < 512) {
@@ -2262,9 +2258,8 @@ static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
 		break;
 	case bulk_latency: /* 250 usec aka 4000 ints/s */
 		if (bytes > 25000) {
-			if (packets > 35) {
+			if (packets > 35)
 				retval = low_latency;
-			}
 		} else if (bytes < 6000) {
 			retval = low_latency;
 		}
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index e297a23..1781efe 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1057,9 +1057,8 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 
 	e_dbg("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
-	if (phy->autoneg_mask & ADVERTISE_1000_FULL) {
+	if (phy->autoneg_mask & ADVERTISE_1000_FULL)
 		ret_val = e1e_wphy(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);
-	}
 
 	return ret_val;
 }
-- 
1.7.3.4

