From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 21 Apr 2016 15:55:28 -0400 (EDT)
Message-ID: <20160421.155528.162580800516468994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix memory leak in iwlwifi, from Matti Gottlieb.

2) Add missing registration of netfilter arp_tables into initial
   namespace, from Florian Westphal.

3) Fix potential NULL deref in DecNET routing code.

4) Restrict NETLINK_URELEASE to truly bound sockets only, from Dmitry
   Ivanov.

5) Fix dst ref counting in VRF, from David Ahern.

6) Fix TSO segmenting limits in i40e driver, from Alexander Duyck.

7) Fix heap leak in PACKET_DIAG_MCLIST, from Mathias Krause.

8) Ravalidate IPV6 datagram socket cached routes properly, particularly
   with UDP, from Martin KaFai Lau.

9) Fix endian bug in RDS dp_ack_seq handling, from Qing Huang.

10) Fix stats typing in bcmgenet driver, from Eric Dumazet.

11) Openvswitch needs to orphan SKBs before ipv6 fragmentation
    handing, from Joe Stringer.

12) SPI device reference leak in spi_ks8895 PHY driver, from Mark
    Brown.

13) atl2 doesn't actually support scatter-gather, so don't advertise
    the feature.  From Ben Hucthings.

Please pull, thanks a lot!

The following changes since commit 183c948a3cb3efbf45eabed41fa7ee04c193=
78fc:

  Merge tag 'tty-4.6-rc3' of git://git.kernel.org/pub/scm/linux/kernel/=
git/gregkh/tty (2016-04-09 12:32:44 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to b4f70527f052b0c00be4d7cac562baa75b212df5=
:

  openvswitch: use flow protocol when recalculating ipv6 checksums (201=
6-04-21 15:28:47 -0400)

----------------------------------------------------------------
Alexander Duyck (1):
      i40e/i40evf: Limit TSO to 7 descriptors for payload instead of 8 =
per packet

Alexei Starovoitov (1):
      bpf/verifier: reject invalid LD_ABS | BPF_DW instruction

Andrew Goodbody (2):
      cpsw: Prevent NUll pointer dereference with two PHYs
      Revert "Prevent NUll pointer dereference with two PHYs on cpsw"

Arnd Bergmann (3):
      bcma: fix building without OF_IRQ
      rtlwifi: fix gcc-6 indentation warning
      macsec: fix crypto Kconfig dependency

Ben Hutchings (1):
      atl2: Disable unimplemented scatter/gather feature

Bj=A9=AArn Mork (1):
      cdc_mbim: apply "NDP to end" quirk to all Huawei devices

Chris Friesen (1):
      route: do not cache fib route info on local routes with oif

Craig Gallek (2):
      soreuseport: fix ordering for mixed v4/v6 sockets
      soreuseport: test mixed v4/v6 sockets

Daniel Borkmann (1):
      vlan: pull on __vlan_insert_tag error path and fix csum correctio=
n

Daniel Jurgens (2):
      net/mlx4_core: Implement pci_resume callback
      net/mlx4_core: Avoid repeated calls to pci enable/disable

David Ahern (3):
      net: vrf: Fix dst reference counting
      net: vrf: Fix dev refcnt leak due to IPv6 prefix route
      net: ipv6: Do not keep linklocal and loopback addresses

David Daney (1):
      net: thunderx: Fix broken of_node_put() code.

David S. Miller (12):
      decnet: Do not build routes to devices without decnet private dat=
a.
      Merge branch 'tipc-fixes'
      Merge tag 'wireless-drivers-for-davem-2016-04-13' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net-qu=
eue
      Merge tag 'mac80211-for-davem-2016-04-14' of git://git.kernel.org=
/.../jberg/mac80211
      Merge branch 'ipv6-dgram-dst-cache'
      Merge branch 'soreuseport-mixed-v4-v6-fixes'
      Merge branch 'dsa-mv88e6xxx-fix-cross-chip-bridging'
      Merge branch 'tcp-coalesce-merge-timestamps'
      Merge branch 'qed-fixes'
      Merge branch 'mlx4-fixes'

Dmitry Ivanov (2):
      netlink: don't send NETLINK_URELEASE for unbound sockets
      nl80211: check netlink protocol in socket release notification

Emmanuel Grumbach (1):
      iwlwifi: pcie: lower the debug level for RSA semaphore access

Emrah Demir (1):
      mISDN: Fixing missing validation in base_sock_bind()

Eran Ben Elisha (1):
      net/mlx4_en: Split SW RX dropped counter per RX ring

Eric Dumazet (1):
      net: bcmgenet: device stats are unsigned long

Erik Hugne (2):
      tipc: make dist queue pernet
      tipc: purge deferred updates from dead nodes

Eugenia Emantayev (1):
      net/mlx4_core: Don't allow to VF change global pause settings

=46elix Fietkau (1):
      bgmac: fix MAC soft-reset bit for corerev > 4

=46lorian Westphal (1):
      netfilter: arp_tables: register table in initns

Grygorii Strashko (1):
      drivers: net: cpsw: fix wrong regs access in cpsw_ndo_open

Hariprasad Shenai (1):
      cxgb4: Stop Rx Queues before freeing it up

Jacob Keller (1):
      fm10k: fix multi-bit VLAN update requests from VF

Jia-Ju Bai (1):
      b43: Fix memory leaks in b43_bus_dev_ssb_init and b43_bus_dev_bcm=
a_init

Joe Stringer (1):
      openvswitch: Orphan skbs before IPv6 defrag

John Crispin (1):
      net: mediatek: update the IRQ part of the binding document

Jorgen Hansen (1):
      VSOCK: Only check error on skb_recv_datagram when skb is NULL

Jozsef Kadlecsik (1):
      netfilter: nf_conntrack_tcp: Fix stack out of bounds when parsing=
 TCP options

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2016-03-30' of https://git.kernel.or=
g/.../iwlwifi/iwlwifi-fixes

Konstantin Khlebnikov (3):
      net/mlx4_en: allocate non 0-order pages for RX ring with __GFP_NO=
MEMALLOC
      net/mlx4_en: do batched put_page using atomic_sub
      cls_cgroup: get sk_classid only from full sockets

Lars Persson (1):
      net: sched: do not requeue a NULL skb

Manish Chopra (3):
      qede: Fix various memory allocation error flows for fastpath
      qede: Fix setting Skb network header
      qede: Fix single MTU sized packet from firmware GRO flow

Marcelo Ricardo Leitner (1):
      sctp: avoid refreshing heartbeat timer too often

Mark Brown (1):
      net: phy: spi_ks8895: Don't leak references to SPI devices

Martin KaFai Lau (7):
      ipv6: datagram: Refactor flowi6 init codes to a new function
      ipv6: datagram: Refactor dst lookup and update codes to a new fun=
ction
      ipv6: datagram: Update dst cache of a connected datagram sk durin=
g pmtu update
      ipv6: udp: Do a route lookup and update during release_cb
      tcp: Fix SOF_TIMESTAMPING_TX_ACK when handling dup acks
      tcp: Merge tx_flags and tskey in tcp_collapse_retrans
      tcp: Merge tx_flags and tskey in tcp_shifted_skb

Mathias Krause (1):
      packet: fix heap info leak in PACKET_DIAG_MCLIST sock_diag interf=
ace

Matti Gottlieb (1):
      iwlwifi: mvm: fix memory leak in paging

Neil Armstrong (2):
      net: ethernet: davinci_emac: Fix Unbalanced pm_runtime_enable
      net: ethernet: davinci_emac: Fix platform_data overwrite

Phil Reid (1):
      net: stmmac: socfgpa: Ensure emac bit set in System Manger for PT=
P

Phil Sutter (1):
      netfilter: ebtables: Fix extension lookup with identical name

Qing Huang (1):
      RDS: fix endianness for dp_ack_seq

Rafa=A9=A9 Mi=A9=A9ecki (1):
      bgmac: reset & enable Ethernet core before using it

Sergei Shtylyov (1):
      sh_eth: re-enable-E-MAC interrupts in sh_eth_set_ringparam()

Shrikrishna Khare (1):
      Driver: Vmxnet3: set CHECKSUM_UNNECESSARY for IPv6 packets

Simon Horman (1):
      openvswitch: use flow protocol when recalculating ipv6 checksums

Vivien Didelot (3):
      net: dsa: mv88e6xxx: unlock DSA and CPU ports
      net: dsa: mv88e6xxx: enable SA learning on DSA ports
      net: dsa: mv88e6xxx: share the same default FDB

Wolfram Sang (1):
      net: ethernet: renesas: ravb_main: test clock rate to avoid divis=
ion by 0

santosh.shilimkar@oracle.com (1):
      RDS: Fix the atomicity for congestion map update

stephen hemminger (1):
      devlink: add missing install of header

 Documentation/devicetree/bindings/net/mediatek-net.txt |   7 ++-
 drivers/bcma/main.c                                    |  17 ++------
 drivers/isdn/mISDN/socket.c                            |   3 ++
 drivers/net/Kconfig                                    |   1 +
 drivers/net/dsa/mv88e6xxx.c                            |  34 +++------=
------
 drivers/net/ethernet/atheros/atlx/atl2.c               |   2 +-
 drivers/net/ethernet/broadcom/bgmac.c                  |   5 +++
 drivers/net/ethernet/broadcom/bgmac.h                  |   6 +--
 drivers/net/ethernet/broadcom/genet/bcmgenet.c         |   6 ++-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c      |   5 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h             |   3 ++
 drivers/net/ethernet/chelsio/cxgb4/sge.c               |  20 +++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c             |  33 +++++++++=
+++++
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c            |  30 +++++++++=
----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c            |  49 +++++++++=
++----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h            |  10 +++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c          |  49 +++++++++=
++----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h          |  10 +++--
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c        |   5 ++-
 drivers/net/ethernet/mellanox/mlx4/en_port.c           |   5 ++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c             |  12 ++++--
 drivers/net/ethernet/mellanox/mlx4/main.c              |  76 +++++++++=
+++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h              |   2 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h           |   1 +
 drivers/net/ethernet/mellanox/mlx4/port.c              |  13 ++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c           | 157 +++++++++=
+++++++++++++++++++++++++++++++++------------------------
 drivers/net/ethernet/renesas/ravb_main.c               |   3 ++
 drivers/net/ethernet/renesas/sh_eth.c                  |   6 +--
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |  16 +++++--
 drivers/net/ethernet/ti/cpsw.c                         |   4 +-
 drivers/net/ethernet/ti/davinci_emac.c                 |   3 +-
 drivers/net/phy/spi_ks8995.c                           |   2 +-
 drivers/net/usb/cdc_mbim.c                             |   9 +++-
 drivers/net/vmxnet3/vmxnet3_drv.c                      |  12 ++++--
 drivers/net/vmxnet3/vmxnet3_int.h                      |   4 +-
 drivers/net/vrf.c                                      | 177 +++++++--=
------------------------------------------------------------------
 drivers/net/wireless/broadcom/b43/main.c               |   6 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c      |   2 +
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c           |   2 -
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c        |   4 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/dm.c    |   6 +--
 include/linux/mlx4/device.h                            |   7 +++
 include/linux/rculist_nulls.h                          |  39 +++++++++=
++++++++
 include/net/cls_cgroup.h                               |   7 ++-
 include/net/ip6_route.h                                |   3 ++
 include/net/ipv6.h                                     |   2 +
 include/net/route.h                                    |   3 ++
 include/net/sctp/structs.h                             |   8 +++-
 include/net/sock.h                                     |   6 ++-
 include/net/tcp.h                                      |   2 +
 include/uapi/linux/Kbuild                              |   1 +
 kernel/bpf/verifier.c                                  |   1 +
 net/bridge/netfilter/ebtables.c                        |   6 ++-
 net/core/skbuff.c                                      |   7 ++-
 net/decnet/dn_route.c                                  |   9 +++-
 net/ipv4/netfilter/arptable_filter.c                   |   6 +++
 net/ipv4/route.c                                       |  19 ++++++--
 net/ipv4/tcp_input.c                                   |   4 +-
 net/ipv4/tcp_output.c                                  |  16 +++++++
 net/ipv4/udp.c                                         |   9 +++-
 net/ipv6/addrconf.c                                    |  22 +++++++++=
-
 net/ipv6/datagram.c                                    | 169 +++++++++=
+++++++++++++++++++++++++++++++++++---------------------------
 net/ipv6/route.c                                       |  19 ++++++--
 net/ipv6/udp.c                                         |   1 +
 net/netfilter/nf_conntrack_proto_tcp.c                 |   4 ++
 net/netlink/af_netlink.c                               |   2 +-
 net/openvswitch/actions.c                              |   4 +-
 net/openvswitch/conntrack.c                            |   1 +
 net/packet/af_packet.c                                 |   1 +
 net/rds/cong.c                                         |   4 +-
 net/rds/ib_cm.c                                        |   2 +-
 net/sched/sch_generic.c                                |   5 ++-
 net/sctp/outqueue.c                                    |  15 ++++---
 net/sctp/sm_make_chunk.c                               |   3 +-
 net/sctp/sm_sideeffect.c                               |  36 +++++++--=
-------
 net/sctp/transport.c                                   |  19 +++++---
 net/tipc/core.c                                        |   1 +
 net/tipc/core.h                                        |   3 ++
 net/tipc/name_distr.c                                  |  35 +++++++++=
++----
 net/vmw_vsock/vmci_transport.c                         |   7 +--
 net/wireless/nl80211.c                                 |   2 +-
 tools/testing/selftests/net/.gitignore                 |   1 +
 tools/testing/selftests/net/Makefile                   |   2 +-
 tools/testing/selftests/net/reuseport_dualstack.c      | 208 +++++++++=
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++++++
 84 files changed, 1009 insertions(+), 529 deletions(-)
 create mode 100644 tools/testing/selftests/net/reuseport_dualstack.c
