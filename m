From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 05/18] bnx2x: Unlimited Tx interrupt work
Date: Mon, 02 Mar 2009 19:59:31 +0200
Message-ID: <1236016772.7723.76.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2320 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755912AbZCBSBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:01:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 05/18] bnx2x: Unlimited Tx interrupt work

The Tx interrupt is very short and there is no need to limit it to a budget

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index e4d54e1..a66536e 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -874,7 +874,7 @@ static inline u16 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
 	return (s16)(fp->bp->tx_ring_size) - used;
 }
 
-static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
+static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
 {
 	struct bnx2x *bp = fp->bp;
 	struct netdev_queue *txq;
@@ -908,9 +908,6 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
 		bd_cons = bnx2x_free_tx_pkt(bp, fp, pkt_cons);
 		sw_cons++;
 		done++;
-
-		if (done == work)
-			break;
 	}
 
 	fp->tx_pkt_cons = sw_cons;
@@ -4177,7 +4174,7 @@ static void bnx2x_timer(unsigned long data)
 		struct bnx2x_fastpath *fp = &bp->fp[0];
 		int rc;
 
-		bnx2x_tx_int(fp, 1000);
+		bnx2x_tx_int(fp);
 		rc = bnx2x_rx_int(fp, 1000);
 	}
 
@@ -7217,7 +7214,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		cnt = 1000;
 		while (bnx2x_has_tx_work_unload(fp)) {
 
-			bnx2x_tx_int(fp, 1000);
+			bnx2x_tx_int(fp);
 			if (!cnt) {
 				BNX2X_ERR("timeout waiting for queue[%d]\n",
 					  i);
@@ -10069,7 +10066,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 	bnx2x_update_fpsb_idx(fp);
 
 	if (bnx2x_has_tx_work(fp))
-		bnx2x_tx_int(fp, budget);
+		bnx2x_tx_int(fp);
 
 	if (bnx2x_has_rx_work(fp))
 		work_done = bnx2x_rx_int(fp, budget);
-- 
1.5.4.3




