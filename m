From: Alexandre TORGUE <alexandre.torgue@gmail.com>
Subject: [PATCH v6 0/6] Add Ethernet support on STM32F429
Date: Mon, 25 Apr 2016 13:53:56 +0200
Message-ID: <1461585242-32401-1-git-send-email-alexandre.torgue@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	robh@kernel.org, manabian@gmail.com, wens@csie.org
To: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
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
