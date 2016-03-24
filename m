From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 23 Mar 2016 22:23:11 -0400 (EDT)
Message-ID: <20160323.222311.757580304869107650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Several bug fixes rolling in, some for changes introduced in this
merge window, and some for problems that have existed for some time:

1) Fix prepare_to_wait() handling in AF_VSOCK, from Claudio Imbrenda.

2) The new DST_CACHE should be a silent config option, from Dave
   Jones.

3) inet_current_timestamp() unintentionally truncates timestamps
   to 16-bit, from Deepa Dinamani.

4) Missing reference to netns in ppp, from Guillaume Nault.

5) Free memory reference in hv_netvsc driver, from Haiyang Zhang.

6) Missing kernel doc documentation for function arguments in various
   spots around the networking, from Luis de Bethencourt.

7) UDP stopped receiving broadcast packets properly, due to overzealous
   multicast checks, fix from Paolo Abeni.

Please pull, thanks a lot!

The following changes since commit de06dbfa7861c9019eedefc0c356ba86e5098f1b:

  Merge branch 'for-linus' of git://ftp.arm.linux.org.uk/~rmk/linux-arm (2016-03-19 16:31:54 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 6579a023a881e0592ce9a98fdfcbcc0a2a096aa7:

  net: ping: make ping_v6_sendmsg static (2016-03-23 22:09:58 -0400)

----------------------------------------------------------------
Alexander Duyck (1):
      net: Reset encap_level to avoid resetting features on inner IP headers

Arnd Bergmann (1):
      net: smc911x: avoid unused variable warnings

Benjamin Poirier (3):
      net: Fix indentation of the conf/ documentation block
      igmp: Document sysctl_igmp_max_msf
      net: Add missing kernel-doc for netdev ptype lists

Bjorn Helgaas (1):
      net: Fix typos and whitespace.

Claudio Imbrenda (2):
      Revert "vsock: Fix blocking ops call in prepare_to_wait"
      AF_VSOCK: Shrink the area influenced by prepare_to_wait

Colin Ian King (1):
      net/mlx4: remove unused array zero_gid[]

Dan Carpenter (1):
      mdio-sun4i: oops in error handling in probe

Daniel Borkmann (3):
      vxlan: fix populating tclass in vxlan6_get_route
      geneve: fix populating tclass in geneve_get_v6_dst
      ipv6, trace: fix tos reporting on fib6_table_lookup

Daode Huang (1):
      net: hns: bug fix about the overflow of mss

Dave Jones (1):
      Make DST_CACHE a silent config option

David Decotigny (2):
      ethtool: minor doc update
      netlink: add support for NIC driver ioctls

David S. Miller (7):
      Merge git://git.kernel.org/.../torvalds/linux
      Merge branch 'flowi6_tos'
      Merge branch 'tunnel-fixes'
      Revert "lan78xx: add ndo_get_stats64"
      Merge branch 'bridge-gso-segs-and-size'
      Merge branch 'hns-fixes'
      Merge branch 'AF_VSOCK-missed-wakeups'

Deepa Dinamani (1):
      net: ipv4: Fix truncated timestamp returned by inet_current_timestamp()

Eric Dumazet (3):
      net: remove a dubious unlikely() clause
      net/rtnetlink: add IFLA_GSO_MAX_SEGS and IFLA_GSO_MAX_SIZE attributes
      bridge: update max_gso_segs and max_gso_size

Guillaume Nault (1):
      ppp: take reference on channels netns

Haishuang Yan (1):
      net: ping: make ping_v6_sendmsg static

Haiyang Zhang (3):
      hv_netvsc: Fix accessing freed memory in netvsc_change_mtu()
      hv_netvsc: Fix the array sizes to be max supported channels
      hv_netvsc: Fix the order of num_sc_offered decrement

Igal Liberman (1):
      fsl/fman: Workaround for Errata A-007273

Jesse Gross (3):
      ipip: Properly mark ipip GRO packets as encapsulated.
      tunnels: Don't apply GRO to multiple layers of encapsulation.
      tunnels: Remove encapsulation offloads on decap.

Jiri Benc (2):
      vxlan: fix sparse warnings
      vxlan: fix too large pskb_may_pull with remote checksum

Kejian Yan (6):
      net: hns: bug fix about ping6
      net: hns: add uc match for debug ports
      net: hns: fix return value of the function about rss
      net: hns: fixes a bug of RSS
      net: hns: fix the bug about mtu setting
      net: hns: adds limitation for debug port mtu

Lance Richardson (1):
      ipv4: initialize flowi4_flags before calling fib_lookup()

Luis de Bethencourt (5):
      gen_stats.c: Add description for cpu argument
      net: sched: Add description for cpu_bstats argument
      net: add description for len argument of dev_get_phys_port_name
      net: add missing descriptions in net_device_priv_flags
      ipv6: remove unused in6_addr struct

Marcelo Ricardo Leitner (5):
      sctp: fix copying more bytes than expected in sctp_add_bind_addr
      sctp: do not update a_rwnd if we are not issuing a sack
      sctp: do not leak chunks that are sent to unconfirmed paths
      sctp: align MTU to a word
      sctp: keep fragmentation point aligned to word size

Paolo Abeni (1):
      ipv4: fix broadcast packets reception

Qianqian Xie (1):
      net: hns: set xge statistic reg as read only

Sebastian Frias (1):
      net: phy: at803x: Request 'reset' GPIO only for AT8030 PHY

Sergei Shtylyov (2):
      macb: fix PHY reset
      at803x: fix reset handling

Sheng Li (2):
      net: hns: fixed portid bug in sending manage pkt
      net: hns: fixed the bug about GMACs mac setting

Tina Ruchandani (1):
      isdn: Use ktime_t instead of 'struct timeval'

Vladimir Zapolskiy (1):
      net: mediatek: fix checking for NULL instead of IS_ERR() in .probe

 Documentation/networking/ip-sysctl.txt             |  19 +++--
 drivers/isdn/mISDN/clock.c                         |  69 +++++++----------
 drivers/net/ethernet/cadence/macb.c                |   4 +-
 drivers/net/ethernet/freescale/fman/fman.c         | 104 +++++++++++++++++++++----
 drivers/net/ethernet/hisilicon/hns/hnae.h          |   3 +
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  12 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |  38 +++++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |  15 +++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |   6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   5 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |   5 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h  |   2 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   2 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  32 +++++---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |  38 +++++----
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        |   4 +-
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |   2 -
 drivers/net/ethernet/smsc/smc911x.c                |   2 +
 drivers/net/geneve.c                               |  11 +--
 drivers/net/hyperv/hyperv_net.h                    |   7 +-
 drivers/net/hyperv/netvsc_drv.c                    |   5 +-
 drivers/net/hyperv/rndis_filter.c                  |  16 ++--
 drivers/net/phy/at803x.c                           |  10 ++-
 drivers/net/phy/mdio-sun4i.c                       |   4 +-
 drivers/net/ppp/ppp_generic.c                      |   4 +-
 drivers/net/usb/lan78xx.c                          |  49 ------------
 drivers/net/vxlan.c                                |   9 +--
 include/linux/mISDNif.h                            |   2 +-
 include/linux/netdevice.h                          | 225 +++++++++++++++++++++++++++---------------------------
 include/net/flow.h                                 |   2 +-
 include/net/inet6_connection_sock.h                |   1 -
 include/net/ip_tunnels.h                           |  16 ++++
 include/net/ipv6.h                                 |   6 ++
 include/net/ping.h                                 |   1 -
 include/net/sctp/sctp.h                            |  10 ++-
 include/net/sctp/structs.h                         |   2 +-
 include/net/vxlan.h                                |  16 ++--
 include/trace/events/fib6.h                        |   2 +-
 include/uapi/linux/ethtool.h                       |   6 +-
 include/uapi/linux/if_link.h                       |   2 +
 net/Kconfig                                        |   2 +-
 net/bridge/br_if.c                                 |  16 ++++
 net/core/dev.c                                     |   3 +-
 net/core/gen_estimator.c                           |   2 +
 net/core/gen_stats.c                               |   1 +
 net/core/rtnetlink.c                               |   4 +
 net/core/skbuff.c                                  |   2 +-
 net/ipv4/af_inet.c                                 |  26 ++++++-
 net/ipv4/fib_frontend.c                            |  16 ++--
 net/ipv4/fou.c                                     |  13 +++-
 net/ipv4/gre_offload.c                             |   6 ++
 net/ipv4/ip_tunnel_core.c                          |   3 +-
 net/ipv4/udp.c                                     |  12 ++-
 net/ipv4/udp_offload.c                             |   7 +-
 net/ipv6/ip6_offload.c                             |  15 +++-
 net/ipv6/ping.c                                    |  59 +++++++-------
 net/ipv6/sit.c                                     |   6 +-
 net/netlink/af_netlink.c                           |  10 ++-
 net/sctp/associola.c                               |   3 +-
 net/sctp/bind_addr.c                               |  14 ++--
 net/sctp/input.c                                   |   3 +-
 net/sctp/outqueue.c                                |   6 +-
 net/sctp/protocol.c                                |   1 +
 net/sctp/sm_make_chunk.c                           |   3 +-
 net/sctp/sm_sideeffect.c                           |   6 +-
 net/sctp/socket.c                                  |   4 +-
 net/sctp/transport.c                               |   4 +-
 net/vmw_vsock/af_vsock.c                           | 155 ++++++++++++++++++++-----------------
 68 files changed, 710 insertions(+), 460 deletions(-)
