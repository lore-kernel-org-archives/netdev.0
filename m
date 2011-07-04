From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] b44: use dev_kfree_skb() in b44_tx()
Date: Mon, 04 Jul 2011 17:41:53 +0200
Message-ID: <1309794113.2247.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47573 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757799Ab1GDPmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 11:42:08 -0400
Received: by wyg8 with SMTP id 8so3478951wyg.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 08:42:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

b44_tx() is run from softirq handler, it can use dev_kfree_skb() instead
of dev_kfree_skb_irq()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/b44.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index a69331e..4345e28 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -609,7 +609,7 @@ static void b44_tx(struct b44 *bp)
 				 skb->len,
 				 DMA_TO_DEVICE);
 		rp->skb = NULL;
-		dev_kfree_skb_irq(skb);
+		dev_kfree_skb(skb);
 	}
 
 	bp->tx_cons = cons;


