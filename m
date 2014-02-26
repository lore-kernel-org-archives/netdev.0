From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 12/31] iw_cxgb4: Fix incorrect BUG_ON conditions.
Date: Wed, 26 Feb 2014 20:36:51 +0530
Message-ID: <1393427230-14532-13-git-send-email-hariprasad@chelsio.com>
References: <1393427230-14532-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, kumaras@chelsio.com,
	dm@chelsio.com, swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, hariprasad@chelsio.com, nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8181 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751995AbaBZPI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 10:08:59 -0500
In-Reply-To: <1393427230-14532-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Based on original work from Jay Hernandez <jay@chelsio.com>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cq.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

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
1.7.1
