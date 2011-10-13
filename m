From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 19:50:19 +0200
Message-ID: <1318528219.2393.52.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59131 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964Ab1JMRuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 13:50:02 -0400
Received: by wwf22 with SMTP id 22so2173340wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 10:50:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2 allocates a full page per fragment. We must account PAGE_SIZE
increments on skb->truesize, not the actual frag length.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 3c221be..6ff7636 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3051,7 +3051,6 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 						&skb_shinfo(skb)->frags[i - 1];
 					frag->size -= tail;
 					skb->data_len -= tail;
-					skb->truesize -= tail;
 				}
 				return 0;
 			}
@@ -3083,7 +3082,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 
 			frag_size -= frag_len;
 			skb->data_len += frag_len;
-			skb->truesize += frag_len;
+			skb->truesize += PAGE_SIZE;
 			skb->len += frag_len;
 
 			pg_prod = NEXT_RX_BD(pg_prod);
