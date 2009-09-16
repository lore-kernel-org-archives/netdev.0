From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 16 Sep 2009 01:42:39 -0700 (PDT)
Message-ID: <20090916.014239.226102399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60899
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751392AbZIPImV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 04:42:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) The idea to use ->close() and then a ->open() to refresh multicast
   addresses in the bonding driver was a bad idea and breaks a bunch
   of stuff.  Better scheme from Moni Shoua.

2) Some TCP code still assuming ssthresh was a u16, oops.  Fix from
   Ilpo J=E4rvinen.

3) RXRPC updates from David Howells.

4) genetlink table locking busted with netns, fix from Johannes Berg.

5) Several fixes for multiq packet scheduler fallout from Jarek Poplaws=
ki.

6) can receives packets in wrong context eliciting warnings from
   local_softirq_pending(), fix from Oliver Hartkopp.

7) TCP MD5 code has preempt level imbalance, fix from Robert Varga.

8) SKY2 bug fixes from Stephen Hemminger.

9) Alexey Dobriyan is constificated, he should probably see a doctor
   about that. :-)

There is a pktgen OOPS regression reported by Ingo, someone replied
with a patch for him to test out so we'll monitor that very closely.

There are some wireless bugs that have been reported with some patches
in the queue as well.  Hopefully John Linville will review those and
get them to me soon.

Please pull, thanks a lot!

The following changes since commit 4142e0d1def2c0176c27fd2e810243045a62=
eb6d:
  Linus Torvalds (1):
        Merge branch 'osync_cleanup' of git://git.kernel.org/.../jack/l=
inux-fs-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (2):
      igb: reset sgmii phy at start of init
      igb: do not allow phy sw reset code to make calls to null pointer=
s

Alexey Dobriyan (3):
      net: constify struct net_protocol
      net: constify struct inet6_protocol
      net: constify remaining proto_ops

David Howells (5):
      RxRPC: Declare the security index constants symbolically
      RxRPC: Allow key payloads to be passed in XDR form
      RxRPC: Allow RxRPC keys to be read
      RxRPC: Parse security index 5 keys (Kerberos 5)
      RxRPC: Use uX/sX rather than uintX_t/intX_t types

Eric Dumazet (1):
      net: kmemcheck annotation in struct socket

Gerrit Renker (1):
      net-next-2.6 [PATCH 1/1] dccp: ccids whitespace-cleanup / CodingS=
tyle

Ilpo J=E4rvinen (1):
      tcp: fix ssthresh u16 leftover

Jarek Poplawski (3):
      pkt_sched: Fix qdisc_graft WRT ingress qdisc
      pkt_sched: Fix tx queue selection in tc_modify_qdisc
      pkt_sched: Fix qdisc_create on stab error handling

Johannes Berg (1):
      genetlink: fix netns vs. netlink table locking

Ken Kawasaki (1):
      pcnet_cs: add cis of Linksys multifunction pcmcia card

Mark Smith (1):
      Have atalk_route_packet() return NET_RX_SUCCESS not NET_XMIT_SUCC=
ESS

Michael Hennerich (1):
      netdev: smc91x: drop Blackfin cruft

Moni Shoua (1):
      bonding: remap muticast addresses without using dev_close() and d=
ev_open()

Oliver Hartkopp (1):
      can: fix NOHZ local_softirq_pending 08 warning

Peter P Waskiewicz Jr (3):
      ixgbe: Properly disable packet split per-ring when globally disab=
led
      ixgbe: Add support for 82599-based CX4 adapters
      ixgbe: Create separate media type for CX4 adapters

Robert Varga (1):
      tcp: fix CONFIG_TCP_MD5SIG + CONFIG_PREEMPT timer BUG()

R=E9mi Denis-Courmont (2):
      Phonet: Netlink event for autoconfigured addresses
      cdc-phonet: remove noisy debug statement

Stephen Hemminger (2):
      sky2: transmit ring accounting
      sky2: Make sure both ports initialize correctly

Vitaliy Gusev (1):
      mlx4: Fix access to freed memory

 drivers/net/bonding/bond_main.c     |    9 +-
 drivers/net/can/vcan.c              |    2 +-
 drivers/net/igb/e1000_82575.c       |  198 ++++----
 drivers/net/igb/e1000_82575.h       |    2 +-
 drivers/net/igb/e1000_defines.h     |    2 +-
 drivers/net/igb/e1000_phy.c         |    5 +-
 drivers/net/igb/igb_main.c          |    2 +-
 drivers/net/ixgbe/ixgbe_82598.c     |    6 +-
 drivers/net/ixgbe/ixgbe_82599.c     |    3 +
 drivers/net/ixgbe/ixgbe_main.c      |    4 +
 drivers/net/ixgbe/ixgbe_type.h      |    2 +
 drivers/net/mlx4/catas.c            |   11 +-
 drivers/net/pcmcia/pcnet_cs.c       |   10 +-
 drivers/net/pppol2tp.c              |    4 +-
 drivers/net/sky2.c                  |   24 +-
 drivers/net/smc91x.h                |   28 --
 drivers/net/usb/cdc-phonet.c        |    1 -
 drivers/serial/serial_cs.c          |   14 +-
 firmware/Makefile                   |    3 +-
 firmware/WHENCE                     |   12 +
 firmware/cis/MT5634ZLX.cis.ihex     |   11 +
 firmware/cis/PCMLM28.cis.ihex       |   18 +
 firmware/cis/RS-COM-2P.cis.ihex     |   10 +
 include/keys/rxrpc-type.h           |  107 ++++
 include/linux/igmp.h                |    2 +
 include/linux/net.h                 |    5 +
 include/linux/netdevice.h           |    3 +-
 include/linux/netlink.h             |    4 +
 include/linux/notifier.h            |    2 +
 include/linux/rxrpc.h               |    7 +
 include/net/addrconf.h              |    2 +
 include/net/protocol.h              |   13 +-
 include/net/sch_generic.h           |    2 +-
 include/net/tcp.h                   |    7 +
 net/appletalk/ddp.c                 |    2 +-
 net/can/af_can.c                    |    4 +-
 net/core/dev.c                      |    4 +-
 net/dccp/ccids/Kconfig              |    6 +-
 net/dccp/ccids/ccid2.c              |    2 -
 net/dccp/ccids/ccid2.h              |    8 +-
 net/dccp/ccids/ccid3.c              |    5 +-
 net/dccp/ccids/ccid3.h              |   50 +-
 net/dccp/ccids/lib/loss_interval.c  |    7 +-
 net/dccp/ccids/lib/loss_interval.h  |    2 -
 net/dccp/ccids/lib/packet_history.c |    4 +-
 net/dccp/ccids/lib/packet_history.h |    1 -
 net/dccp/ccids/lib/tfrc.h           |    4 +-
 net/dccp/ccids/lib/tfrc_equation.c  |   26 +-
 net/dccp/ipv4.c                     |    2 +-
 net/dccp/ipv6.c                     |    4 +-
 net/ipv4/af_inet.c                  |   18 +-
 net/ipv4/ah4.c                      |    2 +-
 net/ipv4/devinet.c                  |    6 +
 net/ipv4/esp4.c                     |    2 +-
 net/ipv4/icmp.c                     |    2 +-
 net/ipv4/igmp.c                     |   22 +
 net/ipv4/ip_gre.c                   |    2 +-
 net/ipv4/ip_input.c                 |    2 +-
 net/ipv4/ipcomp.c                   |    2 +-
 net/ipv4/ipmr.c                     |    6 +-
 net/ipv4/protocol.c                 |    6 +-
 net/ipv4/tcp.c                      |    2 +-
 net/ipv4/tcp_input.c                |    2 +-
 net/ipv4/tcp_ipv4.c                 |    4 +-
 net/ipv4/tcp_minisocks.c            |    4 +-
 net/ipv4/tunnel4.c                  |    4 +-
 net/ipv4/udplite.c                  |    2 +-
 net/ipv6/addrconf.c                 |   19 +
 net/ipv6/af_inet6.c                 |   10 +-
 net/ipv6/ah6.c                      |    2 +-
 net/ipv6/esp6.c                     |    2 +-
 net/ipv6/exthdrs.c                  |    6 +-
 net/ipv6/icmp.c                     |    4 +-
 net/ipv6/ip6_input.c                |    2 +-
 net/ipv6/ip6mr.c                    |    6 +-
 net/ipv6/ipcomp6.c                  |    2 +-
 net/ipv6/mcast.c                    |   19 +
 net/ipv6/protocol.c                 |    6 +-
 net/ipv6/reassembly.c               |    2 +-
 net/ipv6/tcp_ipv6.c                 |    7 +-
 net/ipv6/tunnel6.c                  |    4 +-
 net/ipv6/udp.c                      |    2 +-
 net/ipv6/udplite.c                  |    2 +-
 net/iucv/af_iucv.c                  |    4 +-
 net/netlink/af_netlink.c            |   51 ++-
 net/netlink/genetlink.c             |    5 +-
 net/phonet/pn_dev.c                 |    9 +-
 net/rds/af_rds.c                    |    2 +-
 net/rose/af_rose.c                  |    4 +-
 net/rxrpc/ar-ack.c                  |    6 +-
 net/rxrpc/ar-internal.h             |   32 +-
 net/rxrpc/ar-key.c                  |  914 +++++++++++++++++++++++++++=
++++++--
 net/rxrpc/ar-security.c             |    8 +-
 net/rxrpc/rxkad.c                   |   47 +-
 net/sched/sch_api.c                 |   29 +-
 net/sched/sch_mq.c                  |   13 +-
 net/sctp/ipv6.c                     |    2 +-
 net/sctp/protocol.c                 |    2 +-
 net/socket.c                        |    1 +
 99 files changed, 1526 insertions(+), 452 deletions(-)
 create mode 100644 firmware/cis/MT5634ZLX.cis.ihex
 create mode 100644 firmware/cis/PCMLM28.cis.ihex
 create mode 100644 firmware/cis/RS-COM-2P.cis.ihex
