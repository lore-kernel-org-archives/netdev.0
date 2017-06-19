From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3 net-next 4/7] qed*: qede_roce.[ch] -> qede_rdma.[ch]
Date: Mon, 19 Jun 2017 10:42:34 +0300
Message-ID: <20170619074237.30249-5-Yuval.Mintz@cavium.com>
References: <20170619074237.30249-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170619074237.30249-1-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Once we have iWARP support, the qede portion of the qedr<->qede would
serve all the RDMA protocols - so rename the file to be appropriate
to its function.

While we're at it, we're also moving a couple of inclusions to it into
.h files and adding includes to make sure it contains all type
definitions it requires.

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/qedr/main.c                             | 2 +-
 drivers/infiniband/hw/qedr/qedr.h                             | 2 +-
 drivers/net/ethernet/qlogic/qede/Makefile                     | 2 +-
 drivers/net/ethernet/qlogic/qede/qede.h                       | 1 +
 drivers/net/ethernet/qlogic/qede/qede_main.c                  | 1 -
 drivers/net/ethernet/qlogic/qede/{qede_roce.c => qede_rdma.c} | 2 +-
 include/linux/qed/{qede_roce.h => qede_rdma.h}                | 5 +++++
 7 files changed, 10 insertions(+), 5 deletions(-)
 rename drivers/net/ethernet/qlogic/qede/{qede_roce.c => qede_rdma.c} (99%)
 rename include/linux/qed/{qede_roce.h => qede_rdma.h} (96%)

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
similarity index 96%
rename from include/linux/qed/qede_roce.h
rename to include/linux/qed/qede_rdma.h
index 3b8dd55..a1a9b81 100644
--- a/include/linux/qed/qede_roce.h
+++ b/include/linux/qed/qede_rdma.h
@@ -32,6 +32,11 @@
 #ifndef QEDE_ROCE_H
 #define QEDE_ROCE_H
 
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/types.h>
+#include <linux/workqueue.h>
+
 struct qedr_dev;
 struct qed_dev;
 struct qede_dev;
-- 
2.9.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
