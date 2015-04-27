From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 27 Apr 2015 13:56:33 -0400 (EDT)
Message-ID: <20150427.135633.390607061714659719.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) mlx4 doesn't check fully for supported valid RSS hash function, fix =
from
   Amir Vadai.

2) Off by one in ibmveth_change_mtu(), from David Gibson.

3) Prevent altera chip from reporting false error interrupts in some
   circumstances, from Chee Nouk Phoon.

4) Get rid of that stupid endless loop trying to allocate a FIN packet
   in TCP, and in the process kill deadlocks.  From Eric Dumazet.

5) Fix get_rps_cpus() crash due to wrong invalid-cpu value, also from
   Eric Dumazet.

6) Fix two bugs in async rhashtable resizing, from Thomas Graf.

7) Fix topology server listener socket namespace bug in TIPC, from
   Ying Xue.

8) Add some missing HAS_DMA kconfig dependencies, from Geert
   Uytterhoeven.

9) bgmac driver intends to force re-polling but does so by returning
   the wrong value from it's ->poll() handler.  Fix from Rafa=A9=A9
   Mi=A9=A9ecki.

10) When the creater of an rhashtable configures a max size for it,
    don't bark in the logs and drop insertions when that is exceeded.
    Fix from Johannes Berg.

11) Recover from out of order packets in ppp mppe properly, from Sylvai=
n
    Rochet.

Please pull, thanks a lot!

The following changes since commit 5e6c94a999f67f120c6bbba71bbee840dfee=
6338:

  Merge tag 'mmc-4.1-rc1' of git://git.linaro.org/people/ulf.hansson/mm=
c (2015-04-22 09:29:08 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to 22a8f237c0551bae95ffcd2a7ff17d6f5fcce7e7=
:

  bnx2x: really disable TPA if 'disable_tpa' option is set (2015-04-27 =
13:42:39 -0400)

----------------------------------------------------------------
Alexey Khoroshilov (1):
      pxa168: fix double deallocation of managed resources

Amir Vadai (1):
      net/mlx4_en: Prevent setting invalid RSS hash function

Andreas Oetken (1):
      altera tse: add support for fixed-links.

Ben Shelton (1):
      net/macb: Factor out one-time assignment from loop

Chee Nouk Phoon (1):
      net: eth: altera: Resolve false errors from MSGDMA to TSE

David Gibson (1):
      ibmveth: Fix off-by-one error in ibmveth_change_mtu()

David S. Miller (5):
      Merge branch 'rhashtable-fixes'
      Merge branch 'mpls'
      Merge branch 'tipc-fixes'
      Merge branch 'ppp_mppe_desync'
      netfilter; Add some missing default cases to switch statements in=
 nft_reject.

Eric Dumazet (6):
      tcp: fix possible deadlock in tcp_send_fin()
      net: do not deplete pfmemalloc reserve
      tcp: avoid looping in tcp_send_fin()
      inet: fix possible panic in reqsk_queue_unlink()
      net: fix crash in build_skb()
      net: rfs: fix crash in get_rps_cpus()

Erik Hugne (2):
      tipc: fix random link reset problem
      tipc: fix node refcount issue

Gavin Shan (1):
      net/tg3: Release IRQs on permanent error

Geert Uytterhoeven (3):
      ethernet: amd: AMD_XGBE should depend on HAS_DMA
      ethernet: arc: ARC_EMAC and EMAC_ROCKCHIP should depend on HAS_DM=
A
      can: CAN_GRCAN should depend on HAS_DMA

Jason Eastman (1):
      net: unix: garbage: fixed several comment and whitespace style is=
sues

Johannes Berg (3):
      ip6_gre: use netdev_alloc_pcpu_stats()
      netdev_alloc_pcpu_stats: use less common iterator variable
      rhashtable: don't attempt to grow when at max_size

Li RongQing (1):
      vxlan: remove the unnecessary codes

Luis R. Rodriguez (1):
      ethernet: myri10ge: use arch_phys_wc_add()

Masanari Iida (1):
      net:treewide: Fix typo in drivers/net

Matan Barak (1):
      net/bonding: Make DRV macros private

Michael Ellerman (1):
      ehea: Fix memory hook reference counting crashes

Michal Schmidt (1):
      bnx2x: really disable TPA if 'disable_tpa' option is set

Rafa=A9=A9 Mi=A9=A9ecki (1):
      bgmac: fix requests for extra polling calls from NAPI

Robert Shearman (3):
      mpls: Per-device MPLS state
      mpls: Per-device enabling of packet input
      mpls: Prevent use of implicit NULL label as outgoing label

Rojhalat Ibrahim (1):
      mdio-mux-gpio: use new gpiod_get_array and gpiod_put_array functi=
ons

Sylvain Rochet (2):
      ppp: mppe: sanity error path rework
      ppp: mppe: discard late packet in stateless mode

Thomas Graf (2):
      rhashtable: Schedule async resize when sync realloc fails
      rhashtable: Do not schedule more than one rehash if we can't grow=
 further

Vivien Didelot (1):
      net: mdio-gpio: support access that may sleep

Ying Xue (1):
      tipc: fix topology server broken issue

Yuval Mintz (1):
      bnx2x: Prevent inner-reload while VFs exist

 Documentation/networking/mpls-sysctl.txt            |   9 +++++++
 Documentation/networking/scaling.txt                |   2 +-
 drivers/net/bonding/bond_main.c                     |   2 ++
 drivers/net/bonding/bond_procfs.c                   |   1 +
 drivers/net/bonding/bonding_priv.h                  |  25 ++++++++++++=
++++++++
 drivers/net/can/Kconfig                             |   2 +-
 drivers/net/can/usb/kvaser_usb.c                    |   2 +-
 drivers/net/ethernet/8390/etherh.c                  |   2 +-
 drivers/net/ethernet/altera/altera_msgdmahw.h       |   5 +---
 drivers/net/ethernet/altera/altera_tse_main.c       |  37 ++++++++++++=
++++++++++-------
 drivers/net/ethernet/amd/Kconfig                    |   2 +-
 drivers/net/ethernet/arc/Kconfig                    |   5 ++--
 drivers/net/ethernet/broadcom/bgmac.c               |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |  49 ++++++++++++=
+++++++++++++++++---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |  17 ++++++++++++=
+
 drivers/net/ethernet/broadcom/tg3.c                 |   4 +++-
 drivers/net/ethernet/cadence/macb.c                 |   4 ++--
 drivers/net/ethernet/ibm/ehea/ehea_main.c           |   6 +++--
 drivers/net/ethernet/ibm/ibmveth.c                  |   4 ++--
 drivers/net/ethernet/marvell/pxa168_eth.c           |  16 ++++--------=
-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c     |  29 ++++++++++++=
+----------
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c    |  38 +++++++-----=
-----------------
 drivers/net/phy/mdio-gpio.c                         |  14 +++++++----
 drivers/net/phy/mdio-mux-gpio.c                     |  60 ++++++++++++=
+---------------------------------
 drivers/net/ppp/ppp_mppe.c                          |  36 ++++++++++++=
+++-------------
 drivers/net/vxlan.c                                 |   6 +----
 include/linux/netdevice.h                           |  10 +++++---
 include/linux/rhashtable.h                          |   3 ++-
 include/linux/skbuff.h                              |   1 +
 include/net/bonding.h                               |   7 ------
 include/net/inet_connection_sock.h                  |  20 +-----------=
----
 include/net/request_sock.h                          |  18 ------------=
--
 lib/rhashtable.c                                    |  11 ++++++---
 net/core/dev.c                                      |  12 +++++-----
 net/core/skbuff.c                                   |  30 ++++++++++++=
++++++-----
 net/dccp/ipv4.c                                     |   3 ++-
 net/dccp/ipv6.c                                     |   3 ++-
 net/dccp/minisocks.c                                |   3 +--
 net/ipv4/inet_connection_sock.c                     |  34 ++++++++++++=
++++++++++++++
 net/ipv4/tcp_ipv4.c                                 |   3 ++-
 net/ipv4/tcp_minisocks.c                            |   7 +++---
 net/ipv4/tcp_output.c                               |  64 ++++++++++++=
++++++++++++++++++++++---------------
 net/ipv6/ip6_gre.c                                  |   9 +------
 net/ipv6/tcp_ipv6.c                                 |   3 ++-
 net/mpls/af_mpls.c                                  | 125 ++++++++++++=
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++++++++---
 net/mpls/internal.h                                 |   6 +++++
 net/netfilter/nft_reject.c                          |   2 ++
 net/netfilter/nft_reject_inet.c                     |   2 ++
 net/netlink/af_netlink.c                            |   6 ++---
 net/tipc/link.c                                     |   1 -
 net/tipc/server.c                                   |   9 +++----
 net/tipc/socket.c                                   |   3 ++-
 net/unix/garbage.c                                  |  70 ++++++++++++=
++++++++++--------------------------------
 53 files changed, 527 insertions(+), 317 deletions(-)
 create mode 100644 drivers/net/bonding/bonding_priv.h
