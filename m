From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 04 Nov 2013 01:00:29 -0500 (EST)
Message-ID: <20131104.010029.704611266032274630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm sending a pull request of these lingering bug fixes for networking
before the normal merge window material because some of this stuff I'd
like to get to -stable ASAP.

1) cxgb3 stopped working on 32-bit machines, fix from Ben Hutchings.

2) Structures passed via netlink for netfilter logging are not fully
   initialized.  From Mathias Krause.

3) Properly unlink upper openvswitch device  during notifications,
   from Alexei Starovoitov.

4) Fix race conditions involving access to the IP compression scratch
   buffer, from Michal Kubrecek.

5) We don't handle the expiration of MTU information contained in
   ipv6 routes sometimes, fix from Hannes Frederic Sowa.

6) With Fast Open we can miscompute the TCP SYN/ACK RTT, from Yuchung
   Cheng.

7) Don't take TCP RTT sample when an ACK doesn't acknowledge new data,
   also from Yuchung Cheng.

8) The decreased IPSEC garbage collection threshold causes problems
   for some people, bump it back up.  From Steffen Klassert.

9) Fix skb->truesize calculated by tcp_tso_segment(), from Eric
   Dumazet.

10) flow_dissector doesn't validate packet lengths sufficiently, from
    Jason Wang.

Please pull, thanks a lot!

The following changes since commit 320437af954cbe66478f1f5e8b34cb5a8d07=
2191:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/s390/linux (2013-10-23 08:10:25 +0100)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to c32b7dfbb1dfb3f0a68f250deff65103c8bb704a=
:

  net/mlx4_core: Fix call to __mlx4_unregister_mac (2013-11-04 00:51:10=
 -0500)

----------------------------------------------------------------
Alexei Starovoitov (1):
      openvswitch: fix vport-netdev unregister

Alistair Popple (2):
      ibm emac: Don't call napi_complete if napi_reschedule failed
      ibm emac: Fix locking for enable/disable eob irq

Antonio Quartulli (1):
      netpoll: fix rx_hook() interface by passing the skb

Ariel Elior (1):
      bnx2x: Disable VF access on PF removal

Ben Hutchings (1):
      cxgb3: Fix length calculation in write_ofld_wr() on 32-bit archit=
ectures

Daniel Borkmann (2):
      net: sctp: fix ASCONF to allow non SCTP_ADDR_SRC addresses in ipv=
6
      net: sctp: do not trigger BUG_ON in sctp_cmd_delete_tcb

David S. Miller (6):
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge branch 'qlcnic'
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge branch 'fixes' of git://git.kernel.org/.../jesse/openvswitc=
h
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'fixes-for-3.12' of git://gitorious.org/linux-can/li=
nux-can

Dmitry Kravkov (1):
      bnx2x: prevent FW assert on low mem during unload

Eric Dumazet (2):
      pkt_sched: fq: clear time_next_packet for reused flows
      tcp: gso: fix truesize tracking

=46reddy Xin (1):
      ax88179_178a: Remove AX_MEDIUM_ALWAYS_ONE bit in AX_MEDIUM_STATUS=
_MODE register to avoid TX throttling

Hannes Frederic Sowa (2):
      ipv6: reset dst.expires value when clearing expire flag
      ipv6: ip6_dst_check needs to check for expired dst_entries

Holger Eitzenberger (1):
      netfilter: xt_NFQUEUE: fix --queue-bypass regression

Jack Morgenstein (1):
      net/mlx4_core: Fix call to __mlx4_unregister_mac

Jason Wang (2):
      virtio-net: correctly handle cpu hotplug notifier during resuming
      net: flow_dissector: fail on evil iph->ihl

Markus Pargmann (1):
      can: c_can: Fix RX message handling, handle lost message before E=
OB

Masanari Iida (1):
      doc:net: Fix typo in Documentation/networking

Mathias Krause (2):
      netfilter: ebt_ulog: fix info leaks
      netfilter: ipt_ULOG: fix info leaks

Michael Dr=FCing (1):
      net: x25: Fix dead URLs in Kconfig

Michal Kubecek (1):
      xfrm: prevent ipcomp scratch buffer race condition

Nathan Hintz (1):
      bgmac: don't update slot on skb alloc/dma mapping error

Nikolay Aleksandrov (2):
      netconsole: fix NULL pointer dereference
      netconsole: fix multiple race conditions

Olivier Sobrie (1):
      can: kvaser_usb: fix usb endpoints detection

Randy Dunlap (1):
      Documentation/networking: netdev-FAQ typo corrections

Sebastian Siewior (1):
      net: wan: sbni: remove assembly crc32 code

Shahed Shaikh (2):
      qlcnic: Do not force adapter to perform LRO without destination I=
P check
      qlcnic: Do not read QLCNIC_FW_CAPABILITY_MORE_CAPS bit for 83xx a=
dapter

Somnath Kotur (1):
      be2net: Warn users of possible broken functionality on BE2 cards =
with very old FW versions with latest driver

Steffen Klassert (2):
      xfrm: Increase the garbage collector threshold
      xfrm: Fix null pointer dereference when decoding sessions

Vlad Yasevich (1):
      bridge: pass correct vlan id to multicast code

Wei Liu (1):
      xen-netback: use jiffies_64 value to calculate credit timeout

Will Deacon (1):
      netfilter: x_tables: fix ordering of jumpstack allocation and tab=
le update

Yuchung Cheng (3):
      tcp: fix SYNACK RTT estimation in Fast Open
      tcp: only take RTT from timestamps if new data is acked
      tcp: do not rearm RTO when future data are sacked

 Documentation/networking/dccp.txt                   |  4 +--
 Documentation/networking/e100.txt                   |  2 +-
 Documentation/networking/ieee802154.txt             |  4 +--
 Documentation/networking/l2tp.txt                   |  2 +-
 Documentation/networking/netdev-FAQ.txt             | 24 ++++++++-----=
---
 Documentation/networking/netlink_mmap.txt           |  6 ++--
 Documentation/networking/operstates.txt             |  4 +--
 Documentation/networking/rxrpc.txt                  |  2 +-
 Documentation/networking/stmmac.txt                 |  8 +++---
 Documentation/networking/vortex.txt                 |  4 +--
 Documentation/networking/x25-iface.txt              |  2 +-
 drivers/net/can/c_can/c_can.c                       |  6 ++--
 drivers/net/can/usb/kvaser_usb.c                    | 20 +++++++++----=
-
 drivers/net/ethernet/broadcom/bgmac.c               | 20 ++++++++++---=
-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     | 10 +++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c   | 16 ++++++++++-
 drivers/net/ethernet/chelsio/cxgb3/sge.c            |  3 +-
 drivers/net/ethernet/emulex/benet/be.h              |  9 ++++++
 drivers/net/ethernet/emulex/benet/be_main.c         |  6 ++++
 drivers/net/ethernet/ibm/emac/mal.c                 | 16 +++++------
 drivers/net/ethernet/mellanox/mlx4/cmd.c            |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c |  6 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c      |  7 ++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    |  6 ++--
 drivers/net/netconsole.c                            | 18 +++++++-----
 drivers/net/usb/ax88179_178a.c                      | 11 ++++----
 drivers/net/virtio_net.c                            | 13 ++++-----
 drivers/net/wan/sbni.c                              | 89 -------------=
-----------------------------------------------
 drivers/net/xen-netback/common.h                    |  1 +
 drivers/net/xen-netback/interface.c                 |  3 +-
 drivers/net/xen-netback/netback.c                   | 10 +++----
 include/linux/netpoll.h                             |  5 ++--
 include/net/ip6_fib.h                               |  1 +
 net/bridge/br_device.c                              |  2 +-
 net/bridge/br_input.c                               |  2 +-
 net/bridge/br_multicast.c                           | 44 +++++++++++++=
-----------------
 net/bridge/br_private.h                             |  6 ++--
 net/bridge/netfilter/ebt_ulog.c                     |  9 ++----
 net/core/flow_dissector.c                           |  2 +-
 net/core/netpoll.c                                  | 31 ++++++++++++-=
--------
 net/ipv4/netfilter/arp_tables.c                     |  5 ++++
 net/ipv4/netfilter/ip_tables.c                      |  5 ++++
 net/ipv4/netfilter/ipt_ULOG.c                       |  7 +----
 net/ipv4/tcp_input.c                                | 34 +++++++++++++=
++++------
 net/ipv4/tcp_offload.c                              | 13 ++++-----
 net/ipv4/xfrm4_policy.c                             |  8 ++++--
 net/ipv6/netfilter/ip6_tables.c                     |  5 ++++
 net/ipv6/route.c                                    |  9 ++++--
 net/ipv6/xfrm6_policy.c                             |  8 ++++--
 net/netfilter/x_tables.c                            |  7 ++++-
 net/netfilter/xt_NFQUEUE.c                          |  7 ++++-
 net/openvswitch/dp_notify.c                         |  7 +++--
 net/openvswitch/vport-netdev.c                      | 16 +++++++++--
 net/openvswitch/vport-netdev.h                      |  1 +
 net/sched/sch_fq.c                                  |  1 +
 net/sctp/ipv6.c                                     |  4 ++-
 net/sctp/sm_sideeffect.c                            |  1 -
 net/x25/Kconfig                                     |  4 +--
 net/xfrm/xfrm_ipcomp.c                              | 12 ++++----
 59 files changed, 303 insertions(+), 287 deletions(-)
