From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] b44: use netdev_alloc_skb_ip_align()
Date: Mon, 18 Feb 2013 21:49:56 +0100
Message-ID: <1361220596-26478-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:39768 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751970Ab3BRUuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 15:50:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this patch b44 always allocates the 2 bytes needed for aligned
access on every platform, now it uses netdev_alloc_skb_ip_align().

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index c030274..a7efec2 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -809,11 +809,10 @@ static int b44_rx(struct b44 *bp, int budget)
 			struct sk_buff *copy_skb;
 
 			b44_recycle_rx(bp, cons, bp->rx_prod);
-			copy_skb = netdev_alloc_skb(bp->dev, len + 2);
+			copy_skb = netdev_alloc_skb_ip_align(bp->dev, len);
 			if (copy_skb == NULL)
 				goto drop_it_no_recycle;
 
-			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
 			/* DMA sync done above, copy just the actual packet */
 			skb_copy_from_linear_data_offset(skb, RX_PKT_OFFSET,
-- 
1.7.10.4
