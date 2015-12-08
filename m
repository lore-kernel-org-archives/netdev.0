From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 3/7] cxgb4: Use ACCES_ONCE macro to read queue's consumer index
Date: Tue,  8 Dec 2015 10:09:13 +0530
Message-ID: <1449549557-16023-4-git-send-email-hariprasad@chelsio.com>
References: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:7811 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753363AbbLHEiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 23:38:17 -0500
In-Reply-To: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use helper macro ACCESS_ONCE() to load from the SGE status page
to prevent the compiler loading multiple times.

Based on original work by Mike Werner <werner@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 48d8fbb..1076c35 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -406,7 +406,7 @@ static void free_tx_desc(struct adapter *adap, struct sge_txq *q,
  */
 static inline int reclaimable(const struct sge_txq *q)
 {
-	int hw_cidx = ntohs(q->stat->cidx);
+	int hw_cidx = ntohs(ACCESS_ONCE(q->stat->cidx));
 	hw_cidx -= q->cidx;
 	return hw_cidx < 0 ? hw_cidx + q->size : hw_cidx;
 }
@@ -1320,7 +1320,7 @@ out_free:	dev_kfree_skb_any(skb);
  */
 static inline void reclaim_completed_tx_imm(struct sge_txq *q)
 {
-	int hw_cidx = ntohs(q->stat->cidx);
+	int hw_cidx = ntohs(ACCESS_ONCE(q->stat->cidx));
 	int reclaim = hw_cidx - q->cidx;
 
 	if (reclaim < 0)
-- 
2.3.4
