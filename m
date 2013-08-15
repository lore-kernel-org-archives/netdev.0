From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 15 Aug 2013 16:28:00 -0700 (PDT)
Message-ID: <20130815.162800.401175429439009129.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix SKB leak in 8139cp, from Dave Jones.

2) Fix use of *_PAGES interfaces with mlx5 firmware, from
   Moshe Lazar.

3) RCU conversion of macvtap introduced two races, fixes by
   Eric Dumazet.

4) Synchronize statistic flows in bnx2x driver to prevent
   corruption, from Dmitry Kravkov.

5) Undo optimization in IP tunneling, we were using the inner
   IP header in some cases to inherit the IP ID, but that
   isn't correct in some circumstances.  From Pravin B Shelar.

6) Use correct struct size when parsing netlink attributes in
   rtnl_bridge_getlink().  From Asbjoern Sloth Toennesen.

7) Length verifications in tun_get_user() are bogus, from
   Weiping Pan and Dan Carpenter.

8) Fix bad merge resolution during 3.11 networking development
   in openvswitch, albeit a harmless one which added some
   unreachable code.  From Jesse Gross.

9) Wrong size used in flexible array allocation in openvswitch,
   from Pravin B Shelar.

10) Clear out firmware capability flags the be2net driver isn't
    ready to handle yet, from Sarveshwar Bandi.

11) Revert DMA mapping error checking addition to cxgb3 driver,
    it's buggy.  From Alexey Kardashevskiy.

12) Fix regression in packet scheduler rate limiting when working
    with a link layer of ATM.  From Jesper Dangaard Brouer.

13) Fix several errors in TCP Cubic congestion control, in particular
    overflow errors in timestamp calculations.  From Eric Dumazet
    and Van Jacobson.

14) In ipv6 routing lookups, we need to backtrack if subtree traversal
    don't result in a match.  From Hannes Frederic Sowa.

15) ipgre_header() returns incorrect packet offset.  Fix from Timo Ter=E4=
s.

16) Get "low latency" out of the new MIB counter names.  From Eliezer
    Tamir.

17) State check in ndo_dflt_fdb_del() is inverted, from Sridhar
    Samudrala.

18) Handle TCP Fast Open properly in netfilter conntrack, from Yuchung
    Cheng.

19) Wrong memcpy length in pcan_usb driver, from Stephane Grosjean.

20) Fix dealock in TIPC, from Wang Weidong and Ding Tianhong.

21) call_rcu() call to destroy SCTP transport is done too early and
    might result in an oops.  From Daniel Borkmann.

22) Fix races in genetlink family dumps, from Johannes Berg.

23) Flags passed into macvlan by the user need to be validated properly=
,
    from Michael S. Tsirkin.

24) Fix skge build on 32-bit, from Stephen Hemminger.

25) Handle malformed TCP headers properly in xt_TCPMSS, from Pablo
    Neira Ayuso.

26) Fix handling of stacked vlans in vlan_dev_real_dev(), from Nikolay
    Aleksandrov.

27) Eliminate MTU calculation overflows in esp{4,6}, from Daniel Borkma=
nn.

28) neigh_parms need to be setup before calling the ->ndo_neigh_setup()
    method.  From Veaceslav Falico.

29) Kill out-of-bounds prefetch in fib_trie, from Eric Dumazet.

30) Don't dereference MLD query message if the length isn't value in
    the bridge multicast code, from Linus L=FCssing.

31) Fix VXLAN IGMP join regression due to an inverted check, from Cong
    Wang.

Please pull, thanks a lot.

The following changes since commit 72a67a94bcba71a5fddd6b3596a20604d2b5=
dcd6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-0=
8-03 15:00:23 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 0a324f3189ed9c78b1aaf48d88e93cb18643c655=
:

  net/mlx5_core: Support MANAGE_PAGES and QUERY_PAGES firmware command =
changes (2013-08-15 15:42:57 -0700)

----------------------------------------------------------------
Alexey Brodkin (1):
      ethernet/arc/arc_emac - fix NAPI "work > weight" warning

Alexey Kardashevskiy (1):
      Revert "cxgb3: Check and handle the dma mapping errors"

Ariel Elior (1):
      bnx2x: fix memory leak in VF

Asbjoern Sloth Toennesen (1):
      rtnetlink: rtnl_bridge_getlink: Call nlmsg_find_attr() with ifinf=
omsg header

Barak Witkowsky (1):
      bnx2x: fix PTE write access error

Bartlomiej Zolnierkiewicz (1):
      stmmac: fix init_dma_desc_rings() to handle errors

Byungho An (1):
      net: stmmac: Fixed the condition of extend_desc for jumbo frame

Chris Wright (1):
      mac80211: fix infinite loop in ieee80211_determine_chantype

Cong Wang (2):
      vxlan: fix a regression of igmp join
      vxlan: fix a soft lockup in vxlan module removal

Dan Carpenter (2):
      netfilter: nfnetlink_{log,queue}: fix information leaks in netlin=
k message
      tun: signedness bug in tun_get_user()

Daniel Borkmann (4):
      net: esp{4,6}: fix potential MTU calculation overflows
      net: sctp: sctp_assoc_control_transport: fix MTU size in SCTP_PF =
state
      net: sctp: sctp_transport_destroy{, _rcu}: fix potential pointer =
corruption
      net: tg3: fix NULL pointer dereference in tg3_io_error_detected a=
nd tg3_io_slot_reset

Dave Jones (1):
      8139cp: Fix skb leak in rx_status_loop failure path.

David S. Miller (5):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge branch 'bnx2x'
      Merge branch 'fixes' of git://git.kernel.org/.../jesse/openvswitc=
h

Dmitry Kravkov (2):
      bnx2x: protect different statistics flows
      bnx2x: update fairness parameters following DCB negotiation

Eli Cohen (1):
      mlx5: remove health handler plugin

Eliezer Tamir (2):
      busy_poll: cleanup do-nothing placeholders
      net: rename busy poll MIB counter

Eric Dumazet (5):
      fib_trie: remove potential out of bound access
      tcp: cubic: fix overflow error in bictcp_update()
      tcp: cubic: fix bug in bictcp_acked()
      net: flow_dissector: add 802.1ad support
      macvtap: fix two races

Hannes Frederic Sowa (1):
      ipv6: don't stop backtracking in fib6_lookup_1 if subtree does no=
t match

Himanshu Madhani (1):
      qlcnic: Fix set driver version command

Hyong-Youb Kim (1):
      myri10ge: Update MAINTAINERS

Jesper Dangaard Brouer (1):
      net_sched: restore "linklayer atm" handling

Jesse Gross (2):
      openvswitch: Fix bad merge resolution.
      openvswitch: Reset tunnel key between input and output.

Johannes Berg (6):
      nl80211: fix another nl80211_fam.attrbuf race
      mac80211: don't wait for TX status forever
      mac80211: ignore HT primary channel while connected
      cfg80211: fix P2P GO interface teardown
      mac80211: continue using disabled channels while connected
      genetlink: fix family dump race

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Julia Lawall (2):
      net/vmw_vsock/af_vsock.c: drop unneeded semicolon
      drivers/net/ethernet/via/via-velocity.c: update napi implementati=
on

Linus L=FCssing (2):
      bridge: don't try to update timers in case of broken MLD queries
      batman-adv: fix potential kernel paging errors for unicast transm=
issions

Manish Chopra (1):
      qlcnic: Fix diagnostic interrupt test for 83xx adapters

Michael S. Tsirkin (1):
      macvlan: validate flags

Moshe Lazer (1):
      net/mlx5_core: Support MANAGE_PAGES and QUERY_PAGES firmware comm=
and changes

Pablo Neira Ayuso (2):
      netfilter: xt_TCPMSS: fix handling of malformed TCP header and op=
tions
      netfilter: xt_TCPOPTSTRIP: fix possible off by one access

Pravin B Shelar (2):
      ip_tunnel: Do not use inner ip-header-id for tunnel ip-header-id.
      openvswitch: Use correct type while allocating flex array.

Sarveshwar Bandi (1):
      be2net: Clear any capability flags that driver is not interested =
in.

Solomon Peachy (1):
      cw1200: Fix spurious BUG_ON() trigger when starting AP mode.

Sridhar Samudrala (1):
      rtnetlink: Fix inverted check in ndo_dflt_fdb_del()

Stanislaw Gruszka (2):
      iwl4965: set power mode early
      iwl4965: reset firmware after rfkill off

Stephane Grosjean (1):
      can: pcan_usb: fix wrong memcpy() bytes length

Stephen Hemminger (1):
      skge: fix build on 32 bit

Sucheta Chakraborty (1):
      qlcnic: Fix beacon state return status handling

Timo Ter=E4s (1):
      ip_gre: fix ipgre_header to return correct offset

Veaceslav Falico (2):
      neighbour: populate neigh_parms on alloc before calling ndo_neigh=
_setup
      bonding: modify only neigh_parms owned by us

Wang Sheng-Hui (1):
      bridge: correct the comment for file br_sysfs_br.c

Weiping Pan (1):
      tun: compare with 0 instead of total_len

Yuchung Cheng (1):
      netfilter: nf_conntrack: fix tcp_in_window for Fast Open

Yuval Mintz (1):
      bnx2x: prevent crash in shutdown flow with CNIC

dingtianhong (1):
      tipc: avoid possible deadlock while enable and disable bearer

nikolay@redhat.com (2):
      vlan: make vlan_dev_real_dev work over stacked vlans
      net_sched: make dev_trans_start return vlan's real dev trans_star=
t

stephen hemminger (2):
      skge: add dma_mapping check
      skge: dma_sync the whole receive buffer

 MAINTAINERS                                           |   4 +--
 drivers/net/bonding/bond_main.c                       |   8 ++++-
 drivers/net/can/usb/peak_usb/pcan_usb.c               |   2 +-
 drivers/net/ethernet/arc/emac_main.c                  |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h           |   5 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c       |   4 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h       |   5 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |  43 ++++++++++=
++++++--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c     |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c     |  66 ++++++++++=
++++++++++++++++++++-------
 drivers/net/ethernet/broadcom/tg3.c                   |  13 +++++---
 drivers/net/ethernet/chelsio/cxgb3/sge.c              | 107 ++++++++++=
++++---------------------------------------------
 drivers/net/ethernet/emulex/benet/be_cmds.c           |   3 ++
 drivers/net/ethernet/emulex/benet/be_cmds.h           |   6 ++++
 drivers/net/ethernet/marvell/skge.c                   |  68 ++++++++++=
+++++++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c         |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c          |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fw.c          |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/health.c      |  29 +---------=
------
 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c   |  58 ++++++++++=
+++++-----------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c   |   5 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c |   3 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |   6 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c     |   6 ++--
 drivers/net/ethernet/realtek/8139cp.c                 |   1 +
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c       |  13 ++++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 111 ++++++++++=
+++++++++++++++++++++++++++++++++++++++++-----------
 drivers/net/ethernet/via/via-velocity.c               |   4 ++-
 drivers/net/macvlan.c                                 |   4 +++
 drivers/net/macvtap.c                                 |  12 +++++--
 drivers/net/tun.c                                     |   6 ++--
 drivers/net/vxlan.c                                   |   4 +--
 drivers/net/wireless/cw1200/sta.c                     |   7 ++--
 drivers/net/wireless/iwlegacy/4965-mac.c              |  16 ++++-----
 drivers/net/wireless/iwlegacy/common.c                |   1 +
 include/linux/mlx5/device.h                           |  22 ++++++----=
---
 include/linux/mlx5/driver.h                           |   7 ++--
 include/net/busy_poll.h                               |   7 +---
 include/net/ip_tunnels.h                              |  14 --------
 include/net/sch_generic.h                             |   9 ++++-
 include/uapi/linux/pkt_sched.h                        |  10 +++++-
 include/uapi/linux/snmp.h                             |   2 +-
 net/8021q/vlan_core.c                                 |   7 +++-
 net/batman-adv/bridge_loop_avoidance.c                |   2 ++
 net/batman-adv/gateway_client.c                       |  13 +++++++-
 net/batman-adv/gateway_client.h                       |   3 +-
 net/batman-adv/soft-interface.c                       |   9 ++++-
 net/batman-adv/unicast.c                              |  13 ++++++--
 net/bridge/br_multicast.c                             |   2 +-
 net/bridge/br_sysfs_br.c                              |   2 +-
 net/core/flow_dissector.c                             |   1 +
 net/core/neighbour.c                                  |  10 +++---
 net/core/rtnetlink.c                                  |   4 +--
 net/ipv4/esp4.c                                       |   2 +-
 net/ipv4/fib_trie.c                                   |   5 +--
 net/ipv4/ip_gre.c                                     |   2 +-
 net/ipv4/ip_tunnel_core.c                             |   4 +--
 net/ipv4/proc.c                                       |   2 +-
 net/ipv4/tcp_cubic.c                                  |  12 ++++---
 net/ipv6/esp6.c                                       |   2 +-
 net/ipv6/ip6_fib.c                                    |  16 ++++++---
 net/mac80211/mlme.c                                   |  54 ++++++++++=
++++++++++----------
 net/netfilter/nf_conntrack_proto_tcp.c                |  12 ++++---
 net/netfilter/nfnetlink_log.c                         |   6 +++-
 net/netfilter/nfnetlink_queue_core.c                  |   5 ++-
 net/netfilter/xt_TCPMSS.c                             |  28 +++++++++-=
------
 net/netfilter/xt_TCPOPTSTRIP.c                        |  10 +++---
 net/netlink/genetlink.c                               |   7 ++++
 net/openvswitch/actions.c                             |   1 +
 net/openvswitch/datapath.c                            |   3 --
 net/openvswitch/flow.c                                |   2 +-
 net/sched/sch_api.c                                   |  41 ++++++++++=
+++++++++++++
 net/sched/sch_generic.c                               |   8 ++++-
 net/sched/sch_htb.c                                   |  13 ++++++++
 net/sctp/associola.c                                  |   4 +--
 net/sctp/transport.c                                  |   4 +--
 net/tipc/bearer.c                                     |   9 +++--
 net/vmw_vsock/af_vsock.c                              |   2 +-
 net/wireless/core.c                                   |   1 +
 net/wireless/nl80211.c                                |   6 ++--
 80 files changed, 651 insertions(+), 377 deletions(-)
