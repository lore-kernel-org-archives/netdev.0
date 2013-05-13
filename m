From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 13 May 2013 13:08:18 -0700 (PDT)
Message-ID: <20130513.130818.677935248720864686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Several small bug fixes all over:

1) be2net driver uses wrong payload length when submitting MAC list get
   requests to the chip.  From Sathya Perla.

2) Fix mwifiex memory leak on driver unload, from Amitkumar Karwar.

3) Prevent random memory access in batman-adv, from Marek Lindner.

4) batman-adv doesn't check for pskb_trim_rcsum() errors, also from Marek
   Lindner.

5) Fix fec crashes on rapid link up/down, from Frank Li.

6) Fix inner protocol grovelling in GSO, from Pravin B Shelar.

7) Link event validation fix in qlcnic from Rajesh Borundia.

8) Not all FEC chips can support checksum offload, fix from Shawn Guo.

9) EXPORT_SYMBOL + inline doesn't make any sense, from Denis Efremov.

10) Fix race in passthru mode during device removal in macvlan, from
    Jiri Pirko.

11) Fix RCU hash table lookup socket state race in ipv6, leading to NULL
    pointer derefs, from Eric Dumazet.

12) Add several missing HAS_DMA kconfig dependencies, from Geert
    Uyttterhoeven.

13) Fix bogus PCI resource management in 3c59x driver, from Sergei
    Shtylyov.

14) Fix info leak in ipv6 GRE tunnel driver, from Amerigo Wang.

15) Fix device leak in ipv6 IPSEC policy layer, from Cong Wang.

16) DMA mapping leak fix in qlge from Thadeu Lima de Souza Cascardo.

17) Missing iounmap on probe failure in bna driver, from Wei Yongjun.

Please pull, thanks a lot!

The following changes since commit 70eba4226d9718946941c7be0c8cb66d431e7686:

  Merge tag 'please-pull-pstore' of git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux (2013-05-09 16:42:10 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to ba21fc696dd28ea7a5880345faf0168619a478d2:

  bna: add missing iounmap() on error in bnad_init() (2013-05-13 12:54:38 -0700)

----------------------------------------------------------------
Amerigo Wang (2):
      virtio_net: use default napi weight by default
      ipv6,gre: do not leak info to user-space

Amitkumar Karwar (1):
      mwifiex: fix memory leak issue when driver unload

Antonio Quartulli (2):
      batman-adv: make DAT drop ARP requests targeting local clients
      batman-adv: reorder clean up routine in order to avoid race conditions

Bing Zhao (1):
      mwifiex: clear is_suspended flag when interrupt is received early

Cong Wang (1):
      xfrm6: release dev before returning error

Daniel Drake (1):
      mwifiex: fix setting of multicast filter

David S. Miller (3):
      Merge branch 'wireless'
      Merge branch 'qlcnic'
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/linux-merge

Denis Efremov (1):
      ipv4: ip_output: remove inline marking of EXPORT_SYMBOL functions

Eric Dumazet (1):
      ipv6: do not clear pinet6 field

Felix Fietkau (1):
      ath9k: fix key allocation error handling for powersave keys

Geert Uytterhoeven (6):
      net/ethernet: NET_CALXEDA_XGMAC should depend on HAS_DMA
      net/ethernet: STMMAC_ETH should depend on HAS_DMA
      net/wireless: ATH9K should depend on HAS_DMA
      net/ethernet: ARM_AT91_ETHER should depend on HAS_DMA
      net/ethernet: MACB should depend on HAS_DMA
      caif: CAIF_VIRTIO should depend on HAS_DMA

Himanshu Madhani (2):
      qlcnic: Fix missing bracket in module parameter.
      qlcnic: Fix ethtool supported port status for 83xx

Jiri Pirko (1):
      macvlan: fix passthru mode race between dev removal and rx path

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Manish Chopra (2):
      qlcnic: Fix setting MAC address
      qlcnic: Fix bug in diagnostics test reset recovery path

Marek Lindner (2):
      batman-adv: check proto length before accessing proto string buffer
      batman-adv: check return value of pskb_trim_rcsum()

Or Gerlitz (1):
      net/mlx4_core: Add missing report on VST and spoof-checking dev caps

Petri Gynther (1):
      emac: Fix EMAC soft reset on 460EX/GT

Rajesh Borundia (2):
      qlcnic: Fix mailbox response handling.
      qlcnic: Fix validation of link event command.

Rony Efraim (1):
      net/mlx4: Strengthen VLAN tags/priorities enforcement in VST mode

Sergei Shtylyov (1):
      3c59x: fix PCI resource management

Shahed Shaikh (1):
      qlcnic: Fix ethtool strings

Shawn Guo (1):
      net: fec: enable hardware checksum only on imx6q-fec

Sony Chacko (1):
      qlcnic: Fix reset recovery after transmit timeout

Stanislaw Gruszka (2):
      ath5k: do not reschedule tx_complete_work on stop
      iwl4965: workaround connection regression on passive channel

Sujith Manoharan (2):
      ath9k: Fix beacon reconfiguration
      ath9k: Update initvals for AR9565

Thadeu Lima de Souza Cascardo (1):
      qlge: fix dma map leak when the last chunk is not allocated

Thommy Jakobsson (1):
      B43: Handle DMA RX descriptor underrun

Wei Yongjun (1):
      bna: add missing iounmap() on error in bnad_init()

 drivers/net/caif/Kconfig                                 |   2 +-
 drivers/net/ethernet/3com/3c59x.c                        |  25 ++++++-----
 drivers/net/ethernet/brocade/bna/bnad.c                  |   5 ++-
 drivers/net/ethernet/cadence/Kconfig                     |   3 +-
 drivers/net/ethernet/calxeda/Kconfig                     |   2 +-
 drivers/net/ethernet/freescale/fec_main.c                |  20 ++++++---
 drivers/net/ethernet/ibm/emac/core.c                     |  36 +++++++++++----
 drivers/net/ethernet/mellanox/mlx4/en_resources.c        |   2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c                  |   4 +-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c    |  29 +++++++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h              |   2 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c      |  95 ++++++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h      |   4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c    |  22 +++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c      |  54 +++++++++++-----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h           |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c         |  46 ++++++++++++++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c |   8 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c     |   3 --
 drivers/net/ethernet/qlogic/qlge/qlge_main.c             |   7 +++
 drivers/net/ethernet/stmicro/stmmac/Kconfig              |   2 +-
 drivers/net/macvlan.c                                    |   7 +--
 drivers/net/virtio_net.c                                 |   2 +-
 drivers/net/wireless/ath/ath5k/base.c                    |   5 +++
 drivers/net/wireless/ath/ath9k/Kconfig                   |   2 +-
 drivers/net/wireless/ath/ath9k/ar9565_1p0_initvals.h     | 138 +++++++++++++++++++++++++++++----------------------------
 drivers/net/wireless/ath/ath9k/main.c                    |  10 +++--
 drivers/net/wireless/b43/dma.c                           |  19 ++++++++
 drivers/net/wireless/b43/dma.h                           |   4 +-
 drivers/net/wireless/b43/main.c                          |  43 ++++++++----------
 drivers/net/wireless/iwlegacy/4965-mac.c                 |   3 +-
 drivers/net/wireless/mwifiex/cfg80211.c                  |   3 --
 drivers/net/wireless/mwifiex/cmdevt.c                    |   1 +
 drivers/net/wireless/mwifiex/main.c                      |   1 +
 drivers/net/wireless/mwifiex/sta_ioctl.c                 |  21 +++------
 include/linux/mlx4/qp.h                                  |  29 +++++++++++-
 include/net/sock.h                                       |  12 +++++
 net/batman-adv/distributed-arp-table.c                   |  13 ++++++
 net/batman-adv/main.c                                    |  18 +++++---
 net/batman-adv/network-coding.c                          |   8 +++-
 net/core/sock.c                                          |  12 -----
 net/ipv4/ip_output.c                                     |   2 +-
 net/ipv6/ip6_gre.c                                       |   2 +
 net/ipv6/tcp_ipv6.c                                      |  12 +++++
 net/ipv6/udp.c                                           |  13 +++++-
 net/ipv6/udp_impl.h                                      |   2 +
 net/ipv6/udplite.c                                       |   2 +-
 net/ipv6/xfrm6_policy.c                                  |   4 +-
 48 files changed, 498 insertions(+), 263 deletions(-)
