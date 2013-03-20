From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] chelsio: add headroom in RX path
Date: Wed, 20 Mar 2013 09:33:19 -0700
Message-ID: <1363797199.3333.18.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:60577 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755744Ab3CTQdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:33:22 -0400
Received: by mail-pb0-f41.google.com with SMTP id um15so1507504pbc.28
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 09:33:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Drivers should reserve some headroom in skb used in receive path,
to avoid future head reallocation.

One possible way to do that is to use dev_alloc_skb() instead
of alloc_skb(), so that NET_SKB_PAD bytes are reserved.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/chelsio/cxgb/sge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 4829769..89bef50 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -835,7 +835,7 @@ static void refill_free_list(struct sge *sge, struct freelQ *q)
 		struct sk_buff *skb;
 		dma_addr_t mapping;
 
-		skb = alloc_skb(q->rx_buffer_size, GFP_ATOMIC);
+		skb = dev_alloc_skb(q->rx_buffer_size);
 		if (!skb)
 			break;
 
