From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 09 Feb 2009 20:21:34 -0800 (PST)
Message-ID: <20090209.202134.172521671.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49960
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752123AbZBJEVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 23:21:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Memory leak fixes in ATM and ISDN from Julia Lawall

2) Proper IPV6 tunnel name not used in ipv6 tunneling driver, fix from
   Noriaki Takamiya.

3) Flowlabel socket options can be specified with rediculious sizes
   leading to order 9 page allocations etc., for sanity limit them to
   64K just like we do for other similar cases.

4) Fix sunhme device detection in the case where the system has both
   SBUS and PCI sunhme chips.

5) Unicast filter overflow is handled wrongly in TUN driver, fix
   from Alex Williamson.

6) Neighbour entry dumping can skip entries due to a bug, fix from
   Gautam Kachroo.

7) NULL deref fix in rxrpc from David Howells

8) LRO packets can crash bridging due to a misplaced check, fix from
   Herbert Xu

9) Netfilter fixes from Pablo Neira Ayuso, Qu Haoran, and Eric Leblond via
   Patrick McHardy.

10) Fix 3c509 resum from hibernation on PnP cards, from Ondrej Zery.

11) DE2104X driver code releases TX ring entry to chip (by setting "own" bit)
    before writing the buffer address field.  Fix from Risto Suominen.

Please pull, thanks a lot.

The following changes since commit 4c098bcd55fad34dcf224bf8343db6a9ac58fc68:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../mason/btrfs-unstable

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alex Williamson (1):
      tun: Fix unicast filter overflow

David Howells (1):
      RxRPC: Fix a potential NULL dereference

David S. Miller (3):
      ipv6: Disallow rediculious flowlabel option sizes.
      net_dma: call dmaengine_get only if NET_DMA enabled
      sunhme: Don't match PCI devices in SBUS probe.

Dhananjay Phadke (1):
      netxen: fix msi-x interrupt handling

Eric Leblond (2):
      netfilter: fix tuple inversion for Node information request
      netfilter: nf_conntrack_ipv6: don't track ICMPv6 negotiation message

Eric Van Hensbergen (1):
      9p: fix endian issues [attempt 3]

Gautam Kachroo (1):
      neigh: some entries can be skipped during dumping

Herbert Xu (1):
      bridge: Fix LRO crash with tun

Ilkka Virta (1):
      sungem: Soft lockup in sungem on Netra AC200 when switching interface up

Ivan Vecera (1):
      r8169: Don't update statistics counters when interface is down

Jarek Poplawski (1):
      gianfar: Fix boot hangs while bringing up gianfar ethernet

Jesper Dangaard Brouer (1):
      udp: Fix potential wrong ip_hdr(skb) pointers

Julia Lawall (2):
      drivers/atm: introduce missing kfree
      drivers/isdn: introduce missing kfree

Noriaki TAKAMIYA (1):
      IPv6: fix to set device name when new IPv6 over IPv6 tunnel device is created.

Ondrej Zary (1):
      3c509: Fix resume from hibernation for PnP mode.

Pablo Neira Ayuso (2):
      netfilter: ctnetlink: allow changing NAT sequence adjustment in creation
      netfilter: ctnetlink: fix echo if not subscribed to any multicast group

Qu Haoran (1):
      netfilter: xt_sctp: sctp chunk mapping doesn't work

Risto Suominen (1):
      de2104x: force correct order when writing to rx ring

 drivers/atm/solos-pci.c                        |    1 +
 drivers/isdn/hardware/mISDN/hfcmulti.c         |    2 +
 drivers/net/3c509.c                            |    1 +
 drivers/net/gianfar.c                          |    6 ++
 drivers/net/netxen/netxen_nic.h                |    2 +-
 drivers/net/netxen/netxen_nic_main.c           |   13 +++-
 drivers/net/r8169.c                            |   93 +++++++++++++++---------
 drivers/net/sungem.c                           |    8 +-
 drivers/net/sunhme.c                           |   12 ++-
 drivers/net/tulip/de2104x.c                    |    3 +-
 drivers/net/tun.c                              |   10 ++-
 include/linux/dmaengine.h                      |   12 +++
 net/9p/protocol.c                              |   22 ++++---
 net/bridge/br_forward.c                        |    7 ++-
 net/core/dev.c                                 |    4 +-
 net/core/neighbour.c                           |   14 ++--
 net/ipv4/udp.c                                 |    6 +-
 net/ipv6/ip6_flowlabel.c                       |    8 ++-
 net/ipv6/ip6_tunnel.c                          |    2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   25 ++++++-
 net/netfilter/nf_conntrack_netlink.c           |   15 ++++-
 net/netfilter/xt_sctp.c                        |    2 +-
 net/rxrpc/af_rxrpc.c                           |    5 +-
 23 files changed, 195 insertions(+), 78 deletions(-)
