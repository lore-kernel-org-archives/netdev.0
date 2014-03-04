From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv3 net-next 26/31] iw_cxgb4: rmb() after reading valid gen bit.
Date: Tue,  4 Mar 2014 18:11:52 +0530
Message-ID: <1393936917-25847-27-git-send-email-hariprasad@chelsio.com>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, kumaras@chelsio.com,
	dm@chelsio.com, swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, hariprasad@chelsio.com, nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21610 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932263AbaCDMon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 07:44:43 -0500
In-Reply-To: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Some HW platforms can reorder read operations, so we must rmb() after
we see a valid gen bit in a CQE but before we read any other fields
from the CQE.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/t4.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw/cxgb4/t4.h
index edab0e9..67cd09ee 100644
--- a/drivers/infiniband/hw/cxgb4/t4.h
+++ b/drivers/infiniband/hw/cxgb4/t4.h
@@ -622,6 +622,7 @@ static inline int t4_next_hw_cqe(struct t4_cq *cq, struct t4_cqe **cqe)
 		printk(KERN_ERR MOD "cq overflow cqid %u\n", cq->cqid);
 		BUG_ON(1);
 	} else if (t4_valid_cqe(cq, &cq->queue[cq->cidx])) {
+		rmb();
 		*cqe = &cq->queue[cq->cidx];
 		ret = 0;
 	} else
-- 
1.8.4
