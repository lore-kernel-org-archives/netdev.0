From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 11 Jan 2011 16:24:56 -0800 (PST)
Message-ID: <20110111.162456.179272757.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Mostly driver stuff (as usual), a TCP bind fix, some checksum
offloading cures, and random other small bits all over.

1) Fix signedness bugs in phonet, from Dan Carpenter.

2) Sequence number checking fixes in DCCP from Samuel Jero and
   Gerrit Renker.

3) Support both ports of FEC ethernet device properly, from
   Shawn Guo.

4) Memory leak fix in hamradio and ATM ambassador driver from Jesper
   Juhl.

5) MSI interrupt and statistic handling fixes in bnx2x from Vladislav
   Zolotarov and Eilon Greenstein.

6) Autonegotiation and VLAN fixes in sky2 from Stephen Hemminger.

7) Power management fixes in forcedeth from Rafael J. Wysocki.

8) Fix handling of NLM_F_ROOT | NLM_F_MATCH (can be mistaken as
   a NLM_F_DUMP request) in genetlink.  From Jan Engelhardt.

9) Kernel doc fixes in net/sock.h and net/core/filter.c from Randy
   Dunlap

10) Do PHY init, and thus firmware request, at ->open() time to
    workaround bootup 60 second delay when r8169 is built statically
    into the kernel.  From Francois Romieu.

11) Checksumming offload flags are handled improperly, in particular
    when VLAN's are nested.  From Jesse Gross.

12) Various Intel wired driver fixes from Bruce Allan, Jeff Kirsher,
    Dirk Brandewie, Yi Zou, and Alexander Duyck.

13) Software interrupts are disabled way too long when reading counters
    (for "iptables -L" output, for example).  Fix from Eric Dumazet.

14) bfin_mac driver has to disable checksum offloading when a writeback
    cache is in use, since corrupt packets can result, fix from
    Sonic Zhang.

15) Firmware version detection and ethtool diag dixes in qlcnic from
    Amit Kumar Salecha and Sony Chacko.

16) Mailbox register coherency, and ->open() failure unwinding fixes
    in cxgb4vf from Casey Leedom.

17) On user copy failure, we erroneously leave the connection request
    parameter size set, in CAIF protocol.  Fix from Dan Rosenberg.

18) MLX4 driver needs to be able to allocate different numbers of
    TX vs. RX queues, add a helper for that and use it.  From Tom
    Herbert.

19) Only HTB scheduler handles packet counting in statistics properly
    wrt. segmented SKBs.  Fix this by creating a helper function and
    using it everywhere.  From Eric Dumazet.

20) Firewire needs to be able to invalidate specific ARP entries since
    it uses ARP to discover private info about firewiare network nodes.
    From Maxim Levitsky.

21) IPV6 not handled properly in CAIF, fix from Sjur Braendeland and
    Kumar Sanghvi.

22) Firmware parsing function in r8169 needs some minor tweaks, from
    Hayes Wang.

23) TCP binding bug fix from Eric Dumazet.

24) ehea RX ring initialization fix on device up from Breno Leitao.

25) AUTH truncation bug fixes in IPSEC from Nicolas Dichtel.

26) AH protocol header parsing needs to reload pointers after
    skb COW, also from Nicolas Dichtel.

27) Fix netfilter conntrack race between table dumping and destroy of
    entries, from Stephen Hemminger.

28) RCU annotation addition to bridge netfilter broke broute table,
    fix from Florian Westphal.

Please pull, thanks a lot!

The following changes since commit 0c21e3aaf6ae85bee804a325aa29c3252091=
80fd:

  Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kernel/=
git/hch/hfsplus (2011-01-07 17:16:27 -0800)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (3):
      ixgbe: cleanup flow director hash computation to improve performa=
nce
      ixgbe: further flow director performance optimizations
      ixgbe: update ntuple filter configuration

Breno Leitao (1):
      ehea: Increase the skb array usage

Bruce Allan (6):
      e1000e: cleanup variables set but not used
      e1000e: convert calls of ops.[read|write]_reg to e1e_[r|w]phy
      e1000e: properly bounds-check string functions
      e1000e: use either_crc_le() rather than re-write it
      e1000e: power off PHY after reset when interface is down
      e1000e: add custom set_d[0|3]_lplu_state function pointer for 825=
74

Casey Leedom (2):
      cxgb4vf: fix mailbox data/control coherency domain race
      cxgb4vf: recover from failure in cxgb4vf_open()

Changli Gao (1):
      net: ppp: use {get,put}_unaligned_be{16,32}

Dan Carpenter (1):
      phonet: some signedness bugs

Dan Rosenberg (1):
      caif: don't set connection request param size before copying data

Dang Hongwu (1):
      ah: reload pointers to skb data after calling skb_cow_data()

David S. Miller (2):
      Merge branch 'dccp' of git://eden-feed.erg.abdn.ac.uk/net-next-2.=
6
      Merge branch 'master' of git://1984.lsi.us.es/net-2.6

Dirk Brandewie (1):
      e1000: Add support for the CE4100 reference platform

Eric Dumazet (3):
      netfilter: x_tables: dont block BH while reading counters
      net_sched: factorize qdisc stats handling
      tcp: disallow bind() to reuse addr/port

=46lorian Westphal (1):
      netfilter: ebtables: make broute table work again

Gerrit Renker (1):
      dccp: make upper bound for seq_window consistent on 32/64 bit

Jan Engelhardt (1):
      netlink: test for all flags of the NLM_F_DUMP composite

Jesper Juhl (2):
      hamradio: Resolve memory leak due to missing firmware release in =
add_mcs()
      Madge Ambassador ATM Adapter driver: Always release_firmware() in=
 ucode_init() and don't leak memory.

Jesse Gross (6):
      net offloading: Accept NETIF_F_HW_CSUM for all protocols.
      net offloading: Generalize netif_get_vlan_features().
      net offloading: Pass features into netif_needs_gso().
      net offloading: Convert dev_gso_segment() to use precomputed feat=
ures.
      net offloading: Convert skb_need_linearize() to use precomputed f=
eatures.
      net offloading: Convert checksums to use centrally computed featu=
res.

Ken Kawasaki (1):
      pcnet_cs: add new_id

Kumar Sanghvi (1):
      CAIF: Fix IPv6 support in receive path for GPRS/3G

Maxim Levitsky (1):
      arp: allow to invalidate specific ARP entries

Mike Frysinger (4):
      netdev: bfin_mac: clean up printk messages
      netdev: bfin_mac: mark setup_system_regs as static
      netdev: bfin_mac: drop unused Mac data
      netdev: bfin_mac: let boards set vlan masks

Nicolas Dichtel (2):
      xfrm: check trunc_len in XFRMA_ALG_AUTH_TRUNC
      ah: update maximum truncated ICV length

Rafael J. Wysocki (1):
      forcedeth: Do not use legacy PCI power management

Randy Dunlap (2):
      net/sock.h: make some fields private to fix kernel-doc warning(s)
      net: fix kernel-doc warning in core/filter.c

Samuel Jero (2):
      dccp: fix return value for sequence-invalid packets
      dccp: fix bug in updating the GSR

Shawn Guo (6):
      net/fec: fix MMFR_OP type in fec_enet_mdio_write
      net/fec: remove the use of "index" which is legacy
      net/fec: add mac field into platform data and consolidate fec_get=
_mac
      net/fec: improve pm for better suspend/resume
      net/fec: add dual fec support for mx28
      net/fec: remove config FEC2 as it's used nowhere

Sonic Zhang (1):
      netdev: bfin_mac: disable hardware checksum if writeback cache is=
 enabled

Sony Chacko (1):
      qlcnic: fix ethtool diagnostics test

Stephen Hemminger (3):
      sky2: fix limited auto negotiation
      sky2: convert to new VLAN model (v0.2)
      netfilter: fix race in conntrack between dump_table and destroy

Tom Herbert (2):
      net: Add alloc_netdev_mqs function
      mlx4: Call alloc_etherdev to allocate RX and TX queues

Vladislav Zolotarov (4):
      bnx2x: Don't prevent RSS configuration in INT#x and MSI interrupt=
 modes.
      bnx2x: registers dump fixes
      bnx2x: Move to D0 before clearing MSI/MSI-X configuration.
      bnx2x: Fix the race on bp->stats_pending.

Yi Zou (1):
      ixgbe: make sure per Rx queue is disabled before unmapping the re=
ceive buffer

amit salecha (2):
      qlcnic: fix flash fw version read
      qlcnic: change module parameter permissions

fran=E7ois romieu (1):
      r8169: delay phy init until device opens.

hayeswang (1):
      net/r8169: Update the function of parsing firmware

 Documentation/networking/dccp.txt    |    1 +
 drivers/atm/ambassador.c             |   19 +-
 drivers/net/Kconfig                  |    9 +-
 drivers/net/bfin_mac.c               |   74 ++--
 drivers/net/bfin_mac.h               |   11 +-
 drivers/net/bnx2x/bnx2x.h            |    1 +
 drivers/net/bnx2x/bnx2x_dump.h       |  988 +++++++++++++++++++-------=
-------
 drivers/net/bnx2x/bnx2x_ethtool.c    |   22 +-
 drivers/net/bnx2x/bnx2x_init.h       |  220 ++++++++
 drivers/net/bnx2x/bnx2x_main.c       |   70 +--
 drivers/net/bnx2x/bnx2x_reg.h        |   74 +++
 drivers/net/bnx2x/bnx2x_stats.c      |    5 +
 drivers/net/cxgb4vf/cxgb4vf_main.c   |   15 +-
 drivers/net/cxgb4vf/t4vf_hw.c        |   11 +
 drivers/net/e1000/e1000_hw.c         |  328 +++++++++---
 drivers/net/e1000/e1000_hw.h         |   59 ++-
 drivers/net/e1000/e1000_main.c       |   35 ++
 drivers/net/e1000/e1000_osdep.h      |   19 +-
 drivers/net/e1000e/82571.c           |   77 +++-
 drivers/net/e1000e/e1000.h           |    3 +
 drivers/net/e1000e/es2lan.c          |    4 +-
 drivers/net/e1000e/ethtool.c         |   54 ++-
 drivers/net/e1000e/hw.h              |    1 +
 drivers/net/e1000e/ich8lan.c         |   77 +--
 drivers/net/e1000e/lib.c             |    3 +-
 drivers/net/e1000e/netdev.c          |   53 ++-
 drivers/net/e1000e/phy.c             |   40 +-
 drivers/net/ehea/ehea.h              |    2 +-
 drivers/net/ehea/ehea_main.c         |    6 +-
 drivers/net/fec.c                    |  248 ++++++---
 drivers/net/fec.h                    |    5 +-
 drivers/net/forcedeth.c              |   34 +-
 drivers/net/hamradio/yam.c           |    4 +-
 drivers/net/ixgbe/ixgbe.h            |   21 +-
 drivers/net/ixgbe/ixgbe_82599.c      |  749 ++++++++++----------------
 drivers/net/ixgbe/ixgbe_ethtool.c    |  142 ++++--
 drivers/net/ixgbe/ixgbe_main.c       |  169 +++++--
 drivers/net/ixgbe/ixgbe_type.h       |   91 ++--
 drivers/net/mlx4/en_netdev.c         |    3 +-
 drivers/net/pcmcia/pcnet_cs.c        |    1 +
 drivers/net/ppp_async.c              |   10 +-
 drivers/net/ppp_deflate.c            |    9 +-
 drivers/net/ppp_generic.c            |    9 +-
 drivers/net/ppp_mppe.c               |    7 +-
 drivers/net/ppp_synctty.c            |    3 +-
 drivers/net/qlcnic/qlcnic.h          |   24 +-
 drivers/net/qlcnic/qlcnic_ethtool.c  |    2 +-
 drivers/net/qlcnic/qlcnic_init.c     |   63 +++-
 drivers/net/qlcnic/qlcnic_main.c     |   10 +-
 drivers/net/r8169.c                  |  143 +++++-
 drivers/net/sky2.c                   |  143 +++---
 drivers/net/sky2.h                   |    6 +-
 drivers/net/xen-netfront.c           |    2 +-
 include/linux/bfin_mac.h             |    1 +
 include/linux/etherdevice.h          |    4 +-
 include/linux/fec.h                  |    3 +
 include/linux/if_bridge.h            |    2 +-
 include/linux/netdevice.h            |   24 +-
 include/linux/netfilter/x_tables.h   |   10 +-
 include/net/ah.h                     |    2 +-
 include/net/arp.h                    |    1 +
 include/net/phonet/phonet.h          |    4 +-
 include/net/sch_generic.h            |   20 +-
 include/net/sock.h                   |    4 +
 net/caif/caif_socket.c               |    2 +-
 net/caif/chnl_net.c                  |   18 +-
 net/core/dev.c                       |  149 +++---
 net/core/filter.c                    |    2 +-
 net/core/rtnetlink.c                 |    2 +-
 net/dccp/dccp.h                      |    3 +-
 net/dccp/input.c                     |    2 +-
 net/dccp/sysctl.c                    |    4 +-
 net/ethernet/eth.c                   |   12 +-
 net/ipv4/ah4.c                       |    7 +-
 net/ipv4/arp.c                       |   29 +-
 net/ipv4/inet_connection_sock.c      |    5 +-
 net/ipv4/inet_diag.c                 |    2 +-
 net/ipv4/netfilter/arp_tables.c      |   45 +--
 net/ipv4/netfilter/ip_tables.c       |   45 +--
 net/ipv6/ah6.c                       |    8 +-
 net/ipv6/inet6_connection_sock.c     |    2 +-
 net/ipv6/netfilter/ip6_tables.c      |   45 +--
 net/netfilter/nf_conntrack_netlink.c |   18 +-
 net/netfilter/x_tables.c             |    3 +-
 net/netlink/genetlink.c              |    2 +-
 net/phonet/af_phonet.c               |    6 +-
 net/sched/act_csum.c                 |    3 +-
 net/sched/act_ipt.c                  |    3 +-
 net/sched/act_mirred.c               |    3 +-
 net/sched/act_nat.c                  |    3 +-
 net/sched/act_pedit.c                |    3 +-
 net/sched/act_police.c               |    3 +-
 net/sched/act_simple.c               |    3 +-
 net/sched/act_skbedit.c              |    3 +-
 net/sched/sch_atm.c                  |    6 +-
 net/sched/sch_cbq.c                  |    6 +-
 net/sched/sch_drr.c                  |    8 +-
 net/sched/sch_dsmark.c               |    3 +-
 net/sched/sch_hfsc.c                 |    6 +-
 net/sched/sch_htb.c                  |   17 +-
 net/sched/sch_ingress.c              |    3 +-
 net/sched/sch_multiq.c               |    3 +-
 net/sched/sch_netem.c                |    6 +-
 net/sched/sch_prio.c                 |    3 +-
 net/sched/sch_red.c                  |    3 +-
 net/sched/sch_sfq.c                  |    3 +-
 net/sched/sch_tbf.c                  |    3 +-
 net/sched/sch_teql.c                 |    3 +-
 net/xfrm/xfrm_user.c                 |    6 +-
 109 files changed, 2901 insertions(+), 1867 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
