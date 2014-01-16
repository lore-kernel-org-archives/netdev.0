From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH 13/13] net: mvneta: make mvneta_txq_done() return void
Date: Thu, 16 Jan 2014 08:20:19 +0100
Message-ID: <1389856819-6503-14-git-send-email-w@1wt.eu>
References: <1389856819-6503-1-git-send-email-w@1wt.eu>
Cc: netdev@vger.kernel.org, Arnaud Ebalard <arno@natisbad.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55474 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbaAPHUn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 02:20:43 -0500
In-Reply-To: <1389856819-6503-1-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaud Ebalard <arno@natisbad.org>

The function return parameter is not used in mvneta_tx_done_gbe(),
where the function is called. This patch makes the function return
void.

Reviewed-by: Willy Tarreau <w@1wt.eu>
Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 drivers/net/ethernet/marvell/mvneta.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 8c51501..f418f4f 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1314,15 +1314,16 @@ static void mvneta_txq_bufs_free(struct mvneta_port *pp,
 }
 
 /* Handle end of transmission */
-static int mvneta_txq_done(struct mvneta_port *pp,
+static void mvneta_txq_done(struct mvneta_port *pp,
 			   struct mvneta_tx_queue *txq)
 {
 	struct netdev_queue *nq = netdev_get_tx_queue(pp->dev, txq->id);
 	int tx_done;
 
 	tx_done = mvneta_txq_sent_desc_proc(pp, txq);
-	if (tx_done == 0)
-		return tx_done;
+	if (!tx_done)
+		return;
+
 	mvneta_txq_bufs_free(pp, txq, tx_done);
 
 	txq->count -= tx_done;
@@ -1331,8 +1332,6 @@ static int mvneta_txq_done(struct mvneta_port *pp,
 		if (txq->size - txq->count >= MAX_SKB_FRAGS + 1)
 			netif_tx_wake_queue(nq);
 	}
-
-	return tx_done;
 }
 
 static void *mvneta_frag_alloc(const struct mvneta_port *pp)
-- 
1.7.12.2.21.g234cd45.dirty
