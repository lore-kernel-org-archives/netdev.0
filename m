From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 07/14] niu: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:46:59 +0100
Message-ID: <1314787626-12273-7-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10632 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316Ab1HaKrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 06:47:16 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/sun/niu.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 3c9ef1c..cad58f2 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3290,11 +3290,8 @@ static void niu_rx_skb_append(struct sk_buff *skb, struct page *page,
 			      u32 offset, u32 size)
 {
 	int i = skb_shinfo(skb)->nr_frags;
-	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-	frag->page = page;
-	frag->page_offset = offset;
-	frag->size = size;
+	__skb_fill_page_desc(skb, i, page, offset, size);
 
 	skb->len += size;
 	skb->data_len += size;
@@ -6737,7 +6734,7 @@ static netdev_tx_t niu_start_xmit(struct sk_buff *skb,
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		len = frag->size;
-		mapping = np->ops->map_page(np->device, frag->page,
+		mapping = np->ops->map_page(np->device, skb_frag_page(frag),
 					    frag->page_offset, len,
 					    DMA_TO_DEVICE);
 
-- 
1.7.2.5
