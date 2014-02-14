From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v5 08/10] net: bcmgenet: hook into the build system
Date: Thu, 13 Feb 2014 16:08:49 -0800
Message-ID: <1392336531-28875-9-git-send-email-f.fainelli@gmail.com>
References: <1392336531-28875-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1392336531-28875-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds a new configuration symbol: CONFIG_BCMGENET which allows
us to build the Broadcom GENET driver and hook the driver files into the
build system.

Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
Changes in v5:
- add a dependency on CONFIG_OF

Changes in v4:
- fixed Kconfig dependency against FIXED_PHY which can only be
  selected if BCMGENET is not modular

Changes in v1, v2, v3:
- rebased against net-next/master

 drivers/net/ethernet/broadcom/Kconfig        | 11 +++++++++++
 drivers/net/ethernet/broadcom/Makefile       |  1 +
 drivers/net/ethernet/broadcom/genet/Makefile |  2 ++
 3 files changed, 14 insertions(+)
 create mode 100644 drivers/net/ethernet/broadcom/genet/Makefile

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 3f97d9f..85dbddd 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -60,6 +60,17 @@ config BCM63XX_ENET
 	  This driver supports the ethernet MACs in the Broadcom 63xx
 	  MIPS chipset family (BCM63XX).
 
+config BCMGENET
+	tristate "Broadcom GENET internal MAC support"
+	depends on OF
+	select MII
+	select PHYLIB
+	select FIXED_PHY if BCMGENET=y
+	select BCM7XXX_PHY
+	help
+	  This driver supports the built-in Ethernet MACs found in the
+	  Broadcom BCM7xxx Set Top Box family chipset.
+
 config BNX2
 	tristate "Broadcom NetXtremeII support"
 	depends on PCI
diff --git a/drivers/net/ethernet/broadcom/Makefile b/drivers/net/ethernet/broadcom/Makefile
index 68efa1a..fd639a0 100644
--- a/drivers/net/ethernet/broadcom/Makefile
+++ b/drivers/net/ethernet/broadcom/Makefile
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_B44) += b44.o
 obj-$(CONFIG_BCM63XX_ENET) += bcm63xx_enet.o
+obj-$(CONFIG_BCMGENET) += genet/
 obj-$(CONFIG_BNX2) += bnx2.o
 obj-$(CONFIG_CNIC) += cnic.o
 obj-$(CONFIG_BNX2X) += bnx2x/
diff --git a/drivers/net/ethernet/broadcom/genet/Makefile b/drivers/net/ethernet/broadcom/genet/Makefile
new file mode 100644
index 0000000..31f55a9
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/genet/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_BCMGENET) += genet.o
+genet-objs := bcmgenet.o bcmmii.o
-- 
1.8.3.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
