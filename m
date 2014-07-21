From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH 3/5] iw_cxgb4: Support query_qp() verb
Date: Mon, 21 Jul 2014 20:55:14 +0530
Message-ID: <1405956316-13591-4-git-send-email-hariprasad@chelsio.com>
References: <1405956316-13591-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:32799
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752518AbaGUPTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 11:19:48 -0400
In-Reply-To: <1405956316-13591-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/qp.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index fd66bd9..0e7e0e3 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -1856,5 +1856,11 @@ int c4iw_ib_query_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
 	memset(attr, 0, sizeof *attr);
 	memset(init_attr, 0, sizeof *init_attr);
 	attr->qp_state = to_ib_qp_state(qhp->attr.state);
+	init_attr->cap.max_send_wr = qhp->attr.sq_num_entries;
+	init_attr->cap.max_recv_wr = qhp->attr.rq_num_entries;
+	init_attr->cap.max_send_sge = qhp->attr.sq_max_sges;
+	init_attr->cap.max_recv_sge = qhp->attr.sq_max_sges;
+	init_attr->cap.max_inline_data = T4_MAX_SEND_INLINE;
+	init_attr->sq_sig_type = qhp->sq_sig_all ? IB_SIGNAL_ALL_WR : 0;
 	return 0;
 }
-- 
1.7.1
