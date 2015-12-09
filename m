From: Phil Reid <preid@electromag.com.au>
Subject: [PATCH v5 0/4] stmmac: Fixed Phy & PTP fixes
Date: Wed,  9 Dec 2015 16:39:37 +0800
Message-ID: <1449650381-82074-1-git-send-email-preid@electromag.com.au>
Cc: Phil Reid <preid@electromag.com.au>
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, davem@davemloft.net,
	vbridger@opensource.altera.com, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 203-59-230-133.perm.iinet.net.au ([203.59.230.133]:49244 "EHLO
	preid-centos7.electromag.com.au" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753423AbbLJBdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 20:33:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide ability to specify a fixed phy in the device tree and
retain the mdio bus if no phy is found. This is needed where 
a dsa is connected via a fixed phy and uses the mdio bus for config.
Fixed ptp ref clock calculatins for the stmmac when ptp ref clock
is running at <= 50Mhz. Also add device tree setting to config
ptp clk source on socfpga platforms.

Change from V4:
- Restore #ifdef CONFIG_OF around setting of reset_gpio.
  Member doesn't exist when this isn't defined.

Changes from V3:
- Use if (IS_ENABLED(CONFIG_OF)) instead of #if.
  Reorder some code to reduce if statements.
- of_mdiobus_register already falls back to mdiobus_register
- Tested on system with CONFIG_OF

Changes from V2:
- Formatting, spaces & lines > 80 chars. Using checkpatch
- Drop PTP register debugfs patch.

Changes from V1:
- Fixed mismatch doc / code for ptp_ref_clk dt node. 
- Remove unit address from doc example.

Phil Reid (5):
  stmmac: create of compatible mdio bus for stmacc driver
  stmmac: Correct documentation on stmmac clocks.
  stmmac: Fix calculations for ptp counters when clock input = 50Mhz.
  stmmac: socfpga: Provide dt node to config ptp clk source.

 .../devicetree/bindings/net/socfpga-dwmac.txt      |  2 ++
 Documentation/devicetree/bindings/net/stmmac.txt   | 25 ++++++++++-------
 drivers/net/ethernet/stmicro/stmmac/common.h       |  2 +-
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |  9 +++++++
 .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  |  9 ++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 19 ++++++-------
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 31 +++++++++++++++-------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  2 +-
 8 files changed, 65 insertions(+), 34 deletions(-)

-- 
1.8.3.1
