From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 14 Mar 2017 20:41:42 -0700 (PDT)
Message-ID: <20170314.204142.879030340966547783.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Ensure that mtu is at least IPV6_MIN_MTU in ipv6 VTI tunnel driver, from
   Steffen Klassert.

2) Fix crashes when user tries to get_next_key on an LPM bpf map, from Alexei
   Starovoitov.

3) Fix detection of VLAN fitlering feature for bnx2x VF devices, from Michal
   Schmidt.

4) We can get a divide by zero when TCP socket are morphed into listening
   state, fix from Eric Dumazet.

5) Fix socket refcounting bugs in skb_complete_wifi_ack() and
   skb_complete_tx_timestamp().  From Eric Dumazet.

6) Use after free in dccp_feat_activate_values(), also from Eric Dumazet.

7) Like bonding team needs to use ETH_MAX_MTU as netdev->max_mtu, from
   Jarod Wilson.

8) Fix use after free in vrf_xmit(), from David Ahern.

9) Don't do UDP Fragmentation Offload on IPComp ipsec packets, from
   Alexey Kodanev.

10) Properly check napi_complete_done() return value in order to decide
    whether to re-enable IRQs or not in amd-xgbe driver, from Thomas
    Lendacky.

11) Fix double free of hwmon device in marvell phy driver, from Andrew
    Lunn.

12) Don't crash on malformed netlink attributes in act_connmark, from
    Etienne Noss.

13) Don't remove routes with a higher metric in ipv6 ECMP route replace,
    from Sabrina Dubroca.

14) Don't write into a cloned SKB in ipv6 fragmentation handling, from
    Florian Westphal.

15) Fix routing redirect races in dccp and tcp, basically the ICMP handler
    can't modify the socket's cached route in it's locked by the user
    at this moment.  From Jon Maxwell.

Please pull, thanks a lot!

The following changes since commit 8d70eeb84ab277377c017af6a21d0a337025dede:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-03-04 17:31:39 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to 1e6a1cd888de06b09d2341d782aadb20c6034210:

  Merge branch 'qed-fixes' (2017-03-14 11:37:06 -0700)

----------------------------------------------------------------
Alexander Potapenko (1):
      net: initialize msg.msg_flags in recvfrom

Alexei Starovoitov (4):
      bpf: add get_next_key callback to LPM map
      bpf: fix struct htab_elem layout
      bpf: convert htab map to hlist_nulls
      selftests/bpf: fix broken build

Alexey Khoroshilov (1):
      net/sched: act_skbmod: remove unneeded rcu_read_unlock in tcf_skbmod_dump

Alexey Kodanev (1):
      udp: avoid ufo handling on IP payload compression packets

Andrew Lunn (1):
      net: phy: marvell: Fix double free of hwmon device

Andrey Vagin (1):
      net: use net->count to check whether a netns is alive or not

Arnd Bergmann (1):
      net/mlx5e: add IPV6 dependency

Blomme, Maarten (2):
      spi_ks8995: fix "BUG: key accdaa28 not in .data!"
      spi_ks8995: regs_size incorrect for some devices

Christian Lamparter (2):
      dt: emac: document device-tree based phy discovery and setup
      net: ibm: emac: fix regression caused by emac_dt_phy_probe()

Daniel Borkmann (1):
      bpf: improve read-only handling

Daniel Jurgens (1):
      net/mlx5: Don't save PCI state when PCI error is detected

David Ahern (4):
      vrf: Fix use-after-free in vrf_xmit
      net: ipv6: Remove redundant RTA_OIF in multipath routes
      mpls: Send route delete notifications when router module is unloaded
      mpls: Do not decrement alive counter for unregister events

David Arcari (1):
      net: ethernet: aquantia: call set_irq_affinity_hint before free_irq

David Howells (4):
      rxrpc: Call state should be read with READ_ONCE() under some circumstances
      net: Work around lockdep limitation in sockets that use sockets
      rxrpc: rxrpc_kernel_send_data() needs to handle failed call better
      rxrpc: Wake up the transmitter if Rx window size increases on the peer

David S. Miller (12):
      Merge branch 'bnx2x-fixes'
      Merge branch 'sock_hold-misuses'
      Merge branch 'rds-fixes'
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      net: Revert ksettings conversions.
      Merge branch 'thunderx-misc-fixes'
      Merge branch 'bpf-htab-fixes'
      Merge branch 'bnxt_en-misc-small-fixes'
      Merge branch 'bcmgenet-minor-bug-fixes'
      Merge branch 'mlx5-fixes'
      Merge branch 'mlxsw-small-fixes'
      Merge branch 'qed-fixes'

Dmitry V. Levin (1):
      uapi: fix linux/packet_diag.h userspace compilation error

Doug Berger (7):
      net: bcmgenet: correct the RBUF_OVFL_CNT and RBUF_ERR_CNT MIB values
      net: bcmgenet: correct MIB access of UniMAC RUNT counters
      net: bcmgenet: reserved phy revisions must be checked first
      net: bcmgenet: power down internal phy if open or resume fails
      net: bcmgenet: synchronize irq0 status between the isr and task
      net: bcmgenet: Power up the internal PHY before probing the MII
      net: bcmgenet: decouple flow control from bcmgenet_tx_reclaim

Edwin Chan (1):
      net: bcmgenet: add begin/complete ethtool ops

Eric Dumazet (4):
      tcp: fix various issues for sockets morphing to listen state
      net: fix socket refcounting in skb_complete_wifi_ack()
      net: fix socket refcounting in skb_complete_tx_timestamp()
      dccp: fix use-after-free in dccp_feat_activate_values

Etienne Noss (1):
      act_connmark: avoid crashing on malformed nlattrs with null parms

Eugenia Emantayev (1):
      net/mlx5e: Fix loopback selftest

Florian Fainelli (1):
      net: phy: Do not perform software reset for Generic PHY

Florian Westphal (3):
      xfrm: policy: init locks early
      ipv6: avoid write to a possibly cloned skb
      bridge: drop netfilter fake rtable unconditionally

Hannes Frederic Sowa (2):
      tun: fix premature POLLOUT notification on tun devices
      dccp: fix memory leak during tear-down of unsuccessful connection request

Huy Nguyen (1):
      net/mlx5e: remove IEEE/CEE mode check when setting DCBX mode

Igor Druzhinin (1):
      xen-netback: fix race condition on XenBus disconnect

Jarod Wilson (1):
      team: use ETH_MAX_MTU as max mtu

Jiri Pirko (3):
      mlxsw: spectrum_flower: Remove bogus warns in mlxsw_sp_flower_destroy
      mlxsw: reg: Fix SPVM max record count
      mlxsw: reg: Fix SPVMLR max record count

Johan Hovold (2):
      isdn/gigaset: fix NULL-deref at probe
      net: wimax/i2400m: fix NULL-deref at probe

Jon Maxwell (1):
      dccp/tcp: fix routing redirect race

LABBE Corentin (1):
      tun: remove copyright printing

Lendacky, Thomas (1):
      amd-xgbe: Enable IRQs only if napi_complete_done() is true

Michael Chan (4):
      bnxt_en: Perform function reset earlier during probe.
      bnxt_en: Call bnxt_ulp_stop() during tx timeout.
      bnxt_en: Check if firmware LLDP agent is running.
      bnxt_en: Ignore 0 value in autoneg supported speed from firmware.

Michal Schmidt (7):
      bnx2x: prevent crash when accessing PTP with interface down
      bnx2x: lower verbosity of VF stats debug messages
      bnx2x: fix possible overrun of VFPF multicast addresses array
      bnx2x: fix detection of VLAN filtering feature for VF
      bnx2x: do not rollback VF MAC/VLAN filters we did not configure
      bnx2x: fix incorrect filter count in an error message
      bnx2x: add missing configuration of VF VLAN filters

Mintz, Yuval (4):
      qed: Fix mapping leak on LL2 rx flow
      qed: Free previous connections when releasing iSCSI
      qed: Correct out-of-bound access in OOO history
      qed: Enable iSCSI Out-of-Order

Neil Jerram (1):
      Make IP 'forwarding' doc more precise

Nicolas Dichtel (1):
      vxlan: fix ovs support

Or Gerlitz (1):
      net/mlx5e: Avoid wrong identification of rules on deletion

Paolo Abeni (1):
      net/tunnel: set inner protocol in network gro hooks

Paul Blakey (1):
      net/mlx5: Fix create autogroup prev initializer

Philippe Reynes (8):
      net: smsc: smc911x: use new api ethtool_{get|set}_link_ksettings
      net: smsc: smc91x: use new api ethtool_{get|set}_link_ksettings
      net: sun: cassini: use new api ethtool_{get|set}_link_ksettings
      net: sun: niu: use new api ethtool_{get|set}_link_ksettings
      net: sun: sungem: use new api ethtool_{get|set}_link_ksettings
      net: sun: sunhme: use new api ethtool_{get|set}_link_ksettings
      net: toshiba: ps3_genic_net: use new api ethtool_{get|set}_link_ksettings
      net: toshiba: spider_net: use new api ethtool_{get|set}_link_ksettings

Ram Amrani (2):
      qed: Align CIDs according to DORQ requirement
      qed: Fix interrupt flags on Rx LL2

Sabrina Dubroca (1):
      ipv6: make ECMP route replacement less greedy

Sowmini Varadhan (3):
      rds: tcp: Take explicit refcounts on struct net
      rds: tcp: Reorder initialization sequence in rds_tcp_init to avoid races
      rds: tcp: Sequence teardown of listen and acceptor sockets to avoid races

Steffen Klassert (2):
      xfrm: Don't use sk_family for socket policy lookups
      vti6: Don't report path MTU below IPV6_MIN_MTU.

Sunil Goutham (3):
      net: thunderx: Fix IOMMU translation faults
      net: thunderx: Fix LMAC mode debug prints for QSGMII mode
      net: thunderx: Fix invalid mac addresses for node1 interfaces

Thanneeru Srinivasulu (1):
      net: thunderx: Allow IPv6 frames with zero UDP checksum

Thomas Falcon (2):
      ibmvnic: Fix overflowing firmware/hardware TX queue
      ibmvnic: Allocate number of rx/tx buffers agreed on by firmware

Tomer Tayar (1):
      qed: Prevent creation of too-big u32-chains

VSR Burru (1):
      liquidio: improve UDP TX performance

Vlad Yasevich (1):
      net: Resend IGMP memberships upon peer notification.

WANG Cong (1):
      ipv6: reorder icmpv6_init() and ip6_mr_init()

Zhao Qiang (1):
      ucc/hdlc: fix two little issue

Zhu Yanjun (1):
      rds: ib: add error handle

robert.foss@collabora.com (1):
      qed: Fix copy of uninitialized memory

stephen hemminger (1):
      netvsc: handle select_queue when device is being removed

 Documentation/devicetree/bindings/powerpc/4xx/emac.txt |  62 ++++++++++++++++++++++++++-
 Documentation/networking/ip-sysctl.txt                 |   3 +-
 crypto/af_alg.c                                        |   9 ++--
 crypto/algif_hash.c                                    |   9 ++--
 drivers/isdn/gigaset/bas-gigaset.c                     |   3 ++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c               |  10 +----
 drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c   |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c       |  36 +++++++++++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c      |  24 +++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h      |   1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c       |  40 ++++++++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.c              |  25 ++++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h              |   1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c          |   2 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c         | 206 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--------------------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h         |  16 ++++---
 drivers/net/ethernet/cavium/liquidio/lio_main.c        | 110 +++++++++++++++++++++++------------------------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c     | 104 ++++++++++++++++++++++++---------------------
 drivers/net/ethernet/cavium/liquidio/octeon_config.h   |   6 +--
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c     |  17 +-------
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h     |   4 +-
 drivers/net/ethernet/cavium/liquidio/octeon_main.h     |  42 ------------------
 drivers/net/ethernet/cavium/liquidio/octeon_network.h  |  43 ++++++++++++-------
 drivers/net/ethernet/cavium/thunder/nic.h              |   1 +
 drivers/net/ethernet/cavium/thunder/nicvf_main.c       |  12 +++++-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c     | 184 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----------------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h     |   4 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c      |  64 +++++++++++++++++++---------
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h      |   1 -
 drivers/net/ethernet/ibm/emac/core.c                   |  25 +++++++----
 drivers/net/ethernet/ibm/ibmvnic.c                     |  43 +++++++++++++++----
 drivers/net/ethernet/ibm/ibmvnic.h                     |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig        |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c     |  10 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c  |   5 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c        |  33 ++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c         |   5 ++-
 drivers/net/ethernet/mellanox/mlxsw/reg.h              |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c  |   4 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c              |   3 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c              |   5 +--
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c            |  31 ++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_ll2.c              |  13 +++---
 drivers/net/ethernet/qlogic/qed/qed_ooo.c              |   2 +
 drivers/net/ethernet/smsc/smc91x.c                     |  47 +++++++++++----------
 drivers/net/hyperv/hyperv_net.h                        |   3 +-
 drivers/net/hyperv/netvsc.c                            |   8 +---
 drivers/net/hyperv/netvsc_drv.c                        |  11 ++---
 drivers/net/phy/marvell.c                              |  15 -------
 drivers/net/phy/phy_device.c                           |   2 +-
 drivers/net/phy/spi_ks8995.c                           |   3 +-
 drivers/net/team/team.c                                |   1 +
 drivers/net/tun.c                                      |  19 +++++++--
 drivers/net/vrf.c                                      |   3 +-
 drivers/net/vxlan.c                                    |  73 +++++++++++++++++---------------
 drivers/net/wan/fsl_ucc_hdlc.c                         |   4 +-
 drivers/net/wimax/i2400m/usb.c                         |   3 ++
 drivers/net/xen-netback/interface.c                    |  26 ++++++++----
 drivers/net/xen-netback/netback.c                      |   2 +-
 drivers/net/xen-netback/xenbus.c                       |  20 ++++-----
 drivers/staging/lustre/lnet/lnet/lib-socket.c          |   4 +-
 fs/dlm/lowcomms.c                                      |   2 +-
 fs/ocfs2/cluster/tcp.c                                 |   2 +-
 include/crypto/if_alg.h                                |   2 +-
 include/linux/dccp.h                                   |   1 +
 include/linux/filter.h                                 |  16 +++++--
 include/linux/list_nulls.h                             |   5 +++
 include/linux/net.h                                    |   2 +-
 include/linux/phy.h                                    |   4 ++
 include/linux/rculist_nulls.h                          |  14 ++++++
 include/net/inet_common.h                              |   3 +-
 include/net/inet_connection_sock.h                     |   2 +-
 include/net/sctp/structs.h                             |   3 +-
 include/net/sock.h                                     |   9 ++--
 include/uapi/linux/packet_diag.h                       |   2 +-
 kernel/bpf/hashtab.c                                   | 119 ++++++++++++++++++++++++++++++++++-----------------
 kernel/bpf/lpm_trie.c                                  |   6 +++
 net/atm/svc.c                                          |   5 ++-
 net/ax25/af_ax25.c                                     |   3 +-
 net/bluetooth/l2cap_sock.c                             |   2 +-
 net/bluetooth/rfcomm/sock.c                            |   3 +-
 net/bluetooth/sco.c                                    |   2 +-
 net/bridge/br_input.c                                  |   1 +
 net/bridge/br_netfilter_hooks.c                        |  21 ---------
 net/core/dev.c                                         |   1 +
 net/core/net-sysfs.c                                   |   6 +--
 net/core/skbuff.c                                      |  30 +++++++------
 net/core/sock.c                                        | 106 +++++++++++++++++++++++++---------------------
 net/dccp/ccids/ccid2.c                                 |   1 +
 net/dccp/ipv4.c                                        |   3 +-
 net/dccp/ipv6.c                                        |   8 ++--
 net/dccp/minisocks.c                                   |  24 +++++++----
 net/decnet/af_decnet.c                                 |   5 ++-
 net/ipv4/af_inet.c                                     |   9 ++--
 net/ipv4/inet_connection_sock.c                        |   2 +-
 net/ipv4/ip_output.c                                   |   2 +-
 net/ipv4/tcp_ipv4.c                                    |  10 +++--
 net/ipv4/tcp_timer.c                                   |   6 ++-
 net/ipv6/af_inet6.c                                    |  10 ++---
 net/ipv6/ip6_fib.c                                     |   2 +
 net/ipv6/ip6_offload.c                                 |   4 +-
 net/ipv6/ip6_output.c                                  |   9 +++-
 net/ipv6/ip6_vti.c                                     |   8 +++-
 net/ipv6/route.c                                       |  11 ++---
 net/ipv6/tcp_ipv6.c                                    |   8 ++--
 net/irda/af_irda.c                                     |   5 ++-
 net/iucv/af_iucv.c                                     |   2 +-
 net/llc/af_llc.c                                       |   4 +-
 net/mpls/af_mpls.c                                     |   4 +-
 net/netrom/af_netrom.c                                 |   3 +-
 net/nfc/llcp_sock.c                                    |   2 +-
 net/phonet/pep.c                                       |   6 ++-
 net/phonet/socket.c                                    |   4 +-
 net/rds/connection.c                                   |   1 +
 net/rds/ib_cm.c                                        |  47 ++++++++++++++++-----
 net/rds/rds.h                                          |   6 +--
 net/rds/tcp.c                                          |  38 +++++++++--------
 net/rds/tcp.h                                          |   2 +-
 net/rds/tcp_listen.c                                   |  11 +++--
 net/rose/af_rose.c                                     |   3 +-
 net/rxrpc/input.c                                      |  27 ++++++++----
 net/rxrpc/recvmsg.c                                    |   4 +-
 net/rxrpc/sendmsg.c                                    |  49 +++++++++++++--------
 net/sched/act_connmark.c                               |   3 ++
 net/sched/act_skbmod.c                                 |   1 -
 net/sctp/ipv6.c                                        |   5 ++-
 net/sctp/protocol.c                                    |   5 ++-
 net/sctp/socket.c                                      |   4 +-
 net/smc/af_smc.c                                       |   2 +-
 net/socket.c                                           |   5 ++-
 net/tipc/socket.c                                      |   8 ++--
 net/unix/af_unix.c                                     |   5 ++-
 net/vmw_vsock/af_vsock.c                               |   3 +-
 net/x25/af_x25.c                                       |   3 +-
 net/xfrm/xfrm_policy.c                                 |  19 ++++-----
 tools/include/uapi/linux/bpf_perf_event.h              |  18 ++++++++
 tools/testing/selftests/bpf/Makefile                   |   4 +-
 tools/testing/selftests/bpf/test_verifier.c            |   4 ++
 139 files changed, 1447 insertions(+), 826 deletions(-)
 create mode 100644 tools/include/uapi/linux/bpf_perf_event.h
