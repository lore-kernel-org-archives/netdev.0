From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.4.28-pre1] prism54 Update to 2.6
	status
Date: Mon, 16 Aug 2004 17:55:52 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200408161755.52667.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_IkNIBxrWR6VRArX"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org,
	marcelo.tosatti@cyclades.com
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_IkNIBxrWR6VRArX
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-08-16 Margit Schubert-While <margitsw@t-online.de>

* This rollup patch brings 2.4 into line with current
* and pending 2.6 status as of today.
* The code base is IDENTICAL for both 2.4 and 2.6 with
* the exception of an extra compatibility header for 2.4.

* There is no point in doing a split out for this patch
* as all changes have already been individually posted
* against 2.6 and passed through Jeff.

* As of now, we can post one patch for both kernels.
* I have included Marcelo in the CC so that he is informed.

Margit















--Boundary-00=_IkNIBxrWR6VRArX
Content-Type: text/x-diff;
  charset="us-ascii";
  name="248rollup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="248rollup.patch"

diff -Naur linux-2.4.28-01/drivers/net/wireless/prism54/isl_38xx.c linux-2.4.28-02/drivers/net/wireless/prism54/isl_38xx.c
--- linux-2.4.28-01/drivers/net/wireless/prism54/isl_38xx.c	2004-08-16 17:31:11.000000000 +0200
+++ linux-2.4.28-02/drivers/net/wireless/prism54/isl_38xx.c	2004-08-16 17:38:05.000000000 +0200
@@ -135,8 +135,8 @@
 		      readl(device_base + ISL38XX_CTRL_STAT_REG));
 		udelay(ISL38XX_WRITEIO_DELAY);
 
-		if (reg = readl(device_base + ISL38XX_INT_IDENT_REG),
-		    reg == 0xabadface) {
+		reg = readl(device_base + ISL38XX_INT_IDENT_REG);
+		if (reg == 0xabadface) {
 #if VERBOSE > SHOW_ERROR_MESSAGES
 			do_gettimeofday(&current_time);
 			DEBUG(SHOW_TRACING,
@@ -194,10 +194,8 @@
 void
 isl38xx_interface_reset(void *device_base, dma_addr_t host_address)
 {
-	u32 reg;
-
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "isl38xx_interface_reset \n");
+	DEBUG(SHOW_FUNCTION_CALLS, "isl38xx_interface_reset\n");
 #endif
 
 	/* load the address of the control block in the device */
@@ -205,8 +203,7 @@
 	udelay(ISL38XX_WRITEIO_DELAY);
 
 	/* set the reset bit in the Device Interrupt Register */
-	isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_RESET,
-			  ISL38XX_DEV_INT_REG);
+	isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_RESET, ISL38XX_DEV_INT_REG);
 	udelay(ISL38XX_WRITEIO_DELAY);
 
 	/* enable the interrupt for detecting initialization */
@@ -214,9 +211,7 @@
 	/* Note: Do not enable other interrupts here. We want the
 	 * device to have come up first 100% before allowing any other 
 	 * interrupts. */
-	reg = ISL38XX_INT_IDENT_INIT;
-
-	isl38xx_w32_flush(device_base, reg, ISL38XX_INT_EN_REG);
+	isl38xx_w32_flush(device_base, ISL38XX_INT_IDENT_INIT, ISL38XX_INT_EN_REG);
 	udelay(ISL38XX_WRITEIO_DELAY);  /* allow complete full reset */
 }
 
diff -Naur linux-2.4.28-01/drivers/net/wireless/prism54/isl_38xx.h linux-2.4.28-02/drivers/net/wireless/prism54/isl_38xx.h
--- linux-2.4.28-01/drivers/net/wireless/prism54/isl_38xx.h	2004-08-16 17:31:11.000000000 +0200
+++ linux-2.4.28-02/drivers/net/wireless/prism54/isl_38xx.h	2004-08-16 17:38:00.000000000 +0200
@@ -95,6 +95,10 @@
 #define ISL38XX_INT_SOURCES                     0x001E
 
 /* Control/Status register bits */
+/* Looks like there are other meaningful bits
+    0x20004400 seen in normal operation,
+    0x200044db at 'timeout waiting for mgmt response'
+*/
 #define ISL38XX_CTRL_STAT_SLEEPMODE             0x00000200
 #define	ISL38XX_CTRL_STAT_CLKRUN		0x00800000
 #define ISL38XX_CTRL_STAT_RESET                 0x10000000
diff -Naur linux-2.4.28-01/drivers/net/wireless/prism54/isl_ioctl.c linux-2.4.28-02/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.4.28-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-16 17:31:11.000000000 +0200
+++ linux-2.4.28-02/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-16 17:38:05.000000000 +0200
@@ -334,9 +334,10 @@
 	int rvalue;
 
 	rvalue = mgt_get_request(priv, DOT11_OID_CHANNEL, 0, NULL, &r);
-
+	fwrq->i = r.u;
+	rvalue |= mgt_get_request(priv, DOT11_OID_FREQUENCY, 0, NULL, &r);
 	fwrq->m = r.u;
-	fwrq->e = 0;
+	fwrq->e = 3;
 
 	return rvalue;
 }
@@ -436,7 +437,7 @@
 {
 	struct iw_range *range = (struct iw_range *) extra;
 	islpci_private *priv = netdev_priv(ndev);
-	char *data;
+	u8 *data;
 	int i, m, rvalue;
 	struct obj_frequencies *freq;
 	union oid_res_t r;
@@ -513,8 +514,7 @@
 	i = 0;
 	while ((i < IW_MAX_BITRATES) && (*data != 0)) {
 		/*       the result must be in bps. The card gives us 500Kbps */
-		range->bitrate[i] = (__s32) (*data >> 1);
-		range->bitrate[i] *= 1000000;
+		range->bitrate[i] = *data * 500000;
 		i++;
 		data++;
 	}
@@ -820,9 +820,11 @@
 		return mgt_set_request(priv, DOT11_OID_PROFILES, 0, &profile);
 	}
 
-	if ((ret =
-	     mgt_get_request(priv, DOT11_OID_SUPPORTEDRATES, 0, NULL, &r)))
+	ret = mgt_get_request(priv, DOT11_OID_SUPPORTEDRATES, 0, NULL, &r);
+	if (ret) {
+		kfree(r.ptr);
 		return ret;
+	}
 
 	rate = (u32) (vwrq->value / 500000);
 	data = r.ptr;
@@ -840,6 +842,7 @@
 	}
 
 	if (!data[i]) {
+		kfree(r.ptr);
 		return -EINVAL;
 	}
 
@@ -888,8 +891,11 @@
 	vwrq->value = r.u * 500000;
 
 	/* request the device for the enabled rates */
-	if ((rvalue = mgt_get_request(priv, DOT11_OID_RATES, 0, NULL, &r)))
+	rvalue = mgt_get_request(priv, DOT11_OID_RATES, 0, NULL, &r);
+	if (rvalue) {
+		kfree(r.ptr);
 		return rvalue;
+	}
 	data = r.ptr;
 	vwrq->fixed = (data[0] != 0) && (data[1] == 0);
 	kfree(r.ptr);
@@ -1941,8 +1947,8 @@
 		      struct iw_point *data, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	struct islpci_mgmtframe *response = NULL;
-	int ret = -EIO, response_op = PIMFOR_OP_ERROR;
+	struct islpci_mgmtframe *response;
+	int ret = -EIO;
 
 	printk("%s: get_oid 0x%08X\n", ndev->name, priv->priv_oid);
 	data->length = 0;
@@ -1952,9 +1958,7 @@
 		    islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
 					   priv->priv_oid, extra, 256,
 					   &response);
-		response_op = response->header->operation;
 		printk("%s: ret: %i\n", ndev->name, ret);
-		printk("%s: response_op: %i\n", ndev->name, response_op);
 		if (ret || !response
 		    || response->header->operation == PIMFOR_OP_ERROR) {
 			if (response) {
@@ -1979,7 +1983,7 @@
 		      struct iw_point *data, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	struct islpci_mgmtframe *response = NULL;
+	struct islpci_mgmtframe *response;
 	int ret = 0, response_op = PIMFOR_OP_ERROR;
 
 	printk("%s: set_oid 0x%08X\tlen: %d\n", ndev->name, priv->priv_oid,
@@ -1991,16 +1995,20 @@
 					   priv->priv_oid, extra, data->length,
 					   &response);
 		printk("%s: ret: %i\n", ndev->name, ret);
+		if (ret || !response
+		    || response->header->operation == PIMFOR_OP_ERROR) {
+			if (response) {
+				islpci_mgt_release(response);
+			}
+			printk("%s: EIO\n", ndev->name);
+			ret = -EIO;
+		}
 		if (!ret) {
 			response_op = response->header->operation;
 			printk("%s: response_op: %i\n", ndev->name,
 			       response_op);
 			islpci_mgt_release(response);
 		}
-		if (ret || response_op == PIMFOR_OP_ERROR) {
-			printk("%s: EIO\n", ndev->name);
-			ret = -EIO;
-		}
 	}
 
 	return (ret ? ret : -EINPROGRESS);
diff -Naur linux-2.4.28-01/drivers/net/wireless/prism54/islpci_dev.c linux-2.4.28-02/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.4.28-01/drivers/net/wireless/prism54/islpci_dev.c	2004-08-16 17:31:11.000000000 +0200
+++ linux-2.4.28-02/drivers/net/wireless/prism54/islpci_dev.c	2004-08-16 17:38:05.000000000 +0200
@@ -39,6 +39,7 @@
 #include "oid_mgt.h"
 
 #define ISL3877_IMAGE_FILE	"isl3877"
+#define ISL3886_IMAGE_FILE	"isl3886"
 #define ISL3890_IMAGE_FILE	"isl3890"
 
 static int prism54_bring_down(islpci_private *);
@@ -82,7 +83,7 @@
 	mdelay(50);
 
 	{
-		const struct firmware *fw_entry = 0;
+		const struct firmware *fw_entry = NULL;
 		long fw_len;
 		const u32 *fw_ptr;
 
@@ -185,6 +186,9 @@
 	void *device = priv->device_base;
 	int powerstate = ISL38XX_PSM_POWERSAVE_STATE;
 
+	/* lock the interrupt handler */
+	spin_lock(&priv->slock);
+
 	/* received an interrupt request on a shared IRQ line
 	 * first check whether the device is in sleep mode */
 	reg = readl(device + ISL38XX_CTRL_STAT_REG);
@@ -194,14 +198,10 @@
 #if VERBOSE > SHOW_ERROR_MESSAGES
 		DEBUG(SHOW_TRACING, "Assuming someone else called the IRQ\n");
 #endif
+		spin_unlock(&priv->slock);
 		return IRQ_NONE;
 	}
 
-	if (islpci_get_state(priv) != PRV_STATE_SLEEP)
-		powerstate = ISL38XX_PSM_ACTIVE_STATE;
-
-	/* lock the interrupt handler */
-	spin_lock(&priv->slock);
 
 	/* check whether there is any source of interrupt on the device */
 	reg = readl(device + ISL38XX_INT_IDENT_REG);
@@ -212,6 +212,9 @@
 	reg &= ISL38XX_INT_SOURCES;
 
 	if (reg != 0) {
+		if (islpci_get_state(priv) != PRV_STATE_SLEEP)
+			powerstate = ISL38XX_PSM_ACTIVE_STATE;
+
 		/* reset the request bits in the Identification register */
 		isl38xx_w32_flush(device, reg, ISL38XX_INT_ACK_REG);
 
@@ -339,6 +342,12 @@
 			isl38xx_handle_wakeup(priv->control_block,
 					      &powerstate, priv->device_base);
 		}
+	} else {
+#if VERBOSE > SHOW_ERROR_MESSAGES
+		DEBUG(SHOW_TRACING, "Assuming someone else called the IRQ\n");
+#endif
+		spin_unlock(&priv->slock);
+		return IRQ_NONE;
 	}
 
 	/* sleep -> ready */
@@ -366,8 +375,6 @@
 	u32 rc;
 	islpci_private *priv = netdev_priv(ndev);
 
-	printk(KERN_DEBUG "%s: islpci_open()\n", ndev->name);
-
 	/* reset data structures, upload firmware and reset device */
 	rc = islpci_reset(priv,1);
 	if (rc) {
@@ -453,8 +460,7 @@
 		return rc;
 	}
 
-	printk(KERN_DEBUG
-	       "%s: firmware uploaded done, now triggering reset...\n",
+	printk(KERN_DEBUG "%s: firmware upload complete\n",
 	       priv->ndev->name);
 
 	islpci_set_state(priv, PRV_STATE_POSTBOOT);
@@ -490,15 +496,16 @@
 		/* If we're here it's because our IRQ hasn't yet gone through. 
 		 * Retry a bit more...
 		 */
-		 printk(KERN_ERR "%s: device soft reset timed out\n",
-		       priv->ndev->name);
-
+		printk(KERN_ERR "%s: reset problem: no 'reset complete' IRQ seen\n",
+			priv->ndev->name);
 	}
 
 	finish_wait(&priv->reset_done, &wait);
 
-	if(result)
+	if (result) {
+		printk(KERN_ERR "%s: islpci_reset_if: failure\n", priv->ndev->name);
 		return result;
+	}
 
 	islpci_set_state(priv, PRV_STATE_INIT);
 
@@ -515,6 +522,7 @@
 
 	islpci_set_state(priv, PRV_STATE_READY);
 
+	printk(KERN_DEBUG "%s: interface reset complete\n", priv->ndev->name);
 	return 0;
 }
 
@@ -575,18 +583,18 @@
 	/* now that the data structures are cleaned up, upload
 	 * firmware and reset interface */
 		rc = islpci_upload_fw(priv);
-		if (rc) 
+		if (rc) {
+			printk(KERN_ERR "%s: islpci_reset: failure\n",
+				priv->ndev->name);
 			return rc;
+		}
 	}
 
 	/* finally reset interface */
 	rc = islpci_reset_if(priv);
-	if (!rc) /* If successful */
-		return rc;
-	
-	printk(KERN_DEBUG  "prism54: Your card/socket may be faulty, or IRQ line too busy :(\n");
+	if (rc)
+		printk(KERN_ERR "prism54: Your card/socket may be faulty, or IRQ line too busy :(\n");
 	return rc;
-
 }
 
 struct net_device_stats *
@@ -595,7 +603,7 @@
 	islpci_private *priv = netdev_priv(ndev);
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "islpci_statistics \n");
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_statistics\n");
 #endif
 
 	return &priv->statistics;
@@ -716,7 +724,7 @@
 
 	if (priv->device_base)
 		iounmap(priv->device_base);
-	priv->device_base = 0;
+	priv->device_base = NULL;
 
 	/* free consistent DMA area... */
 	if (priv->driver_mem_address)
@@ -725,10 +733,10 @@
 				    priv->device_host_address);
 
 	/* clear some dangling pointers */
-	priv->driver_mem_address = 0;
+	priv->driver_mem_address = NULL;
 	priv->device_host_address = 0;
 	priv->device_psm_buffer = 0;
-	priv->control_block = 0;
+	priv->control_block = NULL;
 
         /* clean up mgmt rx buffers */
         for (counter = 0; counter < ISL38XX_CB_MGMT_QSIZE; counter++) {
@@ -754,7 +762,7 @@
 
 		if (priv->data_low_rx[counter])
 			dev_kfree_skb(priv->data_low_rx[counter]);
-		priv->data_low_rx[counter] = 0;
+		priv->data_low_rx[counter] = NULL;
 	}
 
 	/* Free the acces control list and the WPA list */
@@ -856,14 +864,14 @@
 
 	/* select the firmware file depending on the device id */
 	switch (pdev->device) {
-	case PCIDEVICE_ISL3890:
-	case PCIDEVICE_3COM6001:
-		strcpy(priv->firmware, ISL3890_IMAGE_FILE);
-		break;
-	case PCIDEVICE_ISL3877:
+	case 0x3877:
 		strcpy(priv->firmware, ISL3877_IMAGE_FILE);
 		break;
 
+	case 0x3886:
+		strcpy(priv->firmware, ISL3886_IMAGE_FILE);
+		break;
+
 	default:
 		strcpy(priv->firmware, ISL3890_IMAGE_FILE);
 		break;
@@ -880,9 +888,9 @@
       do_islpci_free_memory:
 	islpci_free_memory(priv);
       do_free_netdev:
-	pci_set_drvdata(pdev, 0);
+	pci_set_drvdata(pdev, NULL);
 	free_netdev(ndev);
-	priv = 0;
+	priv = NULL;
 	return NULL;
 }
 
diff -Naur linux-2.4.28-01/drivers/net/wireless/prism54/islpci_eth.c linux-2.4.28-02/drivers/net/wireless/prism54/islpci_eth.c
--- linux-2.4.28-01/drivers/net/wireless/prism54/islpci_eth.c	2004-08-16 17:31:11.000000000 +0200
+++ linux-2.4.28-02/drivers/net/wireless/prism54/islpci_eth.c	2004-08-16 17:38:05.000000000 +0200
@@ -508,11 +508,12 @@
 	/* increment the transmit error counter */
 	statistics->tx_errors++;
 
+	printk(KERN_WARNING "%s: tx_timeout", ndev->name);
 	if (!priv->reset_task_pending) {
 		priv->reset_task_pending = 1;
+		printk(", scheduling a reset");
 		netif_stop_queue(ndev);
 		schedule_work(&priv->reset_task);
 	}
-
-	return;
+	printk("\n");
 }
diff -Naur linux-2.4.28-01/drivers/net/wireless/prism54/islpci_hotplug.c linux-2.4.28-02/drivers/net/wireless/prism54/islpci_hotplug.c
--- linux-2.4.28-01/drivers/net/wireless/prism54/islpci_hotplug.c	2004-08-16 17:31:11.000000000 +0200
+++ linux-2.4.28-02/drivers/net/wireless/prism54/islpci_hotplug.c	2004-08-16 17:38:05.000000000 +0200
@@ -44,102 +44,30 @@
  * If you have an update for this please contact prism54-devel@prism54.org 
  * The latest list can be found at http://prism54.org/supported_cards.php */
 static const struct pci_device_id prism54_id_tbl[] = {
-	/* 3COM 3CRWE154G72 Wireless LAN adapter */
-	{
-	 PCIVENDOR_3COM, PCIDEVICE_3COM6001,
-	 PCIVENDOR_3COM, PCIDEVICE_3COM6001,
-	 0, 0, 0
-	},
-
-	/* D-Link Air Plus Xtreme G A1 - DWL-g650 A1 */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_DLINK, 0x3202UL, 
-	 0, 0, 0
-	},
-
-	/* I-O Data WN-G54/CB - WN-G54/CB */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_IODATA, 0xd019UL, 
-	 0, 0, 0
-	},
-
-	/* Netgear WG511 */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_NETGEAR, 0x4800UL,
-	 0, 0, 0
-	},
-
-	/* Tekram Technology clones, Allnet, Netcomm, Zyxel */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_TTL, 0x1605UL,
-	 0, 0, 0
-	},
-
-	/* SMC2802W */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_SMC, 0x2802UL,
-	 0, 0, 0
-	},
-
-	/* SMC2835W */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_SMC, 0x2835UL,
-	 0, 0, 0
-	},
-
-	/* Corega CG-WLCB54GT */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_ATI, 0xc104UL,
-	 0, 0, 0
-	},
-
-	/* I4 Z-Com XG-600 */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_I4, 0x0014UL,
-	 0, 0, 0
-	},
-
-	/* I4 Z-Com XG-900  and clones Macer, Ovislink, Planex, Peabird, */
-	/* Sitecom, Xterasys */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_I4, 0x0020UL,
-	 0, 0, 0
-	},
-
-	/* SMC 2802W V2 */
+	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
 	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_ACCTON, 0xee03UL,
+	 0x1260, 0x3890,
+	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0, 0
 	},
 
-	/* SMC 2835W V2 */
+	/* 3COM 3CRWE154G72 Wireless LAN adapter */
 	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_SMC, 0xa835UL,
+	 0x10b7, 0x6001,
+	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0, 0
 	},
 
 	/* Intersil PRISM Indigo Wireless LAN adapter */
 	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3877,
+	 0x1260, 0x3877,
 	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0, 0
 	},
 
-	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
-	/* Default */
+	/* Intersil PRISM Javelin/Xbow Wireless LAN adapter */
 	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 0x1260, 0x3886,
 	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0, 0
 	},
@@ -166,85 +94,6 @@
 	/* .enable_wake ; we don't support this yet */
 };
 
-static void
-prism54_get_card_model(struct net_device *ndev)
-{
-	islpci_private	*priv;
-	char		*modelp;
-	int		notwork = 0;
-
-	priv = netdev_priv(ndev);
-	switch (priv->pdev->subsystem_device) {
-	case PCIDEVICE_ISL3877:
-		modelp = "PRISM Indigo";
-		break;
-	case PCIDEVICE_ISL3886:
-		modelp = "PRISM Javelin / Xbow";
-		break;
-	case PCIDEVICE_3COM6001:
-		modelp = "3COM 3CRWE154G72";
-		break;
-	case 0x3202UL:
-		modelp = "D-Link DWL-g650 A1";
-		break;
-	case 0xd019UL:
-		modelp = "WN-G54/CB";
-		break;
-	case 0x4800UL:
-		modelp = "Netgear WG511";
-		break;
-	case 0x2802UL:
-		modelp = "SMC2802W";
-		break;
-	case 0xee03UL:
-		modelp = "SMC2802W V2";
-		notwork = 1;
-		break;
-	case 0x2835UL:
-		modelp = "SMC2835W";
-		break;
-	case 0xa835UL:
-		modelp = "SMC2835W V2";
-		notwork = 1;
-		break;
-	case 0xc104UL:
-		modelp = "CG-WLCB54GT";
-		break;
-	case 0x1605UL:
-		modelp = "Tekram Technology clone";
-		break;
-	/* Let's leave this one out for now since it seems bogus/wrong 
-	 * Even if the manufacturer did use 0x0000UL it may not be correct
-	 * by their part, therefore deserving no name ;) */
-	/*      case 0x0000UL: 
-	 *              modelp = "SparkLAN WL-850F";
-	 *              break;*/
-
-	/* We have two reported for the one below :( */
-	case 0x0014UL:
-		modelp = "I4 Z-Com XG-600 and clones";
-		break;
-	case 0x0020UL:
-		modelp = "I4 Z-Com XG-900 and clones";
-		break;
-/* Default it */
-/*
-	case PCIDEVICE_ISL3890:
-		modelp = "PRISM Duette/GT";
-		break;
-*/
-	default:
-		modelp = "PRISM Duette/GT";
-	}
-	printk(KERN_DEBUG "%s: %s driver detected card model: %s\n",
-			ndev->name, DRV_NAME, modelp);
-	if ( notwork ) {
-		printk(KERN_DEBUG "%s: %s Warning - This may not work\n",
-			ndev->name, DRV_NAME);
-	}
-	return;
-}
-
 /******************************************************************************
     Module initialization functions
 ******************************************************************************/
@@ -354,17 +203,14 @@
 
 	/* firmware upload is triggered in islpci_open */
 
-	/* Pretty card model discovery output */
-	prism54_get_card_model(ndev);
-
 	return 0;
 
       do_unregister_netdev:
 	unregister_netdev(ndev);
 	islpci_free_memory(priv);
-	pci_set_drvdata(pdev, 0);
+	pci_set_drvdata(pdev, NULL);
 	free_netdev(ndev);
-	priv = 0;
+	priv = NULL;
       do_pci_release_regions:
 	pci_release_regions(pdev);
       do_pci_disable_device:
@@ -380,7 +226,7 @@
 prism54_remove(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
-	islpci_private *priv = ndev ? netdev_priv(ndev) : 0;
+	islpci_private *priv = ndev ? netdev_priv(ndev) : NULL;
 	BUG_ON(!priv);
 
 	if (!__in_cleanup_module) {
@@ -408,9 +254,9 @@
 	/* free the PCI memory and unmap the remapped page */
 	islpci_free_memory(priv);
 
-	pci_set_drvdata(pdev, 0);
+	pci_set_drvdata(pdev, NULL);
 	free_netdev(ndev);
-	priv = 0;
+	priv = NULL;
 
 	pci_release_regions(pdev);
 
@@ -421,7 +267,7 @@
 prism54_suspend(struct pci_dev *pdev, u32 state)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
-	islpci_private *priv = ndev ? netdev_priv(ndev) : 0;
+	islpci_private *priv = ndev ? netdev_priv(ndev) : NULL;
 	BUG_ON(!priv);
 
 	printk(KERN_NOTICE "%s: got suspend request (state %d)\n",
@@ -446,7 +292,7 @@
 prism54_resume(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
-	islpci_private *priv = ndev ? netdev_priv(ndev) : 0;
+	islpci_private *priv = ndev ? netdev_priv(ndev) : NULL;
 	BUG_ON(!priv);
 
 	printk(KERN_NOTICE "%s: got resume request\n", ndev->name);
diff -Naur linux-2.4.28-01/drivers/net/wireless/prism54/islpci_mgt.h linux-2.4.28-02/drivers/net/wireless/prism54/islpci_mgt.h
--- linux-2.4.28-01/drivers/net/wireless/prism54/islpci_mgt.h	2004-08-16 17:31:11.000000000 +0200
+++ linux-2.4.28-02/drivers/net/wireless/prism54/islpci_mgt.h	2004-08-16 17:38:00.000000000 +0200
@@ -38,21 +38,6 @@
 
 
 /* General driver definitions */
-#define PCIVENDOR_INTERSIL                      0x1260UL
-#define PCIVENDOR_3COM				0x10b7UL
-#define PCIVENDOR_DLINK				0x1186UL
-#define PCIVENDOR_I4				0x17cfUL
-#define PCIVENDOR_IODATA			0x10fcUL
-#define PCIVENDOR_NETGEAR			0x1385UL
-#define PCIVENDOR_SMC				0x10b8UL
-#define PCIVENDOR_ACCTON			0x1113UL
-#define PCIVENDOR_ATI				0x1259UL
-#define PCIVENDOR_TTL				0x16a5UL
-
-#define PCIDEVICE_ISL3877                       0x3877UL
-#define PCIDEVICE_ISL3886                       0x3886UL
-#define PCIDEVICE_ISL3890                       0x3890UL
-#define	PCIDEVICE_3COM6001			0x6001UL
 #define PCIDEVICE_LATENCY_TIMER_MIN 		0x40
 #define PCIDEVICE_LATENCY_TIMER_VAL 		0x50
 
diff -Naur linux-2.4.28-01/drivers/net/wireless/prism54/oid_mgt.c linux-2.4.28-02/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.4.28-01/drivers/net/wireless/prism54/oid_mgt.c	2004-08-16 17:31:11.000000000 +0200
+++ linux-2.4.28-02/drivers/net/wireless/prism54/oid_mgt.c	2004-08-16 17:38:05.000000000 +0200
@@ -219,7 +219,7 @@
 	OID_UNKNOWN(OID_INL_MEMORY, 0xFF020002),
 	OID_U32_C(OID_INL_MODE, 0xFF020003),
 	OID_UNKNOWN(OID_INL_COMPONENT_NR, 0xFF020004),
-	OID_UNKNOWN(OID_INL_VERSION, 0xFF020005),
+	OID_STRUCT(OID_INL_VERSION, 0xFF020005, u8[8], OID_TYPE_RAW),
 	OID_UNKNOWN(OID_INL_INTERFACE_ID, 0xFF020006),
 	OID_UNKNOWN(OID_INL_COMPONENT_ID, 0xFF020007),
 	OID_U32_C(OID_INL_CONFIG, 0xFF020008),
@@ -481,6 +481,8 @@
 	BUG_ON(OID_NUM_LAST <= n);
 	BUG_ON(extra > isl_oid[n].range);
 
+	res->ptr = NULL;
+
 	if (!priv->mib)
 		/* memory has been freed */
 		return -1;
@@ -553,15 +555,18 @@
 		u32 oid = t->oid;
 		BUG_ON(data == NULL);
 		while (j <= t->range) {
-			response = NULL;
-			ret |= islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
+			int r = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
 						      oid, data, t->size,
 						      &response);
 			if (response) {
-				ret |= (response->header->operation ==
-					PIMFOR_OP_ERROR);
+				r |= (response->header->operation == PIMFOR_OP_ERROR);
 				islpci_mgt_release(response);
 			}
+			if (r)
+				printk(KERN_ERR "%s: mgt_commit_list: failure. "
+					"oid=%08x err=%d\n",
+					priv->ndev->name, oid, r);
+			ret |= r;
 			j++;
 			oid++;
 			data += t->size;
@@ -613,14 +618,16 @@
 	DOT11_OID_DEFKEYID,
 	DOT11_OID_DOT1XENABLE,
 	OID_INL_DOT11D_CONFORMANCE,
+	/* Do not initialize this - fw < 1.0.4.3 rejects it
 	OID_INL_OUTPUTPOWER,
+	*/
 };
 
 /* update the MAC addr. */
 static int
 mgt_update_addr(islpci_private *priv)
 {
-	struct islpci_mgmtframe *res = NULL;
+	struct islpci_mgmtframe *res;
 	int ret;
 
 	ret = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
@@ -634,9 +641,13 @@
 	if (res)
 		islpci_mgt_release(res);
 
+	if (ret)
+		printk(KERN_ERR "%s: mgt_update_addr: failure\n", priv->ndev->name);
 	return ret;
 }
 
+#define VEC_SIZE(a) (sizeof(a)/sizeof(a[0]))
+
 void
 mgt_commit(islpci_private *priv)
 {
@@ -646,14 +657,10 @@
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return;
 
-	rvalue = mgt_commit_list(priv, commit_part1,
-				 sizeof (commit_part1) /
-				 sizeof (commit_part1[0]));
+	rvalue = mgt_commit_list(priv, commit_part1, VEC_SIZE(commit_part1));
 
 	if (priv->iw_mode != IW_MODE_MONITOR)
-		rvalue |= mgt_commit_list(priv, commit_part2,
-					  sizeof (commit_part2) /
-					  sizeof (commit_part2[0]));
+		rvalue |= mgt_commit_list(priv, commit_part2, VEC_SIZE(commit_part2));
 
 	u = OID_INL_MODE;
 	rvalue |= mgt_commit_list(priv, &u, 1);
@@ -662,8 +669,7 @@
 	if (rvalue) {
 		/* some request have failed. The device might be in an
 		   incoherent state. We should reset it ! */
-		printk(KERN_DEBUG "%s: mgt_commit has failed. Restart the "
-		       "device \n", priv->ndev->name);
+		printk(KERN_DEBUG "%s: mgt_commit: failure\n", priv->ndev->name);
 	}
 }
 
diff -Naur linux-2.4.28-01/drivers/net/wireless/prism54/prismcompat24.h linux-2.4.28-02/drivers/net/wireless/prism54/prismcompat24.h
--- linux-2.4.28-01/drivers/net/wireless/prism54/prismcompat24.h	2004-08-16 17:31:11.000000000 +0200
+++ linux-2.4.28-02/drivers/net/wireless/prism54/prismcompat24.h	2004-08-16 17:38:00.000000000 +0200
@@ -52,7 +52,7 @@
 #define schedule_work		schedule_task
 
 #if !defined(HAVE_NETDEV_PRIV)
-#define netdev_priv(x)		x->priv
+#define netdev_priv(x)		(x)->priv
 #endif
 
 #if !defined(CONFIG_FW_LOADER) && !defined(CONFIG_FW_LOADER_MODULE)

--Boundary-00=_IkNIBxrWR6VRArX
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_IkNIBxrWR6VRArX--
