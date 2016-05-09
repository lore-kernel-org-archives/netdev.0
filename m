From: Alexandre TORGUE <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RESEND PATCH v6 0/6]  Add Ethernet support on STM32F429
Date: Mon,  9 May 2016 12:31:33 +0200
Message-ID: <1462789899-13153-1-git-send-email-alexandre.torgue@gmail.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org
To: Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
This series:
 -enhance current stmmac driver to control it (code already
available) and adds basic glue for STM32F429 chip.
 -Enable basic Net config in kernel.

Changes since v5:
 -Fix typo in bindings documentation patch.
 -Change clocks names in stm32-dwmac glue driver / Documentation.
 -After rebase, stm32 ethernet node is now available. It has to be updated
according to new clocks names.

Changes since v4:
 -Fix dirty copy/past in bindings documentation patch.

Changes since v3:
 -Fix "tx-clk" and "rx-clk" as required clocks. Driver and bindings are
modified.

Changes since v2:
 -Fix alphabetic order in Kconfig and Makefile.
 -Improve code according to Joachim review.
 -Binding: remove useless entry.

Changes since v1:
 -Fix Kbuild issue in Kconfig.
 -Remove init/exit callbacks. Suspend/Resume and remove driver is no more
driven in stmmac_pltfr but directly in dwmac-stm32 glue driver.
 -Take into account Joachim review.

Regards.

Alexandre.

Alexandre TORGUE (6):
  net: ethernet: dwmac: add Ethernet glue logic for stm32 chip
  Documentation: Bindings: Add STM32 DWMAC glue
  net: ethernet: stmmac: add support of Synopsys 3.50a MAC IP
  ARM: STM32: Enable Ethernet in stm32_defconfig
  ARM: dts: stm32f429: Align Ethernet node with new bindings properties
  ARM: dts: stm32f429: Update Ethernet node on Eval board

 .../devicetree/bindings/net/stm32-dwmac.txt        |  32 ++++
 arch/arm/boot/dts/stm32429i-eval.dts               |   4 +-
 arch/arm/boot/dts/stm32f429.dtsi                   |   6 +-
 arch/arm/configs/stm32_defconfig                   |   9 +
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |  12 ++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c  | 193 +++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   1 +
 8 files changed, 253 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/stm32-dwmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
