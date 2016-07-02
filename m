From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v11 20/22] IB/hns: Add operation for getting immutable port
Date: Sat, 2 Jul 2016 17:39:22 +0800
Message-ID: <1467452364-66522-21-git-send-email-oulijun@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch added a new verbs that is getting port immutable.
It is added in the 4.5 kernel and latest. It is necessary to
solve the fail questions for registering ib device.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
PATCH v11/v10/v9:
- No change over the PATCH v8

PATCH v8:
- The initial patch
---
---
 drivers/infiniband/hw/hns/hns_roce_main.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 1b1ffc4..c1c1feb 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -548,6 +548,25 @@ static int hns_roce_mmap(struct ib_ucontext *context,
 	return 0;
 }
 
+static int hns_roce_port_immutable(struct ib_device *ib_dev, u8 port_num,
+				   struct ib_port_immutable *immutable)
+{
+	struct ib_port_attr attr;
+	int ret;
+
+	ret = hns_roce_query_port(ib_dev, port_num, &attr);
+	if (ret)
+		return ret;
+
+	immutable->pkey_tbl_len = attr.pkey_tbl_len;
+	immutable->gid_tbl_len = attr.gid_tbl_len;
+
+	immutable->core_cap_flags = RDMA_CORE_PORT_IBA_ROCE;
+	immutable->max_mad_size = IB_MGMT_MAD_SIZE;
+
+	return 0;
+}
+
 static void hns_roce_unregister_device(struct hns_roce_dev *hr_dev)
 {
 	struct hns_roce_ib_iboe *iboe = &hr_dev->iboe;
@@ -633,6 +652,9 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 	ib_dev->reg_user_mr		= hns_roce_reg_user_mr;
 	ib_dev->dereg_mr		= hns_roce_dereg_mr;
 
+	/* OTHERS */
+	ib_dev->get_port_immutable	= hns_roce_port_immutable;
+
 	ret = ib_register_device(ib_dev, NULL);
 	if (ret) {
 		dev_err(dev, "ib_register_device failed!\n");
-- 
1.9.1
