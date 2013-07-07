From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH V3 9/9] IB/mlx5: Mellanox Connect-IB, IB driver part 5/5
Date: Sun,  7 Jul 2013 17:25:57 +0300
Message-ID: <1373207157-13914-10-git-send-email-ogerlitz@mellanox.com>
References: <1373207157-13914-1-git-send-email-ogerlitz@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org,
	eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-/2BXmqF2cC23tgiLVFxglmZHpeb/A1Y/@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1373207157-13914-1-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Jack Morgenstein <jackm-/2BXmqF2cC23tgiLVFxglmZHpeb/A1Y/@public.gmane.org>
Signed-off-by: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 MAINTAINERS                         |   10 ++++++++++
 drivers/infiniband/Kconfig          |    1 +
 drivers/infiniband/Makefile         |    1 +
 drivers/infiniband/hw/mlx5/Kconfig  |   10 ++++++++++
 drivers/infiniband/hw/mlx5/Makefile |    3 +++
 5 files changed, 25 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/hw/mlx5/Kconfig
 create mode 100644 drivers/infiniband/hw/mlx5/Makefile

diff --git a/MAINTAINERS b/MAINTAINERS
index 6e82fb5..b426536 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5377,6 +5377,16 @@ S:	Supported
 F:	drivers/net/ethernet/mellanox/mlx5/core/
 F:	include/linux/mlx5/
 
+Mellanox MLX5 IB driver
+M:      Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
+L:      linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+W:      http://www.mellanox.com
+Q:      http://patchwork.kernel.org/project/linux-rdma/list/
+T:      git://openfabrics.org/~eli/connect-ib.git
+S:      Supported
+F:      include/linux/mlx5/
+F:      drivers/infiniband/hw/mlx5/
+
 MODULE SUPPORT
 M:	Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
 S:	Maintained
diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index c85b56c..5ceda71 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -50,6 +50,7 @@ source "drivers/infiniband/hw/amso1100/Kconfig"
 source "drivers/infiniband/hw/cxgb3/Kconfig"
 source "drivers/infiniband/hw/cxgb4/Kconfig"
 source "drivers/infiniband/hw/mlx4/Kconfig"
+source "drivers/infiniband/hw/mlx5/Kconfig"
 source "drivers/infiniband/hw/nes/Kconfig"
 source "drivers/infiniband/hw/ocrdma/Kconfig"
 
diff --git a/drivers/infiniband/Makefile b/drivers/infiniband/Makefile
index b126fef..1fe6988 100644
--- a/drivers/infiniband/Makefile
+++ b/drivers/infiniband/Makefile
@@ -7,6 +7,7 @@ obj-$(CONFIG_INFINIBAND_AMSO1100)	+= hw/amso1100/
 obj-$(CONFIG_INFINIBAND_CXGB3)		+= hw/cxgb3/
 obj-$(CONFIG_INFINIBAND_CXGB4)		+= hw/cxgb4/
 obj-$(CONFIG_MLX4_INFINIBAND)		+= hw/mlx4/
+obj-$(CONFIG_MLX5_INFINIBAND)		+= hw/mlx5/
 obj-$(CONFIG_INFINIBAND_NES)		+= hw/nes/
 obj-$(CONFIG_INFINIBAND_OCRDMA)		+= hw/ocrdma/
 obj-$(CONFIG_INFINIBAND_IPOIB)		+= ulp/ipoib/
diff --git a/drivers/infiniband/hw/mlx5/Kconfig b/drivers/infiniband/hw/mlx5/Kconfig
new file mode 100644
index 0000000..8e6aebf
--- /dev/null
+++ b/drivers/infiniband/hw/mlx5/Kconfig
@@ -0,0 +1,10 @@
+config MLX5_INFINIBAND
+	tristate "Mellanox Connect-IB HCA support"
+	depends on NETDEVICES && ETHERNET && PCI && X86
+	select NET_VENDOR_MELLANOX
+	select MLX5_CORE
+	---help---
+	  This driver provides low-level InfiniBand support for
+	  Mellanox Connect-IB PCI Express host channel adapters (HCAs).
+	  This is required to use InfiniBand protocols such as
+	  IP-over-IB or SRP with these devices.
diff --git a/drivers/infiniband/hw/mlx5/Makefile b/drivers/infiniband/hw/mlx5/Makefile
new file mode 100644
index 0000000..4ea0135
--- /dev/null
+++ b/drivers/infiniband/hw/mlx5/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_MLX5_INFINIBAND)	+= mlx5_ib.o
+
+mlx5_ib-y :=	main.o cq.o doorbell.o qp.o mem.o srq.o mr.o ah.o mad.o
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
