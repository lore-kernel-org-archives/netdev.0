From: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: [PATCH] SIW: Kconfig and Makefile
Date: Tue,  5 Oct 2010 08:53:00 +0200
Message-ID: <1286261580-5065-1-git-send-email-bmt@zurich.ibm.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

---
 drivers/infiniband/Kconfig         |    1 +
 drivers/infiniband/Makefile        |    1 +
 drivers/infiniband/hw/siw/Kconfig  |   14 ++++++++++++++
 drivers/infiniband/hw/siw/Makefile |    5 +++++
 4 files changed, 21 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/hw/siw/Kconfig
 create mode 100644 drivers/infiniband/hw/siw/Makefile

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index 89d70de..524a31c 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -50,6 +50,7 @@ source "drivers/infiniband/hw/cxgb3/Kconfig"
 source "drivers/infiniband/hw/cxgb4/Kconfig"
 source "drivers/infiniband/hw/mlx4/Kconfig"
 source "drivers/infiniband/hw/nes/Kconfig"
+source "drivers/infiniband/hw/siw/Kconfig"
 
 source "drivers/infiniband/ulp/ipoib/Kconfig"
 
diff --git a/drivers/infiniband/Makefile b/drivers/infiniband/Makefile
index 9cc7a47..c01a0d6 100644
--- a/drivers/infiniband/Makefile
+++ b/drivers/infiniband/Makefile
@@ -8,6 +8,7 @@ obj-$(CONFIG_INFINIBAND_CXGB3)		+= hw/cxgb3/
 obj-$(CONFIG_INFINIBAND_CXGB4)		+= hw/cxgb4/
 obj-$(CONFIG_MLX4_INFINIBAND)		+= hw/mlx4/
 obj-$(CONFIG_INFINIBAND_NES)		+= hw/nes/
+obj-$(CONFIG_INFINIBAND_SOFTIWARP)	+= hw/siw/
 obj-$(CONFIG_INFINIBAND_IPOIB)		+= ulp/ipoib/
 obj-$(CONFIG_INFINIBAND_SRP)		+= ulp/srp/
 obj-$(CONFIG_INFINIBAND_ISER)		+= ulp/iser/
diff --git a/drivers/infiniband/hw/siw/Kconfig b/drivers/infiniband/hw/siw/Kconfig
new file mode 100644
index 0000000..6beff23
--- /dev/null
+++ b/drivers/infiniband/hw/siw/Kconfig
@@ -0,0 +1,14 @@
+config INFINIBAND_SOFTIWARP
+	tristate "Software iWARP Stack (EXPERIMENTAL)"
+	depends on INET && EXPERIMENTAL
+	---help---
+	  Kernel Software Implementation of the iWARP protocol stack
+
+	  This driver implements the iWARP protocol stack in software
+	  and interfaces with in-kernel TCP/IP as well as the OFED
+	  verbs interfaces.
+
+	  Please send feedback to <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called siw.
diff --git a/drivers/infiniband/hw/siw/Makefile b/drivers/infiniband/hw/siw/Makefile
new file mode 100644
index 0000000..28344b7
--- /dev/null
+++ b/drivers/infiniband/hw/siw/Makefile
@@ -0,0 +1,5 @@
+obj-$(CONFIG_INFINIBAND_SOFTIWARP) += siw.o
+
+siw-y := siw_main.o siw_cm.o siw_verbs.o siw_obj.o \
+	siw_qp.o siw_qp_tx.o siw_qp_rx.o siw_cq.o siw_cm.o \
+	siw_debug.o siw_ae.o
-- 
1.5.4.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
