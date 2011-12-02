From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] sfc: Use kcalloc instead of kzalloc to allocate array
Date: Fri, 02 Dec 2011 23:36:13 +0100
Message-ID: <1322865373.1534.357.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The advantage of kcalloc is, that will prevent integer overflows which could
result from the multiplication of number of elements and size and it is also
a bit nicer to read.

The semantic patch that makes this change is available
in https://lkml.org/lkml/2011/11/25/107

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
--- a/drivers/net/ethernet/sfc/rx.c 2011-11-13 11:07:36.306977044 +0100
+++ b/drivers/net/ethernet/sfc/rx.c 2011-11-28 19:53:10.346917167 +0100
@@ -669,7 +669,7 @@ int efx_probe_rx_queue(struct efx_rx_que
 		  rx_queue->ptr_mask);
 
 	/* Allocate RX buffers */
-	rx_queue->buffer = kzalloc(entries * sizeof(*rx_queue->buffer),
+	rx_queue->buffer = kcalloc(entries, sizeof(*rx_queue->buffer),
 				   GFP_KERNEL);
 	if (!rx_queue->buffer)
 		return -ENOMEM;
diff -u -p a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
--- a/drivers/net/ethernet/sfc/selftest.c 2011-11-13 11:07:36.306977044 +0100
+++ b/drivers/net/ethernet/sfc/selftest.c 2011-11-28 19:53:09.640237232 +0100
@@ -503,8 +503,8 @@ efx_test_loopback(struct efx_tx_queue *t
 		/* Determine how many packets to send */
 		state->packet_count = efx->txq_entries / 3;
 		state->packet_count = min(1 << (i << 2), state->packet_count);
-		state->skbs = kzalloc(sizeof(state->skbs[0]) *
-				      state->packet_count, GFP_KERNEL);
+		state->skbs = kcalloc(state->packet_count,
+				      sizeof(state->skbs[0]), GFP_KERNEL);
 		if (!state->skbs)
 			return -ENOMEM;
 		state->flush = false;
diff -u -p a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
--- a/drivers/net/ethernet/sfc/tx.c 2011-11-13 11:07:36.313643816 +0100
+++ b/drivers/net/ethernet/sfc/tx.c 2011-11-28 19:53:08.056874176 +0100
@@ -468,7 +468,7 @@ int efx_probe_tx_queue(struct efx_tx_que
 		  tx_queue->queue, efx->txq_entries, tx_queue->ptr_mask);
 
 	/* Allocate software ring */
-	tx_queue->buffer = kzalloc(entries * sizeof(*tx_queue->buffer),
+	tx_queue->buffer = kcalloc(entries, sizeof(*tx_queue->buffer),
 				   GFP_KERNEL);
 	if (!tx_queue->buffer)
 		return -ENOMEM;
