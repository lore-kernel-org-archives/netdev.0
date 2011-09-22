From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 08/14] sunhme: convert to SKB paged frag API.
Date: Thu, 22 Sep 2011 08:53:22 +0100
Message-ID: <1316678008-16842-8-git-send-email-ian.campbell@citrix.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:47937 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab1IVHxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 03:53:42 -0400
In-Reply-To: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/sun/sunhme.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 42f866e..869d47b 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2309,9 +2309,8 @@ static netdev_tx_t happy_meal_start_xmit(struct sk_buff *skb,
 			u32 len, mapping, this_txflags;
 
 			len = this_frag->size;
-			mapping = dma_map_page(hp->dma_dev, this_frag->page,
-					       this_frag->page_offset, len,
-					       DMA_TO_DEVICE);
+			mapping = skb_frag_dma_map(hp->dma_dev, this_frag,
+						   0, len, DMA_TO_DEVICE);
 			this_txflags = tx_flags;
 			if (frag == skb_shinfo(skb)->nr_frags - 1)
 				this_txflags |= TXFLAG_EOP;
-- 
1.7.2.5
