From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 6/8] igb: remove two redundant functions
Date: Fri, 01 Aug 2008 16:11:35 -0700
Message-ID: <20080801231135.393.32635.stgit@localhost.localdomain>
References: <20080801231106.393.46174.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62897 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752008AbYHAXLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 19:11:36 -0400
In-Reply-To: <20080801231106.393.46174.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Two functions were left in the code that are no longer used.  Removing
these functions to keep the code clean.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_mac.c |   82 -------------------------------------------
 drivers/net/igb/e1000_mac.h |    4 --
 2 files changed, 0 insertions(+), 86 deletions(-)

diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 9b0f0af..e18747c 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -144,34 +144,6 @@ void igb_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
 }
 
 /**
- *  igb_init_rx_addrs - Initialize receive address's
- *  @hw: pointer to the HW structure
- *  @rar_count: receive address registers
- *
- *  Setups the receive address registers by setting the base receive address
- *  register to the devices MAC address and clearing all the other receive
- *  address registers to 0.
- **/
-void igb_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
-{
-	u32 i;
-
-	/* Setup the receive address */
-	hw_dbg("Programming MAC Address into RAR[0]\n");
-
-	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
-
-	/* Zero out the other (rar_entry_count - 1) receive addresses */
-	hw_dbg("Clearing RAR[1-%u]\n", rar_count-1);
-	for (i = 1; i < rar_count; i++) {
-		array_wr32(E1000_RA, (i << 1), 0);
-		wrfl();
-		array_wr32(E1000_RA, ((i << 1) + 1), 0);
-		wrfl();
-	}
-}
-
-/**
  *  igb_check_alt_mac_addr - Check for alternate MAC addr
  *  @hw: pointer to the HW structure
  *
@@ -297,60 +269,6 @@ void igb_mta_set(struct e1000_hw *hw, u32 hash_value)
 }
 
 /**
- *  igb_update_mc_addr_list - Update Multicast addresses
- *  @hw: pointer to the HW structure
- *  @mc_addr_list: array of multicast addresses to program
- *  @mc_addr_count: number of multicast addresses to program
- *  @rar_used_count: the first RAR register free to program
- *  @rar_count: total number of supported Receive Address Registers
- *
- *  Updates the Receive Address Registers and Multicast Table Array.
- *  The caller must have a packed mc_addr_list of multicast addresses.
- *  The parameter rar_count will usually be hw->mac.rar_entry_count
- *  unless there are workarounds that change this.
- **/
-void igb_update_mc_addr_list(struct e1000_hw *hw,
-			       u8 *mc_addr_list, u32 mc_addr_count,
-			       u32 rar_used_count, u32 rar_count)
-{
-	u32 hash_value;
-	u32 i;
-
-	/*
-	 * Load the first set of multicast addresses into the exact
-	 * filters (RAR).  If there are not enough to fill the RAR
-	 * array, clear the filters.
-	 */
-	for (i = rar_used_count; i < rar_count; i++) {
-		if (mc_addr_count) {
-			hw->mac.ops.rar_set(hw, mc_addr_list, i);
-			mc_addr_count--;
-			mc_addr_list += ETH_ALEN;
-		} else {
-			array_wr32(E1000_RA, i << 1, 0);
-			wrfl();
-			array_wr32(E1000_RA, (i << 1) + 1, 0);
-			wrfl();
-		}
-	}
-
-	/* Clear the old settings from the MTA */
-	hw_dbg("Clearing MTA\n");
-	for (i = 0; i < hw->mac.mta_reg_count; i++) {
-		array_wr32(E1000_MTA, i, 0);
-		wrfl();
-	}
-
-	/* Load any remaining multicast addresses into the hash table. */
-	for (; mc_addr_count > 0; mc_addr_count--) {
-		hash_value = igb_hash_mc_addr(hw, mc_addr_list);
-		hw_dbg("Hash value = 0x%03X\n", hash_value);
-		igb_mta_set(hw, hash_value);
-		mc_addr_list += ETH_ALEN;
-	}
-}
-
-/**
  *  igb_hash_mc_addr - Generate a multicast hash value
  *  @hw: pointer to the HW structure
  *  @mc_addr: pointer to a multicast address
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index c2a9365..cbee6af 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -51,9 +51,6 @@ s32  igb_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed,
 				       u16 *duplex);
 s32  igb_id_led_init(struct e1000_hw *hw);
 s32  igb_led_off(struct e1000_hw *hw);
-void igb_update_mc_addr_list(struct e1000_hw *hw,
-			       u8 *mc_addr_list, u32 mc_addr_count,
-			       u32 rar_used_count, u32 rar_count);
 s32  igb_setup_link(struct e1000_hw *hw);
 s32  igb_validate_mdi_setting(struct e1000_hw *hw);
 s32  igb_write_8bit_ctrl_reg(struct e1000_hw *hw, u32 reg,
@@ -62,7 +59,6 @@ s32  igb_write_8bit_ctrl_reg(struct e1000_hw *hw, u32 reg,
 void igb_clear_hw_cntrs_base(struct e1000_hw *hw);
 void igb_clear_vfta(struct e1000_hw *hw);
 void igb_config_collision_dist(struct e1000_hw *hw);
-void igb_init_rx_addrs(struct e1000_hw *hw, u16 rar_count);
 void igb_mta_set(struct e1000_hw *hw, u32 hash_value);
 void igb_put_hw_semaphore(struct e1000_hw *hw);
 void igb_rar_set(struct e1000_hw *hw, u8 *addr, u32 index);

