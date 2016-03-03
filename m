From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC 10/15] net: ethernet: Add missing MFD_SYSCON dependency on
 HAS_IOMEM
Date: Thu, 03 Mar 2016 17:03:36 +0900
Message-ID: <1456992221-26712-11-git-send-email-k.kozlowski__14964.8882601925$1456992638$gmane$org@samsung.com>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>
To: Daniel Lezcano <daniel.lezcano@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dan Williams <dan.j.williams@intel.com>,
	Vinod Koul <vinod.koul@intel.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
	Lee Jones <lee.jones@linaro.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Sebastian Reichel <sre@kernel.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Alessandro Zummo <a.zummo@towertech.it>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Andy Gross <andy.gross@linaro.org>,
	David Brown <david.brown@linaro.org>,
	Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, dmaen
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.w1.samsung.com ([210.118.77.12]:57994 "EHLO
	mailout2.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932460AbcCCIFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 03:05:35 -0500
In-reply-to: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MFD_SYSCON depends on HAS_IOMEM so when selecting it avoid unmet
direct dependencies.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 drivers/net/ethernet/hisilicon/Kconfig      | 1 +
 drivers/net/ethernet/stmicro/stmmac/Kconfig | 6 ++++++
 drivers/net/ethernet/ti/Kconfig             | 1 +
 3 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
index 74beb1867230..6a9c91781bf9 100644
--- a/drivers/net/ethernet/hisilicon/Kconfig
+++ b/drivers/net/ethernet/hisilicon/Kconfig
@@ -26,6 +26,7 @@ config HIX5HD2_GMAC
 config HIP04_ETH
 	tristate "HISILICON P04 Ethernet support"
 	select MARVELL_PHY
+	depends on HAS_IOMEM	# For MFD_SYSCON
 	select MFD_SYSCON
 	select HNS_MDIO
 	---help---
diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index cec147d1d34f..d6902bf6e90f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -16,6 +16,7 @@ if STMMAC_ETH
 config STMMAC_PLATFORM
 	tristate "STMMAC Platform bus support"
 	depends on STMMAC_ETH
+	depends on HAS_IOMEM	# For MFD_SYSCON
 	select MFD_SYSCON
 	default y
 	---help---
@@ -41,6 +42,7 @@ config DWMAC_IPQ806X
 	tristate "QCA IPQ806x DWMAC support"
 	default ARCH_QCOM
 	depends on OF
+	depends on HAS_IOMEM	# For MFD_SYSCON
 	select MFD_SYSCON
 	help
 	  Support for QCA IPQ806X DWMAC Ethernet.
@@ -54,6 +56,7 @@ config DWMAC_LPC18XX
 	tristate "NXP LPC18xx/43xx DWMAC support"
 	default ARCH_LPC18XX
 	depends on OF
+	depends on HAS_IOMEM	# For MFD_SYSCON
 	select MFD_SYSCON
 	---help---
 	  Support for NXP LPC18xx/43xx DWMAC Ethernet.
@@ -73,6 +76,7 @@ config DWMAC_ROCKCHIP
 	tristate "Rockchip dwmac support"
 	default ARCH_ROCKCHIP
 	depends on OF
+	depends on HAS_IOMEM	# For MFD_SYSCON
 	select MFD_SYSCON
 	help
 	  Support for Ethernet controller on Rockchip RK3288 SoC.
@@ -84,6 +88,7 @@ config DWMAC_SOCFPGA
 	tristate "SOCFPGA dwmac support"
 	default ARCH_SOCFPGA
 	depends on OF
+	depends on HAS_IOMEM	# For MFD_SYSCON
 	select MFD_SYSCON
 	help
 	  Support for ethernet controller on Altera SOCFPGA
@@ -96,6 +101,7 @@ config DWMAC_STI
 	tristate "STi GMAC support"
 	default ARCH_STI
 	depends on OF
+	depends on HAS_IOMEM	# For MFD_SYSCON
 	select MFD_SYSCON
 	---help---
 	  Support for ethernet controller on STi SOCs.
diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index e7f0b7d95b65..ec56cebe929d 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -62,6 +62,7 @@ config TI_CPSW_ALE
 config TI_CPSW
 	tristate "TI CPSW Switch Support"
 	depends on ARCH_DAVINCI || ARCH_OMAP2PLUS
+	depends on HAS_IOMEM	# For MFD_SYSCON
 	select TI_DAVINCI_CPDMA
 	select TI_DAVINCI_MDIO
 	select TI_CPSW_PHY_SEL
-- 
2.5.0
