From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH v2 0/6] net: stmmac: make DMA programmable burst length more configurable
Date: Mon, 5 Dec 2016 10:10:32 +0100
Message-ID: <1480929039-20257-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <devicetree@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-doc@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

Make DMA programmable burst length more configurable in the stmmac driver.

This is done by adding support for independent pbl for tx/rx through DT.
More fine grained tuning of pbl is possible thanks to a DT property saying
that we should NOT multiply pbl values by x8/x4 in hardware.

All new DT properties are optional, and created in a way that it will not
affect any existing DT configurations.

Changes since V1:
Created cover-letter.
Rebased patch set against next-20161205, since conflicting patches to
stmmac_platform.c has been merged since V1.


Niklas Cassel (6):
  net: stmmac: return error if no DMA configuration is found
  net: stmmac: simplify the common DMA init API
  net: stmmac: stmmac_platform: fix parsing of DT binding
  net: stmmac: dwmac1000: fix define DMA_BUS_MODE_RPBL_MASK
  net: stmmac: add support for independent DMA pbl for tx/rx
  net: smmac: allow configuring lower pbl values

 Documentation/devicetree/bindings/net/stmmac.txt   |  8 +++++-
 Documentation/networking/stmmac.txt                | 24 ++++++++++++-----
 drivers/net/ethernet/stmicro/stmmac/common.h       |  4 +--
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |  2 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    | 26 ++++++++++---------
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |  7 ++---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   | 25 ++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 17 ++++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  2 ++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 30 ++++++++++++----------
 include/linux/stmmac.h                             |  3 +++
 11 files changed, 89 insertions(+), 59 deletions(-)

-- 
2.1.4
