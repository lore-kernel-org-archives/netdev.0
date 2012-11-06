From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 0/7] ARM: AM33XX: net: Add DT support to CPGMAC and MDIO driver
Date: Tue, 6 Nov 2012 13:42:18 +0530
Message-ID: <1352189545-26303-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch-series adds support for,

[1/7]: Typo mistake in CPSW driver while invoking runtime_pm api's

[2/7]: Adds parent<->child relation between CPSW & MDIO module inside cpsw
       driver, as in case of AM33XX, the resources are shared and common
       register bit-field is provided to control module/clock enable/disable,
       makes it difficult to handle common resource.

       So the solution here is, to create parent<->child relation between them.

[3/7]: Add hwmod entry for MDIO module, required for MDIO driver.

[4/7]: cpsw: simplify the setup of the register pointers

[5/7]: Add DT device nodes for both CPSW and MDIO modules in am33xx.dtsi,
       am335x-evm.dts and am335x-bone.dts file

[6/7]: Enable CPSW support to omap2plus_defconfig

[7/7]: cpsw: Kernel warn fix during suspend

This patch series has been created on top of net-next/master and tested
on BeagleBone platform for NFS boot and basic ping test cases.

Mugunthan V N (4):
  ARM: OMAP3+: hwmod: Add AM33XX HWMOD data for davinci_mdio module
  arm/dts: am33xx: Add CPSW and MDIO module nodes for AM33XX
  ARM: OMAP2+: omap2plus_defconfig: Enable CPSW support
  net: cpsw: halt network stack before halting the device during
    suspend

Richard Cochran (1):
  cpsw: simplify the setup of the register pointers

Vaibhav Hiremath (2):
  net: davinci_mdio: Fix typo mistake in calling runtime-pm api
  net: cpsw: Add parent<->child relation support between cpsw and mdio

 Documentation/devicetree/bindings/net/cpsw.txt |   34 ----
 arch/arm/boot/dts/am335x-bone.dts              |    8 +
 arch/arm/boot/dts/am335x-evm.dts               |    8 +
 arch/arm/boot/dts/am33xx.dtsi                  |   42 +++++
 arch/arm/configs/omap2plus_defconfig           |    3 +
 arch/arm/mach-omap2/omap_hwmod_33xx_data.c     |   32 ++++
 drivers/net/ethernet/ti/cpsw.c                 |  231 ++++++++++--------------
 drivers/net/ethernet/ti/davinci_mdio.c         |    2 +-
 include/linux/platform_data/cpsw.h             |   19 --
 9 files changed, 193 insertions(+), 186 deletions(-)

