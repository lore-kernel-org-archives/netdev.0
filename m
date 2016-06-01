From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 0/5] drivers: net: xgene: Fix 1G hot-plug and module support
Date: Tue, 31 May 2016 17:10:35 -0700
Message-ID: <1464739840-21971-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	matthias.bgg@gmail.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36731 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbcFAALC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 20:11:02 -0400
Received: by mail-pf0-f170.google.com with SMTP id f144so2448345pfa.3
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 17:11:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset addresses the following issues,

1. hot-plug issue on the SGMII 1G interface
	- by adding a driver for MDIO management
2. fixes the kernel crash when the driver loaded as an kernel module
	- by fixing hardware cleanups and rearrange kernel API calls

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Matthias Brugger <mbrugger@suse.com>
---

v2: Address review comments from v1
	- Fixed patch 1 compilation error
	- Fixed mdio@1f610000 xge0clk reference
	- Squashed dtb patches
	- Added PORT_OFFSET macro

v1:
	- Initial version
---

Iyappan Subramanian (5):
  drivers: net: xgene: MAC and PHY configuration changes
  drivers: net: xgene: Backward compatibility with older firmware
  drivers: net: phy: Add MDIO driver
  dtb: xgene: Add MDIO node
  drivers: net: xgene: Fix module load/unload crash

 arch/arm64/boot/dts/apm/apm-merlin.dts            |   9 +
 arch/arm64/boot/dts/apm/apm-mustang.dts           |  12 +
 arch/arm64/boot/dts/apm/apm-shadowcat.dtsi        |  11 +
 arch/arm64/boot/dts/apm/apm-storm.dtsi            |  38 +-
 drivers/net/ethernet/apm/xgene/Kconfig            |   1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 241 ++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  19 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 325 ++++++++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  36 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 191 +++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h |   8 +
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |  66 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h |   4 +
 drivers/net/phy/Kconfig                           |   7 +
 drivers/net/phy/Makefile                          |   1 +
 drivers/net/phy/mdio-xgene.c                      | 531 ++++++++++++++++++++++
 drivers/net/phy/mdio-xgene.h                      | 140 ++++++
 17 files changed, 1373 insertions(+), 267 deletions(-)
 create mode 100644 drivers/net/phy/mdio-xgene.c
 create mode 100644 drivers/net/phy/mdio-xgene.h

-- 
1.9.1
