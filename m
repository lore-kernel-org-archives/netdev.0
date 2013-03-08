From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] e1000e: cleanup unnecessary line breaks
Date: Fri,  8 Mar 2013 02:07:14 -0800
Message-ID: <1362737237-13363-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51324 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934011Ab3CHKHf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 05:07:35 -0500
In-Reply-To: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Cuddle broken lines where appropriate.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c   |  6 +--
 drivers/net/ethernet/intel/e1000e/ethtool.c | 12 ++----
 drivers/net/ethernet/intel/e1000e/ich8lan.c |  9 ++---
 drivers/net/ethernet/intel/e1000e/netdev.c  | 60 ++++++++++-------------------
 drivers/net/ethernet/intel/e1000e/phy.c     |  6 +--
 5 files changed, 31 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 49bce4e..c0477fb 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -876,8 +876,7 @@ static s32 e1000_get_cfg_done_82571(struct e1000_hw *hw)
 	s32 timeout = PHY_CFG_TIMEOUT;
 
 	while (timeout) {
-		if (er32(EEMNGCTL) &
-		    E1000_NVM_CFG_DONE_PORT_0)
+		if (er32(EEMNGCTL) & E1000_NVM_CFG_DONE_PORT_0)
 			break;
 		usleep_range(1000, 2000);
 		timeout--;
@@ -1124,8 +1123,7 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 	/* Set the transmit descriptor write-back policy */
 	reg_data = er32(TXDCTL(0));
 	reg_data = ((reg_data & ~E1000_TXDCTL_WTHRESH) |
-		    E1000_TXDCTL_FULL_TX_DESC_WB |
-		    E1000_TXDCTL_COUNT_DESC);
+		    E1000_TXDCTL_FULL_TX_DESC_WB | E1000_TXDCTL_COUNT_DESC);
 	ew32(TXDCTL(0), reg_data);
 
 	/* ...for both queues. */
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index a63cb59..e43c944 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -223,8 +223,7 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
 
 	/* Fiber NICs only allow 1000 gbps Full duplex */
 	if ((adapter->hw.phy.media_type == e1000_media_type_fiber) &&
-	    spd != SPEED_1000 &&
-	    dplx != DUPLEX_FULL) {
+	    (spd != SPEED_1000) && (dplx != DUPLEX_FULL)) {
 		goto err_inval;
 	}
 
@@ -616,8 +615,7 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	strlcpy(drvinfo->driver,  e1000e_driver_name,
-		sizeof(drvinfo->driver));
+	strlcpy(drvinfo->driver, e1000e_driver_name, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, e1000e_driver_version,
 		sizeof(drvinfo->version));
 
@@ -1143,8 +1141,7 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		tx_ring->count = E1000_DEFAULT_TXD;
 
 	tx_ring->buffer_info = kcalloc(tx_ring->count,
-				       sizeof(struct e1000_buffer),
-				       GFP_KERNEL);
+				       sizeof(struct e1000_buffer), GFP_KERNEL);
 	if (!tx_ring->buffer_info) {
 		ret_val = 1;
 		goto err_nomem;
@@ -1205,8 +1202,7 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		rx_ring->count = E1000_DEFAULT_RXD;
 
 	rx_ring->buffer_info = kcalloc(rx_ring->count,
-				       sizeof(struct e1000_buffer),
-				       GFP_KERNEL);
+				       sizeof(struct e1000_buffer), GFP_KERNEL);
 	if (!rx_ring->buffer_info) {
 		ret_val = 5;
 		goto err_nomem;
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index d249db9..0ed04fc 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1379,8 +1379,7 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 	word_addr = (u16)(cnf_base_addr << 1);
 
 	for (i = 0; i < cnf_size; i++) {
-		ret_val = e1000_read_nvm(hw, (word_addr + i * 2), 1,
-					 &reg_data);
+		ret_val = e1000_read_nvm(hw, (word_addr + i * 2), 1, &reg_data);
 		if (ret_val)
 			goto release;
 
@@ -3211,8 +3210,7 @@ static s32 e1000_valid_led_default_ich8lan(struct e1000_hw *hw, u16 *data)
 		return ret_val;
 	}
 
-	if (*data == ID_LED_RESERVED_0000 ||
-	    *data == ID_LED_RESERVED_FFFF)
+	if (*data == ID_LED_RESERVED_0000 || *data == ID_LED_RESERVED_FFFF)
 		*data = ID_LED_DEFAULT_ICH8LAN;
 
 	return 0;
@@ -3756,8 +3754,7 @@ static s32 e1000_get_link_up_info_ich8lan(struct e1000_hw *hw, u16 *speed,
 		return ret_val;
 
 	if ((hw->mac.type == e1000_ich8lan) &&
-	    (hw->phy.type == e1000_phy_igp_3) &&
-	    (*speed == SPEED_1000)) {
+	    (hw->phy.type == e1000_phy_igp_3) && (*speed == SPEED_1000)) {
 		ret_val = e1000_kmrn_lock_loss_workaround_ich8lan(hw);
 	}
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 5337137..b085ce1 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -219,9 +219,8 @@ static void e1000e_dump(struct e1000_adapter *adapter)
 	if (netdev) {
 		dev_info(&adapter->pdev->dev, "Net device Info\n");
 		pr_info("Device Name     state            trans_start      last_rx\n");
-		pr_info("%-15s %016lX %016lX %016lX\n",
-			netdev->name, netdev->state, netdev->trans_start,
-			netdev->last_rx);
+		pr_info("%-15s %016lX %016lX %016lX\n", netdev->name,
+			netdev->state, netdev->trans_start, netdev->last_rx);
 	}
 
 	/* Print Registers */
@@ -755,8 +754,7 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_ring *rx_ring,
 			    cpu_to_le64(ps_page->dma);
 		}
 
-		skb = __netdev_alloc_skb_ip_align(netdev,
-						  adapter->rx_ps_bsize0,
+		skb = __netdev_alloc_skb_ip_align(netdev, adapter->rx_ps_bsize0,
 						  gfp);
 
 		if (!skb) {
@@ -937,10 +935,8 @@ static bool e1000_clean_rx_irq(struct e1000_ring *rx_ring, int *work_done,
 
 		cleaned = true;
 		cleaned_count++;
-		dma_unmap_single(&pdev->dev,
-				 buffer_info->dma,
-				 adapter->rx_buffer_len,
-				 DMA_FROM_DEVICE);
+		dma_unmap_single(&pdev->dev, buffer_info->dma,
+				 adapter->rx_buffer_len, DMA_FROM_DEVICE);
 		buffer_info->dma = 0;
 
 		length = le16_to_cpu(rx_desc->wb.upper.length);
@@ -1082,8 +1078,7 @@ static void e1000_print_hw_hang(struct work_struct *work)
 	if (test_bit(__E1000_DOWN, &adapter->state))
 		return;
 
-	if (!adapter->tx_hang_recheck &&
-	    (adapter->flags2 & FLAG2_DMA_BURST)) {
+	if (!adapter->tx_hang_recheck && (adapter->flags2 & FLAG2_DMA_BURST)) {
 		/* May be block on write-back, flush and detect again
 		 * flush pending descriptor writebacks to memory
 		 */
@@ -1125,19 +1120,10 @@ static void e1000_print_hw_hang(struct work_struct *work)
 	      "PHY 1000BASE-T Status  <%x>\n"
 	      "PHY Extended Status    <%x>\n"
 	      "PCI Status             <%x>\n",
-	      readl(tx_ring->head),
-	      readl(tx_ring->tail),
-	      tx_ring->next_to_use,
-	      tx_ring->next_to_clean,
-	      tx_ring->buffer_info[eop].time_stamp,
-	      eop,
-	      jiffies,
-	      eop_desc->upper.fields.status,
-	      er32(STATUS),
-	      phy_status,
-	      phy_1000t_status,
-	      phy_ext_status,
-	      pci_status);
+	      readl(tx_ring->head), readl(tx_ring->tail), tx_ring->next_to_use,
+	      tx_ring->next_to_clean, tx_ring->buffer_info[eop].time_stamp,
+	      eop, jiffies, eop_desc->upper.fields.status, er32(STATUS),
+	      phy_status, phy_1000t_status, phy_ext_status, pci_status);
 
 	/* Suggest workaround for known h/w issue */
 	if ((hw->mac.type == e1000_pchlan) && (er32(CTRL) & E1000_CTRL_TFCE))
@@ -2811,8 +2797,7 @@ static void e1000_update_mng_vlan(struct e1000_adapter *adapter)
 	u16 vid = adapter->hw.mng_cookie.vlan_id;
 	u16 old_vid = adapter->mng_vlan_id;
 
-	if (adapter->hw.mng_cookie.status &
-	    E1000_MNG_DHCP_COOKIE_STATUS_VLAN) {
+	if (adapter->hw.mng_cookie.status & E1000_MNG_DHCP_COOKIE_STATUS_VLAN) {
 		e1000_vlan_rx_add_vid(netdev, vid);
 		adapter->mng_vlan_id = vid;
 	}
@@ -3090,19 +3075,17 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 		/* Enable Packet split descriptors */
 		rctl |= E1000_RCTL_DTYP_PS;
 
-		psrctl |= adapter->rx_ps_bsize0 >>
-			E1000_PSRCTL_BSIZE0_SHIFT;
+		psrctl |= adapter->rx_ps_bsize0 >> E1000_PSRCTL_BSIZE0_SHIFT;
 
 		switch (adapter->rx_ps_pages) {
 		case 3:
-			psrctl |= PAGE_SIZE <<
-				E1000_PSRCTL_BSIZE3_SHIFT;
+			psrctl |= PAGE_SIZE << E1000_PSRCTL_BSIZE3_SHIFT;
+			/* fall-through */
 		case 2:
-			psrctl |= PAGE_SIZE <<
-				E1000_PSRCTL_BSIZE2_SHIFT;
+			psrctl |= PAGE_SIZE << E1000_PSRCTL_BSIZE2_SHIFT;
+			/* fall-through */
 		case 1:
-			psrctl |= PAGE_SIZE >>
-				E1000_PSRCTL_BSIZE1_SHIFT;
+			psrctl |= PAGE_SIZE >> E1000_PSRCTL_BSIZE1_SHIFT;
 			break;
 		}
 
@@ -3753,8 +3736,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		 * but don't include ethernet FCS because hardware appends it
 		 */
 		min_tx_space = (adapter->max_frame_size +
-				sizeof(struct e1000_tx_desc) -
-				ETH_FCS_LEN) * 2;
+				sizeof(struct e1000_tx_desc) - ETH_FCS_LEN) * 2;
 		min_tx_space = ALIGN(min_tx_space, 1024);
 		min_tx_space >>= 10;
 		/* software strips receive CRC, so leave room for it */
@@ -4262,8 +4244,7 @@ static int e1000_open(struct net_device *netdev)
 	e1000e_power_up_phy(adapter);
 
 	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
-	if ((adapter->hw.mng_cookie.status &
-	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN))
+	if ((adapter->hw.mng_cookie.status & E1000_MNG_DHCP_COOKIE_STATUS_VLAN))
 		e1000_update_mng_vlan(adapter);
 
 	/* DMA latency requirement to workaround jumbo issue */
@@ -4365,8 +4346,7 @@ static int e1000_close(struct net_device *netdev)
 	/* kill manageability vlan ID if supported, but not if a vlan with
 	 * the same ID is registered on the host OS (let 8021q kill it)
 	 */
-	if (adapter->hw.mng_cookie.status &
-	    E1000_MNG_DHCP_COOKIE_STATUS_VLAN)
+	if (adapter->hw.mng_cookie.status & E1000_MNG_DHCP_COOKIE_STATUS_VLAN)
 		e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
 
 	/* If AMT is enabled, let the firmware know that the network
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index e071ef7..9b3d167 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -71,8 +71,7 @@ s32 e1000e_check_reset_block_generic(struct e1000_hw *hw)
 
 	manc = er32(MANC);
 
-	return (manc & E1000_MANC_BLK_PHY_RST_ON_IDE) ?
-	       E1000_BLK_PHY_RESET : 0;
+	return (manc & E1000_MANC_BLK_PHY_RST_ON_IDE) ? E1000_BLK_PHY_RESET : 0;
 }
 
 /**
@@ -775,8 +774,7 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 
 		phy_data |= M88E1000_EPSCR_TX_CLK_25;
 
-		if ((phy->revision == 2) &&
-		    (phy->id == M88E1111_I_PHY_ID)) {
+		if ((phy->revision == 2) && (phy->id == M88E1111_I_PHY_ID)) {
 			/* 82573L PHY - set the downshift counter to 5x. */
 			phy_data &= ~M88EC018_EPSCR_DOWNSHIFT_COUNTER_MASK;
 			phy_data |= M88EC018_EPSCR_DOWNSHIFT_COUNTER_5X;
-- 
1.7.11.7
