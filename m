From: Jon Smirl <jonsmirl@gmail.com>
Subject: Re: [RFC][WIP] IEEE 802.15.4 implementation for Linux v1
Date: Fri, 5 Jun 2009 00:03:30 -0400
Message-ID: <9e4733910906042103q6c21886cia02d33cb278cef1e@mail.gmail.com>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, slapin@ossfans.org,
	maxim.osipov@siemens.com, dmitry.baryshkov@siemens.com,
	oliver.fendt@siemens.com
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:26444 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbZFEEK1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 00:10:27 -0400
In-Reply-To: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 1, 2009 at 10:54 AM, Dmitry
Eremin-Solenikov<dbaryshkov@gmail.com> wrote:
> Hi,
>
> As a part of research activities the Embedded Systems - Open Platform=
 Group
> from Siemens Corporate Technology we are working on adding support fo=
r
> the IEEE 802.15.4 Wireless Personal Area Networks to the Linux. Our c=
urrent
> implementation is neither certified nor even feature complete. Howeve=
r
> we'd like to present current state of our patchset to the Linux devel=
opers
> community to gain comments, fixes, ideas, etc. This is not yet a pull=
 request,
> but more like an RFC.

Does this stack work with the Atmel USB version of at86rf230?
ATAVRRZUSBSTICK, http://www.atmel.com/dyn/products/tools_card.asp?tool_=
id=3D4396

It's not so simple to plug in the at86rf230 using SPI. Supporting USB
sticks lets you develop on a desktop PC.

freaklabs.org is using ATAVRRZUSBSTICK


>
> The project page is available at http://apps.sourceforge.net/trac/lin=
ux-zigbee
> with source code of kernel part available from git at
> http://zigbee-linux.git.sourceforge.net, mirrored for convenience at
> git://git.kernel.org/pub/scm/linux/kernel/git/lumag/lowpan.git
>
> The source code for userspace utils is available from git at
> http://linux-zigbee.git.sourceforge.net/
>
> Changes since previous RFC:
> =A0* Split the code into socket family, netlink interface and separat=
e
> =A0 =A0MAC 802.15.4 implementation.
> =A0* Add a sample driver for devices implementing mac level of IEEE 8=
02.15.4
> =A0 =A0on their own.
> =A0* Major cleanup of public interfaces.
> =A0* Drop our CRC implementation and use a variant of CRC-ITU-T one
> =A0* Add preliminary version of AT86RF231 Atmel chip driver
>
> The following changes since commit 59a3759d0fe8d969888c741bb33f4946e4=
d3750d:
> =A0Linus Torvalds (1):
> =A0 =A0 =A0 =A0Linux 2.6.30-rc7
>
> are available in the git repository at:
>
> =A0git://git.kernel.org/pub/scm/linux/kernel/git/lumag/lowpan.git for=
-review-v1
>
> Darren Salt (1):
> =A0 =A0 =A0crc-itu-t: add bit-reversed calculation
>
> Dmitry Eremin-Solenikov (9):
> =A0 =A0 =A0Add constants for the ieee 802.15.4/ZigBee stack
> =A0 =A0 =A0net: add IEEE 802.15.4 socket family implementation
> =A0 =A0 =A0net: add NL802154 interface for configuration of 802.15.4 =
devices
> =A0 =A0 =A0ieee802154: add simple HardMAC driver sample
> =A0 =A0 =A0mac802154: add a software MAC 802.15.4 implementation
> =A0 =A0 =A0ieee802154: add virtual loopback driver
> =A0 =A0 =A0tty_io: export tty_class
> =A0 =A0 =A0ieee802154: add serial dongle driver
> =A0 =A0 =A0ieee802154: add at86rf230/rf231 spi driver
>
> =A0drivers/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A01 +
> =A0drivers/char/tty_io.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
1 +
> =A0drivers/ieee802154/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 | =A0 42 ++
> =A0drivers/ieee802154/Makefile =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A06 +
> =A0drivers/ieee802154/at86rf230.c =A0 =A0 =A0 =A0 | =A0971 ++++++++++=
+++++++++++++++++++++
> =A0drivers/ieee802154/fakehard.c =A0 =A0 =A0 =A0 =A0| =A0253 ++++++++
> =A0drivers/ieee802154/fakelb.c =A0 =A0 =A0 =A0 =A0 =A0| =A0335 ++++++=
+++++
> =A0drivers/ieee802154/serial.c =A0 =A0 =A0 =A0 =A0 =A0| =A0999 ++++++=
++++++++++++++++++++++++++
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
2 +
> =A0include/linux/crc-itu-t.h =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 10 +
> =A0include/linux/if.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
2 +
> =A0include/linux/if_arp.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 =
+
> =A0include/linux/if_ether.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +
> =A0include/linux/socket.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 =
+-
> =A0include/linux/spi/at86rf230.h =A0 =A0 =A0 =A0 =A0| =A0 32 +
> =A0include/linux/tty.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
3 +-
> =A0include/net/ieee802154/af_ieee802154.h | =A0 60 ++
> =A0include/net/ieee802154/mac802154.h =A0 =A0 | =A0 79 +++
> =A0include/net/ieee802154/mac_def.h =A0 =A0 =A0 | =A0158 +++++
> =A0include/net/ieee802154/netdevice.h =A0 =A0 | =A0 84 +++
> =A0include/net/ieee802154/nl802154.h =A0 =A0 =A0| =A0165 ++++++
> =A0lib/crc-itu-t.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 18 +
> =A0net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 =A02 +
> =A0net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A02 +
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A06 +-
> =A0net/core/sock.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A03 +
> =A0net/ieee802154/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 12 +
> =A0net/ieee802154/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 =
+
> =A0net/ieee802154/af802154.h =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 35 ++
> =A0net/ieee802154/af_ieee802154.c =A0 =A0 =A0 =A0 | =A0356 ++++++++++=
++
> =A0net/ieee802154/dgram.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0373 ++=
++++++++++
> =A0net/ieee802154/netlink.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0485 ++++=
++++++++++++
> =A0net/ieee802154/raw.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0250 =
++++++++
> =A0net/mac802154/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 13 =
+
> =A0net/mac802154/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A05 =
+
> =A0net/mac802154/beacon.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0242 ++=
++++++
> =A0net/mac802154/beacon.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 48 ++
> =A0net/mac802154/beacon_hash.c =A0 =A0 =A0 =A0 =A0 =A0| =A0103 ++++
> =A0net/mac802154/beacon_hash.h =A0 =A0 =A0 =A0 =A0 =A0| =A0 40 ++
> =A0net/mac802154/dev.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A084=
3 +++++++++++++++++++++++++++
> =A0net/mac802154/mac802154.h =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 64 ++
> =A0net/mac802154/mac_cmd.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0325 ++=
+++++++++
> =A0net/mac802154/main.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 96 =
+++
> =A0net/mac802154/mdev.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0283 =
+++++++++
> =A0net/mac802154/mib.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 3=
2 +
> =A0net/mac802154/pib.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 8=
7 +++
> =A0net/mac802154/pib.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 3=
5 ++
> =A0net/mac802154/scan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0215 =
+++++++
> =A048 files changed, 7187 insertions(+), 4 deletions(-)
> =A0create mode 100644 drivers/ieee802154/Kconfig
> =A0create mode 100644 drivers/ieee802154/Makefile
> =A0create mode 100644 drivers/ieee802154/at86rf230.c
> =A0create mode 100644 drivers/ieee802154/fakehard.c
> =A0create mode 100644 drivers/ieee802154/fakelb.c
> =A0create mode 100644 drivers/ieee802154/serial.c
> =A0create mode 100644 include/linux/spi/at86rf230.h
> =A0create mode 100644 include/net/ieee802154/af_ieee802154.h
> =A0create mode 100644 include/net/ieee802154/mac802154.h
> =A0create mode 100644 include/net/ieee802154/mac_def.h
> =A0create mode 100644 include/net/ieee802154/netdevice.h
> =A0create mode 100644 include/net/ieee802154/nl802154.h
> =A0create mode 100644 net/ieee802154/Kconfig
> =A0create mode 100644 net/ieee802154/Makefile
> =A0create mode 100644 net/ieee802154/af802154.h
> =A0create mode 100644 net/ieee802154/af_ieee802154.c
> =A0create mode 100644 net/ieee802154/dgram.c
> =A0create mode 100644 net/ieee802154/netlink.c
> =A0create mode 100644 net/ieee802154/raw.c
> =A0create mode 100644 net/mac802154/Kconfig
> =A0create mode 100644 net/mac802154/Makefile
> =A0create mode 100644 net/mac802154/beacon.c
> =A0create mode 100644 net/mac802154/beacon.h
> =A0create mode 100644 net/mac802154/beacon_hash.c
> =A0create mode 100644 net/mac802154/beacon_hash.h
> =A0create mode 100644 net/mac802154/dev.c
> =A0create mode 100644 net/mac802154/mac802154.h
> =A0create mode 100644 net/mac802154/mac_cmd.c
> =A0create mode 100644 net/mac802154/main.c
> =A0create mode 100644 net/mac802154/mdev.c
> =A0create mode 100644 net/mac802154/mib.h
> =A0create mode 100644 net/mac802154/pib.c
> =A0create mode 100644 net/mac802154/pib.h
> =A0create mode 100644 net/mac802154/scan.c
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>



--=20
Jon Smirl
jonsmirl@gmail.com
