From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH V2 1/2] RDMA/cxgb4: Update RDMA/cxgb4 due to macro definition removal in cxgb4 driver
Date: Wed,  5 Sep 2012 17:31:54 +0530
Message-ID: <1346846515-25997-2-git-send-email-vipul@chelsio.com>
References: <1346846515-25997-1-git-send-email-vipul@chelsio.com>
Cc: roland@purestorage.com, davem@davemloft.net, divy@chelsio.com,
	dm@chelsio.com, swise@opengridcomputing.com, kumaras@chelsio.com,
	santosh@chelsio.com, sivasu@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22654 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406Ab2IEMFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 08:05:05 -0400
In-Reply-To: <1346846515-25997-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cxgb4 driver has duplicate definitions of registers which will be removed. This
patch updates the RDMA/cxgb4 driver accordingly.

Signed-off-by: Santosh Rastapur <santosh@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
Reviewed-by: Sivakumar Subramani <sivasu@chelsio.com>
---
V2: Changed the order of the patch in patch series to avoid build failure
between two changes.

 drivers/infiniband/hw/cxgb4/qp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 45aedf1..5213bab 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -1155,7 +1155,7 @@ static int ring_kernel_db(struct c4iw_qp *qhp, u32 qid, u16 inc)
 		 */
 		if (cxgb4_dbfifo_count(qhp->rhp->rdev.lldi.ports[0], 1) <
 		    (qhp->rhp->rdev.lldi.dbfifo_int_thresh << 5)) {
-			writel(V_QID(qid) | V_PIDX(inc), qhp->wq.db);
+			writel(QID(qid) | PIDX(inc), qhp->wq.db);
 			break;
 		}
 		set_current_state(TASK_UNINTERRUPTIBLE);
-- 
1.7.1
