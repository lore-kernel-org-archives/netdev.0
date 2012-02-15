From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 15 Feb 2012 16:29:55 -0500 (EST)
Message-ID: <20120215.162955.1766444494566592539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) VETH_INFO_PEER netlink attribute needs to have it's size validated,
   from Thomas Graf.

2) 'poll' module option of bnx2x driver crashes the machine, just remove
   it.  From Michal Schmidt.

3) ks8851_mll driver reads the irq number from two places, but only
   initializes one of them, oops.  Use only one location and fix
   this problem, from Jan Weitzel.

4) Fix buffer overrun and unicast sterring bugs in mellanox
   mlx4 driver, from Eugenia Emantayev.

5) Swapped kcalloc() args in RxRPC and mlx4, from Axel Lin.

6) PHY MDIO device name regression fixes from Florian Fainelli.

7) If the wake event IRQ line is different from the netdevice one,
   we have to properly route it to the stmmac interrupt handler.
   From Francesco Virlinzi.

8) Fix rwlock lock initialization ordering bug in mac80211, from
   Mohammed Shafi Shajakhan.

9) TCP lost_cnt can get out of sync, and in fact go negative, in
   certain circumstances.  Fix the way we specify what sequence
   range to operate on in tcp_sacktag_one() to fix this bug.
   From Neal Cardwell.

Please pull, thanks a lot!

The following changes since commit c38e23456278e967f094b08247ffc3711b1029b2:

  i387: fix sense of sanity check (2012-02-15 08:05:18 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Axel Lin (2):
      mlx4: Fix kcalloc parameters swapped
      RxRPC: Fix kcalloc parameters swapped

Cousson, Benoit (1):
      ks8851: Fix NOHZ local_softirq_pending 08 warning

Eric Dumazet (3):
      bnx2x: fix bnx2x_storm_stats_update() on big endian
      netpoll: netpoll_poll_dev() should access dev->flags
      3c59x: shorten timer period for slave devices

Eugenia Emantayev (3):
      mlx4: fix buffer overrun
      mlx4: fix QP tree trashing
      mlx4: add unicast steering entries to resource_tracker

Florian Fainelli (5):
      cpmac: fix PHY name to match MDIO bus name
      bcm63xx-enet: fix PHY name to match MDIO bus name
      fec: fix PHY name to match fixed MDIO bus name
      octeon: fix PHY name to match MDIO bus name
      ixp4xx-eth: fix PHY name to match MDIO bus name

Francesco Virlinzi (1):
      stmmac: request_irq when use an ext wake irq line (v2)

Giuseppe CAVALLARO (3):
      stmmac: do not discard frame on dribbling bit assert
      stmmac: move hw init in the probe (v2)
      stmmac: update the driver version to Feb 2012 (v2)

Jan Weitzel (1):
      net/ethernet: ks8851_mll fix irq handling

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Michal Schmidt (1):
      bnx2x: remove the 'poll' module option

Mohammed Shafi Shajakhan (1):
      mac80211: Fix a rwlock bad magic bug

Neal Cardwell (3):
      tcp: allow tcp_sacktag_one() to tag ranges not aligned with skbs
      tcp: fix range tcp_shifted_skb() passes to tcp_sacktag_one()
      tcp: fix tcp_shifted_skb() adjustment of lost_cnt_hint for FACK

Simon Graham (1):
      rtlwifi: Modify rtl_pci_init to return 0 on success

Thomas Graf (1):
      veth: Enforce minimum size of VETH_INFO_PEER

Tim Gardner (1):
      ipheth: Add iPhone 4S

 drivers/net/ethernet/3com/3c59x.c                  |    2 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   17 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |    8 +-
 drivers/net/ethernet/freescale/fec.c               |    2 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c            |    5 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   21 ++-
 drivers/net/ethernet/micrel/ks8851.c               |    2 +-
 drivers/net/ethernet/micrel/ks8851_mll.c           |   14 +-
 drivers/net/ethernet/octeon/octeon_mgmt.c          |    4 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |    1 +
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |    2 +-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    5 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    7 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  205 ++++++++++----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    6 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   23 +--
 drivers/net/ethernet/ti/cpmac.c                    |    4 +-
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |    3 +-
 drivers/net/usb/ipheth.c                           |    5 +
 drivers/net/veth.c                                 |    4 +-
 drivers/net/wireless/rtlwifi/pci.c                 |    4 +-
 net/core/netpoll.c                                 |    2 +-
 net/ipv4/tcp_input.c                               |   45 +++--
 net/mac80211/main.c                                |    4 +-
 net/rxrpc/ar-key.c                                 |    4 +-
 27 files changed, 212 insertions(+), 191 deletions(-)
