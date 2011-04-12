From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH] ixgbe: Remove not used blink_led_start/stop
	code
Date: Tue, 12 Apr 2011 16:30:33 -0700
Message-ID: <4DA4E099.2080206@kernel.org>
References: <4DA4E016.1050800@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, NetDev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4DA4E016.1050800@kernel.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


There is no user for those code.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 drivers/net/ixgbe/ixgbe_82598.c  |    2 -
 drivers/net/ixgbe/ixgbe_82599.c  |    2 -
 drivers/net/ixgbe/ixgbe_common.c |   56 ---------------------------------------
 drivers/net/ixgbe/ixgbe_common.h |    2 -
 drivers/net/ixgbe/ixgbe_type.h   |    2 -
 drivers/net/ixgbe/ixgbe_x540.c   |    2 -
 6 files changed, 66 deletions(-)

Index: linux-2.6/drivers/net/ixgbe/ixgbe_82598.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgbe/ixgbe_82598.c
+++ linux-2.6/drivers/net/ixgbe/ixgbe_82598.c
@@ -1207,8 +1207,6 @@ static struct ixgbe_mac_operations mac_o
 	.get_link_capabilities	= &ixgbe_get_link_capabilities_82598,
 	.led_on			= &ixgbe_led_on_generic,
 	.led_off		= &ixgbe_led_off_generic,
-	.blink_led_start	= &ixgbe_blink_led_start_generic,
-	.blink_led_stop		= &ixgbe_blink_led_stop_generic,
 	.set_rar		= &ixgbe_set_rar_generic,
 	.clear_rar		= &ixgbe_clear_rar_generic,
 	.set_vmdq		= &ixgbe_set_vmdq_82598,
Index: linux-2.6/drivers/net/ixgbe/ixgbe_82599.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgbe/ixgbe_82599.c
+++ linux-2.6/drivers/net/ixgbe/ixgbe_82599.c
@@ -2052,8 +2052,6 @@ static struct ixgbe_mac_operations mac_o
 	.get_link_capabilities  = &ixgbe_get_link_capabilities_82599,
 	.led_on                 = &ixgbe_led_on_generic,
 	.led_off                = &ixgbe_led_off_generic,
-	.blink_led_start        = &ixgbe_blink_led_start_generic,
-	.blink_led_stop         = &ixgbe_blink_led_stop_generic,
 	.set_rar                = &ixgbe_set_rar_generic,
 	.clear_rar              = &ixgbe_clear_rar_generic,
 	.set_vmdq               = &ixgbe_set_vmdq_generic,
Index: linux-2.6/drivers/net/ixgbe/ixgbe_common.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgbe/ixgbe_common.c
+++ linux-2.6/drivers/net/ixgbe/ixgbe_common.c
@@ -2242,62 +2242,6 @@ s32 ixgbe_enable_rx_dma_generic(struct i
 }
 
 /**
- *  ixgbe_blink_led_start_generic - Blink LED based on index.
- *  @hw: pointer to hardware structure
- *  @index: led number to blink
- **/
-s32 ixgbe_blink_led_start_generic(struct ixgbe_hw *hw, u32 index)
-{
-	ixgbe_link_speed speed = 0;
-	bool link_up = 0;
-	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
-	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
-
-	/*
-	 * Link must be up to auto-blink the LEDs;
-	 * Force it if link is down.
-	 */
-	hw->mac.ops.check_link(hw, &speed, &link_up, false);
-
-	if (!link_up) {
-		autoc_reg |= IXGBE_AUTOC_AN_RESTART;
-		autoc_reg |= IXGBE_AUTOC_FLU;
-		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
-		msleep(10);
-	}
-
-	led_reg &= ~IXGBE_LED_MODE_MASK(index);
-	led_reg |= IXGBE_LED_BLINK(index);
-	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
-	IXGBE_WRITE_FLUSH(hw);
-
-	return 0;
-}
-
-/**
- *  ixgbe_blink_led_stop_generic - Stop blinking LED based on index.
- *  @hw: pointer to hardware structure
- *  @index: led number to stop blinking
- **/
-s32 ixgbe_blink_led_stop_generic(struct ixgbe_hw *hw, u32 index)
-{
-	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
-	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
-
-	autoc_reg &= ~IXGBE_AUTOC_FLU;
-	autoc_reg |= IXGBE_AUTOC_AN_RESTART;
-	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
-
-	led_reg &= ~IXGBE_LED_MODE_MASK(index);
-	led_reg &= ~IXGBE_LED_BLINK(index);
-	led_reg |= IXGBE_LED_LINK_ACTIVE << IXGBE_LED_MODE_SHIFT(index);
-	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
-	IXGBE_WRITE_FLUSH(hw);
-
-	return 0;
-}
-
-/**
  *  ixgbe_get_san_mac_addr_offset - Get SAN MAC address offset from the EEPROM
  *  @hw: pointer to hardware structure
  *  @san_mac_offset: SAN MAC address offset
Index: linux-2.6/drivers/net/ixgbe/ixgbe_common.h
===================================================================
--- linux-2.6.orig/drivers/net/ixgbe/ixgbe_common.h
+++ linux-2.6/drivers/net/ixgbe/ixgbe_common.h
@@ -85,8 +85,6 @@ s32 ixgbe_check_mac_link_generic(struct
                                  bool *link_up, bool link_up_wait_to_complete);
 s32 ixgbe_get_wwn_prefix_generic(struct ixgbe_hw *hw, u16 *wwnn_prefix,
                                  u16 *wwpn_prefix);
-s32 ixgbe_blink_led_start_generic(struct ixgbe_hw *hw, u32 index);
-s32 ixgbe_blink_led_stop_generic(struct ixgbe_hw *hw, u32 index);
 void ixgbe_set_mac_anti_spoofing(struct ixgbe_hw *hw, bool enable, int pf);
 void ixgbe_set_vlan_anti_spoofing(struct ixgbe_hw *hw, bool enable, int vf);
 
Index: linux-2.6/drivers/net/ixgbe/ixgbe_type.h
===================================================================
--- linux-2.6.orig/drivers/net/ixgbe/ixgbe_type.h
+++ linux-2.6/drivers/net/ixgbe/ixgbe_type.h
@@ -2530,8 +2530,6 @@ struct ixgbe_mac_operations {
 	/* LED */
 	s32 (*led_on)(struct ixgbe_hw *, u32);
 	s32 (*led_off)(struct ixgbe_hw *, u32);
-	s32 (*blink_led_start)(struct ixgbe_hw *, u32);
-	s32 (*blink_led_stop)(struct ixgbe_hw *, u32);
 
 	/* RAR, Multicast, VLAN */
 	s32 (*set_rar)(struct ixgbe_hw *, u32, u8 *, u32, u32);
Index: linux-2.6/drivers/net/ixgbe/ixgbe_x540.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgbe/ixgbe_x540.c
+++ linux-2.6/drivers/net/ixgbe/ixgbe_x540.c
@@ -681,8 +681,6 @@ static struct ixgbe_mac_operations mac_o
 	.get_link_capabilities  = &ixgbe_get_copper_link_capabilities_generic,
 	.led_on                 = &ixgbe_led_on_generic,
 	.led_off                = &ixgbe_led_off_generic,
-	.blink_led_start        = &ixgbe_blink_led_start_generic,
-	.blink_led_stop         = &ixgbe_blink_led_stop_generic,
 	.set_rar                = &ixgbe_set_rar_generic,
 	.clear_rar              = &ixgbe_clear_rar_generic,
 	.set_vmdq               = &ixgbe_set_vmdq_generic,

------------------------------------------------------------------------------
Forrester Wave Report - Recovery time is now measured in hours and minutes
not days. Key insights are discussed in the 2010 Forrester Wave Report as
part of an in-depth evaluation of disaster recovery service providers.
Forrester found the best-in-class provider in terms of services and vision.
Read this report now!  http://p.sf.net/sfu/ibm-webcastpromo
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
