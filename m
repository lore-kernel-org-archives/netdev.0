From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: Re: [rtc-linux] Re: [RFC 04/15] irqchip: st: Add missing MFD_SYSCON
 dependency on HAS_IOMEM
Date: Thu, 3 Mar 2016 21:00:57 +0900
Message-ID: <CAJKOXPcZuyicNAaH6CpOe+bTrLtM1k0tVisS_xJXGDrxyZ_i5A@mail.gmail.com>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
	<1456992221-26712-5-git-send-email-k.kozlowski@samsung.com>
	<2506651.J2Z42d81nD@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-arm-kernel@lists.infradead.org,
	Daniel Lezcano <daniel.lezcano@linaro.org>,
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
	Greg Kroah-Hartman <gregkh@linuxfoundation.org
To: rtc-linux@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34001 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754349AbcCCMA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 07:00:58 -0500
In-Reply-To: <2506651.J2Z42d81nD@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-03-03 19:53 GMT+09:00 Arnd Bergmann <arnd@arndb.de>:
> On Thursday 03 March 2016 17:03:30 Krzysztof Kozlowski wrote:
>>  config ST_IRQCHIP
>>         bool
>>         select REGMAP
>> +       depends on HAS_IOMEM    # For MFD_SYSCON
>>         select MFD_SYSCON
>>         help
>>           Enables SysCfg Controlled IRQs on STi based platforms.
>>
>
> Not user visible.

Hmmm... you are right (here and in other patches) but why am I getting
all these errors:
warning: (ST_IRQCHIP && HIP04_ETH && STMMAC_PLATFORM && DWMAC_IPQ806X
&& DWMAC_LPC18XX && DWMAC_ROCKCHIP && DWMAC_SOCFPGA && DWMAC_STI &&
TI_CPSW && PINCTRL_ROCKCHIP && PINCTRL_DOVE && POWER_RESET_KEYSTONE &&
S3C2410_WATCHDOG && VIDEO_OMAP3 && VIDEO_S5P_FIMC && USB_XHCI_MTK &&
RTC_DRV_AT91SAM9 && LPC18XX_DMAMUX && VIDEO_OMAP4 && HWSPINLOCK_QCOM
&& ATMEL_ST && QCOM_GSBI && PHY_HI6220_USB) selects MFD_SYSCON which
has unmet direct dependencies (HAS_IOMEM)
?
(ARCH=um, allyesconfig)
Adding depends here (and in other places) really helps... but it
should not have any impact...

Thanks for comments,
Krzysztof
