From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 08/11] sunbmac: remove unnecessary setting of skb->dev
Date: Mon,  9 Jul 2012 17:09:32 -0700
Message-ID: <1341878975-10577-8-git-send-email-jdmason@kudzu.us>
References: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56424 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199Ab2GJAJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:09:39 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so20018595pbb.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 17:09:39 -0700 (PDT)
In-Reply-To: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->dev is being unnecessarily set during ring init and skb alloc in rx.  It is
already being set to the proper value when eth_type_trans is called on packet
receive, and the skb->dev is not referenced anywhere else in the code.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/sun/sunbmac.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 2a83fc5..967fe8c 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -233,7 +233,6 @@ static void bigmac_init_rings(struct bigmac *bp, int from_irq)
 			continue;
 
 		bp->rx_skbs[i] = skb;
-		skb->dev = dev;
 
 		/* Because we reserve afterwards. */
 		skb_put(skb, ETH_FRAME_LEN);
@@ -838,7 +837,6 @@ static void bigmac_rx(struct bigmac *bp)
 					 RX_BUF_ALLOC_SIZE - 34,
 					 DMA_FROM_DEVICE);
 			bp->rx_skbs[elem] = new_skb;
-			new_skb->dev = bp->dev;
 			skb_put(new_skb, ETH_FRAME_LEN);
 			skb_reserve(new_skb, 34);
 			this->rx_addr =
-- 
1.7.9.5
