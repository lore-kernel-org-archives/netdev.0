From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V2 for-next 08/11] IB/hns: Modify query info named port_num when querying RC QP
Date: Tue, 15 Nov 2016 18:10:50 +0000
Message-ID: <20161115181053.399568-9-salil.mehta@huawei.com>
References: <20161115181053.399568-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xushaobo2-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <lijun_nudt-9Onoh4P/yGk@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161115181053.399568-1-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

This patch modified the output query info qp_attr->port_num
to fix bug in hip06.

Signed-off-by: Wei Hu (Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Salil Mehta  <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index 509ea75..34b7898 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -2857,9 +2857,7 @@ static int hns_roce_v1_q_qp(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr,
 	qp_attr->pkey_index = roce_get_field(context->qpc_bytes_12,
 			      QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_M,
 			      QP_CONTEXT_QPC_BYTES_12_P_KEY_INDEX_S);
-	qp_attr->port_num = (u8)roce_get_field(context->qpc_bytes_156,
-			     QP_CONTEXT_QPC_BYTES_156_PORT_NUM_M,
-			     QP_CONTEXT_QPC_BYTES_156_PORT_NUM_S) + 1;
+	qp_attr->port_num = hr_qp->port + 1;
 	qp_attr->sq_draining = 0;
 	qp_attr->max_rd_atomic = roce_get_field(context->qpc_bytes_156,
 				 QP_CONTEXT_QPC_BYTES_156_INITIATOR_DEPTH_M,
-- 
1.7.9.5


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
