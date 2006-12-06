From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 10/16] Spidernet Remove unused variable
Date: Wed, 6 Dec 2006 17:41:18 -0600
Message-ID: <20061206234117.GJ4649@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:33446 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937807AbWLFXlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 18:41:25 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB6NfOkF020644
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:41:24 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB6NfOo5212898
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:41:24 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB6NfNoE002778
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:41:24 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206223223.GH17931@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remove unused variable; this makes code easier to read.
Tweak commentary.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-06 16:03:09.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-06 16:03:11.000000000 -0600
@@ -341,17 +341,16 @@ spider_net_free_rx_chain_contents(struct
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
 
@@ -379,7 +378,7 @@ spider_net_prepare_rx_descr(struct spide
 		(SPIDER_NET_RXBUF_ALIGN - 1);
 	if (offset)
 		skb_reserve(descr->skb, SPIDER_NET_RXBUF_ALIGN - offset);
-	/* io-mmu-map the skb */
+	/* iommu-map the skb */
 	buf = pci_map_single(card->pdev, descr->skb->data,
 			SPIDER_NET_MAX_FRAME, PCI_DMA_FROMDEVICE);
 	descr->buf_addr = buf;
@@ -394,7 +393,7 @@ spider_net_prepare_rx_descr(struct spide
 					 SPIDER_NET_DMAC_NOINTR_COMPLETE;
 	}
 
-	return error;
+	return 0;
 }
 
 /**
