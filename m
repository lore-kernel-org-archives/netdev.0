From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/1] drivers: net: cpsw: remove tx event processing in rx napi poll
Date: Tue, 21 Jul 2015 16:00:42 +0530
Message-ID: <1437474642-32175-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:38203 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562AbbGUKat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 06:30:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit c03abd84634d ("net: ethernet: cpsw: don't requests IRQs
we don't use") common isr and napi are separated into separate tx isr
and rx isr/napi, but still in rx napi tx events are handled. So removing
the tx event handling in rx napi.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index f335bf1..d155bf2 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -793,9 +793,7 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 static int cpsw_poll(struct napi_struct *napi, int budget)
 {
 	struct cpsw_priv	*priv = napi_to_priv(napi);
-	int			num_tx, num_rx;
-
-	num_tx = cpdma_chan_process(priv->txch, 128);
+	int			num_rx;
 
 	num_rx = cpdma_chan_process(priv->rxch, budget);
 	if (num_rx < budget) {
@@ -810,9 +808,8 @@ static int cpsw_poll(struct napi_struct *napi, int budget)
 		}
 	}
 
-	if (num_rx || num_tx)
-		cpsw_dbg(priv, intr, "poll %d rx, %d tx pkts\n",
-			 num_rx, num_tx);
+	if (num_rx)
+		cpsw_dbg(priv, intr, "poll %d rx pkts\n", num_rx);
 
 	return num_rx;
 }
-- 
2.5.0.rc2.13.g961abca
