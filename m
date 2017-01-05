From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v4 0/3] adding new glue driver dwmac-dwc-qos-eth
Date: Thu, 5 Jan 2017 14:43:38 +0000
Message-ID: <cover.1483626480.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <lars.persson@axis.com>, <niklass@axis.com>, <swarren@nvidia.com>,
        <treding@nvidia.com>, <netdev@vger.kernel.org>,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:49256 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759105AbdAEOyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 09:54:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set contains the porting of the synopsys/dwc_eth_qos.c driver
to the stmmac structure. This operation resulted in the creation of a new
platform glue driver called dwmac-dwc-qos-eth which was based in the
dwc_eth_qos as is.

dwmac-dwc-qos-eth inherited dwc_eth_qos DT bindings, to assure that current
and old users can continue to use it as before. We can see this driver as
being deprecated, since all new development will be done in stmmac.

Please check each patch for implementation details.

Joao Pinto (3):
  stmmac: adding DT parameter for LPI tx clock gating
  stmmac: move stmmac_clk, pclk, clk_ptp_ref and stmmac_rst to platform
    structure
  stmmac: adding new glue driver dwmac-dwc-qos-eth

 .../bindings/net/snps,dwc-qos-ethernet.txt         |   3 +
 Documentation/devicetree/bindings/net/stmmac.txt   |   2 +
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   9 +
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
 drivers/net/ethernet/stmicro/stmmac/common.h       |   3 +-
 .../ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c    | 202 +++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |   2 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   5 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  |   6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   5 -
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   4 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  85 ++-------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  65 ++++++-
 include/linux/stmmac.h                             |   6 +
 15 files changed, 317 insertions(+), 82 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c

-- 
2.9.3
