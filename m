From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 03 Nov 2011 22:40:39 -0400 (EDT)
Message-ID: <20111103.224039.583140439749870987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) NULL crash in x25_recvmsg(), fix from Dave Jones.

2) __alloc_skb() alignments need adjusting for SLOB, fix from Tony Lindgren.

3) l2tp_recv_dequeue() can leave queue in inconsistent state, resulting in
   a subsequent crash, fix from Eric Dumazet.

4) Missing bh_unlock_sock() in inet_csk_route_child_sock(), from Eric
   Dumazet.

5) Build fix for 3c505 driver from Andrew Morton.

6) Fix docbook comment in skbuff.h, from Marcos Paulo de Souza.

7) IPVS netfilter fixes from Krzysztof Wilczynski and Simon Horman.

8) Fix refcount leak in ipv6 netfilter core, from Florian Westphal.

9) Fix multicast/promisc state refcounting bug due to vlan propagating
   flag state changes on downed devices.  Fix from Matthijs Kooijman.

10) Fix build error due to typo in ll_temac driver, from Stephen Rothwell.

11) Fix build of AF_PACKET due to bogus inline prototypes, from Olof
    Johansson.

12) be2net driver bug fixes from Padmanabh Ratnakar.

13) Intel ethernet fixes from Bruce Allan, Jesse Brandeburg, Tomasz Kantecki,
    Emil Tantilov, John Fastabend, and Greg Rose.

Please pull, thanks a lot!

The following changes since commit d6748066ad0e8b2514545998f8367ebb3906f299:

  Merge branch 'upstream' of git://git.linux-mips.org/pub/scm/ralf/upstream-linus (2011-11-03 13:28:14 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Andrew Morton (1):
      drivers/net/ethernet/i825xx/3c505.c: fix build with dynamic debug

Arjan van de Ven (1):
      net: make the tcp and udp file_operations for the /proc stuff const

Bruce Allan (1):
      e1000e: demote a debugging WARN to a debug log message

Cesar Eduardo Barros (1):
      net/ethernet: sc92031 is not Realtek

Dave Jones (1):
      x25: Fix NULL dereference in x25_recvmsg

David S. Miller (2):
      neigh: Kill bogus SMP protected debugging message.
      Merge git://git.kernel.org/.../jkirsher/net

Emil Tantilov (3):
      ixgbe: Fix link issues caused by a reset while interface is down
      ixgbe: fix disabling of Tx laser at probe
      ixgbe: fix reading of the buffer returned by the firmware

Eric Dumazet (3):
      udp: fix a race in encap_rcv handling
      l2tp: fix race in l2tp_recv_dequeue()
      net: add missing bh_unlock_sock() calls

Florian Westphal (2):
      netfilter: ipv6: fix afinfo->route refcnt leak on error
      netfilter: do not propagate nf_queue errors in nf_hook_slow

Geert Uytterhoeven (1):
      net/ethernet: Move mac89x0.c from apple to cirrus

Greg Rose (2):
      ixgbe: Fix compiler warnings
      ixgbevf: Update release version

Jesse Brandeburg (1):
      e100: make sure vlan support isn't advertised on old adapters

Joe Perches (1):
      netfilter: Remove unnecessary OOM logging messages

John Fastabend (2):
      ixgbe: fix smatch splat due to missing NULL check
      ixgbe: DCB, return max for IEEE traffic classes

Kantecki, Tomasz (1):
      igb: Fix for I347AT4 PHY cable length unit detection

Krzysztof Wilczynski (3):
      ipvs: Expose ip_vs_ftp module parameters via sysfs.
      ipvs: Remove unused variable "cs" from ip_vs_leave function.
      ipvs: Fix compilation error in ip_vs.h for ip_vs_confirm_conntrack function.

Marcos Paulo de Souza (1):
      include: linux: skbuf.h: Fix parameter documentation

Matthijs Kooijman (1):
      vlan: Don't propagate flag changes on down interfaces.

Oliver Hartkopp (1):
      MAINTAINERS: Add can-gw include to maintained files

Olof Johansson (1):
      af_packet: de-inline some helper functions

Pablo Neira Ayuso (2):
      netfilter: export NAT definitions through linux/netfilter_ipv4/nf_nat.h
      MAINTAINERS: update netfilter maintainers

Padmanabh Ratnakar (4):
      be2net: Fix endian issue in RX filter command
      be2net: Fix disabling multicast promiscous mode
      be2net: Prevent CQ full condition for Lancer
      be2net: Add detect UE feature for Lancer

Paul Bolle (1):
      isdn: hisax: Fix typo 'HISAX_DE_AOC'

Simon Horman (6):
      ipvs: Add documentation for new sysctl entries
      ipvs: Remove unused parameter from ip_vs_confirm_conntrack()
      ipvs: Remove unused return value of protocol state transitions
      ipvs: Removed unused variables
      ipvs: secure_tcp does provide alternate state timeouts
      ipvs: Enhance grammar used to refer to Kconfig options

Stephen Rothwell (1):
      net: fix typo in drivers/net/ethernet/xilinx/ll_temac_main.c

Tony Lindgren (1):
      net: Add back alignment for size for __alloc_skb

Weiping Pan (1):
      bonding:update speed/duplex for NETDEV_CHANGE

 Documentation/networking/ipvs-sysctl.txt          |   62 +++++++++++++++++--
 MAINTAINERS                                       |    5 +-
 drivers/isdn/hisax/l3dss1.c                       |    6 +-
 drivers/net/bonding/bond_main.c                   |   37 ++++--------
 drivers/net/bonding/bond_procfs.c                 |   12 +++-
 drivers/net/ethernet/Kconfig                      |    1 +
 drivers/net/ethernet/Makefile                     |    1 +
 drivers/net/ethernet/apple/Kconfig                |   12 ----
 drivers/net/ethernet/apple/Makefile               |    1 -
 drivers/net/ethernet/cirrus/Kconfig               |   14 ++++-
 drivers/net/ethernet/cirrus/Makefile              |    1 +
 drivers/net/ethernet/{apple => cirrus}/mac89x0.c  |    0
 drivers/net/ethernet/emulex/benet/be_cmds.c       |   12 +++-
 drivers/net/ethernet/emulex/benet/be_hw.h         |    2 +
 drivers/net/ethernet/emulex/benet/be_main.c       |   68 +++++++++++++-------
 drivers/net/ethernet/i825xx/3c505.c               |    6 +-
 drivers/net/ethernet/intel/e100.c                 |    4 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c       |    3 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c        |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   |   20 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c   |   10 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   48 ++++++---------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h    |    2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 drivers/net/ethernet/realtek/Kconfig              |   12 ----
 drivers/net/ethernet/realtek/Makefile             |    1 -
 drivers/net/ethernet/silan/Kconfig                |   33 ++++++++++
 drivers/net/ethernet/silan/Makefile               |    5 ++
 drivers/net/ethernet/{realtek => silan}/sc92031.c |    0
 drivers/net/ethernet/xilinx/ll_temac_main.c       |    4 +-
 include/linux/netfilter_ipv4/Kbuild               |    1 +
 include/linux/netfilter_ipv4/nf_nat.h             |   58 ++++++++++++++++++
 include/linux/skbuff.h                            |    4 +-
 include/net/ip_vs.h                               |   11 ++--
 include/net/netfilter/nf_conntrack_tuple.h        |   27 +--------
 include/net/netfilter/nf_nat.h                    |   26 +--------
 include/net/tcp.h                                 |   10 ++-
 include/net/udp.h                                 |   12 ++--
 net/8021q/vlan_dev.c                              |   10 ++-
 net/bridge/netfilter/ebt_ulog.c                   |    7 +-
 net/core/neighbour.c                              |    6 +--
 net/core/skbuff.c                                 |    1 +
 net/dccp/ipv4.c                                   |    1 +
 net/ipv4/netfilter/ipt_CLUSTERIP.c                |    1 -
 net/ipv4/netfilter/ipt_ULOG.c                     |    4 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c            |   22 +------
 net/ipv4/tcp_ipv4.c                               |   23 ++++---
 net/ipv4/udp.c                                    |   30 +++++----
 net/ipv4/udplite.c                                |   13 +++-
 net/ipv6/netfilter.c                              |   13 +++-
 net/ipv6/netfilter/nf_conntrack_reasm.c           |    7 +-
 net/ipv6/tcp_ipv6.c                               |   12 +++-
 net/ipv6/udp.c                                    |   12 +++-
 net/ipv6/udplite.c                                |   13 +++-
 net/l2tp/l2tp_core.c                              |    3 +-
 net/netfilter/core.c                              |   11 ++--
 net/netfilter/ipset/ip_set_core.c                 |    4 +-
 net/netfilter/ipvs/ip_vs_core.c                   |   20 +++---
 net/netfilter/ipvs/ip_vs_ctl.c                    |   22 ++-----
 net/netfilter/ipvs/ip_vs_dh.c                     |    5 +-
 net/netfilter/ipvs/ip_vs_ftp.c                    |    5 +-
 net/netfilter/ipvs/ip_vs_lblc.c                   |    9 +--
 net/netfilter/ipvs/ip_vs_lblcr.c                  |   13 +---
 net/netfilter/ipvs/ip_vs_nfct.c                   |    2 +-
 net/netfilter/ipvs/ip_vs_proto.c                  |    5 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c             |   14 +---
 net/netfilter/ipvs/ip_vs_proto_tcp.c              |    6 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c              |    5 +-
 net/netfilter/ipvs/ip_vs_sh.c                     |    5 +-
 net/netfilter/ipvs/ip_vs_wrr.c                    |    5 +-
 net/netfilter/ipvs/ip_vs_xmit.c                   |    2 +-
 net/netfilter/nf_conntrack_core.c                 |    5 +-
 net/netfilter/nfnetlink_log.c                     |    7 +--
 net/netfilter/xt_IDLETIMER.c                      |    2 -
 net/netfilter/xt_hashlimit.c                      |    5 +-
 net/packet/af_packet.c                            |   52 ++++++++--------
 net/x25/af_x25.c                                  |   11 +++-
 77 files changed, 506 insertions(+), 422 deletions(-)
 rename drivers/net/ethernet/{apple => cirrus}/mac89x0.c (100%)
 create mode 100644 drivers/net/ethernet/silan/Kconfig
 create mode 100644 drivers/net/ethernet/silan/Makefile
 rename drivers/net/ethernet/{realtek => silan}/sc92031.c (100%)
 create mode 100644 include/linux/netfilter_ipv4/nf_nat.h
