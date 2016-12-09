From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH V2  22/22] bnxt_re: Add bnxt_re driver build support
Date: Thu,  8 Dec 2016 22:48:16 -0800
Message-ID: <1481266096-23331-23-git-send-email-selvin.xavier@broadcom.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Makefile and Kconfig changes for enabling bnxt_re compilation

Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/Kconfig            | 2 ++
 drivers/infiniband/hw/Makefile        | 1 +
 drivers/infiniband/hw/bnxtre/Kconfig  | 9 +++++++++
 drivers/infiniband/hw/bnxtre/Makefile | 6 ++++++
 4 files changed, 18 insertions(+)
 create mode 100644 drivers/infiniband/hw/bnxtre/Kconfig
 create mode 100644 drivers/infiniband/hw/bnxtre/Makefile

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index fb3fb89..a4fab22 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -91,4 +91,6 @@ source "drivers/infiniband/hw/hfi1/Kconfig"
 
 source "drivers/infiniband/hw/qedr/Kconfig"
 
+source "drivers/infiniband/hw/bnxtre/Kconfig"
+
 endif # INFINIBAND
diff --git a/drivers/infiniband/hw/Makefile b/drivers/infiniband/hw/Makefile
index e7a5ed9..7227b36 100644
--- a/drivers/infiniband/hw/Makefile
+++ b/drivers/infiniband/hw/Makefile
@@ -11,3 +11,4 @@ obj-$(CONFIG_INFINIBAND_USNIC)		+= usnic/
 obj-$(CONFIG_INFINIBAND_HFI1)		+= hfi1/
 obj-$(CONFIG_INFINIBAND_HNS)		+= hns/
 obj-$(CONFIG_INFINIBAND_QEDR)		+= qedr/
+obj-$(CONFIG_INFINIBAND_BNXTRE)		+= bnxtre/
diff --git a/drivers/infiniband/hw/bnxtre/Kconfig b/drivers/infiniband/hw/bnxtre/Kconfig
new file mode 100644
index 0000000..b1f153f
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/Kconfig
@@ -0,0 +1,9 @@
+config INFINIBAND_BNXTRE
+    tristate "Broadcom Netxtreme HCA support"
+    depends on ETHERNET && NETDEVICES && PCI && INET
+    select NET_VENDOR_BROADCOM
+    select BNXT
+    ---help---
+	  This driver supports Broadcom NetXtreme-E 10/25/40/50 gigabit
+	  RoCE HCAs.  To compile this driver as a module, choose M here:
+	  the module will be called bnxt_re.
diff --git a/drivers/infiniband/hw/bnxtre/Makefile b/drivers/infiniband/hw/bnxtre/Makefile
new file mode 100644
index 0000000..39df4f1
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/Makefile
@@ -0,0 +1,6 @@
+
+ccflags-y := -Idrivers/net/ethernet/broadcom/bnxt
+obj-$(CONFIG_INFINIBAND_BNXTRE) += bnxt_re.o
+bnxt_re-y := bnxt_re_main.o bnxt_re_ib_verbs.o bnxt_re_debugfs.o \
+	     bnxt_qplib_res.o bnxt_qplib_rcfw.o	\
+	     bnxt_qplib_sp.o bnxt_qplib_fp.o
-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
