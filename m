From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] drivers: fix dev->trans_start removal fallout
Date: Wed,  4 May 2016 22:56:07 +0200
Message-ID: <1462395367-16704-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:53311 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751139AbcEDU4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 16:56:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kbuild test robot reported a build failure on s390.
While at it, also fix missing conversion in the tilera driver.

Fixes: 9b36627acecd5792 ("net: remove dev->trans_start")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 0bb98bc..922a443 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -2026,7 +2026,7 @@ static void tile_net_tx_timeout(struct net_device *dev)
 {
 	PDEBUG("tile_net_tx_timeout()\n");
 	PDEBUG("Transmit timeout at %ld, latency %ld\n", jiffies,
-	       jiffies - dev->trans_start);
+	       jiffies - dev_trans_start(dev));
 
 	/* XXX: ISSUE: This doesn't seem useful for us. */
 	netif_wake_queue(dev);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 7871537..b7b7477 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3481,7 +3481,7 @@ static void qeth_flush_buffers(struct qeth_qdio_out_q *queue, int index,
 		}
 	}
 
-	queue->card->dev->trans_start = jiffies;
+	netif_trans_update(queue->card->dev);
 	if (queue->card->options.performance_stats) {
 		queue->card->perf_stats.outbound_do_qdio_cnt++;
 		queue->card->perf_stats.outbound_do_qdio_start_time =
-- 
2.7.3
