From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 14/14] vmxnet3: convert to SKB paged frag API.
Date: Thu, 22 Sep 2011 08:53:28 +0100
Message-ID: <1316678008-16842-14-git-send-email-ian.campbell@citrix.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48517 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616Ab1IVHxv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 03:53:51 -0400
In-Reply-To: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>
Cc: "VMware, Inc." <pv-drivers@vmware.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 759c1a4..57e7c66 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -654,7 +654,7 @@ vmxnet3_append_frag(struct sk_buff *skb, struct Vmxnet3_RxCompDesc *rcd,
 
 	BUG_ON(skb_shinfo(skb)->nr_frags >= MAX_SKB_FRAGS);
 
-	frag->page = rbi->page;
+	__skb_frag_set_page(frag, rbi->page);
 	frag->page_offset = 0;
 	frag->size = rcd->len;
 	skb->data_len += frag->size;
@@ -748,9 +748,9 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 
 		tbi = tq->buf_info + tq->tx_ring.next2fill;
 		tbi->map_type = VMXNET3_MAP_PAGE;
-		tbi->dma_addr = pci_map_page(adapter->pdev, frag->page,
-					     frag->page_offset, frag->size,
-					     PCI_DMA_TODEVICE);
+		tbi->dma_addr = skb_frag_dma_map(&adapter->pdev->dev, frag,
+						 0, frag->size,
+						 PCI_DMA_TODEVICE);
 
 		tbi->len = frag->size;
 
-- 
1.7.2.5
