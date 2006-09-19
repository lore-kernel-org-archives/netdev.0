From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 05/23] e1000: rename flow control symbols
Date: Tue, 19 Sep 2006 10:28:43 -0700
Message-ID: <20060919172842.4605.41117.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:14349 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030339AbWISRTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:19:48 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Sogned-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |   14 +++---
 drivers/net/e1000/e1000_hw.c      |   84 +++++++++++++++++++------------------
 drivers/net/e1000/e1000_hw.h      |   18 ++++----
 drivers/net/e1000/e1000_param.c   |   12 +++--
 4 files changed, 63 insertions(+), 65 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 108e01a..f50faa9 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -228,11 +228,11 @@ e1000_get_pauseparam(struct net_device *
 	pause->autoneg =
 		(adapter->fc_autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE);
 
-	if (hw->fc == e1000_fc_rx_pause)
+	if (hw->fc == E1000_FC_RX_PAUSE)
 		pause->rx_pause = 1;
-	else if (hw->fc == e1000_fc_tx_pause)
+	else if (hw->fc == E1000_FC_TX_PAUSE)
 		pause->tx_pause = 1;
-	else if (hw->fc == e1000_fc_full) {
+	else if (hw->fc == E1000_FC_FULL) {
 		pause->rx_pause = 1;
 		pause->tx_pause = 1;
 	}
@@ -252,13 +252,13 @@ e1000_set_pauseparam(struct net_device *
 		msleep(1);
 
 	if (pause->rx_pause && pause->tx_pause)
-		hw->fc = e1000_fc_full;
+		hw->fc = E1000_FC_FULL;
 	else if (pause->rx_pause && !pause->tx_pause)
-		hw->fc = e1000_fc_rx_pause;
+		hw->fc = E1000_FC_RX_PAUSE;
 	else if (!pause->rx_pause && pause->tx_pause)
-		hw->fc = e1000_fc_tx_pause;
+		hw->fc = E1000_FC_TX_PAUSE;
 	else if (!pause->rx_pause && !pause->tx_pause)
-		hw->fc = e1000_fc_none;
+		hw->fc = E1000_FC_NONE;
 
 	hw->original_fc = hw->fc;
 
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 763a9e8..bfc03ff 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -1017,11 +1017,11 @@ e1000_setup_link(struct e1000_hw *hw)
      * control setting, then the variable hw->fc will
      * be initialized based on a value in the EEPROM.
      */
-    if (hw->fc == e1000_fc_default) {
+    if (hw->fc == E1000_FC_DEFAULT) {
         switch (hw->mac_type) {
         case e1000_ich8lan:
         case e1000_82573:
-            hw->fc = e1000_fc_full;
+            hw->fc = E1000_FC_FULL;
             break;
         default:
             ret_val = e1000_read_eeprom(hw, EEPROM_INIT_CONTROL2_REG,
@@ -1031,12 +1031,12 @@ e1000_setup_link(struct e1000_hw *hw)
                 return -E1000_ERR_EEPROM;
             }
             if ((eeprom_data & EEPROM_WORD0F_PAUSE_MASK) == 0)
-                hw->fc = e1000_fc_none;
+                hw->fc = E1000_FC_NONE;
             else if ((eeprom_data & EEPROM_WORD0F_PAUSE_MASK) ==
                     EEPROM_WORD0F_ASM_DIR)
-                hw->fc = e1000_fc_tx_pause;
+                hw->fc = E1000_FC_TX_PAUSE;
             else
-                hw->fc = e1000_fc_full;
+                hw->fc = E1000_FC_FULL;
             break;
         }
     }
@@ -1046,10 +1046,10 @@ e1000_setup_link(struct e1000_hw *hw)
      * hub or switch with different Flow Control capabilities.
      */
     if (hw->mac_type == e1000_82542_rev2_0)
-        hw->fc &= (~e1000_fc_tx_pause);
+        hw->fc &= (~E1000_FC_TX_PAUSE);
 
     if ((hw->mac_type < e1000_82543) && (hw->report_tx_early == 1))
-        hw->fc &= (~e1000_fc_rx_pause);
+        hw->fc &= (~E1000_FC_RX_PAUSE);
 
     hw->original_fc = hw->fc;
 
@@ -1101,7 +1101,7 @@ e1000_setup_link(struct e1000_hw *hw)
      * ability to transmit pause frames in not enabled, then these
      * registers will be set to 0.
      */
-    if (!(hw->fc & e1000_fc_tx_pause)) {
+    if (!(hw->fc & E1000_FC_TX_PAUSE)) {
         E1000_WRITE_REG(hw, FCRTL, 0);
         E1000_WRITE_REG(hw, FCRTH, 0);
     } else {
@@ -1188,11 +1188,11 @@ e1000_setup_fiber_serdes_link(struct e10
      *      3:  Both Rx and TX flow control (symmetric) are enabled.
      */
     switch (hw->fc) {
-    case e1000_fc_none:
+    case E1000_FC_NONE:
         /* Flow control is completely disabled by a software over-ride. */
         txcw = (E1000_TXCW_ANE | E1000_TXCW_FD);
         break;
-    case e1000_fc_rx_pause:
+    case E1000_FC_RX_PAUSE:
         /* RX Flow control is enabled and TX Flow control is disabled by a
          * software over-ride. Since there really isn't a way to advertise
          * that we are capable of RX Pause ONLY, we will advertise that we
@@ -1201,13 +1201,13 @@ e1000_setup_fiber_serdes_link(struct e10
          */
         txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_PAUSE_MASK);
         break;
-    case e1000_fc_tx_pause:
+    case E1000_FC_TX_PAUSE:
         /* TX Flow control is enabled, and RX Flow control is disabled, by a
          * software over-ride.
          */
         txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_ASM_DIR);
         break;
-    case e1000_fc_full:
+    case E1000_FC_FULL:
         /* Flow control (both RX and TX) is enabled by a software over-ride. */
         txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_PAUSE_MASK);
         break;
@@ -2123,13 +2123,13 @@ e1000_phy_setup_autoneg(struct e1000_hw 
      *          in the EEPROM is used.
      */
     switch (hw->fc) {
-    case e1000_fc_none: /* 0 */
+    case E1000_FC_NONE: /* 0 */
         /* Flow control (RX & TX) is completely disabled by a
          * software over-ride.
          */
         mii_autoneg_adv_reg &= ~(NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
         break;
-    case e1000_fc_rx_pause: /* 1 */
+    case E1000_FC_RX_PAUSE: /* 1 */
         /* RX Flow control is enabled, and TX Flow control is
          * disabled, by a software over-ride.
          */
@@ -2141,14 +2141,14 @@ e1000_phy_setup_autoneg(struct e1000_hw 
          */
         mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
         break;
-    case e1000_fc_tx_pause: /* 2 */
+    case E1000_FC_TX_PAUSE: /* 2 */
         /* TX Flow control is enabled, and RX Flow control is
          * disabled, by a software over-ride.
          */
         mii_autoneg_adv_reg |= NWAY_AR_ASM_DIR;
         mii_autoneg_adv_reg &= ~NWAY_AR_PAUSE;
         break;
-    case e1000_fc_full: /* 3 */
+    case E1000_FC_FULL: /* 3 */
         /* Flow control (both RX and TX) is enabled by a software
          * over-ride.
          */
@@ -2192,7 +2192,7 @@ e1000_phy_force_speed_duplex(struct e100
     DEBUGFUNC("e1000_phy_force_speed_duplex");
 
     /* Turn off Flow control if we are forcing speed and duplex. */
-    hw->fc = e1000_fc_none;
+    hw->fc = E1000_FC_NONE;
 
     DEBUGOUT1("hw->fc = %d\n", hw->fc);
 
@@ -2546,18 +2546,18 @@ e1000_force_mac_fc(struct e1000_hw *hw)
      */
 
     switch (hw->fc) {
-    case e1000_fc_none:
+    case E1000_FC_NONE:
         ctrl &= (~(E1000_CTRL_TFCE | E1000_CTRL_RFCE));
         break;
-    case e1000_fc_rx_pause:
+    case E1000_FC_RX_PAUSE:
         ctrl &= (~E1000_CTRL_TFCE);
         ctrl |= E1000_CTRL_RFCE;
         break;
-    case e1000_fc_tx_pause:
+    case E1000_FC_TX_PAUSE:
         ctrl &= (~E1000_CTRL_RFCE);
         ctrl |= E1000_CTRL_TFCE;
         break;
-    case e1000_fc_full:
+    case E1000_FC_FULL:
         ctrl |= (E1000_CTRL_TFCE | E1000_CTRL_RFCE);
         break;
     default:
@@ -2656,14 +2656,14 @@ e1000_config_fc_after_link_up(struct e10
              *   LOCAL DEVICE  |   LINK PARTNER
              * PAUSE | ASM_DIR | PAUSE | ASM_DIR | NIC Resolution
              *-------|---------|-------|---------|--------------------
-             *   0   |    0    |  DC   |   DC    | e1000_fc_none
-             *   0   |    1    |   0   |   DC    | e1000_fc_none
-             *   0   |    1    |   1   |    0    | e1000_fc_none
-             *   0   |    1    |   1   |    1    | e1000_fc_tx_pause
-             *   1   |    0    |   0   |   DC    | e1000_fc_none
-             *   1   |   DC    |   1   |   DC    | e1000_fc_full
-             *   1   |    1    |   0   |    0    | e1000_fc_none
-             *   1   |    1    |   0   |    1    | e1000_fc_rx_pause
+             *   0   |    0    |  DC   |   DC    | E1000_FC_NONE
+             *   0   |    1    |   0   |   DC    | E1000_FC_NONE
+             *   0   |    1    |   1   |    0    | E1000_FC_NONE
+             *   0   |    1    |   1   |    1    | E1000_FC_TX_PAUSE
+             *   1   |    0    |   0   |   DC    | E1000_FC_NONE
+             *   1   |   DC    |   1   |   DC    | E1000_FC_FULL
+             *   1   |    1    |   0   |    0    | E1000_FC_NONE
+             *   1   |    1    |   0   |    1    | E1000_FC_RX_PAUSE
              *
              */
             /* Are both PAUSE bits set to 1?  If so, this implies
@@ -2675,7 +2675,7 @@ e1000_config_fc_after_link_up(struct e10
              *   LOCAL DEVICE  |   LINK PARTNER
              * PAUSE | ASM_DIR | PAUSE | ASM_DIR | Result
              *-------|---------|-------|---------|--------------------
-             *   1   |   DC    |   1   |   DC    | e1000_fc_full
+             *   1   |   DC    |   1   |   DC    | E1000_FC_FULL
              *
              */
             if ((mii_nway_adv_reg & NWAY_AR_PAUSE) &&
@@ -2686,11 +2686,11 @@ e1000_config_fc_after_link_up(struct e10
                  * ONLY. Hence, we must now check to see if we need to
                  * turn OFF  the TRANSMISSION of PAUSE frames.
                  */
-                if (hw->original_fc == e1000_fc_full) {
-                    hw->fc = e1000_fc_full;
+                if (hw->original_fc == E1000_FC_FULL) {
+                    hw->fc = E1000_FC_FULL;
                     DEBUGOUT("Flow Control = FULL.\n");
                 } else {
-                    hw->fc = e1000_fc_rx_pause;
+                    hw->fc = E1000_FC_RX_PAUSE;
                     DEBUGOUT("Flow Control = RX PAUSE frames only.\n");
                 }
             }
@@ -2699,14 +2699,14 @@ e1000_config_fc_after_link_up(struct e10
              *   LOCAL DEVICE  |   LINK PARTNER
              * PAUSE | ASM_DIR | PAUSE | ASM_DIR | Result
              *-------|---------|-------|---------|--------------------
-             *   0   |    1    |   1   |    1    | e1000_fc_tx_pause
+             *   0   |    1    |   1   |    1    | E1000_FC_TX_PAUSE
              *
              */
             else if (!(mii_nway_adv_reg & NWAY_AR_PAUSE) &&
                      (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
                      (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
                      (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
-                hw->fc = e1000_fc_tx_pause;
+                hw->fc = E1000_FC_TX_PAUSE;
                 DEBUGOUT("Flow Control = TX PAUSE frames only.\n");
             }
             /* For transmitting PAUSE frames ONLY.
@@ -2714,14 +2714,14 @@ e1000_config_fc_after_link_up(struct e10
              *   LOCAL DEVICE  |   LINK PARTNER
              * PAUSE | ASM_DIR | PAUSE | ASM_DIR | Result
              *-------|---------|-------|---------|--------------------
-             *   1   |    1    |   0   |    1    | e1000_fc_rx_pause
+             *   1   |    1    |   0   |    1    | E1000_FC_RX_PAUSE
              *
              */
             else if ((mii_nway_adv_reg & NWAY_AR_PAUSE) &&
                      (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
                      !(mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
                      (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
-                hw->fc = e1000_fc_rx_pause;
+                hw->fc = E1000_FC_RX_PAUSE;
                 DEBUGOUT("Flow Control = RX PAUSE frames only.\n");
             }
             /* Per the IEEE spec, at this point flow control should be
@@ -2744,13 +2744,13 @@ e1000_config_fc_after_link_up(struct e10
              * be asked to delay transmission of packets than asking
              * our link partner to pause transmission of frames.
              */
-            else if ((hw->original_fc == e1000_fc_none ||
-                      hw->original_fc == e1000_fc_tx_pause) ||
+            else if ((hw->original_fc == E1000_FC_NONE ||
+                      hw->original_fc == E1000_FC_TX_PAUSE) ||
                       hw->fc_strict_ieee) {
-                hw->fc = e1000_fc_none;
+                hw->fc = E1000_FC_NONE;
                 DEBUGOUT("Flow Control = NONE.\n");
             } else {
-                hw->fc = e1000_fc_rx_pause;
+                hw->fc = E1000_FC_RX_PAUSE;
                 DEBUGOUT("Flow Control = RX PAUSE frames only.\n");
             }
 
@@ -2765,7 +2765,7 @@ e1000_config_fc_after_link_up(struct e10
             }
 
             if (duplex == HALF_DUPLEX)
-                hw->fc = e1000_fc_none;
+                hw->fc = E1000_FC_NONE;
 
             /* Now we call a subroutine to actually force the MAC
              * controller to use the correct flow control settings.
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 12544e1..488dcb0 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -90,15 +90,6 @@ typedef enum {
     e1000_100_full = 3
 } e1000_speed_duplex_type;
 
-/* Flow Control Settings */
-typedef enum {
-    e1000_fc_none = 0,
-    e1000_fc_rx_pause = 1,
-    e1000_fc_tx_pause = 2,
-    e1000_fc_full = 3,
-    e1000_fc_default = 0xFF
-} e1000_fc_type;
-
 struct e1000_shadow_ram {
     uint16_t    eeprom_word;
     boolean_t   modified;
@@ -1376,7 +1367,7 @@ struct e1000_hw {
     struct e1000_shadow_ram *eeprom_shadow_ram;
     uint32_t flash_bank_size;
     uint32_t flash_base_addr;
-    e1000_fc_type fc;
+    uint32_t fc;
     e1000_bus_speed bus_speed;
     e1000_bus_width bus_width;
     e1000_bus_type bus_type;
@@ -1930,6 +1921,13 @@ struct e1000_hw {
 #define E1000_FCRTL_RTL  0x0000FFF8     /* Mask Bits[15:3] for RTL */
 #define E1000_FCRTL_XONE 0x80000000     /* Enable XON frame transmission */
 
+/* Flow Control Settings */
+#define E1000_FC_NONE     0
+#define E1000_FC_RX_PAUSE 1
+#define E1000_FC_TX_PAUSE 2
+#define E1000_FC_FULL     3
+#define E1000_FC_DEFAULT  0xFF
+
 /* Header split receive */
 #define E1000_RFCTL_ISCSI_DIS           0x00000001
 #define E1000_RFCTL_ISCSI_DWC_MASK      0x0000003E
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index 85eb6bc..9c3c1ac 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -396,17 +396,17 @@ e1000_check_options(struct e1000_adapter
 	{ /* Flow Control */
 
 		struct e1000_opt_list fc_list[] =
-			{{ e1000_fc_none,    "Flow Control Disabled" },
-			 { e1000_fc_rx_pause,"Flow Control Receive Only" },
-			 { e1000_fc_tx_pause,"Flow Control Transmit Only" },
-			 { e1000_fc_full,    "Flow Control Enabled" },
-			 { e1000_fc_default, "Flow Control Hardware Default" }};
+			{{ E1000_FC_NONE,    "Flow Control Disabled" },
+			 { E1000_FC_RX_PAUSE,"Flow Control Receive Only" },
+			 { E1000_FC_TX_PAUSE,"Flow Control Transmit Only" },
+			 { E1000_FC_FULL,    "Flow Control Enabled" },
+			 { E1000_FC_DEFAULT, "Flow Control Hardware Default" }};
 
 		struct e1000_option opt = {
 			.type = list_option,
 			.name = "Flow Control",
 			.err  = "reading default settings from EEPROM",
-			.def  = e1000_fc_default,
+			.def  = E1000_FC_DEFAULT,
 			.arg  = { .l = { .nr = ARRAY_SIZE(fc_list),
 					 .p = fc_list }}
 		};



---
Auke Kok <auke-jan.h.kok@intel.com>
