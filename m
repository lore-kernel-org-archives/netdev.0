From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 16/26] igb: rename igb_update_mc_addr_list_82575 to
	not include the 82575
Date: Sat, 07 Feb 2009 01:20:10 -0800
Message-ID: <20090207092010.15697.29840.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:44136
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754219AbZBGJUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:20:31 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There isn't much point in having the _82575 hanging off the end of this
function since there aren't any other version of this function running
around within this driver.  This also allows for a bit of whitespace
cleanup due to a shorter function name.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    8 ++++----
 drivers/net/igb/e1000_82575.h |    2 +-
 drivers/net/igb/igb_main.c    |    7 +++----
 3 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 527d4c8..68a9822 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -787,7 +787,7 @@ static void igb_init_rx_addrs_82575(struct e1000_hw *hw, u16 rar_count)
 }
 
 /**
- *  igb_update_mc_addr_list_82575 - Update Multicast addresses
+ *  igb_update_mc_addr_list - Update Multicast addresses
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
  *  @mc_addr_count: number of multicast addresses to program
@@ -799,9 +799,9 @@ static void igb_init_rx_addrs_82575(struct e1000_hw *hw, u16 rar_count)
  *  The parameter rar_count will usually be hw->mac.rar_entry_count
  *  unless there are workarounds that change this.
  **/
-void igb_update_mc_addr_list_82575(struct e1000_hw *hw,
-                                   u8 *mc_addr_list, u32 mc_addr_count,
-                                   u32 rar_used_count, u32 rar_count)
+void igb_update_mc_addr_list(struct e1000_hw *hw,
+                             u8 *mc_addr_list, u32 mc_addr_count,
+                             u32 rar_used_count, u32 rar_count)
 {
 	u32 hash_value;
 	u32 i;
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index c1928b5..e0a376f 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -28,7 +28,7 @@
 #ifndef _E1000_82575_H_
 #define _E1000_82575_H_
 
-void igb_update_mc_addr_list_82575(struct e1000_hw*, u8*, u32, u32, u32);
+void igb_update_mc_addr_list(struct e1000_hw*, u8*, u32, u32, u32);
 extern void igb_shutdown_fiber_serdes_link_82575(struct e1000_hw *hw);
 extern void igb_rx_fifo_flush_82575(struct e1000_hw *hw);
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index cbb3858..2d169a4 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2227,8 +2227,8 @@ static void igb_set_multi(struct net_device *netdev)
 
 	if (!netdev->mc_count) {
 		/* nothing to program, so clear mc list */
-		igb_update_mc_addr_list_82575(hw, NULL, 0, 1,
-					  mac->rar_entry_count);
+		igb_update_mc_addr_list(hw, NULL, 0, 1,
+					mac->rar_entry_count);
 		return;
 	}
 
@@ -2245,8 +2245,7 @@ static void igb_set_multi(struct net_device *netdev)
 		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
 		mc_ptr = mc_ptr->next;
 	}
-	igb_update_mc_addr_list_82575(hw, mta_list, i, 1,
-	                              mac->rar_entry_count);
+	igb_update_mc_addr_list(hw, mta_list, i, 1, mac->rar_entry_count);
 	kfree(mta_list);
 }
 

