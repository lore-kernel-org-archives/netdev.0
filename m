From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [v6, 0/5] Fix eSDHC host version register bug
Date: Wed, 9 Mar 2016 18:08:46 +0800
Message-ID: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt@kernel.org>, <scott.wood@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Jochen Friedrich <jochen@scram.de>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	<ulf.hansson@linaro.org>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	"Zhao Qiang" <qiang.zhao@freescale.com>,
	Kumar Gala <galak@codeaurora.org>,
	"Santosh Shilimkar" <ssantosh@kernel.org>, <leoyang.li@nxp.com>,
	<xiaobo.xie@nxp.com>, Yangbo Lu <yangbo.lu@nxp.com>
To: <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-clk@vger.kernel.org>, <linux-i2c@vger.kernel.org>,
	<iommu@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	<linux-mmc@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset is used to fix a host version register bug in the T4240-R1.0-R2.0
eSDHC controller. To get the SoC version and revision, it's needed to add the
GUTS driver to access the global utilities registers.

So, the first three patches are to add the GUTS driver.
The following two patches are to enable GUTS driver support to get SVR in eSDHC
driver and fix host version for T4240.

Yangbo Lu (5):
  ARM64: dts: ls2080a: add device configuration node
  soc: fsl: add GUTS driver for QorIQ platforms
  dt: move guts devicetree doc out of powerpc directory
  powerpc/fsl: move mpc85xx.h to include/linux/fsl
  mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0

 .../bindings/{powerpc => soc}/fsl/guts.txt         |   3 +
 arch/arm64/boot/dts/freescale/fsl-ls2080a.dtsi     |   6 ++
 drivers/clk/clk-qoriq.c                            |   3 +-
 drivers/i2c/busses/i2c-mpc.c                       |   2 +-
 drivers/iommu/fsl_pamu.c                           |   3 +-
 drivers/mmc/host/Kconfig                           |   1 +
 drivers/mmc/host/sdhci-of-esdhc.c                  |  23 ++++
 drivers/net/ethernet/freescale/gianfar.c           |   2 +-
 drivers/soc/Kconfig                                |   2 +-
 drivers/soc/fsl/Kconfig                            |   8 ++
 drivers/soc/fsl/Makefile                           |   1 +
 drivers/soc/fsl/guts.c                             | 119 +++++++++++++++++++++
 include/linux/fsl/guts.h                           | 100 ++++++++---------
 .../asm/mpc85xx.h => include/linux/fsl/svr.h       |   4 +-
 14 files changed, 220 insertions(+), 57 deletions(-)
 rename Documentation/devicetree/bindings/{powerpc => soc}/fsl/guts.txt (91%)
 create mode 100644 drivers/soc/fsl/Kconfig
 create mode 100644 drivers/soc/fsl/guts.c
 rename arch/powerpc/include/asm/mpc85xx.h => include/linux/fsl/svr.h (97%)

-- 
2.1.0.27.g96db324
