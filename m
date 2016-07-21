From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v6 00/12] drivers: net: xgene: Fix module crash and 1G hot-plug
Date: Wed, 20 Jul 2016 23:59:18 -0700
Message-ID: <1469084370-16781-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34057 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbcGUG7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 02:59:06 -0400
Received: by mail-pa0-f47.google.com with SMTP id fi15so26196588pac.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 23:59:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset addresses the following issues,

1. Fixes the kernel crash when the driver loaded as an kernel module
	- by fixing hardware cleanups and rearrange kernel API calls

2. Hot-plug issue on the SGMII 1G interface
	- by adding a driver for MDIO management

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
v6: Address review comments from v5
	- changed to use devm_ioremap_resource
	- changed to return PTR_ERR(clk) on failure
	- cleaned up and removed indirections
	- exported mdio read/write and phy_register functions
	- changed mii_bus is to indicate interface instance
	- changed to call the exported mdio read/write and phy_register functions

v5: Address review comments from v4
	- Fixed clock reset sequence by adding delay
	- Fixed clock count by adding clk_unprepare_disable() in port shutdown

v4: Address review comments from v3
	- Reorganized into smaller patches
	- Added wrapper functions for sgmii_control_reset and sgmii_tbi_control_reset
	- Removed clk_get warning info
	- mdio: Changed the order of 'if' statements and removed the 'else' statement
	- mdio: Removed the mdio_read(write) indirection wrapper functions
	- ethtool: Fixed SGMII 1G get_settings and set_settings
	- Documentation: dtb: Added MDIO node information
	- MAINTAINERS: Added MDIO driver and documentation path

v3: Address review comments from v2
	- Add comment about hardware clock reset sequence on xgene_mdio_reset

v2: Address review comments from v1
	- Fixed patch 1 compilation error
	- Fixed mdio@1f610000 xge0clk reference
	- Squashed dtb patches
	- Added PORT_OFFSET macro

v1:
	- Initial version
---

Iyappan Subramanian (12):
  drivers: net: xgene: Separate set_speed from mac_init
  drivers: net: xgene: Fix module unload crash - hw resource cleanup
  drivers: net: xgene: Fix module unload crash - change sw sequence
  drivers: net: xgene: Fix module unload crash - clkrst sequence
  drivers: net: phy: xgene: Add MDIO driver
  drivers: net: xgene: Add backward compatibility
  drivers: net: xgene: Enable MDIO driver
  drivers: net: xgene: Use exported functions
  drivers: net: xgene: ethtool: Use phy_ethtool_gset and sset
  dtb: xgene: Add MDIO node
  Documentation: dtb: xgene: Add MDIO node
  MAINTAINERS: xgene: Add driver and documentation path

 .../devicetree/bindings/net/apm-xgene-mdio.txt     |  37 ++
 MAINTAINERS                                        |   2 +
 arch/arm64/boot/dts/apm/apm-merlin.dts             |   6 +
 arch/arm64/boot/dts/apm/apm-mustang.dts            |  12 +
 arch/arm64/boot/dts/apm/apm-shadowcat.dtsi         |  11 +-
 arch/arm64/boot/dts/apm/apm-storm.dtsi             |  26 +-
 drivers/net/ethernet/apm/xgene/Kconfig             |   1 +
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    |  22 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     | 255 ++++++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |  11 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 215 ++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  33 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c  | 239 +++++++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h  |   8 +
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c  |  66 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h  |   3 +
 drivers/net/phy/Kconfig                            |   5 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/mdio-xgene.c                       | 477 +++++++++++++++++++++
 drivers/net/phy/mdio-xgene.h                       | 143 ++++++
 20 files changed, 1290 insertions(+), 283 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-mdio.txt
 create mode 100644 drivers/net/phy/mdio-xgene.c
 create mode 100644 drivers/net/phy/mdio-xgene.h

-- 
1.9.1
