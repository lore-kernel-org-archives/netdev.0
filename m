From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 5/8] igb: fix issue of set_mta member not being set
Date: Fri, 01 Aug 2008 16:11:30 -0700
Message-ID: <20080801231130.393.86587.stgit@localhost.localdomain>
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
	id S1751231AbYHAXLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 19:11:31 -0400
In-Reply-To: <20080801231106.393.46174.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igb_mta_set function was not being correctly assigned to the mac
operations function pointer

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    1 +
 drivers/net/igb/e1000_mac.c   |    2 +-
 drivers/net/igb/e1000_mac.h   |    1 +
 3 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index cd75a2b..3310705 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1495,6 +1495,7 @@ static struct e1000_mac_operations e1000_mac_ops_82575 = {
 	.rar_set              = igb_rar_set,
 	.read_mac_addr        = igb_read_mac_addr_82575,
 	.get_speed_and_duplex = igb_get_speed_and_duplex_copper,
+	.mta_set              = igb_mta_set,
 };
 
 static struct e1000_phy_operations e1000_phy_ops_82575 = {
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

