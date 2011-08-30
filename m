From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 02/14] 8139cp: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 10:18:18 +0100
Message-ID: <1314695910-22344-2-git-send-email-ian.campbell@citrix.com>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:54568 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150Ab1H3JSf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 05:18:35 -0400
In-Reply-To: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/realtek/8139cp.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 5d2d1b8..c77d5af 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -784,8 +784,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 
 			len = this_frag->size;
 			mapping = dma_map_single(&cp->pdev->dev,
-						 ((void *) page_address(this_frag->page) +
-						  this_frag->page_offset),
+						 skb_frag_address(this_frag),
 						 len, PCI_DMA_TODEVICE);
 			eor = (entry == (CP_TX_RING_SIZE - 1)) ? RingEnd : 0;
 
-- 
1.7.2.5
