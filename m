From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Subject: [PATCH 2/7] e1000e: cleanup: fix bracket issues
Date: Thu,  9 Dec 2010 02:40:52 +0000
Message-ID: <1291862457-16671-3-git-send-email-asbjorn@asbjorn.biz>
References: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes bracket-related issues reported by checkpatch, such as
unnecessary brackets around statements, brackets placed incorrectly,
and missing brackets.

Fixes 7 errors and 10 warnings reported by checkpatch.

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
---
 drivers/net/e1000e/es2lan.c  |    8 ++++----
 drivers/net/e1000e/ethtool.c |    4 ++--
 drivers/net/e1000e/hw.h      |    2 +-
 drivers/net/e1000e/ich8lan.c |    5 ++---
 drivers/net/e1000e/lib.c     |    6 ++----
 drivers/net/e1000e/netdev.c  |   21 ++++++++-------------
 drivers/net/e1000e/phy.c     |   28 +++++++++++++---------------
 7 files changed, 32 insertions(+), 42 deletions(-)

diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index afed60f..6069e9f 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -100,8 +100,8 @@
  * with a lower bound at "index" and the upper bound at
  * "index + 5".
  */
-static const u16 e1000_gg82563_cable_length_table[] =
-	 { 0, 60, 115, 150, 150, 60, 115, 150, 180, 180, 0xFF };
+static const u16 e1000_gg82563_cable_length_table[] = {
+	0, 60, 115, 150, 150, 60, 115, 150, 180, 180, 0xFF };
 #define GG82563_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_gg82563_cable_length_table)
 
@@ -426,8 +426,8 @@ static void e1000_release_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 {
 	u32 swfw_sync;
 
-	while (e1000e_get_hw_semaphore(hw) != 0);
-	/* Empty */
+	while (e1000e_get_hw_semaphore(hw) != 0)
+		; /* Empty */
 
 	swfw_sync = er32(SW_FW_SYNC);
 	swfw_sync &= ~mask;
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 8acfbca..8ff3a8a 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -763,8 +763,8 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data,
 			     int reg, int offset, u32 mask, u32 write)
 {
 	u32 pat, val;
-	static const u32 test[] =
-		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
+	static const u32 test[] = {
+		0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
 	for (pat = 0; pat < ARRAY_SIZE(test); pat++) {
 		E1000_WRITE_REG_ARRAY(&adapter->hw, reg, offset,
 				      (test[pat] & write));
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 0a319e1..f009dd5 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -469,7 +469,7 @@ enum e1000_1000t_rx_status {
 	e1000_1000t_rx_status_undefined = 0xFF
 };
 
-enum e1000_rev_polarity{
+enum e1000_rev_polarity {
 	e1000_rev_polarity_normal = 0,
 	e1000_rev_polarity_reversed,
 	e1000_rev_polarity_undefined = 0xFF
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 53edfd4..c5a7726 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2303,11 +2303,10 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
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
index 20870b2..513b4d1 100644
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
index 820ea48..d71854f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1325,7 +1325,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				goto next_desc;
 		}
 
-#define rxtop rx_ring->rx_skb_top
+#define rxtop (rx_ring->rx_skb_top)
 		if (!(status & E1000_RXD_STAT_EOP)) {
 			/* this descriptor is only the beginning (or middle) */
 			if (!rxtop) {
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
index a26c296..23b1e48 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -42,20 +42,20 @@ static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
 					  u16 *data, bool read);
 
 /* Cable length tables */
-static const u16 e1000_m88_cable_length_table[] =
-	{ 0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
+static const u16 e1000_m88_cable_length_table[] = {
+	0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
 #define M88E1000_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_m88_cable_length_table)
 
-static const u16 e1000_igp_2_cable_length_table[] =
-	{ 0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21, 0, 0, 0, 3,
-	  6, 10, 13, 16, 19, 23, 26, 29, 32, 35, 38, 41, 6, 10, 14, 18, 22,
-	  26, 30, 33, 37, 41, 44, 48, 51, 54, 58, 61, 21, 26, 31, 35, 40,
-	  44, 49, 53, 57, 61, 65, 68, 72, 75, 79, 82, 40, 45, 51, 56, 61,
-	  66, 70, 75, 79, 83, 87, 91, 94, 98, 101, 104, 60, 66, 72, 77, 82,
-	  87, 92, 96, 100, 104, 108, 111, 114, 117, 119, 121, 83, 89, 95,
-	  100, 105, 109, 113, 116, 119, 122, 124, 104, 109, 114, 118, 121,
-	  124};
+static const u16 e1000_igp_2_cable_length_table[] = {
+	0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21, 0, 0, 0, 3,
+	6, 10, 13, 16, 19, 23, 26, 29, 32, 35, 38, 41, 6, 10, 14, 18, 22,
+	26, 30, 33, 37, 41, 44, 48, 51, 54, 58, 61, 21, 26, 31, 35, 40,
+	44, 49, 53, 57, 61, 65, 68, 72, 75, 79, 82, 40, 45, 51, 56, 61,
+	66, 70, 75, 79, 83, 87, 91, 94, 98, 101, 104, 60, 66, 72, 77, 82,
+	87, 92, 96, 100, 104, 108, 111, 114, 117, 119, 121, 83, 89, 95,
+	100, 105, 109, 113, 116, 119, 122, 124, 104, 109, 114, 118, 121,
+	124 };
 #define IGP02E1000_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_igp_2_cable_length_table)
 
@@ -1043,9 +1043,8 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 
 	e_dbg("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
-	if (phy->autoneg_mask & ADVERTISE_1000_FULL) {
+	if (phy->autoneg_mask & ADVERTISE_1000_FULL)
 		ret_val = e1e_wphy(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);
-	}
 
 	return ret_val;
 }
@@ -1840,8 +1839,7 @@ s32 e1000e_get_cable_length_igp_2(struct e1000_hw *hw)
 	u16 phy_data, i, agc_value = 0;
 	u16 cur_agc_index, max_agc_index = 0;
 	u16 min_agc_index = IGP02E1000_CABLE_LENGTH_TABLE_SIZE - 1;
-	u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] =
-							 {IGP02E1000_PHY_AGC_A,
+	u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] = { IGP02E1000_PHY_AGC_A,
 							  IGP02E1000_PHY_AGC_B,
 							  IGP02E1000_PHY_AGC_C,
 							  IGP02E1000_PHY_AGC_D};
-- 
1.7.2.3
