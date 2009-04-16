From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 16 Apr 2009 04:12:55 -0700 (PDT)
Message-ID: <20090416.041255.47106723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41208
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752902AbZDPLNE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 07:13:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I was trying to wait for the netfilter/RCU issue to be resolved
before pushing, but that still seems to require some more things
to be worked out.

In trying to do that, more than usual has accumulated and for
this I apologize.  There should be a lot less here, however it
would have been more incremental if I hadn't held out for the
netfilter RCU thing.  Some of these fixes would have made -rc2
as well, c'est la vie, I guess...

Note there is a merge changeset in here because a conflict had
to be resolved in the MAINTAINERS file.

1) Initial congestion window fix in TCP from Ilpo J=E4rvinen.

2) Two GRO fixes and a TUN fix from Herbert Xu.

3) phylib was converted to schedule_delayed_work() but the time
   offset arguments weren't converted properly.  Fix from
   Atsushi Nemoto.

4) When setting up the AF_PACKET mmap() ring, the code handles memory
   allocation failures adequately and propagates the error back to
   userspace, so we should use GFP_NOWARN.  From Eric Dumazet.

5) Timewait socket OOPS fix in ipv6 from Vlad Yasevich.

6) Remove bogus bonding driver debug printk that triggers under
   normal usage.  From Jay Vosburgh.

7) Driver fixes:

   Several build fixes via netdev_ops conversions from Alexander Berega=
lov.

   Intel ethernet driver powerdown fixes from Rafael J. Wysocki.

   MTU changing BUG() trigger fix in skge from Michal Schmidt.

   Chip reset crash fix in gianfar from Markus Brunner.

   via-velocity IRQ handler typing fix from S=E9guier R=E9gis.

   myri10ge LRO alignment fix from Stanislaw Gruszka

   tg3 big-endian NVRAM MAC address fix from James Bottomley, actually
   this one is likely to have some followups and tweaks...
  =20
   forcedeth uses wrong napi_*() interfaces resulting in crashes,
   fix from your's truly.

   sfc fix for NAPI add/delete balancing and event bitfield setting
   from Ben Hutchings.

   Several Intel driver bug fixes (WOL settings, virtual function numbe=
r
   vf_data checks, etc.) from Alexander Duyck.

8) Device leak in token-ring layer code, fix from Wei Yongjun.

9) PHY layer does not handle platform_device_register_simple() error
   returns properly, fix from Dan Carpenter.

Please pull, thanks a lot!

The following changes since commit 3ee8da87ba6151ec91b2b8bbd27633bb248e=
a0d5:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../tiwai/soun=
d-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (1):
      be2net: fix for default setting of pause auto-negotiation

Alexander Beregalov (25):
      fs_enet: convert to netdev_ops
      ibm_newemac: convert to netdev_ops
      ariadne: convert to net_device_ops
      am79c961a: convert to net_device_ops
      at91_ether: convert to net_device_ops
      ep93xx_eth: convert to net_device_ops
      ether1: convert to net_device_ops
      ether3: convert to net_device_ops
      xtsonic: convert to net_device_ops
      tsi108_eth: convert to net_device_ops
      tc35815: convert to net_device_ops
      sun3_82586: convert to net_device_ops
      sh_eth: convert to net_device_ops
      macsonic: convert to net_device_ops
      macb: convert to net_device_ops
      mac89x0: convert to net_device_ops
      isa-skeleton: convert to net_device_ops
      ioc3-eth: convert to net_device_ops
      eth_v10: convert to net_device_ops
      ehea: Fix incomplete conversion to net_device_ops
      a2065: convert to net_device_ops
      atarilance: convert to net_device_ops
      au1000: convert to net_device_ops
      bfin_mac: convert to net_device_ops
      declance: convert to net_device_ops

Alexander Duyck (5):
      net: netif_device_attach/detach should start/stop all queues
      ixgbe: only allow WOL for 82599 KX4 NIC
      igb: fix unused external references introduced with sr-iov change=
s
      igbvf: fix unused external references
      igb: do not check for vf_data if we didn't enable vfs

Anatolij Gustschin (2):
      phylib: Allow early-out in phy_change
      phylib: Add interrupt source check function to M88E1121R driver

Atsushi Nemoto (1):
      phylib: Fix delay argument of schedule_delayed_work

Ben Hutchings (3):
      net: Update maintainers
      sfc: Match calls to netif_napi_add() and netif_napi_del()
      sfc: Use correct macro to set event bitfield

Brian Haley (1):
      Bonding: fix zero address hole bug in arp_ip_target list

Dan Carpenter (1):
      phy: error handling for platform_device_register_simple()

David S. Miller (3):
      forcedeth: Use napi_complete() not __napi_complete().
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Revert "rose: zero length frame filtering in af_rose.c"

Eric Dumazet (1):
      packet: avoid warnings when high-order page allocation fails

Herbert Xu (3):
      gro: Normalise skb before bypassing GRO on netpoll VLAN path
      tun: Fix crash with non-GSO users
      gro: Restore correct value to gso_size

Ilpo J=E4rvinen (1):
      tcp: fix >2 iw selection

James Bottomley (1):
      tg3: fix big endian MAC address collection failure

Jay Vosburgh (1):
      bonding: Remove debug printk

Jesse Brandeburg (1):
      e1000/e1000: fix compile warning

Markus Brunner (1):
      gianfar: stop send queue before resetting gianfar

Michal Schmidt (1):
      skge: fix occasional BUG during MTU change

PJ Waskiewicz (1):
      ixgbe: Move the LED blink code to common, since 82599 also uses i=
t

Rafael J. Wysocki (3):
      NET/e1000: Fix powering off during shutdown
      NET/e1000e: Fix powering off during shutdown
      NET/ixgbe: Fix powering off during shutdown

Sergei Poselenov (1):
      phylib: Basic support for the M88E1121R Marvell chip

Stanislaw Gruszka (1):
      myr10ge: again fix lro_gen_skb() alignment

Stephen Hemminger (1):
      netsched: Allow meta match on vlan tag on receive

S=E9guier R=E9gis (1):
      via-velocity : fix compilation warning.

Vlad Yasevich (1):
      ipv6: Fix NULL pointer dereference with time-wait sockets

Wei Yongjun (1):
      tr: fix leakage of device in net/802/tr.c

Wu Fengguang (2):
      ixgbe: fix tx queue index
      ixgbe: update real_num_tx_queues on changing num_rx_queues

Yang Hongyang (1):
      ipv6:remove useless check

 Documentation/networking/bonding.txt |    2 +-
 MAINTAINERS                          |   13 ++-----
 drivers/net/a2065.c                  |   17 +++++++---
 drivers/net/ariadne.c                |   19 +++++++---
 drivers/net/arm/am79c961a.c          |   24 ++++++++-----
 drivers/net/arm/at91_ether.c         |   32 ++++++++++-------
 drivers/net/arm/ep93xx_eth.c         |   19 +++++++---
 drivers/net/arm/ether1.c             |   19 +++++++---
 drivers/net/arm/ether3.c             |   19 +++++++---
 drivers/net/atarilance.c             |   18 ++++++----
 drivers/net/au1000_eth.c             |   23 ++++++++----
 drivers/net/benet/be_ethtool.c       |    4 +-
 drivers/net/bfin_mac.c               |   24 ++++++++-----
 drivers/net/bonding/bond_alb.c       |    2 -
 drivers/net/bonding/bond_main.c      |    5 +--
 drivers/net/bonding/bond_sysfs.c     |   14 ++++---
 drivers/net/cris/eth_v10.c           |   30 ++++++++++-------
 drivers/net/declance.c               |   17 +++++++---
 drivers/net/e1000/e1000_main.c       |   48 +++++++++++++++++++-------=
-
 drivers/net/e1000e/netdev.c          |   61 +++++++++++++++++++++++++-=
-------
 drivers/net/ehea/ehea_main.c         |    4 +-
 drivers/net/forcedeth.c              |    4 +-
 drivers/net/fs_enet/fs_enet-main.c   |   27 +++++++++-----
 drivers/net/gianfar.c                |    2 +
 drivers/net/ibm_newemac/core.c       |   41 ++++++++++++++++-------
 drivers/net/igb/e1000_mac.c          |    2 +-
 drivers/net/igb/e1000_mac.h          |    1 -
 drivers/net/igb/e1000_mbx.c          |   17 +--------
 drivers/net/igb/e1000_mbx.h          |    2 -
 drivers/net/igb/igb_main.c           |   37 ++++++++++++--------
 drivers/net/igbvf/igbvf.h            |    3 --
 drivers/net/igbvf/netdev.c           |    9 +++--
 drivers/net/igbvf/vf.c               |    2 +-
 drivers/net/igbvf/vf.h               |    1 -
 drivers/net/ioc3-eth.c               |   22 ++++++++----
 drivers/net/isa-skeleton.c           |   20 +++++++----
 drivers/net/ixgbe/ixgbe_82598.c      |   59 +-------------------------=
------
 drivers/net/ixgbe/ixgbe_82599.c      |   40 +---------------------
 drivers/net/ixgbe/ixgbe_common.c     |   55 ++++++++++++++++++++++++++=
++++
 drivers/net/ixgbe/ixgbe_common.h     |    3 ++
 drivers/net/ixgbe/ixgbe_ethtool.c    |   24 +++++++++++++-
 drivers/net/ixgbe/ixgbe_main.c       |   57 ++++++++++++++++++++++++--=
------
 drivers/net/mac89x0.c                |   18 +++++++---
 drivers/net/macb.c                   |   19 +++++++---
 drivers/net/macsonic.c               |   19 +++++++---
 drivers/net/myri10ge/myri10ge.c      |    1 +
 drivers/net/phy/fixed.c              |    5 ++-
 drivers/net/phy/marvell.c            |   54 ++++++++++++++++++++++++++=
++++
 drivers/net/phy/phy.c                |   14 ++++++--
 drivers/net/sfc/efx.c                |    7 ++--
 drivers/net/sfc/falcon.c             |    4 +-
 drivers/net/sh_eth.c                 |   21 ++++++++----
 drivers/net/skge.c                   |    4 +-
 drivers/net/sun3_82586.c             |   19 +++++++---
 drivers/net/tc35815.c                |   27 +++++++++-----
 drivers/net/tg3.c                    |    9 ++++-
 drivers/net/tsi108_eth.c             |   20 +++++++----
 drivers/net/tun.c                    |    5 ++-
 drivers/net/via-velocity.c           |    4 +-
 drivers/net/xtsonic.c                |   19 +++++++---
 include/linux/phy.h                  |    6 +++
 include/net/udp.h                    |    2 -
 net/802/tr.c                         |    3 ++
 net/8021q/vlan_core.c                |    4 ++-
 net/core/dev.c                       |    9 +++--
 net/ipv4/tcp_input.c                 |    3 ++
 net/ipv4/udp.c                       |    3 +-
 net/ipv6/ipv6_sockglue.c             |    4 --
 net/ipv6/udp.c                       |    6 +++-
 net/packet/af_packet.c               |    5 ++-
 net/rose/af_rose.c                   |   10 -----
 net/sched/em_meta.c                  |    6 ++-
 72 files changed, 734 insertions(+), 438 deletions(-)
