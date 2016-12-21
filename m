From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for bnxt_re V4 21/21] RDMA/bnxt_re: Add bnxt_re driver build support
Date: Wed, 21 Dec 2016 03:42:10 -0800
Message-ID: <1482320530-5344-22-git-send-email-selvin.xavier@broadcom.com>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482320530-5344-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Makefile and Kconfig changes for enabling bnxt_re compilation

v3: Adds list of MAINTAINERS of bnxt_re driver. Removes bnxt_re_debugfs.c from
    Makefile as this file is no longer present

Signed-off-by: Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 MAINTAINERS                            | 11 +++++++++++
 drivers/infiniband/Kconfig             |  2 ++
 drivers/infiniband/hw/Makefile         |  1 +
 drivers/infiniband/hw/bnxt_re/Kconfig  |  9 +++++++++
 drivers/infiniband/hw/bnxt_re/Makefile |  6 ++++++
 5 files changed, 29 insertions(+)
 create mode 100644 drivers/infiniband/hw/bnxt_re/Kconfig
 create mode 100644 drivers/infiniband/hw/bnxt_re/Makefile

diff --git a/MAINTAINERS b/MAINTAINERS
index 331f6af..a4e7b13 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2776,6 +2776,17 @@ L:	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org (moderated for non-subscribers)
 S:	Maintained
 F:	arch/arm64/boot/dts/broadcom/vulcan*
 
+BROADCOM NETXTREME-E ROCE DRIVER
+M:	Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
+M:	Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
+M:	Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
+M:	Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
+L:	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+W:	http://www.broadcom.com
+S:	Supported
+F:	drivers/infiniband/hw/bnxt_re/
+F:	include/uapi/rdma/bnxt_re-abi.h
+
 BROCADE BFA FC SCSI DRIVER
 M:	Anil Gurumurthy <anil.gurumurthy-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
 M:	Sudarsana Kalluru <sudarsana.kalluru-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index fb3fb89..257172c 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -91,4 +91,6 @@ source "drivers/infiniband/hw/hfi1/Kconfig"
 
 source "drivers/infiniband/hw/qedr/Kconfig"
 
+source "drivers/infiniband/hw/bnxt_re/Kconfig"
+
 endif # INFINIBAND
diff --git a/drivers/infiniband/hw/Makefile b/drivers/infiniband/hw/Makefile
index e7a5ed9..b8b7545 100644
--- a/drivers/infiniband/hw/Makefile
+++ b/drivers/infiniband/hw/Makefile
@@ -11,3 +11,4 @@ obj-$(CONFIG_INFINIBAND_USNIC)		+= usnic/
 obj-$(CONFIG_INFINIBAND_HFI1)		+= hfi1/
 obj-$(CONFIG_INFINIBAND_HNS)		+= hns/
 obj-$(CONFIG_INFINIBAND_QEDR)		+= qedr/
+obj-$(CONFIG_INFINIBAND_BNXT_RE)	+= bnxt_re/
diff --git a/drivers/infiniband/hw/bnxt_re/Kconfig b/drivers/infiniband/hw/bnxt_re/Kconfig
new file mode 100644
index 0000000..cd0175e
--- /dev/null
+++ b/drivers/infiniband/hw/bnxt_re/Kconfig
@@ -0,0 +1,9 @@
+config INFINIBAND_BNXT_RE
+    tristate "Broadcom Netxtreme HCA support"
+    depends on ETHERNET && NETDEVICES && PCI && INET
+    select NET_VENDOR_BROADCOM
+    select BNXT
+    ---help---
+	  This driver supports Broadcom NetXtreme-E 10/25/40/50 gigabit
+	  RoCE HCAs.  To compile this driver as a module, choose M here:
+	  the module will be called bnxt_re.
diff --git a/drivers/infiniband/hw/bnxt_re/Makefile b/drivers/infiniband/hw/bnxt_re/Makefile
new file mode 100644
index 0000000..036f84e
--- /dev/null
+++ b/drivers/infiniband/hw/bnxt_re/Makefile
@@ -0,0 +1,6 @@
+
+ccflags-y := -Idrivers/net/ethernet/broadcom/bnxt
+obj-$(CONFIG_INFINIBAND_BNXT_RE) += bnxt_re.o
+bnxt_re-y := main.o ib_verbs.o \
+	     qplib_res.o qplib_rcfw.o	\
+	     qplib_sp.o qplib_fp.o
-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
