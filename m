From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v3 2/8] net: mvneta: Clean-up mvneta_tx_frag_process()
Date: Thu, 22 May 2014 20:06:57 -0300
Message-ID: <1400800023-1562-3-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:49695 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751243AbaEVXH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 19:07:59 -0400
In-Reply-To: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A tiny clean-up to improve readability. This commit makes no functionality
change.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 18c698d..3034601 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1654,9 +1654,9 @@ static int mvneta_tx_frag_process(struct mvneta_port *pp, struct sk_buff *skb,
 				  struct mvneta_tx_queue *txq)
 {
 	struct mvneta_tx_desc *tx_desc;
-	int i;
+	int i, nr_frags = skb_shinfo(skb)->nr_frags;
 
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+	for (i = 0; i < nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 		void *addr = page_address(frag->page.p) + frag->page_offset;
 
@@ -1673,20 +1673,16 @@ static int mvneta_tx_frag_process(struct mvneta_port *pp, struct sk_buff *skb,
 			goto error;
 		}
 
-		if (i == (skb_shinfo(skb)->nr_frags - 1)) {
+		if (i == nr_frags - 1) {
 			/* Last descriptor */
 			tx_desc->command = MVNETA_TXD_L_DESC | MVNETA_TXD_Z_PAD;
-
 			txq->tx_skb[txq->txq_put_index] = skb;
-
-			mvneta_txq_inc_put(txq);
 		} else {
 			/* Descriptor in the middle: Not First, Not Last */
 			tx_desc->command = 0;
-
 			txq->tx_skb[txq->txq_put_index] = NULL;
-			mvneta_txq_inc_put(txq);
 		}
+		mvneta_txq_inc_put(txq);
 	}
 
 	return 0;
-- 
1.9.1
