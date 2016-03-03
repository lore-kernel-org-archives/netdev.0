From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC 15/15] mfd: syscon: Fix build of missing ioremap on UM
Date: Thu, 03 Mar 2016 17:03:41 +0900
Message-ID: <1456992221-26712-16-git-send-email-k.kozlowski__20383.5252010778$1456992406$gmane$org@samsung.com>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
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
Received: from mailout3.w1.samsung.com ([210.118.77.13]:55598 "EHLO
	mailout3.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932538AbcCCIGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 03:06:19 -0500
In-reply-to: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit c89c0114955a ("mfd: syscon: Set regmap max_register in
of_syscon_register") the syscon uses ioremap so it fails on COMPILE_TES=
T
without HAS_IOMEM:

drivers/mfd/syscon.c: In function =E2=80=98of_syscon_register=E2=80=99:
drivers/mfd/syscon.c:67:9: error: implicit declaration of function =E2=80=
=98ioremap=E2=80=99 [-Werror=3Dimplicit-function-declaration]
  base =3D ioremap(res.start, resource_size(&res));
         ^
drivers/mfd/syscon.c:67:7: warning: assignment makes pointer from integ=
er without a cast [-Wint-conversion]
  base =3D ioremap(res.start, resource_size(&res));
       ^
drivers/mfd/syscon.c:109:2: error: implicit declaration of function =E2=
=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-declaration]
  iounmap(base);

When selecting MFD_SYSCON, depend on HAS_IOMEM to avoid unmet direct
dependencies.

Reported-by: kbuild test robot <lkp@intel.com>
=46ixes: c89c0114955a ("mfd: syscon: Set regmap max_register in of_sysc=
on_register")
Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 drivers/mfd/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/mfd/Kconfig b/drivers/mfd/Kconfig
index aa21dc55eb15..2e5b1e525a1d 100644
--- a/drivers/mfd/Kconfig
+++ b/drivers/mfd/Kconfig
@@ -1034,6 +1034,7 @@ config MFD_SUN6I_PRCM
=20
 config MFD_SYSCON
 	bool "System Controller Register R/W Based on Regmap"
+	depends on HAS_IOMEM
 	select REGMAP_MMIO
 	help
 	  Select this option to enable accessing system control registers
--=20
2.5.0
