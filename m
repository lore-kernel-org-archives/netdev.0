From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/8] e1000e: rename mc_addr_list_update
Date: Fri, 28 Mar 2008 09:15:11 -0700
Message-ID: <20080328161510.6562.79584.stgit@localhost.localdomain>
References: <20080328161503.6562.44329.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080328161503.6562.44329.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Rename this function to be consistent with function naming (verb first)

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/82571.c   |   10 +++++-----
 drivers/net/e1000e/e1000.h   |    8 +++++---
 drivers/net/e1000e/es2lan.c  |    2 +-
 drivers/net/e1000e/hw.h      |    2 +-
 drivers/net/e1000e/ich8lan.c |    2 +-
 drivers/net/e1000e/lib.c     |    8 ++++----
 drivers/net/e1000e/netdev.c  |   15 +++++++--------
 7 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index c58dc2e..f5a4d40 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -972,7 +972,7 @@ void e1000e_clear_vfta(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_mc_addr_list_update_82571 - Update Multicast addresses
+ *  e1000_update_mc_addr_list_82571 - Update Multicast addresses
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
  *  @mc_addr_count: number of multicast addresses to program
@@ -984,7 +984,7 @@ void e1000e_clear_vfta(struct e1000_hw *hw)
  *  The parameter rar_count will usually be hw->mac.rar_entry_count
  *  unless there are workarounds that change this.
  **/
-static void e1000_mc_addr_list_update_82571(struct e1000_hw *hw,
+static void e1000_update_mc_addr_list_82571(struct e1000_hw *hw,
 					    u8 *mc_addr_list,
 					    u32 mc_addr_count,
 					    u32 rar_used_count,
@@ -993,8 +993,8 @@ static void e1000_mc_addr_list_update_82571(struct e1000_hw *hw,
 	if (e1000e_get_laa_state_82571(hw))
 		rar_count--;
 
-	e1000e_mc_addr_list_update_generic(hw, mc_addr_list, mc_addr_count,
-					  rar_used_count, rar_count);
+	e1000e_update_mc_addr_list_generic(hw, mc_addr_list, mc_addr_count,
+					   rar_used_count, rar_count);
 }
 
 /**
@@ -1269,7 +1269,7 @@ static struct e1000_mac_operations e82571_mac_ops = {
 	/* .get_link_up_info: media type dependent */
 	.led_on			= e1000e_led_on_generic,
 	.led_off		= e1000e_led_off_generic,
-	.mc_addr_list_update	= e1000_mc_addr_list_update_82571,
+	.update_mc_addr_list	= e1000_update_mc_addr_list_82571,
 	.reset_hw		= e1000_reset_hw_82571,
 	.init_hw		= e1000_init_hw_82571,
 	.setup_link		= e1000_setup_link_82571,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index ffba63c..499adb2 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -387,9 +387,11 @@ extern s32 e1000e_copper_link_setup_igp(struct e1000_hw *hw);
 extern s32 e1000e_setup_link(struct e1000_hw *hw);
 extern void e1000e_clear_vfta(struct e1000_hw *hw);
 extern void e1000e_init_rx_addrs(struct e1000_hw *hw, u16 rar_count);
-extern void e1000e_mc_addr_list_update_generic(struct e1000_hw *hw,
-				       u8 *mc_addr_list, u32 mc_addr_count,
-				       u32 rar_used_count, u32 rar_count);
+extern void e1000e_update_mc_addr_list_generic(struct e1000_hw *hw,
+					       u8 *mc_addr_list,
+					       u32 mc_addr_count,
+					       u32 rar_used_count,
+					       u32 rar_count);
 extern void e1000e_rar_set(struct e1000_hw *hw, u8 *addr, u32 index);
 extern s32 e1000e_set_fc_watermarks(struct e1000_hw *hw);
 extern void e1000e_set_pcie_no_snoop(struct e1000_hw *hw, u32 no_snoop);
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 2657754..df27824 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1190,7 +1190,7 @@ static struct e1000_mac_operations es2_mac_ops = {
 	.get_link_up_info	= e1000_get_link_up_info_80003es2lan,
 	.led_on			= e1000e_led_on_generic,
 	.led_off		= e1000e_led_off_generic,
-	.mc_addr_list_update	= e1000e_mc_addr_list_update_generic,
+	.update_mc_addr_list	= e1000e_update_mc_addr_list_generic,
 	.reset_hw		= e1000_reset_hw_80003es2lan,
 	.init_hw		= e1000_init_hw_80003es2lan,
 	.setup_link		= e1000e_setup_link,
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 2346e2c..b582d78 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -685,7 +685,7 @@ struct e1000_mac_operations {
 	s32  (*get_link_up_info)(struct e1000_hw *, u16 *, u16 *);
 	s32  (*led_on)(struct e1000_hw *);
 	s32  (*led_off)(struct e1000_hw *);
-	void (*mc_addr_list_update)(struct e1000_hw *, u8 *, u32, u32, u32);
+	void (*update_mc_addr_list)(struct e1000_hw *, u8 *, u32, u32, u32);
 	s32  (*reset_hw)(struct e1000_hw *);
 	s32  (*init_hw)(struct e1000_hw *);
 	s32  (*setup_link)(struct e1000_hw *);
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 8440156..eed1b44 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2212,7 +2212,7 @@ static struct e1000_mac_operations ich8_mac_ops = {
 	.get_link_up_info	= e1000_get_link_up_info_ich8lan,
 	.led_on			= e1000_led_on_ich8lan,
 	.led_off		= e1000_led_off_ich8lan,
-	.mc_addr_list_update	= e1000e_mc_addr_list_update_generic,
+	.update_mc_addr_list	= e1000e_update_mc_addr_list_generic,
 	.reset_hw		= e1000_reset_hw_ich8lan,
 	.init_hw		= e1000_init_hw_ich8lan,
 	.setup_link		= e1000_setup_link_ich8lan,
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index b7eaff0..9c3ce71 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -265,7 +265,7 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 }
 
 /**
- *  e1000e_mc_addr_list_update_generic - Update Multicast addresses
+ *  e1000e_update_mc_addr_list_generic - Update Multicast addresses
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
  *  @mc_addr_count: number of multicast addresses to program
@@ -277,9 +277,9 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
  *  The parameter rar_count will usually be hw->mac.rar_entry_count
  *  unless there are workarounds that change this.
  **/
-void e1000e_mc_addr_list_update_generic(struct e1000_hw *hw,
-				       u8 *mc_addr_list, u32 mc_addr_count,
-				       u32 rar_used_count, u32 rar_count)
+void e1000e_update_mc_addr_list_generic(struct e1000_hw *hw,
+					u8 *mc_addr_list, u32 mc_addr_count,
+					u32 rar_used_count, u32 rar_count)
 {
 	u32 hash_value;
 	u32 i;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 88fac39..2e07534 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1889,7 +1889,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 }
 
 /**
- *  e1000_mc_addr_list_update - Update Multicast addresses
+ *  e1000_update_mc_addr_list - Update Multicast addresses
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
  *  @mc_addr_count: number of multicast addresses to program
@@ -1903,11 +1903,11 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
  *  exists and all implementations are handled in the generic version of this
  *  function.
  **/
-static void e1000_mc_addr_list_update(struct e1000_hw *hw, u8 *mc_addr_list,
-			       u32 mc_addr_count, u32 rar_used_count,
-			       u32 rar_count)
+static void e1000_update_mc_addr_list(struct e1000_hw *hw, u8 *mc_addr_list,
+				      u32 mc_addr_count, u32 rar_used_count,
+				      u32 rar_count)
 {
-	hw->mac.ops.mc_addr_list_update(hw, mc_addr_list, mc_addr_count,
+	hw->mac.ops.update_mc_addr_list(hw, mc_addr_list, mc_addr_count,
 				        rar_used_count, rar_count);
 }
 
@@ -1961,7 +1961,7 @@ static void e1000_set_multi(struct net_device *netdev)
 			mc_ptr = mc_ptr->next;
 		}
 
-		e1000_mc_addr_list_update(hw, mta_list, i, 1,
+		e1000_update_mc_addr_list(hw, mta_list, i, 1,
 					  mac->rar_entry_count);
 		kfree(mta_list);
 	} else {
@@ -1969,8 +1969,7 @@ static void e1000_set_multi(struct net_device *netdev)
 		 * if we're called from probe, we might not have
 		 * anything to do here, so clear out the list
 		 */
-		e1000_mc_addr_list_update(hw, NULL, 0, 1,
-					  mac->rar_entry_count);
+		e1000_update_mc_addr_list(hw, NULL, 0, 1, mac->rar_entry_count);
 	}
 }
 


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
