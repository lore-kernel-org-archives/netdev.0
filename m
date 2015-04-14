From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/5] cxgb4: Use device node in page allocation
Date: Wed, 15 Apr 2015 02:02:32 +0530
Message-ID: <1429043554-8744-4-git-send-email-hariprasad@chelsio.com>
References: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8814 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932443AbbDNPUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 11:20:42 -0400
In-Reply-To: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index e0cfce8..6af4bab 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -592,8 +592,10 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 	unsigned int cred = q->avail;
 	__be64 *d = &q->desc[q->pidx];
 	struct rx_sw_desc *sd = &q->sdesc[q->pidx];
+	int node;
 
 	gfp |= __GFP_NOWARN;
+	node = dev_to_node(adap->pdev_dev);
 
 	if (s->fl_pg_order == 0)
 		goto alloc_small_pages;
@@ -602,7 +604,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 	 * Prefer large buffers
 	 */
 	while (n) {
-		pg = __dev_alloc_pages(gfp, s->fl_pg_order);
+		pg = alloc_pages_node(node, gfp | __GFP_COMP, s->fl_pg_order);
 		if (unlikely(!pg)) {
 			q->large_alloc_failed++;
 			break;       /* fall back to single pages */
@@ -632,7 +634,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 
 alloc_small_pages:
 	while (n--) {
-		pg = __dev_alloc_page(gfp);
+		pg = alloc_pages_node(node, gfp, 0);
 		if (unlikely(!pg)) {
 			q->alloc_failed++;
 			break;
-- 
2.3.4
