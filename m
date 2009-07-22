From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 21 Jul 2009 21:21:50 -0700 (PDT)
Message-ID: <20090721.212150.76000594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39480
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750702AbZGVEVp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 00:21:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) TCP MD5 signature support was broken when an IPV4 connection
   is made to an ipv6 listening socket.  Fixes from John Dykstra.

2) Netfilter fixes via Patrick McHardy.

3) Fix races with sock refcounting in sock_copy(), from Eric
   Dumazet.

4) Several "dereference before NULL check" fixes from Julia
   Lawall.

5) E100 gets RX descriptor corruption on some platforms, fix
   from Krzysztof Halasa.

6) CAN protocol fixes from Lothar Wa=DFmann and Wolfgang Grandegger.

7) ATL1C has mis-placed parenthesis in some expressions, fixes
   from Roel Kluin.

8) New driver for w90p910 MAC, from Wan ZongShun.

9) Bug fix for CDC-EEM crc checking, from Vincent CUISSARD.

10) SO_TIMESTAMPING sockopt returns bogus error code, fix from
    R=E9mi Denis-Courmont.

11) New CDC Phonet USB driver also from R=E9mi Denis-Courmont.

12) When a device changes type, bonding multicast list must
    be cleaned.

13) Two IXGBE bug fixes from Lucy Liu.

14) Device down race fix in SKY2 driver by Mike McCormack.
    Also revert a bogus SKY2 shutdown change that broke
    startup on some systems, from Stephen Hemminger.

15) Fix OOPS on moduleunload in macsonic/jazzsonic.  From
    Finn Thain.

16) Various MAINTAINER and email address updates from
    Evgeniy Polyakov and Ralf Baechle.

Please pull, thanks a lot!

The following changes since commit e9e961c9a818a2f24711af493b907a8e40a6=
9efc:
  Linus Torvalds (1):
        Merge branch 'i2c-for-2631-rc3' of git://aeryn.fluff.org.uk/bjd=
ooks/linux

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ben Dooks (1):
      net: Micrel KS8851 SPI network driver

Cesar Eduardo Barros (1):
      New device ID for sc92031 [1088:2031]

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6

Dhananjay Phadke (3):
      netxen: fix context deletion sequence
      netxen: fix deadlock on dev close
      netxen: fix thermal check and shutdown

Eric Dumazet (2):
      netfilter: nf_conntrack: nf_conntrack_alloc() fixes
      net: sock_copy() fixes

Evgeniy Polyakov (1):
      connector: maintainer/mail update.

=46inn Thain (1):
      macsonic, jazzsonic: fix oops on module unload

Joe Perches (1):
      netfilter: add netfilter git to MAINTAINERS

John Dykstra (2):
      tcp: Fix MD5 signature checking on IPv4 mapped sockets
      tcp: Use correct peer adr when copying MD5 keys

Julia Lawall (3):
      drivers/net: Move a dereference below a NULL test
      drivers/net: Move a dereference below a NULL test
      drivers/net/mlx4: Adjust constant

Ken Kawasaki (1):
      3c589_cs: re-initialize the multicast in the tc589_reset

Krzysztof Halasa (1):
      E100: work around the driver using streaming DMA mapping for RX d=
escriptors.

Lothar Wa=DFmann (2):
      net/can bugfix: use after free bug in can protocol drivers
      net/can: add module alias to can protocol drivers

Lucy Liu (2):
      ixgbe: clear mac address data block in DCB mode
      ixgbe: Remove DPRINTK messages in DCB mode

Mike McCormack (1):
      sky2: Avoid races in sky2_down

Moni Shoua (1):
      bonding: clean muticast addresses when device changes type

Patrick McHardy (1):
      netfilter: xt_osf: fix nf_log_packet() arguments

Ralf Baechle (2):
      MAINTAINERS entry for STRIP driver
      Update Andreas Koensgen's email address

R=E9mi Denis-Courmont (2):
      Fix error return for setsockopt(SO_TIMESTAMPING)
      USB host CDC Phonet network interface driver

Stephen Hemminger (1):
      sky2: revert shutdown changes

Uwe Kleine-K=F6nig (1):
      macsonic: move probe function to .devinit.text

Vincent CUISSARD (1):
      cdc-eem: bad crc checking

Wan ZongShun (1):
      Add mac driver for w90p910

Wolfgang Grandegger (3):
      can: sja1000: remove duplicated includes
      can: restart device even if dev_alloc_skb() fails
      can: switch carrier on if device was stopped while in bus-off sta=
te

roel kluin (2):
      atl1c: add missing parentheses
      atl1c: misplaced parenthesis

 CREDITS                              |    2 +-
 Documentation/RCU/rculist_nulls.txt  |    7 +-
 Documentation/connector/cn_test.c    |    4 +-
 Documentation/connector/ucon.c       |    2 +-
 Documentation/networking/6pack.txt   |    2 +-
 MAINTAINERS                          |   11 +-
 drivers/connector/cn_queue.c         |    2 +-
 drivers/connector/connector.c        |    4 +-
 drivers/net/Kconfig                  |    6 +
 drivers/net/Makefile                 |    1 +
 drivers/net/arm/Kconfig              |    8 +
 drivers/net/arm/Makefile             |    1 +
 drivers/net/arm/w90p910_ether.c      | 1105 ++++++++++++++++++++++++++=
++
 drivers/net/atl1c/atl1c.h            |    8 +-
 drivers/net/atl1c/atl1c_main.c       |    2 +-
 drivers/net/bnx2x_link.c             |    3 +-
 drivers/net/bonding/bond_main.c      |   12 +-
 drivers/net/can/dev.c                |    8 +-
 drivers/net/can/sja1000/sja1000.c    |    1 -
 drivers/net/e100.c                   |    3 +
 drivers/net/hamradio/6pack.c         |    2 +-
 drivers/net/ibm_newemac/rgmii.c      |    7 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c     |    6 +-
 drivers/net/jazzsonic.c              |    1 +
 drivers/net/ks8851.c                 | 1322 ++++++++++++++++++++++++++=
++++++++
 drivers/net/ks8851.h                 |  296 ++++++++
 drivers/net/macsonic.c               |   15 +-
 drivers/net/mlx4/en_ethtool.c        |    2 +-
 drivers/net/netxen/netxen_nic.h      |    3 +
 drivers/net/netxen/netxen_nic_ctx.c  |   13 +-
 drivers/net/netxen/netxen_nic_hw.c   |    9 +-
 drivers/net/netxen/netxen_nic_init.c |    5 +-
 drivers/net/netxen/netxen_nic_main.c |   36 +-
 drivers/net/pcmcia/3c589_cs.c        |   21 +-
 drivers/net/sc92031.c                |    1 +
 drivers/net/sky2.c                   |   25 +-
 drivers/net/usb/Kconfig              |    8 +
 drivers/net/usb/Makefile             |    1 +
 drivers/net/usb/cdc-phonet.c         |  461 ++++++++++++
 drivers/net/usb/cdc_eem.c            |    2 +-
 include/net/sock.h                   |   32 +-
 include/net/tcp.h                    |    5 +
 net/can/bcm.c                        |    4 +
 net/can/raw.c                        |    4 +
 net/core/sock.c                      |   22 +-
 net/ipv4/tcp_ipv4.c                  |    3 +-
 net/ipv4/tcp_output.c                |    2 +-
 net/ipv6/tcp_ipv6.c                  |    3 +-
 net/netfilter/nf_conntrack_core.c    |   21 +-
 net/netfilter/xt_osf.c               |    5 +-
 50 files changed, 3417 insertions(+), 112 deletions(-)
 create mode 100644 drivers/net/arm/w90p910_ether.c
 create mode 100644 drivers/net/ks8851.c
 create mode 100644 drivers/net/ks8851.h
 create mode 100644 drivers/net/usb/cdc-phonet.c
