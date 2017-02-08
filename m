From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 00/16] net: stmmac: misc fix
Date: Wed,  8 Feb 2017 09:31:05 +0100
Message-ID: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

I am currently working on dwmac-sun8i glue driver for Allwinner H3/A83T/A64.
This serie is the result of all minor problem found in the stmmac driver.

All patch are tested on cubieboard2 via dwmac-sunxi and on pine64/orangepis via dwmac-sun8i.

Regards

Changes since v1:
- Removed netdev_dbg() in "net: stmmac: print phy information"
- Removed patch "net: stmmac: Implement NAPI for TX", it will be reworked
- Changed error message in "Correct the error message about invalid speed"
- Added some acked-by

Corentin Labbe (16):
  net: stmmac: fix the typo on MAC_RNABLE_RX
  net: stmmac: Remove the bus_setup function pointer
  net: stmmac: fix some typos in comments
  net: stmmac: remove freesoftware address
  net: stmmac: remplace asm/io.h by linux/io.h
  net: stmmac: fix some code style problem
  net: stmmac: replace stmmac_mdio_busy_wait by readl_poll_timeout
  net: stmmac: Use readl_poll_timeout
  net: stmmac: replace ENOSYS by EINVAL
  net: stmmac: Correct the error message about invalid speed
  net: stmmac: Rewrite two test against NULL value
  net: stmmac: rename rx_crc to rx_crc_errors
  net: stmmac: print phy information
  net: stmmac: remove dead code in stmmac_tx_clean
  net: stmmac: remove unused variable in sysfs_display_ring
  net: stmmac: replace unsigned by u32

 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |  4 --
 drivers/net/ethernet/stmicro/stmmac/common.h       |  8 +---
 drivers/net/ethernet/stmicro/stmmac/descs.h        |  4 --
 drivers/net/ethernet/stmicro/stmmac/descs_com.h    |  4 --
 drivers/net/ethernet/stmicro/stmmac/dwmac100.h     |  4 --
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |  4 --
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  4 --
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |  4 --
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |  4 --
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |  4 --
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c |  2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |  4 --
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    | 28 +++++-------
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |  6 +--
 drivers/net/ethernet/stmicro/stmmac/mmc.h          |  4 --
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c     |  4 --
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |  6 +--
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |  4 --
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  4 --
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |  6 +--
 .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  |  4 --
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 49 ++++++--------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 52 ++++++++--------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  4 --
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  6 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |  4 --
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h   |  4 --
 include/linux/stmmac.h                             |  1 -
 28 files changed, 51 insertions(+), 185 deletions(-)

-- 
2.10.2
