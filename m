From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 22 Jul 2008 18:43:15 -0700 (PDT)
Message-ID: <20080722.184315.193699759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51665
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750857AbYGWBnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 21:43:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Major items:

1) Pull in network driver work via Jeff Garzik, including addition
   of the Atheros L1E Gigabit Ethernet driver.

2) Stephen Hemminger fixes a refcount bug wrt. timers in ipv6, as
   well as some futher ipv6 cleanups.

3) Adrian Bunk marked some functions static.

4) Anton Vorontsov fixes some more cases of driver netif_*_queue() usage.

5) ipv6_devconf should not be exported to userland in header files

6) Fix handling of coverage parameter in UDPLITE, from Gerrit Ranker.

7) 'mandocs' make target was failing.  Fix thanks to Dave Jones.

There is a pending fix for Ingo's netconsole memory corruption
problems, it is an e1000 driver bug.  I will integrate that fix in the
next round since it appears all the active Intel driver maintainers
are at OLS this week :-)

Please pull, thanks a lot!

The following changes since commit 5547cd0ae8b46db9a084505239294eed9b8c8e2d:
  Patrick McHardy (1):
        netfilter: nf_conntrack_sctp: fix sparse warnings

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (5):
      netns: make get_proc_net() static
      pkt_sched: make qdisc_class_hash_alloc() static
      sctp: make sctp_outq_flush() static
      sctp: remove sctp_assoc_proc_exit()
      ipv6: make struct ipv6_devconf static

Andy Richter (1):
      s390/net: Cleanup claw printk messages.

Anton Vorontsov (1):
      netdev: bunch of drivers: avoid WARN at net/core/dev.c:1328

Arjan van de Ven (1):
      net: Print the module name as part of the watchdog message

Ben Dooks (1):
      DM9000: Remove magic numbers

Ben Hutchings (3):
      sfc: I2C adapter initialisation fixes
      sfc: Use a separate workqueue for resets
      sfc: Create one RX queue and interrupt per CPU package by default

Brice Goglin (2):
      myri10ge: remove wcfifo
      myri10ge: use ioremap_wc

Christoph Lameter (1):
      Fix typo in meth driver

Dave Jones (4):
      net: Fix build failure with 'make mandocs'.
      8139too: Make PIO/MMIO a runtime decision through a module parameter.
      8139too: Force usage of PIO on OQO2
      8139too: Fall back to PIO when MMIO fails.

David S. Miller (7):
      ipv6: __KERNEL__ ifdef struct ipv6_devconf
      tcp: Fix bitmask test in tcp_syn_options()
      netdev: Handle ->addr_list_lock just like ->_xmit_lock for lockdep.
      Merge branch 'upstream-davem' of master.kernel.org:/.../jgarzik/netdev-2.6
      Merge branch 'upstream-davem' of master.kernel.org:/.../jgarzik/netdev-2.6
      netxen: Needs to include linux/vmalloc.h
      ipw2200: Call netif_*_queue() interfaces properly.

Dhananjay Phadke (11):
      netxen: cleanup unused variables/functions
      netxen: hw multicast filtering
      netxen: add defs for new chip/boards
      netxen: add 2MB PCI memory support
      netxen: pci probe and firmware init changes
      netxen: remove netxen_nic_isr.c
      netxen: add netxen_nic_ctx.c
      netxen: mtu, mac, link status changes
      netxen: cut-through rx changes
      netxen: enable tso6, intr coalescing.
      netxen: update driver version

Florian Fainelli (11):
      r6040: prefix all functions with r6040
      r6040: fix null pointer access and tx timeouts
      r6040: fix scheduling while atomic in r6040_tx_timeout
      r6040: rework the RX buffers allocation routine
      r6040: call napi_disable when puting down the interface and set lp->dev accordingly.
      r6040: completely rework the RX path
      r6040: use definitions for magic values in descriptor status
      r6040: change the default waiting time
      r6040: handle RX fifo full and no descriptor interrupts
      r6040: bump release number to 0.18
      r6040: rework init_one error handling

Francois Romieu (2):
      r8169: multicast register update
      e1000: delete non NAPI code from the driver

Gerrit Renker (1):
      udplite: Protection against coverage value wrap-around

Harvey Harrison (2):
      net: igb_main.c fix sparse integer as NULL pointer warning
      net: tun.c fix cast

Ian Schram (1):
      mac80211_hwsim.c: fix: BUG: unable to handle kernel NULL pointer dereference at 0000000000000370

Ingo Molnar (1):
      net 8390p: fix interface usage

Jeff Garzik (2):
      Merge branch 'r8169-davem' of git://git.kernel.org/.../romieu/netdev-2.6 into upstream-fixes
      [netdrvr] atl1d: fix !CONFIG_PM build

Jeff Kirsher (1):
      e1000: remove email reference

Jesse Brandeburg (1):
      ixgbe: remove device ID for unsupported device

Jie Yang (1):
      atl1e: Atheros L1E Gigabit Ethernet driver

Joe Perches (6):
      e1000: neaten function declarations
      e1000: Use hw, er32, and ew32
      e1000: Move extern function definitions to e1000.h
      e1000: Remove spaces after casts and function names
      e1000: checkpatch clean
      e1000: Move assignments in tests before test

Laurent Pinchart (1):
      fs_enet: Remove unused fields in the fs_mii_bb_platform_info structure.

Lennert Buytenhek (1):
      mv643xx_eth: fix NETPOLL build

Marcus Sundberg (1):
      r8169: avoid thrashing PCI conf space above RTL_GIGA_MAC_VER_06

Paulius Zaleckas (1):
      at91_ether: use netstats in net_device structure

Peter Tiedemann (1):
      s390/net/ctcm: message cleanup

Stephen Hemminger (7):
      ipv6: use timer pending
      net: use kcalloc in netdev_queue alloc
      netns: dont alloc ipv6 fib timer list
      ipv6: use round_jiffies
      ipv6: use spin_trylock_bh
      ipv6: use kcalloc
      ipv6: icmp6_dst_gc return change

Taku Izumi (1):
      e1000: make ioport free

Thomas Backlund (1):
      rndis_host: support WM6 devices as modems

Ursula Braun (1):
      MAINTAINERS: Update email address of Ursula Braun

Wang Chen (1):
      de4x5: Remove developer debug feature about set/clear promisc

Wang Jian (2):
      net/phy: Fix copper/fiber auto-selection for 88e1111
      net/phy: Fix 88e1111 copper/fiber selection in RGMII mode

frank.blaschka@de.ibm.com (1):
      qeth: fix build error caused by VLAN changes

 Documentation/networking/e1000.txt       |   14 +-
 Documentation/networking/udplite.txt     |    2 +-
 MAINTAINERS                              |    4 +-
 drivers/net/8139too.c                    |  138 +-
 drivers/net/Kconfig                      |   25 +-
 drivers/net/Makefile                     |    1 +
 drivers/net/arm/at91_ether.c             |   39 +-
 drivers/net/arm/at91_ether.h             |    1 -
 drivers/net/atl1e/Makefile               |    2 +
 drivers/net/atl1e/atl1e.h                |  503 ++++++
 drivers/net/atl1e/atl1e_ethtool.c        |  405 +++++
 drivers/net/atl1e/atl1e_hw.c             |  664 ++++++++
 drivers/net/atl1e/atl1e_hw.h             |  793 +++++++++
 drivers/net/atl1e/atl1e_main.c           | 2599 ++++++++++++++++++++++++++++++
 drivers/net/atl1e/atl1e_param.c          |  263 +++
 drivers/net/au1000_eth.c                 |    5 +-
 drivers/net/bfin_mac.c                   |    1 -
 drivers/net/bonding/bond_main.c          |    3 +
 drivers/net/cpmac.c                      |    2 -
 drivers/net/dm9000.c                     |   15 +-
 drivers/net/e1000/e1000.h                |   71 +-
 drivers/net/e1000/e1000_ethtool.c        |  558 ++++----
 drivers/net/e1000/e1000_hw.c             | 1373 +++++++---------
 drivers/net/e1000/e1000_main.c           | 1490 ++++++++---------
 drivers/net/e1000/e1000_osdep.h          |   14 +-
 drivers/net/e1000/e1000_param.c          |   16 +-
 drivers/net/fec_mpc52xx.c                |    5 -
 drivers/net/fs_enet/fs_enet-main.c       |    7 +-
 drivers/net/hamradio/bpqether.c          |    2 +
 drivers/net/hp-plus.c                    |    2 +-
 drivers/net/hp.c                         |    2 +-
 drivers/net/igb/igb_main.c               |    2 +-
 drivers/net/ixgbe/ixgbe_main.c           |    2 -
 drivers/net/macb.c                       |    4 +-
 drivers/net/macvlan.c                    |    3 +
 drivers/net/meth.c                       |    2 +-
 drivers/net/mv643xx_eth.c                |    2 +-
 drivers/net/myri10ge/myri10ge.c          |   62 +-
 drivers/net/ne.c                         |    2 +-
 drivers/net/ne2.c                        |    2 +-
 drivers/net/netxen/Makefile              |    2 +-
 drivers/net/netxen/netxen_nic.h          |  575 ++++++-
 drivers/net/netxen/netxen_nic_ctx.c      |  710 ++++++++
 drivers/net/netxen/netxen_nic_ethtool.c  |  168 ++-
 drivers/net/netxen/netxen_nic_hdr.h      |  251 +++-
 drivers/net/netxen/netxen_nic_hw.c       | 2196 ++++++++++++++++++-------
 drivers/net/netxen/netxen_nic_hw.h       |   60 +-
 drivers/net/netxen/netxen_nic_init.c     |  806 ++++++----
 drivers/net/netxen/netxen_nic_isr.c      |  220 ---
 drivers/net/netxen/netxen_nic_main.c     | 1169 +++++++++-----
 drivers/net/netxen/netxen_nic_niu.c      |  114 +-
 drivers/net/netxen/netxen_nic_phan_reg.h |   31 +-
 drivers/net/phy/marvell.c                |    7 +-
 drivers/net/r6040.c                      |  445 +++---
 drivers/net/r8169.c                      |   14 +-
 drivers/net/sfc/efx.c                    |   39 +-
 drivers/net/sfc/falcon.c                 |   12 +-
 drivers/net/sfc/net_driver.h             |    5 +-
 drivers/net/sh_eth.c                     |    5 -
 drivers/net/tc35815.c                    |    1 -
 drivers/net/tulip/de4x5.c                |   16 -
 drivers/net/tulip/de4x5.h                |    3 +-
 drivers/net/tun.c                        |    2 +-
 drivers/net/usb/cdc_ether.c              |   11 +-
 drivers/net/usb/rndis_host.c             |    4 +
 drivers/net/wireless/hostap/hostap_hw.c  |    3 +
 drivers/net/wireless/ipw2200.c           |   33 +-
 drivers/net/wireless/mac80211_hwsim.c    |   18 +-
 drivers/s390/net/claw.c                  | 2141 ++++++-------------------
 drivers/s390/net/ctcm_dbug.c             |   29 +-
 drivers/s390/net/ctcm_dbug.h             |   39 +-
 drivers/s390/net/ctcm_fsms.c             |  402 ++---
 drivers/s390/net/ctcm_main.c             |  514 +++----
 drivers/s390/net/ctcm_main.h             |   31 +-
 drivers/s390/net/ctcm_mpc.c              | 1110 +++++--------
 drivers/s390/net/ctcm_mpc.h              |    2 +-
 drivers/s390/net/qeth_l3_main.c          |    2 +-
 fs/proc/proc_net.c                       |   11 +-
 include/linux/fs_enet_pd.h               |    4 -
 include/linux/ipv6.h                     |    2 +
 include/linux/netdevice.h                |   60 +-
 include/linux/proc_fs.h                  |    2 -
 include/net/if_inet6.h                   |    2 -
 include/net/ip6_route.h                  |    2 +-
 include/net/netns/ipv6.h                 |    2 +-
 include/net/sctp/structs.h               |    1 -
 net/8021q/vlan_dev.c                     |    4 +
 net/core/dev.c                           |  102 +-
 net/ipv4/tcp_output.c                    |    2 +-
 net/ipv4/udp.c                           |    4 +
 net/ipv6/addrconf.c                      |    2 +-
 net/ipv6/ip6_fib.c                       |   60 +-
 net/ipv6/route.c                         |   10 +-
 net/netrom/af_netrom.c                   |    2 +
 net/rose/af_rose.c                       |    2 +
 net/sched/sch_api.c                      |    2 +-
 net/sched/sch_generic.c                  |    6 +-
 net/sctp/outqueue.c                      |    4 +-
 net/sctp/proc.c                          |    5 -
 99 files changed, 13448 insertions(+), 7133 deletions(-)
 create mode 100644 drivers/net/atl1e/Makefile
 create mode 100644 drivers/net/atl1e/atl1e.h
 create mode 100644 drivers/net/atl1e/atl1e_ethtool.c
 create mode 100644 drivers/net/atl1e/atl1e_hw.c
 create mode 100644 drivers/net/atl1e/atl1e_hw.h
 create mode 100644 drivers/net/atl1e/atl1e_main.c
 create mode 100644 drivers/net/atl1e/atl1e_param.c
 create mode 100644 drivers/net/netxen/netxen_nic_ctx.c
 delete mode 100644 drivers/net/netxen/netxen_nic_isr.c
