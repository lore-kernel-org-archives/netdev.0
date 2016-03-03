From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC 00/15] tree-wide: mfd: syscon: Fix unmet ioremap dependency
Date: Thu, 03 Mar 2016 17:03:26 +0900
Message-ID: <1456992221-26712-1-git-send-email-k.kozlowski__35244.4820492112$1456993018$gmane$org@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
Received: from mailout3.w1.samsung.com ([210.118.77.13]:55416 "EHLO
	mailout3.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbcCCIEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 03:04:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Building allyesconfig on ARCH=3Dum fails with:
   drivers/mfd/syscon.c: In function =E2=80=98of_syscon_register=E2=80=99=
:
   drivers/mfd/syscon.c:67:9: error: implicit declaration of function =E2=
=80=98ioremap=E2=80=99 [-Werror=3Dimplicit-function-declaration]
      base =3D ioremap(res.start, resource_size(&res));

Since commit c89c0114955a ("mfd: syscon: Set regmap max_register in
of_syscon_register") the syscon depends on HAS_IOMEM because
it uses the ioremap().

However syscon is often directly selected... so first the dependency on
HAS_IOMEM has to be added to all selecting symbols.

Comments are welcomed whether this is appropriate approach.


The last patch "mfd: syscon: Fix build of missing ioremap on UM" should
enter all other to avoid kbuild complains like:

warning: (ST_IRQCHIP && HIP04_ETH && STMMAC_PLATFORM && DWMAC_IPQ806X &=
&
DWMAC_LPC18XX && DWMAC_ROCKCHIP && DWMAC_SOCFPGA && DWMAC_STI && TI_CPS=
W
&& PINCTRL_ROCKCHIP && PINCTRL_DOVE && POWER_RESET_KEYSTONE &&
S3C2410_WATCHDOG && VIDEO_OMAP3 && VIDEO_S5P_FIMC && USB_XHCI_MTK &&
RTC_DRV_AT91SAM9 && LPC18XX_DMAMUX && VIDEO_OMAP4 && HWSPINLOCK_QCOM &&=
 ATMEL_ST
&& QCOM_GSBI && PHY_HI6220_USB)
selects MFD_SYSCON which has unmet direct dependencies (HAS_IOMEM)


Best regards,
Krzysztof


Krzysztof Kozlowski (15):
  clocksource: atmel: Add missing MFD_SYSCON dependency on HAS_IOMEM
  dmaengine: nxp: Add missing MFD_SYSCON dependency on HAS_IOMEM
  hwspinlock: qcom: Add missing MFD_SYSCON dependency on HAS_IOMEM
  irqchip: st: Add missing MFD_SYSCON dependency on HAS_IOMEM
  phy: hi6220: Add missing MFD_SYSCON dependency on HAS_IOMEM
  pinctrl: rockchip: Add missing MFD_SYSCON dependency on HAS_IOMEM
  pinctrl: mvebu: Add missing MFD_SYSCON dependency on HAS_IOMEM
  rtc: at91sam9: Add missing MFD_SYSCON dependency on HAS_IOMEM
  media: platform: Add missing MFD_SYSCON dependency on HAS_IOMEM
  net: ethernet: Add missing MFD_SYSCON dependency on HAS_IOMEM
  power: reset: keystone: Add missing MFD_SYSCON dependency on HAS_IOME=
M
  soc: qcom: Add missing MFD_SYSCON dependency on HAS_IOMEM
  staging: media: omap4iss: Add missing MFD_SYSCON dependency on
    HAS_IOMEM
  usb: xhci: mtk: Add missing MFD_SYSCON dependency on HAS_IOMEM
  mfd: syscon: Fix build of missing ioremap on UM

 drivers/clocksource/Kconfig                 | 1 +
 drivers/dma/Kconfig                         | 1 +
 drivers/hwspinlock/Kconfig                  | 1 +
 drivers/irqchip/Kconfig                     | 1 +
 drivers/media/platform/Kconfig              | 1 +
 drivers/media/platform/exynos4-is/Kconfig   | 1 +
 drivers/mfd/Kconfig                         | 1 +
 drivers/net/ethernet/hisilicon/Kconfig      | 1 +
 drivers/net/ethernet/stmicro/stmmac/Kconfig | 6 ++++++
 drivers/net/ethernet/ti/Kconfig             | 1 +
 drivers/phy/Kconfig                         | 1 +
 drivers/pinctrl/Kconfig                     | 1 +
 drivers/pinctrl/mvebu/Kconfig               | 1 +
 drivers/power/reset/Kconfig                 | 1 +
 drivers/rtc/Kconfig                         | 1 +
 drivers/soc/qcom/Kconfig                    | 1 +
 drivers/staging/media/omap4iss/Kconfig      | 1 +
 drivers/usb/host/Kconfig                    | 1 +
 18 files changed, 23 insertions(+)

--=20
2.5.0
