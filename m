From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 3/7] tg3: fix race in transmit time stamping.
Date: Sun, 19 Jun 2011 15:31:41 +0200
Message-ID: <3028b6650f99e6581e1afbf810dc7fcc4be6941e.1308489767.git.richard.cochran@omicron.at>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55555 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727Ab1FSNb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 09:31:59 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so477619fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 06:31:58 -0700 (PDT)
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 743d997..34ea37d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6088,11 +6088,11 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		entry = NEXT_TX(tnapi->tx_prod);
 	}
 
+	skb_tx_timestamp(skb);
+
 	/* Packets are ready, update Tx producer idx local and on card. */
 	tw32_tx_mbox(tnapi->prodmbox, entry);
 
-	skb_tx_timestamp(skb);
-
 	tnapi->tx_prod = entry;
 	if (unlikely(tg3_tx_avail(tnapi) <= (MAX_SKB_FRAGS + 1))) {
 		netif_tx_stop_queue(txq);
-- 
1.7.0.4

