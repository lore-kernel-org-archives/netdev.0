From: frank.blaschka@de.ibm.com
Subject: [patch 4/4] [PATCH] qeth: buffer count imbalance
Date: Wed, 08 Dec 2010 13:58:01 +0100
Message-ID: <20101208125844.812890035@de.ibm.com>
References: <20101208125757.726629855@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Jan Glauber <jang@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:51182 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865Ab0LHM6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 07:58:47 -0500
Content-Disposition: inline; filename=137-qeth-buffer-imbalance.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Glauber <jang@linux.vnet.ibm.com>

The used buffers counter is not incremented in case of an error so
the counter can become negative. Increment the used buffers counter
before checking for errors.

Signed-off-by: Jan Glauber <jang@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -2840,6 +2840,7 @@ static void qeth_flush_buffers(struct qe
 		queue->card->perf_stats.outbound_do_qdio_time +=
 			qeth_get_micros() -
 			queue->card->perf_stats.outbound_do_qdio_start_time;
+	atomic_add(count, &queue->used_buffers);
 	if (rc) {
 		queue->card->stats.tx_errors += count;
 		/* ignore temporary SIGA errors without busy condition */
@@ -2853,7 +2854,6 @@ static void qeth_flush_buffers(struct qe
 		qeth_schedule_recovery(queue->card);
 		return;
 	}
-	atomic_add(count, &queue->used_buffers);
 	if (queue->card->options.performance_stats)
 		queue->card->perf_stats.bufs_sent += count;
 }

