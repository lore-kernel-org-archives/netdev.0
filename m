From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 23 Jul 2016 02:07:56 -0400 (EDT)
Message-ID: <20160723.020756.2194659589075955833.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix memory leak in nftables, from Liping Zhang.

2) Need to check result of vlan_insert_tag() in batman-adv otherwise
   we risk NULL skb derefs, from Sven Eckelmann.

3) Check for dev_alloc_skb() failures in cfg80211, from Gregory
   Greenman.

4) Handle properly when we have ppp_unregister_channel() happening
   in parallel with ppp_connect_channel(), from WANG Cong.

5) Fix DCCP deadlock, from Eric Dumazet.

6) Bail out properly in UDP if sk_filter() truncates the packet to be
   smaller than even the space that the protocol headers need.  From
   Michal Kubecek.

7) Similarly for rose, dccp, and sctp, from Willem de Bruijn.

8) Make TCP challenge ACKs less predictable, from Eric Dumazet.

9) Fix infinite loop in bgmac_dma_tx_add() from Florian Fainelli.

Please pull, thanks a lot!

The following changes since commit bc86765181aa26cc9afcb0a6f9f253cbb118=
6f26:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-0=
7-06 09:42:43 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to f8e7718cc0445587fe8530fc2d240d9aac2c9072=
:

  packet: propagate sock_cmsg_send() error (2016-07-22 01:41:48 -0400)

----------------------------------------------------------------
Alexander Duyck (1):
      i40e/i40evf: Fix i40e_rx_checksum

Beniamino Galvani (1):
      bonding: set carrier off for devices created through netlink

Colin Ian King (1):
      bnxt_en: initialize rc to zero to avoid returning garbage

Daniel Jurgens (1):
      net/mlx5e: Fix TX Timeout to detect queues stuck on BQL

David S. Miller (11):
      Merge tag 'mac80211-for-davem-2016-07-06' of git://git.kernel.org=
/.../jberg/mac80211
      Merge branch 'ibmvnic-fixes'
      Merge tag 'batadv-net-for-davem-20160708' of git://git.open-mesh.=
org/linux-merge
      Merge branch 'tipc-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'ethoc-fixes'
      Merge branch 'mlx5-fixes'
      Merge branch 'sk_filter-trim-limit'
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net-qu=
eue
      Merge branch 'mlxsw-fixes'
      Merge branch 'mlx4-fixes'

Dmitri Epshtein (1):
      net: mvneta: set real interrupt per packet for tx_done

Douglas Miller (1):
      Update maintainer for EHEA driver.

Eric Dumazet (2):
      dccp: avoid deadlock in dccp_v4_ctl_send_reset
      tcp: make challenge acks less predictable

Eugenia Emantayev (2):
      net/mlx4_en: Move filters cleanup to a proper location
      net/mlx4_en: Add resilience in low memory systems

=46lorian Fainelli (6):
      net: ethoc: Fix early error paths
      net: ethoc: Correctly pad short packets
      net: bgmac: Fix infinite loop in bgmac_dma_tx_add()
      et131x: Fix logical vs bitwise check in et131x_tx_timeout()
      net: nb8800: Fix SKB leak in nb8800_receive()
      net: cavium: liquidio: Avoid dma_unmap_single on uninitialized nd=
ata

=46lorian Westphal (2):
      netfilter: conntrack: avoid integer overflow when resizing
      netfilter: nft_ct: fix expiration getter

Grant Grundler (1):
      r8152: add MODULE_VERSION

Gregory Greenman (1):
      cfg80211: handle failed skb allocation

Guilherme G. Piccoli (1):
      i40e: use valid online CPU on q_vector initialization

Ido Schimmel (5):
      mlxsw: spectrum: Force link training according to admin state
      mlxsw: spectrum: Indicate support for autonegotiation
      mlxsw: spectrum: Don't emit errors when PFC is disabled
      mlxsw: spectrum: Prevent overwrite of DCB capability fields
      mlxsw: spectrum: Prevent invalid ingress buffer mapping

Jason Baron (1):
      tcp: enable per-socket rate limiting of all 'challenge acks'

Jon Paul Maloy (3):
      tipc: extend broadcast link initialization criteria
      tipc: ensure correct broadcast send buffer release when peer is l=
ost
      tipc: reset all unicast links when broadcast send link fails

Julian Anastasov (1):
      ipv4: reject RTNH_F_DEAD and RTNH_F_LINKDOWN from user space

Kiran Patil (1):
      i40e: enable VSI broadcast promiscuous mode instead of adding bro=
adcast filter

Konstantin Khlebnikov (1):
      net/sched/sch_htb: clamp xstats tokens to fit into 32-bit int

Liping Zhang (2):
      netfilter: nf_tables: fix memory leak if expr init fails
      netfilter: nft_meta: set skb->nf_trace appropriately

Mario Limonciello (1):
      r8152: Add support for setting pass through MAC address on RTL815=
3-AD

Michal Kube=E8ek (1):
      udp: prevent bugcheck if filter truncates packet too much

Mohamad Haj Yahia (1):
      net/mlx5e: start/stop all tx queues upon open/close netdev

Noam Camus (1):
      net: nps_enet: Fix PCS reset

Pablo Neira Ayuso (2):
      Merge tag 'ipvs-fixes2-for-v4.7' of https://git.kernel.org/.../ho=
rms/ipvs
      netfilter: conntrack: skip clash resolution if nat is in place

Paolo Abeni (2):
      ixgbe: napi_poll must return the work done
      vlan: use a valid default mtu value for vlan over macsec

Purushottam Kushwaha (1):
      nl80211: Move ACL parsing later to avoid a possible memory leak

Quentin Armitage (1):
      ipvs: fix bind to link-local mcast IPv6 address in backup

Saeed Mahameed (1):
      net/mlx5e: Fix del vxlan port command buffer memset

Soheil Hassas Yeganeh (2):
      sock: ignore SCM_RIGHTS and SCM_CREDENTIALS in __sock_cmsg_send
      packet: propagate sock_cmsg_send() error

Sven Eckelmann (7):
      batman-adv: Avoid nullptr dereference in bla after vlan_insert_ta=
g
      batman-adv: Avoid nullptr dereference in dat after vlan_insert_ta=
g
      batman-adv: Fix orig_node_vlan leak on orig_node_release
      batman-adv: Fix non-atomic bla_claim::backbone_gw access
      batman-adv: Fix reference leak in batadv_find_router
      batman-adv: Free last_bonding_candidate on release of orig_node
      batman-adv: Fix speedy join in gateway client mode

Thomas Falcon (4):
      ibmvnic: properly start and stop tx queues
      ibmvnic: dispose irq mappings
      ibmvnic: simplify and improve driver probe function
      ibmvnic: Fix passive VNIC server login process

Vivien Didelot (1):
      net: switchdev: change ageing_time type to clock_t

WANG Cong (1):
      ppp: defer netns reference release for ppp channel

Willem de Bruijn (3):
      rose: limit sk_filter trim to payload
      dccp: limit sk_filter trim to payload
      sctp: load transport header after sk_filter

Yoshihiro Shimoda (1):
      packet: fix second argument of sock_tx_timestamp()

hayeswang (1):
      r8152: remove the setting of LAN_WAKE_EN

 MAINTAINERS                                            |   2 +-
 drivers/net/bonding/bond_netlink.c                     |   6 ++-
 drivers/net/ethernet/agere/et131x.c                    |   2 +-
 drivers/net/ethernet/aurora/nb8800.c                   |   1 +
 drivers/net/ethernet/broadcom/bgmac.c                  |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c      |   2 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c        |   9 ++--
 drivers/net/ethernet/ethoc.c                           |  16 ++++--
 drivers/net/ethernet/ezchip/nps_enet.c                 |   1 +
 drivers/net/ethernet/ibm/ibmvnic.c                     | 227 +++++++++=
++++++++++++++++++++++++++++++++++++++++++++++++++++++-----------------=
------
 drivers/net/ethernet/ibm/ibmvnic.h                     |   2 +
 drivers/net/ethernet/intel/i40e/i40e_main.c            |  48 +++++++++=
++-------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c            |  30 +++++++--=
---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c          |  30 +++++++--=
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c          |   2 +-
 drivers/net/ethernet/marvell/mvneta.c                  |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c        |  54 +++++++++=
+++---------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c         | 110 +++++++++=
++++++++++++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_rx.c             |   3 --
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h           |   9 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c      |  13 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c        |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h              |  17 ++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c         |  28 ++-------=
--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c     |   8 ++-
 drivers/net/ppp/ppp_generic.c                          |   5 +-
 drivers/net/usb/r8152.c                                |  85 +++++++++=
+++++++++++++++++++----
 include/linux/filter.h                                 |   6 ++-
 include/linux/netdevice.h                              |   7 +++
 include/net/netfilter/nf_conntrack.h                   |   8 +++
 include/net/sock.h                                     |   8 ++-
 include/net/switchdev.h                                |   2 +-
 net/8021q/vlan_dev.c                                   |  10 ++--
 net/8021q/vlan_netlink.c                               |   7 ++-
 net/batman-adv/bridge_loop_avoidance.c                 | 116 +++++++++=
++++++++++++++++++++++++++---------
 net/batman-adv/distributed-arp-table.c                 |  10 +++-
 net/batman-adv/originator.c                            |  15 ++++++
 net/batman-adv/routing.c                               |  52 +++++++++=
++++++-----
 net/batman-adv/send.c                                  |   4 +-
 net/batman-adv/types.h                                 |   6 ++-
 net/core/filter.c                                      |  10 ++--
 net/core/sock.c                                        |  11 +++--
 net/dccp/ipv4.c                                        |  12 +++--
 net/dccp/ipv6.c                                        |   2 +-
 net/ipv4/fib_semantics.c                               |   6 +++
 net/ipv4/tcp_input.c                                   |  54 +++++++++=
+++---------
 net/ipv4/udp.c                                         |   2 +
 net/ipv6/udp.c                                         |   2 +
 net/netfilter/ipvs/ip_vs_sync.c                        |   6 ++-
 net/netfilter/nf_conntrack_core.c                      |   8 +++
 net/netfilter/nf_tables_api.c                          |   4 +-
 net/netfilter/nft_ct.c                                 |   6 +--
 net/netfilter/nft_meta.c                               |   2 +-
 net/packet/af_packet.c                                 |  10 ++--
 net/rose/rose_in.c                                     |   3 +-
 net/sched/sch_htb.c                                    |   6 ++-
 net/sctp/input.c                                       |   5 +-
 net/tipc/bearer.c                                      |  15 ++++++
 net/tipc/bearer.h                                      |   1 +
 net/tipc/link.c                                        |   9 +++-
 net/tipc/node.c                                        |  15 ++++--
 net/wireless/nl80211.c                                 |   8 +--
 net/wireless/util.c                                    |   2 +
 64 files changed, 850 insertions(+), 320 deletions(-)
