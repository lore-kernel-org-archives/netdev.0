From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 16 Dec 2009 00:03:02 -0800 (PST)
Message-ID: <20091216.000302.140787020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932089AbZLPIDK@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Revert a set of TCP changes which were not fully cooked.
The kernel log message signature for this regression is:

	Badness at net/ipv4/inet_connection_sock.c:293

Julia Lawall found and fixed several instances of sizeof(pointer) that
were definitely not intended.

Dynamic sizing of the UDP hash table introduced a subtle bug, fixed
by Eric Dumazet.

A couple netfilter bug fixes via Patrick McHardy, including a nasty
one involving a conflict between the defragmentation done by
the core stack and those done by various parts of netfilter.

Update x25 maintainer.

And a few small driver bug fixes to round things out.

Please pull, thanks a lot.

The following changes since commit 3ea6b3d0e6d0ffd91c0f8cadeb69b7133c038b32:
  Linus Torvalds (1):
        Merge branch 'for_linus' of git://git.kernel.org/.../jack/linux-udf-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Arnd Bergmann (1):
      x25: Update maintainer.

David S. Miller (2):
      tcp: Revert per-route SACK/DSACK/TIMESTAMP changes.
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6

Eric Dumazet (2):
      udp: udp_lib_get_port() fix
      packet: dont call sleeping functions while holding rcu_read_lock()

Eric W. Biederman (1):
      net: Fix userspace RTM_NEWLINK notifications.

Florian Fainelli (1):
      bcm63xx_enet: fix compilation failure after get_stats_count removal

Geert Uytterhoeven (1):
      can: CAN_MCP251X should depend on HAS_DMA

Gurucharan Shetty (1):
      ixgbe: allow tx of pre-formatted vlan tagged packets

Jan Engelhardt (1):
      netfilter: xtables: document minimal required version

Joe Perches (1):
      drivers/net/bonding/: : use pr_fmt

Julia Lawall (4):
      drivers/atm: Correct code taking the size of a pointer
      drivers/net/sfc: Correct code taking the size of a pointer
      drivers/net/cpmac.c: Correct code taking the size of a pointer
      drivers/net/usb: Correct code taking the size of a pointer

Ken Kawasaki (1):
      3c574_cs: disable irq before calling el3_interrupt

Magnus Damm (1):
      net: sh_eth alignment fix for sh7724 using NET_IP_ALIGN V2

Mallikarjuna R Chilakala (2):
      ixgbe: Fix tx_restart_queue/non_eop_desc statistics counters
      ixgbe: Fix 82598 premature copper PHY link indicatation

Oliver Hartkopp (1):
      can: Fix data length code handling in rx path

Patrick McHardy (2):
      ipv6: reassembly: use seperate reassembly queues for conntrack and local delivery
      netfilter: fix crashes in bridge netfilter caused by fragment jumps

Simon Horman (1):
      ipvs: zero usvc and udest

Xiaotian Feng (1):
      ipvs: fix synchronization on connection close

roel kluin (1):
      mlx4_core: return a negative error value

stephen hemminger (2):
      sky2: print Optima chip name
      sky2: leave PCI config space writeable

 Documentation/Changes                          |    2 +
 MAINTAINERS                                    |    4 +-
 drivers/atm/iphase.c                           |    2 +-
 drivers/net/bcm63xx_enet.c                     |   12 +-
 drivers/net/bonding/bond_3ad.c                 |  171 ++++---
 drivers/net/bonding/bond_alb.c                 |   38 +-
 drivers/net/bonding/bond_ipv6.c                |   12 +-
 drivers/net/bonding/bond_main.c                |  607 +++++++++---------------
 drivers/net/bonding/bond_sysfs.c               |  327 +++++--------
 drivers/net/can/Kconfig                        |    2 +-
 drivers/net/can/at91_can.c                     |    2 +-
 drivers/net/can/bfin_can.c                     |    2 +-
 drivers/net/can/mcp251x.c                      |   13 +-
 drivers/net/can/mscan/mscan.c                  |    3 +-
 drivers/net/can/sja1000/sja1000.c              |   18 +-
 drivers/net/can/ti_hecc.c                      |    2 +-
 drivers/net/can/usb/ems_usb.c                  |    2 +-
 drivers/net/cpmac.c                            |    2 +-
 drivers/net/ixgbe/ixgbe_82598.c                |   38 ++
 drivers/net/ixgbe/ixgbe_main.c                 |   20 +-
 drivers/net/ixgbe/ixgbe_type.h                 |    2 +
 drivers/net/mlx4/sense.c                       |    2 +-
 drivers/net/pcmcia/3c574_cs.c                  |    4 +
 drivers/net/pcmcia/3c589_cs.c                  |    4 +
 drivers/net/sfc/selftest.c                     |    2 +-
 drivers/net/sh_eth.c                           |    7 +-
 drivers/net/sky2.c                             |   15 +-
 drivers/net/usb/rtl8150.c                      |    2 +-
 include/linux/can/dev.h                        |    9 +
 include/linux/rtnetlink.h                      |    6 +-
 include/net/dst.h                              |    2 +-
 include/net/ip.h                               |    1 +
 include/net/ipv6.h                             |    8 +
 include/net/netfilter/ipv6/nf_conntrack_ipv6.h |    2 +-
 include/net/tcp.h                              |    3 +-
 net/core/dev.c                                 |   11 +
 net/core/rtnetlink.c                           |    6 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c            |   21 +-
 net/ipv4/syncookies.c                          |   27 +-
 net/ipv4/tcp_input.c                           |   24 +-
 net/ipv4/tcp_ipv4.c                            |   21 +-
 net/ipv4/tcp_minisocks.c                       |   10 +-
 net/ipv4/tcp_output.c                          |   18 +-
 net/ipv4/udp.c                                 |    7 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   19 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c        |    7 +-
 net/ipv6/reassembly.c                          |    5 +-
 net/ipv6/syncookies.c                          |   28 +-
 net/ipv6/tcp_ipv6.c                            |    3 +-
 net/netfilter/ipvs/ip_vs_core.c                |    1 +
 net/netfilter/ipvs/ip_vs_ctl.c                 |    4 +
 net/packet/af_packet.c                         |   71 ++--
 52 files changed, 745 insertions(+), 886 deletions(-)
