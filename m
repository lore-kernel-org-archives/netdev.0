From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 4/7] qed*: Rename qede_roce.[ch]
Date: Thu, 15 Jun 2017 23:29:30 +0300
Message-ID: <20170615202933.20934-5-Yuval.Mintz@cavium.com>
References: <20170615202933.20934-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0062.outbound.protection.outlook.com ([104.47.41.62]:20730
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752070AbdFOUbk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 16:31:40 -0400
In-Reply-To: <20170615202933.20934-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kalderon <Michal.Kalderon@cavium.com>

Once we have iWARP support, the qede portion of the qedr<->qede would
serve all the RDMA protocols - so rename the file to be appropriate
to its function.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/infiniband/hw/qedr/main.c                             | 2 +-
 drivers/infiniband/hw/qedr/qedr.h                             | 2 +-
 drivers/net/ethernet/qlogic/qede/Makefile                     | 2 +-
 drivers/net/ethernet/qlogic/qede/qede.h                       | 1 +
 drivers/net/ethernet/qlogic/qede/qede_main.c                  | 1 -
 drivers/net/ethernet/qlogic/qede/{qede_roce.c => qede_rdma.c} | 2 +-
 include/linux/qed/{qede_roce.h => qede_rdma.h}                | 0
 7 files changed, 5 insertions(+), 5 deletions(-)
 rename drivers/net/ethernet/qlogic/qede/{qede_roce.c => qede_rdma.c} (99%)
 rename include/linux/qed/{qede_roce.h => qede_rdma.h} (100%)

diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index 5a32b80..714eb0c 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -37,7 +37,7 @@
 #include <linux/iommu.h>
 #include <linux/pci.h>
 #include <net/addrconf.h>
-#include <linux/qed/qede_roce.h>
+
 #include <linux/qed/qed_chain.h>
 #include <linux/qed/qed_if.h>
 #include "qedr.h"
diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
index 80333ec..2376019 100644
--- a/drivers/infiniband/hw/qedr/qedr.h
+++ b/drivers/infiniband/hw/qedr/qedr.h
@@ -37,7 +37,7 @@
 #include <linux/qed/qed_if.h>
 #include <linux/qed/qed_chain.h>
 #include <linux/qed/qed_roce_if.h>
-#include <linux/qed/qede_roce.h>
+#include <linux/qed/qede_rdma.h>
 #include <linux/qed/roce_common.h>
 #include "qedr_hsi_rdma.h"
 
diff --git a/drivers/net/ethernet/qlogic/qede/Makefile b/drivers/net/ethernet/qlogic/qede/Makefile
index bc5f7c3..75408fb 100644
--- a/drivers/net/ethernet/qlogic/qede/Makefile
+++ b/drivers/net/ethernet/qlogic/qede/Makefile
@@ -2,4 +2,4 @@ obj-$(CONFIG_QEDE) := qede.o
 
 qede-y := qede_main.o qede_fp.o qede_filter.o qede_ethtool.o qede_ptp.o
 qede-$(CONFIG_DCB) += qede_dcbnl.o
-qede-$(CONFIG_QED_RDMA) += qede_roce.o
+qede-$(CONFIG_QED_RDMA) += qede_rdma.o
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 694c09b..2d6b30c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -40,6 +40,7 @@
 #include <linux/kernel.h>
 #include <linux/mutex.h>
 #include <linux/bpf.h>
+#include <linux/qed/qede_rdma.h>
 #include <linux/io.h>
 #ifdef CONFIG_RFS_ACCEL
 #include <linux/cpu_rmap.h>
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 37ad799..e9eaa38 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -60,7 +60,6 @@
 #include <net/ip6_checksum.h>
 #include <linux/bitops.h>
 #include <linux/vmalloc.h>
-#include <linux/qed/qede_roce.h>
 #include "qede.h"
 #include "qede_ptp.h"
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_roce.c b/drivers/net/ethernet/qlogic/qede/qede_rdma.c
similarity index 99%
rename from drivers/net/ethernet/qlogic/qede/qede_roce.c
rename to drivers/net/ethernet/qlogic/qede/qede_rdma.c
index c0030fb..9837ee2 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_roce.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_rdma.c
@@ -33,7 +33,7 @@
 #include <linux/netdevice.h>
 #include <linux/list.h>
 #include <linux/mutex.h>
-#include <linux/qed/qede_roce.h>
+#include <linux/qed/qede_rdma.h>
 #include "qede.h"
 
 static struct qedr_driver *qedr_drv;
diff --git a/include/linux/qed/qede_roce.h b/include/linux/qed/qede_rdma.h
similarity index 100%
rename from include/linux/qed/qede_roce.h
rename to include/linux/qed/qede_rdma.h
-- 
2.9.4
