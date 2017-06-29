From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 29 Jun 2017 16:18:51 -0400 (EDT)
Message-ID: <20170629.161851.1296462645904764029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Need to access netdev->num_rx_queues behind an accessor in netvsc
   driver otherwise the build breaks with some configs, from Arnd Bergmann.

2) Add dummy xfrm_dev_event() so that build doesn't fail when
   CONFIG_XFRM_OFFLOAD is not set.  From Hangbin Liu.

3) Don't OOPS when pfkey_msg2xfrm_state() signals an erros, from
   Dan Carpenter.

4) Fix MCDI command size for filter operations in sfc driver, from
   Martin Habets.

5) Fix UFO segmenting so that we don't calculate incorrect checksums,
   from Michal Kubecek.

6) When ipv6 datagram connects fail, reset destination address and
   port.  From Wei Wang.

7) TCP disconnect must reset the cached receive DST, from WANG Cong.

8) Fix sign extension bug on 32-bit in dev_get_stats(), from Eric
   Dumazet.

9) fman driver has to depend on HAS_DMA, from Madalin Bucur.

10) Fix bpf pointer leak with xadd in verifier, from Daniel Borkmann.

11) Fix negative page counts with GFO, from Michal Kubecek.

Please pull, thanks a lot!

The following changes since commit 48b6bbef9a1789f0365c1a385879a1fea4460016:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-06-21 12:40:20 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to d58299a478c416c0b48e4b31c6332fe7beb63000:

  sfc: fix attempt to translate invalid filter ID (2017-06-29 15:59:38 -0400)

----------------------------------------------------------------
Andrew F. Davis (1):
      net: usb: asix88179_178a: Add support for the Belkin B2B128

Arnd Bergmann (1):
      netvsc: don't access netdev->num_rx_queues directly

Colin Ian King (1):
      Trivial fix to spelling mistake in arc_printk message

Dan Carpenter (3):
      xfrm: Oops on error in pfkey_msg2xfrm_state()
      xfrm: NULL dereference on allocation failure
      rocker: move dereference before free

Daniel Borkmann (1):
      bpf: prevent leaking pointer via xadd on unpriviledged

David S. Miller (4):
      Merge branch 'macvlan-Fix-some-issues-with-changing-mac-addresses'
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'bnxt_en-fixes'
      Merge branch 'arcnet-fixes'

Edward Cree (1):
      sfc: fix attempt to translate invalid filter ID

Eric Dumazet (1):
      net: prevent sign extension in dev_get_stats()

Gao Feng (1):
      net: sched: Fix one possible panic when no destroy callback

Hangbin Liu (2):
      xfrm: fix xfrm_dev_event() missing when compile without CONFIG_XFRM_OFFLOAD
      xfrm: move xfrm_garbage_collect out of xfrm_policy_flush

Ido Schimmel (1):
      mlxsw: spectrum_router: Fix NULL pointer dereference

Jason Wang (1):
      virtio-net: serialize tx routine during reset

Lokesh Vutla (1):
      drivers: net: cpsw-common: Fix reading of mac address for am43 SoCs

Madalin Bucur (1):
      fsl/fman: add dependency on HAS_DMA

Martin Habets (1):
      sfc: Fix MCDI command size for filter operations

Michael Chan (2):
      bnxt_en: Add missing logic to handle TPA end error conditions.
      bnxt_en: Fix netpoll handling.

Michael Grzeschik (4):
      arcnet: change irq handler to lock irqsave
      arcnet: com20020: remove needless base_addr assignment
      arcnet: com20020-pci: fix dev_id calculation
      arcnet: com20020-pci: add missing pdev setup in netdev structure

Michal Kubeèek (2):
      net: account for current skb length when deciding about UFO
      net: handle NAPI_GRO_FREE_STOLEN_HEAD case also in napi_frags_finish()

Mintz, Yuval (1):
      bnx2x: Don't log mc removal needlessly

Richard Cochran (1):
      net: dp83640: Avoid NULL pointer dereference.

Serhey Popovych (1):
      veth: Be more robust on network device creation when no attributes

Vlad Yasevich (4):
      macvlan: Do not return error when setting the same mac address
      macvlan: Fix passthru macvlan mac address inheritance
      macvlan: convert port passthru to flags.
      macvlan: Let passthru macvlan correctly restore lower mac address

WANG Cong (4):
      ipv6: only call ip6_route_dev_notify() once for NETDEV_UNREGISTER
      ipv6: avoid unregistering inet6_dev for loopback
      sit: use __GFP_NOWARN for user controlled allocation
      tcp: reset sk_rx_dst in tcp_disconnect()

Wei Liu (1):
      xen-netback: correctly schedule rate-limited queues

Wei Wang (1):
      net: ipv6: reset daddr and dport in sk if connect() fails

Yossi Kuperman (2):
      xfrm6: Fix IPv6 payload_len in xfrm6_transport_finish
      esp6_offload: Fix IP6CB(skb)->nhoff for ESP GRO

Zach Brown (1):
      net/phy: micrel: configure intterupts after autoneg workaround

 drivers/net/arcnet/arcnet.c                           |  7 ++++---
 drivers/net/arcnet/capmode.c                          |  2 +-
 drivers/net/arcnet/com20020-pci.c                     |  6 ++++--
 drivers/net/arcnet/com20020.c                         |  2 --
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c             | 61 ++++++++++++++++++++++++++++++++++++++++++++++++++++---------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h             |  6 +++++-
 drivers/net/ethernet/freescale/fman/Kconfig           |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c |  3 +++
 drivers/net/ethernet/rocker/rocker_ofdpa.c            |  2 +-
 drivers/net/ethernet/sfc/ef10.c                       | 15 ++++++++-------
 drivers/net/ethernet/ti/cpsw-common.c                 |  2 +-
 drivers/net/hyperv/netvsc_drv.c                       |  4 ++--
 drivers/net/macvlan.c                                 | 85 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--------------
 drivers/net/phy/dp83640.c                             |  2 +-
 drivers/net/phy/micrel.c                              |  2 ++
 drivers/net/usb/ax88179_178a.c                        | 16 ++++++++++++++++
 drivers/net/veth.c                                    |  4 ++--
 drivers/net/virtio_net.c                              |  1 +
 drivers/net/xen-netback/common.h                      |  1 +
 drivers/net/xen-netback/interface.c                   |  6 +++++-
 drivers/net/xen-netback/netback.c                     |  6 +++++-
 include/net/xfrm.h                                    |  7 ++-----
 kernel/bpf/verifier.c                                 |  5 +++++
 net/core/dev.c                                        | 30 ++++++++++++++++++++----------
 net/ipv4/ip_output.c                                  |  3 ++-
 net/ipv4/tcp.c                                        |  2 ++
 net/ipv6/addrconf.c                                   |  5 +++--
 net/ipv6/datagram.c                                   |  8 +++++++-
 net/ipv6/esp6_offload.c                               | 25 +++++++++++++++++++++++++
 net/ipv6/ip6_output.c                                 |  2 +-
 net/ipv6/route.c                                      |  6 +++++-
 net/ipv6/sit.c                                        |  2 +-
 net/ipv6/udp.c                                        |  3 ++-
 net/ipv6/xfrm6_input.c                                |  2 +-
 net/key/af_key.c                                      | 19 +++++++++++++++----
 net/sched/sch_api.c                                   |  3 ++-
 net/xfrm/Makefile                                     |  3 +--
 net/xfrm/xfrm_device.c                                |  2 ++
 net/xfrm/xfrm_policy.c                                |  4 ----
 net/xfrm/xfrm_user.c                                  |  1 +
 tools/testing/selftests/bpf/test_verifier.c           | 66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 42 files changed, 350 insertions(+), 84 deletions(-)
