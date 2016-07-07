From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v5 00/11] drivers: net: xgene: Fix module crash and 1G hot-plug
Date: Thu,  7 Jul 2016 16:02:48 -0700
Message-ID: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	matthias.bgg@gmail.com, andrew@lunn.ch, linux@armlinux.org.uk,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36329 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbcGGXCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 19:02:54 -0400
Received: by mail-pf0-f172.google.com with SMTP id t190so9970735pfb.3
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 16:02:54 -0700 (PDT)
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

Iyappan Subramanian (11):
  drivers: net: xgene: Separate set_speed from mac_init
  drivers: net: xgene: Fix module unload crash - hw resource cleanup
  drivers: net: xgene: Fix module unload crash - change sw sequence
  drivers: net: xgene: Fix module unload crash - clkrst sequence
  drivers: net: phy: xgene: Add MDIO driver
  drivers: net: xgene: Add backward compatibility
  drivers: net: xgene: Enable MDIO driver
  drivers: net: xgene: ethtool: Use phy_ethtool_gset and sset
  dtb: xgene: Add MDIO node
  Documentation: dtb: xgene: Add MDIO node
  MAINTAINERS: xgene: Add driver and documentation path

 .../devicetree/bindings/net/apm-xgene-mdio.txt     |  37 ++
 MAINTAINERS                                        |   2 +
 arch/arm64/boot/dts/apm/apm-mustang.dts            |  12 +
 arch/arm64/boot/dts/apm/apm-storm.dtsi             |  36 +-
 drivers/net/ethernet/apm/xgene/Kconfig             |   1 +
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    |  22 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     | 159 +++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |  11 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 220 ++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  33 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c  | 237 ++++++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h  |   8 +
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c  |  66 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h  |   3 +
 drivers/net/phy/Kconfig                            |   6 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/mdio-xgene.c                       | 487 +++++++++++++++++++++
 drivers/net/phy/mdio-xgene.h                       | 140 ++++++
 18 files changed, 1278 insertions(+), 203 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-mdio.txt
 create mode 100644 drivers/net/phy/mdio-xgene.c
 create mode 100644 drivers/net/phy/mdio-xgene.h

-- 
1.9.1
