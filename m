From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 05 Feb 2015 01:07:08 -0800 (PST)
Message-ID: <20150205.010708.1889827152703440720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Stretch ACKs can kill performance with Reno and CUBIC congestion con=
trol,
   largely due to LRO and GRO.  Fix from Neal Cardwell.

2) Fix userland breakage because we accidently emit zero length netlink
   messages from the bridging code.  From Roopa Prabhu.

3) Carry handling in generic csum_tcpudp_nofold is broken, fix from
   Karl Beldan.

4) Remove bogus dev_set_net() calls from CAIF driver, from Nicolas
   Dichtel.

5) Make sure PPP deflation never returns a length greater then the
   output buffer, otherwise we overflow and trigger skb_over_panic().
   Fix from Florian Westphal.

6) COSA driver needs VIRT_TO_BUS Kconfig dependencies, from Arnd
   Bergmann.

7) Don't increase route cached MTU on datagram too big ICMPs.
   From Li Wei.

8) Fix error path leaks in nf_tables, from Pablo Neira Ayuso.

9) Fix bitmask handling regression in netlink that broke things
   like acpi userland tools.  From Pablo Neira Ayuso.

10) Wrong header pointer passed to param_type2af() in SCTP code,
    from Saran Maruti Ramanara.

11) Stacked vlans not handled correctly by vlan_get_protocol(), from
    Toshiaki Makita.

12) Add missing DMA memory barrier to xgene driver, from Iyappan
    Subramanian.

13) Fix crash in rate estimators, from Eric Dumazet.

14) We've been adding various workarounds, one after another, for
    the change which added the per-net tcp_sock.  It was meant to
    reduce socket contention but added lots of problems.

    Reduce this instead to a proper per-cpu socket and that rids
    us of all the daemons.

    From Eric Dumazet.

15) Fix memory corruption and OOPS in mlx4 driver, from Jack
    Morgenstein.

16) When we disabled UFO in the virtio_net device, it introduces some
    serious performance regressions.  The orignal problem was IPV6
    fragment ID generation, so fix that properly instead.  From Vlad
    Yasevich.

17) sr9700 driver build breaks on xtensa because it defines macros
    with the same name as those used by the arch code.  Use more
    unique names.  From Chen Gang.

18) Fix endianness in new virio 1.0 mode of the vhost net driver,
    from Michael S. Tsirkin.

19) Several sysctls were setting the maxlen attribute incorrectly,
    from Sasha Levin.

20) Don't accept an FQ scheduler quantum of zero, that leads to
    crashes.  From Kenneth Klette Jonassen.

21) Fix dumping of non-existing actions in the packet scheduler
    classifier.  From Ignacy Gaw=EAdzki.

22) Return the write work_done value when doing TX work in the qlcnic
    driver.

23) ip6gre_err accesses the info field with the wrong endianness,
    from Sabrina Dubroca.

Please pull, thanks a lot!

The following changes since commit 59343cd7c4809cf7598789e1cd14563780ae=
4239:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-0=
1-27 13:55:36 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net=20

for you to fetch changes up to a409caecb2e17fc475533738dd1c69b32e13fe09=
:

  sit: fix some __be16/u16 mismatches (2015-02-05 00:43:14 -0800)

----------------------------------------------------------------
Arnd Bergmann (4):
      net: cs89x0: always build platform code if !HAS_IOPORT_MAP
      net: wan: add missing virt_to_bus dependencies
      net: lance,ni64: don't build for ARM
      net: am2150: fix nmclan_cs.c shared interrupt handling

Chen Gang (1):
      net: usb: sr9700: Use 'SR_' prefix for the common register macros

Dan Carpenter (1):
      isdn: off by one in connect_res()

David L Stevens (1):
      sunvnet: set queue mapping when doing packet copies

David S. Miller (6):
      Merge branch 'tcp_stretch_acks'
      Merge branch 'netns'
      Merge branch 'arm-build-fixes'
      Merge branch 'vlan_get_protocol'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'virtio_net_ufo'

David Vrabel (1):
      xen-netback: stop the guest rx thread after a fatal error

Eric Dumazet (7):
      tcp: ipv4: initialize unicast_sock sk_pacing_rate
      net: sched: fix panic in rate estimators
      ipv4: tcp: get rid of ugly unicast_sock
      flow_keys: n_proto type should be __be16
      net: remove some sparse warnings
      ipv6: fix sparse errors in ip6_make_flowlabel()
      sit: fix some __be16/u16 mismatches

=46lorian Westphal (1):
      ppp: deflate: never return len larger than output buffer

Haiyang Zhang (1):
      hyperv: Fix the error processing in netvsc_send()

Ignacy Gaw=EAdzki (1):
      cls_api.c: Fix dumping of non-existing actions' stats.

Iyappan Subramanian (1):
      drivers: net: xgene: fix: Out of order descriptor bytes read

Jack Morgenstein (1):
      net/mlx4_core: Fix kernel Oops (mem corruption) when working with=
 more than 80 VFs

Julian Anastasov (1):
      ipvs: rerouting to local clients is not needed anymore

Kenneth Klette Jonassen (1):
      pkt_sched: fq: avoid hang when quantum 0

Lendacky, Thomas (2):
      amd-xgbe: Adjust for zero-based traffic class count
      amd-xgbe: Set RSS enablement based on hardware features

Li Wei (1):
      ipv4: Don't increase PMTU with Datagram Too Big message.

Marcelo Leitner (1):
      qlge: Fix qlge_update_hw_vlan_features to handle if interface is =
down

Michael S. Tsirkin (1):
      vhost/net: fix up num_buffers endian-ness

Neal Cardwell (5):
      tcp: stretch ACK fixes prep
      tcp: fix the timid additive increase on stretch ACKs
      tcp: fix stretch ACK bugs in Reno
      tcp: fix stretch ACK bugs in CUBIC
      tcp: fix timing issue in CUBIC slope calculation

Nicolas Dichtel (2):
      caif: remove wrong dev_net_set() call
      vxlan: setup the right link netns in newlink hdlr

Pablo Neira (1):
      netlink: fix wrong subscription bitmask to group mapping in

Pablo Neira Ayuso (3):
      netfilter: nf_tables: validate hooks in NAT expressions
      netfilter: nf_tables: disable preemption when restoring chain cou=
nters
      netfilter: nf_tables: fix leaks in error path of nf_tables_newcha=
in()

Richard Weinberger (1):
      Documentation: Update netlink_mmap.txt

Roopa Prabhu (1):
      bridge: dont send notification when skb->len =3D=3D 0 in rtnl_bri=
dge_notify

Sabrina Dubroca (1):
      ip6_gre: fix endianness errors in ip6gre_err

Sanjeev Sharma (1):
      gianfar: correct the bad expression while writing bit-pattern

Saran Maruti Ramanara (1):
      net: sctp: fix passing wrong parameter header to param_type2af in=
 sctp_process_param

Sasha Levin (1):
      net: rds: use correct size for max unacked packets and bytes

Shahed Shaikh (1):
      qlcnic: Fix NAPI poll routine for Tx completion

Toshiaki Makita (4):
      net: Fix vlan_get_protocol for stacked vlan
      igbvf: Fix checksum error when using stacked vlan
      ixgbe: Fix checksum error when using stacked vlan
      ixgbevf: Fix checksum error when using stacked vlan

Vlad Yasevich (3):
      ipv6: Select fragment id during UFO segmentation if not set.
      Revert "drivers/net, ipv6: Select IPv6 fragment idents for virtio=
 UFO packets"
      Revert "drivers/net: Disable UFO through virtio"

karl beldan (2):
      lib/checksum.c: fix carry in csum_tcpudp_nofold
      lib/checksum.c: fix build for generic csum_tcpudp_nofold

 Documentation/networking/netlink_mmap.txt         | 13 ++---
 drivers/isdn/hardware/eicon/message.c             |  2 +-
 drivers/net/caif/caif_hsi.c                       |  1 -
 drivers/net/ethernet/amd/Kconfig                  |  4 +-
 drivers/net/ethernet/amd/nmclan_cs.c              |  2 +
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c          |  4 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |  2 +
 drivers/net/ethernet/cirrus/Kconfig               |  3 +-
 drivers/net/ethernet/freescale/gianfar_ethtool.c  |  2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c         | 19 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h         |  3 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c    | 27 ++++++++--
 drivers/net/ethernet/qlogic/qlge/qlge_main.c      | 26 +++++----
 drivers/net/ethernet/sun/sunvnet.c                |  1 +
 drivers/net/hyperv/netvsc.c                       | 11 ++--
 drivers/net/macvtap.c                             | 16 +++---
 drivers/net/ppp/ppp_deflate.c                     |  2 +-
 drivers/net/tun.c                                 | 25 ++++-----
 drivers/net/usb/sr9700.c                          | 36 ++++++-------
 drivers/net/usb/sr9700.h                          | 66 +++++++++++----=
--------
 drivers/net/virtio_net.c                          | 24 ++++-----
 drivers/net/vxlan.c                               | 10 ++--
 drivers/net/wan/Kconfig                           |  6 +--
 drivers/net/xen-netback/interface.c               |  2 +
 drivers/net/xen-netback/netback.c                 |  3 +-
 drivers/vhost/net.c                               |  4 +-
 include/linux/if_vlan.h                           | 60 +++++++++++++++=
+-----
 include/linux/mlx4/device.h                       |  2 +-
 include/net/flow_keys.h                           |  6 +--
 include/net/ip.h                                  |  2 +-
 include/net/ipv6.h                                |  7 ++-
 include/net/netfilter/nf_tables.h                 |  2 +
 include/net/netns/ipv4.h                          |  1 +
 include/net/sch_generic.h                         | 13 ++---
 include/net/tcp.h                                 |  4 +-
 lib/checksum.c                                    | 12 ++++-
 net/bridge/netfilter/nft_reject_bridge.c          | 29 +++-------
 net/caif/chnl_net.c                               |  1 -
 net/core/dev.c                                    | 37 ++-----------
 net/core/rtnetlink.c                              |  6 ++-
 net/ipv4/ip_output.c                              | 29 ++--------
 net/ipv4/route.c                                  |  3 ++
 net/ipv4/tcp_bic.c                                |  2 +-
 net/ipv4/tcp_cong.c                               | 32 ++++++-----
 net/ipv4/tcp_cubic.c                              | 39 ++++++--------
 net/ipv4/tcp_ipv4.c                               | 37 +++++++++++--
 net/ipv4/tcp_scalable.c                           |  3 +-
 net/ipv4/tcp_veno.c                               |  2 +-
 net/ipv4/tcp_yeah.c                               |  2 +-
 net/ipv6/ip6_gre.c                                |  4 +-
 net/ipv6/ip6_output.c                             | 14 -----
 net/ipv6/output_core.c                            | 41 +++++++++++---
 net/ipv6/sit.c                                    |  8 +--
 net/ipv6/udp_offload.c                            | 10 +++-
 net/netfilter/ipvs/ip_vs_core.c                   | 33 ++++++++----
 net/netfilter/nf_tables_api.c                     | 28 +++++++++-
 net/netfilter/nft_masq.c                          | 26 +++++----
 net/netfilter/nft_nat.c                           | 40 ++++++++++----
 net/netfilter/nft_redir.c                         | 25 ++++++---
 net/netlink/af_netlink.c                          |  4 +-
 net/rds/sysctl.c                                  |  4 +-
 net/sched/cls_api.c                               |  7 +--
 net/sched/sch_fq.c                                | 10 +++-
 net/sctp/sm_make_chunk.c                          |  2 +-
 66 files changed, 524 insertions(+), 383 deletions(-)
