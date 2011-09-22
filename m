From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 12/14] via-velocity: convert to SKB paged frag API.
Date: Thu, 22 Sep 2011 08:53:26 +0100
Message-ID: <1316678008-16842-12-git-send-email-ian.campbell@citrix.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48517 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751792Ab1IVHxr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 03:53:47 -0400
In-Reply-To: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/via/via-velocity.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 086463b..1ec32c4 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2556,9 +2556,10 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		tdinfo->skb_dma[i + 1] = pci_map_page(vptr->pdev, frag->page,
-				frag->page_offset, frag->size,
-				PCI_DMA_TODEVICE);
+		tdinfo->skb_dma[i + 1] = skb_frag_dma_map(&vptr->pdev->dev,
+							  frag, 0,
+							  frag->size,
+							  PCI_DMA_TODEVICE);
 
 		td_ptr->td_buf[i + 1].pa_low = cpu_to_le32(tdinfo->skb_dma[i + 1]);
 		td_ptr->td_buf[i + 1].pa_high = 0;
-- 
1.7.2.5
