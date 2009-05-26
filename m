From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC][WIP] IEEE 802.15.4 implementation for Linux
Date: Tue, 26 May 2009 15:21:57 +0400
Message-ID: <20090526112157.GA19976@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org, maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

As a part of research activities in the Embedded Systems - Open Platform Group
from Siemens Corporate Technology we are working on adding support for
the IEEE 802.15.4 Wireless Personal Area Networks to the Linux. Our current
implementation is neither certified nor even feature complete. However
we'd like to present current state of our patchset to the Linux developers
community to gain comments, fixes, ideas, etc. This is not yet a pull request,
but more like an RFC.

The project page is available at http://apps.sourceforge.net/trac/linux-zigbee
with source code of kernel part available from git at
http://zigbee-linux.git.sourceforge.net, mirrored for convenience at
git://git.kernel.org/pub/scm/linux/kernel/git/lumag/lowpan.git

The source code for userspace utils is available from git at
http://linux-zigbee.git.sourceforge.net/

Several comments about our implementation:
* As with 802.11 there are two types of devices: the smart ones that implement
  most parts of the protocol by themselves and more or less dumb ones which
  simply send and receive what they are told. Currently we do only support the
  second type of devices (SoftMAC)
* The implementation is split between code driving radio, (master, mwpanX
  interface: mdev.c), code processing frames according the IEEE 802.15.4
  rules (slave wpanX devices) and finally sockets (af_ieee802154.c, dgram.c,
  raw.c).
* We do present two example drivers using our stack. One is purely virtual
  one either looping the packets back or connecting several virtual interfaces
  (the one at fakelb.c), and the driver for the Freescale MC13192 evaluation
  boards (13192-SARD, 13192-EVK) using our custom firmware (currently only
  available at request, we are working on publishing it). The driver for the
  Atmel at86rf230/at86rf231 chips will follow in several weeks.

The following changes since commit 59a3759d0fe8d969888c741bb33f4946e4d3750d:
  Linus Torvalds (1):
        Linux 2.6.30-rc7

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lumag/lowpan.git for-review-v0

Dmitry Eremin-Solenikov (5):
      Add constants for the ieee 802.15.4/ZigBee stack
      net: add IEEE 802.15.4 partial implementation
      ieee802154: add socket address family code
      ieee802154: add virtual loopback driver
      ieee802154: add serial dongle driver

 drivers/Makefile                       |    1 +
 drivers/ieee802154/Kconfig             |   26 +
 drivers/ieee802154/Makefile            |    4 +
 drivers/ieee802154/fakelb.c            |  335 +++++++++++
 drivers/ieee802154/serial.c            | 1001 ++++++++++++++++++++++++++++++++
 drivers/net/Kconfig                    |    2 +
 include/linux/if.h                     |    2 +
 include/linux/if_arp.h                 |    2 +
 include/linux/if_ether.h               |    2 +
 include/linux/socket.h                 |    6 +-
 include/linux/tty.h                    |    3 +-
 include/net/ieee802154/af_ieee802154.h |   65 ++
 include/net/ieee802154/beacon.h        |   53 ++
 include/net/ieee802154/beacon_hash.h   |   40 ++
 include/net/ieee802154/const.h         |  696 ++++++++++++++++++++++
 include/net/ieee802154/crc.h           |   38 ++
 include/net/ieee802154/dev.h           |  107 ++++
 include/net/ieee802154/mac_def.h       |   96 +++
 include/net/ieee802154/netdev.h        |   74 +++
 include/net/ieee802154/nl.h            |  166 ++++++
 include/net/ieee802154/phy.h           |  117 ++++
 net/Kconfig                            |    1 +
 net/Makefile                           |    1 +
 net/core/dev.c                         |    6 +-
 net/core/sock.c                        |    3 +
 net/ieee802154/Kconfig                 |   12 +
 net/ieee802154/Makefile                |    6 +
 net/ieee802154/af_ieee802154.c         |  312 ++++++++++
 net/ieee802154/beacon.c                |  251 ++++++++
 net/ieee802154/beacon_hash.c           |  105 ++++
 net/ieee802154/crc.c                   |   73 +++
 net/ieee802154/dev.c                   |  935 +++++++++++++++++++++++++++++
 net/ieee802154/dgram.c                 |  372 ++++++++++++
 net/ieee802154/mac_cmd.c               |  226 +++++++
 net/ieee802154/main.c                  |  175 ++++++
 net/ieee802154/mdev.c                  |  189 ++++++
 net/ieee802154/netlink.c               |  637 ++++++++++++++++++++
 net/ieee802154/raw.c                   |  249 ++++++++
 net/ieee802154/scan.c                  |  211 +++++++
 net/ieee802154/start.c                 |   46 ++
 40 files changed, 6642 insertions(+), 4 deletions(-)
 create mode 100644 drivers/ieee802154/Kconfig
 create mode 100644 drivers/ieee802154/Makefile
 create mode 100644 drivers/ieee802154/fakelb.c
 create mode 100644 drivers/ieee802154/serial.c
 create mode 100644 include/net/ieee802154/af_ieee802154.h
 create mode 100644 include/net/ieee802154/beacon.h
 create mode 100644 include/net/ieee802154/beacon_hash.h
 create mode 100644 include/net/ieee802154/const.h
 create mode 100644 include/net/ieee802154/crc.h
 create mode 100644 include/net/ieee802154/dev.h
 create mode 100644 include/net/ieee802154/mac_def.h
 create mode 100644 include/net/ieee802154/netdev.h
 create mode 100644 include/net/ieee802154/nl.h
 create mode 100644 include/net/ieee802154/phy.h
 create mode 100644 net/ieee802154/Kconfig
 create mode 100644 net/ieee802154/Makefile
 create mode 100644 net/ieee802154/af_ieee802154.c
 create mode 100644 net/ieee802154/beacon.c
 create mode 100644 net/ieee802154/beacon_hash.c
 create mode 100644 net/ieee802154/crc.c
 create mode 100644 net/ieee802154/dev.c
 create mode 100644 net/ieee802154/dgram.c
 create mode 100644 net/ieee802154/mac_cmd.c
 create mode 100644 net/ieee802154/main.c
 create mode 100644 net/ieee802154/mdev.c
 create mode 100644 net/ieee802154/netlink.c
 create mode 100644 net/ieee802154/raw.c
 create mode 100644 net/ieee802154/scan.c
 create mode 100644 net/ieee802154/start.c

-- 
With best wishes
Dmitry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
