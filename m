From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 01/18] e1000: whitespace changes, comments, typos
Date: Wed, 01 Nov 2006 09:51:30 -0800
Message-ID: <20061101175130.2356.78527.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:13328 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946960AbWKARmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:42:53 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Small whitespace changes, comment changes, typo fixes.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |   27 +++++-----
 drivers/net/e1000/e1000_hw.c      |    6 +-
 drivers/net/e1000/e1000_hw.h      |    5 +-
 drivers/net/e1000/e1000_main.c    |  101 +++++++++++++++++++------------------
 drivers/net/e1000/e1000_osdep.h   |    1 
 5 files changed, 72 insertions(+), 68 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index c564adb..82d2c78 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -133,9 +133,7 @@ e1000_get_settings(struct net_device *ne
 
 		if (hw->autoneg == 1) {
 			ecmd->advertising |= ADVERTISED_Autoneg;
-
 			/* the e1000 autoneg seems to match ethtool nicely */
-
 			ecmd->advertising |= hw->autoneg_advertised;
 		}
 
@@ -285,7 +283,7 @@ e1000_set_pauseparam(struct net_device *
 			e1000_reset(adapter);
 	} else
 		retval = ((hw->media_type == e1000_media_type_fiber) ?
-			   e1000_setup_link(hw) : e1000_force_mac_fc(hw));
+			  e1000_setup_link(hw) : e1000_force_mac_fc(hw));
 
 	clear_bit(__E1000_RESETTING, &adapter->flags);
 	return retval;
@@ -774,7 +772,7 @@ e1000_reg_test(struct e1000_adapter *ada
 	/* The status register is Read Only, so a write should fail.
 	 * Some bits that get toggled are ignored.
 	 */
-        switch (adapter->hw.mac_type) {
+	switch (adapter->hw.mac_type) {
 	/* there are several bits on newer hardware that are r/w */
 	case e1000_82571:
 	case e1000_82572:
@@ -802,12 +800,14 @@ e1000_reg_test(struct e1000_adapter *ada
 	}
 	/* restore previous status */
 	E1000_WRITE_REG(&adapter->hw, STATUS, before);
+
 	if (adapter->hw.mac_type != e1000_ich8lan) {
 		REG_PATTERN_TEST(FCAL, 0xFFFFFFFF, 0xFFFFFFFF);
 		REG_PATTERN_TEST(FCAH, 0x0000FFFF, 0xFFFFFFFF);
 		REG_PATTERN_TEST(FCT, 0x0000FFFF, 0xFFFFFFFF);
 		REG_PATTERN_TEST(VET, 0x0000FFFF, 0xFFFFFFFF);
 	}
+
 	REG_PATTERN_TEST(RDTR, 0x0000FFFF, 0xFFFFFFFF);
 	REG_PATTERN_TEST(RDBAH, 0xFFFFFFFF, 0xFFFFFFFF);
 	REG_PATTERN_TEST(RDLEN, 0x000FFF80, 0x000FFFFF);
@@ -820,8 +820,9 @@ e1000_reg_test(struct e1000_adapter *ada
 	REG_PATTERN_TEST(TDLEN, 0x000FFF80, 0x000FFFFF);
 
 	REG_SET_AND_CHECK(RCTL, 0xFFFFFFFF, 0x00000000);
+
 	before = (adapter->hw.mac_type == e1000_ich8lan ?
-			0x06C3B33E : 0x06DFB3FE);
+	          0x06C3B33E : 0x06DFB3FE);
 	REG_SET_AND_CHECK(RCTL, before, 0x003FFFFB);
 	REG_SET_AND_CHECK(TCTL, 0xFFFFFFFF, 0x00000000);
 
@@ -834,10 +835,10 @@ e1000_reg_test(struct e1000_adapter *ada
 		REG_PATTERN_TEST(TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
 		REG_PATTERN_TEST(TIDV, 0x0000FFFF, 0x0000FFFF);
 		value = (adapter->hw.mac_type == e1000_ich8lan ?
-				E1000_RAR_ENTRIES_ICH8LAN : E1000_RAR_ENTRIES);
+		         E1000_RAR_ENTRIES_ICH8LAN : E1000_RAR_ENTRIES);
 		for (i = 0; i < value; i++) {
 			REG_PATTERN_TEST(RA + (((i << 1) + 1) << 2), 0x8003FFFF,
-					 0xFFFFFFFF);
+			                 0xFFFFFFFF);
 		}
 
 	} else {
@@ -883,8 +884,7 @@ e1000_eeprom_test(struct e1000_adapter *
 }
 
 static irqreturn_t
-e1000_test_intr(int irq,
-		void *data)
+e1000_test_intr(int irq, void *data)
 {
 	struct net_device *netdev = (struct net_device *) data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -905,11 +905,11 @@ e1000_intr_test(struct e1000_adapter *ad
 
 	/* NOTE: we don't test MSI interrupts here, yet */
 	/* Hook up test interrupt handler just for this test */
-	if (!request_irq(irq, &e1000_test_intr, IRQF_PROBE_SHARED,
-			 netdev->name, netdev))
+	if (!request_irq(irq, &e1000_test_intr, IRQF_PROBE_SHARED, netdev->name,
+	                 netdev))
 		shared_int = FALSE;
 	else if (request_irq(irq, &e1000_test_intr, IRQF_SHARED,
-			      netdev->name, netdev)) {
+	         netdev->name, netdev)) {
 		*data = 1;
 		return -1;
 	}
@@ -925,6 +925,7 @@ e1000_intr_test(struct e1000_adapter *ad
 
 		if (adapter->hw.mac_type == e1000_ich8lan && i == 8)
 			continue;
+
 		/* Interrupt to test */
 		mask = 1 << i;
 
@@ -1674,7 +1675,7 @@ e1000_diag_test(struct net_device *netde
 		if (e1000_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		/* Offline tests aren't run; pass by default */
+		/* Online tests aren't run; pass by default */
 		data[0] = 0;
 		data[1] = 0;
 		data[2] = 0;
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 65077f3..a0a3c7e 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -2367,6 +2367,7 @@ e1000_phy_force_speed_duplex(struct e100
 
         /* Need to reset the PHY or these changes will be ignored */
         mii_ctrl_reg |= MII_CR_RESET;
+
     /* Disable MDI-X support for 10/100 */
     } else if (hw->phy_type == e1000_phy_ife) {
         ret_val = e1000_read_phy_reg(hw, IFE_PHY_MDIX_CONTROL, &phy_data);
@@ -2379,6 +2380,7 @@ e1000_phy_force_speed_duplex(struct e100
         ret_val = e1000_write_phy_reg(hw, IFE_PHY_MDIX_CONTROL, phy_data);
         if (ret_val)
             return ret_val;
+
     } else {
         /* Clear Auto-Crossover to force MDI manually.  IGP requires MDI
          * forced whenever speed or duplex are forced.
@@ -5841,6 +5843,7 @@ e1000_mta_set(struct e1000_hw *hw,
     hash_reg = (hash_value >> 5) & 0x7F;
     if (hw->mac_type == e1000_ich8lan)
         hash_reg &= 0x1F;
+
     hash_bit = hash_value & 0x1F;
 
     mta = E1000_READ_REG_ARRAY(hw, MTA, hash_reg);
@@ -6026,6 +6029,7 @@ e1000_id_led_init(struct e1000_hw * hw)
         else
             eeprom_data = ID_LED_DEFAULT;
     }
+
     for (i = 0; i < 4; i++) {
         temp = (eeprom_data >> (i << 2)) & led_mask;
         switch (temp) {
@@ -9013,5 +9017,3 @@ e1000_init_lcd_from_nvm(struct e1000_hw 
     return E1000_SUCCESS;
 }
 
-
-
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 449a603..b32a0c3 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -326,6 +326,7 @@ int32_t e1000_phy_hw_reset(struct e1000_
 int32_t e1000_phy_reset(struct e1000_hw *hw);
 int32_t e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
 int32_t e1000_validate_mdi_setting(struct e1000_hw *hw);
+
 void e1000_phy_powerdown_workaround(struct e1000_hw *hw);
 
 /* EEPROM Functions */
@@ -390,7 +391,6 @@ int32_t e1000_mng_write_dhcp_info(struct
                                   uint16_t length);
 boolean_t e1000_check_mng_mode(struct e1000_hw *hw);
 boolean_t e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
-
 int32_t e1000_read_eeprom(struct e1000_hw *hw, uint16_t reg, uint16_t words, uint16_t *data);
 int32_t e1000_validate_eeprom_checksum(struct e1000_hw *hw);
 int32_t e1000_update_eeprom_checksum(struct e1000_hw *hw);
@@ -576,6 +576,7 @@ int32_t e1000_check_phy_reset_block(stru
  * E1000_RAR_ENTRIES - 1 multicast addresses.
  */
 #define E1000_RAR_ENTRIES 15
+
 #define E1000_RAR_ENTRIES_ICH8LAN  6
 
 #define MIN_NUMBER_OF_DESCRIPTORS  8
@@ -1335,9 +1336,9 @@ struct e1000_hw_stats {
     uint64_t gotch;
     uint64_t rnbc;
     uint64_t ruc;
+    uint64_t rfc;
     uint64_t roc;
     uint64_t rlerrc;
-    uint64_t rfc;
     uint64_t rjc;
     uint64_t mgprc;
     uint64_t mgpdc;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8d04752..7ec2dd5 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -375,7 +375,7 @@ e1000_update_mng_vlan(struct e1000_adapt
  * e1000_release_hw_control resets {CTRL_EXT|FWSM}:DRV_LOAD bit.
  * For ASF and Pass Through versions of f/w this means that the
  * driver is no longer loaded. For AMT version (only with 82573) i
- * of the f/w this means that the netowrk i/f is closed.
+ * of the f/w this means that the network i/f is closed.
  *
  **/
 
@@ -416,7 +416,7 @@ e1000_release_hw_control(struct e1000_ad
  * e1000_get_hw_control sets {CTRL_EXT|FWSM}:DRV_LOAD bit.
  * For ASF and Pass Through versions of f/w this means that
  * the driver is loaded. For AMT version (only with 82573)
- * of the f/w this means that the netowrk i/f is open.
+ * of the f/w this means that the network i/f is open.
  *
  **/
 
@@ -426,6 +426,7 @@ e1000_get_hw_control(struct e1000_adapte
 	uint32_t ctrl_ext;
 	uint32_t swsm;
 	uint32_t extcnf;
+
 	/* Let firmware know the driver has taken over */
 	switch (adapter->hw.mac_type) {
 	case e1000_82571:
@@ -1279,12 +1280,10 @@ e1000_open(struct net_device *netdev)
 		return -EBUSY;
 
 	/* allocate transmit descriptors */
-
 	if ((err = e1000_setup_all_tx_resources(adapter)))
 		goto err_setup_tx;
 
 	/* allocate receive descriptors */
-
 	if ((err = e1000_setup_all_rx_resources(adapter)))
 		goto err_setup_rx;
 
@@ -1569,6 +1568,8 @@ e1000_configure_tx(struct e1000_adapter 
 
 	if (hw->mac_type == e1000_82571 || hw->mac_type == e1000_82572) {
 		tarc = E1000_READ_REG(hw, TARC0);
+		/* set the speed mode bit, we'll clear it if we're not at
+		 * gigabit link later */
 		tarc |= (1 << 21);
 		E1000_WRITE_REG(hw, TARC0, tarc);
 	} else if (hw->mac_type == e1000_80003es2lan) {
@@ -2418,6 +2419,7 @@ e1000_watchdog(unsigned long data)
 		DPRINTK(LINK, INFO,
 			"Gigabit has been disabled, downgrading speed\n");
 	}
+
 	if (adapter->hw.mac_type == e1000_82573) {
 		e1000_enable_tx_pkt_filtering(&adapter->hw);
 		if (adapter->mng_vlan_id != adapter->hw.mng_cookie.vlan_id)
@@ -2462,13 +2464,12 @@ e1000_watchdog(unsigned long data)
 			if ((adapter->hw.mac_type == e1000_82571 ||
 			     adapter->hw.mac_type == e1000_82572) &&
 			    txb2b == 0) {
-#define SPEED_MODE_BIT (1 << 21)
 				uint32_t tarc0;
 				tarc0 = E1000_READ_REG(&adapter->hw, TARC0);
-				tarc0 &= ~SPEED_MODE_BIT;
+				tarc0 &= ~(1 << 21);
 				E1000_WRITE_REG(&adapter->hw, TARC0, tarc0);
 			}
-				
+
 #ifdef NETIF_F_TSO
 			/* disable TSO for pcie and 10/100 speeds, to avoid
 			 * some hardware issues */
@@ -3010,9 +3011,9 @@ e1000_xmit_frame(struct sk_buff *skb, st
 		max_per_txd = min(mss << 2, max_per_txd);
 		max_txd_pwr = fls(max_per_txd) - 1;
 
-	/* TSO Workaround for 82571/2/3 Controllers -- if skb->data
-	 * points to just header, pull a few bytes of payload from
-	 * frags into skb->data */
+		/* TSO Workaround for 82571/2/3 Controllers -- if skb->data
+		* points to just header, pull a few bytes of payload from
+		* frags into skb->data */
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
 		if (skb->data_len && (hdr_len == (skb->len - skb->data_len))) {
 			switch (adapter->hw.mac_type) {
@@ -3316,12 +3317,12 @@ e1000_update_stats(struct e1000_adapter 
 	adapter->stats.roc += E1000_READ_REG(hw, ROC);
 
 	if (adapter->hw.mac_type != e1000_ich8lan) {
-	adapter->stats.prc64 += E1000_READ_REG(hw, PRC64);
-	adapter->stats.prc127 += E1000_READ_REG(hw, PRC127);
-	adapter->stats.prc255 += E1000_READ_REG(hw, PRC255);
-	adapter->stats.prc511 += E1000_READ_REG(hw, PRC511);
-	adapter->stats.prc1023 += E1000_READ_REG(hw, PRC1023);
-	adapter->stats.prc1522 += E1000_READ_REG(hw, PRC1522);
+		adapter->stats.prc64 += E1000_READ_REG(hw, PRC64);
+		adapter->stats.prc127 += E1000_READ_REG(hw, PRC127);
+		adapter->stats.prc255 += E1000_READ_REG(hw, PRC255);
+		adapter->stats.prc511 += E1000_READ_REG(hw, PRC511);
+		adapter->stats.prc1023 += E1000_READ_REG(hw, PRC1023);
+		adapter->stats.prc1522 += E1000_READ_REG(hw, PRC1522);
 	}
 
 	adapter->stats.symerrs += E1000_READ_REG(hw, SYMERRS);
@@ -3352,12 +3353,12 @@ e1000_update_stats(struct e1000_adapter 
 	adapter->stats.tpr += E1000_READ_REG(hw, TPR);
 
 	if (adapter->hw.mac_type != e1000_ich8lan) {
-	adapter->stats.ptc64 += E1000_READ_REG(hw, PTC64);
-	adapter->stats.ptc127 += E1000_READ_REG(hw, PTC127);
-	adapter->stats.ptc255 += E1000_READ_REG(hw, PTC255);
-	adapter->stats.ptc511 += E1000_READ_REG(hw, PTC511);
-	adapter->stats.ptc1023 += E1000_READ_REG(hw, PTC1023);
-	adapter->stats.ptc1522 += E1000_READ_REG(hw, PTC1522);
+		adapter->stats.ptc64 += E1000_READ_REG(hw, PTC64);
+		adapter->stats.ptc127 += E1000_READ_REG(hw, PTC127);
+		adapter->stats.ptc255 += E1000_READ_REG(hw, PTC255);
+		adapter->stats.ptc511 += E1000_READ_REG(hw, PTC511);
+		adapter->stats.ptc1023 += E1000_READ_REG(hw, PTC1023);
+		adapter->stats.ptc1522 += E1000_READ_REG(hw, PTC1522);
 	}
 
 	adapter->stats.mptc += E1000_READ_REG(hw, MPTC);
@@ -3383,18 +3384,17 @@ e1000_update_stats(struct e1000_adapter 
 		adapter->stats.icrxoc += E1000_READ_REG(hw, ICRXOC);
 
 		if (adapter->hw.mac_type != e1000_ich8lan) {
-		adapter->stats.icrxptc += E1000_READ_REG(hw, ICRXPTC);
-		adapter->stats.icrxatc += E1000_READ_REG(hw, ICRXATC);
-		adapter->stats.ictxptc += E1000_READ_REG(hw, ICTXPTC);
-		adapter->stats.ictxatc += E1000_READ_REG(hw, ICTXATC);
-		adapter->stats.ictxqec += E1000_READ_REG(hw, ICTXQEC);
-		adapter->stats.ictxqmtc += E1000_READ_REG(hw, ICTXQMTC);
-		adapter->stats.icrxdmtc += E1000_READ_REG(hw, ICRXDMTC);
+			adapter->stats.icrxptc += E1000_READ_REG(hw, ICRXPTC);
+			adapter->stats.icrxatc += E1000_READ_REG(hw, ICRXATC);
+			adapter->stats.ictxptc += E1000_READ_REG(hw, ICTXPTC);
+			adapter->stats.ictxatc += E1000_READ_REG(hw, ICTXATC);
+			adapter->stats.ictxqec += E1000_READ_REG(hw, ICTXQEC);
+			adapter->stats.ictxqmtc += E1000_READ_REG(hw, ICTXQMTC);
+			adapter->stats.icrxdmtc += E1000_READ_REG(hw, ICRXDMTC);
 		}
 	}
 
 	/* Fill out the OS statistics structure */
-
 	adapter->net_stats.rx_packets = adapter->stats.gprc;
 	adapter->net_stats.tx_packets = adapter->stats.gptc;
 	adapter->net_stats.rx_bytes = adapter->stats.gorcl;
@@ -3426,7 +3426,6 @@ e1000_update_stats(struct e1000_adapter 
 	/* Tx Dropped needs to be maintained elsewhere */
 
 	/* Phy Stats */
-
 	if (hw->media_type == e1000_media_type_copper) {
 		if ((adapter->link_speed == SPEED_1000) &&
 		   (!e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_tmp))) {
@@ -3502,6 +3501,8 @@ e1000_intr(int irq, void *data)
 	if (likely(netif_rx_schedule_prep(netdev)))
 		__netif_rx_schedule(netdev);
 	else
+		/* this really should not happen! if it does it is basically a
+		 * bug, but not a hard error, so enable ints and continue */
 		e1000_irq_enable(adapter);
 #else
 	/* Writing IMC and IMS is needed for 82547.
@@ -3528,7 +3529,6 @@ e1000_intr(int irq, void *data)
 		e1000_irq_enable(adapter);
 
 #endif
-
 	return IRQ_HANDLED;
 }
 
@@ -3615,7 +3615,6 @@ e1000_clean_tx_irq(struct e1000_adapter 
 			if (unlikely(++i == tx_ring->count)) i = 0;
 		}
 
-
 		eop = tx_ring->buffer_info[i].next_to_watch;
 		eop_desc = E1000_TX_DESC(*tx_ring, eop);
 #ifdef CONFIG_E1000_NAPI
@@ -3760,6 +3759,7 @@ e1000_clean_rx_irq(struct e1000_adapter 
 	while (rx_desc->status & E1000_RXD_STAT_DD) {
 		struct sk_buff *skb;
 		u8 status;
+
 #ifdef CONFIG_E1000_NAPI
 		if (*work_done >= work_to_do)
 			break;
@@ -3999,7 +3999,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 			goto copydone;
 		} /* if */
 		}
-		
+
 		for (j = 0; j < adapter->rx_ps_pages; j++) {
 			if (!(length= le16_to_cpu(rx_desc->wb.upper.length[j])))
 				break;
@@ -4234,7 +4234,7 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
 		}
 
 		skb = netdev_alloc_skb(netdev,
-				       adapter->rx_ps_bsize0 + NET_IP_ALIGN);
+		                       adapter->rx_ps_bsize0 + NET_IP_ALIGN);
 
 		if (unlikely(!skb)) {
 			adapter->alloc_rx_buff_failed++;
@@ -4511,7 +4511,6 @@ e1000_read_pcie_cap_reg(struct e1000_hw 
     return E1000_SUCCESS;
 }
 
-
 void
 e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value)
 {
@@ -4534,12 +4533,12 @@ e1000_vlan_rx_register(struct net_device
 		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
 
 		if (adapter->hw.mac_type != e1000_ich8lan) {
-		/* enable VLAN receive filtering */
-		rctl = E1000_READ_REG(&adapter->hw, RCTL);
-		rctl |= E1000_RCTL_VFE;
-		rctl &= ~E1000_RCTL_CFIEN;
-		E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
-		e1000_update_mng_vlan(adapter);
+			/* enable VLAN receive filtering */
+			rctl = E1000_READ_REG(&adapter->hw, RCTL);
+			rctl |= E1000_RCTL_VFE;
+			rctl &= ~E1000_RCTL_CFIEN;
+			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+			e1000_update_mng_vlan(adapter);
 		}
 	} else {
 		/* disable VLAN tag insert/strip */
@@ -4548,14 +4547,16 @@ e1000_vlan_rx_register(struct net_device
 		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
 
 		if (adapter->hw.mac_type != e1000_ich8lan) {
-		/* disable VLAN filtering */
-		rctl = E1000_READ_REG(&adapter->hw, RCTL);
-		rctl &= ~E1000_RCTL_VFE;
-		E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
-		if (adapter->mng_vlan_id != (uint16_t)E1000_MNG_VLAN_NONE) {
-			e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
-			adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
-		}
+			/* disable VLAN filtering */
+			rctl = E1000_READ_REG(&adapter->hw, RCTL);
+			rctl &= ~E1000_RCTL_VFE;
+			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+			if (adapter->mng_vlan_id !=
+			    (uint16_t)E1000_MNG_VLAN_NONE) {
+				e1000_vlan_rx_kill_vid(netdev,
+				                       adapter->mng_vlan_id);
+				adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
+			}
 		}
 	}
 
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index a464cb2..3b7eb7c 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -119,5 +119,4 @@ typedef enum {
 #define E1000_READ_ICH8_REG16(a, reg) ( \
     readw((a)->flash_address + reg))
 
-
 #endif /* _E1000_OSDEP_H_ */



---
Auke Kok <auke-jan.h.kok@intel.com>
