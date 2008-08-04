From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [UPDATED PATCH 4/7] igb: correct issue of set_mta member of mac.ops
	not being populated
Date: Mon, 04 Aug 2008 15:00:06 -0700
Message-ID: <20080804220001.16188.70685.stgit@localhost.localdomain>
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
Received: from mga11.intel.com ([192.55.52.93]:28500 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752364AbYHDWAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 18:00:07 -0400
In-Reply-To: <20080804215531.16188.73257.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igb_mta_set function was not being correctly used

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    2 +-
 drivers/net/igb/e1000_hw.h    |    1 -
 drivers/net/igb/e1000_mac.c   |    2 +-
 drivers/net/igb/e1000_mac.h   |    1 +
 4 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index cd75a2b..76f9f86 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -850,7 +850,7 @@ void igb_update_mc_addr_list_82575(struct e1000_hw *hw,
 	for (; mc_addr_count > 0; mc_addr_count--) {
 		hash_value = igb_hash_mc_addr(hw, mc_addr_list);
 		hw_dbg("Hash value = 0x%03X\n", hash_value);
-		hw->mac.ops.mta_set(hw, hash_value);
+		igb_mta_set(hw, hash_value);
 		mc_addr_list += ETH_ALEN;
 	}
 }
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 19fa4ee..a65ccc3 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -420,7 +420,6 @@ struct e1000_mac_operations {
 	void (*rar_set)(struct e1000_hw *, u8 *, u32);
 	s32  (*read_mac_addr)(struct e1000_hw *);
 	s32  (*get_speed_and_duplex)(struct e1000_hw *, u16 *, u16 *);
-	void (*mta_set)(struct e1000_hw *, u32);
 };
 
 struct e1000_phy_operations {
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 20408aa..9b0f0af 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -271,7 +271,7 @@ void igb_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
  *  current value is read, the new bit is OR'd in and the new value is
  *  written back into the register.
  **/
-static void igb_mta_set(struct e1000_hw *hw, u32 hash_value)
+void igb_mta_set(struct e1000_hw *hw, u32 hash_value)
 {
 	u32 hash_bit, hash_reg, mta;
 
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index dc2f8cc..c2a9365 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -63,6 +63,7 @@ void igb_clear_hw_cntrs_base(struct e1000_hw *hw);
 void igb_clear_vfta(struct e1000_hw *hw);
 void igb_config_collision_dist(struct e1000_hw *hw);
 void igb_init_rx_addrs(struct e1000_hw *hw, u16 rar_count);
+void igb_mta_set(struct e1000_hw *hw, u32 hash_value);
 void igb_put_hw_semaphore(struct e1000_hw *hw);
 void igb_rar_set(struct e1000_hw *hw, u8 *addr, u32 index);
 s32  igb_check_alt_mac_addr(struct e1000_hw *hw);

