From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 for-next 06/11] IB/hns: Fix the bug for qp state in hns_roce_v1_m_qp()
Date: Tue, 15 Nov 2016 18:10:48 +0000
Message-ID: <20161115181053.399568-7-salil.mehta@huawei.com>
References: <20161115181053.399568-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <xushaobo2@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <lijun_nudt@163.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115181053.399568-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lijun Ou <oulijun@huawei.com>

In old code, the value of qp state from qpc was assigned for
attr->qp_state. The value may be an error while attr_mask &
IB_QP_STATE is zero.

Signed-off-by: Lijun Ou <oulijun@huawei.com>
Reviewed-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index 643a2ff..b835a55 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -2571,7 +2571,7 @@ static int hns_roce_v1_m_qp(struct ib_qp *ibqp, const struct ib_qp_attr *attr,
 	/* Every status migrate must change state */
 	roce_set_field(context->qpc_bytes_144,
 		       QP_CONTEXT_QPC_BYTES_144_QP_STATE_M,
-		       QP_CONTEXT_QPC_BYTES_144_QP_STATE_S, attr->qp_state);
+		       QP_CONTEXT_QPC_BYTES_144_QP_STATE_S, new_state);
 
 	/* SW pass context to HW */
 	ret = hns_roce_v1_qp_modify(hr_dev, &hr_qp->mtt,
-- 
1.7.9.5
