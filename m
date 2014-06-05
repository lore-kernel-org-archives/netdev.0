From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH V3 net-next 4/5] amd-xgbe: Configuration and build support
Date: Thu, 5 Jun 2014 09:15:18 -0500
Message-ID: <20140605141518.19317.75592.stgit@tlendack-t1.amdoffice.net>
References: <20140605141454.19317.87165.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <jcm@redhat.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0185.outbound.protection.outlook.com ([207.46.163.185]:14027
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751661AbaFEOPZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 10:15:25 -0400
In-Reply-To: <20140605141454.19317.87165.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides the Kconfig and Makefile changes needed
to configure and build the AMD 10GbE platform driver and the
AMD 10GbE phylib driver.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/Kconfig  |   14 +++++++++++++-
 drivers/net/ethernet/amd/Makefile |    1 +
 drivers/net/phy/Kconfig           |    6 ++++++
 drivers/net/phy/Makefile          |    1 +
 4 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 562df46..bbaf36d 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -7,7 +7,7 @@ config NET_VENDOR_AMD
 	default y
 	depends on DIO || MACH_DECSTATION || MVME147 || ATARI || SUN3 || \
 		   SUN3X || SBUS || PCI || ZORRO || (ISA && ISA_DMA_API) || \
-		   (ARM && ARCH_EBSA110) || ISA || EISA || PCMCIA
+		   (ARM && ARCH_EBSA110) || ISA || EISA || PCMCIA || ARM64
 	---help---
 	  If you have a network (Ethernet) chipset belonging to this class,
 	  say Y.
@@ -177,4 +177,16 @@ config SUNLANCE
 	  To compile this driver as a module, choose M here: the module
 	  will be called sunlance.
 
+config AMD_XGBE
+	tristate "AMD 10GbE Ethernet driver"
+	depends on OF_NET
+	select PHYLIB
+	select AMD_XGBE_PHY
+	---help---
+	  This driver supports the AMD 10GbE Ethernet device found on an
+	  AMD SoC.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called amd-xgbe.
+
 endif # NET_VENDOR_AMD
diff --git a/drivers/net/ethernet/amd/Makefile b/drivers/net/ethernet/amd/Makefile
index cdd4301..a38a2dc 100644
--- a/drivers/net/ethernet/amd/Makefile
+++ b/drivers/net/ethernet/amd/Makefile
@@ -17,3 +17,4 @@ obj-$(CONFIG_NI65) += ni65.o
 obj-$(CONFIG_PCNET32) += pcnet32.o
 obj-$(CONFIG_SUN3LANCE) += sun3lance.o
 obj-$(CONFIG_SUNLANCE) += sunlance.o
+obj-$(CONFIG_AMD_XGBE) += xgbe/
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6a17f92..65de0ca 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -24,6 +24,12 @@ config AMD_PHY
 	---help---
 	  Currently supports the am79c874
 
+config AMD_XGBE_PHY
+	tristate "Driver for the AMD 10GbE (amd-xgbe) PHYs"
+	depends on OF
+	---help---
+	  Currently supports the AMD 10GbE PHY
+
 config MARVELL_PHY
 	tristate "Drivers for Marvell PHYs"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 07d2402..7dc3d5b 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -33,3 +33,4 @@ obj-$(CONFIG_MDIO_BUS_MUX_GPIO)	+= mdio-mux-gpio.o
 obj-$(CONFIG_MDIO_BUS_MUX_MMIOREG) += mdio-mux-mmioreg.o
 obj-$(CONFIG_MDIO_SUN4I)	+= mdio-sun4i.o
 obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
+obj-$(CONFIG_AMD_XGBE_PHY)	+= amd-xgbe-phy.o
