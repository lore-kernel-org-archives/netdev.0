From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 12 Jul 2013 23:16:27 -0700 (PDT)
Message-ID: <20130712.231627.1891287860450946112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076Ab3GMGQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jul 2013 02:16:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just a bunch of small fixes and tidy ups:

1) Finish the "busy_poll" renames, from Eliezer Tamir.

2) Fix RCU stalls in IFB driver, from Ding Tianhong.

3) Linearize buffers properly in tun/macvtap zerocopy code.

4) Don't crash on rmmod in vxlan, from Pravin B Shelar.

5) Spinlock used before init in alx driver, from Maarten Lankhorst.

6) A sparse warning fix in bnx2x broke TSO checksums, fix from
   Dmitry Kravkov.

7) Dummy and ifb driver load failure paths can oops, fixes from
   Tan Xiaojun and Ding Tianhong.

8) Correct MTU calculations in IP tunnels, from Alexander Duyck.

9) Account all TCP retransmits in SNMP stats properly, from Yuchung
   Cheng.

10) atl1e and via-rhine do not handle DMA mapping failures properly,
    from Neil Horman.

11) Various equal-cost multipath route fixes in ipv6 from Hannes
    Frederic Sowa.

Please pull, thanks a lot!

The following changes since commit bfffbea1aaeeb1eb6500c83ff9653416daa5b490:

  Merge tag 'mmc-updates-for-3.11-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/cjb/mmc (2013-07-10 11:16:00 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 307f2fb95e9b96b3577916e73d92e104f8f26494:

  ipv6: only static routes qualify for equal cost multipathing (2013-07-12 16:29:54 -0700)

----------------------------------------------------------------
Alexander Duyck (2):
      gso: Update tunnel segmentation to support Tx checksum offload
      gre: Fix MTU sizing check for gretap tunnels

Andy Shevchenko (1):
      net/tipc: use %*phC to dump small buffers in hex form

Camelia Groza (1):
      inet: fix spacing in assignment

David S. Miller (1):
      Merge "net: finish renaming lls to busy poll"

Dmitry Kravkov (1):
      bnx2x: fix tunneling CSUM calculation

Eliezer Tamir (3):
      net: rename include/net/ll_poll.h to include/net/busy_poll.h
      net: rename ll methods to busy-poll
      net: rename busy poll socket op and globals

Geert Uytterhoeven (1):
      sh_eth: SH_ETH should depend on HAS_DMA

Hannes Frederic Sowa (3):
      ipv6: in case of link failure remove route directly instead of letting it expire
      ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
      ipv6: only static routes qualify for equal cost multipathing

Helmut Schaa (1):
      drivers: net: phy: at803x: Add missing mdio device id

Jason Wang (2):
      tuntap: correctly linearize skb when zerocopy is used
      macvtap: correctly linearize skb when zerocopy is used

Jitendra Kalsaria (1):
      qlcnic: Adding Maintainers.

Maarten Lankhorst (1):
      alx: fix lockdep annotation

Neil Horman (2):
      atl1e: fix dma mapping warnings
      via-rhine: fix dma mapping errors

Paolo Valente (2):
      pkt_sched: sch_qfq: improve efficiency of make_eligible
      pkt_sched: sch_qfq: remove forward declaration of qfq_update_agg_ts

Pravin B Shelar (1):
      vxlan: Fix kernel crash on rmmod.

Sasha Levin (1):
      9p: fix off by one causing access violations and memory corruption

Sunghan Suh (1):
      net: access page->private by using page_private

Wolfram Sang (3):
      drivers/net/can/c_can: don't use devm_pinctrl_get_select_default() in probe
      drivers/net/ethernet/cadence: don't use devm_pinctrl_get_select_default() in probe
      drivers/net/ieee802154: don't use devm_pinctrl_get_select_default() in probe

Yuchung Cheng (1):
      tcp: account all retransmit failures

dingtianhong (3):
      ifb: fix rcu_sched self-detected stalls
      dummy: fix oops when loading the dummy failed
      ifb: fix oops when loading the ifb failed

hayeswang (4):
      r8169: add a new chip for RTL8411
      net/usb: add relative mii functions for r815x
      usb/net/r8152: fix integer overflow in expression
      usb/net/r815x: fix cast to restricted __le32

“Cosmin (1):
      net: strict_strtoul is obsolete, use kstrtoul instead

 Documentation/sysctl/net.txt                     |  17 ++--
 MAINTAINERS                                      |   2 +
 arch/alpha/include/uapi/asm/socket.h             |   2 +-
 arch/avr32/include/uapi/asm/socket.h             |   2 +-
 arch/cris/include/uapi/asm/socket.h              |   2 +-
 arch/frv/include/uapi/asm/socket.h               |   2 +-
 arch/h8300/include/uapi/asm/socket.h             |   2 +-
 arch/ia64/include/uapi/asm/socket.h              |   2 +-
 arch/m32r/include/uapi/asm/socket.h              |   2 +-
 arch/mips/include/uapi/asm/socket.h              |   2 +-
 arch/mn10300/include/uapi/asm/socket.h           |   2 +-
 arch/parisc/include/uapi/asm/socket.h            |   2 +-
 arch/powerpc/include/uapi/asm/socket.h           |   2 +-
 arch/s390/include/uapi/asm/socket.h              |   2 +-
 arch/sparc/include/uapi/asm/socket.h             |   2 +-
 arch/xtensa/include/uapi/asm/socket.h            |   2 +-
 drivers/net/can/c_can/c_can_platform.c           |   7 --
 drivers/net/dummy.c                              |   4 +
 drivers/net/ethernet/atheros/alx/main.c          |   5 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c  |  28 +++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |  10 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   2 +-
 drivers/net/ethernet/cadence/at91_ether.c        |  11 ---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   4 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c       |   4 +-
 drivers/net/ethernet/realtek/r8169.c             |  67 +++++++++++++++
 drivers/net/ethernet/renesas/Kconfig             |   1 +
 drivers/net/ethernet/via/via-rhine.c             |  17 +++-
 drivers/net/ieee802154/mrf24j40.c                |   7 --
 drivers/net/ifb.c                                |   8 +-
 drivers/net/macvtap.c                            |   8 +-
 drivers/net/phy/at803x.c                         |   1 +
 drivers/net/tun.c                                |   9 +-
 drivers/net/usb/Makefile                         |   2 +-
 drivers/net/usb/cdc_ether.c                      |   9 +-
 drivers/net/usb/r8152.c                          |   3 +-
 drivers/net/usb/r815x.c                          | 234 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/vxlan.c                              |   2 +-
 fs/select.c                                      |   2 +-
 include/linux/netdevice.h                        |   2 +-
 include/net/{ll_poll.h => busy_poll.h}           |  30 ++++---
 include/uapi/asm-generic/socket.h                |   2 +-
 net/9p/trans_common.c                            |  10 +--
 net/core/datagram.c                              |   2 +-
 net/core/dev.c                                   |  14 ++-
 net/core/skbuff.c                                |   6 +-
 net/core/sock.c                                  |   8 +-
 net/core/sysctl_net_core.c                       |  10 +--
 net/dns_resolver/dns_key.c                       |   2 +-
 net/ipv4/gre_offload.c                           |   3 +
 net/ipv4/inet_hashtables.c                       |   2 +-
 net/ipv4/ip_tunnel.c                             |   2 +-
 net/ipv4/tcp.c                                   |   2 +-
 net/ipv4/tcp_ipv4.c                              |   4 +-
 net/ipv4/tcp_output.c                            |   7 +-
 net/ipv4/udp.c                                   |   8 +-
 net/ipv6/ip6_fib.c                               |  15 +++-
 net/ipv6/route.c                                 |  72 ++++++++++------
 net/ipv6/tcp_ipv6.c                              |   4 +-
 net/ipv6/udp.c                                   |   4 +-
 net/sched/sch_qfq.c                              | 127 ++++++++++++++-------------
 net/socket.c                                     |   6 +-
 net/tipc/ib_media.c                              |   8 +-
 65 files changed, 607 insertions(+), 241 deletions(-)
 create mode 100644 drivers/net/usb/r815x.c
 rename include/net/{ll_poll.h => busy_poll.h} (83%)
