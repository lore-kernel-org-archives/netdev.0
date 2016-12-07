From: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
Subject: [PATCH v3 0/6] net: stmmac: make DMA programmable burst length more configurable
Date: Wed, 7 Dec 2016 15:20:02 +0100
Message-ID: <1481120409-18103-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass-VrBV9hrLPhE@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Changes since V2:
Moved default value initialization of pbl to stmmac_platform.c
and added a check for pbl != 0 in stmmac_main.c,
to catch a possble pbl == 0 from pci glue.


Niklas Cassel (6):
  net: stmmac: return error if no DMA configuration is found
  net: stmmac: simplify the common DMA init API
  net: stmmac: stmmac_platform: fix parsing of DT binding
  net: stmmac: dwmac1000: fix define DMA_BUS_MODE_RPBL_MASK
  net: stmmac: add support for independent DMA pbl for tx/rx
  net: smmac: allow configuring lower pbl values

 Documentation/devicetree/bindings/net/stmmac.txt   |  8 +++++-
 Documentation/networking/stmmac.txt                | 24 +++++++++++-----
 drivers/net/ethernet/stmicro/stmmac/common.h       |  4 +--
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |  2 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    | 26 ++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |  7 +++--
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   | 25 ++++++++++-------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 14 ++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  2 ++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 32 ++++++++++++----------
 include/linux/stmmac.h                             |  3 ++
 11 files changed, 88 insertions(+), 59 deletions(-)

-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
