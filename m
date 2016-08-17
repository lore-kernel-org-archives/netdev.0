From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 17 Aug 2016 19:58:10 -0400 (EDT)
Message-ID: <20160817.195810.1387252255569831383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Buffers powersave frame test is reversed in cfg80211, fix from
   Felix Fietkau.

2) Remove bogus WARN_ON in openvswitch, from Jarno Rajahalme.

3) Fix some tg3 ethtool logic bugs, and one that would cause no
   interrupts to be generated when rx-coalescing is set to 0.
   From Satish Baddipadige and Siva Reddy Kallam.

4) QLCNIC mailbox corruption and napi budget handling fix from
   Manish Chopra.

5) Fix fib_trie logic when walking the trie during /proc/net/route
   output than can access a stale node pointer.  From David Forster.

6) Several sctp_diag fixes from Phil Sutter.

7) PAUSE frame handling fixes in mlxsw driver from Ido Schimmel.

8) Checksum fixup fixes in bpf from Daniel Borkmann.

9) Memork leaks in nfnetlink, from Liping Zhang.

10) Use after free in rxrpc, from David Howells.

11) Use after free in new skb_array code of macvtap driver, from
    Jason Wang.

12) Calipso resource leak, from Colin Ian King.

13) mediatek bug fixes (missing stats sync init, etc.) from Sean Wang.

14) Fix bpf non-linear packet write helpers, from Daniel Borkmann.

15) Fix lockdep splats in macsec, from Sabrina Dubroca.

16) hv_netvsc bug fixes from Vitaly Kuznetsov, mostly to do with
    VF handling.

17) Various tc-action bug fixes, from CONG Wang.

Please pull, thanks a lot!

The following changes since commit bf0f500bd0199aab613eb0ecb3412edd5472740d:

  Merge tag 'trace-v4.8-1' of git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-trace (2016-08-03 12:50:06 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to b96c22c071eb1126db4055de4bb75b02b05affd1:

  Merge branch 'tc_action-fixes' (2016-08-17 19:27:58 -0400)

----------------------------------------------------------------
Alexander Duyck (2):
      ixgbe: Force VLNCTRL.VFE to be set in all VMDq paths
      ixgbe: Re-enable ability to toggle VLAN filtering

Alexei Starovoitov (2):
      bpf: restore behavior of bpf_map_update_elem
      samples/bpf: add bpf_map_update_elem() tests

Arnd Bergmann (3):
      net: xgene: fix maybe-uninitialized variable
      rxrpc: fix uninitialized pointer dereference in debug code
      dsa: mv88e6xxx: hide unused functions

Christophe Leroy (1):
      netfilter: nf_conntrack_sip: CSeq 0 is a valid CSeq

Colin Ian King (2):
      cfg80211: fix missing break in NL8211_CHAN_WIDTH_80P80 case
      calipso: fix resource leak on calipso_genopt failure

Daniel Borkmann (5):
      bpf: also call skb_postpush_rcsum on xmit occasions
      bpf: fix checksum fixups on bpf_skb_store_bytes
      bpf: fix checksum for vlan push/pop helper
      bpf: fix bpf_skb_in_cgroup helper naming
      bpf: fix write helpers with regards to non-linear parts

Dave Ertman (1):
      i40e: check for and deal with non-contiguous TCs

David Forster (1):
      ipv4: panic in leaf_walk_rcu due to stale node pointer

David Howells (6):
      rxrpc: Fix races between skb free, ACK generation and replying
      rxrpc: Need to flag call as being released on connect failure
      rxrpc: Don't access connection from call if pointer is NULL
      rxrpc: Once packet posted in data_ready, don't retry posting
      rxrpc: Fix a use-after-push in data_ready handler
      rxrpc: Free packets discarded in data_ready

David S. Miller (14):
      Merge branch 'tg3-fixes'
      Merge branch 'qlcnic-fixes'
      Merge tag 'mac80211-for-davem-2016-08-05' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'sctp_diag-fixes'
      Merge branch 'mlxsw-dcb-fixes'
      Merge branch 'bpf-csum-complete'
      Merge branch 'qed-fixes'
      Merge tag 'rxrpc-fixes-20160809' of git://git.kernel.org/.../dhowells/linux-fs
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'hv_netvsc-VF-removal-fixes'
      Merge branch 'mediatek-fixes'
      Merge branch 'mlxsw-fixes'
      Merge branch '1GbE' of git://git.kernel.org/.../jkirsher/net-queue
      Merge branch 'tc_action-fixes'

Elad Raz (1):
      mlxsw: spectrum: Add missing packet traps

Fabian Frederick (1):
      net: hns: fix typo in g_gmac_stats_string[]

Felix Fietkau (2):
      mac80211: fix check for buffered powersave frames with txq
      mac80211: fix purging multicast PS buffer queue

Florian Westphal (1):
      rhashtable: avoid large lock-array allocations

Geert Uytterhoeven (1):
      net: dsa: b53: Add missing ULL suffix for 64-bit constant

Grygorii Strashko (1):
      drivers: net: cpsw: fix kmemleak false-positive reports for sk buffers

Harini Katakam (1):
      net: macb: Correct CAPS mask

Ian Wienand (1):
      OVS: Ignore negative headroom value

Ido Schimmel (11):
      mlxsw: spectrum: Do not assume PAUSE frames are disabled
      mlxsw: spectrum: Do not override PAUSE settings
      mlxsw: spectrum: Add missing DCB rollback in error path
      mlxsw: spectrum: Don't return upon error in removal path
      mlxsw: spectrum: Remove redundant errors from the code
      mlxsw: spectrum: Create PVID vPort before registering netdevice
      mlxsw: spectrum: Mark port as active before registering it
      mlxsw: spectrum: Trap loop-backed packets
      mlxsw: spectrum: Add missing rollbacks in error path
      mlxsw: spectrum: Unmap 802.1Q FID before destroying it
      mlxsw: spectrum: Allow packets to be trapped from any PG

Jakub Kicinski (1):
      bpf: fix method of PTR_TO_PACKET reg id generation

Jarno Rajahalme (1):
      openvswitch: Remove incorrect WARN_ONCE().

Jarod Wilson (2):
      e1000e: factor out systim sanitization
      e1000e: fix PTP on e1000_pch_lpt variants

Jason Wang (1):
      macvtap: fix use after free for skb_array during release

Jiri Pirko (1):
      mlxsw: reg: Fix missing op field fill-up

Johannes Berg (1):
      ipv6: suppress sparse warnings in IP6_ECN_set_ce()

Kshitiz Gupta (1):
      igb: fix adjusting PTP timestamps for Tx/Rx latency

Lance Richardson (1):
      vti: flush x-netns xfrm cache when vti interface is removed

Laura Garcia Liebana (1):
      netfilter: nft_exthdr: Add size check on u8 nft_exthdr attributes

Liping Zhang (5):
      netfilter: nf_ct_h323: do not re-activate already expired timer
      netfilter: nf_ct_expect: remove the redundant slash when policy name is empty
      netfilter: nfnetlink_queue: fix memory leak when attach expectation successfully
      netfilter: nfnetlink_queue: reject verdict request from different portid
      netfilter: ctnetlink: reject new conntrack request with different l4proto

Lorenzo Colitti (1):
      net: ipv6: Fix ping to link-local addresses.

Maital Hahn (1):
      mac80211: mesh: flush stations before beacons are stopped

Manish Chopra (3):
      qlcnic: fix data structure corruption in async mbx command handling
      qlcnic: fix napi budget alteration
      qlcnic: Update version to 5.3.65

Martynas Pumputis (1):
      openvswitch: do not ignore netdev errors when creating tunnel vports

Masashi Honma (2):
      mac80211: End the MPSP even if EOSP frame was not acked
      nl80211: correct checks for NL80211_MESHCONF_HT_OPMODE value

Maxim Altshul (1):
      mac80211: Add ieee80211_hw pointer to get_expected_throughput

Mike Manning (1):
      net: ipv6: Do not keep IPv6 addresses when IPv6 is disabled

Pablo Neira Ayuso (2):
      netfilter: nf_tables: s/MFT_REG32_01/NFT_REG32_01
      netfilter: nft_rbtree: ignore inactive matching element with no descendants

Parthasarathy Bhuvaragan (1):
      tipc: fix variable dereference before NULL check

Paul Gortmaker (1):
      net/ethernet: tundra: fix dump_eth_one warning in tsi108_eth

Phil Sutter (4):
      sctp: Export struct sctp_info to userspace
      sctp_diag: Fix T3_rtx timer export
      sctp_diag: Respect ss adding TCPF_CLOSE to idiag_states
      rhashtable-test: Fix max_size parameter description

Roman Mashak (1):
      net_sched: allow flushing tc police actions

Sabrina Dubroca (3):
      macsec: use after free when deleting the underlying device
      macsec: fix lockdep splats when nesting devices
      net: remove type_check from dev_get_nest_level()

Satish Baddipadige (1):
      tg3: Fix for diasllow rx coalescing time to be 0

Simon Horman (1):
      gre: set inner_protocol on xmit

Siva Reddy Kallam (1):
      tg3: Report the correct number of RSS queues through tg3_get_rxnfc

Sudarsana Reddy Kalluru (4):
      qed: Remove the endian-ness conversion for pri_to_tc value.
      qed: Use ieee mfw-mask to get ethtype in ieee-dcbx mode.
      qed: Add dcbx app support for IEEE Selection Field.
      qed: Update app count when adding a new dcbx app entry to the table.

Sylwester Nawrocki (1):
      dm9000: Fix irq trigger type setup on non-dt platforms

Toshiaki Makita (1):
      bridge: Fix problems around fdb entries pointing to the bridge device

Vegard Nossum (4):
      net/irda: handle iriap_register_lsap() allocation failure
      net/sctp: always initialise sctp_ht_iter::start_fail
      rhashtable: fix shift by 64 when shrinking
      tipc: fix NULL pointer dereference in shutdown()

Vincent (1):
      mlxsw: spectrum_router: Fix use after free

Vitaly Kuznetsov (5):
      hv_netvsc: don't lose VF information
      hv_netvsc: avoid deadlocks between rtnl lock and vf_use_cnt wait
      hv_netvsc: reset vf_inject on VF removal
      hv_netvsc: protect module refcount by checking net_device_ctx->vf_netdev
      hv_netvsc: fix bonding devices check in netvsc_netdev_event()

WANG Cong (6):
      net_sched: remove the leftover cleanup_a()
      net_sched: remove an unnecessary list_del()
      net_sched: fix a typo in tc_for_each_action()
      net_sched: move tc offload macros to pkt_cls.h
      net_sched: convert tcf_exts from list to pointer array
      net_sched: unify the init logic for act_police

Wei Yongjun (1):
      net: arc_emac: add missing of_node_put() in arc_emac_probe()

Wenyou Yang (1):
      net: phy: micrel: Add specific suspend

Xin Long (1):
      sctp: use event->chunk when it's valid

Zhu Yanjun (1):
      bonding: fix the typo

pravin shelar (2):
      net: vxlan: lwt: Use source ip address during route lookup.
      net: vxlan: lwt: Fix vxlan local traffic.

sean.wang@mediatek.com (5):
      net: ethernet: mediatek: fixed that initializing u64_stats_sync is missing
      net: ethernet: mediatek: add the missing of_node_put() after node is used done
      net: ethernet: mediatek: fix RMII mode and add REVMII supported by GMAC
      net: ethernet: mediatek: fix flow control settings on GMAC0 is not being enabled properly
      net: ethernet: mediatek: fix runtime warning raised by inconsistent struct device pointers passed to DMA API

 Documentation/networking/rxrpc.txt                       |  21 +++---
 drivers/net/bonding/bond_main.c                          |   2 +-
 drivers/net/dsa/b53/b53_regs.h                           |   2 +-
 drivers/net/dsa/mv88e6xxx/chip.c                         |   2 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c           |   2 +
 drivers/net/ethernet/arc/emac_main.c                     |   6 +-
 drivers/net/ethernet/broadcom/tg3.c                      |   5 +-
 drivers/net/ethernet/cadence/macb.h                      |   2 +-
 drivers/net/ethernet/davicom/dm9000.c                    |   8 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c       |   2 +-
 drivers/net/ethernet/intel/e1000e/82571.c                |   6 +-
 drivers/net/ethernet/intel/e1000e/e1000.h                |   1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c              |   3 +-
 drivers/net/ethernet/intel/e1000e/netdev.c               |  66 +++++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_main.c              |  35 +++++++---
 drivers/net/ethernet/intel/igb/igb_ptp.c                 |  26 +++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c            |  23 +++++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.c              |  49 +++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c          |  12 +++-
 drivers/net/ethernet/mellanox/mlxsw/reg.h                |  11 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c           | 115 +++++++++++++++++---------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h           |   2 -
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c   |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c       |  10 +--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c    |   3 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c |  42 ++----------
 drivers/net/ethernet/mellanox/mlxsw/trap.h               |   4 ++
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c               | 223 +++++++++++++++++++++++++++++++++++++++++++++++----------------
 drivers/net/ethernet/qlogic/qed/qed_hsi.h                |   8 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h              |   4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c           |   2 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h        |   9 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c |  95 +++++++++++++++------------
 drivers/net/ethernet/ti/cpsw.c                           |   2 +
 drivers/net/ethernet/tundra/tsi108_eth.c                 |   2 +
 drivers/net/hyperv/hyperv_net.h                          |  24 +++----
 drivers/net/hyperv/netvsc.c                              |  19 +++---
 drivers/net/hyperv/netvsc_drv.c                          | 105 ++++++++++++++----------------
 drivers/net/macsec.c                                     |  52 ++++++++++++---
 drivers/net/macvlan.c                                    |   2 +-
 drivers/net/macvtap.c                                    |   5 +-
 drivers/net/phy/micrel.c                                 |  27 +++++---
 drivers/net/vxlan.c                                      |  34 ++++++----
 drivers/net/wireless/ti/wlcore/main.c                    |   5 +-
 fs/afs/cmservice.c                                       |  78 ++++++++++------------
 fs/afs/fsclient.c                                        | 221 +++++++++++++++++++++-----------------------------------------
 fs/afs/internal.h                                        |  14 +++-
 fs/afs/rxrpc.c                                           |  73 +++++++++++++--------
 fs/afs/vlclient.c                                        |  11 ++--
 include/linux/netdevice.h                                |   3 +-
 include/linux/qed/qed_if.h                               |   8 +++
 include/linux/sctp.h                                     |  64 ------------------
 include/linux/skbuff.h                                   |  52 +++++++++------
 include/net/act_api.h                                    |  23 ++-----
 include/net/af_rxrpc.h                                   |   2 +-
 include/net/gre.h                                        |   1 +
 include/net/inet_ecn.h                                   |   3 +-
 include/net/mac80211.h                                   |   3 +-
 include/net/pkt_cls.h                                    |  41 ++++++++++--
 include/uapi/linux/bpf.h                                 |   4 +-
 include/uapi/linux/netfilter/nf_tables.h                 |   2 +-
 include/uapi/linux/sctp.h                                |  64 ++++++++++++++++++
 kernel/bpf/hashtab.c                                     |  84 ++++++++++++++++++++----
 kernel/bpf/verifier.c                                    |   7 +-
 lib/rhashtable.c                                         |  13 ++--
 lib/test_rhashtable.c                                    |   2 +-
 net/8021q/vlan.c                                         |   2 +-
 net/bridge/br_fdb.c                                      |  52 ++++++++-------
 net/core/dev.c                                           |  10 +--
 net/core/filter.c                                        | 109 ++++++++++++++-----------------
 net/ipv4/fib_trie.c                                      |   8 +--
 net/ipv4/ip_gre.c                                        |   1 -
 net/ipv4/ip_vti.c                                        |  31 +++++++++
 net/ipv6/addrconf.c                                      |   4 +-
 net/ipv6/calipso.c                                       |   4 +-
 net/ipv6/ip6_gre.c                                       |   2 -
 net/ipv6/ping.c                                          |  33 +++++-----
 net/irda/iriap.c                                         |   8 ++-
 net/mac80211/cfg.c                                       |   2 +-
 net/mac80211/driver-ops.h                                |   2 +-
 net/mac80211/mesh.c                                      |  10 +--
 net/mac80211/rx.c                                        |   2 +-
 net/mac80211/status.c                                    |  14 ++--
 net/mac80211/tx.c                                        |   6 +-
 net/netfilter/nf_conntrack_expect.c                      |   2 +-
 net/netfilter/nf_conntrack_h323_main.c                   |   3 +-
 net/netfilter/nf_conntrack_netlink.c                     |  10 ++-
 net/netfilter/nf_conntrack_sip.c                         |   4 +-
 net/netfilter/nfnetlink_queue.c                          |   6 +-
 net/netfilter/nft_exthdr.c                               |  11 +++-
 net/netfilter/nft_rbtree.c                               |  10 +--
 net/openvswitch/conntrack.c                              |   8 +--
 net/openvswitch/vport-geneve.c                           |   9 ++-
 net/openvswitch/vport-gre.c                              |  11 +++-
 net/openvswitch/vport-internal_dev.c                     |   2 +-
 net/openvswitch/vport-vxlan.c                            |   9 ++-
 net/rxrpc/ar-internal.h                                  |   1 +
 net/rxrpc/call_accept.c                                  |   1 +
 net/rxrpc/call_event.c                                   |   7 ++
 net/rxrpc/call_object.c                                  |  11 ++--
 net/rxrpc/input.c                                        |  39 ++++++-----
 net/rxrpc/recvmsg.c                                      |  25 +------
 net/rxrpc/skbuff.c                                       |  41 ++++++++++--
 net/sched/act_api.c                                      |  34 +++-------
 net/sched/act_police.c                                   |  62 ++++--------------
 net/sched/cls_api.c                                      |  51 ++++++++++-----
 net/sctp/proc.c                                          |   1 +
 net/sctp/sctp_diag.c                                     |  18 ++++--
 net/sctp/ulpevent.c                                      |   4 +-
 net/tipc/monitor.c                                       |   3 +-
 net/tipc/socket.c                                        |   3 +-
 net/wireless/chan.c                                      |   1 +
 net/wireless/nl80211.c                                   |  34 +++++++++-
 samples/bpf/bpf_helpers.h                                |   4 +-
 samples/bpf/test_cgrp2_tc_kern.c                         |   2 +-
 samples/bpf/test_maps.c                                  |  15 ++++-
 116 files changed, 1486 insertions(+), 1109 deletions(-)
