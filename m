From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: [PATCH] IB/mthca: comment fix
Date: Mon, 10 Jul 2006 14:14:12 +0300
Message-ID: <20060710111412.GD24705@mellanox.co.il>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>,
	  "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@mellanox.co.il>,
	Ingo Molnar <mingo@elte.hu>,
	Zach Brown <zach.brown@oracle.com>, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxl145v66.mxlogic.net ([208.65.145.66]:5025 "EHLO
	p02c11o143.mxlogic.net") by vger.kernel.org with ESMTP
	id S1751341AbWGJLNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 07:13:46 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,
Here's a cosmetic patch for IB/mthca. Pls drop it into -mm and on.

---

comment in mthca_qp.c makes it seem lockdep is the only reason WQ locks should
be initialized separately, but as Zach Brown and Roland pointed out, there are
other reasons, e.g. that mthca_wq_init is called from modify qp as well.

Signed-off-by: Michael S. Tsirkin <mst@mellanox.co.il>

diff --git a/drivers/infiniband/hw/mthca/mthca_qp.c b/drivers/infiniband/hw/mthca/mthca_qp.c
index 490fc78..2f3917e 100644
--- a/drivers/infiniband/hw/mthca/mthca_qp.c
+++ b/drivers/infiniband/hw/mthca/mthca_qp.c
@@ -1114,7 +1114,7 @@ static int mthca_alloc_qp_common(struct 
 	qp->sq_policy    = send_policy;
 	mthca_wq_init(&qp->sq);
 	mthca_wq_init(&qp->rq);
-	/* these are initialized separately so lockdep can tell them apart */
+
 	spin_lock_init(&qp->sq.lock);
 	spin_lock_init(&qp->rq.lock);
 

-- 
MST
