From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] spidernet: Use pci_dma_mapping_error()
Date: Wed, 27 Sep 2006 14:02:26 -0500
Message-ID: <20060927140226.6f215273@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:45786 "EHLO mail.lixom.net")
	by vger.kernel.org with ESMTP id S1030642AbWI0TDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 15:03:05 -0400
To: Utz Bacher <utz.bacher@de.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>, jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A driver shouldn't compare to DMA_ERROR_CODE directly, use
pci_dma_mapping_error() instead.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: linux-2.6/drivers/net/spider_net.c
===================================================================
--- linux-2.6.orig/drivers/net/spider_net.c
+++ linux-2.6/drivers/net/spider_net.c
@@ -317,7 +317,7 @@ spider_net_init_chain(struct spider_net_
 				     SPIDER_NET_DESCR_SIZE,
 				     direction);
 
-		if (buf == DMA_ERROR_CODE)
+		if (pci_dma_mapping_error(buf))
 			goto iommu_error;
 
 		descr->bus_addr = buf;
@@ -420,7 +420,7 @@ spider_net_prepare_rx_descr(struct spide
 	buf = pci_map_single(card->pdev, descr->skb->data,
 			SPIDER_NET_MAX_FRAME, PCI_DMA_FROMDEVICE);
 	descr->buf_addr = buf;
-	if (buf == DMA_ERROR_CODE) {
+	if (pci_dma_mapping_error(buf)) {
 		dev_kfree_skb_any(descr->skb);
 		if (netif_msg_rx_err(card) && net_ratelimit())
 			pr_err("Could not iommu-map rx buffer\n");
@@ -649,7 +649,7 @@ spider_net_prepare_tx_descr(struct spide
 	dma_addr_t buf;
 
 	buf = pci_map_single(card->pdev, skb->data, skb->len, PCI_DMA_TODEVICE);
-	if (buf == DMA_ERROR_CODE) {
+	if (pci_dma_mapping_error(buf)) {
 		if (netif_msg_tx_err(card) && net_ratelimit())
 			pr_err("could not iommu-map packet (%p, %i). "
 				  "Dropping packet\n", skb->data, skb->len);
