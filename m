From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 31 Jul 2015 16:08:06 -0700 (PDT)
Message-ID: <20150731.160806.1271603628986513420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Must tearodnw SR-IOV before unregistering netdev in igb driver, from
   Alex Williamson.

2) Fix ipv6 route unreachable crash in IPVS, from Alex Gartrell.

3) Default route selection in ipv4 should take the prefix length,
   table ID, and TOS into account, from Julian Anastasov.

4) sch_plug must have a reset method in order to purge all buffered
   packets when the qdisc is reset, likewise for sch_choke, from WANG
   Cong.

5) Fix deadlock and races in slave_changelink/br_setport in bridging.
   From Nikolay Aleksandrov.

6) mlx4 bug fixes (wrong index in port even propagation to VFs,
   overzealous BUG_ON assertion, etc.) from Ido Shamay, Jack
   Morgenstein, and Or Gerlitz.

7) Turn off klog message about SCTP userspace interface compat that makes
   no sense at all, from Daniel Borkmann.

8) Fix unbounded restarts of inet frag eviction process, causing NMI
   watchdog soft lockup messages, from Florian Westphal.

9) Suspend/resume fixes for r8152 from Hayes Wang.

10) Fix busy loop when MSG_WAITALL|MSG_PEEK is used in TCP recv, from
    Sabrina Dubroca.

11) Fix performance regression when removing a lot of routes from the
    ipv4 routing tables, from Alexander Duyck.

12) Fix device leak in AF_PACKET, from Lars Westerhoff.

13) AF_PACKET also has a header length comparison bug due to signedness,
    from Alexander Drozdov.

14) Fix bug in EBPF tail call generation on x86, from Daniel Borkmann.

15) Memory leaks, TSO stats, watchdog timeout and other fixes to thunderx
    driver from Sunil Goutham and Thanneeru Srinivasulu.

16) act_bpf can leak memory when replacing programs, from Daniel
    Borkmann.

17) WOL packet fixes in gianfar driver, from Claudiu Manoil.

Please pull, thanks a lot.

The following changes since commit c5dfd654d0ec0a28fe81e7bd4d4fd984a9855e09:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-07-22 14:45:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to ea111545843e657504193e4f726e1116b96b8141:

  stmmac: fix missing MODULE_LICENSE in stmmac_platform (2015-07-31 15:44:24 -0700)

----------------------------------------------------------------
Alex Gartrell (2):
      ipvs: fix ipv6 route unreach panic
      ipvs: skb_orphan in case of forwarding

Alexander Drozdov (1):
      packet: tpacket_snd(): fix signed/unsigned comparison

Alexander Duyck (1):
      fib_trie: Drop unnecessary calls to leaf_pull_suffix

Andrew Lunn (1):
      net: fec: Ensure clocks are enabled while using mdio bus

Andy Shevchenko (6):
      net/macb: improve big endian CPU support
      net/macb: check if macb_config present
      net/macb: use dev_*() when netdev is not yet registered
      net/macb: suppress compiler warnings
      net/macb: replace macb_count_tx_descriptors() by DIV_ROUND_UP()
      net/macb: convert to kernel doc

Claudiu Manoil (3):
      gianfar: Fix warning when CONFIG_PM off
      gianfar: Fix suspend/resume for wol magic packet
      gianfar: Enable device wakeup when appropriate

Daniel Borkmann (4):
      net: sctp: stop spamming klog with rfc6458, 5.3.2. deprecation warnings
      ebpf, x86: fix general protection fault when tail call is invoked
      act_bpf: fix memory leaks when replacing bpf programs
      net: sched: fix refcount imbalance in actions

David S. Miller (12):
      Merge branch 'fib_select_default-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'mlx4-fixes'
      Merge branch 'inet-frag-fixes'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'r8152-fixes'
      Merge branch 'macb-fixes'
      macb: Fix build with macro'ized readl/writel.
      Merge branch 'netcp-fixes'
      Merge branch 'thunderx-fixes'
      Merge branch 'r8152-fixes'
      Merge branch 'gianfar-wol-fixes'

David Ward (1):
      net/ipv4: suppress NETDEV_UP notification on address lifetime update

Dmitry Torokhov (1):
      netfilter: IDLETIMER: fix lockdep warning

Eric Dumazet (2):
      arp: filter NOARP neighbours for SIOCGARP
      ipv6: flush nd cache on IFF_NOARP change

Florian Westphal (3):
      inet: frag: don't re-use chainlist for evictor
      inet: frag: change *_frag_mem_limit functions to take netns_frags as argument
      inet: frag: don't wait for timer deletion when evicting

Ido Shamay (1):
      net/mlx4_en: Remove BUG_ON assert when checking if ring is full

Ivan Vecera (1):
      macvtap: fix network header pointer for VLAN tagged pkts

Jack Morgenstein (2):
      net/mlx4_core: Fix wrong index in propagating port change event to VFs
      net/mlx4_core: Relieve cpu load average on the port sending flow

Jiri Pirko (1):
      niu: don't count tx error twice in case of headroom realloc fails

Joachim Eastwood (1):
      stmmac: fix missing MODULE_LICENSE in stmmac_platform

Joe Stringer (1):
      netfilter: nf_conntrack: Support expectations in different zones

Johan Hedberg (1):
      Bluetooth: Fix NULL pointer dereference in smp_conn_security

Julian Anastasov (6):
      ipvs: do not use random local source address for tunnels
      ipvs: fix crash if scheduler is changed
      ipvs: fix crash with sync protocol v0 and FTP
      ipvs: call skb_sender_cpu_clear
      ipv4: fib_select_default should match the prefix
      ipv4: consider TOS in fib_select_default

Karicheri, Muralidharan (3):
      net: netcp: fix cleanup interface list in netcp_remove()
      net: netcp: ethss: fix up incorrect use of list api
      net: netcp: ethss: cleanup gbe_probe() and gbe_remove() functions

Konstantin Khlebnikov (1):
      cgroup: net_cls: fix false-positive "suspicious RCU usage"

Lars Westerhoff (1):
      packet: missing dev_put() in packet_do_bind()

Lucas Stach (2):
      net: fec: use managed DMA API functions to allocate BD ring
      net: fec: introduce fec_ptp_stop and use in probe fail path

Nikolay Aleksandrov (4):
      bridge: netlink: fix slave_changelink/br_setport race conditions
      inet: frags: remove INET_FRAG_EVICTED and use list_evictor for the test
      bridge: stp: when using userspace stp stop kernel hello and hold timers
      bridge: mdb: fix delmdb state in the notification

Or Gerlitz (1):
      net/mlx4_core: Use sink counter for the VF default as fallback

Pablo Neira Ayuso (3):
      netfilter: ctnetlink: put back references to master ct and expect objects
      netfilter: fix netns dependencies with conntrack templates
      Merge tag 'ipvs-fixes-for-v4.2' of https://git.kernel.org/.../horms/ipvs

Sabrina Dubroca (1):
      tcp: fix recv with flags MSG_WAITALL | MSG_PEEK

Satish Ashok (1):
      bridge: mcast: give fast leave precedence over multicast router and querier

Shahed Shaikh (1):
      qlcnic: Fix corruption while copying

Sowmini Varadhan (1):
      net: sk_clone_lock() should only do get_net() if the parent is not a kernel socket

Sunil Goutham (10):
      net: thunderx: Fix data integrity issues with LDWB
      net: thunderx: Fix memory leak while tearing down interface
      net: thunderx: Fix RQ_DROP miscalculation
      net: thunderx: Fix memory leak when changing queue count
      net: thunderx: Fix TSO packet statistic
      net: thunderx: Suppress alloc_pages() failure warnings
      net: thunderx: Wakeup TXQ only if CQE_TX are processed
      net: thunderx: Set watchdog timeout value
      net: thunderx: Fix crash when changing rss with mutliple traffic flows
      net: thunderx: Add PCI driver shutdown routine

Thanneeru Srinivasulu (1):
      net: thunderx: Fix for crash while BGX teardown

Toshiaki Makita (1):
      bridge: Fix network header pointer for vlan tagged packets

WANG Cong (3):
      sch_plug: purge buffered packets during reset
      sch_choke: drop all packets in queue during reset
      act_pedit: check binding before calling tcf_hash_release()

WingMan Kwok (1):
      net: netcp: Fixes SGMII reset on network interface shutdown

hayeswang (5):
      r8152: fix the issue about U1/U2
      r8152: fix wakeup settings
      r8152: don't enable napi before rx ready
      r8152: add pre_reset and post_reset
      r8152: reset device when tx timeout

 arch/x86/net/bpf_jit_comp.c                           |   8 ++--
 drivers/net/ethernet/cadence/macb.c                   | 125 ++++++++++++++++++++++++++++++++++++++++---------------------
 drivers/net/ethernet/cadence/macb.h                   |  34 +++++++----------
 drivers/net/ethernet/cavium/thunder/nic.h             |  12 +++++-
 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c   |  26 ++++++++-----
 drivers/net/ethernet/cavium/thunder/nicvf_main.c      |  55 +++++++++++++++++++--------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c    |  17 ++++++---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h    |  14 +++++--
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c     |   5 ++-
 drivers/net/ethernet/freescale/fec.h                  |   1 +
 drivers/net/ethernet/freescale/fec_main.c             |  98 +++++++++++++++++++++++++++++++++++++++---------
 drivers/net/ethernet/freescale/fec_ptp.c              |  10 +++++
 drivers/net/ethernet/freescale/gianfar.c              | 104 ++++++++++++++++-----------------------------------
 drivers/net/ethernet/freescale/gianfar.h              |   3 --
 drivers/net/ethernet/freescale/gianfar_ethtool.c      |   5 +--
 drivers/net/ethernet/mellanox/mlx4/cmd.c              |  17 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c            |   1 -
 drivers/net/ethernet/mellanox/mlx4/eq.c               |   4 +-
 drivers/net/ethernet/mellanox/mlx4/main.c             |   5 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c |   2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |   4 ++
 drivers/net/ethernet/sun/niu.c                        |   4 +-
 drivers/net/ethernet/ti/netcp.h                       |   1 +
 drivers/net/ethernet/ti/netcp_core.c                  |  14 +++++--
 drivers/net/ethernet/ti/netcp_ethss.c                 |  67 ++++++++++++++++++---------------
 drivers/net/ethernet/ti/netcp_sgmii.c                 |  30 ++++++++++++++-
 drivers/net/macvtap.c                                 |   7 ++++
 drivers/net/usb/r8152.c                               | 189 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--------------------------
 include/linux/platform_data/macb.h                    |  14 +++++--
 include/net/act_api.h                                 |   8 +++-
 include/net/inet_frag.h                               |  17 ++++++---
 include/net/ip_fib.h                                  |   3 +-
 include/net/netfilter/nf_conntrack.h                  |   2 +-
 include/net/netns/conntrack.h                         |   1 -
 include/net/sock.h                                    |   2 +-
 net/bluetooth/smp.c                                   |   4 ++
 net/bridge/br_forward.c                               |  29 ++++++++++----
 net/bridge/br_mdb.c                                   |   1 +
 net/bridge/br_multicast.c                             |  50 +++++++++++++------------
 net/bridge/br_netlink.c                               |  10 ++++-
 net/bridge/br_stp.c                                   |   5 ++-
 net/bridge/br_stp_if.c                                |  13 ++++++-
 net/bridge/br_stp_timer.c                             |   4 +-
 net/core/netclassid_cgroup.c                          |   3 +-
 net/core/sock.c                                       |   8 ++--
 net/dccp/proto.c                                      |   2 +-
 net/ieee802154/6lowpan/reassembly.c                   |   6 +--
 net/ipv4/arp.c                                        |  16 ++++----
 net/ipv4/devinet.c                                    |   1 -
 net/ipv4/fib_lookup.h                                 |   1 +
 net/ipv4/fib_semantics.c                              |  41 ++++++++++++++------
 net/ipv4/fib_trie.c                                   |   7 +---
 net/ipv4/inet_fragment.c                              |  40 ++++++++------------
 net/ipv4/ip_fragment.c                                |  12 +++---
 net/ipv4/route.c                                      |   2 +-
 net/ipv4/tcp.c                                        |  11 ++++--
 net/ipv6/ndisc.c                                      |   6 +++
 net/ipv6/netfilter/nf_conntrack_reasm.c               |   6 +--
 net/ipv6/reassembly.c                                 |   8 ++--
 net/llc/af_llc.c                                      |   4 +-
 net/netfilter/ipvs/ip_vs_core.c                       |  16 +++++++-
 net/netfilter/ipvs/ip_vs_ctl.c                        |  78 ++++++++++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_sched.c                      |  12 +++---
 net/netfilter/ipvs/ip_vs_sync.c                       |   2 +-
 net/netfilter/ipvs/ip_vs_xmit.c                       |  41 +++++++++++++++++++-
 net/netfilter/nf_conntrack_core.c                     |  67 +++++++++++++++++++++------------
 net/netfilter/nf_conntrack_expect.c                   |   3 +-
 net/netfilter/nf_conntrack_netlink.c                  |   5 ---
 net/netfilter/nf_synproxy_core.c                      |   7 ++--
 net/netfilter/xt_CT.c                                 |   8 ++--
 net/netfilter/xt_IDLETIMER.c                          |   1 +
 net/packet/af_packet.c                                |  11 +++---
 net/sched/act_api.c                                   |  11 +++---
 net/sched/act_bpf.c                                   |  53 +++++++++++++++++---------
 net/sched/act_pedit.c                                 |   5 +--
 net/sched/sch_choke.c                                 |  13 +++++++
 net/sched/sch_plug.c                                  |   1 +
 net/sctp/socket.c                                     |   6 ---
 78 files changed, 1000 insertions(+), 539 deletions(-)
