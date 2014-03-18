From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)
Date: Wed, 19 Mar 2014 03:32:30 +0530
Message-ID: <1395180150-18548-1-git-send-email-monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/infiniband/hw/qib/qib_qp.c

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/infiniband/hw/qib/qib_qp.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/qib/qib_qp.c b/drivers/infiniband/hw/qib/qib_qp.c
index 7e7e16f..1f5f04c 100644
--- a/drivers/infiniband/hw/qib/qib_qp.c
+++ b/drivers/infiniband/hw/qib/qib_qp.c
@@ -252,10 +252,10 @@ static void remove_qp(struct qib_ibdev *dev, struct qib_qp *qp)
 
 	if (ibp->qp0 == qp) {
 		atomic_dec(&qp->refcount);
-		rcu_assign_pointer(ibp->qp0, NULL);
+		RCU_INIT_POINTER(ibp->qp0, NULL);
 	} else if (ibp->qp1 == qp) {
 		atomic_dec(&qp->refcount);
-		rcu_assign_pointer(ibp->qp1, NULL);
+		RCU_INIT_POINTER(ibp->qp1, NULL);
 	} else {
 		struct qib_qp *q, **qpp;
 
@@ -303,7 +303,7 @@ unsigned qib_free_all_qps(struct qib_devdata *dd)
 	spin_lock_irqsave(&dev->qpt_lock, flags);
 	for (n = 0; n < dev->qp_table_size; n++) {
 		qp = dev->qp_table[n];
-		rcu_assign_pointer(dev->qp_table[n], NULL);
+		RCU_INIT_POINTER(dev->qp_table[n], NULL);
 
 		for (; qp; qp = qp->next)
 			qp_inuse++;
-- 
1.7.9.5
