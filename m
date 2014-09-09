From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH net-next] sfc: Convert the normal transmit complete path to dev_consume_skb_any()
Date: Tue,  9 Sep 2014 14:43:27 -0700 (PDT)
Message-ID: <20140909214327.D474F290042C@tardy>
Cc: <davem@davemloft.net>, <sshah@solarflare.com>,
	<linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:44257 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577AbaIIVnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 17:43:41 -0400
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com [15.217.128.52])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id 5D2C661AA2
	for <netdev@vger.kernel.org>; Tue,  9 Sep 2014 21:43:40 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Rick Jones <rick.jones2@hp.com>

Convert the normal transmit completion path from dev_kfree_skb_any()
to dev_consume_skb_any() to help keep dropped packet profiling
meaningful.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compile tested only.  Also a fixup to make scripts/checkpatch.pl
happy.

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 65c220f..3206098 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -78,7 +78,7 @@ static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 	if (buffer->flags & EFX_TX_BUF_SKB) {
 		(*pkts_compl)++;
 		(*bytes_compl) += buffer->skb->len;
-		dev_kfree_skb_any((struct sk_buff *) buffer->skb);
+		dev_consume_skb_any((struct sk_buff *)buffer->skb);
 		netif_vdbg(tx_queue->efx, tx_done, tx_queue->efx->net_dev,
 			   "TX queue %d transmission id %x complete\n",
 			   tx_queue->queue, tx_queue->read_count);
