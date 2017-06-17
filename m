From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 net-next 8/8] net: hns3: Add HNS3 driver to kernel build framework & MAINTAINERS
Date: Sat, 17 Jun 2017 18:24:31 +0100
Message-ID: <20170617172431.177044-9-salil.mehta@huawei.com>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170617172431.177044-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch updates the MAINTAINERS file with HNS3 Ethernet driver
maintainers names and other details. This also introduces the new
Makefiles required to build the HNS3 Ethernet driver and updates
the existing Kconfig file in the hisilicon folder.

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
Patch V3: Addressed below errors:
 1. Intel kbuild: https://lkml.org/lkml/2017/6/14/313
 2. Intel Kbuild: https://lkml.org/lkml/2017/6/14/636
Patch V2: No change
Patch V1: Initial Submit
---
 MAINTAINERS                                        |  8 +++++++
 drivers/net/ethernet/hisilicon/Kconfig             | 27 ++++++++++++++++++++++
 drivers/net/ethernet/hisilicon/Makefile            |  1 +
 drivers/net/ethernet/hisilicon/hns3/Makefile       |  7 ++++++
 .../net/ethernet/hisilicon/hns3/hns3pf/Makefile    | 11 +++++++++
 5 files changed, 54 insertions(+)
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/Makefile
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile

diff --git a/MAINTAINERS b/MAINTAINERS
index 8b8249b..cda0e80 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6070,6 +6070,14 @@ S:	Maintained
 F:	drivers/net/ethernet/hisilicon/
 F:	Documentation/devicetree/bindings/net/hisilicon*.txt
 
+HISILICON NETWORK SUBSYSTEM 3 DRIVER (HNS3)
+M:	Yisen Zhuang <yisen.zhuang@huawei.com>
+M:	Salil Mehta <salil.mehta@huawei.com>
+L:	netdev@vger.kernel.org
+W:	http://www.hisilicon.com
+S:	Maintained
+F:	drivers/net/ethernet/hisilicon/hns3/
+
 HISILICON ROCE DRIVER
 M:	Lijun Ou <oulijun@huawei.com>
 M:	Wei Hu(Xavier) <xavier.huwei@huawei.com>
diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
index d11287e..9f8ea28 100644
--- a/drivers/net/ethernet/hisilicon/Kconfig
+++ b/drivers/net/ethernet/hisilicon/Kconfig
@@ -76,4 +76,31 @@ config HNS_ENET
 	  This selects the general ethernet driver for HNS.  This module make
 	  use of any HNS AE driver, such as HNS_DSAF
 
+config HNS3
+	tristate "Hisilicon Network Subsystem Support HNS3 (Framework)"
+    depends on PCI
+	---help---
+	  This selects the framework support for Hisilicon Network Subsystem 3.
+	  This layer facilitates clients like ENET, RoCE and user-space ethernet
+	  drivers(like ODP)to register with HNAE devices and their associated
+	  operations.
+
+config HNS3_HCLGE
+	tristate "Hisilicon HNS3 HCLGE Acceleration Engine & Compatibility Layer Support"
+    depends on PCI_MSI
+	select HNS3
+	---help---
+	  This selects the HNS3_HCLGE network acceleration engine & its hardware
+	  compatibility layer. The engine would be used in Hisilicon hip08 family of
+	  SoCs and further upcoming SoCs.
+
+config HNS3_ENET
+	tristate "Hisilicon HNS3 Ethernet Device Support"
+    depends on 64BIT && PCI
+	select HNS3
+	---help---
+	  This selects the Ethernet Driver for Hisilicon Network Subsystem 3 for hip08
+	  family of SoCs. This module depends upon HNAE3 driver to access the HNAE3
+	  devices and their associated operations.
+
 endif # NET_VENDOR_HISILICON
diff --git a/drivers/net/ethernet/hisilicon/Makefile b/drivers/net/ethernet/hisilicon/Makefile
index 8661695..3828c43 100644
--- a/drivers/net/ethernet/hisilicon/Makefile
+++ b/drivers/net/ethernet/hisilicon/Makefile
@@ -6,4 +6,5 @@ obj-$(CONFIG_HIX5HD2_GMAC) += hix5hd2_gmac.o
 obj-$(CONFIG_HIP04_ETH) += hip04_eth.o
 obj-$(CONFIG_HNS_MDIO) += hns_mdio.o
 obj-$(CONFIG_HNS) += hns/
+obj-$(CONFIG_HNS3) += hns3/
 obj-$(CONFIG_HISI_FEMAC) += hisi_femac.o
diff --git a/drivers/net/ethernet/hisilicon/hns3/Makefile b/drivers/net/ethernet/hisilicon/hns3/Makefile
new file mode 100644
index 0000000..5e53735
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns3/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the HISILICON network device drivers.
+#
+
+obj-$(CONFIG_HNS3) += hns3pf/
+
+obj-$(CONFIG_HNS3) +=hnae3.o
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile b/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
new file mode 100644
index 0000000..c0a92b5
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
@@ -0,0 +1,11 @@
+#
+# Makefile for the HISILICON network device drivers.
+#
+
+ccflags-y := -Idrivers/net/ethernet/hisilicon/hns3
+
+obj-$(CONFIG_HNS3_HCLGE) += hclge.o
+hclge-objs =hclge_main.o hclge_cmd.o hclge_mdio.o hclge_tm.o
+
+obj-$(CONFIG_HNS3_ENET) += hns3.o
+hns3-objs = hns3_enet.o hns3_ethtool.o
-- 
2.7.4
