From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: [PATCH] vxge: use pci_dma_mapping_error to test return value
Date: Wed, 6 Jan 2010 00:16:59 +0300
Message-ID: <20100105211659.GA12882@coldcone>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:35504 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754704Ab0AEVPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 16:15:11 -0500
Received: by fxm25 with SMTP id 25so10217448fxm.21
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2010 13:15:09 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pci_dma_mapping_error should be used to test return value of
pci_map_single or pci_map_page.

Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>
---

drivers/net/vxge/vxge-main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 0fdfd58..f7ed495 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -310,7 +310,7 @@ static int vxge_rx_map(void *dtrh, struct vxge_ring *ring)
 	dma_addr = pci_map_single(ring->pdev, rx_priv->skb_data,
 				rx_priv->data_size, PCI_DMA_FROMDEVICE);
 
-	if (dma_addr == 0) {
+	if (unlikely(pci_dma_mapping_error(ring->pdev, dma_addr))) {
 		ring->stats.pci_map_fail++;
 		return -EIO;
 	}
@@ -821,7 +821,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 	int frg_cnt, first_frg_len;
 	skb_frag_t *frag;
 	int i = 0, j = 0, avail;
-	u64 dma_pointer;
+	dma_addr_t dma_pointer;
 	struct vxge_tx_priv *txdl_priv = NULL;
 	struct __vxge_hw_fifo *fifo_hw;
 	int offload_type;
