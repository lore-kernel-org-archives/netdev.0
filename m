From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 17/19] e1000: convert entire driver to new register naming
Date: Thu, 29 Mar 2007 09:40:33 -0700
Message-ID: <20070329164033.6595.67234.stgit@localhost.localdomain>
References: <20070329163304.6595.81963.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: auke-jan.h.kok@intel.com, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	cramerj@intel.com, john.ronciak@intel.com,
	arjan.van.de.ven@intel.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46025 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030404AbXC2QlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 12:41:06 -0400
In-Reply-To: <20070329163304.6595.81963.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeb Cramer <cramerj@intel.com>

Change all code to use E1000_REG_NAME type naming everywhere, including
macro changes that pass these along. Change PHY_CTRL to PHY_CONTROL. Change
e1000_10/100_* to ADVERTISE_*. Change E1000_MNG_DHCP_COOKIE_STATUS_VLAN_
SUPPORT to remove _SUPPORT.

Signed-off-by: Jeb Cramer <cramerj@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |  226 +++++++++---------
 drivers/net/e1000/e1000_main.c    |  477 ++++++++++++++++++-------------------
 drivers/net/e1000/e1000_osdep.h   |   52 ++--
 drivers/net/e1000/e1000_param.c   |   20 +-
 4 files changed, 380 insertions(+), 395 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 089de8e..ef7166b 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -166,7 +166,7 @@ e1000_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 			ecmd->transceiver = XCVR_EXTERNAL;
 	}
 
-	if (E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_LU) {
+	if (E1000_READ_REG(&adapter->hw, E1000_STATUS) & E1000_STATUS_LU) {
 
 		e1000_get_speed_and_duplex(hw, &adapter->link_speed,
 		                                   &adapter->link_duplex);
@@ -245,11 +245,11 @@ e1000_get_pauseparam(struct net_device *netdev,
 	pause->autoneg =
 		(adapter->fc_autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE);
 
-	if (hw->fc == E1000_FC_RX_PAUSE)
+	if (hw->fc == e1000_fc_rx_pause)
 		pause->rx_pause = 1;
-	else if (hw->fc == E1000_FC_TX_PAUSE)
+	else if (hw->fc == e1000_fc_tx_pause)
 		pause->tx_pause = 1;
-	else if (hw->fc == E1000_FC_FULL) {
+	else if (hw->fc == e1000_fc_full) {
 		pause->rx_pause = 1;
 		pause->tx_pause = 1;
 	}
@@ -269,13 +269,13 @@ e1000_set_pauseparam(struct net_device *netdev,
 		msleep(1);
 
 	if (pause->rx_pause && pause->tx_pause)
-		hw->fc = E1000_FC_FULL;
+		hw->fc = e1000_fc_full;
 	else if (pause->rx_pause && !pause->tx_pause)
-		hw->fc = E1000_FC_RX_PAUSE;
+		hw->fc = e1000_fc_rx_pause;
 	else if (!pause->rx_pause && pause->tx_pause)
-		hw->fc = E1000_FC_TX_PAUSE;
+		hw->fc = e1000_fc_tx_pause;
 	else if (!pause->rx_pause && !pause->tx_pause)
-		hw->fc = E1000_FC_NONE;
+		hw->fc = e1000_fc_none;
 
 	hw->original_fc = hw->fc;
 
@@ -395,20 +395,20 @@ e1000_get_regs(struct net_device *netdev,
 
 	regs->version = (1 << 24) | (hw->revision_id << 16) | hw->device_id;
 
-	regs_buff[0]  = E1000_READ_REG(hw, CTRL);
-	regs_buff[1]  = E1000_READ_REG(hw, STATUS);
+	regs_buff[0]  = E1000_READ_REG(hw, E1000_CTRL);
+	regs_buff[1]  = E1000_READ_REG(hw, E1000_STATUS);
 
-	regs_buff[2]  = E1000_READ_REG(hw, RCTL);
-	regs_buff[3]  = E1000_READ_REG(hw, RDLEN);
-	regs_buff[4]  = E1000_READ_REG(hw, RDH);
-	regs_buff[5]  = E1000_READ_REG(hw, RDT);
-	regs_buff[6]  = E1000_READ_REG(hw, RDTR);
+	regs_buff[2]  = E1000_READ_REG(hw, E1000_RCTL);
+	regs_buff[3]  = E1000_READ_REG(hw, E1000_RDLEN);
+	regs_buff[4]  = E1000_READ_REG(hw, E1000_RDH);
+	regs_buff[5]  = E1000_READ_REG(hw, E1000_RDT);
+	regs_buff[6]  = E1000_READ_REG(hw, E1000_RDTR);
 
-	regs_buff[7]  = E1000_READ_REG(hw, TCTL);
-	regs_buff[8]  = E1000_READ_REG(hw, TDLEN);
-	regs_buff[9]  = E1000_READ_REG(hw, TDH);
-	regs_buff[10] = E1000_READ_REG(hw, TDT);
-	regs_buff[11] = E1000_READ_REG(hw, TIDV);
+	regs_buff[7]  = E1000_READ_REG(hw, E1000_TCTL);
+	regs_buff[8]  = E1000_READ_REG(hw, E1000_TDLEN);
+	regs_buff[9]  = E1000_READ_REG(hw, E1000_TDH);
+	regs_buff[10] = E1000_READ_REG(hw, E1000_TDT);
+	regs_buff[11] = E1000_READ_REG(hw, E1000_TIDV);
 
 	regs_buff[12] = adapter->hw.phy_type;  /* PHY type (IGP=1, M88=0) */
 	if (hw->phy_type == e1000_phy_igp) {
@@ -468,7 +468,7 @@ e1000_get_regs(struct net_device *netdev,
 	if (hw->mac_type >= e1000_82540 &&
 	    hw->mac_type < e1000_82571 &&
 	    hw->media_type == e1000_media_type_copper) {
-		regs_buff[26] = E1000_READ_REG(hw, MANC);
+		regs_buff[26] = E1000_READ_REG(hw, E1000_MANC);
 	}
 }
 
@@ -745,9 +745,8 @@ err_setup:
 		if (value != (test[pat] & W & M)) {                             \
 			DPRINTK(DRV, ERR, "pattern test reg %04X failed: got " \
 			        "0x%08X expected 0x%08X\n",                    \
-			        E1000_##R, value, (test[pat] & W & M));        \
-			*data = (adapter->hw.mac_type < e1000_82543) ?         \
-				E1000_82542_##R : E1000_##R;                   \
+			        R, value, (test[pat] & W & M));        \
+			*data = E1000_REGISTER(&adapter->hw, R);               \
 			return 1;                                              \
 		}                                                              \
 	}                                                                      \
@@ -760,9 +759,8 @@ err_setup:
 	value = E1000_READ_REG(&adapter->hw, R);                               \
 	if ((W & M) != (value & M)) {                                          \
 		DPRINTK(DRV, ERR, "set/check reg %04X test failed: got 0x%08X "\
-		        "expected 0x%08X\n", E1000_##R, (value & M), (W & M)); \
-		*data = (adapter->hw.mac_type < e1000_82543) ?                 \
-			E1000_82542_##R : E1000_##R;                           \
+		        "expected 0x%08X\n", R, (value & M), (W & M)); \
+		*data = E1000_REGISTER(&adapter->hw, R);                       \
 		return 1;                                                      \
 	}                                                                      \
 }
@@ -792,10 +790,10 @@ e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 		break;
 	}
 
-	before = E1000_READ_REG(&adapter->hw, STATUS);
-	value = (E1000_READ_REG(&adapter->hw, STATUS) & toggle);
-	E1000_WRITE_REG(&adapter->hw, STATUS, toggle);
-	after = E1000_READ_REG(&adapter->hw, STATUS) & toggle;
+	before = E1000_READ_REG(&adapter->hw, E1000_STATUS);
+	value = (E1000_READ_REG(&adapter->hw, E1000_STATUS) & toggle);
+	E1000_WRITE_REG(&adapter->hw, E1000_STATUS, toggle);
+	after = E1000_READ_REG(&adapter->hw, E1000_STATUS) & toggle;
 	if (value != after) {
 		DPRINTK(DRV, ERR, "failed STATUS register test got: "
 		        "0x%08X expected: 0x%08X\n", after, value);
@@ -803,61 +801,61 @@ e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 		return 1;
 	}
 	/* restore previous status */
-	E1000_WRITE_REG(&adapter->hw, STATUS, before);
+	E1000_WRITE_REG(&adapter->hw, E1000_STATUS, before);
 
 	if (adapter->hw.mac_type != e1000_ich8lan) {
-		REG_PATTERN_TEST(FCAL, 0xFFFFFFFF, 0xFFFFFFFF);
-		REG_PATTERN_TEST(FCAH, 0x0000FFFF, 0xFFFFFFFF);
-		REG_PATTERN_TEST(FCT, 0x0000FFFF, 0xFFFFFFFF);
-		REG_PATTERN_TEST(VET, 0x0000FFFF, 0xFFFFFFFF);
+		REG_PATTERN_TEST(E1000_FCAL, 0xFFFFFFFF, 0xFFFFFFFF);
+		REG_PATTERN_TEST(E1000_FCAH, 0x0000FFFF, 0xFFFFFFFF);
+		REG_PATTERN_TEST(E1000_FCT, 0x0000FFFF, 0xFFFFFFFF);
+		REG_PATTERN_TEST(E1000_VET, 0x0000FFFF, 0xFFFFFFFF);
 	}
 
-	REG_PATTERN_TEST(RDTR, 0x0000FFFF, 0xFFFFFFFF);
-	REG_PATTERN_TEST(RDBAH, 0xFFFFFFFF, 0xFFFFFFFF);
-	REG_PATTERN_TEST(RDLEN, 0x000FFF80, 0x000FFFFF);
-	REG_PATTERN_TEST(RDH, 0x0000FFFF, 0x0000FFFF);
-	REG_PATTERN_TEST(RDT, 0x0000FFFF, 0x0000FFFF);
-	REG_PATTERN_TEST(FCRTH, 0x0000FFF8, 0x0000FFF8);
-	REG_PATTERN_TEST(FCTTV, 0x0000FFFF, 0x0000FFFF);
-	REG_PATTERN_TEST(TIPG, 0x3FFFFFFF, 0x3FFFFFFF);
-	REG_PATTERN_TEST(TDBAH, 0xFFFFFFFF, 0xFFFFFFFF);
-	REG_PATTERN_TEST(TDLEN, 0x000FFF80, 0x000FFFFF);
+	REG_PATTERN_TEST(E1000_RDTR, 0x0000FFFF, 0xFFFFFFFF);
+	REG_PATTERN_TEST(E1000_RDBAH, 0xFFFFFFFF, 0xFFFFFFFF);
+	REG_PATTERN_TEST(E1000_RDLEN, 0x000FFF80, 0x000FFFFF);
+	REG_PATTERN_TEST(E1000_RDH, 0x0000FFFF, 0x0000FFFF);
+	REG_PATTERN_TEST(E1000_RDT, 0x0000FFFF, 0x0000FFFF);
+	REG_PATTERN_TEST(E1000_FCRTH, 0x0000FFF8, 0x0000FFF8);
+	REG_PATTERN_TEST(E1000_FCTTV, 0x0000FFFF, 0x0000FFFF);
+	REG_PATTERN_TEST(E1000_TIPG, 0x3FFFFFFF, 0x3FFFFFFF);
+	REG_PATTERN_TEST(E1000_TDBAH, 0xFFFFFFFF, 0xFFFFFFFF);
+	REG_PATTERN_TEST(E1000_TDLEN, 0x000FFF80, 0x000FFFFF);
 
-	REG_SET_AND_CHECK(RCTL, 0xFFFFFFFF, 0x00000000);
+	REG_SET_AND_CHECK(E1000_RCTL, 0xFFFFFFFF, 0x00000000);
 
 	before = (adapter->hw.mac_type == e1000_ich8lan ?
 	          0x06C3B33E : 0x06DFB3FE);
-	REG_SET_AND_CHECK(RCTL, before, 0x003FFFFB);
-	REG_SET_AND_CHECK(TCTL, 0xFFFFFFFF, 0x00000000);
+	REG_SET_AND_CHECK(E1000_RCTL, before, 0x003FFFFB);
+	REG_SET_AND_CHECK(E1000_TCTL, 0xFFFFFFFF, 0x00000000);
 
 	if (adapter->hw.mac_type >= e1000_82543) {
 
-		REG_SET_AND_CHECK(RCTL, before, 0xFFFFFFFF);
-		REG_PATTERN_TEST(RDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
+		REG_SET_AND_CHECK(E1000_RCTL, before, 0xFFFFFFFF);
+		REG_PATTERN_TEST(E1000_RDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
 		if (adapter->hw.mac_type != e1000_ich8lan)
-			REG_PATTERN_TEST(TXCW, 0xC000FFFF, 0x0000FFFF);
-		REG_PATTERN_TEST(TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
-		REG_PATTERN_TEST(TIDV, 0x0000FFFF, 0x0000FFFF);
+			REG_PATTERN_TEST(E1000_TXCW, 0xC000FFFF, 0x0000FFFF);
+		REG_PATTERN_TEST(E1000_TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
+		REG_PATTERN_TEST(E1000_TIDV, 0x0000FFFF, 0x0000FFFF);
 		value = (adapter->hw.mac_type == e1000_ich8lan ?
 		         E1000_RAR_ENTRIES_ICH8LAN : E1000_RAR_ENTRIES);
 		for (i = 0; i < value; i++) {
-			REG_PATTERN_TEST(RA + (((i << 1) + 1) << 2), 0x8003FFFF,
+			REG_PATTERN_TEST(E1000_RA + (((i << 1) + 1) << 2), 0x8003FFFF,
 			                 0xFFFFFFFF);
 		}
 
 	} else {
 
-		REG_SET_AND_CHECK(RCTL, 0xFFFFFFFF, 0x01FFFFFF);
-		REG_PATTERN_TEST(RDBAL, 0xFFFFF000, 0xFFFFFFFF);
-		REG_PATTERN_TEST(TXCW, 0x0000FFFF, 0x0000FFFF);
-		REG_PATTERN_TEST(TDBAL, 0xFFFFF000, 0xFFFFFFFF);
+		REG_SET_AND_CHECK(E1000_RCTL, 0xFFFFFFFF, 0x01FFFFFF);
+		REG_PATTERN_TEST(E1000_RDBAL, 0xFFFFF000, 0xFFFFFFFF);
+		REG_PATTERN_TEST(E1000_TXCW, 0x0000FFFF, 0x0000FFFF);
+		REG_PATTERN_TEST(E1000_TDBAL, 0xFFFFF000, 0xFFFFFFFF);
 
 	}
 
 	value = (adapter->hw.mac_type == e1000_ich8lan ?
 			E1000_MC_TBL_SIZE_ICH8LAN : E1000_MC_TBL_SIZE);
 	for (i = 0; i < value; i++)
-		REG_PATTERN_TEST(MTA + (i << 2), 0xFFFFFFFF, 0xFFFFFFFF);
+		REG_PATTERN_TEST(E1000_MTA + (i << 2), 0xFFFFFFFF, 0xFFFFFFFF);
 
 	*data = 0;
 	return 0;
@@ -893,7 +891,7 @@ e1000_test_intr(int irq, void *data)
 	struct net_device *netdev = (struct net_device *) data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	adapter->test_icr |= E1000_READ_REG(&adapter->hw, ICR);
+	adapter->test_icr |= E1000_READ_REG(&adapter->hw, E1000_ICR);
 
 	return IRQ_HANDLED;
 }
@@ -921,7 +919,7 @@ e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 	        (shared_int ? "shared" : "unshared"));
 
 	/* Disable all the interrupts */
-	E1000_WRITE_REG(&adapter->hw, IMC, 0xFFFFFFFF);
+	E1000_WRITE_REG(&adapter->hw, E1000_IMC, 0xFFFFFFFF);
 	msleep(10);
 
 	/* Test each interrupt */
@@ -941,8 +939,8 @@ e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 			 * test failed.
 			 */
 			adapter->test_icr = 0;
-			E1000_WRITE_REG(&adapter->hw, IMC, mask);
-			E1000_WRITE_REG(&adapter->hw, ICS, mask);
+			E1000_WRITE_REG(&adapter->hw, E1000_IMC, mask);
+			E1000_WRITE_REG(&adapter->hw, E1000_ICS, mask);
 			msleep(10);
 
 			if (adapter->test_icr & mask) {
@@ -958,8 +956,8 @@ e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 		 * test failed.
 		 */
 		adapter->test_icr = 0;
-		E1000_WRITE_REG(&adapter->hw, IMS, mask);
-		E1000_WRITE_REG(&adapter->hw, ICS, mask);
+		E1000_WRITE_REG(&adapter->hw, E1000_IMS, mask);
+		E1000_WRITE_REG(&adapter->hw, E1000_ICS, mask);
 		msleep(10);
 
 		if (!(adapter->test_icr & mask)) {
@@ -975,8 +973,8 @@ e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 			 * test failed.
 			 */
 			adapter->test_icr = 0;
-			E1000_WRITE_REG(&adapter->hw, IMC, ~mask & 0x00007FFF);
-			E1000_WRITE_REG(&adapter->hw, ICS, ~mask & 0x00007FFF);
+			E1000_WRITE_REG(&adapter->hw, E1000_IMC, ~mask & 0x00007FFF);
+			E1000_WRITE_REG(&adapter->hw, E1000_ICS, ~mask & 0x00007FFF);
 			msleep(10);
 
 			if (adapter->test_icr) {
@@ -987,7 +985,7 @@ e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 	}
 
 	/* Disable all the interrupts */
-	E1000_WRITE_REG(&adapter->hw, IMC, 0xFFFFFFFF);
+	E1000_WRITE_REG(&adapter->hw, E1000_IMC, 0xFFFFFFFF);
 	msleep(10);
 
 	/* Unhook test interrupt handler */
@@ -1074,17 +1072,17 @@ e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	memset(txdr->desc, 0, txdr->size);
 	txdr->next_to_use = txdr->next_to_clean = 0;
 
-	E1000_WRITE_REG(&adapter->hw, TDBAL,
+	E1000_WRITE_REG(&adapter->hw, E1000_TDBAL,
 			((uint64_t) txdr->dma & 0x00000000FFFFFFFF));
-	E1000_WRITE_REG(&adapter->hw, TDBAH, ((uint64_t) txdr->dma >> 32));
-	E1000_WRITE_REG(&adapter->hw, TDLEN,
+	E1000_WRITE_REG(&adapter->hw, E1000_TDBAH, ((uint64_t) txdr->dma >> 32));
+	E1000_WRITE_REG(&adapter->hw, E1000_TDLEN,
 			txdr->count * sizeof(struct e1000_tx_desc));
-	E1000_WRITE_REG(&adapter->hw, TDH, 0);
-	E1000_WRITE_REG(&adapter->hw, TDT, 0);
-	E1000_WRITE_REG(&adapter->hw, TCTL,
+	E1000_WRITE_REG(&adapter->hw, E1000_TDH, 0);
+	E1000_WRITE_REG(&adapter->hw, E1000_TDT, 0);
+	E1000_WRITE_REG(&adapter->hw, E1000_TCTL,
 			E1000_TCTL_PSP | E1000_TCTL_EN |
 			E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT |
-			E1000_FDX_COLLISION_DISTANCE << E1000_COLD_SHIFT);
+			E1000_COLLISION_DISTANCE << E1000_COLD_SHIFT);
 
 	for (i = 0; i < txdr->count; i++) {
 		struct e1000_tx_desc *tx_desc = E1000_TX_DESC(*txdr, i);
@@ -1129,18 +1127,18 @@ e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	memset(rxdr->desc, 0, rxdr->size);
 	rxdr->next_to_use = rxdr->next_to_clean = 0;
 
-	rctl = E1000_READ_REG(&adapter->hw, RCTL);
-	E1000_WRITE_REG(&adapter->hw, RCTL, rctl & ~E1000_RCTL_EN);
-	E1000_WRITE_REG(&adapter->hw, RDBAL,
+	rctl = E1000_READ_REG(&adapter->hw, E1000_RCTL);
+	E1000_WRITE_REG(&adapter->hw, E1000_RCTL, rctl & ~E1000_RCTL_EN);
+	E1000_WRITE_REG(&adapter->hw, E1000_RDBAL,
 			((uint64_t) rxdr->dma & 0xFFFFFFFF));
-	E1000_WRITE_REG(&adapter->hw, RDBAH, ((uint64_t) rxdr->dma >> 32));
-	E1000_WRITE_REG(&adapter->hw, RDLEN, rxdr->size);
-	E1000_WRITE_REG(&adapter->hw, RDH, 0);
-	E1000_WRITE_REG(&adapter->hw, RDT, 0);
+	E1000_WRITE_REG(&adapter->hw, E1000_RDBAH, ((uint64_t) rxdr->dma >> 32));
+	E1000_WRITE_REG(&adapter->hw, E1000_RDLEN, rxdr->size);
+	E1000_WRITE_REG(&adapter->hw, E1000_RDH, 0);
+	E1000_WRITE_REG(&adapter->hw, E1000_RDT, 0);
 	rctl = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_SZ_2048 |
 		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
 		(adapter->hw.mc_filter_type << E1000_RCTL_MO_SHIFT);
-	E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+	E1000_WRITE_REG(&adapter->hw, E1000_RCTL, rctl);
 
 	for (i = 0; i < rxdr->count; i++) {
 		struct e1000_rx_desc *rx_desc = E1000_RX_DESC(*rxdr, i);
@@ -1210,14 +1208,14 @@ e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 
 	/* Setup the Device Control Register for PHY loopback test. */
 
-	ctrl_reg = E1000_READ_REG(&adapter->hw, CTRL);
+	ctrl_reg = E1000_READ_REG(&adapter->hw, E1000_CTRL);
 	ctrl_reg |= (E1000_CTRL_ILOS |		/* Invert Loss-Of-Signal */
 		     E1000_CTRL_FRCSPD |	/* Set the Force Speed Bit */
 		     E1000_CTRL_FRCDPX |	/* Set the Force Duplex Bit */
 		     E1000_CTRL_SPD_1000 |	/* Force Speed to 1000 */
 		     E1000_CTRL_FD);		/* Force Duplex to FULL */
 
-	E1000_WRITE_REG(&adapter->hw, CTRL, ctrl_reg);
+	E1000_WRITE_REG(&adapter->hw, E1000_CTRL, ctrl_reg);
 
 	/* Read the PHY Specific Control Register (0x10) */
 	e1000_read_phy_reg(&adapter->hw, M88E1000_PHY_SPEC_CTRL, &phy_reg);
@@ -1234,7 +1232,7 @@ e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 	/* Have to setup TX_CLK and TX_CRS after software reset */
 	e1000_phy_reset_clk_and_crs(adapter);
 
-	e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x8100);
+	e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, 0x8100);
 
 	/* Wait for reset to complete. */
 	udelay(500);
@@ -1246,15 +1244,15 @@ e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 	e1000_phy_disable_receiver(adapter);
 
 	/* Set the loopback bit in the PHY control register. */
-	e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &phy_reg);
+	e1000_read_phy_reg(&adapter->hw, PHY_CONTROL, &phy_reg);
 	phy_reg |= MII_CR_LOOPBACK;
-	e1000_write_phy_reg(&adapter->hw, PHY_CTRL, phy_reg);
+	e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, phy_reg);
 
 	/* Setup TX_CLK and TX_CRS one more time. */
 	e1000_phy_reset_clk_and_crs(adapter);
 
 	/* Check Phy Configuration */
-	e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &phy_reg);
+	e1000_read_phy_reg(&adapter->hw, PHY_CONTROL, &phy_reg);
 	if (phy_reg != 0x4100)
 		 return 9;
 
@@ -1282,19 +1280,19 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 		e1000_write_phy_reg(&adapter->hw,
 				    M88E1000_PHY_SPEC_CTRL, 0x0808);
 		/* reset to update Auto-MDI/MDIX */
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x9140);
+		e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, 0x9140);
 		/* autoneg off */
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x8140);
+		e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, 0x8140);
 	} else if (adapter->hw.phy_type == e1000_phy_gg82563)
 		e1000_write_phy_reg(&adapter->hw,
 		                    GG82563_PHY_KMRN_MODE_CTRL,
 		                    0x1CC);
 
-	ctrl_reg = E1000_READ_REG(&adapter->hw, CTRL);
+	ctrl_reg = E1000_READ_REG(&adapter->hw, E1000_CTRL);
 
 	if (adapter->hw.phy_type == e1000_phy_ife) {
 		/* force 100, set loopback */
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x6100);
+		e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, 0x6100);
 
 		/* Now set up the MAC to the same speed/duplex as the PHY. */
 		ctrl_reg &= ~E1000_CTRL_SPD_SEL; /* Clear the speed sel bits */
@@ -1304,10 +1302,10 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
 	} else {
 		/* force 1000, set loopback */
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x4140);
+		e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, 0x4140);
 
 		/* Now set up the MAC to the same speed/duplex as the PHY. */
-		ctrl_reg = E1000_READ_REG(&adapter->hw, CTRL);
+		ctrl_reg = E1000_READ_REG(&adapter->hw, E1000_CTRL);
 		ctrl_reg &= ~E1000_CTRL_SPD_SEL; /* Clear the speed sel bits */
 		ctrl_reg |= (E1000_CTRL_FRCSPD | /* Set the Force Speed Bit */
 			     E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
@@ -1321,12 +1319,12 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	else {
 		/* Set the ILOS bit on the fiber Nic is half
 		 * duplex link is detected. */
-		stat_reg = E1000_READ_REG(&adapter->hw, STATUS);
+		stat_reg = E1000_READ_REG(&adapter->hw, E1000_STATUS);
 		if ((stat_reg & E1000_STATUS_FD) == 0)
 			ctrl_reg |= (E1000_CTRL_ILOS | E1000_CTRL_SLU);
 	}
 
-	E1000_WRITE_REG(&adapter->hw, CTRL, ctrl_reg);
+	E1000_WRITE_REG(&adapter->hw, E1000_CTRL, ctrl_reg);
 
 	/* Disable the receiver on the PHY so when a cable is plugged in, the
 	 * PHY does not begin to autoneg when a cable is reconnected to the NIC.
@@ -1381,9 +1379,9 @@ e1000_set_phy_loopback(struct e1000_adapter *adapter)
 		/* Default PHY loopback work is to read the MII
 		 * control register and assert bit 14 (loopback mode).
 		 */
-		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &phy_reg);
+		e1000_read_phy_reg(&adapter->hw, PHY_CONTROL, &phy_reg);
 		phy_reg |= MII_CR_LOOPBACK;
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, phy_reg);
+		e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, phy_reg);
 		return 0;
 		break;
 	}
@@ -1410,14 +1408,14 @@ e1000_setup_loopback_test(struct e1000_adapter *adapter)
 		case e1000_82572:
 #define E1000_SERDES_LB_ON 0x410
 			e1000_set_phy_loopback(adapter);
-			E1000_WRITE_REG(hw, SCTL, E1000_SERDES_LB_ON);
+			E1000_WRITE_REG(hw, E1000_SCTL, E1000_SERDES_LB_ON);
 			msleep(10);
 			return 0;
 			break;
 		default:
-			rctl = E1000_READ_REG(hw, RCTL);
+			rctl = E1000_READ_REG(hw, E1000_RCTL);
 			rctl |= E1000_RCTL_LBM_TCVR;
-			E1000_WRITE_REG(hw, RCTL, rctl);
+			E1000_WRITE_REG(hw, E1000_RCTL, rctl);
 			return 0;
 		}
 	} else if (hw->media_type == e1000_media_type_copper)
@@ -1433,9 +1431,9 @@ e1000_loopback_cleanup(struct e1000_adapter *adapter)
 	uint32_t rctl;
 	uint16_t phy_reg;
 
-	rctl = E1000_READ_REG(hw, RCTL);
+	rctl = E1000_READ_REG(hw, E1000_RCTL);
 	rctl &= ~(E1000_RCTL_LBM_TCVR | E1000_RCTL_LBM_MAC);
-	E1000_WRITE_REG(hw, RCTL, rctl);
+	E1000_WRITE_REG(hw, E1000_RCTL, rctl);
 
 	switch (hw->mac_type) {
 	case e1000_82571:
@@ -1443,7 +1441,7 @@ e1000_loopback_cleanup(struct e1000_adapter *adapter)
 		if (hw->media_type == e1000_media_type_fiber ||
 		    hw->media_type == e1000_media_type_internal_serdes) {
 #define E1000_SERDES_LB_OFF 0x400
-			E1000_WRITE_REG(hw, SCTL, E1000_SERDES_LB_OFF);
+			E1000_WRITE_REG(hw, E1000_SCTL, E1000_SERDES_LB_OFF);
 			msleep(10);
 			break;
 		}
@@ -1458,10 +1456,10 @@ e1000_loopback_cleanup(struct e1000_adapter *adapter)
 			e1000_write_phy_reg(hw,
 					    GG82563_PHY_KMRN_MODE_CTRL,
 					    0x180);
-		e1000_read_phy_reg(hw, PHY_CTRL, &phy_reg);
+		e1000_read_phy_reg(hw, PHY_CONTROL, &phy_reg);
 		if (phy_reg & MII_CR_LOOPBACK) {
 			phy_reg &= ~MII_CR_LOOPBACK;
-			e1000_write_phy_reg(hw, PHY_CTRL, phy_reg);
+			e1000_write_phy_reg(hw, PHY_CONTROL, phy_reg);
 			e1000_phy_reset(hw);
 		}
 		break;
@@ -1500,7 +1498,7 @@ e1000_run_loopback_test(struct e1000_adapter *adapter)
 	int i, j, k, l, lc, good_cnt, ret_val=0;
 	unsigned long time;
 
-	E1000_WRITE_REG(&adapter->hw, RDT, rxdr->count - 1);
+	E1000_WRITE_REG(&adapter->hw, E1000_RDT, rxdr->count - 1);
 
 	/* Calculate the loop count based on the largest descriptor ring
 	 * The idea is to wrap the largest ring a number of times using 64
@@ -1523,7 +1521,7 @@ e1000_run_loopback_test(struct e1000_adapter *adapter)
 				    	PCI_DMA_TODEVICE);
 			if (unlikely(++k == txdr->count)) k = 0;
 		}
-		E1000_WRITE_REG(&adapter->hw, TDT, k);
+		E1000_WRITE_REG(&adapter->hw, E1000_TDT, k);
 		msleep(200);
 		time = jiffies; /* set the start time for the receive */
 		good_cnt = 0;
@@ -1604,7 +1602,7 @@ e1000_link_test(struct e1000_adapter *adapter, uint64_t *data)
 		if (adapter->hw.autoneg)  /* if auto_neg is set wait for it */
 			msleep(4000);
 
-		if (!(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_LU)) {
+		if (!(E1000_READ_REG(&adapter->hw, E1000_STATUS) & E1000_STATUS_LU)) {
 			*data = 1;
 		}
 	}
@@ -1715,7 +1713,7 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter, struct ethtool_wol
 	case E1000_DEV_ID_82571EB_SERDES:
 	case E1000_DEV_ID_82571EB_COPPER:
 		/* Wake events not supported on port B */
-		if (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1) {
+		if (E1000_READ_REG(hw, E1000_STATUS) & E1000_STATUS_FUNC_1) {
 			wol->supported = 0;
 			break;
 		}
@@ -1723,7 +1721,7 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter, struct ethtool_wol
 		retval = 0;
 		break;
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
-	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
+	case E1000_DEV_ID_82571EB_QUAD_COPPER_LP:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		/* quad port adapters only support WoL on port A */
 		if (!adapter->quad_port_a) {
@@ -1737,7 +1735,7 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter, struct ethtool_wol
 		/* dual port cards only support WoL on port A from now on
 		 * unless it was enabled in the eeprom for port B
 		 * so exclude FUNC_1 ports from having WoL enabled */
-		if (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1 &&
+		if (E1000_READ_REG(hw, E1000_STATUS) & E1000_STATUS_FUNC_1 &&
 		    !adapter->eeprom_wol) {
 			wol->supported = 0;
 			break;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 5f7201d..690d475 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -350,7 +350,7 @@ static void
 e1000_irq_disable(struct e1000_adapter *adapter)
 {
 	atomic_inc(&adapter->irq_sem);
-	E1000_WRITE_REG(&adapter->hw, IMC, ~0);
+	E1000_WRITE_REG(&adapter->hw, E1000_IMC, ~0);
 	E1000_WRITE_FLUSH(&adapter->hw);
 	synchronize_irq(adapter->pdev->irq);
 }
@@ -364,7 +364,7 @@ static void
 e1000_irq_enable(struct e1000_adapter *adapter)
 {
 	if (likely(atomic_dec_and_test(&adapter->irq_sem))) {
-		E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
+		E1000_WRITE_REG(&adapter->hw, E1000_IMS, IMS_ENABLE_MASK);
 		E1000_WRITE_FLUSH(&adapter->hw);
 	}
 }
@@ -378,7 +378,7 @@ e1000_update_mng_vlan(struct e1000_adapter *adapter)
 	if (adapter->vlgrp) {
 		if (!vlan_group_get_device(adapter->vlgrp, vid)) {
 			if (adapter->hw.mng_cookie.status &
-				E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) {
+				E1000_MNG_DHCP_COOKIE_STATUS_VLAN) {
 				e1000_vlan_rx_add_vid(netdev, vid);
 				adapter->mng_vlan_id = vid;
 			} else
@@ -413,16 +413,16 @@ e1000_release_hw_control(struct e1000_adapter *adapter)
 	/* Let firmware taken over control of h/w */
 	switch (adapter->hw.mac_type) {
 	case e1000_82573:
-		swsm = E1000_READ_REG(&adapter->hw, SWSM);
-		E1000_WRITE_REG(&adapter->hw, SWSM,
+		swsm = E1000_READ_REG(&adapter->hw, E1000_SWSM);
+		E1000_WRITE_REG(&adapter->hw, E1000_SWSM,
 				swsm & ~E1000_SWSM_DRV_LOAD);
 		break;
 	case e1000_82571:
 	case e1000_82572:
 	case e1000_80003es2lan:
 	case e1000_ich8lan:
-		ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
-		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
+		ctrl_ext = E1000_READ_REG(&adapter->hw, E1000_CTRL_EXT);
+		E1000_WRITE_REG(&adapter->hw, E1000_CTRL_EXT,
 				ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
 		break;
 	default:
@@ -450,16 +450,16 @@ e1000_get_hw_control(struct e1000_adapter *adapter)
 	/* Let firmware know the driver has taken over */
 	switch (adapter->hw.mac_type) {
 	case e1000_82573:
-		swsm = E1000_READ_REG(&adapter->hw, SWSM);
-		E1000_WRITE_REG(&adapter->hw, SWSM,
+		swsm = E1000_READ_REG(&adapter->hw, E1000_SWSM);
+		E1000_WRITE_REG(&adapter->hw, E1000_SWSM,
 				swsm | E1000_SWSM_DRV_LOAD);
 		break;
 	case e1000_82571:
 	case e1000_82572:
 	case e1000_80003es2lan:
 	case e1000_ich8lan:
-		ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
-		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
+		ctrl_ext = E1000_READ_REG(&adapter->hw, E1000_CTRL_EXT);
+		E1000_WRITE_REG(&adapter->hw, E1000_CTRL_EXT,
 				ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
 		break;
 	default:
@@ -471,7 +471,7 @@ static void
 e1000_init_manageability(struct e1000_adapter *adapter)
 {
 	if (adapter->en_mng_pt) {
-		uint32_t manc = E1000_READ_REG(&adapter->hw, MANC);
+		uint32_t manc = E1000_READ_REG(&adapter->hw, E1000_MANC);
 
 		/* disable hardware interception of ARP */
 		manc &= ~(E1000_MANC_ARP_EN);
@@ -480,17 +480,17 @@ e1000_init_manageability(struct e1000_adapter *adapter)
 		/* this will probably generate destination unreachable messages
 		 * from the host OS, but the packets will be handled on SMBUS */
 		if (adapter->has_manc2h) {
-			uint32_t manc2h = E1000_READ_REG(&adapter->hw, MANC2H);
+			uint32_t manc2h = E1000_READ_REG(&adapter->hw, E1000_MANC2H);
 
 			manc |= E1000_MANC_EN_MNG2HOST;
 #define E1000_MNG2HOST_PORT_623 (1 << 5)
 #define E1000_MNG2HOST_PORT_664 (1 << 6)
 			manc2h |= E1000_MNG2HOST_PORT_623;
 			manc2h |= E1000_MNG2HOST_PORT_664;
-			E1000_WRITE_REG(&adapter->hw, MANC2H, manc2h);
+			E1000_WRITE_REG(&adapter->hw, E1000_MANC2H, manc2h);
 		}
 
-		E1000_WRITE_REG(&adapter->hw, MANC, manc);
+		E1000_WRITE_REG(&adapter->hw, E1000_MANC, manc);
 	}
 }
 
@@ -498,7 +498,7 @@ static void
 e1000_release_manageability(struct e1000_adapter *adapter)
 {
 	if (adapter->en_mng_pt) {
-		uint32_t manc = E1000_READ_REG(&adapter->hw, MANC);
+		uint32_t manc = E1000_READ_REG(&adapter->hw, E1000_MANC);
 
 		/* re-enable hardware interception of ARP */
 		manc |= E1000_MANC_ARP_EN;
@@ -509,7 +509,7 @@ e1000_release_manageability(struct e1000_adapter *adapter)
 		/* don't explicitly have to mess with MANC2H since
 		 * MANC has an enable disable that gates MANC2H */
 
-		E1000_WRITE_REG(&adapter->hw, MANC, manc);
+		E1000_WRITE_REG(&adapter->hw, E1000_MANC, manc);
 	}
 }
 
@@ -555,7 +555,7 @@ int e1000_up(struct e1000_adapter *adapter)
 	e1000_irq_enable(adapter);
 
 	/* fire a link change interrupt to start the watchdog */
-	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
+	E1000_WRITE_REG(&adapter->hw, E1000_ICS, E1000_ICS_LSC);
 	return 0;
 }
 
@@ -577,9 +577,9 @@ void e1000_power_up_phy(struct e1000_adapter *adapter)
 	if (adapter->hw.media_type == e1000_media_type_copper) {
 		/* according to the manual, the phy will retain its
 		 * settings across a power-down/up cycle */
-		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
+		e1000_read_phy_reg(&adapter->hw, PHY_CONTROL, &mii_reg);
 		mii_reg &= ~MII_CR_POWER_DOWN;
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, mii_reg);
+		e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, mii_reg);
 	}
 }
 
@@ -604,7 +604,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 		case e1000_82541_rev_2:
 		case e1000_82547:
 		case e1000_82547_rev_2:
-			if (E1000_READ_REG(&adapter->hw, MANC) &
+			if (E1000_READ_REG(&adapter->hw, E1000_MANC) &
 			    E1000_MANC_SMBUS_EN)
 				goto out;
 			break;
@@ -620,9 +620,9 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 		default:
 			goto out;
 		}
-		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
+		e1000_read_phy_reg(&adapter->hw, PHY_CONTROL, &mii_reg);
 		mii_reg |= MII_CR_POWER_DOWN;
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, mii_reg);
+		e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, mii_reg);
 		mdelay(1);
 	}
 out:
@@ -681,8 +681,7 @@ e1000_reset(struct e1000_adapter *adapter)
 	 */
 
 	switch (adapter->hw.mac_type) {
-	case e1000_82542_rev2_0:
-	case e1000_82542_rev2_1:
+	case e1000_82542:
 	case e1000_82543:
 	case e1000_82544:
 	case e1000_82540:
@@ -730,7 +729,7 @@ e1000_reset(struct e1000_adapter *adapter)
 		}
 	} else if (adapter->hw.max_frame_size > MAXIMUM_ETHERNET_FRAME_SIZE) {
 		/* adjust PBA for jumbo frames */
-		E1000_WRITE_REG(&adapter->hw, PBA, pba);
+		E1000_WRITE_REG(&adapter->hw, E1000_PBA, pba);
 
 		/* To maintain wire speed transmits, the Tx FIFO should be
 		 * large enough to accomodate two full transmit packets,
@@ -738,7 +737,7 @@ e1000_reset(struct e1000_adapter *adapter)
 		 * the Rx FIFO should be large enough to accomodate at least
 		 * one full receive packet and is similarly rounded up and
 		 * expressed in KB. */
-		pba = E1000_READ_REG(&adapter->hw, PBA);
+		pba = E1000_READ_REG(&adapter->hw, E1000_PBA);
 		/* upper 16 bits has Tx packet buffer allocation size in KB */
 		tx_space = pba >> 16;
 		/* lower 16 bits has Rx packet buffer allocation size in KB */
@@ -784,7 +783,7 @@ e1000_reset(struct e1000_adapter *adapter)
 		}
 	}
 
-	E1000_WRITE_REG(&adapter->hw, PBA, pba);
+	E1000_WRITE_REG(&adapter->hw, E1000_PBA, pba);
 
 	/* flow control settings */
 	/* Set the FC high water mark to 90% of the FIFO size.
@@ -809,7 +808,7 @@ e1000_reset(struct e1000_adapter *adapter)
 	/* Allow time for pending master requests to run */
 	e1000_reset_hw(&adapter->hw);
 	if (adapter->hw.mac_type >= e1000_82544)
-		E1000_WRITE_REG(&adapter->hw, WUC, 0);
+		E1000_WRITE_REG(&adapter->hw, E1000_WUC, 0);
 
 	if (e1000_init_hw(&adapter->hw))
 		DPRINTK(PROBE, ERR, "Hardware Error\n");
@@ -820,16 +819,16 @@ e1000_reset(struct e1000_adapter *adapter)
 	    adapter->hw.mac_type <= e1000_82547_rev_2 &&
 	    adapter->hw.autoneg == 1 &&
 	    adapter->hw.autoneg_advertised == ADVERTISE_1000_FULL) {
-		uint32_t ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+		uint32_t ctrl = E1000_READ_REG(&adapter->hw, E1000_CTRL);
 		/* clear phy power management bit if we are in gig only mode,
 		 * which if enabled will attempt negotiation to 100Mb, which
 		 * can cause a loss of link at power off or driver unload */
 		ctrl &= ~E1000_CTRL_SWDPIN3;
-		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
+		E1000_WRITE_REG(&adapter->hw, E1000_CTRL, ctrl);
 	}
 
 	/* Enable h/w to recognize an 802.1Q VLAN Ethernet packet */
-	E1000_WRITE_REG(&adapter->hw, VET, ETHERNET_IEEE_VLAN_TYPE);
+	E1000_WRITE_REG(&adapter->hw, E1000_VET, ETHERNET_IEEE_VLAN_TYPE);
 
 	e1000_reset_adaptive(&adapter->hw);
 	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
@@ -1056,8 +1055,7 @@ e1000_probe(struct pci_dev *pdev,
 	 */
 
 	switch (adapter->hw.mac_type) {
-	case e1000_82542_rev2_0:
-	case e1000_82542_rev2_1:
+	case e1000_82542:
 	case e1000_82543:
 		break;
 	case e1000_82544:
@@ -1074,7 +1072,7 @@ e1000_probe(struct pci_dev *pdev,
 	case e1000_82546_rev_3:
 	case e1000_82571:
 	case e1000_80003es2lan:
-		if (E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_FUNC_1){
+		if (E1000_READ_REG(&adapter->hw, E1000_STATUS) & E1000_STATUS_FUNC_1){
 			e1000_read_eeprom(&adapter->hw,
 				EEPROM_INIT_CONTROL3_PORT_B, 1, &eeprom_data);
 			break;
@@ -1100,12 +1098,12 @@ e1000_probe(struct pci_dev *pdev,
 	case E1000_DEV_ID_82571EB_FIBER:
 		/* Wake events only supported on port A for dual fiber
 		 * regardless of eeprom setting */
-		if (E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_FUNC_1)
+		if (E1000_READ_REG(&adapter->hw, E1000_STATUS) & E1000_STATUS_FUNC_1)
 			adapter->eeprom_wol = 0;
 		break;
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
-	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
+	case E1000_DEV_ID_82571EB_QUAD_COPPER_LP:
 		/* if quad port adapter, disable WoL on all but port A */
 		if (global_quad_port_a != 0)
 			adapter->eeprom_wol = 0;
@@ -1132,8 +1130,8 @@ e1000_probe(struct pci_dev *pdev,
 		 (hw->bus_speed == e1000_bus_speed_100) ? "100MHz" :
 		 (hw->bus_speed == e1000_bus_speed_66) ? "66MHz" : "33MHz"),
 		((hw->bus_width == e1000_bus_width_64) ? "64-bit" :
-		 (hw->bus_width == e1000_bus_width_pciex_4) ? "Width x4" :
-		 (hw->bus_width == e1000_bus_width_pciex_1) ? "Width x1" :
+		 (hw->bus_width == e1000_bus_width_pcie_x4) ? "Width x4" :
+		 (hw->bus_width == e1000_bus_width_pcie_x1) ? "Width x1" :
 		 "32-bit"));
 	}
 
@@ -1417,7 +1415,7 @@ e1000_open(struct net_device *netdev)
 
 	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
 	if ((adapter->hw.mng_cookie.status &
-			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT)) {
+	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN)) {
 		e1000_update_mng_vlan(adapter);
 	}
 
@@ -1447,7 +1445,7 @@ e1000_open(struct net_device *netdev)
 	e1000_irq_enable(adapter);
 
 	/* fire a link status change interrupt to start the watchdog */
-	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
+	E1000_WRITE_REG(&adapter->hw, E1000_ICS, E1000_ICS_LSC);
 
 	return E1000_SUCCESS;
 
@@ -1491,7 +1489,7 @@ e1000_close(struct net_device *netdev)
 	/* kill manageability vlan ID if supported, but not if a vlan with
 	 * the same ID is registered on the host OS (let 8021q kill it) */
 	if ((adapter->hw.mng_cookie.status &
-			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
+			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
 	     !(adapter->vlgrp &&
 	       vlan_group_get_device(adapter->vlgrp, adapter->mng_vlan_id))) {
 		e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
@@ -1656,13 +1654,13 @@ e1000_configure_tx(struct e1000_adapter *adapter)
 		tdba = adapter->tx_ring[0].dma;
 		tdlen = adapter->tx_ring[0].count *
 			sizeof(struct e1000_tx_desc);
-		E1000_WRITE_REG(hw, TDLEN, tdlen);
-		E1000_WRITE_REG(hw, TDBAH, (tdba >> 32));
-		E1000_WRITE_REG(hw, TDBAL, (tdba & 0x00000000ffffffffULL));
-		E1000_WRITE_REG(hw, TDT, 0);
-		E1000_WRITE_REG(hw, TDH, 0);
-		adapter->tx_ring[0].tdh = ((hw->mac_type >= e1000_82543) ? E1000_TDH : E1000_82542_TDH);
-		adapter->tx_ring[0].tdt = ((hw->mac_type >= e1000_82543) ? E1000_TDT : E1000_82542_TDT);
+		E1000_WRITE_REG(hw, E1000_TDLEN, tdlen);
+		E1000_WRITE_REG(hw, E1000_TDBAH, (tdba >> 32));
+		E1000_WRITE_REG(hw, E1000_TDBAL, (tdba & 0x00000000ffffffffULL));
+		E1000_WRITE_REG(hw, E1000_TDT, 0);
+		E1000_WRITE_REG(hw, E1000_TDH, 0);
+		adapter->tx_ring[0].tdh = E1000_REGISTER(&adapter->hw, E1000_TDH);
+		adapter->tx_ring[0].tdt = E1000_REGISTER(&adapter->hw, E1000_TDT);
 		break;
 	}
 
@@ -1675,8 +1673,7 @@ e1000_configure_tx(struct e1000_adapter *adapter)
 		tipg = DEFAULT_82543_TIPG_IPGT_COPPER;
 
 	switch (hw->mac_type) {
-	case e1000_82542_rev2_0:
-	case e1000_82542_rev2_1:
+	case e1000_82542:
 		tipg = DEFAULT_82542_TIPG_IPGT;
 		ipgr1 = DEFAULT_82542_TIPG_IPGR1;
 		ipgr2 = DEFAULT_82542_TIPG_IPGR2;
@@ -1692,34 +1689,34 @@ e1000_configure_tx(struct e1000_adapter *adapter)
 	}
 	tipg |= ipgr1 << E1000_TIPG_IPGR1_SHIFT;
 	tipg |= ipgr2 << E1000_TIPG_IPGR2_SHIFT;
-	E1000_WRITE_REG(hw, TIPG, tipg);
+	E1000_WRITE_REG(hw, E1000_TIPG, tipg);
 
 	/* Set the Tx Interrupt Delay register */
 
-	E1000_WRITE_REG(hw, TIDV, adapter->tx_int_delay);
+	E1000_WRITE_REG(hw, E1000_TIDV, adapter->tx_int_delay);
 	if (hw->mac_type >= e1000_82540)
-		E1000_WRITE_REG(hw, TADV, adapter->tx_abs_int_delay);
+		E1000_WRITE_REG(hw, E1000_TADV, adapter->tx_abs_int_delay);
 
 	/* Program the Transmit Control Register */
 
-	tctl = E1000_READ_REG(hw, TCTL);
+	tctl = E1000_READ_REG(hw, E1000_TCTL);
 	tctl &= ~E1000_TCTL_CT;
 	tctl |= E1000_TCTL_PSP | E1000_TCTL_RTLC |
 		(E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT);
 
 	if (hw->mac_type == e1000_82571 || hw->mac_type == e1000_82572) {
-		tarc = E1000_READ_REG(hw, TARC0);
+		tarc = E1000_READ_REG(hw, E1000_TARC0);
 		/* set the speed mode bit, we'll clear it if we're not at
 		 * gigabit link later */
 		tarc |= (1 << 21);
-		E1000_WRITE_REG(hw, TARC0, tarc);
+		E1000_WRITE_REG(hw, E1000_TARC0, tarc);
 	} else if (hw->mac_type == e1000_80003es2lan) {
-		tarc = E1000_READ_REG(hw, TARC0);
+		tarc = E1000_READ_REG(hw, E1000_TARC0);
 		tarc |= 1;
-		E1000_WRITE_REG(hw, TARC0, tarc);
-		tarc = E1000_READ_REG(hw, TARC1);
+		E1000_WRITE_REG(hw, E1000_TARC0, tarc);
+		tarc = E1000_READ_REG(hw, E1000_TARC1);
 		tarc |= 1;
-		E1000_WRITE_REG(hw, TARC1, tarc);
+		E1000_WRITE_REG(hw, E1000_TARC1, tarc);
 	}
 
 	e1000_config_collision_dist(hw);
@@ -1742,7 +1739,7 @@ e1000_configure_tx(struct e1000_adapter *adapter)
 	    hw->bus_type == e1000_bus_type_pcix)
 		adapter->pcix_82544 = 1;
 
-	E1000_WRITE_REG(hw, TCTL, tctl);
+	E1000_WRITE_REG(hw, E1000_TCTL, tctl);
 
 }
 
@@ -1894,7 +1891,7 @@ e1000_setup_rctl(struct e1000_adapter *adapter)
 	uint32_t pages = 0;
 #endif
 
-	rctl = E1000_READ_REG(&adapter->hw, RCTL);
+	rctl = E1000_READ_REG(&adapter->hw, E1000_RCTL);
 
 	rctl &= ~(3 << E1000_RCTL_MO_SHIFT);
 
@@ -1963,14 +1960,14 @@ e1000_setup_rctl(struct e1000_adapter *adapter)
 #endif
 	if (adapter->rx_ps_pages) {
 		/* Configure extra packet-split registers */
-		rfctl = E1000_READ_REG(&adapter->hw, RFCTL);
+		rfctl = E1000_READ_REG(&adapter->hw, E1000_RFCTL);
 		rfctl |= E1000_RFCTL_EXTEN;
 		/* disable packet split support for IPv6 extension headers,
 		 * because some malformed IPv6 headers can hang the RX */
 		rfctl |= (E1000_RFCTL_IPV6_EX_DIS |
 		          E1000_RFCTL_NEW_IPV6_EXT_DIS);
 
-		E1000_WRITE_REG(&adapter->hw, RFCTL, rfctl);
+		E1000_WRITE_REG(&adapter->hw, E1000_RFCTL, rfctl);
 
 		rctl |= E1000_RCTL_DTYP_PS;
 
@@ -1990,10 +1987,10 @@ e1000_setup_rctl(struct e1000_adapter *adapter)
 			break;
 		}
 
-		E1000_WRITE_REG(&adapter->hw, PSRCTL, psrctl);
+		E1000_WRITE_REG(&adapter->hw, E1000_PSRCTL, psrctl);
 	}
 
-	E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+	E1000_WRITE_REG(&adapter->hw, E1000_RCTL, rctl);
 }
 
 /**
@@ -2024,29 +2021,29 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 	}
 
 	/* disable receives while setting up the descriptors */
-	rctl = E1000_READ_REG(hw, RCTL);
-	E1000_WRITE_REG(hw, RCTL, rctl & ~E1000_RCTL_EN);
+	rctl = E1000_READ_REG(hw, E1000_RCTL);
+	E1000_WRITE_REG(hw, E1000_RCTL, rctl & ~E1000_RCTL_EN);
 
 	/* set the Receive Delay Timer Register */
-	E1000_WRITE_REG(hw, RDTR, adapter->rx_int_delay);
+	E1000_WRITE_REG(hw, E1000_RDTR, adapter->rx_int_delay);
 
 	if (hw->mac_type >= e1000_82540) {
-		E1000_WRITE_REG(hw, RADV, adapter->rx_abs_int_delay);
+		E1000_WRITE_REG(hw, E1000_RADV, adapter->rx_abs_int_delay);
 		if (adapter->itr_setting != 0)
-			E1000_WRITE_REG(hw, ITR,
+			E1000_WRITE_REG(hw, E1000_ITR,
 				1000000000 / (adapter->itr * 256));
 	}
 
 	if (hw->mac_type >= e1000_82571) {
-		ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+		ctrl_ext = E1000_READ_REG(hw, E1000_CTRL_EXT);
 		/* Reset delay timers after every interrupt */
 		ctrl_ext |= E1000_CTRL_EXT_INT_TIMER_CLR;
 #ifdef CONFIG_E1000_NAPI
 		/* Auto-Mask interrupts upon ICR access */
 		ctrl_ext |= E1000_CTRL_EXT_IAME;
-		E1000_WRITE_REG(hw, IAM, 0xffffffff);
+		E1000_WRITE_REG(hw, E1000_IAM, 0xffffffff);
 #endif
-		E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
+		E1000_WRITE_REG(hw, E1000_CTRL_EXT, ctrl_ext);
 		E1000_WRITE_FLUSH(hw);
 	}
 
@@ -2056,19 +2053,19 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 	case 1:
 	default:
 		rdba = adapter->rx_ring[0].dma;
-		E1000_WRITE_REG(hw, RDLEN, rdlen);
-		E1000_WRITE_REG(hw, RDBAH, (rdba >> 32));
-		E1000_WRITE_REG(hw, RDBAL, (rdba & 0x00000000ffffffffULL));
-		E1000_WRITE_REG(hw, RDT, 0);
-		E1000_WRITE_REG(hw, RDH, 0);
-		adapter->rx_ring[0].rdh = ((hw->mac_type >= e1000_82543) ? E1000_RDH : E1000_82542_RDH);
-		adapter->rx_ring[0].rdt = ((hw->mac_type >= e1000_82543) ? E1000_RDT : E1000_82542_RDT);
+		E1000_WRITE_REG(hw, E1000_RDLEN, rdlen);
+		E1000_WRITE_REG(hw, E1000_RDBAH, (rdba >> 32));
+		E1000_WRITE_REG(hw, E1000_RDBAL, (rdba & 0x00000000ffffffffULL));
+		E1000_WRITE_REG(hw, E1000_RDT, 0);
+		E1000_WRITE_REG(hw, E1000_RDH, 0);
+		adapter->rx_ring[0].rdh = E1000_REGISTER(&adapter->hw, E1000_RDH);
+		adapter->rx_ring[0].rdt = E1000_REGISTER(&adapter->hw, E1000_RDT);
 		break;
 	}
 
 	/* Enable 82543 Receive Checksum Offload for TCP and UDP */
 	if (hw->mac_type >= e1000_82543) {
-		rxcsum = E1000_READ_REG(hw, RXCSUM);
+		rxcsum = E1000_READ_REG(hw, E1000_RXCSUM);
 		if (adapter->rx_csum == TRUE) {
 			rxcsum |= E1000_RXCSUM_TUOFL;
 
@@ -2082,17 +2079,17 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 			rxcsum &= ~E1000_RXCSUM_TUOFL;
 			/* don't need to clear IPPCSE as it defaults to 0 */
 		}
-		E1000_WRITE_REG(hw, RXCSUM, rxcsum);
+		E1000_WRITE_REG(hw, E1000_RXCSUM, rxcsum);
 	}
 
 	/* enable early receives on 82573, only takes effect if using > 2048
 	 * byte total frame size.  for example only for jumbo frames */
 #define E1000_ERT_2048 0x100
 	if (hw->mac_type == e1000_82573)
-		E1000_WRITE_REG(hw, ERT, E1000_ERT_2048);
+		E1000_WRITE_REG(hw, E1000_ERT, E1000_ERT_2048);
 
 	/* Enable Receives */
-	E1000_WRITE_REG(hw, RCTL, rctl);
+	E1000_WRITE_REG(hw, E1000_RCTL, rctl);
 }
 
 /**
@@ -2332,9 +2329,9 @@ e1000_enter_82542_rst(struct e1000_adapter *adapter)
 
 	e1000_pci_clear_mwi(&adapter->hw);
 
-	rctl = E1000_READ_REG(&adapter->hw, RCTL);
+	rctl = E1000_READ_REG(&adapter->hw, E1000_RCTL);
 	rctl |= E1000_RCTL_RST;
-	E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+	E1000_WRITE_REG(&adapter->hw, E1000_RCTL, rctl);
 	E1000_WRITE_FLUSH(&adapter->hw);
 	mdelay(5);
 
@@ -2348,9 +2345,9 @@ e1000_leave_82542_rst(struct e1000_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	uint32_t rctl;
 
-	rctl = E1000_READ_REG(&adapter->hw, RCTL);
+	rctl = E1000_READ_REG(&adapter->hw, E1000_RCTL);
 	rctl &= ~E1000_RCTL_RST;
-	E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+	E1000_WRITE_REG(&adapter->hw, E1000_RCTL, rctl);
 	E1000_WRITE_FLUSH(&adapter->hw);
 	mdelay(5);
 
@@ -2384,7 +2381,7 @@ e1000_set_mac(struct net_device *netdev, void *p)
 
 	/* 82542 2.0 needs to be in reset to write receive address registers */
 
-	if (adapter->hw.mac_type == e1000_82542_rev2_0)
+	if (adapter->hw.mac_type == e1000_82542)
 		e1000_enter_82542_rst(adapter);
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
@@ -2408,7 +2405,7 @@ e1000_set_mac(struct net_device *netdev, void *p)
 					E1000_RAR_ENTRIES - 1);
 	}
 
-	if (adapter->hw.mac_type == e1000_82542_rev2_0)
+	if (adapter->hw.mac_type == e1000_82542)
 		e1000_leave_82542_rst(adapter);
 
 	return 0;
@@ -2446,7 +2443,7 @@ e1000_set_multi(struct net_device *netdev)
 
 	/* Check for Promiscuous and All Multicast modes */
 
-	rctl = E1000_READ_REG(hw, RCTL);
+	rctl = E1000_READ_REG(hw, E1000_RCTL);
 
 	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
@@ -2457,11 +2454,11 @@ e1000_set_multi(struct net_device *netdev)
 		rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
 	}
 
-	E1000_WRITE_REG(hw, RCTL, rctl);
+	E1000_WRITE_REG(hw, E1000_RCTL, rctl);
 
 	/* 82542 2.0 needs to be in reset to write receive address registers */
 
-	if (hw->mac_type == e1000_82542_rev2_0)
+	if (hw->mac_type == e1000_82542)
 		e1000_enter_82542_rst(adapter);
 
 	/* load the first 14 multicast address into the exact filters 1-14
@@ -2476,9 +2473,9 @@ e1000_set_multi(struct net_device *netdev)
 			e1000_rar_set(hw, mc_ptr->dmi_addr, i);
 			mc_ptr = mc_ptr->next;
 		} else {
-			E1000_WRITE_REG_ARRAY(hw, RA, i << 1, 0);
+			E1000_WRITE_REG_ARRAY(hw, E1000_RA, i << 1, 0);
 			E1000_WRITE_FLUSH(hw);
-			E1000_WRITE_REG_ARRAY(hw, RA, (i << 1) + 1, 0);
+			E1000_WRITE_REG_ARRAY(hw, E1000_RA, (i << 1) + 1, 0);
 			E1000_WRITE_FLUSH(hw);
 		}
 	}
@@ -2486,7 +2483,7 @@ e1000_set_multi(struct net_device *netdev)
 	/* clear the old settings from the multicast hash table */
 
 	for (i = 0; i < mta_reg_count; i++) {
-		E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
+		E1000_WRITE_REG_ARRAY(hw, E1000_MTA, i, 0);
 		E1000_WRITE_FLUSH(hw);
 	}
 
@@ -2497,7 +2494,7 @@ e1000_set_multi(struct net_device *netdev)
 		e1000_mta_set(hw, hash_value);
 	}
 
-	if (hw->mac_type == e1000_82542_rev2_0)
+	if (hw->mac_type == e1000_82542)
 		e1000_leave_82542_rst(adapter);
 }
 
@@ -2524,24 +2521,24 @@ e1000_82547_tx_fifo_stall(unsigned long data)
 	uint32_t tctl;
 
 	if (atomic_read(&adapter->tx_fifo_stall)) {
-		if ((E1000_READ_REG(&adapter->hw, TDT) ==
-		    E1000_READ_REG(&adapter->hw, TDH)) &&
-		   (E1000_READ_REG(&adapter->hw, TDFT) ==
-		    E1000_READ_REG(&adapter->hw, TDFH)) &&
-		   (E1000_READ_REG(&adapter->hw, TDFTS) ==
-		    E1000_READ_REG(&adapter->hw, TDFHS))) {
-			tctl = E1000_READ_REG(&adapter->hw, TCTL);
-			E1000_WRITE_REG(&adapter->hw, TCTL,
+		if ((E1000_READ_REG(&adapter->hw, E1000_TDT) ==
+		    E1000_READ_REG(&adapter->hw, E1000_TDH)) &&
+		   (E1000_READ_REG(&adapter->hw, E1000_TDFT) ==
+		    E1000_READ_REG(&adapter->hw, E1000_TDFH)) &&
+		   (E1000_READ_REG(&adapter->hw, E1000_TDFTS) ==
+		    E1000_READ_REG(&adapter->hw, E1000_TDFHS))) {
+			tctl = E1000_READ_REG(&adapter->hw, E1000_TCTL);
+			E1000_WRITE_REG(&adapter->hw, E1000_TCTL,
 					tctl & ~E1000_TCTL_EN);
-			E1000_WRITE_REG(&adapter->hw, TDFT,
+			E1000_WRITE_REG(&adapter->hw, E1000_TDFT,
 					adapter->tx_head_addr);
-			E1000_WRITE_REG(&adapter->hw, TDFH,
+			E1000_WRITE_REG(&adapter->hw, E1000_TDFH,
 					adapter->tx_head_addr);
-			E1000_WRITE_REG(&adapter->hw, TDFTS,
+			E1000_WRITE_REG(&adapter->hw, E1000_TDFTS,
 					adapter->tx_head_addr);
-			E1000_WRITE_REG(&adapter->hw, TDFHS,
+			E1000_WRITE_REG(&adapter->hw, E1000_TDFHS,
 					adapter->tx_head_addr);
-			E1000_WRITE_REG(&adapter->hw, TCTL, tctl);
+			E1000_WRITE_REG(&adapter->hw, E1000_TCTL, tctl);
 			E1000_WRITE_FLUSH(&adapter->hw);
 
 			adapter->tx_fifo_head = 0;
@@ -2569,7 +2566,7 @@ e1000_watchdog(unsigned long data)
 	ret_val = e1000_check_for_link(&adapter->hw);
 	if ((ret_val == E1000_ERR_PHY) &&
 	    (adapter->hw.phy_type == e1000_phy_igp_3) &&
-	    (E1000_READ_REG(&adapter->hw, CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {
+	    (E1000_READ_REG(&adapter->hw, E1000_CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {
 		/* See e1000_kumeran_lock_loss_workaround() */
 		DPRINTK(LINK, INFO,
 			"Gigabit has been disabled, downgrading speed\n");
@@ -2582,10 +2579,10 @@ e1000_watchdog(unsigned long data)
 	}
 
 	if ((adapter->hw.media_type == e1000_media_type_internal_serdes) &&
-	   !(E1000_READ_REG(&adapter->hw, TXCW) & E1000_TXCW_ANE))
+	   !(E1000_READ_REG(&adapter->hw, E1000_TXCW) & E1000_TXCW_ANE))
 		link = !adapter->hw.serdes_link_down;
 	else
-		link = E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_LU;
+		link = E1000_READ_REG(&adapter->hw, E1000_STATUS) & E1000_STATUS_LU;
 
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
@@ -2595,7 +2592,7 @@ e1000_watchdog(unsigned long data)
 			                           &adapter->link_speed,
 			                           &adapter->link_duplex);
 
-			ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+			ctrl = E1000_READ_REG(&adapter->hw, E1000_CTRL);
 			DPRINTK(LINK, INFO, "NIC Link is Up %d Mbps %s, "
 			        "Flow Control: %s\n",
 			        adapter->link_speed,
@@ -2627,9 +2624,9 @@ e1000_watchdog(unsigned long data)
 			     adapter->hw.mac_type == e1000_82572) &&
 			    txb2b == 0) {
 				uint32_t tarc0;
-				tarc0 = E1000_READ_REG(&adapter->hw, TARC0);
+				tarc0 = E1000_READ_REG(&adapter->hw, E1000_TARC0);
 				tarc0 &= ~(1 << 21);
-				E1000_WRITE_REG(&adapter->hw, TARC0, tarc0);
+				E1000_WRITE_REG(&adapter->hw, E1000_TARC0, tarc0);
 			}
 
 			/* disable TSO for pcie and 10/100 speeds, to avoid
@@ -2656,9 +2653,9 @@ e1000_watchdog(unsigned long data)
 
 			/* enable transmits in the hardware, need to do this
 			 * after setting TARC0 */
-			tctl = E1000_READ_REG(&adapter->hw, TCTL);
+			tctl = E1000_READ_REG(&adapter->hw, E1000_TCTL);
 			tctl |= E1000_TCTL_EN;
-			E1000_WRITE_REG(&adapter->hw, TCTL, tctl);
+			E1000_WRITE_REG(&adapter->hw, E1000_TCTL, tctl);
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
@@ -2668,8 +2665,8 @@ e1000_watchdog(unsigned long data)
 			/* make sure the receive unit is started */
 			if (adapter->hw.rx_needs_kicking) {
 				struct e1000_hw *hw = &adapter->hw;
-				uint32_t rctl = E1000_READ_REG(hw, RCTL);
-				E1000_WRITE_REG(hw, RCTL, rctl | E1000_RCTL_EN);
+				uint32_t rctl = E1000_READ_REG(hw, E1000_RCTL);
+				E1000_WRITE_REG(hw, E1000_RCTL, rctl | E1000_RCTL_EN);
 			}
 		}
 	} else {
@@ -2720,7 +2717,7 @@ e1000_watchdog(unsigned long data)
 	}
 
 	/* Cause software interrupt to ensure rx ring is cleaned */
-	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_RXDMT0);
+	E1000_WRITE_REG(&adapter->hw, E1000_ICS, E1000_ICS_RXDMT0);
 
 	/* Force detection of hung controller every watchdog period */
 	adapter->detect_tx_hung = TRUE;
@@ -2865,7 +2862,7 @@ set_itr_now:
 		             min(adapter->itr + (new_itr >> 2), new_itr) :
 		             new_itr;
 		adapter->itr = new_itr;
-		E1000_WRITE_REG(hw, ITR, 1000000000 / (new_itr * 256));
+		E1000_WRITE_REG(hw, E1000_ITR, 1000000000 / (new_itr * 256));
 	}
 
 	return;
@@ -3201,7 +3198,7 @@ e1000_transfer_dhcp_info(struct e1000_adapter *adapter, struct sk_buff *skb)
 	if (vlan_tx_tag_present(skb)) {
 		if (!((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id) &&
 			( adapter->hw.mng_cookie.status &
-			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT)) )
+			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN)) )
 			return 0;
 	}
 	if (skb->len > MINIMUM_DHCP_PACKET_SIZE) {
@@ -3601,89 +3598,89 @@ e1000_update_stats(struct e1000_adapter *adapter)
 	 * be written while holding adapter->stats_lock
 	 */
 
-	adapter->stats.crcerrs += E1000_READ_REG(hw, CRCERRS);
-	adapter->stats.gprc += E1000_READ_REG(hw, GPRC);
-	adapter->stats.gorcl += E1000_READ_REG(hw, GORCL);
-	adapter->stats.gorch += E1000_READ_REG(hw, GORCH);
-	adapter->stats.bprc += E1000_READ_REG(hw, BPRC);
-	adapter->stats.mprc += E1000_READ_REG(hw, MPRC);
-	adapter->stats.roc += E1000_READ_REG(hw, ROC);
+	adapter->stats.crcerrs += E1000_READ_REG(hw, E1000_CRCERRS);
+	adapter->stats.gprc += E1000_READ_REG(hw, E1000_GPRC);
+	adapter->stats.gorcl += E1000_READ_REG(hw, E1000_GORCL);
+	adapter->stats.gorch += E1000_READ_REG(hw, E1000_GORCH);
+	adapter->stats.bprc += E1000_READ_REG(hw, E1000_BPRC);
+	adapter->stats.mprc += E1000_READ_REG(hw, E1000_MPRC);
+	adapter->stats.roc += E1000_READ_REG(hw, E1000_ROC);
 
 	if (adapter->hw.mac_type != e1000_ich8lan) {
-		adapter->stats.prc64 += E1000_READ_REG(hw, PRC64);
-		adapter->stats.prc127 += E1000_READ_REG(hw, PRC127);
-		adapter->stats.prc255 += E1000_READ_REG(hw, PRC255);
-		adapter->stats.prc511 += E1000_READ_REG(hw, PRC511);
-		adapter->stats.prc1023 += E1000_READ_REG(hw, PRC1023);
-		adapter->stats.prc1522 += E1000_READ_REG(hw, PRC1522);
-	}
-
-	adapter->stats.symerrs += E1000_READ_REG(hw, SYMERRS);
-	adapter->stats.mpc += E1000_READ_REG(hw, MPC);
-	adapter->stats.scc += E1000_READ_REG(hw, SCC);
-	adapter->stats.ecol += E1000_READ_REG(hw, ECOL);
-	adapter->stats.mcc += E1000_READ_REG(hw, MCC);
-	adapter->stats.latecol += E1000_READ_REG(hw, LATECOL);
-	adapter->stats.dc += E1000_READ_REG(hw, DC);
-	adapter->stats.sec += E1000_READ_REG(hw, SEC);
-	adapter->stats.rlec += E1000_READ_REG(hw, RLEC);
-	adapter->stats.xonrxc += E1000_READ_REG(hw, XONRXC);
-	adapter->stats.xontxc += E1000_READ_REG(hw, XONTXC);
-	adapter->stats.xoffrxc += E1000_READ_REG(hw, XOFFRXC);
-	adapter->stats.xofftxc += E1000_READ_REG(hw, XOFFTXC);
-	adapter->stats.fcruc += E1000_READ_REG(hw, FCRUC);
-	adapter->stats.gptc += E1000_READ_REG(hw, GPTC);
-	adapter->stats.gotcl += E1000_READ_REG(hw, GOTCL);
-	adapter->stats.gotch += E1000_READ_REG(hw, GOTCH);
-	adapter->stats.rnbc += E1000_READ_REG(hw, RNBC);
-	adapter->stats.ruc += E1000_READ_REG(hw, RUC);
-	adapter->stats.rfc += E1000_READ_REG(hw, RFC);
-	adapter->stats.rjc += E1000_READ_REG(hw, RJC);
-	adapter->stats.torl += E1000_READ_REG(hw, TORL);
-	adapter->stats.torh += E1000_READ_REG(hw, TORH);
-	adapter->stats.totl += E1000_READ_REG(hw, TOTL);
-	adapter->stats.toth += E1000_READ_REG(hw, TOTH);
-	adapter->stats.tpr += E1000_READ_REG(hw, TPR);
+		adapter->stats.prc64 += E1000_READ_REG(hw, E1000_PRC64);
+		adapter->stats.prc127 += E1000_READ_REG(hw, E1000_PRC127);
+		adapter->stats.prc255 += E1000_READ_REG(hw, E1000_PRC255);
+		adapter->stats.prc511 += E1000_READ_REG(hw, E1000_PRC511);
+		adapter->stats.prc1023 += E1000_READ_REG(hw, E1000_PRC1023);
+		adapter->stats.prc1522 += E1000_READ_REG(hw, E1000_PRC1522);
+	}
+
+	adapter->stats.symerrs += E1000_READ_REG(hw, E1000_SYMERRS);
+	adapter->stats.mpc += E1000_READ_REG(hw, E1000_MPC);
+	adapter->stats.scc += E1000_READ_REG(hw, E1000_SCC);
+	adapter->stats.ecol += E1000_READ_REG(hw, E1000_ECOL);
+	adapter->stats.mcc += E1000_READ_REG(hw, E1000_MCC);
+	adapter->stats.latecol += E1000_READ_REG(hw, E1000_LATECOL);
+	adapter->stats.dc += E1000_READ_REG(hw, E1000_DC);
+	adapter->stats.sec += E1000_READ_REG(hw, E1000_SEC);
+	adapter->stats.rlec += E1000_READ_REG(hw, E1000_RLEC);
+	adapter->stats.xonrxc += E1000_READ_REG(hw, E1000_XONRXC);
+	adapter->stats.xontxc += E1000_READ_REG(hw, E1000_XONTXC);
+	adapter->stats.xoffrxc += E1000_READ_REG(hw, E1000_XOFFRXC);
+	adapter->stats.xofftxc += E1000_READ_REG(hw, E1000_XOFFTXC);
+	adapter->stats.fcruc += E1000_READ_REG(hw, E1000_FCRUC);
+	adapter->stats.gptc += E1000_READ_REG(hw, E1000_GPTC);
+	adapter->stats.gotcl += E1000_READ_REG(hw, E1000_GOTCL);
+	adapter->stats.gotch += E1000_READ_REG(hw, E1000_GOTCH);
+	adapter->stats.rnbc += E1000_READ_REG(hw, E1000_RNBC);
+	adapter->stats.ruc += E1000_READ_REG(hw, E1000_RUC);
+	adapter->stats.rfc += E1000_READ_REG(hw, E1000_RFC);
+	adapter->stats.rjc += E1000_READ_REG(hw, E1000_RJC);
+	adapter->stats.torl += E1000_READ_REG(hw, E1000_TORL);
+	adapter->stats.torh += E1000_READ_REG(hw, E1000_TORH);
+	adapter->stats.totl += E1000_READ_REG(hw, E1000_TOTL);
+	adapter->stats.toth += E1000_READ_REG(hw, E1000_TOTH);
+	adapter->stats.tpr += E1000_READ_REG(hw, E1000_TPR);
 
 	if (adapter->hw.mac_type != e1000_ich8lan) {
-		adapter->stats.ptc64 += E1000_READ_REG(hw, PTC64);
-		adapter->stats.ptc127 += E1000_READ_REG(hw, PTC127);
-		adapter->stats.ptc255 += E1000_READ_REG(hw, PTC255);
-		adapter->stats.ptc511 += E1000_READ_REG(hw, PTC511);
-		adapter->stats.ptc1023 += E1000_READ_REG(hw, PTC1023);
-		adapter->stats.ptc1522 += E1000_READ_REG(hw, PTC1522);
+		adapter->stats.ptc64 += E1000_READ_REG(hw, E1000_PTC64);
+		adapter->stats.ptc127 += E1000_READ_REG(hw, E1000_PTC127);
+		adapter->stats.ptc255 += E1000_READ_REG(hw, E1000_PTC255);
+		adapter->stats.ptc511 += E1000_READ_REG(hw, E1000_PTC511);
+		adapter->stats.ptc1023 += E1000_READ_REG(hw, E1000_PTC1023);
+		adapter->stats.ptc1522 += E1000_READ_REG(hw, E1000_PTC1522);
 	}
 
-	adapter->stats.mptc += E1000_READ_REG(hw, MPTC);
-	adapter->stats.bptc += E1000_READ_REG(hw, BPTC);
+	adapter->stats.mptc += E1000_READ_REG(hw, E1000_MPTC);
+	adapter->stats.bptc += E1000_READ_REG(hw, E1000_BPTC);
 
 	/* used for adaptive IFS */
 
-	hw->tx_packet_delta = E1000_READ_REG(hw, TPT);
+	hw->tx_packet_delta = E1000_READ_REG(hw, E1000_TPT);
 	adapter->stats.tpt += hw->tx_packet_delta;
-	hw->collision_delta = E1000_READ_REG(hw, COLC);
+	hw->collision_delta = E1000_READ_REG(hw, E1000_COLC);
 	adapter->stats.colc += hw->collision_delta;
 
 	if (hw->mac_type >= e1000_82543) {
-		adapter->stats.algnerrc += E1000_READ_REG(hw, ALGNERRC);
-		adapter->stats.rxerrc += E1000_READ_REG(hw, RXERRC);
-		adapter->stats.tncrs += E1000_READ_REG(hw, TNCRS);
-		adapter->stats.cexterr += E1000_READ_REG(hw, CEXTERR);
-		adapter->stats.tsctc += E1000_READ_REG(hw, TSCTC);
-		adapter->stats.tsctfc += E1000_READ_REG(hw, TSCTFC);
+		adapter->stats.algnerrc += E1000_READ_REG(hw, E1000_ALGNERRC);
+		adapter->stats.rxerrc += E1000_READ_REG(hw, E1000_RXERRC);
+		adapter->stats.tncrs += E1000_READ_REG(hw, E1000_TNCRS);
+		adapter->stats.cexterr += E1000_READ_REG(hw, E1000_CEXTERR);
+		adapter->stats.tsctc += E1000_READ_REG(hw, E1000_TSCTC);
+		adapter->stats.tsctfc += E1000_READ_REG(hw, E1000_TSCTFC);
 	}
 	if (hw->mac_type > e1000_82547_rev_2) {
-		adapter->stats.iac += E1000_READ_REG(hw, IAC);
-		adapter->stats.icrxoc += E1000_READ_REG(hw, ICRXOC);
+		adapter->stats.iac += E1000_READ_REG(hw, E1000_IAC);
+		adapter->stats.icrxoc += E1000_READ_REG(hw, E1000_ICRXOC);
 
 		if (adapter->hw.mac_type != e1000_ich8lan) {
-			adapter->stats.icrxptc += E1000_READ_REG(hw, ICRXPTC);
-			adapter->stats.icrxatc += E1000_READ_REG(hw, ICRXATC);
-			adapter->stats.ictxptc += E1000_READ_REG(hw, ICTXPTC);
-			adapter->stats.ictxatc += E1000_READ_REG(hw, ICTXATC);
-			adapter->stats.ictxqec += E1000_READ_REG(hw, ICTXQEC);
-			adapter->stats.ictxqmtc += E1000_READ_REG(hw, ICTXQMTC);
-			adapter->stats.icrxdmtc += E1000_READ_REG(hw, ICRXDMTC);
+			adapter->stats.icrxptc += E1000_READ_REG(hw, E1000_ICRXPTC);
+			adapter->stats.icrxatc += E1000_READ_REG(hw, E1000_ICRXATC);
+			adapter->stats.ictxptc += E1000_READ_REG(hw, E1000_ICTXPTC);
+			adapter->stats.ictxatc += E1000_READ_REG(hw, E1000_ICTXATC);
+			adapter->stats.ictxqec += E1000_READ_REG(hw, E1000_ICTXQEC);
+			adapter->stats.ictxqmtc += E1000_READ_REG(hw, E1000_ICTXQMTC);
+			adapter->stats.icrxdmtc += E1000_READ_REG(hw, E1000_ICRXDMTC);
 		}
 	}
 
@@ -3739,9 +3736,9 @@ e1000_update_stats(struct e1000_adapter *adapter)
 
 	/* Management Stats */
 	if (adapter->hw.has_smbus) {
-		adapter->stats.mgptc += E1000_READ_REG(hw, MGTPTC);
-		adapter->stats.mgprc += E1000_READ_REG(hw, MGTPRC);
-		adapter->stats.mgpdc += E1000_READ_REG(hw, MGTPDC);
+		adapter->stats.mgptc += E1000_READ_REG(hw, E1000_MGTPTC);
+		adapter->stats.mgprc += E1000_READ_REG(hw, E1000_MGTPRC);
+		adapter->stats.mgpdc += E1000_READ_REG(hw, E1000_MGTPDC);
 	}
 
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
@@ -3763,7 +3760,7 @@ e1000_intr_msi(int irq, void *data)
 #ifndef CONFIG_E1000_NAPI
 	int i;
 #endif
-	uint32_t icr = E1000_READ_REG(hw, ICR);
+	uint32_t icr = E1000_READ_REG(hw, E1000_ICR);
 
 #ifdef CONFIG_E1000_NAPI
 	/* read ICR disables interrupts using IAM, so keep up with our
@@ -3778,8 +3775,8 @@ e1000_intr_msi(int irq, void *data)
 		if (netif_carrier_ok(netdev) &&
 		    (adapter->hw.mac_type == e1000_80003es2lan)) {
 			/* disable receives */
-			uint32_t rctl = E1000_READ_REG(hw, RCTL);
-			E1000_WRITE_REG(hw, RCTL, rctl & ~E1000_RCTL_EN);
+			uint32_t rctl = E1000_READ_REG(hw, E1000_RCTL);
+			E1000_WRITE_REG(hw, E1000_RCTL, rctl & ~E1000_RCTL_EN);
 		}
 		/* guard against interrupt when we're going down */
 		if (!test_bit(__E1000_DOWN, &adapter->flags))
@@ -3826,7 +3823,7 @@ e1000_intr(int irq, void *data)
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t rctl, icr = E1000_READ_REG(hw, ICR);
+	uint32_t rctl, icr = E1000_READ_REG(hw, E1000_ICR);
 #ifndef CONFIG_E1000_NAPI
 	int i;
 #endif
@@ -3858,8 +3855,8 @@ e1000_intr(int irq, void *data)
 		if (netif_carrier_ok(netdev) &&
 		    (adapter->hw.mac_type == e1000_80003es2lan)) {
 			/* disable receives */
-			rctl = E1000_READ_REG(hw, RCTL);
-			E1000_WRITE_REG(hw, RCTL, rctl & ~E1000_RCTL_EN);
+			rctl = E1000_READ_REG(hw, E1000_RCTL);
+			E1000_WRITE_REG(hw, E1000_RCTL, rctl & ~E1000_RCTL_EN);
 		}
 		/* guard against interrupt when we're going down */
 		if (!test_bit(__E1000_DOWN, &adapter->flags))
@@ -3870,7 +3867,7 @@ e1000_intr(int irq, void *data)
 	if (unlikely(hw->mac_type < e1000_82571)) {
 		/* disable interrupts, without the synchronize_irq bit */
 		atomic_inc(&adapter->irq_sem);
-		E1000_WRITE_REG(hw, IMC, ~0);
+		E1000_WRITE_REG(hw, E1000_IMC, ~0);
 		E1000_WRITE_FLUSH(hw);
 	}
 	if (likely(netif_rx_schedule_prep(netdev))) {
@@ -3896,7 +3893,7 @@ e1000_intr(int irq, void *data)
 	 */
 	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2) {
 		atomic_inc(&adapter->irq_sem);
-		E1000_WRITE_REG(hw, IMC, ~0);
+		E1000_WRITE_REG(hw, E1000_IMC, ~0);
 	}
 
 	adapter->total_tx_bytes = 0;
@@ -4049,7 +4046,7 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		if (tx_ring->buffer_info[eop].dma &&
 		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
 		               (adapter->tx_timeout_factor * HZ))
-		    && !(E1000_READ_REG(&adapter->hw, STATUS) &
+		    && !(E1000_READ_REG(&adapter->hw, E1000_STATUS) &
 		         E1000_STATUS_TXOFF)) {
 
 			/* detected Tx unit hang */
@@ -4726,11 +4723,11 @@ e1000_smartspeed(struct e1000_adapter *adapter)
 					    phy_ctrl);
 			adapter->smartspeed++;
 			if (!e1000_phy_setup_autoneg(&adapter->hw) &&
-			   !e1000_read_phy_reg(&adapter->hw, PHY_CTRL,
+			   !e1000_read_phy_reg(&adapter->hw, PHY_CONTROL,
 				   	       &phy_ctrl)) {
 				phy_ctrl |= (MII_CR_AUTO_NEG_EN |
 					     MII_CR_RESTART_AUTO_NEG);
-				e1000_write_phy_reg(&adapter->hw, PHY_CTRL,
+				e1000_write_phy_reg(&adapter->hw, PHY_CONTROL,
 						    phy_ctrl);
 			}
 		}
@@ -4741,10 +4738,10 @@ e1000_smartspeed(struct e1000_adapter *adapter)
 		phy_ctrl |= CR_1000T_MS_ENABLE;
 		e1000_write_phy_reg(&adapter->hw, PHY_1000T_CTRL, phy_ctrl);
 		if (!e1000_phy_setup_autoneg(&adapter->hw) &&
-		   !e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &phy_ctrl)) {
+		   !e1000_read_phy_reg(&adapter->hw, PHY_CONTROL, &phy_ctrl)) {
 			phy_ctrl |= (MII_CR_AUTO_NEG_EN |
 				     MII_CR_RESTART_AUTO_NEG);
-			e1000_write_phy_reg(&adapter->hw, PHY_CTRL, phy_ctrl);
+			e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, phy_ctrl);
 		}
 	}
 	/* Restart process after E1000_SMARTSPEED_MAX iterations */
@@ -4821,12 +4818,12 @@ e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 		}
 		if (adapter->hw.media_type == e1000_media_type_copper) {
 			switch (data->reg_num) {
-			case PHY_CTRL:
+			case PHY_CONTROL:
 				if (mii_reg & MII_CR_POWER_DOWN)
 					break;
 				if (mii_reg & MII_CR_AUTO_NEG_EN) {
-					adapter->hw.autoneg = 1;
-					adapter->hw.autoneg_advertised = 0x2F;
+					adapter->hw.mac.autoneg = 1;
+					adapter->hw.phy.autoneg_advertised = 0x2F;
 				} else {
 					if (mii_reg & 0x40)
 						spddplx = SPEED_1000;
@@ -4862,7 +4859,7 @@ e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 			}
 		} else {
 			switch (data->reg_num) {
-			case PHY_CTRL:
+			case PHY_CONTROL:
 				if (mii_reg & MII_CR_POWER_DOWN)
 					break;
 				if (netif_running(adapter->netdev))
@@ -4946,29 +4943,29 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 
 	if (grp) {
 		/* enable VLAN tag insert/strip */
-		ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+		ctrl = E1000_READ_REG(&adapter->hw, E1000_CTRL);
 		ctrl |= E1000_CTRL_VME;
-		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
+		E1000_WRITE_REG(&adapter->hw, E1000_CTRL, ctrl);
 
 		if (adapter->hw.mac_type != e1000_ich8lan) {
 			/* enable VLAN receive filtering */
-			rctl = E1000_READ_REG(&adapter->hw, RCTL);
+			rctl = E1000_READ_REG(&adapter->hw, E1000_RCTL);
 			rctl |= E1000_RCTL_VFE;
 			rctl &= ~E1000_RCTL_CFIEN;
-			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+			E1000_WRITE_REG(&adapter->hw, E1000_RCTL, rctl);
 			e1000_update_mng_vlan(adapter);
 		}
 	} else {
 		/* disable VLAN tag insert/strip */
-		ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+		ctrl = E1000_READ_REG(&adapter->hw, E1000_CTRL);
 		ctrl &= ~E1000_CTRL_VME;
-		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
+		E1000_WRITE_REG(&adapter->hw, E1000_CTRL, ctrl);
 
 		if (adapter->hw.mac_type != e1000_ich8lan) {
 			/* disable VLAN filtering */
-			rctl = E1000_READ_REG(&adapter->hw, RCTL);
+			rctl = E1000_READ_REG(&adapter->hw, E1000_RCTL);
 			rctl &= ~E1000_RCTL_VFE;
-			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+			E1000_WRITE_REG(&adapter->hw, E1000_RCTL, rctl);
 			if (adapter->mng_vlan_id !=
 			    (uint16_t)E1000_MNG_VLAN_NONE) {
 				e1000_vlan_rx_kill_vid(netdev,
@@ -4988,12 +4985,12 @@ e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
 	uint32_t vfta, index;
 
 	if ((adapter->hw.mng_cookie.status &
-	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
+	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
 	    (vid == adapter->mng_vlan_id))
 		return;
 	/* add VID to filter table */
 	index = (vid >> 5) & 0x7F;
-	vfta = E1000_READ_REG_ARRAY(&adapter->hw, VFTA, index);
+	vfta = E1000_READ_REG_ARRAY(&adapter->hw, E1000_VFTA, index);
 	vfta |= (1 << (vid & 0x1F));
 	e1000_write_vfta(&adapter->hw, index, vfta);
 }
@@ -5009,7 +5006,7 @@ e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
 	e1000_irq_enable(adapter);
 
 	if ((adapter->hw.mng_cookie.status &
-	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
+	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
 	    (vid == adapter->mng_vlan_id)) {
 		/* release control to f/w */
 		e1000_release_hw_control(adapter);
@@ -5018,7 +5015,7 @@ e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
 
 	/* remove VID from filter table */
 	index = (vid >> 5) & 0x7F;
-	vfta = E1000_READ_REG_ARRAY(&adapter->hw, VFTA, index);
+	vfta = E1000_READ_REG_ARRAY(&adapter->hw, E1000_VFTA, index);
 	vfta &= ~(1 << (vid & 0x1F));
 	e1000_write_vfta(&adapter->hw, index, vfta);
 }
@@ -5052,16 +5049,16 @@ e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx)
 
 	switch (spddplx) {
 	case SPEED_10 + DUPLEX_HALF:
-		adapter->hw.forced_speed_duplex = e1000_10_half;
+		adapter->hw.forced_speed_duplex = ADVERTISE_10_HALF;
 		break;
 	case SPEED_10 + DUPLEX_FULL:
-		adapter->hw.forced_speed_duplex = e1000_10_full;
+		adapter->hw.forced_speed_duplex = ADVERTISE_10_FULL;
 		break;
 	case SPEED_100 + DUPLEX_HALF:
-		adapter->hw.forced_speed_duplex = e1000_100_half;
+		adapter->hw.forced_speed_duplex = ADVERTISE_100_HALF;
 		break;
 	case SPEED_100 + DUPLEX_FULL:
-		adapter->hw.forced_speed_duplex = e1000_100_full;
+		adapter->hw.forced_speed_duplex = ADVERTISE_100_FULL;
 		break;
 	case SPEED_1000 + DUPLEX_FULL:
 		adapter->hw.autoneg = 1;
@@ -5099,7 +5096,7 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 		return retval;
 #endif
 
-	status = E1000_READ_REG(&adapter->hw, STATUS);
+	status = E1000_READ_REG(&adapter->hw, E1000_STATUS);
 	if (status & E1000_STATUS_LU)
 		wufc &= ~E1000_WUFC_LNKC;
 
@@ -5109,40 +5106,40 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 
 		/* turn on all-multi mode if wake on multicast is enabled */
 		if (wufc & E1000_WUFC_MC) {
-			rctl = E1000_READ_REG(&adapter->hw, RCTL);
+			rctl = E1000_READ_REG(&adapter->hw, E1000_RCTL);
 			rctl |= E1000_RCTL_MPE;
-			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+			E1000_WRITE_REG(&adapter->hw, E1000_RCTL, rctl);
 		}
 
 		if (adapter->hw.mac_type >= e1000_82540) {
-			ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+			ctrl = E1000_READ_REG(&adapter->hw, E1000_CTRL);
 			/* advertise wake from D3Cold */
 			#define E1000_CTRL_ADVD3WUC 0x00100000
 			/* phy power management enable */
 			#define E1000_CTRL_EN_PHY_PWR_MGMT 0x00200000
 			ctrl |= E1000_CTRL_ADVD3WUC |
 				E1000_CTRL_EN_PHY_PWR_MGMT;
-			E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
+			E1000_WRITE_REG(&adapter->hw, E1000_CTRL, ctrl);
 		}
 
 		if (adapter->hw.media_type == e1000_media_type_fiber ||
 		   adapter->hw.media_type == e1000_media_type_internal_serdes) {
 			/* keep the laser running in D3 */
-			ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
+			ctrl_ext = E1000_READ_REG(&adapter->hw, E1000_CTRL_EXT);
 			ctrl_ext |= E1000_CTRL_EXT_SDP7_DATA;
-			E1000_WRITE_REG(&adapter->hw, CTRL_EXT, ctrl_ext);
+			E1000_WRITE_REG(&adapter->hw, E1000_CTRL_EXT, ctrl_ext);
 		}
 
 		/* Allow time for pending master requests to run */
 		e1000_disable_pciex_master(&adapter->hw);
 
-		E1000_WRITE_REG(&adapter->hw, WUC, E1000_WUC_PME_EN);
-		E1000_WRITE_REG(&adapter->hw, WUFC, wufc);
+		E1000_WRITE_REG(&adapter->hw, E1000_WUC, E1000_WUC_PME_EN);
+		E1000_WRITE_REG(&adapter->hw, E1000_WUFC, wufc);
 		pci_enable_wake(pdev, PCI_D3hot, 1);
 		pci_enable_wake(pdev, PCI_D3cold, 1);
 	} else {
-		E1000_WRITE_REG(&adapter->hw, WUC, 0);
-		E1000_WRITE_REG(&adapter->hw, WUFC, 0);
+		E1000_WRITE_REG(&adapter->hw, E1000_WUC, 0);
+		E1000_WRITE_REG(&adapter->hw, E1000_WUFC, 0);
 		pci_enable_wake(pdev, PCI_D3hot, 0);
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
@@ -5196,7 +5193,7 @@ e1000_resume(struct pci_dev *pdev)
 
 	e1000_power_up_phy(adapter);
 	e1000_reset(adapter);
-	E1000_WRITE_REG(&adapter->hw, WUS, ~0);
+	E1000_WRITE_REG(&adapter->hw, E1000_WUS, ~0);
 
 	e1000_init_manageability(adapter);
 
@@ -5288,7 +5285,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
 	e1000_reset(adapter);
-	E1000_WRITE_REG(&adapter->hw, WUS, ~0);
+	E1000_WRITE_REG(&adapter->hw, E1000_WUS, ~0);
 
 	return PCI_ERS_RESULT_RECOVERED;
 }
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 10af742..d486e63 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -61,60 +61,50 @@ typedef enum {
 #define DEBUGOUT3 DEBUGOUT2
 #define DEBUGOUT7 DEBUGOUT3
 
+#define E1000_REGISTER(a, reg) (((a)->mac.type >= e1000_82543) \
+                               ? reg                           \
+                               : e1000_translate_register_82542(reg))
 
 #define E1000_WRITE_REG(a, reg, value) ( \
-    writel((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg))))
+    writel((value), ((a)->hw_addr + E1000_REGISTER(a, reg))))
 
-#define E1000_READ_REG(a, reg) ( \
-    readl((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)))
+#define E1000_READ_REG(a, reg) (readl((a)->hw_addr + E1000_REGISTER(a, reg)))
 
 #define E1000_WRITE_REG_ARRAY(a, reg, offset, value) ( \
-    writel((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        ((offset) << 2))))
+    writel((value), ((a)->hw_addr + E1000_REGISTER(a, reg) + ((offset) << 2))))
 
 #define E1000_READ_REG_ARRAY(a, reg, offset) ( \
-    readl((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        ((offset) << 2)))
+    readl((a)->hw_addr + E1000_REGISTER(a, reg) + ((offset) << 2)))
 
 #define E1000_READ_REG_ARRAY_DWORD E1000_READ_REG_ARRAY
 #define E1000_WRITE_REG_ARRAY_DWORD E1000_WRITE_REG_ARRAY
 
 #define E1000_WRITE_REG_ARRAY_WORD(a, reg, offset, value) ( \
-    writew((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        ((offset) << 1))))
+    writew((value), ((a)->hw_addr + E1000_REGISTER(a, reg) + ((offset) << 1))))
 
 #define E1000_READ_REG_ARRAY_WORD(a, reg, offset) ( \
-    readw((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        ((offset) << 1)))
+    readw((a)->hw_addr + E1000_REGISTER(a, reg) + ((offset) << 1)))
 
 #define E1000_WRITE_REG_ARRAY_BYTE(a, reg, offset, value) ( \
-    writeb((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        (offset))))
+    writeb((value), ((a)->hw_addr + E1000_REGISTER(a, reg) + (offset))))
 
 #define E1000_READ_REG_ARRAY_BYTE(a, reg, offset) ( \
-    readb((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        (offset)))
+    readb((a)->hw_addr + E1000_REGISTER(a, reg) + (offset)))
 
-#define E1000_WRITE_FLUSH(a) E1000_READ_REG(a, STATUS)
+#define E1000_WRITE_REG_IO(a, reg, offset) do { \
+    outl(reg, ((a)->io_base));                  \
+    outl(offset, ((a)->io_base + 4));      } while(0)
 
-#define E1000_WRITE_ICH_FLASH_REG(a, reg, value) ( \
-    writel((value), ((a)->flash_address + reg)))
+#define E1000_WRITE_FLUSH(a) E1000_READ_REG(a, E1000_STATUS)
 
-#define E1000_READ_ICH_FLASH_REG(a, reg) ( \
-    readl((a)->flash_address + reg))
+#define E1000_WRITE_FLASH_REG(a, reg, value) ( \
+    writel((value), ((a)->flash_address + reg)))
 
-#define E1000_WRITE_ICH_FLASH_REG16(a, reg, value) ( \
+#define E1000_WRITE_FLASH_REG16(a, reg, value) ( \
     writew((value), ((a)->flash_address + reg)))
 
-#define E1000_READ_ICH_FLASH_REG16(a, reg) ( \
-    readw((a)->flash_address + reg))
+#define E1000_READ_FLASH_REG(a, reg) (readl((a)->flash_address + reg))
+
+#define E1000_READ_FLASH_REG16(a, reg) (readw((a)->flash_address + reg))
 
 #endif /* _E1000_OSDEP_H_ */
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index f8862e2..e01c993 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -358,17 +358,17 @@ e1000_check_options(struct e1000_adapter *adapter)
 	{ /* Flow Control */
 
 		struct e1000_opt_list fc_list[] =
-			{{ E1000_FC_NONE,    "Flow Control Disabled" },
-			 { E1000_FC_RX_PAUSE,"Flow Control Receive Only" },
-			 { E1000_FC_TX_PAUSE,"Flow Control Transmit Only" },
-			 { E1000_FC_FULL,    "Flow Control Enabled" },
-			 { E1000_FC_DEFAULT, "Flow Control Hardware Default" }};
+			{{ e1000_fc_none,    "Flow Control Disabled" },
+			 { e1000_fc_rx_pause,"Flow Control Receive Only" },
+			 { e1000_fc_tx_pause,"Flow Control Transmit Only" },
+			 { e1000_fc_full,    "Flow Control Enabled" },
+			 { e1000_fc_default, "Flow Control Hardware Default" }};
 
 		struct e1000_option opt = {
 			.type = list_option,
 			.name = "Flow Control",
 			.err  = "reading default settings from EEPROM",
-			.def  = E1000_FC_DEFAULT,
+			.def  = e1000_fc_default,
 			.arg  = { .l = { .nr = ARRAY_SIZE(fc_list),
 					 .p = fc_list }}
 		};
@@ -727,13 +727,13 @@ e1000_check_copper_options(struct e1000_adapter *adapter)
 	case SPEED_10 + HALF_DUPLEX:
 		DPRINTK(PROBE, INFO, "Forcing to 10 Mbps Half Duplex\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 0;
-		adapter->hw.forced_speed_duplex = e1000_10_half;
+		adapter->hw.forced_speed_duplex = ADVERTISE_10_HALF;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_10 + FULL_DUPLEX:
 		DPRINTK(PROBE, INFO, "Forcing to 10 Mbps Full Duplex\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 0;
-		adapter->hw.forced_speed_duplex = e1000_10_full;
+		adapter->hw.forced_speed_duplex = ADVERTISE_10_FULL;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_100:
@@ -748,13 +748,13 @@ e1000_check_copper_options(struct e1000_adapter *adapter)
 	case SPEED_100 + HALF_DUPLEX:
 		DPRINTK(PROBE, INFO, "Forcing to 100 Mbps Half Duplex\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 0;
-		adapter->hw.forced_speed_duplex = e1000_100_half;
+		adapter->hw.forced_speed_duplex = ADVERTISE_100_HALF;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_100 + FULL_DUPLEX:
 		DPRINTK(PROBE, INFO, "Forcing to 100 Mbps Full Duplex\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 0;
-		adapter->hw.forced_speed_duplex = e1000_100_full;
+		adapter->hw.forced_speed_duplex = ADVERTISE_100_FULL;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_1000:
