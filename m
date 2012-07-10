From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 10/11] sunhme: remove unnecessary setting of skb->dev
Date: Mon,  9 Jul 2012 17:09:34 -0700
Message-ID: <1341878975-10577-10-git-send-email-jdmason@kudzu.us>
References: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:42042 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167Ab2GJAJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:09:50 -0400
Received: by gglu4 with SMTP id u4so10719391ggl.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 17:09:49 -0700 (PDT)
In-Reply-To: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->dev is being unnecessarily set during ring init and skb alloc in rx.  It is
already being set to the proper value when eth_type_trans is called on packet
receive, and the skb->dev is not referenced anywhere else in the code.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/sun/sunhme.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index dfc00c4..73f341b 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -1249,7 +1249,6 @@ static void happy_meal_clean_rings(struct happy_meal *hp)
 static void happy_meal_init_rings(struct happy_meal *hp)
 {
 	struct hmeal_init_block *hb = hp->happy_block;
-	struct net_device *dev = hp->dev;
 	int i;
 
 	HMD(("happy_meal_init_rings: counters to zero, "));
@@ -1270,7 +1269,6 @@ static void happy_meal_init_rings(struct happy_meal *hp)
 			continue;
 		}
 		hp->rx_skbs[i] = skb;
-		skb->dev = dev;
 
 		/* Because we reserve afterwards. */
 		skb_put(skb, (ETH_FRAME_LEN + RX_OFFSET + 4));
@@ -2031,7 +2029,6 @@ static void happy_meal_rx(struct happy_meal *hp, struct net_device *dev)
 			}
 			dma_unmap_single(hp->dma_dev, dma_addr, RX_BUF_ALLOC_SIZE, DMA_FROM_DEVICE);
 			hp->rx_skbs[elem] = new_skb;
-			new_skb->dev = dev;
 			skb_put(new_skb, (ETH_FRAME_LEN + RX_OFFSET + 4));
 			hme_write_rxd(hp, this,
 				      (RXFLAG_OWN|((RX_BUF_ALLOC_SIZE-RX_OFFSET)<<16)),
-- 
1.7.9.5
