From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 9/14] Spidernet Remove unused variable
Date: Wed, 13 Dec 2006 15:19:54 -0600
Message-ID: <20061213211954.GI1915@austin.ibm.com>
References: <20061213210010.GR4329@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	Christoph Hellwig <hch@infradead.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>,
	James K Lewis <jim@jklewis.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:57651 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbWLMVT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 16:19:57 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDLJvxd014609
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 16:19:57 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDLJueJ447962
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 14:19:56 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDLJtNq014231
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 14:19:56 -0700
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061213210010.GR4329@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remove unused variable; this makes code easier to read.
Tweak commentary.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-13 14:28:11.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-13 14:28:15.000000000 -0600
@@ -367,21 +367,20 @@ spider_net_free_rx_chain_contents(struct
 }
 
 /**
- * spider_net_prepare_rx_descr - reinitializes a rx descriptor
+ * spider_net_prepare_rx_descr - Reinitialize RX descriptor
  * @card: card structure
  * @descr: descriptor to re-init
  *
- * return 0 on succes, <0 on failure
+ * Return 0 on succes, <0 on failure.
  *
- * allocates a new rx skb, iommu-maps it and attaches it to the descriptor.
- * Activate the descriptor state-wise
+ * Allocates a new rx skb, iommu-maps it and attaches it to the
+ * descriptor. Mark the descriptor as activated, ready-to-use.
  */
 static int
 spider_net_prepare_rx_descr(struct spider_net_card *card,
 			    struct spider_net_descr *descr)
 {
 	dma_addr_t buf;
-	int error = 0;
 	int offset;
 	int bufsize;
 
@@ -409,7 +408,7 @@ spider_net_prepare_rx_descr(struct spide
 		(SPIDER_NET_RXBUF_ALIGN - 1);
 	if (offset)
 		skb_reserve(descr->skb, SPIDER_NET_RXBUF_ALIGN - offset);
-	/* io-mmu-map the skb */
+	/* iommu-map the skb */
 	buf = pci_map_single(card->pdev, descr->skb->data,
 			SPIDER_NET_MAX_FRAME, PCI_DMA_FROMDEVICE);
 	descr->buf_addr = buf;
@@ -424,7 +423,7 @@ spider_net_prepare_rx_descr(struct spide
 					 SPIDER_NET_DMAC_NOINTR_COMPLETE;
 	}
 
-	return error;
+	return 0;
 }
 
 /**
