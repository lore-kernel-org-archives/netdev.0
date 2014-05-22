From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 22 May 2014 17:51:29 -0400 (EDT)
Message-ID: <20140522.175129.1161419079593015458.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It looks like a sizeble collection but this is nearly 3 weeks of bug
fixing while you were qaway.

1) Fix crashes over IPSEC tunnels with NAT, the latter can reroute the =
packet
   through a non-IPSEC protected path and the code has to be able to ha=
ndle
   SKBs attached to routes lacking an attached xfrm state.  From Steffe=
n
   Klassert.

2) Fix OOPSs in ipv4 and ipv6 ipsec layers for unsupported
   sub-protocols, also from Steffen Klassert.

3) Set local_df on fragmented netfilter skbs otherwise we won't be able
   to forward successfully, from Florian Westphal.

4) cdc_mbim ipv6 neighbour code does __vlan_find_dev_deep without holdi=
ng
   RCU lock, from Bjorn Mork.

5) local_df test in ip_may_fragment is inverted, from Florian Westphal.

6) jme driver doesn't check for DMA mapping failures, from Neil Horman.

7) qlogic driver doesn't calculate number of TX queues properly, from
   Shahed Shaikh.

8) fib_info_cnt can drift irreversibly positive if we fail to allocate
   the fi->fib_metrics array, from Sergey Popovich.

9) Fix use after free in ip6_route_me_harder(), also from Sergey
   Popovich.

10) When SYSCTL is disabled, we don't handle local_port_range and
    ping_group_range defaults properly at all, from Cong Wang.

11) Unaccelerated VLAN tagged frames improperly handled by cdc_mbim
    driver, fix from Bjorn Mork.

12) cassini driver needs nested lock annotations for TX locking,
    from Emil Goode.

13) On init error ipv6 VTI driver can unregister pernet ops twice,
    oops.  Fix from Mahtias Krause.

14) If macvlan device is down, don't propagate IFF_ALLMULTI changes,
    from Peter Christensen.

15) Missing NULL pointer check while parsing netlink config options
    in ip6_tnl_validate().  From Susant Sahani.

16) Fix handling of neighbour entries during ipv6 router
    reachability probing, from Duan Jiong.

17) x86 and s390 JIT address randomization has some address calculation=
=09
    bugs leading to crashes, from Alexei Starovoitov and Heiko
    Carstens.

18) Clear up those uglies with nop patching and net_get_random_once(),
    from Hannes Frederic Sowa.

19) Option length miscalculated in ip6_append_data(), fix also from
    Hannes Frederic Sowa.

20) A while ago we fixed a race during device unregistry when a namespa=
ce
    went down, turns out there is a second place that needs similar
    protection.  From Cong Wang.

21) In the new Altera TSE driver multicast filtering isn't working,
    disable it and just use promisc mode until the cause is found.
    From Vince Bridgers.

22) When we disable router enabling in ipv6 we have to flush the
    cached routes explicitly, from Duan Jiong.

23) NBMA tunnels should not cache routes on the tunnel object because
    the key is variable, from Timo Ter=E4s.

24) With stacked devices GRO information in skb->cb[] can be not setup
    properly, make sure it is in all code paths.  From Eric Dumazet.

25) Really fix stacked vlan locking, multiple levels of nesting with
    intervening non-vlan devices are possible.  From Vlad Yasevich.

26) Fallback ipip tunnel device's mtu is not setup properly, from
    Steffen Klassert.

27) The packet scheduler's tcindex filter can crash because we
    structure copy objects with list_head's inside, oops.  From
    Cong Wang.

28) Fix CHECKSUM_COMPLETE handling for ipv6 GRE tunnels, from Eric
    Dumazet.

29) In some configurations 'itag' in __mkroute_input() can end up
    being used uninitialized because of how fib_validate_source()
    works.  Fit it by explitly initializing itag to zero like all
    the other fib_validate_source() callers do, from Li RongQing.

Please pull, thanks a lot!

The following changes since commit 2080cee435088a2390195c2424e494c50e37=
d6a1:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-0=
5-05 15:59:46 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to b6ed5498601df40489606dbc14a9c7011c16630b=
:

  batman: fix a bogus warning from batadv_is_on_batman_iface() (2014-05=
-22 17:23:00 -0400)

----------------------------------------------------------------
Alexander Bondar (1):
      iwlwifi: mvm: several fixes in scan

Alexei Starovoitov (1):
      net: filter: x86: fix JIT address randomization

Antonio Quartulli (3):
      batman-adv: fix reference counting imbalance while sending fragme=
nt
      batman-adv: increase orig refcount when storing ref in gw_node
      batman-adv: fix local TT check for outgoing arp requests in DAT

Bj=F8rn Mork (2):
      net: cdc_mbim: __vlan_find_dev_deep need rcu_read_lock
      net: cdc_mbim: handle unaccelerated VLAN tagged frames

Bob Copeland (1):
      mac80211: fixup radiotap tx flags for RTS/CTS

Chun-Yeow Yeoh (1):
      mac80211: avoid handling of SMPS for mesh

Cong Wang (5):
      ipv4: move local_port_range out of CONFIG_SYSCTL
      ping: move ping_group_range out of CONFIG_SYSCTL
      rtnetlink: wait for unregistering devices in rtnl_link_unregister=
()
      net_sched: fix an oops in tcindex filter
      batman: fix a bogus warning from batadv_is_on_batman_iface()

Daniel Kim (1):
      brcmfmac: Fix iovar 'bw_cap' set command failure

Daniel Mack (1):
      net: mdio: of_mdiobus_register(): fall back to mdiobus_register()=
 for !CONFIG_OF

Darek Marcinkiewicz (1):
      Driver for Beckhoff CX5020 EtherCAT master module.

David S. Miller (16):
      Merge branch 'gso_forward'
      Merge branch 'qlcnic_net'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'mdio_net'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge branch 'altera_tse'
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'mlx4-net'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge branch 'stacked_netdevice_locking'
      Merge branch 'bond_stacked_vlans'
      Merge git://git.kernel.org/.../pablo/nf
      Merge tag 'linux-can-fixes-for-3.15-20140519' of git://gitorious.=
org/linux-can/linux-can
      Merge tag 'linux-can-fixes-for-3.15-20140521' of git://gitorious.=
org/linux-can/linux-can

David Spinadel (2):
      iwlwifi: mvm: do no sched scan while associated
      iwlwifi: mvm: prevent sched scan while not idle

David Vrabel (1):
      xen-netback: fix race between napi_complete() and interrupt handl=
er

Denys Fedoryshchenko (1):
      netfilter: nfnetlink: Fix use after free when it fails to process=
 batch

Duan Jiong (2):
      neigh: set nud_state to NUD_INCOMPLETE when probing router reacha=
bility
      ipv6: update Destination Cache entries when gateway turn into hos=
t

Eliad Peller (5):
      cfg80211: free sme on connection failures
      cfg80211: add cfg80211_sched_scan_stopped_rtnl
      mac80211: fix nested rtnl locking on ieee80211_reconfig
      mac80211: fix vif name tracing
      iwlwifi: mvm: fix off-by-one in scan channels configuration

Emil Goode (1):
      net: cassini: use nested lock annotation

Emmanuel Grumbach (5):
      iwlwifi: mvm: BT Coex - fix validity flags during init
      iwlwifi: mvm: rs - s/CPTCFG/CONFIG
      iwlwifi: pcie: disable interrupts upon PCIe alloc
      iwlwifi: mvm: fix setting channel in monitor mode
      mac80211: fix suspend vs. association race

Eric Dumazet (2):
      net: gro: make sure skb->cb[] initial content has not to be zero
      ipv6: gro: fix CHECKSUM_COMPLETE support

=46abian Godehardt (1):
      net/dsa/dsa.c: increment chip_index during of_node handling on ds=
a_of_probe()

=46lorian Westphal (6):
      netfilter: ctnetlink: don't add null bindings if no nat requested
      netfilter: ipv4: defrag: set local_df flag on defragmented skb
      net: ipv4: ip_forward: fix inverted local_df test
      net: ipv6: send pkttoobig immediately if orig frag size > mtu
      net: ip: push gso skb forwarding handling down the stack
      Revert "net: core: introduce netif_skb_dev_features"

Guenter Roeck (1):
      net: phy: Don't call phy_resume if phy_init_hw failed

Hannes Frederic Sowa (2):
      net: avoid dependency of net_get_random_once on nop patching
      ipv6: fix calculation of option len in ip6_append_data

Hans de Goede (1):
      stmmac: Remove unbalanced clk_disable call

Heiko Carstens (1):
      net: filter: s390: fix JIT address randomization

Henning Rogge (1):
      mac80211: Fix mac80211 station info rx bitrate for IBSS mode

Jesse Gross (1):
      MAINTAINERS: Pravin Shelar is Open vSwitch maintainer.

Joe Perches (1):
      bnx2x: Convert return 0 to return rc

Johan Hovold (5):
      net: mdio-gpio: fix device-tree binding documentation
      net: mdio-gpio: warn about missing bus alias id
      Revert "net: eth: cpsw: Correctly attach to GPIO bitbang MDIO dri=
ver"
      net: cpsw: fix null dereference at probe
      net: cpsw: add missing of_node_put

Johannes Berg (3):
      mac80211: allow VHT with peers not capable of 40MHz
      nl80211: fix NL80211_FEATURE_P2P_DEVICE_NEEDS_CHANNEL API
      mac80211: fix on-channel remain-on-channel

John W. Linville (7):
      Merge git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi=
-fixes
      Merge git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Kalesh AP (1):
      be2net: enable interrupts in EEH resume

Li RongQing (1):
      ipv4: initialise the itag variable in __mkroute_input

Lorenzo Colitti (1):
      net: ipv6: make "ip -6 route get mark xyz" work.

Manish Chopra (1):
      qlcnic: Fix panic while dumping TX queues on TX timeout

Marek Lindner (1):
      batman-adv: fix indirect hard_iface NULL dereference

Matan Barak (2):
      net/mlx4_core: Add UPDATE_QP SRIOV wrapper support
      IB/mlx4: Invoke UPDATE_QP for proxy QP1 on MAC changes

Mathias Krause (1):
      vti6: Don't unregister pernet ops twice on init errors

Nathaniel W Filardo (1):
      af_rxrpc: Fix XDR length check in rxrpc key demarshalling.

Neil Horman (2):
      jme: Fix DMA unmap warning
      jme: Fix unmap loop counting error:

Nikolay Aleksandrov (2):
      sfc: fix calling of free_irq with already free vector
      bonding: fix out of range parameters for bond_intmax_tbl

Oliver Hartkopp (1):
      can: c_can: remove obsolete STRICT_FRAME_ORDERING Kconfig option

Pablo Neira Ayuso (6):
      netfilter: nf_tables: reset rule number counter after jump and go=
to
      netfilter: nf_tables: fix goto action
      netfilter: nf_tables: fix tracing of the goto action
      netfilter: nf_tables: fix bogus rulenum after goto action
      netfilter: nf_tables: fix missing return trace at the end of non-=
base chain
      netfilter: nf_tables: fix trace of matching non-terminal rule

Peter Christensen (1):
      macvlan: Don't propagate IFF_ALLMULTI changes on down interfaces.

Rajkumar Manoharan (1):
      ath9k_htc: Stop ANI before doing hw_reset

Randy Dunlap (1):
      ptp: fix kconfig dependency warnings

Sergey Popovich (2):
      ipv4: fib_semantics: increment fib_info_cnt after fib_info alloca=
tion
      netfilter: Fix potential use after free in ip6_route_me_harder()

Shahed Shaikh (1):
      qlcnic: Set real_num_{tx|rx}_queues properly

Simon Wunderlich (4):
      batman-adv: fix neigh_ifinfo imbalance
      batman-adv: fix neigh reference imbalance
      batman-adv: always run purge_orig_neighbors
      batman-adv: fix removing neigh_ifinfo

Steffen Klassert (6):
      xfrm: Fix crash with ipv6 IPsec tunnel and NAT.
      vti4: Don't count header length twice.
      xfrm4: Properly handle unsupported protocols
      xfrm6: Properly handle unsupported protocols
      vti: Use the tunnel mark for lookup in the error handlers.
      ip_tunnel: Initialize the fallback device properly

Stephane Grosjean (1):
      can: peak_pci: prevent use after free at netdev removal

Susant Sahani (1):
      ip6_tunnel: fix potential NULL pointer dereference

Timo Ter=E4s (1):
      ipv4: ip_tunnels: disable cache for nbma gre tunnels

Tobias Klauser (1):
      net: doc: Update references to skb->rxhash

Ursula Braun (1):
      af_iucv: wrong mapping of sent and confirmed skbs

Vasily Averin (2):
      ipv4: fix "conntrack zones" support for defrag user check in ip_e=
xpire
      bridge: superfluous skb->nfct check in br_nf_dev_queue_xmit

Vince Bridgers (2):
      Altera TSE: Fix sparse errors and warnings
      Altera TSE: Disable Multicast filtering to workaround problem

Vlad Yasevich (9):
      net: Find the nesting level of a given device by type.
      net: Allow for more then a single subclass for netif_addr_lock
      vlan: Fix lockdep warning with stacked vlan devices.
      macvlan: Fix lockdep warnings with stacked macvlan devices
      bonding: Fix stacked device detection in arp monitoring
      bonding: Fix alb mode to only use first level vlans.
      vlan: Fix build error wth vlan_get_encap_level()
      bonding: Don't assume 802.1Q when sending alb learning packets.
      bonding: Send ALB learning packets using the right source

Yuval Mintz (1):
      bnx2x: Fix UNDI driver unload

Zhangfei Gao (1):
      net: phy: resume phydev when going to RESUMING

Zoltan Kiss (1):
      xen-netback: Fix grant ref resolution in RX path

 Documentation/devicetree/bindings/net/mdio-gpio.txt   |   2 +-
 Documentation/networking/filter.txt                   |   2 +-
 Documentation/networking/packet_mmap.txt              |   2 +-
 MAINTAINERS                                           |   4 +-
 arch/s390/net/bpf_jit_comp.c                          |   2 +-
 arch/x86/net/bpf_jit_comp.c                           |   2 +-
 drivers/infiniband/hw/mlx4/main.c                     |  67 ++++-
 drivers/infiniband/hw/mlx4/mlx4_ib.h                  |   3 +
 drivers/infiniband/hw/mlx4/qp.c                       |   8 +
 drivers/net/bonding/bond_alb.c                        |  54 ++--
 drivers/net/bonding/bond_main.c                       | 134 +++++----
 drivers/net/bonding/bond_options.c                    |   1 +
 drivers/net/bonding/bonding.h                         |   1 +
 drivers/net/can/c_can/Kconfig                         |   7 -
 drivers/net/can/c_can/c_can.c                         |  36 ---
 drivers/net/can/sja1000/peak_pci.c                    |  14 +-
 drivers/net/ethernet/Kconfig                          |  12 +
 drivers/net/ethernet/Makefile                         |   1 +
 drivers/net/ethernet/altera/Makefile                  |   1 +
 drivers/net/ethernet/altera/altera_msgdma.c           | 110 ++++----
 drivers/net/ethernet/altera/altera_msgdmahw.h         |  13 +-
 drivers/net/ethernet/altera/altera_sgdma.c            | 181 ++++++----=
--
 drivers/net/ethernet/altera/altera_sgdmahw.h          |  26 +-
 drivers/net/ethernet/altera/altera_tse.h              |  47 ++++
 drivers/net/ethernet/altera/altera_tse_ethtool.c      | 108 +++++---
 drivers/net/ethernet/altera/altera_tse_main.c         | 133 +++++----
 drivers/net/ethernet/altera/altera_utils.c            |  20 +-
 drivers/net/ethernet/altera/altera_utils.h            |   8 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |  10 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c     |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c      |   2 +-
 drivers/net/ethernet/ec_bhf.c                         | 706 ++++++++++=
+++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_main.c           |   6 +
 drivers/net/ethernet/jme.c                            |  53 +++-
 drivers/net/ethernet/mellanox/mlx4/cmd.c              |   4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h             |   6 +
 drivers/net/ethernet/mellanox/mlx4/qp.c               |  35 +++
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  54 ++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h           |  16 --
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |  57 +++-
 drivers/net/ethernet/sfc/nic.c                        |  14 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |   4 +-
 drivers/net/ethernet/sun/cassini.c                    |   2 +-
 drivers/net/ethernet/ti/cpsw.c                        |  17 +-
 drivers/net/macvlan.c                                 |  18 +-
 drivers/net/phy/mdio-gpio.c                           |   4 +
 drivers/net/phy/phy.c                                 |  16 +-
 drivers/net/phy/phy_device.c                          |   4 +-
 drivers/net/usb/cdc_mbim.c                            |  57 ++--
 drivers/net/wireless/ath/ath9k/htc_drv_main.c         |   5 +-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |   2 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c               |   6 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h        |   8 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c           |   9 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h                |   3 +
 drivers/net/wireless/iwlwifi/mvm/rs.c                 |   2 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c               |  55 +---
 drivers/net/wireless/iwlwifi/mvm/utils.c              |  19 ++
 drivers/net/wireless/iwlwifi/pcie/trans.c             |  10 +-
 drivers/net/xen-netback/common.h                      |   2 +-
 drivers/net/xen-netback/interface.c                   |  30 +-
 drivers/net/xen-netback/netback.c                     | 102 +++++--
 drivers/ptp/Kconfig                                   |   3 +-
 include/linux/if_macvlan.h                            |   1 +
 include/linux/if_vlan.h                               |  15 +-
 include/linux/mlx4/qp.h                               |  11 +
 include/linux/net.h                                   |  15 +-
 include/linux/netdevice.h                             |  34 ++-
 include/linux/of_mdio.h                               |   7 +-
 include/linux/rtnetlink.h                             |   5 +
 include/net/cfg80211.h                                |  12 +
 include/net/ip6_route.h                               |   1 +
 include/net/netns/ipv4.h                              |   9 +-
 include/uapi/linux/nl80211.h                          |   4 +-
 net/8021q/vlan.c                                      |   1 +
 net/8021q/vlan_dev.c                                  |  52 +---
 net/batman-adv/bat_iv_ogm.c                           |   2 +
 net/batman-adv/distributed-arp-table.c                |   3 +-
 net/batman-adv/fragmentation.c                        |  11 +-
 net/batman-adv/gateway_client.c                       |  11 +-
 net/batman-adv/hard-interface.c                       |   2 +-
 net/batman-adv/originator.c                           |  62 ++++-
 net/bridge/br_netfilter.c                             |   4 +-
 net/core/dev.c                                        | 102 ++++++-
 net/core/neighbour.c                                  |   4 +-
 net/core/net_namespace.c                              |   2 +-
 net/core/rtnetlink.c                                  |  33 ++-
 net/core/skbuff.c                                     |   4 +-
 net/core/utils.c                                      |   8 +-
 net/dsa/dsa.c                                         |   3 +-
 net/ipv4/af_inet.c                                    |  36 +++
 net/ipv4/fib_semantics.c                              |   2 +-
 net/ipv4/inet_connection_sock.c                       |   8 +-
 net/ipv4/ip_forward.c                                 |  54 +---
 net/ipv4/ip_fragment.c                                |   5 +-
 net/ipv4/ip_output.c                                  |  51 +++-
 net/ipv4/ip_tunnel.c                                  |   4 +-
 net/ipv4/ip_vti.c                                     |   5 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c                   |   5 +-
 net/ipv4/ping.c                                       |   6 +-
 net/ipv4/route.c                                      |   2 +-
 net/ipv4/sysctl_net_ipv4.c                            |  42 +--
 net/ipv4/xfrm4_output.c                               |  32 ++-
 net/ipv4/xfrm4_protocol.c                             |  19 +-
 net/ipv6/ip6_offload.c                                |   6 +-
 net/ipv6/ip6_output.c                                 |   8 +-
 net/ipv6/ip6_tunnel.c                                 |   2 +-
 net/ipv6/ip6_vti.c                                    |   8 +-
 net/ipv6/ndisc.c                                      |   7 +-
 net/ipv6/netfilter.c                                  |   6 +-
 net/ipv6/route.c                                      |  24 ++
 net/ipv6/tcpv6_offload.c                              |   2 +-
 net/ipv6/xfrm6_output.c                               |  22 +-
 net/ipv6/xfrm6_protocol.c                             |  11 +-
 net/iucv/af_iucv.c                                    |   2 +-
 net/mac80211/ieee80211_i.h                            |   1 +
 net/mac80211/mlme.c                                   |  20 +-
 net/mac80211/offchannel.c                             |  27 +-
 net/mac80211/rx.c                                     |   3 +-
 net/mac80211/sta_info.c                               |   3 +-
 net/mac80211/status.c                                 |   5 +-
 net/mac80211/trace.h                                  |   4 +-
 net/mac80211/util.c                                   |   2 +-
 net/mac80211/vht.c                                    |   9 +-
 net/netfilter/nf_conntrack_netlink.c                  |   3 +
 net/netfilter/nf_tables_core.c                        |  49 ++--
 net/netfilter/nfnetlink.c                             |   8 +-
 net/rxrpc/ar-key.c                                    |   2 +-
 net/sched/cls_tcindex.c                               |  30 +-
 net/wireless/scan.c                                   |  12 +-
 net/wireless/sme.c                                    |   2 +-
 131 files changed, 2381 insertions(+), 928 deletions(-)
 create mode 100644 drivers/net/ethernet/ec_bhf.c
