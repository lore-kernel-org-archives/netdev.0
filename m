From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v8 21/22] IB/hns: Kconfig and Makefile for RoCE module
Date: Wed, 25 May 2016 23:05:24 +0800
Message-ID: <1464188725-42805-22-git-send-email-oulijun@huawei.com>
References: <1464188725-42805-1-git-send-email-oulijun@huawei.com>
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
In-Reply-To: <1464188725-42805-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch added Kconfig and Makefile for building RoCE module.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
 drivers/infiniband/Kconfig         |  1 +
 drivers/infiniband/hw/Makefile     |  1 +
 drivers/infiniband/hw/hns/Kconfig  | 10 ++++++++++
 drivers/infiniband/hw/hns/Makefile |  9 +++++++++
 4 files changed, 21 insertions(+)
 create mode 100644 drivers/infiniband/hw/hns/Kconfig
 create mode 100644 drivers/infiniband/hw/hns/Makefile

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index 6425c0e..726a4ca 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -74,6 +74,7 @@ source "drivers/infiniband/hw/mlx5/Kconfig"
 source "drivers/infiniband/hw/nes/Kconfig"
 source "drivers/infiniband/hw/ocrdma/Kconfig"
 source "drivers/infiniband/hw/usnic/Kconfig"
+source "drivers/infiniband/hw/hns/Kconfig"
 
 source "drivers/infiniband/ulp/ipoib/Kconfig"
 
diff --git a/drivers/infiniband/hw/Makefile b/drivers/infiniband/hw/Makefile
index c7ad0a4..223eb78 100644
--- a/drivers/infiniband/hw/Makefile
+++ b/drivers/infiniband/hw/Makefile
@@ -8,3 +8,4 @@ obj-$(CONFIG_MLX5_INFINIBAND)		+= mlx5/
 obj-$(CONFIG_INFINIBAND_NES)		+= nes/
 obj-$(CONFIG_INFINIBAND_OCRDMA)		+= ocrdma/
 obj-$(CONFIG_INFINIBAND_USNIC)		+= usnic/
+obj-$(CONFIG_INFINIBAND_HISILICON_HNS) 	+= hns/
diff --git a/drivers/infiniband/hw/hns/Kconfig b/drivers/infiniband/hw/hns/Kconfig
new file mode 100644
index 0000000..c47c168
--- /dev/null
+++ b/drivers/infiniband/hw/hns/Kconfig
@@ -0,0 +1,10 @@
+config INFINIBAND_HISILICON_HNS
+	tristate "Hisilicon Hns ROCE Driver"
+	depends on NET_VENDOR_HISILICON
+	depends on ARM64 && HNS && HNS_DSAF && HNS_ENET
+	---help---
+	  This is a ROCE/RDMA driver for the Hisilicon RoCE engine. The engine
+	  is used in Hisilicon Hi1610 and more further ICT SoC.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called hns-roce.
diff --git a/drivers/infiniband/hw/hns/Makefile b/drivers/infiniband/hw/hns/Makefile
new file mode 100644
index 0000000..404a700
--- /dev/null
+++ b/drivers/infiniband/hw/hns/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for the HISILICON RoCE drivers.
+#
+
+obj-$(CONFIG_INFINIBAND_HISILICON_HNS) += hns-roce.o
+hns-roce-objs := hns_roce_main.o hns_roce_cmd.o hns_roce_eq.o hns_roce_pd.o \
+	hns_roce_ah.o hns_roce_icm.o hns_roce_mr.o hns_roce_qp.o \
+	hns_roce_cq.o hns_roce_alloc.o hns_roce_hw_v1.o
+
-- 
1.9.1
