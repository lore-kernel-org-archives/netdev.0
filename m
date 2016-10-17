From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 00/15] ethernet: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:02 -0400
Message-ID: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the network stack core min/max MTU checking infrastructure is in
place, time to start making drivers use it. We'll start with the easiest
ones, the ethernet drivers, split roughly by vendor, with a catch-all
patch at the end.

For the most part, every patch does the same essential thing: removes the
MTU range checking from the drivers' ndo_change_mtu function, puts those
ranges into the core net_device min_mtu and max_mtu fields, and where
possible, removes ndo_change_mtu functions entirely.

These patches have all been built through the 0-day build infrastructure
provided by Intel, on top of net-next as of October 17.

Rebasing git tree with these patches can be found here:

  https://github.com/jarodwilson/linux-muck

Jarod Wilson (15):
  ethernet/atheros: use core min/max MTU checking
  ethernet/broadcom: use core min/max MTU checking
  ethernet/intel: use core min/max MTU checking
  ethernet/marvell: use core min/max MTU checking
  ethernet/mellanox: use core min/max MTU checking
  ethernet/qlogic: use core min/max MTU checking
  ethernet/realtek: use core min/max MTU checking
  ethernet/sun: use core min/max MTU checking
  ethernet/dlink: use core min/max MTU checking
  ethernet/neterion: use core min/max MTU checking
  ethernet/cavium: use core min/max MTU checking
  ethernet/ibm: use core min/max MTU checking
  ethernet/tile: use core min/max MTU checking
  ethernet/toshiba: use core min/max MTU checking
  ethernet: use core min/max MTU checking

CC: netdev@vger.kernel.org

 drivers/net/ethernet/agere/et131x.c                |  7 ++--
 drivers/net/ethernet/altera/altera_tse.h           |  1 -
 drivers/net/ethernet/altera/altera_tse_main.c      | 14 ++------
 drivers/net/ethernet/amd/amd8111e.c                |  5 ++-
 drivers/net/ethernet/atheros/alx/hw.h              |  1 -
 drivers/net/ethernet/atheros/alx/main.c            | 10 ++----
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    | 41 ++++++++++++++--------
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    | 12 +++----
 drivers/net/ethernet/atheros/atlx/atl1.c           | 15 ++++----
 drivers/net/ethernet/atheros/atlx/atl2.c           | 16 ++++-----
 drivers/net/ethernet/atheros/atlx/atl2.h           |  3 --
 drivers/net/ethernet/broadcom/b44.c                |  9 +++--
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       | 35 ++++++------------
 drivers/net/ethernet/broadcom/bnx2.c               | 16 ++++-----
 drivers/net/ethernet/broadcom/bnx2.h               |  6 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |  6 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  8 +----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   | 22 +++++-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  7 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  7 ++--
 drivers/net/ethernet/broadcom/tg3.c                |  9 ++---
 drivers/net/ethernet/brocade/bna/bnad.c            |  7 ++--
 drivers/net/ethernet/cadence/macb.c                | 19 +++++-----
 drivers/net/ethernet/calxeda/xgmac.c               | 20 +++--------
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 15 +++-----
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  2 +-
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c   | 13 ++-----
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 10 +++---
 drivers/net/ethernet/chelsio/cxgb/common.h         |  5 +++
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          | 18 ++++++++--
 drivers/net/ethernet/chelsio/cxgb/pm3393.c         |  8 +----
 drivers/net/ethernet/chelsio/cxgb/vsc7326.c        |  5 ---
 drivers/net/ethernet/cisco/enic/enic_main.c        |  7 ++--
 drivers/net/ethernet/cisco/enic/enic_res.h         |  2 +-
 drivers/net/ethernet/dlink/dl2k.c                  | 22 +++---------
 drivers/net/ethernet/dlink/sundance.c              |  6 ++--
 drivers/net/ethernet/freescale/gianfar.c           |  9 ++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |  3 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 11 +++---
 drivers/net/ethernet/ibm/ehea/ehea_main.c          | 13 +++----
 drivers/net/ethernet/ibm/emac/core.c               |  9 ++---
 drivers/net/ethernet/intel/e100.c                  |  9 -----
 drivers/net/ethernet/intel/e1000/e1000_main.c      | 12 +++----
 drivers/net/ethernet/intel/e1000e/netdev.c         | 14 ++++----
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c    | 15 +++-----
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 10 +++---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  8 ++---
 drivers/net/ethernet/intel/igb/e1000_defines.h     |  3 +-
 drivers/net/ethernet/intel/igb/igb_main.c          | 15 +++-----
 drivers/net/ethernet/intel/igbvf/defines.h         |  3 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          | 14 +++-----
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        | 16 +++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 11 +++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  | 33 ++++++++---------
 drivers/net/ethernet/marvell/mvneta.c              | 36 ++++++-------------
 drivers/net/ethernet/marvell/mvpp2.c               | 36 +++++--------------
 drivers/net/ethernet/marvell/pxa168_eth.c          |  7 ++--
 drivers/net/ethernet/marvell/skge.c                |  7 ++--
 drivers/net/ethernet/marvell/sky2.c                | 18 +++++-----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  8 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 24 ++++---------
 drivers/net/ethernet/micrel/ksz884x.c              | 33 ++++++++---------
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   | 20 ++++++-----
 drivers/net/ethernet/natsemi/natsemi.c             |  7 ++--
 drivers/net/ethernet/neterion/s2io.c               |  9 +++--
 drivers/net/ethernet/neterion/vxge/vxge-config.h   |  2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |  9 +++--
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 10 +++---
 drivers/net/ethernet/nvidia/forcedeth.c            |  9 +++--
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 13 ++++---
 drivers/net/ethernet/pasemi/pasemi_mac.c           | 12 ++++---
 drivers/net/ethernet/qlogic/qede/qede.h            |  5 +--
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c    |  8 -----
 drivers/net/ethernet/qlogic/qede/qede_main.c       |  4 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  6 ----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  4 +++
 drivers/net/ethernet/qualcomm/qca_framing.h        |  6 ++--
 drivers/net/ethernet/qualcomm/qca_spi.c            | 16 +++------
 drivers/net/ethernet/realtek/8139cp.c              |  8 ++---
 drivers/net/ethernet/realtek/8139too.c             | 13 +++----
 drivers/net/ethernet/realtek/r8169.c               |  8 ++---
 drivers/net/ethernet/rocker/rocker_main.c          | 12 +++----
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    | 17 +++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 25 +++++--------
 drivers/net/ethernet/sun/cassini.c                 |  7 ++--
 drivers/net/ethernet/sun/ldmvsw.c                  |  5 ++-
 drivers/net/ethernet/sun/niu.c                     |  7 ++--
 drivers/net/ethernet/sun/sungem.c                  | 11 +++---
 drivers/net/ethernet/sun/sunvnet.c                 |  5 ++-
 drivers/net/ethernet/sun/sunvnet_common.c          | 10 ------
 drivers/net/ethernet/sun/sunvnet_common.h          |  3 +-
 drivers/net/ethernet/tehuti/tehuti.c               | 14 +++-----
 drivers/net/ethernet/tehuti/tehuti.h               |  3 ++
 drivers/net/ethernet/ti/netcp_core.c               | 20 +++--------
 drivers/net/ethernet/tile/tilegx.c                 | 21 +++++------
 drivers/net/ethernet/tile/tilepro.c                | 27 +++-----------
 drivers/net/ethernet/toshiba/ps3_gelic_net.c       | 23 +++---------
 drivers/net/ethernet/toshiba/ps3_gelic_net.h       |  1 -
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c  |  1 -
 drivers/net/ethernet/toshiba/spider_net.c          | 24 +++----------
 drivers/net/ethernet/via/via-velocity.c            | 11 +++---
 drivers/staging/octeon/ethernet.c                  | 22 ++++++------
 102 files changed, 480 insertions(+), 744 deletions(-)

-- 
2.10.0
