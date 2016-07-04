From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/9] net: r6040: Check for skb->xmit_more
Date: Mon,  4 Jul 2016 14:36:05 -0700
Message-ID: <1467668169-31547-6-git-send-email-f.fainelli@gmail.com>
References: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34063 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932448AbcGDVgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 17:36:18 -0400
Received: by mail-oi0-f68.google.com with SMTP id s17so24991524oih.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 14:36:18 -0700 (PDT)
In-Reply-To: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kick the transmission only if this is the last SKB to transmit or the
queue is not already stopped.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 4bf78f18a937..96b2d639c3c1 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -840,7 +840,8 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
 	skb_tx_timestamp(skb);
 
 	/* Trigger the MAC to check the TX descriptor */
-	iowrite16(TM2TX, ioaddr + MTPR);
+	if (!skb->xmit_more || netif_queue_stopped(dev))
+		iowrite16(TM2TX, ioaddr + MTPR);
 	lp->tx_insert_ptr = descptr->vndescp;
 
 	/* If no tx resource, stop */
-- 
2.7.4
