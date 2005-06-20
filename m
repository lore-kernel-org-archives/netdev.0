From: Pavel Machek <pavel@ucw.cz>
Subject: [patch] ipw2100: remove by-hand function entry/exit debugging
Date: Mon, 20 Jun 2005 13:29:50 +0200
Message-ID: <20050620112950.GA12102@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev list <netdev@oss.sgi.com>, Andrew Morton <akpm@zip.com.au>,
        Jeff Garzik <jgarzik@pobox.com>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This removes debug prints from entry/exit of functions. Such level of
debugging should probably be done by gdb or similar.

Signed-off-by: Pavel Machek <pavel@suse.cz>

--- clean-mm/drivers/net/wireless/ipw2100.c	2005-06-20 12:34:33.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2100.c	2005-06-20 12:55:03.000000000 +0200
@@ -1083,8 +1046,6 @@
 {
 	struct ipw2100_ordinals *ord = &priv->ordinals;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	read_register(priv->net_dev, IPW_MEM_HOST_SHARED_ORDINALS_TABLE_1,
 		      &ord->table1_addr);
 
@@ -1095,10 +1056,6 @@
 	read_nic_dword(priv->net_dev, ord->table2_addr, &ord->table2_size);
 
 	ord->table2_size &= 0x0000FFFF;
-
-	IPW_DEBUG_INFO("table 1 size: %d\n", ord->table1_size);
-	IPW_DEBUG_INFO("table 2 size: %d\n", ord->table2_size);
-	IPW_DEBUG_INFO("exit\n");
 }
 
 static inline void ipw2100_hw_set_gpio(struct ipw2100_priv *priv)
@@ -1196,8 +1153,6 @@
 	int i;
 	u32 inta, inta_mask, gpio;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	if (priv->status & STATUS_RUNNING)
 		return 0;
 
@@ -1284,9 +1239,6 @@
 
 	/* The adapter has been reset; we are not associated */
 	priv->status &= ~(STATUS_ASSOCIATING | STATUS_ASSOCIATED);
-
-	IPW_DEBUG_INFO("exit\n");
-
 	return 0;
 }
 
@@ -1596,8 +1548,6 @@
 	};
 	int err;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	IPW_DEBUG_SCAN("setting scan options\n");
 
 	cmd.host_command_parameters[0] = 0;
@@ -1641,8 +1591,6 @@
 		return 0;
 	}
 
-	IPW_DEBUG_INFO("enter\n");
-
 	/* Not clearing here; doing so makes iwlist always return nothing...
 	 *
 	 * We should modify the table logic to use aging tables vs. clearing
@@ -1655,8 +1603,6 @@
 	if (err)
 		priv->status &= ~STATUS_SCANNING;
 
-	IPW_DEBUG_INFO("exit\n");
-
 	return err;
 }
 
@@ -3190,8 +3087,6 @@
 	ipw2100_enable_interrupts(priv);
 
 	spin_unlock_irqrestore(&priv->low_lock, flags);
-
-	IPW_DEBUG_ISR("exit\n");
 }
 
 
@@ -4149,43 +3460,32 @@
 {
 	struct ipw2100_status_queue *q = &priv->status_queue;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	q->size = entries * sizeof(struct ipw2100_status);
 	q->drv = (struct ipw2100_status *)pci_alloc_consistent(
 		priv->pci_dev, q->size, &q->nic);
 	if (!q->drv) {
-		IPW_DEBUG_WARNING(
+		printk(KERN_WARNING DRV_NAME ": "
 		       "Can not allocate status queue.\n");
 		return -ENOMEM;
 	}
 
 	memset(q->drv, 0, q->size);
-
-	IPW_DEBUG_INFO("exit\n");
-
 	return 0;
 }
 
 static void status_queue_free(struct ipw2100_priv *priv)
 {
-	IPW_DEBUG_INFO("enter\n");
-
 	if (priv->status_queue.drv) {
 		pci_free_consistent(
 			priv->pci_dev, priv->status_queue.size,
 			priv->status_queue.drv, priv->status_queue.nic);
 		priv->status_queue.drv = NULL;
 	}
-
-	IPW_DEBUG_INFO("exit\n");
 }
 
 static int bd_queue_allocate(struct ipw2100_priv *priv,
 			     struct ipw2100_bd_queue *q, int entries)
 {
-	IPW_DEBUG_INFO("enter\n");
-
 	memset(q, 0, sizeof(struct ipw2100_bd_queue));
 
 	q->entries = entries;
@@ -4196,17 +3496,12 @@
 		return -ENOMEM;
 	}
 	memset(q->drv, 0, q->size);
-
-	IPW_DEBUG_INFO("exit\n");
-
 	return 0;
 }
 
 static void bd_queue_free(struct ipw2100_priv *priv,
 			  struct ipw2100_bd_queue *q)
 {
-	IPW_DEBUG_INFO("enter\n");
-
 	if (!q)
 		return;
 
@@ -4215,24 +3510,18 @@
 				    q->size, q->drv, q->nic);
 		q->drv = NULL;
 	}
-
-	IPW_DEBUG_INFO("exit\n");
 }
 
 static void bd_queue_initialize(
 	struct ipw2100_priv *priv, struct ipw2100_bd_queue * q,
 	u32 base, u32 size, u32 r, u32 w)
 {
-	IPW_DEBUG_INFO("enter\n");
-
 	IPW_DEBUG_INFO("initializing bd queue at virt=%p, phys=%08x\n", q->drv, q->nic);
 
 	write_register(priv->net_dev, base, q->nic);
 	write_register(priv->net_dev, size, q->entries);
 	write_register(priv->net_dev, r, q->oldest);
 	write_register(priv->net_dev, w, q->next);
-
-	IPW_DEBUG_INFO("exit\n");
 }
 
 static void ipw2100_kill_workqueue(struct ipw2100_priv *priv)
@@ -4256,11 +3545,9 @@
 	void *v;
 	dma_addr_t p;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	err = bd_queue_allocate(priv, &priv->tx_queue, TX_QUEUE_LENGTH);
 	if (err) {
-		IPW_DEBUG_ERROR("%s: failed bd_queue_allocate\n",
+		printk(KERN_ERR DRV_NAME ": %s: failed bd_queue_allocate\n",
 		       priv->net_dev->name);
 		return err;
 	}
@@ -4312,8 +3599,6 @@
 {
 	int i;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	/*
 	 * reinitialize packet info lists
 	 */
@@ -4352,17 +3637,12 @@
 			    IPW_MEM_HOST_SHARED_TX_QUEUE_BD_SIZE,
 			    IPW_MEM_HOST_SHARED_TX_QUEUE_READ_INDEX,
 			    IPW_MEM_HOST_SHARED_TX_QUEUE_WRITE_INDEX);
-
-	IPW_DEBUG_INFO("exit\n");
-
 }
 
 static void ipw2100_tx_free(struct ipw2100_priv *priv)
 {
 	int i;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	bd_queue_free(priv, &priv->tx_queue);
 
 	if (!priv->tx_buffers)
@@ -4383,8 +3663,6 @@
 
 	kfree(priv->tx_buffers);
 	priv->tx_buffers = NULL;
-
-	IPW_DEBUG_INFO("exit\n");
 }
 
 
@@ -4393,8 +3671,6 @@
 {
 	int i, j, err = -EINVAL;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	err = bd_queue_allocate(priv, &priv->rx_queue, RX_QUEUE_LENGTH);
 	if (err) {
 		IPW_DEBUG_INFO("failed bd_queue_allocate\n");
@@ -4416,11 +3692,8 @@
 		    GFP_KERNEL);
 	if (!priv->rx_buffers) {
 		IPW_DEBUG_INFO("can't allocate rx packet buffer table\n");
-
 		bd_queue_free(priv, &priv->rx_queue);
-
 		status_queue_free(priv);
-
 		return -ENOMEM;
 	}
 
@@ -4461,8 +3734,6 @@
 
 static void ipw2100_rx_initialize(struct ipw2100_priv *priv)
 {
-	IPW_DEBUG_INFO("enter\n");
-
 	priv->rx_queue.oldest = 0;
 	priv->rx_queue.available = priv->rx_queue.entries - 1;
 	priv->rx_queue.next = priv->rx_queue.entries - 1;
@@ -4479,16 +3750,12 @@
 	/* set up the status queue */
 	write_register(priv->net_dev, IPW_MEM_HOST_SHARED_RX_STATUS_BASE,
 		       priv->status_queue.nic);
-
-	IPW_DEBUG_INFO("exit\n");
 }
 
 static void ipw2100_rx_free(struct ipw2100_priv *priv)
 {
 	int i;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	bd_queue_free(priv, &priv->rx_queue);
 	status_queue_free(priv);
 
@@ -4507,8 +3774,6 @@
 
 	kfree(priv->rx_buffers);
 	priv->rx_buffers = NULL;
-
-	IPW_DEBUG_INFO("exit\n");
 }
 
 static int ipw2100_read_mac_address(struct ipw2100_priv *priv)
@@ -4549,8 +3814,6 @@
 
 	IPW_DEBUG_HC("SET_MAC_ADDRESS\n");
 
-	IPW_DEBUG_INFO("enter\n");
-
 	if (priv->config & CFG_CUSTOM_MAC) {
 		memcpy(cmd.host_command_parameters, priv->mac_addr,
 		       ETH_ALEN);
@@ -4560,8 +3823,6 @@
 		       ETH_ALEN);
 
 	err = ipw2100_hw_send_command(priv, &cmd);
-
-	IPW_DEBUG_INFO("exit\n");
 	return err;
 }
 
@@ -4948,8 +4168,6 @@
 	int err;
 	int len;
 
-	IPW_DEBUG_HC("DISASSOCIATION_BSSID\n");
-
 	len = ETH_ALEN;
 	/* The Firmware currently ignores the BSSID and just disassociates from
 	 * the currently associated AP -- but in the off chance that a future
@@ -5009,8 +4196,6 @@
 	};
 	int err;
 
-	IPW_DEBUG_HC("SET_WPA_IE\n");
-
 	if (!batch_mode) {
 		err = ipw2100_disable_adapter(priv);
 		if (err)
@@ -5136,8 +4321,6 @@
 
 	cmd.host_command_parameters[0] = interval;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	if (priv->ieee->iw_mode == IW_MODE_ADHOC) {
 		if (!batch_mode) {
 			err = ipw2100_disable_adapter(priv);
@@ -5153,9 +4336,6 @@
 				return err;
 		}
 	}
-
-	IPW_DEBUG_INFO("exit\n");
-
 	return 0;
 }
 
@@ -5515,8 +4695,6 @@
 	int batch_mode = 1;
 	u8 *bssid;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	err = ipw2100_disable_adapter(priv);
 	if (err)
 		return err;
@@ -5525,9 +4703,6 @@
 		err = ipw2100_set_channel(priv, priv->channel, batch_mode);
 		if (err)
 			return err;
-
-		IPW_DEBUG_INFO("exit\n");
-
 		return 0;
 	}
 #endif /* CONFIG_IPW2100_MONITOR */
@@ -5604,9 +4779,6 @@
 	  if (err)
 	  return err;
 	*/
-
-	IPW_DEBUG_INFO("exit\n");
-
 	return 0;
 }
 
@@ -5669,8 +4841,6 @@
 	struct list_head *element;
 	struct ipw2100_tx_packet *packet;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	spin_lock_irqsave(&priv->low_lock, flags);
 
 	if (priv->status & STATUS_ASSOCIATED)
@@ -5692,9 +4862,6 @@
 		INC_STAT(&priv->tx_free_stat);
 	}
 	spin_unlock_irqrestore(&priv->low_lock, flags);
-
-	IPW_DEBUG_INFO("exit\n");
-
 	return 0;
 }
 
@@ -6449,8 +5616,6 @@
 	int registered = 0;
 	u32 val;
 
-	IPW_DEBUG_INFO("enter\n");
-
 	mem_start = pci_resource_start(pci_dev, 0);
 	mem_len = pci_resource_len(pci_dev, 0);
 	mem_flags = pci_resource_flags(pci_dev, 0);
@@ -6598,8 +5763,6 @@
 		ipw2100_start_scan(priv);
 	}
 
-	IPW_DEBUG_INFO("exit\n");
-
 	priv->status |= STATUS_INITIALIZED;
 
 	up(&priv->action_sem);
@@ -6689,17 +5851,11 @@
 
 	pci_release_regions(pci_dev);
 	pci_disable_device(pci_dev);
-
-	IPW_DEBUG_INFO("exit\n");
 }
 
 
 #ifdef CONFIG_PM
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,11)
-static int ipw2100_suspend(struct pci_dev *pci_dev, u32 state)
-#else
 static int ipw2100_suspend(struct pci_dev *pci_dev, pm_message_t state)
-#endif
 {
 	struct ipw2100_priv *priv = pci_get_drvdata(pci_dev);
 	struct net_device *dev = priv->net_dev;
@@ -8288,8 +7444,6 @@
 
 	down(&priv->action_sem);
 
-	IPW_DEBUG_WX("enter\n");
-
 	up(&priv->action_sem);
 
 	wrqu.ap_addr.sa_family = ARPHRD_ETHER;

-- 
teflon -- maybe it is a trademark, but it should not be.
