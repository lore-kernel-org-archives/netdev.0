From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 14/25] ixgb: format all if( to be if (
Date: Tue, 08 Jul 2008 15:52:13 -0700
Message-ID: <20080708225213.6925.19171.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53842 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754021AbYGHWwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:52:14 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

this patch is trivial but because I want to have everything be nice and
tidy I'm updating it.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_ee.c      |    8 +-
 drivers/net/ixgb/ixgb_ethtool.c |   68 +++++++++----------
 drivers/net/ixgb/ixgb_hw.c      |   13 ++--
 drivers/net/ixgb/ixgb_main.c    |  141 +++++++++++++++++++--------------------
 drivers/net/ixgb/ixgb_osdep.h   |    2 -
 drivers/net/ixgb/ixgb_param.c   |   30 ++++----
 6 files changed, 130 insertions(+), 132 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index 2f7ed52..ba41d2a 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -108,7 +108,7 @@ ixgb_shift_out_bits(struct ixgb_hw *hw,
 		 */
 		eecd_reg &= ~IXGB_EECD_DI;
 
-		if(data & mask)
+		if (data & mask)
 			eecd_reg |= IXGB_EECD_DI;
 
 		IXGB_WRITE_REG(hw, EECD, eecd_reg);
@@ -159,7 +159,7 @@ ixgb_shift_in_bits(struct ixgb_hw *hw)
 		eecd_reg = IXGB_READ_REG(hw, EECD);
 
 		eecd_reg &= ~(IXGB_EECD_DI);
-		if(eecd_reg & IXGB_EECD_DO)
+		if (eecd_reg & IXGB_EECD_DO)
 			data |= 1;
 
 		ixgb_lower_clock(hw, &eecd_reg);
@@ -300,7 +300,7 @@ ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 	for(i = 0; i < 200; i++) {
 		eecd_reg = IXGB_READ_REG(hw, EECD);
 
-		if(eecd_reg & IXGB_EECD_DO)
+		if (eecd_reg & IXGB_EECD_DO)
 			return (true);
 
 		udelay(50);
@@ -331,7 +331,7 @@ ixgb_validate_eeprom_checksum(struct ixgb_hw *hw)
 	for(i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++)
 		checksum += ixgb_read_eeprom(hw, i);
 
-	if(checksum == (u16) EEPROM_SUM)
+	if (checksum == (u16) EEPROM_SUM)
 		return (true);
 	else
 		return (false);
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 8464d8a..7c9b35c 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -95,7 +95,7 @@ ixgb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	ecmd->port = PORT_FIBRE;
 	ecmd->transceiver = XCVR_EXTERNAL;
 
-	if(netif_carrier_ok(adapter->netdev)) {
+	if (netif_carrier_ok(adapter->netdev)) {
 		ecmd->speed = SPEED_10000;
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
@@ -122,11 +122,11 @@ ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
-	if(ecmd->autoneg == AUTONEG_ENABLE ||
+	if (ecmd->autoneg == AUTONEG_ENABLE ||
 	   ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
 		return -EINVAL;
 	
-	if(netif_running(adapter->netdev)) {
+	if (netif_running(adapter->netdev)) {
 		ixgb_down(adapter, true);
 		ixgb_reset(adapter);
 		ixgb_up(adapter);
@@ -146,11 +146,11 @@ ixgb_get_pauseparam(struct net_device *netdev,
 	
 	pause->autoneg = AUTONEG_DISABLE;
 		
-	if(hw->fc.type == ixgb_fc_rx_pause)
+	if (hw->fc.type == ixgb_fc_rx_pause)
 		pause->rx_pause = 1;
-	else if(hw->fc.type == ixgb_fc_tx_pause)
+	else if (hw->fc.type == ixgb_fc_tx_pause)
 		pause->tx_pause = 1;
-	else if(hw->fc.type == ixgb_fc_full) {
+	else if (hw->fc.type == ixgb_fc_full) {
 		pause->rx_pause = 1;
 		pause->tx_pause = 1;
 	}
@@ -163,19 +163,19 @@ ixgb_set_pauseparam(struct net_device *netdev,
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
 	
-	if(pause->autoneg == AUTONEG_ENABLE)
+	if (pause->autoneg == AUTONEG_ENABLE)
 		return -EINVAL;
 
-	if(pause->rx_pause && pause->tx_pause)
+	if (pause->rx_pause && pause->tx_pause)
 		hw->fc.type = ixgb_fc_full;
-	else if(pause->rx_pause && !pause->tx_pause)
+	else if (pause->rx_pause && !pause->tx_pause)
 		hw->fc.type = ixgb_fc_rx_pause;
-	else if(!pause->rx_pause && pause->tx_pause)
+	else if (!pause->rx_pause && pause->tx_pause)
 		hw->fc.type = ixgb_fc_tx_pause;
-	else if(!pause->rx_pause && !pause->tx_pause)
+	else if (!pause->rx_pause && !pause->tx_pause)
 		hw->fc.type = ixgb_fc_none;
 
-	if(netif_running(adapter->netdev)) {
+	if (netif_running(adapter->netdev)) {
 		ixgb_down(adapter, true);
 		ixgb_up(adapter);
 		ixgb_set_speed_duplex(netdev);
@@ -200,7 +200,7 @@ ixgb_set_rx_csum(struct net_device *netdev, u32 data)
 
 	adapter->rx_csum = data;
 
-	if(netif_running(netdev)) {
+	if (netif_running(netdev)) {
 		ixgb_down(adapter, true);
 		ixgb_up(adapter);
 		ixgb_set_speed_duplex(netdev);
@@ -229,7 +229,7 @@ ixgb_set_tx_csum(struct net_device *netdev, u32 data)
 static int
 ixgb_set_tso(struct net_device *netdev, u32 data)
 {
-	if(data)
+	if (data)
 		netdev->features |= NETIF_F_TSO;
 	else
 		netdev->features &= ~NETIF_F_TSO;
@@ -415,7 +415,7 @@ ixgb_get_eeprom(struct net_device *netdev,
 	int i, max_len, first_word, last_word;
 	int ret_val = 0;
 
-	if(eeprom->len == 0) {
+	if (eeprom->len == 0) {
 		ret_val = -EINVAL;
 		goto geeprom_error;
 	}
@@ -424,12 +424,12 @@ ixgb_get_eeprom(struct net_device *netdev,
 
 	max_len = ixgb_get_eeprom_len(netdev);
 
-	if(eeprom->offset > eeprom->offset + eeprom->len) {
+	if (eeprom->offset > eeprom->offset + eeprom->len) {
 		ret_val = -EINVAL;
 		goto geeprom_error;
 	}
 
-	if((eeprom->offset + eeprom->len) > max_len)
+	if ((eeprom->offset + eeprom->len) > max_len)
 		eeprom->len = (max_len - eeprom->offset);
 
 	first_word = eeprom->offset >> 1;
@@ -437,7 +437,7 @@ ixgb_get_eeprom(struct net_device *netdev,
 
 	eeprom_buff = kmalloc(sizeof(__le16) *
 			(last_word - first_word + 1), GFP_KERNEL);
-	if(!eeprom_buff)
+	if (!eeprom_buff)
 		return -ENOMEM;
 
 	/* note the eeprom was good because the driver loaded */
@@ -464,35 +464,35 @@ ixgb_set_eeprom(struct net_device *netdev,
 	int max_len, first_word, last_word;
 	u16 i;
 
-	if(eeprom->len == 0)
+	if (eeprom->len == 0)
 		return -EINVAL;
 
-	if(eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
+	if (eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
 		return -EFAULT;
 
 	max_len = ixgb_get_eeprom_len(netdev);
 
-	if(eeprom->offset > eeprom->offset + eeprom->len)
+	if (eeprom->offset > eeprom->offset + eeprom->len)
 		return -EINVAL;
 
-	if((eeprom->offset + eeprom->len) > max_len)
+	if ((eeprom->offset + eeprom->len) > max_len)
 		eeprom->len = (max_len - eeprom->offset);
 
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
 	eeprom_buff = kmalloc(max_len, GFP_KERNEL);
-	if(!eeprom_buff)
+	if (!eeprom_buff)
 		return -ENOMEM;
 
 	ptr = (void *)eeprom_buff;
 
-	if(eeprom->offset & 1) {
+	if (eeprom->offset & 1) {
 		/* need read/modify/write of first changed EEPROM word */
 		/* only the second byte of the word is being modified */
 		eeprom_buff[0] = ixgb_read_eeprom(hw, first_word);
 		ptr++;
 	}
-	if((eeprom->offset + eeprom->len) & 1) {
+	if ((eeprom->offset + eeprom->len) & 1) {
 		/* need read/modify/write of last changed EEPROM word */
 		/* only the first byte of the word is being modified */
 		eeprom_buff[last_word - first_word] 
@@ -504,7 +504,7 @@ ixgb_set_eeprom(struct net_device *netdev,
 		ixgb_write_eeprom(hw, first_word + i, eeprom_buff[i]);
 
 	/* Update the checksum over the first part of the EEPROM if needed */
-	if(first_word <= EEPROM_CHECKSUM_REG)
+	if (first_word <= EEPROM_CHECKSUM_REG)
 		ixgb_update_eeprom_checksum(hw);
 
 	kfree(eeprom_buff);
@@ -557,10 +557,10 @@ ixgb_set_ringparam(struct net_device *netdev,
 	tx_old = adapter->tx_ring;
 	rx_old = adapter->rx_ring;
 
-	if((ring->rx_mini_pending) || (ring->rx_jumbo_pending)) 
+	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
 
-	if(netif_running(adapter->netdev))
+	if (netif_running(adapter->netdev))
 		ixgb_down(adapter, true);
 
 	rxdr->count = max(ring->rx_pending,(u32)MIN_RXD);
@@ -571,11 +571,11 @@ ixgb_set_ringparam(struct net_device *netdev,
 	txdr->count = min(txdr->count,(u32)MAX_TXD);
 	txdr->count = ALIGN(txdr->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
 
-	if(netif_running(adapter->netdev)) {
+	if (netif_running(adapter->netdev)) {
 		/* Try to get new resources before deleting old */
-		if((err = ixgb_setup_rx_resources(adapter)))
+		if ((err = ixgb_setup_rx_resources(adapter)))
 			goto err_setup_rx;
-		if((err = ixgb_setup_tx_resources(adapter)))
+		if ((err = ixgb_setup_tx_resources(adapter)))
 			goto err_setup_tx;
 
 		/* save the new, restore the old in order to free it,
@@ -589,7 +589,7 @@ ixgb_set_ringparam(struct net_device *netdev,
 		ixgb_free_tx_resources(adapter);
 		adapter->rx_ring = rx_new;
 		adapter->tx_ring = tx_new;
-		if((err = ixgb_up(adapter)))
+		if ((err = ixgb_up(adapter)))
 			return err;
 		ixgb_set_speed_duplex(netdev);
 	}
@@ -615,7 +615,7 @@ ixgb_led_blink_callback(unsigned long data)
 {
 	struct ixgb_adapter *adapter = (struct ixgb_adapter *)data;
 
-	if(test_and_change_bit(IXGB_LED_ON, &adapter->led_status))
+	if (test_and_change_bit(IXGB_LED_ON, &adapter->led_status))
 		ixgb_led_off(&adapter->hw);
 	else
 		ixgb_led_on(&adapter->hw);
@@ -631,7 +631,7 @@ ixgb_phys_id(struct net_device *netdev, u32 data)
 	if (!data)
 		data = INT_MAX;
 
-	if(!adapter->blink_timer.function) {
+	if (!adapter->blink_timer.function) {
 		init_timer(&adapter->blink_timer);
 		adapter->blink_timer.function = ixgb_led_blink_callback;
 		adapter->blink_timer.data = (unsigned long)adapter;
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 04d2003..d023fb5 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -125,7 +125,7 @@ ixgb_adapter_stop(struct ixgb_hw *hw)
 	/* If we are stopped or resetting exit gracefully and wait to be
 	 * started again before accessing the hardware.
 	 */
-	if(hw->adapter_stopped) {
+	if (hw->adapter_stopped) {
 		DEBUGOUT("Exiting because the adapter is already stopped!!!\n");
 		return false;
 	}
@@ -482,7 +482,7 @@ ixgb_mc_addr_list_update(struct ixgb_hw *hw,
 		/* Place this multicast address in the RAR if there is room, *
 		 * else put it in the MTA
 		 */
-		if(rar_used_count < IXGB_RAR_ENTRIES) {
+		if (rar_used_count < IXGB_RAR_ENTRIES) {
 			ixgb_rar_set(hw,
 				     mc_addr_list +
 				     (i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad)),
@@ -719,9 +719,8 @@ ixgb_setup_fc(struct ixgb_hw *hw)
 	/* Write the new settings */
 	IXGB_WRITE_REG(hw, CTRL0, ctrl_reg);
 
-	if (pap_reg != 0) {
+	if (pap_reg != 0)
 		IXGB_WRITE_REG(hw, PAP, pap_reg);
-	}
 
 	/* Set the flow control receive threshold registers.  Normally,
 	 * these registers will be set to a default threshold that may be
@@ -729,14 +728,14 @@ ixgb_setup_fc(struct ixgb_hw *hw)
 	 * ability to transmit pause frames in not enabled, then these
 	 * registers will be set to 0.
 	 */
-	if(!(hw->fc.type & ixgb_fc_tx_pause)) {
+	if (!(hw->fc.type & ixgb_fc_tx_pause)) {
 		IXGB_WRITE_REG(hw, FCRTL, 0);
 		IXGB_WRITE_REG(hw, FCRTH, 0);
 	} else {
 	   /* We need to set up the Receive Threshold high and low water
 	    * marks as well as (optionally) enabling the transmission of XON
 	    * frames. */
-		if(hw->fc.send_xon) {
+		if (hw->fc.send_xon) {
 			IXGB_WRITE_REG(hw, FCRTL,
 				(hw->fc.low_water | IXGB_FCRTL_XONE));
 		} else {
@@ -1007,7 +1006,7 @@ ixgb_clear_hw_cntrs(struct ixgb_hw *hw)
 	DEBUGFUNC("ixgb_clear_hw_cntrs");
 
 	/* if we are stopped or resetting exit gracefully */
-	if(hw->adapter_stopped) {
+	if (hw->adapter_stopped) {
 		DEBUGOUT("Exiting because the adapter is stopped!!!\n");
 		return;
 	}
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index fc2cf0e..f7dda04 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -250,7 +250,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 		return err;
 	}
 
-	if((hw->max_frame_size != max_frame) ||
+	if ((hw->max_frame_size != max_frame) ||
 		(hw->max_frame_size !=
 		(IXGB_READ_REG(hw, MFS) >> IXGB_MFS_SHIFT))) {
 
@@ -258,11 +258,11 @@ ixgb_up(struct ixgb_adapter *adapter)
 
 		IXGB_WRITE_REG(hw, MFS, hw->max_frame_size << IXGB_MFS_SHIFT);
 
-		if(hw->max_frame_size >
+		if (hw->max_frame_size >
 		   IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH) {
 			u32 ctrl0 = IXGB_READ_REG(hw, CTRL0);
 
-			if(!(ctrl0 & IXGB_CTRL0_JFE)) {
+			if (!(ctrl0 & IXGB_CTRL0_JFE)) {
 				ctrl0 |= IXGB_CTRL0_JFE;
 				IXGB_WRITE_REG(hw, CTRL0, ctrl0);
 			}
@@ -299,7 +299,7 @@ ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog)
 	if (adapter->have_msi)
 		pci_disable_msi(adapter->pdev);
 
-	if(kill_watchdog)
+	if (kill_watchdog)
 		del_timer_sync(&adapter->watchdog_timer);
 
 	adapter->link_speed = 0;
@@ -356,14 +356,14 @@ ixgb_probe(struct pci_dev *pdev,
 	int i;
 	int err;
 
-	if((err = pci_enable_device(pdev)))
+	if ((err = pci_enable_device(pdev)))
 		return err;
 
-	if(!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
+	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
 	   !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
 		pci_using_dac = 1;
 	} else {
-		if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
+		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
 		   (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
 			printk(KERN_ERR
 			 "ixgb: No usable DMA configuration, aborting\n");
@@ -372,13 +372,13 @@ ixgb_probe(struct pci_dev *pdev,
 		pci_using_dac = 0;
 	}
 
-	if((err = pci_request_regions(pdev, ixgb_driver_name)))
+	if ((err = pci_request_regions(pdev, ixgb_driver_name)))
 		goto err_request_regions;
 
 	pci_set_master(pdev);
 
 	netdev = alloc_etherdev(sizeof(struct ixgb_adapter));
-	if(!netdev) {
+	if (!netdev) {
 		err = -ENOMEM;
 		goto err_alloc_etherdev;
 	}
@@ -400,9 +400,9 @@ ixgb_probe(struct pci_dev *pdev,
 	}
 
 	for(i = BAR_1; i <= BAR_5; i++) {
-		if(pci_resource_len(pdev, i) == 0)
+		if (pci_resource_len(pdev, i) == 0)
 			continue;
-		if(pci_resource_flags(pdev, i) & IORESOURCE_IO) {
+		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
 			adapter->hw.io_base = pci_resource_start(pdev, i);
 			break;
 		}
@@ -436,7 +436,7 @@ ixgb_probe(struct pci_dev *pdev,
 
 	/* setup the private structure */
 
-	if((err = ixgb_sw_init(adapter)))
+	if ((err = ixgb_sw_init(adapter)))
 		goto err_sw_init;
 
 	netdev->features = NETIF_F_SG |
@@ -446,12 +446,12 @@ ixgb_probe(struct pci_dev *pdev,
 			   NETIF_F_HW_VLAN_FILTER;
 	netdev->features |= NETIF_F_TSO;
 
-	if(pci_using_dac)
+	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
 	/* make sure the EEPROM is good */
 
-	if(!ixgb_validate_eeprom_checksum(&adapter->hw)) {
+	if (!ixgb_validate_eeprom_checksum(&adapter->hw)) {
 		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
 		err = -EIO;
 		goto err_eeprom;
@@ -460,7 +460,7 @@ ixgb_probe(struct pci_dev *pdev,
 	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
 
-	if(!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!is_valid_ether_addr(netdev->perm_addr)) {
 		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
 		err = -EIO;
 		goto err_eeprom;
@@ -475,7 +475,7 @@ ixgb_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->tx_timeout_task, ixgb_tx_timeout_task);
 
 	strcpy(netdev->name, "eth%d");
-	if((err = register_netdev(netdev)))
+	if ((err = register_netdev(netdev)))
 		goto err_register;
 
 	/* we're going to reset, so assume we have no link for now */
@@ -558,7 +558,7 @@ ixgb_sw_init(struct ixgb_adapter *adapter)
 	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 	adapter->rx_buffer_len = hw->max_frame_size + 8; /* + 8 for errata */
 
-	if((hw->device_id == IXGB_DEVICE_ID_82597EX)
+	if ((hw->device_id == IXGB_DEVICE_ID_82597EX)
 	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_CX4)
 	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_LR)
 	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_SR))
@@ -596,15 +596,15 @@ ixgb_open(struct net_device *netdev)
 
 	/* allocate transmit descriptors */
 
-	if((err = ixgb_setup_tx_resources(adapter)))
+	if ((err = ixgb_setup_tx_resources(adapter)))
 		goto err_setup_tx;
 
 	/* allocate receive descriptors */
 
-	if((err = ixgb_setup_rx_resources(adapter)))
+	if ((err = ixgb_setup_rx_resources(adapter)))
 		goto err_setup_rx;
 
-	if((err = ixgb_up(adapter)))
+	if ((err = ixgb_up(adapter)))
 		goto err_up;
 
 	return 0;
@@ -660,7 +660,7 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 
 	size = sizeof(struct ixgb_buffer) * txdr->count;
 	txdr->buffer_info = vmalloc(size);
-	if(!txdr->buffer_info) {
+	if (!txdr->buffer_info) {
 		DPRINTK(PROBE, ERR,
 		 "Unable to allocate transmit descriptor ring memory\n");
 		return -ENOMEM;
@@ -673,7 +673,7 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 	txdr->size = ALIGN(txdr->size, 4096);
 
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
-	if(!txdr->desc) {
+	if (!txdr->desc) {
 		vfree(txdr->buffer_info);
 		DPRINTK(PROBE, ERR,
 		 "Unable to allocate transmit descriptor memory\n");
@@ -749,7 +749,7 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 
 	size = sizeof(struct ixgb_buffer) * rxdr->count;
 	rxdr->buffer_info = vmalloc(size);
-	if(!rxdr->buffer_info) {
+	if (!rxdr->buffer_info) {
 		DPRINTK(PROBE, ERR,
 		 "Unable to allocate receive descriptor ring\n");
 		return -ENOMEM;
@@ -763,7 +763,7 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 
-	if(!rxdr->desc) {
+	if (!rxdr->desc) {
 		vfree(rxdr->buffer_info);
 		DPRINTK(PROBE, ERR,
 		 "Unable to allocate receive descriptors\n");
@@ -984,7 +984,7 @@ ixgb_clean_rx_ring(struct ixgb_adapter *adapter)
 
 	for(i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
-		if(buffer_info->skb) {
+		if (buffer_info->skb) {
 
 			pci_unmap_single(pdev,
 					 buffer_info->dma,
@@ -1025,7 +1025,7 @@ ixgb_set_mac(struct net_device *netdev, void *p)
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 
-	if(!is_valid_ether_addr(addr->sa_data))
+	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
@@ -1058,16 +1058,16 @@ ixgb_set_multi(struct net_device *netdev)
 
 	rctl = IXGB_READ_REG(hw, RCTL);
 
-	if(netdev->flags & IFF_PROMISC) {
+	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (IXGB_RCTL_UPE | IXGB_RCTL_MPE);
-	} else if(netdev->flags & IFF_ALLMULTI) {
+	} else if (netdev->flags & IFF_ALLMULTI) {
 		rctl |= IXGB_RCTL_MPE;
 		rctl &= ~IXGB_RCTL_UPE;
 	} else {
 		rctl &= ~(IXGB_RCTL_UPE | IXGB_RCTL_MPE);
 	}
 
-	if(netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
+	if (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
 		rctl |= IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
@@ -1104,8 +1104,8 @@ ixgb_watchdog(unsigned long data)
 		netif_stop_queue(netdev);
 	}
 
-	if(adapter->hw.link_up) {
-		if(!netif_carrier_ok(netdev)) {
+	if (adapter->hw.link_up) {
+		if (!netif_carrier_ok(netdev)) {
 			DPRINTK(LINK, INFO,
 			        "NIC Link is Up 10000 Mbps Full Duplex\n");
 			adapter->link_speed = 10000;
@@ -1114,7 +1114,7 @@ ixgb_watchdog(unsigned long data)
 			netif_wake_queue(netdev);
 		}
 	} else {
-		if(netif_carrier_ok(netdev)) {
+		if (netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
 			DPRINTK(LINK, INFO, "NIC Link is Down\n");
@@ -1126,8 +1126,8 @@ ixgb_watchdog(unsigned long data)
 
 	ixgb_update_stats(adapter);
 
-	if(!netif_carrier_ok(netdev)) {
-		if(IXGB_DESC_UNUSED(txdr) + 1 < txdr->count) {
+	if (!netif_carrier_ok(netdev)) {
+		if (IXGB_DESC_UNUSED(txdr) + 1 < txdr->count) {
 			/* We've lost link, so the controller stops DMA,
 			 * but we've got queued Tx work that's never going
 			 * to get done, so reset controller to flush Tx.
@@ -1207,7 +1207,7 @@ ixgb_tso(struct ixgb_adapter *adapter, struct sk_buff *skb)
 						| (skb->len - (hdr_len)));
 
 
-		if(++i == adapter->tx_ring.count) i = 0;
+		if (++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
 
 		return 1;
@@ -1223,7 +1223,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapter, struct sk_buff *skb)
 	unsigned int i;
 	u8 css, cso;
 
-	if(likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
+	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		struct ixgb_buffer *buffer_info;
 		css = skb_transport_offset(skb);
 		cso = css + skb->csum_offset;
@@ -1245,7 +1245,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapter, struct sk_buff *skb)
 			cpu_to_le32(IXGB_CONTEXT_DESC_TYPE
 				    | IXGB_TX_DESC_CMD_IDE);
 
-		if(++i == adapter->tx_ring.count) i = 0;
+		if (++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
 
 		return true;
@@ -1295,7 +1295,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 		len -= size;
 		offset += size;
 		count++;
-		if(++i == tx_ring->count) i = 0;
+		if (++i == tx_ring->count) i = 0;
 	}
 
 	for(f = 0; f < nr_frags; f++) {
@@ -1328,7 +1328,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 			len -= size;
 			offset += size;
 			count++;
-			if(++i == tx_ring->count) i = 0;
+			if (++i == tx_ring->count) i = 0;
 		}
 	}
 	i = (i == 0) ? tx_ring->count - 1 : i - 1;
@@ -1349,17 +1349,16 @@ ixgb_tx_queue(struct ixgb_adapter *adapter, int count, int vlan_id,int tx_flags)
 	u8 popts = 0;
 	unsigned int i;
 
-	if(tx_flags & IXGB_TX_FLAGS_TSO) {
+	if (tx_flags & IXGB_TX_FLAGS_TSO) {
 		cmd_type_len |= IXGB_TX_DESC_CMD_TSE;
 		popts |= (IXGB_TX_DESC_POPTS_IXSM | IXGB_TX_DESC_POPTS_TXSM);
 	}
 
-	if(tx_flags & IXGB_TX_FLAGS_CSUM)
+	if (tx_flags & IXGB_TX_FLAGS_CSUM)
 		popts |= IXGB_TX_DESC_POPTS_TXSM;
 
-	if(tx_flags & IXGB_TX_FLAGS_VLAN) {
+	if (tx_flags & IXGB_TX_FLAGS_VLAN)
 		cmd_type_len |= IXGB_TX_DESC_CMD_VLE;
-	}
 
 	i = tx_ring->next_to_use;
 
@@ -1373,7 +1372,7 @@ ixgb_tx_queue(struct ixgb_adapter *adapter, int count, int vlan_id,int tx_flags)
 		tx_desc->popts = popts;
 		tx_desc->vlan = cpu_to_le16(vlan_id);
 
-		if(++i == tx_ring->count) i = 0;
+		if (++i == tx_ring->count) i = 0;
 	}
 
 	tx_desc->cmd_type_len |= cpu_to_le32(IXGB_TX_DESC_CMD_EOP 
@@ -1441,7 +1440,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 
-	if(skb->len <= 0) {
+	if (skb->len <= 0) {
 		dev_kfree_skb_any(skb);
 		return 0;
 	}
@@ -1450,7 +1449,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
                      DESC_NEEDED)))
 		return NETDEV_TX_BUSY;
 
-	if(adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |= IXGB_TX_FLAGS_VLAN;
 		vlan_id = vlan_tx_tag_get(skb);
 	}
@@ -1465,7 +1464,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	if (likely(tso))
 		tx_flags |= IXGB_TX_FLAGS_TSO;
-	else if(ixgb_tx_csum(adapter, skb))
+	else if (ixgb_tx_csum(adapter, skb))
 		tx_flags |= IXGB_TX_FLAGS_CSUM;
 
 	ixgb_tx_queue(adapter, ixgb_tx_map(adapter, skb, first), vlan_id,
@@ -1573,7 +1572,7 @@ ixgb_update_stats(struct ixgb_adapter *adapter)
 	if (pci_channel_offline(pdev))
 		return;
 
-	if((netdev->flags & IFF_PROMISC) || (netdev->flags & IFF_ALLMULTI) ||
+	if ((netdev->flags & IFF_PROMISC) || (netdev->flags & IFF_ALLMULTI) ||
 	   (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES)) {
 		u64 multi = IXGB_READ_REG(&adapter->hw, MPRCL);
 		u32 bcast_l = IXGB_READ_REG(&adapter->hw, BPRCL);
@@ -1582,7 +1581,7 @@ ixgb_update_stats(struct ixgb_adapter *adapter)
 
 		multi |= ((u64)IXGB_READ_REG(&adapter->hw, MPRCH) << 32);
 		/* fix up multicast stats by removing broadcasts */
-		if(multi >= bcast)
+		if (multi >= bcast)
 			multi -= bcast;
 		
 		adapter->stats.mprcl += (multi & 0xFFFFFFFF);
@@ -1706,7 +1705,7 @@ ixgb_intr(int irq, void *data)
 	unsigned int i;
 #endif
 
-	if(unlikely(!icr))
+	if (unlikely(!icr))
 		return IRQ_NONE;  /* Not our interrupt */
 
 	if (unlikely(icr & (IXGB_INT_RXSEQ | IXGB_INT_LSC)))
@@ -1729,7 +1728,7 @@ ixgb_intr(int irq, void *data)
 	 * transmit queues for completed descriptors, intended to
 	 * avoid starvation issues and assist tx/rx fairness. */
 	for(i = 0; i < IXGB_MAX_INTR; i++)
-		if(!ixgb_clean_rx_irq(adapter) &
+		if (!ixgb_clean_rx_irq(adapter) &
 		   !ixgb_clean_tx_irq(adapter))
 			break;
 #endif 
@@ -1798,7 +1797,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 			*(u32 *)&(tx_desc->status) = 0;
 
 			cleaned = (i == eop);
-			if(++i == tx_ring->count) i = 0;
+			if (++i == tx_ring->count) i = 0;
 		}
 
 		eop = tx_ring->buffer_info[i].next_to_watch;
@@ -1820,7 +1819,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 		}
 	}
 
-	if(adapter->detect_tx_hung) {
+	if (adapter->detect_tx_hung) {
 		/* detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung = false;
@@ -1869,7 +1868,7 @@ ixgb_rx_checksum(struct ixgb_adapter *adapter,
 	/* Ignore Checksum bit is set OR
 	 * TCP Checksum has not been calculated
 	 */
-	if((rx_desc->status & IXGB_RX_DESC_STATUS_IXSM) ||
+	if ((rx_desc->status & IXGB_RX_DESC_STATUS_IXSM) ||
 	   (!(rx_desc->status & IXGB_RX_DESC_STATUS_TCPCS))) {
 		skb->ip_summed = CHECKSUM_NONE;
 		return;
@@ -1877,7 +1876,7 @@ ixgb_rx_checksum(struct ixgb_adapter *adapter,
 
 	/* At this point we know the hardware did the TCP checksum */
 	/* now look at the TCP checksum error bit */
-	if(rx_desc->errors & IXGB_RX_DESC_ERRORS_TCPE) {
+	if (rx_desc->errors & IXGB_RX_DESC_ERRORS_TCPE) {
 		/* let the stack verify checksum errors */
 		skb->ip_summed = CHECKSUM_NONE;
 		adapter->hw_csum_rx_error++;
@@ -1918,7 +1917,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 		u8 status;
 
 #ifdef CONFIG_IXGB_NAPI
-		if(*work_done >= work_to_do)
+		if (*work_done >= work_to_do)
 			break;
 
 		(*work_done)++;
@@ -1929,11 +1928,11 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 
 		prefetch(skb->data);
 
-		if(++i == rx_ring->count) i = 0;
+		if (++i == rx_ring->count) i = 0;
 		next_rxd = IXGB_RX_DESC(*rx_ring, i);
 		prefetch(next_rxd);
 
-		if((j = i + 1) == rx_ring->count) j = 0;
+		if ((j = i + 1) == rx_ring->count) j = 0;
 		next2_buffer = &rx_ring->buffer_info[j];
 		prefetch(next2_buffer);
 
@@ -1950,7 +1949,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 
 		length = le16_to_cpu(rx_desc->length);
 
-		if(unlikely(!(status & IXGB_RX_DESC_STATUS_EOP))) {
+		if (unlikely(!(status & IXGB_RX_DESC_STATUS_EOP))) {
 
 			/* All receives must fit into a single buffer */
 
@@ -1999,14 +1998,14 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 
 		skb->protocol = eth_type_trans(skb, netdev);
 #ifdef CONFIG_IXGB_NAPI
-		if(adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
+		if (adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
 				le16_to_cpu(rx_desc->special));
 		} else {
 			netif_receive_skb(skb);
 		}
 #else /* CONFIG_IXGB_NAPI */
-		if(adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
+		if (adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
 				le16_to_cpu(rx_desc->special));
 		} else {
@@ -2092,7 +2091,7 @@ map_skb:
 		rx_desc->status = 0;
 
 
-		if(++i == rx_ring->count) i = 0;
+		if (++i == rx_ring->count) i = 0;
 		buffer_info = &rx_ring->buffer_info[i];
 	}
 
@@ -2125,7 +2124,7 @@ ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 	ixgb_irq_disable(adapter);
 	adapter->vlgrp = grp;
 
-	if(grp) {
+	if (grp) {
 		/* enable VLAN tag insert/strip */
 		ctrl = IXGB_READ_REG(&adapter->hw, CTRL0);
 		ctrl |= IXGB_CTRL0_VME;
@@ -2197,10 +2196,10 @@ ixgb_restore_vlan(struct ixgb_adapter *adapter)
 {
 	ixgb_vlan_rx_register(adapter->netdev, adapter->vlgrp);
 
-	if(adapter->vlgrp) {
+	if (adapter->vlgrp) {
 		u16 vid;
 		for(vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
-			if(!vlan_group_get_device(adapter->vlgrp, vid))
+			if (!vlan_group_get_device(adapter->vlgrp, vid))
 				continue;
 			ixgb_vlan_rx_add_vid(adapter->netdev, vid);
 		}
@@ -2238,7 +2237,7 @@ static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
-	if(netif_running(netdev))
+	if (netif_running(netdev))
 		ixgb_down(adapter, true);
 
 	pci_disable_device(pdev);
@@ -2261,7 +2260,7 @@ static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
-	if(pci_enable_device(pdev)) {
+	if (pci_enable_device(pdev)) {
 		DPRINTK(PROBE, ERR, "Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
@@ -2277,14 +2276,14 @@ static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev)
 	ixgb_reset(adapter);
 
 	/* Make sure the EEPROM is good */
-	if(!ixgb_validate_eeprom_checksum(&adapter->hw)) {
+	if (!ixgb_validate_eeprom_checksum(&adapter->hw)) {
 		DPRINTK(PROBE, ERR, "After reset, the EEPROM checksum is not valid.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
 
-	if(!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!is_valid_ether_addr(netdev->perm_addr)) {
 		DPRINTK(PROBE, ERR, "After reset, invalid MAC address.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
@@ -2307,8 +2306,8 @@ static void ixgb_io_resume (struct pci_dev *pdev)
 
 	pci_set_master(pdev);
 
-	if(netif_running(netdev)) {
-		if(ixgb_up(adapter)) {
+	if (netif_running(netdev)) {
+		if (ixgb_up(adapter)) {
 			printk ("ixgb: can't bring device back up after reset\n");
 			return;
 		}
diff --git a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/ixgb/ixgb_osdep.h
index 4be1b27..fb74bb1 100644
--- a/drivers/net/ixgb/ixgb_osdep.h
+++ b/drivers/net/ixgb/ixgb_osdep.h
@@ -40,7 +40,7 @@
 #include <linux/sched.h>
 
 #undef ASSERT
-#define ASSERT(x)	if(!(x)) BUG()
+#define ASSERT(x)	if (!(x)) BUG()
 #define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)
 
 #ifdef DBG
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index 865d14d..a23d2ff 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -200,7 +200,7 @@ struct ixgb_option {
 static int __devinit
 ixgb_validate_option(unsigned int *value, const struct ixgb_option *opt)
 {
-	if(*value == OPTION_UNSET) {
+	if (*value == OPTION_UNSET) {
 		*value = opt->def;
 		return 0;
 	}
@@ -217,7 +217,7 @@ ixgb_validate_option(unsigned int *value, const struct ixgb_option *opt)
 		}
 		break;
 	case range_option:
-		if(*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
+		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
 			printk(KERN_INFO "%s set to %i\n", opt->name, *value);
 			return 0;
 		}
@@ -228,8 +228,8 @@ ixgb_validate_option(unsigned int *value, const struct ixgb_option *opt)
 
 		for(i = 0; i < opt->arg.l.nr; i++) {
 			ent = &opt->arg.l.p[i];
-			if(*value == ent->i) {
-				if(ent->str[0] != '\0')
+			if (*value == ent->i) {
+				if (ent->str[0] != '\0')
 					printk(KERN_INFO "%s\n", ent->str);
 				return 0;
 			}
@@ -260,7 +260,7 @@ void __devinit
 ixgb_check_options(struct ixgb_adapter *adapter)
 {
 	int bd = adapter->bd_number;
-	if(bd >= IXGB_MAX_NIC) {
+	if (bd >= IXGB_MAX_NIC) {
 		printk(KERN_NOTICE
 			   "Warning: no configuration for board #%i\n", bd);
 		printk(KERN_NOTICE "Using defaults for all values\n");
@@ -277,7 +277,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		};
 		struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 
-		if(num_TxDescriptors > bd) {
+		if (num_TxDescriptors > bd) {
 			tx_ring->count = TxDescriptors[bd];
 			ixgb_validate_option(&tx_ring->count, &opt);
 		} else {
@@ -296,7 +296,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		};
 		struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 
-		if(num_RxDescriptors > bd) {
+		if (num_RxDescriptors > bd) {
 			rx_ring->count = RxDescriptors[bd];
 			ixgb_validate_option(&rx_ring->count, &opt);
 		} else {
@@ -312,7 +312,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			.def  = OPTION_ENABLED
 		};
 
-		if(num_XsumRX > bd) {
+		if (num_XsumRX > bd) {
 			unsigned int rx_csum = XsumRX[bd];
 			ixgb_validate_option(&rx_csum, &opt);
 			adapter->rx_csum = rx_csum;
@@ -338,7 +338,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 					 .p = fc_list }}
 		};
 
-		if(num_FlowControl > bd) {
+		if (num_FlowControl > bd) {
 			unsigned int fc = FlowControl[bd];
 			ixgb_validate_option(&fc, &opt);
 			adapter->hw.fc.type = fc;
@@ -356,7 +356,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 					 .max = MAX_FCRTH}}
 		};
 
-		if(num_RxFCHighThresh > bd) {
+		if (num_RxFCHighThresh > bd) {
 			adapter->hw.fc.high_water = RxFCHighThresh[bd];
 			ixgb_validate_option(&adapter->hw.fc.high_water, &opt);
 		} else {
@@ -376,7 +376,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 					 .max = MAX_FCRTL}}
 		};
 
-		if(num_RxFCLowThresh > bd) {
+		if (num_RxFCLowThresh > bd) {
 			adapter->hw.fc.low_water = RxFCLowThresh[bd];
 			ixgb_validate_option(&adapter->hw.fc.low_water, &opt);
 		} else {
@@ -396,7 +396,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 					.max = MAX_FCPAUSE}}
 		};
 
-		if(num_FCReqTimeout > bd) {
+		if (num_FCReqTimeout > bd) {
 			unsigned int pause_time = FCReqTimeout[bd];
 			ixgb_validate_option(&pause_time, &opt);
 			adapter->hw.fc.pause_time = pause_time;
@@ -429,7 +429,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 					 .max = MAX_RDTR}}
 		};
 
-		if(num_RxIntDelay > bd) {
+		if (num_RxIntDelay > bd) {
 			adapter->rx_int_delay = RxIntDelay[bd];
 			ixgb_validate_option(&adapter->rx_int_delay, &opt);
 		} else {
@@ -446,7 +446,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 					 .max = MAX_TIDV}}
 		};
 
-		if(num_TxIntDelay > bd) {
+		if (num_TxIntDelay > bd) {
 			adapter->tx_int_delay = TxIntDelay[bd];
 			ixgb_validate_option(&adapter->tx_int_delay, &opt);
 		} else {
@@ -462,7 +462,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			.def  = OPTION_ENABLED
 		};
 
-		if(num_IntDelayEnable > bd) {
+		if (num_IntDelayEnable > bd) {
 			unsigned int ide = IntDelayEnable[bd];
 			ixgb_validate_option(&ide, &opt);
 			adapter->tx_int_delay_enable = ide;

