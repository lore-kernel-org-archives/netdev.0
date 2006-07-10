From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: [PATCH updated] IB/mthca: comment fix
Date: Mon, 10 Jul 2006 18:18:24 +0300
Message-ID: <20060710151824.GL24705@mellanox.co.il>
References: <20060710111412.GD24705@mellanox.co.il>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Zach Brown <zach.brown@oracle.com>,
	openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxl145v68.mxlogic.net ([208.65.145.68]:4273 "EHLO
	p02c11o145.mxlogic.net") by vger.kernel.org with ESMTP
	id S1422651AbWGJPSN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 11:18:13 -0400
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <20060710111412.GD24705@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK, the following makes it clear what the function does, from its name.
More comments?

---

After recent changes, mthca_wq_init does not actually initialize the WQ as it
used to - it simply resets all index fields to their initial values. So,
let's rename it to mthca_wq_reset.

Signed-off-by: Michael S. Tsirkin <mst@mellanox.co.il>

diff --git a/drivers/infiniband/hw/mthca/mthca_qp.c b/drivers/infiniband/hw/mthca/mthca_qp.c
index 490fc78..cd8b672 100644
--- a/drivers/infiniband/hw/mthca/mthca_qp.c
+++ b/drivers/infiniband/hw/mthca/mthca_qp.c
@@ -222,9 +222,8 @@ static void *get_send_wqe(struct mthca_q
 			 (PAGE_SIZE - 1));
 }
 
-static void mthca_wq_init(struct mthca_wq *wq)
+static void mthca_wq_reset(struct mthca_wq *wq)
 {
-	/* mthca_alloc_qp_common() initializes the locks */
 	wq->next_ind  = 0;
 	wq->last_comp = wq->max - 1;
 	wq->head      = 0;
@@ -845,10 +844,10 @@ int mthca_modify_qp(struct ib_qp *ibqp, 
 			mthca_cq_clean(dev, to_mcq(qp->ibqp.recv_cq), qp->qpn,
 				       qp->ibqp.srq ? to_msrq(qp->ibqp.srq) : NULL);
 
-		mthca_wq_init(&qp->sq);
+		mthca_wq_reset(&qp->sq);
 		qp->sq.last = get_send_wqe(qp, qp->sq.max - 1);
 
-		mthca_wq_init(&qp->rq);
+		mthca_wq_reset(&qp->rq);
 		qp->rq.last = get_recv_wqe(qp, qp->rq.max - 1);
 
 		if (mthca_is_memfree(dev)) {
@@ -1112,9 +1111,9 @@ static int mthca_alloc_qp_common(struct 
 	qp->atomic_rd_en = 0;
 	qp->resp_depth   = 0;
 	qp->sq_policy    = send_policy;
-	mthca_wq_init(&qp->sq);
-	mthca_wq_init(&qp->rq);
-	/* these are initialized separately so lockdep can tell them apart */
+	mthca_wq_reset(&qp->sq);
+	mthca_wq_reset(&qp->rq);
+
 	spin_lock_init(&qp->sq.lock);
 	spin_lock_init(&qp->rq.lock);
 
-- 
MST
