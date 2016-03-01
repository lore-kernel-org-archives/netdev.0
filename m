From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/5] cxgb4/cxgb4vf: Use fl capacity to check if fl needs to be replenished
Date: Tue,  1 Mar 2016 17:19:32 +0530
Message-ID: <1456832976-12840-2-git-send-email-hariprasad@chelsio.com>
References: <1456832976-12840-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, nirranjan@chelsio.com, leedom@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:38225 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752680AbcCALqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 06:46:49 -0500
In-Reply-To: <1456832976-12840-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use freelist capacity instead of freelist size while checking, if
freelist needs to be refilled

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c   | 2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index b4eb4680a27c..22d972030927 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2226,7 +2226,7 @@ static int process_responses(struct sge_rspq *q, int budget)
 		budget_left--;
 	}
 
-	if (q->offset >= 0 && rxq->fl.size - rxq->fl.avail >= 16)
+	if (q->offset >= 0 && fl_cap(&rxq->fl) - rxq->fl.avail >= 16)
 		__refill_fl(q->adap, &rxq->fl);
 	return budget - budget_left;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 6528231d8a59..9772aad22bca 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1864,7 +1864,7 @@ static int process_responses(struct sge_rspq *rspq, int budget)
 	 * for new buffer pointers, refill the Free List.
 	 */
 	if (rspq->offset >= 0 &&
-	    rxq->fl.size - rxq->fl.avail >= 2*FL_PER_EQ_UNIT)
+	    fl_cap(&rxq->fl) - rxq->fl.avail >= 2*FL_PER_EQ_UNIT)
 		__refill_fl(rspq->adapter, &rxq->fl);
 	return budget - budget_left;
 }
-- 
2.3.4
