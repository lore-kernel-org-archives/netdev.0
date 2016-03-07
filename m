From: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V4 3/4] net-next: mediatek: add Kconfig and Makefile
Date: Mon,  7 Mar 2016 09:56:36 +0100
Message-ID: <1457340997-23116-4-git-send-email-blogic@openwrt.org>
References: <1457340997-23116-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 =?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
 <steven.liu-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 =?UTF-8?q?Carlos=20Huang=20=28=E9=BB=83=E5=A3=AB=E5=BD=B0=29?=
 <Carlos.Huang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1457340997-23116-1-git-send-email-blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the Makefile and Kconfig required to make the driver build.

Signed-off-by: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/Kconfig           |    1 +
 drivers/net/ethernet/Makefile          |    1 +
 drivers/net/ethernet/mediatek/Kconfig  |   17 +++++++++++++++++
 drivers/net/ethernet/mediatek/Makefile |    5 +++++
 4 files changed, 24 insertions(+)
 create mode 100644 drivers/net/ethernet/mediatek/Kconfig
 create mode 100644 drivers/net/ethernet/mediatek/Makefile

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 0b13af8..be67a19 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -106,6 +106,7 @@ config LANTIQ_ETOP
 	  Support for the MII0 inside the Lantiq SoC
 
 source "drivers/net/ethernet/marvell/Kconfig"
+source "drivers/net/ethernet/mediatek/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
 source "drivers/net/ethernet/microchip/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 38dc1a7..6ffcc80 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -46,6 +46,7 @@ obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_LANTIQ_ETOP) += lantiq_etop.o
 obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
+obj-$(CONFIG_NET_VENDOR_MEDIATEK) += mediatek/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
 obj-$(CONFIG_NET_VENDOR_MICROCHIP) += microchip/
diff --git a/drivers/net/ethernet/mediatek/Kconfig b/drivers/net/ethernet/mediatek/Kconfig
new file mode 100644
index 0000000..b0229f4
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/Kconfig
@@ -0,0 +1,17 @@
+config NET_VENDOR_MEDIATEK
+	bool "MediaTek ethernet driver"
+	depends on ARCH_MEDIATEK
+	---help---
+	  If you have a Mediatek SoC with ethernet, say Y.
+
+if NET_VENDOR_MEDIATEK
+
+config NET_MEDIATEK_SOC
+	tristate "MediaTek MT7623 Gigabit ethernet support"
+	depends on NET_VENDOR_MEDIATEK #&& (MACH_MT7623 || MACH_MT2701)
+	select PHYLIB
+	---help---
+	  This driver supports the gigabit ethernet MACs in the
+	  MediaTek MT2701/MT7623 chipset family.
+
+endif #NET_VENDOR_MEDIATEK
diff --git a/drivers/net/ethernet/mediatek/Makefile b/drivers/net/ethernet/mediatek/Makefile
new file mode 100644
index 0000000..aa3f1c8
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Mediatek SoCs built-in ethernet macs
+#
+
+obj-$(CONFIG_NET_MEDIATEK_SOC)			+= mtk_eth_soc.o
-- 
1.7.10.4
