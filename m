From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv4 net-next 13/32] iw_cxgb4: Fix incorrect BUG_ON conditions
Date: Fri,  7 Mar 2014 16:03:10 +0530
Message-ID: <1394188409-9739-14-git-send-email-hariprasad@chelsio.com>
References: <1394188409-9739-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, santosh@chelsio.com,
	dm@chelsio.com, kumaras@chelsio.com, swise@opengridcomputing.com,
	leedom@chelsio.com, nirranjan@chelsio.com, hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25631 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752078AbaCGKmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 05:42:22 -0500
In-Reply-To: <1394188409-9739-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Based on original work from Jay Hernandez <jay@chelsio.com>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cq.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index c0673ac..59f7601 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -603,7 +603,7 @@ proc_cqe:
 	 */
 	if (SQ_TYPE(hw_cqe)) {
 		int idx = CQE_WRID_SQ_IDX(hw_cqe);
-		BUG_ON(idx > wq->sq.size);
+		BUG_ON(idx >= wq->sq.size);
 
 		/*
 		* Account for any unsignaled completions completed by
@@ -617,7 +617,7 @@ proc_cqe:
 			wq->sq.in_use -= wq->sq.size + idx - wq->sq.cidx;
 		else
 			wq->sq.in_use -= idx - wq->sq.cidx;
-		BUG_ON(wq->sq.in_use < 0 && wq->sq.in_use < wq->sq.size);
+		BUG_ON(wq->sq.in_use <= 0 && wq->sq.in_use >= wq->sq.size);
 
 		wq->sq.cidx = (uint16_t)idx;
 		PDBG("%s completing sq idx %u\n", __func__, wq->sq.cidx);
-- 
1.8.4
