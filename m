From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [net-next.git 1/3 (V2)] stmmac: remove specific SoC Koption from platform.
Date: Tue, 4 Nov 2014 15:49:32 +0100
Message-ID: <1415112574-21321-2-git-send-email-peppe.cavallaro@st.com>
References: <1415112574-21321-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:60199 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754378AbaKDPBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 10:01:37 -0500
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id sA4ExCbE006681
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2014 16:01:28 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1qeymsre5t-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 16:01:28 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 95F4841
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 15:00:52 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id DE8D8B4D97
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 15:01:18 +0000 (GMT)
In-Reply-To: <1415112574-21321-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes all the Koptions added to build the glue-logic files
for all different architectures: DWMAC_MESON, DWMAC_SUNXI, DWMAC_STI ...
Nowadays the stmmac needs to be compiled on several platforms; in some
case it very convenient to guarantee that its build is always completed
with success on all the branches where the driver is present.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---

V2: re-based on top of the latest updates for net-next

 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   50 ++------------------
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    8 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    9 +---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   10 +----
 4 files changed, 9 insertions(+), 68 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index b02d4a3..40f356d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -18,56 +18,14 @@ config STMMAC_PLATFORM
 	depends on STMMAC_ETH
 	default y
 	---help---
-	  This selects the platform specific bus support for
-	  the stmmac device driver. This is the driver used
-	  on many embedded STM platforms based on ARM and SuperH
-	  processors.
+	  This selects the platform specific bus support for the stmmac driver.
+	  This is the driver used on several SoCs:
+	  STi, Allwinner, Amlogic Meson, Altera SOCFPGA.
+
 	  If you have a controller with this interface, say Y or M here.
 
 	  If unsure, say N.
 
-config DWMAC_MESON
-	bool "Amlogic Meson dwmac support"
-	depends on STMMAC_PLATFORM && ARCH_MESON
-	help
-	  Support for Ethernet controller on Amlogic Meson SoCs.
-
-	  This selects the Amlogic Meson SoC glue layer support for
-	  the stmmac device driver. This driver is used for Meson6 and
-	  Meson8 SoCs.
-
-config DWMAC_SOCFPGA
-	bool "SOCFPGA dwmac support"
-	depends on STMMAC_PLATFORM && MFD_SYSCON && (ARCH_SOCFPGA || COMPILE_TEST)
-	help
-	  Support for ethernet controller on Altera SOCFPGA
-
-	  This selects the Altera SOCFPGA SoC glue layer support
-	  for the stmmac device driver. This driver is used for
-	  arria5 and cyclone5 FPGA SoCs.
-
-config DWMAC_SUNXI
-	bool "Allwinner GMAC support"
-	depends on STMMAC_PLATFORM && ARCH_SUNXI
-	default y
-	---help---
-	  Support for Allwinner A20/A31 GMAC ethernet controllers.
-
-	  This selects Allwinner SoC glue layer support for the
-	  stmmac device driver. This driver is used for A20/A31
-	  GMAC 	  ethernet controller.
-
-config DWMAC_STI
-	bool "STi GMAC support"
-	depends on STMMAC_PLATFORM && ARCH_STI
-	default y
-	---help---
-	  Support for ethernet controller on STi SOCs.
-
-	  This selects STi SoC glue layer support for the stmmac
-	  device driver. This driver is used on for the STi series
-	  SOCs GMAC ethernet controller.
-
 config STMMAC_PCI
 	bool "STMMAC PCI bus support"
 	depends on STMMAC_ETH && PCI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 0533d0b..034da70 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -1,10 +1,8 @@
 obj-$(CONFIG_STMMAC_ETH) += stmmac.o
-stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
 stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
-stmmac-$(CONFIG_DWMAC_MESON) += dwmac-meson.o
-stmmac-$(CONFIG_DWMAC_SUNXI) += dwmac-sunxi.o
-stmmac-$(CONFIG_DWMAC_STI) += dwmac-sti.o
-stmmac-$(CONFIG_DWMAC_SOCFPGA) += dwmac-socfpga.o
+stmmac-$(CONFIG_STMMAC_PLATFORM) +=	stmmac_platform.o dwmac-meson.o \
+					dwmac-sunxi.o dwmac-sti.o \
+					dwmac-socfpga.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 	      chain_mode.o dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o \
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index c3c4065..23aad9a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -137,20 +137,13 @@ void stmmac_disable_eee_mode(struct stmmac_priv *priv);
 bool stmmac_eee_init(struct stmmac_priv *priv);
 
 #ifdef CONFIG_STMMAC_PLATFORM
-#ifdef CONFIG_DWMAC_MESON
 extern const struct stmmac_of_data meson6_dwmac_data;
-#endif
-#ifdef CONFIG_DWMAC_SUNXI
 extern const struct stmmac_of_data sun7i_gmac_data;
-#endif
-#ifdef CONFIG_DWMAC_STI
 extern const struct stmmac_of_data stih4xx_dwmac_data;
 extern const struct stmmac_of_data stid127_dwmac_data;
-#endif
-#ifdef CONFIG_DWMAC_SOCFPGA
 extern const struct stmmac_of_data socfpga_gmac_data;
-#endif
 extern struct platform_driver stmmac_pltfr_driver;
+
 static inline int stmmac_register_platform(void)
 {
 	int err;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index db56fa7..f4fe854 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -30,22 +30,14 @@
 #include "stmmac.h"
 
 static const struct of_device_id stmmac_dt_ids[] = {
-#ifdef CONFIG_DWMAC_MESON
+	/* SoC specific glue layers should come before generic bindings */
 	{ .compatible = "amlogic,meson6-dwmac", .data = &meson6_dwmac_data},
-#endif
-#ifdef CONFIG_DWMAC_SUNXI
 	{ .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
-#endif
-#ifdef CONFIG_DWMAC_STI
 	{ .compatible = "st,stih415-dwmac", .data = &stih4xx_dwmac_data},
 	{ .compatible = "st,stih416-dwmac", .data = &stih4xx_dwmac_data},
 	{ .compatible = "st,stid127-dwmac", .data = &stid127_dwmac_data},
 	{ .compatible = "st,stih407-dwmac", .data = &stih4xx_dwmac_data},
-#endif
-#ifdef CONFIG_DWMAC_SOCFPGA
 	{ .compatible = "altr,socfpga-stmmac", .data = &socfpga_gmac_data },
-#endif
-	/* SoC specific glue layers should come before generic bindings */
 	{ .compatible = "st,spear600-gmac"},
 	{ .compatible = "snps,dwmac-3.610"},
 	{ .compatible = "snps,dwmac-3.70a"},
-- 
1.7.4.4
