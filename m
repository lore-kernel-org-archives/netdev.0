From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 12/17 linux-2.6.7-rc2] prism54: Add likely/unlikely (resend again)
Date: Sat, 5 Jun 2004 15:51:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406051551.07667.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_L/cwA561oBMa7vW"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_L/cwA561oBMa7vW
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Previous patch 12 doesn't compile, sorry.
Other patches unaffected.

* islpci_eth.c : Do some likely/unlikely




--Boundary-00=_L/cwA561oBMa7vW
Content-Type: text/x-diff;
  charset="us-ascii";
  name="12-add-likely.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="12-add-likely.patch"

diff -NaurEbB linux-2.6.6ct/drivers/net/wireless/prism54/islpci_eth.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_eth.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_eth.c	2004-05-28 14:41:32.820447976 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_eth.c	2004-05-28 15:33:42.187711840 +0200
@@ -105,7 +105,7 @@
 
 	/* check whether the destination queue has enough fragments for the frame */
 	curr_frag = le32_to_cpu(cb->driver_curr_frag[ISL38XX_CB_TX_DATA_LQ]);
-	if (curr_frag - priv->free_data_tx >= ISL38XX_CB_TX_QSIZE) {
+	if (unlikely(curr_frag - priv->free_data_tx >= ISL38XX_CB_TX_QSIZE)) {
 		printk(KERN_ERR "%s: transmit device queue full when awake\n",
 		       ndev->name);
 		netif_stop_queue(ndev);
@@ -121,7 +121,7 @@
 	/* Check alignment and WDS frame formatting. The start of the packet should
 	 * be aligned on a 4-byte boundary. If WDS is enabled add another 6 bytes
 	 * and add WDS address information */
-	if (((long) skb->data & 0x03) | init_wds) {
+	if (unlikely(((long) skb->data & 0x03) | init_wds)) {
 		/* get the number of bytes to add and re-allign */
 		offset = (4 - (long) skb->data) & 0x03;
 		offset += init_wds ? 6 : 0;
@@ -192,7 +192,7 @@
 	pci_map_address = pci_map_single(priv->pdev,
 					 (void *) skb->data, skb->len,
 					 PCI_DMA_TODEVICE);
-	if (pci_map_address == 0) {
+	if (unlikely(pci_map_address == 0)) {
 		printk(KERN_WARNING "%s: cannot map buffer to PCI\n",
 		       ndev->name);
 
@@ -382,10 +382,10 @@
 	skb->dev = ndev;
 
 	/* take care of monitor mode and spy monitoring. */
-	if (priv->iw_mode == IW_MODE_MONITOR)
+	if (unlikely(priv->iw_mode == IW_MODE_MONITOR))
 		discard = islpci_monitor_rx(priv, &skb);
 	else {
-		if (skb->data[2 * ETH_ALEN] == 0) {
+		if (unlikely(skb->data[2 * ETH_ALEN] == 0)) {
 			/* The packet has a rx_annex. Read it for spy monitoring, Then
 			 * remove it, while keeping the 2 leading MAC addr.
 			 */
@@ -418,7 +418,7 @@
 	     skb->data[0], skb->data[1], skb->data[2], skb->data[3],
 	     skb->data[4], skb->data[5]);
 #endif
-	if (discard) {
+	if (unlikely(discard)) {
 		dev_kfree_skb(skb);
 		skb = NULL;
 	} else
@@ -434,7 +434,8 @@
 	       index - priv->free_data_rx < ISL38XX_CB_RX_QSIZE) {
 		/* allocate an sk_buff for received data frames storage
 		 * include any required allignment operations */
-		if (skb = dev_alloc_skb(MAX_FRAGMENT_SIZE_RX + 2), skb == NULL) {
+		skb = dev_alloc_skb(MAX_FRAGMENT_SIZE_RX + 2);
+		if (unlikely(skb == NULL)) {
 			/* error allocating an sk_buff structure elements */
 			DEBUG(SHOW_ERROR_MESSAGES, "Error allocating skb \n");
 			break;
@@ -454,7 +455,7 @@
 		    pci_map_single(priv->pdev, (void *) skb->data,
 				   MAX_FRAGMENT_SIZE_RX + 2,
 				   PCI_DMA_FROMDEVICE);
-		if (priv->pci_map_rx_address[index] == (dma_addr_t) NULL) {
+		if (unlikely(priv->pci_map_rx_address[index] == (dma_addr_t) NULL)) {
 			/* error mapping the buffer to device accessable memory address */
 			DEBUG(SHOW_ERROR_MESSAGES,
 			      "Error mapping DMA address\n");

--Boundary-00=_L/cwA561oBMa7vW--
