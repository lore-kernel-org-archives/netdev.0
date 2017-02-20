From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH RFC] net: stmmac: unify registers dumps methods
Date: Mon, 20 Feb 2017 14:44:34 +0100
Message-ID: <20170220134435.12837-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hello

The following patch address the problem that two way of dumping registers are
available in stmmac, via ethtool and directly at init (if NETIF_MSG_HW is enabled).
It is better to keep only one method, ethtool, since the other was ugly (logs of pr_xxx).

But by working on this issue, I saw two problem:
- "ethtool" for gmac/gmac4 always dump the 55 first registers, while dwmac4_dump_regs dump the first 132 registers, so clearly the current stmmac_ethtool_gregs miss some registers
- stmmac_ethtool_gregs claim to dump whole address space (len=REG_SPACE_SIZE), but in fact concat two distant address space.

The current patch address all by being bijective between reg_space and address space, so all DMA registers goes to their "real" address in reg_space.
But this fix break the pretty print of registers name of ethtool. (ethtool -d eth0 hex on still works).

What do you think about this issue ?

Corentin Labbe (1):
  net: stmmac: unify registers dumps methods

 drivers/net/ethernet/stmicro/stmmac/common.h       |  4 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   | 10 +--
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    | 16 ++---
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    | 30 +++------
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c | 15 ++---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 12 +---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   | 78 +++++++++++-----------
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   | 21 +-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  5 --
 9 files changed, 71 insertions(+), 120 deletions(-)

-- 
2.10.2
