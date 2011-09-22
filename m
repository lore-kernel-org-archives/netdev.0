From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 03/14] skge: convert to SKB paged frag API.
Date: Thu, 22 Sep 2011 08:53:17 +0100
Message-ID: <1316678008-16842-3-git-send-email-ian.campbell@citrix.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48517 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750963Ab1IVHxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 03:53:36 -0400
In-Reply-To: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/marvell/skge.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 34622b0..88e5856 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -2758,8 +2758,8 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-			map = pci_map_page(hw->pdev, frag->page, frag->page_offset,
-					   frag->size, PCI_DMA_TODEVICE);
+			map = skb_frag_dma_map(&hw->pdev->dev, frag, 0,
+					       frag->size, PCI_DMA_TODEVICE);
 
 			e = e->next;
 			e->skb = skb;
-- 
1.7.2.5
