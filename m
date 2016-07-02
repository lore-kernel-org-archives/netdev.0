From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v11 21/22] IB/hns: Kconfig and Makefile for RoCE module
Date: Sat, 2 Jul 2016 17:39:23 +0800
Message-ID: <1467452364-66522-22-git-send-email-oulijun@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch added Kconfig and Makefile for building RoCE module.

Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
PATCH v11:
hns_roce_icm.o -> hns_roce_hem.o

PATCH v10/v9/v8/v7/v6/v5:
- No change over the PATCH v4

PATCH v4:
This fixes the comments given by Christoph Hellwig over the PATCH v3:
  Link: https://lkml.org/lkml/2016/3/22/609

PATCH V3:
This fixes the comments given by Leon Romanovsky over the PATCH v2:
  Link: https://lkml.org/lkml/2016/3/20/5

PATCH v2:
This fixes the comments given by Leon Romanovsky over the PATCH v1:
  Link: https://lkml.org/lkml/2016/3/6/94
Fixes the error tested by kbuild test robot over the PATCH v1:
  Link: https://lkml.org/lkml/2016/3/4/343

PATCH v1:
- The initial patch
---
---
 drivers/infiniband/Kconfig         |  1 +
 drivers/infiniband/hw/Makefile     |  1 +
 drivers/infiniband/hw/hns/Kconfig  | 10 ++++++++++
 drivers/infiniband/hw/hns/Makefile |  8 ++++++++
 4 files changed, 20 insertions(+)
 create mode 100644 drivers/infiniband/hw/hns/Kconfig
 create mode 100644 drivers/infiniband/hw/hns/Makefile

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index 2137adf..767f92b 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -74,6 +74,7 @@ source "drivers/infiniband/hw/mlx5/Kconfig"
 source "drivers/infiniband/hw/nes/Kconfig"
 source "drivers/infiniband/hw/ocrdma/Kconfig"
 source "drivers/infiniband/hw/usnic/Kconfig"
+source "drivers/infiniband/hw/hns/Kconfig"
 
 source "drivers/infiniband/ulp/ipoib/Kconfig"
 
diff --git a/drivers/infiniband/hw/Makefile b/drivers/infiniband/hw/Makefile
index c0c7cf8..2ad851d 100644
--- a/drivers/infiniband/hw/Makefile
+++ b/drivers/infiniband/hw/Makefile
@@ -9,3 +9,4 @@ obj-$(CONFIG_INFINIBAND_NES)		+= nes/
 obj-$(CONFIG_INFINIBAND_OCRDMA)		+= ocrdma/
 obj-$(CONFIG_INFINIBAND_USNIC)		+= usnic/
 obj-$(CONFIG_INFINIBAND_HFI1)		+= hfi1/
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
index 0000000..8bb7e85
--- /dev/null
+++ b/drivers/infiniband/hw/hns/Makefile
@@ -0,0 +1,8 @@
+#
+# Makefile for the HISILICON RoCE drivers.
+#
+
+obj-$(CONFIG_INFINIBAND_HISILICON_HNS) += hns-roce.o
+hns-roce-objs := hns_roce_main.o hns_roce_cmd.o hns_roce_eq.o hns_roce_pd.o \
+	hns_roce_ah.o hns_roce_hem.o hns_roce_mr.o hns_roce_qp.o \
+	hns_roce_cq.o hns_roce_alloc.o hns_roce_hw_v1.o
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
