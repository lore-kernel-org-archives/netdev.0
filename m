From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 for-next 08/11] IB/hns: Modify query info named port_num when querying RC QP
Date: Wed, 23 Nov 2016 19:41:06 +0000
Message-ID: <20161123194109.420760-9-salil.mehta@huawei.com>
References: <20161123194109.420760-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <xushaobo2@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <lijun_nudt@163.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161123194109.420760-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>

This patch modified the output query info qp_attr->port_num
to fix bug in hip06.

Signed-off-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>
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
