From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 22 Mar 2017 20:47:44 -0700 (PDT)
Message-ID: <20170322.204744.1124413246830835520.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Several netfilter fixes from Pablo and the crew:
	a) Handle fragmented packets properly in netfilter conntrack,
	   from Florian Westphal.
	b) Fix SCTP ICMP packet handling, from Ying Xue.
	c) Fix big-endian bug in nftables, from Liping Zhang.
	d) Fix alignment of fake conntrack entry, from Steven Rostedt.

2) Fix feature flags setting in fjes driver, from Taku Izumi.

3) Openvswitch ipv6 tunnel source address not set properly, from
   Or Gerlitz.

4) Fix jumbo MTU handling in amd-xgbe driver, from Thomas Lendacky.

5) sk->sk_frag.page not released properly in some cases, from Eric
   Dumazet.

6) Fix RTNL deadlocks in nl80211, from Johannes Berg.

7) Fix erroneous RTNL lockdep splat in crypto, from Herbert Xu.

8) Cure improper inflight handling during AF_UNIX GC, from Andrey
   Ulanov.

9) sch_dsmark doesn't write to packet headers properly, from Eric
   Dumazet.

10) Fix SCM_TIMESTAMPING_OPT_STATS handling in TCP, from Soheil Hassas
    Yeganeh.

11) Add some IDs for Motorola qmi_wwan chips, from Tony Lindgren.

12) Fix nametbl deadlock in tipc, from Ying Xue.

13) GRO and LRO packets not counted correctly in mlx5 driver, from
    Gal Pressman.

14) Fix reset of internal PHYs in bcmgenet, from Doug Berger.

15) Fix hashmap allocation handling, from Alexei Starovoitov.

16) nl_fib_input() needs stronger netlink message length checking,
    from Eric Dumazet.

17) Fix double-free of sk->sk_filter during sock clone, from Daniel
    Borkmann.

18) Fix RX checksum offloading in aquantia driver, from Pavel Belous.

Please pull, thanks a lot!

The following changes since commit 95422dec6bd4a7c57444743f7b1bb375335a6298:

  Merge tag 'scsi-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi (2017-03-15 10:44:19 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to 68c386590375b2aea5a3154f17882a30170707bf:

  net:ethernet:aquantia: Fix for RX checksum offload. (2017-03-22 19:40:52 -0700)

----------------------------------------------------------------
Alexander Potapenko (1):
      ipv6: make sure to initialize sockc.tsflags before first use

Alexei Starovoitov (1):
      bpf: fix hashmap extra_elems logic

Amitkumar Karwar (1):
      MAINTAINERS: update for mwifiex driver maintainers

Andrey Ulanov (1):
      net: unix: properly re-increment inflight counter of GC discarded candidates

Arnd Bergmann (3):
      cpsw/netcp: work around reverse cpts dependency
      cpsw/netcp: cpts depends on posix_timers
      Bluetooth: btqcomsmd: fix compile-test dependency

Bjørn Mork (1):
      qmi_wwan: add Dell DW5811e

Brian Norris (3):
      mwifiex: pcie: don't leak DMA buffers when removing
      mwifiex: set adapter->dev before starting to use mwifiex_dbg()
      mwifiex: uninit wakeup info when removing device

Dan Carpenter (2):
      bna: integer overflow bug in debugfs
      sfc: cleanup a condition in efx_udp_tunnel_del()

Daniel Borkmann (1):
      socket, bpf: fix sk_filter use after free in sk_clone_lock

David Ahern (3):
      net: mpls: Fix nexthop alive tracking on down events
      net: ipv6: set route type for anycast routes
      net: vrf: Reset rt6i_idev in local dst after put

David Arcari (1):
      net: ethernet: aquantia: set net_device mtu when mtu is changed

David Howells (1):
      rxrpc: Ignore BUSY packets on old calls

David S. Miller (7):
      Merge git://git.kernel.org/.../pablo/nf
      Merge tag 'batadv-net-for-davem-20170316' of git://git.open-mesh.org/linux-merge
      Merge branch 'vsock-pkt-cancel'
      Merge branch 'r8152-rx-settings'
      Merge tag 'wireless-drivers-for-davem-2017-03-21' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'mlx5-fixes'
      Merge branch 'fjes-fixes'

Doug Berger (1):
      net: bcmgenet: remove bcmgenet_internal_phy_setup()

Eric Dumazet (6):
      net: properly release sk_frag.page
      tcp: tcp_get_info() should read tcp_time_stamp later
      sch_dsmark: fix invalid skb_cow() usage
      ipv4: provide stronger user input validation in nl_fib_input()
      tcp: initialize icsk_ack.lrcvtime at session start time
      inet: frag: release spinlock before calling icmp_send()

Florian Fainelli (1):
      net: bcmgenet: Do not suspend PHY if Wake-on-LAN is enabled

Florian Westphal (2):
      netfilter: don't track fragmented packets
      netfilter: bridge: honor frag_max_size when refragmenting

Gal Pressman (2):
      net/mlx5e: Count GSO packets correctly
      net/mlx5e: Count LRO packets correctly

Govindarajulu Varadarajan (1):
      enic: update enic maintainers

Herbert Xu (1):
      crypto: deadlock between crypto_alg_sem/rtnl_mutex/genl_mutex

Jack Morgenstein (1):
      net/mlx4_core: Avoid delays during VF driver device shutdown

Johannes Berg (1):
      nl80211: fix dumpit error path RTNL deadlocks

Kris Murphy (1):
      openvswitch: Add missing case OVS_TUNNEL_KEY_ATTR_PAD

Lendacky, Thomas (2):
      amd-xgbe: Fix jumbo MTU processing on newer hardware
      amd-xgbe: Fix the ECC-related bit position definitions

Liping Zhang (3):
      netfilter: nft_set_bitmap: fetch the element key based on the set->klen
      netfilter: nf_tables: fix mismatch in big-endian system
      netfilter: nft_ct: do cleanup work when NFTA_CT_DIRECTION is invalid

Maor Gottlieb (1):
      net/mlx5: Increase number of max QPs in default profile

Nathan Fontenot (1):
      ibmvnic: Free tx/rx scrq pointer array when releasing sub-crqs

Or Gerlitz (4):
      net/openvswitch: Set the ipv6 source tunnel key address attribute correctly
      net/mlx5: Add missing entries for set/query rate limit commands
      net/mlx5e: Change the TC offload rule add/del code path to be per NIC or E-Switch
      net/mlx5e: Use the proper UAPI values when offloading TC vlan actions

Pablo Neira (1):
      MAINTAINERS: remove MACVLAN and VLAN entries

Pablo Neira Ayuso (3):
      netfilter: nf_tables: set pktinfo->thoff at AH header if found
      netfilter: nft_set_bitmap: keep a list of dummy elements
      Revert "netfilter: nf_tables: add flush field to struct nft_set_iter"

Paul Blakey (1):
      net/mlx5e: Avoid supporting udp tunnel port ndo for VF reps

Pavel Belous (1):
      net:ethernet:aquantia: Fix for RX checksum offload.

Peng Tao (4):
      vsock: track pkt owner vsock
      vhost-vsock: add pkt cancel capability
      vsock: add pkt cancel capability
      vsock: cancel packets when failing to connect

Roi Dayan (1):
      net/mlx5: E-Switch, Don't allow changing inline mode when flows are configured

Ryan Hsu (1):
      ath10k: fix incorrect wlan_mac_base in qca6174_regs

Sara Sharon (1):
      iwlwifi: mvm: cleanup pending frames in DQA mode

Soheil Hassas Yeganeh (2):
      tcp: fix SCM_TIMESTAMPING_OPT_STATS for normal skbs
      tcp: mark skbs with SCM_TIMESTAMPING_OPT_STATS

Stanislaw Gruszka (1):
      genetlink: fix counting regression on ctrl_dumpfamily()

Steven Rostedt (VMware) (1):
      netfilter: Force fake conntrack entry to be at least 8 bytes aligned

Sven Eckelmann (2):
      batman-adv: Keep fragments equally sized
      batman-adv: Initialize gw sel_class via batadv_algo

Taku Izumi (1):
      fjes: Fix wrong netdevice feature flags

Tejun Heo (1):
      cgroup, net_cls: iterate the fds of only the tasks which are being migrated

Tony Lindgren (1):
      net: qmi_wwan: Add USB IDs for MDM6600 modem on Motorola Droid 4

WANG Cong (1):
      bridge: resolve a false alarm of lockdep

Xin Long (5):
      sctp: remove temporary variable confirm from sctp_packet_transmit
      sctp: define dst_pending_confirm as a bit in sctp_transport
      sctp: out_qlen should be updated when pruning unsent queue
      sctp: declare struct sctp_stream before using it
      sctp: remove useless err from sctp_association_init

Yaroslav Isakov (1):
      tun: fix inability to set offloads after disabling them via ethtool

Yasuaki Ishimatsu (2):
      fjes: Do not load fjes driver if system does not have extended socket device.
      fjes: Do not load fjes driver if extended socket device is not power on.

Ying Xue (2):
      netfilter: nf_nat_sctp: fix ICMP packet to be dropped accidently
      tipc: fix nametbl deadlock at tipc_nametbl_unsubscribe

Zi Shen Lim (1):
      selftests/bpf: fix broken build, take 2

hayeswang (3):
      r8152: fix the list rx_done may be used without initialization
      r8152: set the RMS of RTL8153 according to the mtu
      r8152: fix the rx early size of RTL8153

stephen hemminger (1):
      netvsc: fix race during initialization

 MAINTAINERS                                                        |  18 +--------
 drivers/bluetooth/Kconfig                                          |   3 +-
 drivers/net/ethernet/amd/xgbe/xgbe-common.h                        |  30 +++++++-------
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c                           |  20 +++++-----
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c                           | 102 +++++++++++++++++++++++++++++------------------
 drivers/net/ethernet/aquantia/atlantic/aq_main.c                   |   1 +
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0_internal.h |   1 +
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h |   1 +
 drivers/net/ethernet/broadcom/genet/bcmgenet.c                     |   6 ++-
 drivers/net/ethernet/broadcom/genet/bcmmii.c                       |  15 -------
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c                    |   2 +-
 drivers/net/ethernet/ibm/ibmvnic.c                                 |   2 +
 drivers/net/ethernet/mellanox/mlx4/cmd.c                           |  11 ++++++
 drivers/net/ethernet/mellanox/mlx4/main.c                          |  11 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c                      |   4 ++
 drivers/net/ethernet/mellanox/mlx5/core/en.h                       |   4 --
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c                  |   8 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c                   |   2 -
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c                    |   4 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c                    |  74 +++++++++++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c                    |   5 ++-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h                  |   6 +++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c         |  22 +++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c                     |   2 +-
 drivers/net/ethernet/sfc/efx.c                                     |   2 +-
 drivers/net/ethernet/ti/Kconfig                                    |  10 ++++-
 drivers/net/ethernet/ti/Makefile                                   |   2 +-
 drivers/net/fjes/fjes_main.c                                       |  78 +++++++++++++++++++++++++++++++++---
 drivers/net/hyperv/netvsc.c                                        |   7 +++-
 drivers/net/tun.c                                                  |   2 +
 drivers/net/usb/qmi_wwan.c                                         |   6 +++
 drivers/net/usb/r8152.c                                            |  24 ++++++++----
 drivers/net/vrf.c                                                  |   4 +-
 drivers/net/wireless/ath/ath10k/hw.c                               |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c                  |   5 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c                       |  11 +++---
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h                       |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c                        |  41 +++++++++----------
 drivers/net/wireless/marvell/mwifiex/main.c                        |  11 ++++--
 drivers/net/wireless/marvell/mwifiex/pcie.c                        |  38 +++++++++---------
 drivers/vhost/vsock.c                                              |  41 +++++++++++++++++++
 include/linux/errqueue.h                                           |   2 +
 include/linux/mlx4/device.h                                        |   1 +
 include/linux/virtio_vsock.h                                       |   3 ++
 include/net/af_vsock.h                                             |   3 ++
 include/net/netfilter/nf_conntrack.h                               |   2 +-
 include/net/netfilter/nf_tables.h                                  |  30 +++++++++++++-
 include/net/netfilter/nf_tables_ipv6.h                             |   6 ++-
 include/net/sctp/structs.h                                         |   5 ++-
 kernel/bpf/hashtab.c                                               | 144 +++++++++++++++++++++++++++++++++----------------------------------
 net/batman-adv/bat_iv_ogm.c                                        |  11 ++++++
 net/batman-adv/bat_v.c                                             |  14 +++++--
 net/batman-adv/fragmentation.c                                     |  20 ++++++----
 net/batman-adv/gateway_common.c                                    |   5 +++
 net/batman-adv/soft-interface.c                                    |   1 -
 net/batman-adv/types.h                                             |   2 +
 net/bridge/br_fdb.c                                                |   2 +-
 net/bridge/br_netfilter_hooks.c                                    |  12 +++---
 net/bridge/br_private.h                                            |   9 -----
 net/core/netclassid_cgroup.c                                       |  32 +++++++--------
 net/core/skbuff.c                                                  |  27 ++++++++++---
 net/core/sock.c                                                    |  16 +++++---
 net/ipv4/fib_frontend.c                                            |   3 +-
 net/ipv4/ip_fragment.c                                             |  25 ++++++++----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c                     |   4 ++
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c                           |   5 ---
 net/ipv4/netfilter/nft_masq_ipv4.c                                 |   8 ++--
 net/ipv4/netfilter/nft_redir_ipv4.c                                |   8 ++--
 net/ipv4/tcp.c                                                     |   3 +-
 net/ipv4/tcp_input.c                                               |   2 +-
 net/ipv4/tcp_minisocks.c                                           |   1 +
 net/ipv6/netfilter/nft_masq_ipv6.c                                 |   8 ++--
 net/ipv6/netfilter/nft_redir_ipv6.c                                |   8 ++--
 net/ipv6/route.c                                                   |   2 +
 net/ipv6/udp.c                                                     |   2 +-
 net/mpls/af_mpls.c                                                 |  13 ++++--
 net/netfilter/nf_conntrack_core.c                                  |   6 ++-
 net/netfilter/nf_nat_proto_sctp.c                                  |  13 +++++-
 net/netfilter/nf_tables_api.c                                      |   4 --
 net/netfilter/nft_ct.c                                             |  21 +++++-----
 net/netfilter/nft_meta.c                                           |  40 ++++++++++---------
 net/netfilter/nft_nat.c                                            |   8 ++--
 net/netfilter/nft_set_bitmap.c                                     | 165 +++++++++++++++++++++++++++++++++++++----------------------------------------
 net/netlink/af_netlink.c                                           |  41 +++++++++++++++++++
 net/netlink/genetlink.c                                            |   4 +-
 net/openvswitch/flow_netlink.c                                     |   4 +-
 net/rxrpc/conn_event.c                                             |   4 ++
 net/sched/sch_dsmark.c                                             |  10 ++++-
 net/sctp/associola.c                                               |   6 +--
 net/sctp/output.c                                                  |   7 ++--
 net/sctp/outqueue.c                                                |  11 +++---
 net/socket.c                                                       |  13 +++++-
 net/tipc/subscr.c                                                  |   7 +++-
 net/unix/garbage.c                                                 |  17 ++++----
 net/vmw_vsock/af_vsock.c                                           |  14 +++++++
 net/vmw_vsock/virtio_transport.c                                   |  42 ++++++++++++++++++++
 net/vmw_vsock/virtio_transport_common.c                            |   7 ++++
 net/wireless/nl80211.c                                             | 127 ++++++++++++++++++++++++++---------------------------------
 tools/testing/selftests/bpf/Makefile                               |  19 ++++-----
 tools/testing/selftests/bpf/test_maps.c                            |  29 ++++++++++++--
 100 files changed, 1086 insertions(+), 612 deletions(-)
