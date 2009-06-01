From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC][WIP] IEEE 802.15.4 implementation for Linux v1
Date: Mon,  1 Jun 2009 18:54:41 +0400
Message-ID: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org, maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

As a part of research activities the Embedded Systems - Open Platform Group
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

Changes since previous RFC:
  * Split the code into socket family, netlink interface and separate
    MAC 802.15.4 implementation.
  * Add a sample driver for devices implementing mac level of IEEE 802.15.4
    on their own.
  * Major cleanup of public interfaces.
  * Drop our CRC implementation and use a variant of CRC-ITU-T one
  * Add preliminary version of AT86RF231 Atmel chip driver

The following changes since commit 59a3759d0fe8d969888c741bb33f4946e4d3750d:
  Linus Torvalds (1):
        Linux 2.6.30-rc7

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lumag/lowpan.git for-review-v1

Darren Salt (1):
      crc-itu-t: add bit-reversed calculation

Dmitry Eremin-Solenikov (9):
      Add constants for the ieee 802.15.4/ZigBee stack
      net: add IEEE 802.15.4 socket family implementation
      net: add NL802154 interface for configuration of 802.15.4 devices
      ieee802154: add simple HardMAC driver sample
      mac802154: add a software MAC 802.15.4 implementation
      ieee802154: add virtual loopback driver
      tty_io: export tty_class
      ieee802154: add serial dongle driver
      ieee802154: add at86rf230/rf231 spi driver

 drivers/Makefile                       |    1 +
 drivers/char/tty_io.c                  |    1 +
 drivers/ieee802154/Kconfig             |   42 ++
 drivers/ieee802154/Makefile            |    6 +
 drivers/ieee802154/at86rf230.c         |  971 +++++++++++++++++++++++++++++++
 drivers/ieee802154/fakehard.c          |  253 ++++++++
 drivers/ieee802154/fakelb.c            |  335 +++++++++++
 drivers/ieee802154/serial.c            |  999 ++++++++++++++++++++++++++++++++
 drivers/net/Kconfig                    |    2 +
 include/linux/crc-itu-t.h              |   10 +
 include/linux/if.h                     |    2 +
 include/linux/if_arp.h                 |    2 +
 include/linux/if_ether.h               |    2 +
 include/linux/socket.h                 |    6 +-
 include/linux/spi/at86rf230.h          |   32 +
 include/linux/tty.h                    |    3 +-
 include/net/ieee802154/af_ieee802154.h |   60 ++
 include/net/ieee802154/mac802154.h     |   79 +++
 include/net/ieee802154/mac_def.h       |  158 +++++
 include/net/ieee802154/netdevice.h     |   84 +++
 include/net/ieee802154/nl802154.h      |  165 ++++++
 lib/crc-itu-t.c                        |   18 +
 net/Kconfig                            |    2 +
 net/Makefile                           |    2 +
 net/core/dev.c                         |    6 +-
 net/core/sock.c                        |    3 +
 net/ieee802154/Kconfig                 |   12 +
 net/ieee802154/Makefile                |    5 +
 net/ieee802154/af802154.h              |   35 ++
 net/ieee802154/af_ieee802154.c         |  356 ++++++++++++
 net/ieee802154/dgram.c                 |  373 ++++++++++++
 net/ieee802154/netlink.c               |  485 ++++++++++++++++
 net/ieee802154/raw.c                   |  250 ++++++++
 net/mac802154/Kconfig                  |   13 +
 net/mac802154/Makefile                 |    5 +
 net/mac802154/beacon.c                 |  242 ++++++++
 net/mac802154/beacon.h                 |   48 ++
 net/mac802154/beacon_hash.c            |  103 ++++
 net/mac802154/beacon_hash.h            |   40 ++
 net/mac802154/dev.c                    |  843 +++++++++++++++++++++++++++
 net/mac802154/mac802154.h              |   64 ++
 net/mac802154/mac_cmd.c                |  325 +++++++++++
 net/mac802154/main.c                   |   96 +++
 net/mac802154/mdev.c                   |  283 +++++++++
 net/mac802154/mib.h                    |   32 +
 net/mac802154/pib.c                    |   87 +++
 net/mac802154/pib.h                    |   35 ++
 net/mac802154/scan.c                   |  215 +++++++
 48 files changed, 7187 insertions(+), 4 deletions(-)
 create mode 100644 drivers/ieee802154/Kconfig
 create mode 100644 drivers/ieee802154/Makefile
 create mode 100644 drivers/ieee802154/at86rf230.c
 create mode 100644 drivers/ieee802154/fakehard.c
 create mode 100644 drivers/ieee802154/fakelb.c
 create mode 100644 drivers/ieee802154/serial.c
 create mode 100644 include/linux/spi/at86rf230.h
 create mode 100644 include/net/ieee802154/af_ieee802154.h
 create mode 100644 include/net/ieee802154/mac802154.h
 create mode 100644 include/net/ieee802154/mac_def.h
 create mode 100644 include/net/ieee802154/netdevice.h
 create mode 100644 include/net/ieee802154/nl802154.h
 create mode 100644 net/ieee802154/Kconfig
 create mode 100644 net/ieee802154/Makefile
 create mode 100644 net/ieee802154/af802154.h
 create mode 100644 net/ieee802154/af_ieee802154.c
 create mode 100644 net/ieee802154/dgram.c
 create mode 100644 net/ieee802154/netlink.c
 create mode 100644 net/ieee802154/raw.c
 create mode 100644 net/mac802154/Kconfig
 create mode 100644 net/mac802154/Makefile
 create mode 100644 net/mac802154/beacon.c
 create mode 100644 net/mac802154/beacon.h
 create mode 100644 net/mac802154/beacon_hash.c
 create mode 100644 net/mac802154/beacon_hash.h
 create mode 100644 net/mac802154/dev.c
 create mode 100644 net/mac802154/mac802154.h
 create mode 100644 net/mac802154/mac_cmd.c
 create mode 100644 net/mac802154/main.c
 create mode 100644 net/mac802154/mdev.c
 create mode 100644 net/mac802154/mib.h
 create mode 100644 net/mac802154/pib.c
 create mode 100644 net/mac802154/pib.h
 create mode 100644 net/mac802154/scan.c
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
