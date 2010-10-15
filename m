From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] pch_gbe: make local functions static
Date: Fri, 15 Oct 2010 14:09:14 -0700
Message-ID: <20101015140914.01d8ef08@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55429 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932441Ab0JOVJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 17:09:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make routines that are only used in one file static.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/pch_gbe/pch_gbe.h      |    4 +---
 drivers/net/pch_gbe/pch_gbe_api.c  |    2 +-
 drivers/net/pch_gbe/pch_gbe_main.c |   26 +++++++++++++++-----------
 3 files changed, 17 insertions(+), 15 deletions(-)

--- a/drivers/net/pch_gbe/pch_gbe.h	2010-10-15 13:56:27.823153599 -0700
+++ b/drivers/net/pch_gbe/pch_gbe.h	2010-10-15 13:56:34.519359889 -0700
@@ -644,9 +644,7 @@ extern void pch_gbe_free_tx_resources(st
 extern void pch_gbe_free_rx_resources(struct pch_gbe_adapter *adapter,
 				       struct pch_gbe_rx_ring *rx_ring);
 extern void pch_gbe_update_stats(struct pch_gbe_adapter *adapter);
-extern int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg);
-extern void pch_gbe_mdio_write(struct net_device *netdev, int addr, int reg,
-				int data);
+
 /* pch_gbe_param.c */
 extern void pch_gbe_check_options(struct pch_gbe_adapter *adapter);
 
--- a/drivers/net/pch_gbe/pch_gbe_api.c	2010-10-15 13:54:46.088037739 -0700
+++ b/drivers/net/pch_gbe/pch_gbe_api.c	2010-10-15 13:54:57.484377021 -0700
@@ -97,7 +97,7 @@ static const struct pch_gbe_functions pc
  * pch_gbe_plat_init_function_pointers - Init func ptrs
  * @hw:	Pointer to the HW structure
  */
-void pch_gbe_plat_init_function_pointers(struct pch_gbe_hw *hw)
+static void pch_gbe_plat_init_function_pointers(struct pch_gbe_hw *hw)
 {
 	/* Set PHY parameter */
 	hw->phy.reset_delay_us     = PCH_GBE_PHY_RESET_DELAY_US;
--- a/drivers/net/pch_gbe/pch_gbe_main.c	2010-10-15 13:54:03.014763090 -0700
+++ b/drivers/net/pch_gbe/pch_gbe_main.c	2010-10-15 13:57:16.992669897 -0700
@@ -85,6 +85,9 @@ const char pch_driver_version[] = DRV_VE
 
 static unsigned int copybreak __read_mostly = PCH_GBE_COPYBREAK_DEFAULT;
 
+static int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg);
+static void pch_gbe_mdio_write(struct net_device *netdev, int addr, int reg,
+			       int data);
 /**
  * pch_gbe_mac_read_mac_addr - Read MAC address
  * @hw:	            Pointer to the HW structure
@@ -114,7 +117,7 @@ s32 pch_gbe_mac_read_mac_addr(struct pch
  * @reg:	Pointer of register
  * @busy:	Busy bit
  */
-void pch_gbe_wait_clr_bit(void *reg, u32 bit)
+static void pch_gbe_wait_clr_bit(void *reg, u32 bit)
 {
 	u32 tmp;
 	/* wait busy */
@@ -130,7 +133,7 @@ void pch_gbe_wait_clr_bit(void *reg, u32
  * @addr:   Pointer to the MAC address
  * @index:  MAC address array register
  */
-void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
+static void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
 {
 	u32 mar_low, mar_high, adrmask;
 
@@ -161,7 +164,7 @@ void pch_gbe_mac_mar_set(struct pch_gbe_
  * pch_gbe_mac_reset_hw - Reset hardware
  * @hw:	Pointer to the HW structure
  */
-void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
+static void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
 {
 	/* Read the MAC address. and store to the private data */
 	pch_gbe_mac_read_mac_addr(hw);
@@ -180,7 +183,7 @@ void pch_gbe_mac_reset_hw(struct pch_gbe
  * @hw:	Pointer to the HW structure
  * @mar_count: Receive address registers
  */
-void pch_gbe_mac_init_rx_addrs(struct pch_gbe_hw *hw, u16 mar_count)
+static void pch_gbe_mac_init_rx_addrs(struct pch_gbe_hw *hw, u16 mar_count)
 {
 	u32 i;
 
@@ -206,9 +209,9 @@ void pch_gbe_mac_init_rx_addrs(struct pc
  * @mar_used_count: The first MAC Address register free to program
  * @mar_total_num:  Total number of supported MAC Address Registers
  */
-void pch_gbe_mac_mc_addr_list_update(struct pch_gbe_hw *hw,
-				     u8 *mc_addr_list, u32 mc_addr_count,
-				     u32 mar_used_count, u32 mar_total_num)
+static void pch_gbe_mac_mc_addr_list_update(struct pch_gbe_hw *hw,
+					    u8 *mc_addr_list, u32 mc_addr_count,
+					    u32 mar_used_count, u32 mar_total_num)
 {
 	u32 i, adrmask;
 
@@ -285,7 +288,7 @@ s32 pch_gbe_mac_force_mac_fc(struct pch_
  * @hw:     Pointer to the HW structure
  * @wu_evt: Wake up event
  */
-void pch_gbe_mac_set_wol_event(struct pch_gbe_hw *hw, u32 wu_evt)
+static void pch_gbe_mac_set_wol_event(struct pch_gbe_hw *hw, u32 wu_evt)
 {
 	u32 addr_mask;
 
@@ -359,7 +362,7 @@ u16 pch_gbe_mac_ctrl_miim(struct pch_gbe
  * pch_gbe_mac_set_pause_packet - Set pause packet
  * @hw:   Pointer to the HW structure
  */
-void pch_gbe_mac_set_pause_packet(struct pch_gbe_hw *hw)
+static void pch_gbe_mac_set_pause_packet(struct pch_gbe_hw *hw)
 {
 	unsigned long tmp2, tmp3;
 
@@ -482,7 +485,7 @@ static int pch_gbe_init_phy(struct pch_g
  *	0:	Successfully
  *	Negative value:	Failed
  */
-int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg)
+static int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg)
 {
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
 	struct pch_gbe_hw *hw = &adapter->hw;
@@ -498,7 +501,8 @@ int pch_gbe_mdio_read(struct net_device
  * @reg:    Access location
  * @data:   Write data
  */
-void pch_gbe_mdio_write(struct net_device *netdev, int addr, int reg, int data)
+static void pch_gbe_mdio_write(struct net_device *netdev,
+			       int addr, int reg, int data)
 {
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
 	struct pch_gbe_hw *hw = &adapter->hw;
