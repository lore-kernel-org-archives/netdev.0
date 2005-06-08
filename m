From: Pavel Machek <pavel@ucw.cz>
Subject: [-mm] ipw2100: cleanup debug prints
Date: Wed, 8 Jun 2005 15:28:14 +0200
Message-ID: <20050608132814.GA2634@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev list <netdev@oss.sgi.com>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
        Andrew Morton <akpm@zip.com.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

ipw2100 uses custom debug prints that are sometimes longer and always
harder to read than normal printk. They also introduced some bugs where
prefix is printed twice.

Signed-off-by: Pavel Machek <pavel@suse.cz>

--- /data/l/clean-mm/drivers/net/wireless/ipw2100.c	2005-06-08 12:11:29.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2100.c	2005-06-08 15:09:26.000000000 +0200
@@ -484,7 +476,7 @@
 	u32 total_length;
 
 	if (ordinals->table1_addr == 0) {
-		IPW_DEBUG_WARNING(DRV_NAME ": attempt to use fw ordinals "
+		printk(KERN_WARNING DRV_NAME ": attempt to use fw ordinals "
 		       "before they have been loaded.\n");
 		return -EINVAL;
 	}
@@ -493,8 +485,7 @@
 		if (*len < IPW_ORD_TAB_1_ENTRY_SIZE) {
 			*len = IPW_ORD_TAB_1_ENTRY_SIZE;
 
-			IPW_DEBUG_WARNING(DRV_NAME
-			       ": ordinal buffer length too small, need %d\n",
+			printk(KERN_WARNING DRV_NAME ": ordinal buffer length too small, need %d\n",
 			       IPW_ORD_TAB_1_ENTRY_SIZE);
 
 			return -EINVAL;
@@ -546,7 +537,7 @@
 		return 0;
 	}
 
-	IPW_DEBUG_WARNING(DRV_NAME ": ordinal %d neither in table 1 nor "
+	printk(KERN_WARNING DRV_NAME ": ordinal %d neither in table 1 nor "
 	       "in table 2\n", ord);
 
 	return -EINVAL;
@@ -761,7 +752,7 @@
 	}
 
 	if (priv->fatal_error) {
-		IPW_DEBUG_WARNING("%s: firmware fatal error\n",
+		printk(KERN_WARNING DRV_NAME ": %s: firmware fatal error\n",
 		       priv->net_dev->name);
 		return -EIO;
 	}
@@ -1001,7 +975,7 @@
 	/* load microcode */
 	err = ipw2100_ucode_download(priv, &ipw2100_firmware);
 	if (err) {
-		IPW_DEBUG_ERROR("%s: Error loading microcode: %d\n",
+		printk(KERN_ERR DRV_NAME ": %s: Error loading microcode: %d\n",
 		       priv->net_dev->name, err);
 		goto fail;
 	}
@@ -1014,7 +988,7 @@
 	/* s/w reset and clock stabilization (again!!!) */
 	err = sw_reset_and_clock(priv);
 	if (err) {
-		IPW_DEBUG_ERROR("%s: sw_reset_and_clock failed: %d\n",
+		printk(KERN_ERR DRV_NAME ": %s: sw_reset_and_clock failed: %d\n",
 		       priv->net_dev->name, err);
 		goto fail;
 	}
@@ -1210,7 +1163,7 @@
 	 * fw & dino ucode
 	 */
 	if (ipw2100_download_firmware(priv)) {
-		IPW_DEBUG_ERROR("%s: Failed to power on the adapter.\n",
+		printk(KERN_ERR DRV_NAME ": %s: Failed to power on the adapter.\n",
 		       priv->net_dev->name);
 		return -EIO;
 	}
@@ -1270,7 +1223,7 @@
 		     i ? "SUCCESS" : "FAILED");
 
 	if (!i) {
-		IPW_DEBUG_WARNING("%s: Firmware did not initialize.\n",
+		printk(KERN_WARNING DRV_NAME ": %s: Firmware did not initialize.\n",
 		       priv->net_dev->name);
 		return -EIO;
 	}
@@ -1466,7 +1416,7 @@
 
 		err = ipw2100_hw_phy_off(priv);
 		if (err)
-			IPW_DEBUG_WARNING("Error disabling radio %d\n", err);
+			printk(KERN_WARNING DRV_NAME ": Error disabling radio %d\n", err);
 
 		/*
 		 * If in D0-standby mode going directly to D3 may cause a
@@ -1492,7 +1442,7 @@
 
 		err = ipw2100_hw_send_command(priv, &cmd);
 		if (err)
-			IPW_DEBUG_WARNING(
+			printk(KERN_WARNING DRV_NAME ": "
 			       "%s: Power down command failed: Error %d\n",
 			       priv->net_dev->name, err);
 		else {
@@ -1533,7 +1483,7 @@
 	}
 
 	if (i == 0)
-		IPW_DEBUG_WARNING(DRV_NAME
+		printk(KERN_WARNING DRV_NAME 
 		       ": %s: Could now power down adapter.\n",
 		       priv->net_dev->name);
 
@@ -1573,13 +1523,13 @@
 
 	err = ipw2100_hw_send_command(priv, &cmd);
 	if (err) {
-		IPW_DEBUG_WARNING("exit - failed to send CARD_DISABLE command\n");
+		printk(KERN_WARNING DRV_NAME ": exit - failed to send CARD_DISABLE command\n");
 		goto fail_up;
 	}
 
 	err = ipw2100_wait_for_card_state(priv, IPW_HW_STATE_DISABLED);
 	if (err) {
-		IPW_DEBUG_WARNING("exit - card failed to change to DISABLED\n");
+		printk(KERN_WARNING DRV_NAME ": exit - card failed to change to DISABLED\n");
 		goto fail_up;
 	}
 
@@ -1689,7 +1633,7 @@
 	    (priv->status & STATUS_RESET_PENDING)) {
 		/* Power cycle the card ... */
 		if (ipw2100_power_cycle_adapter(priv)) {
-			IPW_DEBUG_WARNING("%s: Could not cycle adapter.\n",
+			printk(KERN_WARNING DRV_NAME ": %s: Could not cycle adapter.\n",
 					  priv->net_dev->name);
 			rc = 1;
 			goto exit;
@@ -1699,7 +1643,7 @@
 
 	/* Load the firmeware, start the clocks, etc. */
 	if (ipw2100_start_adapter(priv)) {
-	       	IPW_DEBUG_ERROR("%s: Failed to start the firmware.\n",
+	       	printk(KERN_ERR DRV_NAME ": %s: Failed to start the firmware.\n",
 				priv->net_dev->name);
 		rc = 1;
 		goto exit;
@@ -1709,7 +1653,7 @@
 
 	/* Determine capabilities of this particular HW configuration */
 	if (ipw2100_get_hw_features(priv)) {
-		IPW_DEBUG_ERROR("%s: Failed to determine HW features.\n",
+		printk(KERN_ERR DRV_NAME ": %s: Failed to determine HW features.\n",
 				priv->net_dev->name);
 		rc = 1;
 		goto exit;
@@ -1717,7 +1661,7 @@
 
 	lock = LOCK_NONE;
 	if (ipw2100_set_ordinal(priv, IPW_ORD_PERS_DB_LOCK, &lock, &ord_len)) {
-		IPW_DEBUG_ERROR("%s: Failed to clear ordinal lock.\n",
+		printk(KERN_ERR DRV_NAME ": %s: Failed to clear ordinal lock.\n",
 				priv->net_dev->name);
 		rc = 1;
 		goto exit;
@@ -1743,7 +1687,7 @@
 	/* Send all of the commands that must be sent prior to
 	 * HOST_COMPLETE */
 	if (ipw2100_adapter_setup(priv)) {
-		IPW_DEBUG_ERROR("%s: Failed to start the card.\n",
+		printk(KERN_ERR DRV_NAME ": %s: Failed to start the card.\n",
 				priv->net_dev->name);
 		rc = 1;
 		goto exit;
@@ -1752,7 +1696,7 @@
 	if (!deferred) {
 		/* Enable the adapter - sends HOST_COMPLETE */
 		if (ipw2100_enable_adapter(priv)) {
-			IPW_DEBUG_ERROR(
+			printk(KERN_ERR DRV_NAME ": "
 				"%s: failed in call to enable adapter.\n",
 				priv->net_dev->name);
 			ipw2100_hw_stop_adapter(priv);
@@ -1810,7 +1754,7 @@
 	spin_unlock_irqrestore(&priv->low_lock, flags);
 
 	if (ipw2100_hw_stop_adapter(priv))
-		IPW_DEBUG_ERROR("%s: Error stopping adapter.\n",
+		printk(KERN_ERR DRV_NAME ": %s: Error stopping adapter.\n",
 		       priv->net_dev->name);
 
 	/* Do not disable the interrupt until _after_ we disable
@@ -2417,7 +2312,7 @@
 
 	/* We need to allocate a new SKB and attach it to the RDB. */
 	if (unlikely(ipw2100_alloc_skb(priv, packet))) {
-		IPW_DEBUG_WARNING(
+		printk(KERN_WARNING DRV_NAME ": "
 			"%s: Unable to allocate SKB onto RBD ring - disabling "
 			"adapter.\n", priv->net_dev->name);
 		/* TODO: schedule adapter shutdown */
@@ -2679,7 +2574,7 @@
 		break;
 
 	default:
-		IPW_DEBUG_WARNING("%s: Bad fw_pend_list entry!\n",
+		printk(KERN_WARNING DRV_NAME ": %s: Bad fw_pend_list entry!\n",
 				   priv->net_dev->name);
 		return 0;
 	}
@@ -2693,7 +2588,7 @@
 	read_register(priv->net_dev, IPW_MEM_HOST_SHARED_TX_QUEUE_WRITE_INDEX,
 		      &w);
 	if (w != txq->next)
-		IPW_DEBUG_WARNING("%s: write index mismatch\n",
+		printk(KERN_WARNING DRV_NAME ": %s: write index mismatch\n",
 		       priv->net_dev->name);
 
         /*
@@ -2754,7 +2649,7 @@
 	switch (packet->type) {
 	case DATA:
 		if (txq->drv[txq->oldest].status.info.fields.txType != 0)
-			IPW_DEBUG_WARNING("%s: Queue mismatch.  "
+			printk(KERN_WARNING DRV_NAME ": %s: Queue mismatch.  "
 			       "Expecting DATA TBD but pulled "
 			       "something else: ids %d=%d.\n",
 			       priv->net_dev->name, txq->oldest, packet->index);
@@ -2801,7 +2696,7 @@
 
 	case COMMAND:
 		if (txq->drv[txq->oldest].status.info.fields.txType != 1)
-			IPW_DEBUG_WARNING("%s: Queue mismatch.  "
+			printk(KERN_WARNING DRV_NAME ": %s: Queue mismatch.  "
 			       "Expecting COMMAND TBD but pulled "
 			       "something else: ids %d=%d.\n",
 			       priv->net_dev->name, txq->oldest, packet->index);
@@ -3085,7 +2980,7 @@
 		      (unsigned long)inta & IPW_INTERRUPT_MASK);
 
 	if (inta & IPW2100_INTA_FATAL_ERROR) {
-		IPW_DEBUG_WARNING(DRV_NAME
+		printk(KERN_WARNING DRV_NAME
 				  ": Fatal interrupt. Scheduling firmware restart.\n");
 		priv->inta_other++;
 		write_register(
@@ -3105,7 +3000,7 @@
 	}
 
 	if (inta & IPW2100_INTA_PARITY_ERROR) {
-		IPW_DEBUG_ERROR("***** PARITY ERROR INTERRUPT !!!! \n");
+		printk(KERN_ERR DRV_NAME ": ***** PARITY ERROR INTERRUPT !!!! \n");
 		priv->inta_other++;
 		write_register(
 			dev, IPW_REG_INTA,
@@ -3223,7 +3116,7 @@
 
 	if (inta == 0xFFFFFFFF) {
 		/* Hardware disappeared */
-		IPW_DEBUG_WARNING("IRQ INTA == 0xFFFFFFFF\n");
+		printk(KERN_WARNING DRV_NAME ": IRQ INTA == 0xFFFFFFFF\n");
 		goto none;
 	}
 
@@ -3308,7 +3201,7 @@
 		IPW_COMMAND_POOL_SIZE * sizeof(struct ipw2100_tx_packet),
 		GFP_KERNEL);
 	if (!priv->msg_buffers) {
-		IPW_DEBUG_ERROR("%s: PCI alloc failed for msg "
+		printk(KERN_ERR DRV_NAME ": %s: PCI alloc failed for msg "
 		       "buffers.\n", priv->net_dev->name);
 		return -ENOMEM;
 	}
@@ -3319,7 +3212,7 @@
 			sizeof(struct ipw2100_cmd_header),
 			&p);
 		if (!v) {
-			IPW_DEBUG_ERROR(
+			printk(KERN_ERR DRV_NAME ": "
 			       "%s: PCI alloc failed for msg "
 			       "buffers.\n",
 			       priv->net_dev->name);
@@ -3826,7 +3289,7 @@
 
 	err = ipw2100_disable_adapter(priv);
 	if (err) {
-		IPW_DEBUG_ERROR("%s: Could not disable adapter %d\n",
+		printk(KERN_ERR DRV_NAME ": %s: Could not disable adapter %d\n",
 		       priv->net_dev->name, err);
 		return err;
 	}
@@ -4272,7 +3557,7 @@
 		TX_PENDED_QUEUE_LENGTH * sizeof(struct ipw2100_tx_packet),
 		GFP_ATOMIC);
 	if (!priv->tx_buffers) {
-		IPW_DEBUG_ERROR("%s: alloc failed form tx buffers.\n",
+		printk(KERN_ERR DRV_NAME ": %s: alloc failed form tx buffers.\n",
 		       priv->net_dev->name);
 		bd_queue_free(priv, &priv->tx_queue);
 		return -ENOMEM;
@@ -4282,7 +3567,7 @@
 		v = pci_alloc_consistent(
 			priv->pci_dev, sizeof(struct ipw2100_data_header), &p);
 		if (!v) {
-			IPW_DEBUG_ERROR("%s: PCI alloc failed for tx "
+			printk(KERN_ERR DRV_NAME ": %s: PCI alloc failed for tx "
 			       "buffers.\n", priv->net_dev->name);
 			err = -ENOMEM;
 			break;
@@ -4593,7 +3852,7 @@
 	if (!batch_mode) {
 		err = ipw2100_disable_adapter(priv);
 		if (err) {
-			IPW_DEBUG_ERROR("%s: Could not disable adapter %d\n",
+			printk(KERN_ERR DRV_NAME ": %s: Could not disable adapter %d\n",
 			       priv->net_dev->name, err);
 			return err;
 		}
@@ -5212,7 +4390,7 @@
 	if (!batch_mode) {
 		err = ipw2100_disable_adapter(priv);
 		if (err) {
-			IPW_DEBUG_ERROR("%s: Could not disable adapter %d\n",
+			printk(KERN_ERR DRV_NAME ": %s: Could not disable adapter %d\n",
 			       priv->net_dev->name, err);
 			return err;
 		}
@@ -5300,7 +4478,7 @@
 		err = ipw2100_disable_adapter(priv);
 		/* FIXME: IPG: shouldn't this prink be in _disable_adapter()? */
 		if (err) {
-			IPW_DEBUG_ERROR("%s: Could not disable adapter %d\n",
+			printk(KERN_ERR DRV_NAME ": %s: Could not disable adapter %d\n",
 			       priv->net_dev->name, err);
 			return err;
 		}
@@ -5336,7 +4514,7 @@
 	if (!batch_mode) {
 		err = ipw2100_disable_adapter(priv);
 		if (err) {
-			IPW_DEBUG_ERROR("%s: Could not disable adapter %d\n",
+			printk(KERN_ERR DRV_NAME ": %s: Could not disable adapter %d\n",
 			       priv->net_dev->name, err);
 			return err;
 		}
@@ -5884,7 +5049,7 @@
 			break;
 
 		default:
-			IPW_DEBUG_ERROR("%s: Unknown WPA param: %d\n",
+			printk(KERN_ERR DRV_NAME ": %s: Unknown WPA param: %d\n",
 					    dev->name, name);
 			ret = -EOPNOTSUPP;
 	}
@@ -5907,7 +5072,7 @@
 			break;
 
 		default:
-			IPW_DEBUG_ERROR("%s: Unknown MLME request: %d\n",
+			printk(KERN_ERR DRV_NAME ": %s: Unknown MLME request: %d\n",
 					    dev->name, command);
 			ret = -EOPNOTSUPP;
 	}
@@ -6157,7 +5322,7 @@
 		break;
 
 	default:
-		IPW_DEBUG_ERROR("%s: Unknown WPA supplicant request: %d\n",
+		printk(KERN_ERR DRV_NAME ": %s: Unknown WPA supplicant request: %d\n",
 				dev->name, param->cmd);
 		ret = -EOPNOTSUPP;
 
@@ -8395,7 +7531,7 @@
 		(struct ipw2100_fw_header *)fw->fw_entry->data;
 
 	if (IPW2100_FW_MAJOR(h->version) != IPW2100_FW_MAJOR_VERSION) {
-		IPW_DEBUG_WARNING("Firmware image not compatible "
+		printk(KERN_WARNING DRV_NAME ": Firmware image not compatible "
 		       "(detected version id of %u). "
 		       "See Documentation/networking/README.ipw2100\n",
 		       h->version);
@@ -8438,7 +7574,7 @@
 	rc = request_firmware(&fw->fw_entry, fw_name, &priv->pci_dev->dev);
 
 	if (rc < 0) {
-		IPW_DEBUG_ERROR(
+		printk(KERN_ERR DRV_NAME ": "
 		       "%s: Firmware '%s' not available or load failed.\n",
 		       priv->net_dev->name, fw_name);
 		return rc;
@@ -8520,7 +7656,7 @@
 		firmware_data_left -= 2;
 
 		if (len > 32) {
-			IPW_DEBUG_ERROR(
+			printk(KERN_ERR DRV_NAME ": "
 			       "Invalid firmware run-length of %d bytes\n",
 			       len);
 			return -EINVAL;
@@ -8630,7 +7766,7 @@
 	}
 
 	if (i == 10) {
-		IPW_DEBUG_ERROR("%s: Error initializing Symbol\n",
+		printk(KERN_ERR DRV_NAME ": %s: Error initializing Symbol\n",
 		       dev->name);
 		return -EIO;
 	}
@@ -8651,7 +7787,7 @@
 	}
 
 	if (i == 30) {
-		IPW_DEBUG_ERROR("%s: No response from Symbol - hw not alive\n",
+		printk(KERN_ERR DRV_NAME ": %s: No response from Symbol - hw not alive\n",
 		       dev->name);
 		printk_buf(IPW_DL_ERROR, (u8*)&response, sizeof(response));
 		return -EIO;
