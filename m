From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 17 Nov 2015 16:48:06 -0500 (EST)
Message-ID: <20151117.164806.803638279073968531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix list tests in netfilter ingress support, from Florian Westphal.

2) Fix reversal of input and output interfaces in ingress hook
   invocation, from Pablo Neira Ayuso.

3) We have a use after free in r8169, caught by Dave Jones, fixed by
   Francois Romieu.

4) Splice use-after-free fix in AF_UNIX frmo Hannes Frederic Sowa.

5) Three ipv6 route handling bug fixes from Martin KaFai Lau:
   a) Don't create clone routes not managed by the fib6 tree
   b) Don't forget to check expiration of DST_NOCACHE routes.
   c) Handle rt->dst.from =3D=3D NULL properly.

6) Several AF_PACKET fixes wrt. transport header setting and SKB
   protocol setting, from Daniel Borkmann.

7) Fix thunder driver crash on shutdown, from Pavel Fedin.

8) Several Mellanox driver fixes (max MTU calculations, use of correct
   DMA unmap in TX path, etc.) from Saeed Mahameed, Tariq Toukan,
   Doron Tsur, Achiad Shochat, Eran Ben Elisha, and Noa Osherovich.

9) Several mv88e6060 DSA driver fixes (wrong bit definitions for certai=
n
   registers, etc.) from Neil Armstrong.

10) Make sure to disable preemption while updating per-cpu stats of ip
    tunnels, from Jason A. Donenfeld.

11) Various ARM64 bpf JIT fixes, from Yang Shi.

12) Flush icache properly in ARM JITs, from Daniel Borkmann.

13) Fix masking of RX and TX interrupts in ravb driver, from Masaru
    Nagai.

14) Fix netdev feature propagation for devices not implementing
    ->ndo_set_features().  From Nikolay Aleksandrov.

15) Big endian fix in vmxnet3 driver, from Shrikrishna Khare.

16) RAW socket code increments incorrect SNMP counters, fix from
    Ben Cartwright-Cox.

17) IPv6 multicast SNMP counters are bumped twice, fix from Neil
    Horman.

18) Fix handling of VLAN headers on stacked devices when REORDER
    is disabled.  From Vlad Yasevich.

19) Fix SKB leaks and use-after-free in ipvlan and macvlan drivers,
    from Sabrina Dubroca.

Please pull, thanks a lot!

The following changes since commit c5a37883f42be712a989e54d5d6c0159b0e5=
6599:

  Merge branch 'akpm' (patches from Andrew) (2015-11-10 21:14:23 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to e7523a497d48a9921983a80670f7a02dc4639d41=
:

  MAINTAINERS: Update Mellanox's Eth NIC driver entries (2015-11-17 15:=
25:45 -0500)

----------------------------------------------------------------
Achiad Shochat (1):
      net/mlx5e: Use the right DMA free function on TX path

Andrew Lunn (2):
      phy: marvell: Add support for 88E1540 PHY
      net: phy: Use interrupts when available in NOLINK state

Anthony Lineham (1):
      netfilter: Fix removal of GRE expectation entries created by PPTP

Arnd Bergmann (3):
      netfilter: nfnetlink_log: work around uninitialized variable warn=
ing
      netfilter: fix xt_TEE and xt_TPROXY dependencies
      stmmac: avoid ipq806x constant overflow warning

Ben Cartwright-Cox (1):
      raw: increment correct SNMP counters for ICMP messages

Bj=F8rn Mork (1):
      net/core: use netdev name in warning if no parent

Colin Ian King (1):
      fjes: fix inconsistent indenting

Daniel Borkmann (7):
      packet: do skb_probe_transport_header when we actually have data
      packet: always probe for transport header
      packet: only allow extra vlan len on ethernet devices
      packet: infer protocol from ethernet header if unset
      packet: fix tpacket_snd max frame len
      bpf, arm: start flushing icache range from header
      bpf, arm64: start flushing icache range from header

Daniele Palmas (1):
      net: usb: cdc_ether: add Dell DW5580 as a mobile broadband adapte=
r

David S. Miller (6):
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'ipv6-route-fixes'
      Merge branch 'packet-fixes'
      Merge branch 'mellanox-net-fixes'
      Merge branch 'mv88e6060-fixes'
      Merge branch 'vlan-reorder'

Doron Tsur (1):
      net/mlx5e: Max mtu comparison fix

Dragos Tatulea (1):
      net: switchdev: fix return code of fdb_dump stub

Eran Ben Elisha (1):
      net/mlx4_core: Fix sleeping while holding spinlock at rem_slave_c=
ounters

Eric Dumazet (2):
      tcp: ensure proper barriers in lockless contexts
      ipvs: use skb_to_full_sk() helper

=46lorian Westphal (1):
      netfilter: ingress: don't use nf_hook_list_active

Hannes Frederic Sowa (4):
      af-unix: fix use-after-free with concurrent readers while splicin=
g
      af_unix: don't append consumed skbs to sk_receive_queue
      rtnetlink: fix frame size warning in rtnl_fill_ifinfo
      af_unix: take receive queue lock while appending new skb

Ido Schimmel (1):
      switchdev: bridge: Check return code is not EOPNOTSUPP

Ivan Vecera (2):
      be2net: remove unused local rsstable array
      be2net: replace hardcoded values with existing define

Jason A. Donenfeld (1):
      ip_tunnel: disable preemption when updating per-cpu tstats

Jozsef Kadlecsik (3):
      netfilter: ipset: Fix extension alignment
      netfilter: ipset: Fix hash:* type expiration
      netfilter: ipset: Fix hash type expire: release empty hash bucket=
 block

Julia Lawall (2):
      net: cavium: liquidio: constify pci_error_handlers structures
      sfc: constify pci_error_handlers structures

Kamal Mostafa (1):
      tools/net: Use include/uapi with __EXPORTED_HEADERS__

Martin KaFai Lau (3):
      ipv6: Avoid creating RTF_CACHE from a rt that is not managed by f=
ib6 tree
      ipv6: Check expire on DST_NOCACHE route
      ipv6: Check rt->dst.from for the DST_NOCACHE route

Martin Zhang (1):
      net: use skb_clone to avoid alloc_pages failure.

Masaru Nagai (2):
      ravb: Fix int mask value overwritten issue
      ravb: remove unhandle int cause

M=E5ns Rullg=E5rd (2):
      net: phy: at803x: support interrupt on 8030 and 8035
      net: phy: vitesse: add support for VSC8601

Neil Armstrong (6):
      net: dsa: mv88e6060: remove poll_link callback
      net: dsa: mv88e6060: use the correct InitReady bit
      net: dsa: mv88e6060: use the correct MaxFrameSize bit
      net: dsa: mv88e6060: use the correct bit shift for mac0
      net: dsa: mv88e6060: add register defines header file
      net: dsa: mv88e6060: replace magic values with register defines

Neil Horman (1):
      snmp: Remove duplicate OUTMCAST stat increment

Nikolay Aleksandrov (3):
      net: fix feature changes on devices without ndo_set_features
      net: fix __netdev_update_features return on ndo_set_features fail=
ure
      net/core: revert "net: fix __netdev_update_features return.." and=
 add comment

Noa Osherovich (1):
      net/mlx4_core: Avoid returning success in case of an error flow

Ondrej Zary (2):
      dl2k: Add support for IP1000A-based cards
      ipg: Remove ipg driver

Or Gerlitz (1):
      MAINTAINERS: Update Mellanox's Eth NIC driver entries

Pablo Neira Ayuso (4):
      netfilter: ingress: fix wrong input interface on hook
      Merge branch 'master' of git://blackhole.kfki.hu/nf
      net: add __netdev_alloc_pcpu_stats() to indicate gfp flags
      netfilter: nf_tables: add clone interface to expression operation=
s

Pavel Fedin (3):
      net: thunder: Fix crash upon shutdown after failed probe
      net: smsc911x: Reset PHY during initialization
      net: thunder: Check for driver data in nicvf_remove()

Sabrina Dubroca (3):
      ipvlan: fix leak in ipvlan_rcv_frame
      ipvlan: fix use after free of skb
      macvlan: fix leak in macvlan_handle_frame

Saeed Mahameed (1):
      net/mlx5e: Fix inline header size calculation

Shrikrishna Khare (1):
      Driver: Vmxnet3: Fix use of mfTableLen for big endian architectur=
es

Tariq Toukan (1):
      net/mlx5e: Added self loopback prevention

Timo Ter=E4s (1):
      via-velocity: unconditionally drop frames with bad l2 length

Tobias Klauser (2):
      packet: Don't check frames_per_block against negative values
      packet: Use PAGE_ALIGNED macro

Vlad Yasevich (2):
      vlan: Fix untag operations of stacked vlans with REORDER_HEADER o=
ff
      vlan: Do not put vlan headers back on bridge and macvlan ports

Yang Shi (3):
      arm64: bpf: fix JIT frame pointer setup
      bpf: samples: exclude asm/sysreg.h for arm64
      arm64: bpf: make BPF prologue and epilogue align with ARM64 AAPCS

Yuval Mintz (1):
      bnx2x: Fix VLANs null-pointer for 57710, 57711

fran=E7ois romieu (1):
      r8169: fix kasan reported skb use-after-free.

lucien (1):
      sctp: translate host order to network order when setting a hmacid

 MAINTAINERS                                           |   17 +-
 arch/arm/net/bpf_jit_32.c                             |    2 +-
 arch/arm64/net/bpf_jit_comp.c                         |   48 +-
 drivers/net/dsa/mv88e6060.c                           |  114 ++---
 drivers/net/dsa/mv88e6060.h                           |  111 +++++
 drivers/net/ethernet/Kconfig                          |    1 -
 drivers/net/ethernet/Makefile                         |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |    2 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c       |    2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c      |   10 +-
 drivers/net/ethernet/dlink/Kconfig                    |    5 +-
 drivers/net/ethernet/dlink/dl2k.c                     |   55 +-
 drivers/net/ethernet/dlink/dl2k.h                     |   15 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c        |   19 +-
 drivers/net/ethernet/emulex/benet/be_main.c           |    2 +-
 drivers/net/ethernet/icplus/Kconfig                   |   13 -
 drivers/net/ethernet/icplus/Makefile                  |    5 -
 drivers/net/ethernet/icplus/ipg.c                     | 2300 ---------=
-----------------------------------------------------------------------=
----
 drivers/net/ethernet/icplus/ipg.h                     |  748 ---------=
------------------
 drivers/net/ethernet/mellanox/mlx4/main.c             |    8 +-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |   39 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h          |   10 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c     |   50 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c       |   76 +--
 drivers/net/ethernet/realtek/r8169.c                  |    6 +-
 drivers/net/ethernet/renesas/ravb_main.c              |    8 +-
 drivers/net/ethernet/sfc/efx.c                        |    2 +-
 drivers/net/ethernet/smsc/smsc911x.c                  |   17 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c   |   10 +-
 drivers/net/ethernet/via/via-velocity.c               |   24 +-
 drivers/net/fjes/fjes_hw.c                            |    2 +-
 drivers/net/ipvlan/ipvlan_core.c                      |   14 +-
 drivers/net/macvlan.c                                 |    2 +
 drivers/net/phy/at803x.c                              |    4 +
 drivers/net/phy/marvell.c                             |   16 +
 drivers/net/phy/phy.c                                 |    3 +
 drivers/net/phy/vitesse.c                             |   16 +-
 drivers/net/usb/cdc_ether.c                           |    5 +
 drivers/net/vmxnet3/vmxnet3_drv.c                     |    7 +-
 drivers/net/vmxnet3/vmxnet3_int.h                     |    4 +-
 include/linux/marvell_phy.h                           |    1 +
 include/linux/mlx5/mlx5_ifc.h                         |   24 +-
 include/linux/netdevice.h                             |   32 +-
 include/linux/netfilter/ipset/ip_set.h                |    2 +-
 include/linux/netfilter_ingress.h                     |   13 +-
 include/net/ip6_fib.h                                 |    3 +-
 include/net/ip6_tunnel.h                              |    3 +-
 include/net/ip_tunnels.h                              |    3 +-
 include/net/netfilter/nf_tables.h                     |   16 +-
 include/net/sock.h                                    |   25 +
 include/net/switchdev.h                               |    2 +-
 net/8021q/vlan_core.c                                 |    4 +-
 net/bridge/br_stp.c                                   |    2 +-
 net/bridge/br_stp_if.c                                |    2 +-
 net/core/dev.c                                        |   18 +-
 net/core/neighbour.c                                  |    2 +-
 net/core/rtnetlink.c                                  |  274 +++++----=
-
 net/core/skbuff.c                                     |    3 +-
 net/ipv4/inet_connection_sock.c                       |    4 +-
 net/ipv4/netfilter/nf_nat_pptp.c                      |    2 +-
 net/ipv4/raw.c                                        |    8 +-
 net/ipv4/tcp.c                                        |   21 +-
 net/ipv4/tcp_diag.c                                   |    2 +-
 net/ipv4/tcp_ipv4.c                                   |   14 +-
 net/ipv6/mcast.c                                      |    2 -
 net/ipv6/route.c                                      |   22 +-
 net/ipv6/tcp_ipv6.c                                   |   19 +-
 net/netfilter/Kconfig                                 |    6 +-
 net/netfilter/ipset/ip_set_bitmap_gen.h               |   17 +-
 net/netfilter/ipset/ip_set_bitmap_ip.c                |   14 +-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c             |   64 ++-
 net/netfilter/ipset/ip_set_bitmap_port.c              |   18 +-
 net/netfilter/ipset/ip_set_core.c                     |   14 +-
 net/netfilter/ipset/ip_set_hash_gen.h                 |   26 +-
 net/netfilter/ipset/ip_set_list_set.c                 |    5 +-
 net/netfilter/ipvs/ip_vs_core.c                       |   16 +-
 net/netfilter/nfnetlink_log.c                         |    2 +-
 net/netfilter/nft_counter.c                           |   49 +-
 net/netfilter/nft_dynset.c                            |    5 +-
 net/packet/af_packet.c                                |   92 ++--
 net/sctp/auth.c                                       |    4 +-
 net/unix/af_unix.c                                    |   24 +-
 samples/bpf/Makefile                                  |    7 +-
 tools/net/Makefile                                    |    7 +-
 84 files changed, 1036 insertions(+), 3650 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6060.h
 delete mode 100644 drivers/net/ethernet/icplus/Kconfig
 delete mode 100644 drivers/net/ethernet/icplus/Makefile
 delete mode 100644 drivers/net/ethernet/icplus/ipg.c
 delete mode 100644 drivers/net/ethernet/icplus/ipg.h
