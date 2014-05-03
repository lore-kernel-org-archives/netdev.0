From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 2/7] net: mvneta: Clean-up mvneta_tx_frag_process()
Date: Sat,  3 May 2014 15:26:57 -0300
Message-ID: <1399141622-30654-3-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:60623 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752218AbaECS2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 14:28:11 -0400
In-Reply-To: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A tiny clean-up to improve readability. This commit makes no functionality
change.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 14786c8..d73ed91 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1524,9 +1524,9 @@ static int mvneta_tx_frag_process(struct mvneta_port *pp, struct sk_buff *skb,
 				  struct mvneta_tx_queue *txq)
 {
 	struct mvneta_tx_desc *tx_desc;
-	int i;
+	int i, nr_frags = skb_shinfo(skb)->nr_frags;
 
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+	for (i = 0; i < nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 		void *addr = page_address(frag->page.p) + frag->page_offset;
 
@@ -1543,20 +1543,16 @@ static int mvneta_tx_frag_process(struct mvneta_port *pp, struct sk_buff *skb,
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
