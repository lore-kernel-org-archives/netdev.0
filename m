From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 00/13] ISDN: Update for net-next
Date: Sat, 25 Jul 2009 20:34:56 +0200
Message-ID: <cover.1248546896.git.keil@b1-systems.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752345AbZGYUyS@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

This is the collection of ISDN patches for net-next, you can pull them from

git://git.kernel.org/pub/scm/linux/kernel/git/kkeil/ISDN-2.6-net-next for_david

The first 4 patches make the isdnhdlc code usable for other ISDN drivers and
fix minor bugs and lot of cosmetic issues in this code.

The 5. patch moved a function implemented in all mISDN HW drivers in a commom place.

Patch 6-10 add new hardware driver to mISDN, now nearly all PCI HW which was supported by
HiSax is also supported by mISDN and we can start migration.

Patch 11 was posted some time ago from Julia Lawall and remove some unnecessary NULL tests

Patch 12 was posted last week from Stoyan Gaydarov to use ARRAY_SIZE. Modified to avoid
extra defines by me.

Patch 13 is a bugfix for hfcmulti.
 

Julia Lawall (1):
  drivers/isdn: Drop unnecessary NULL test

Karsten Keil (12):
  ISDN: Make isdnhdlc usable for other ISDN drivers
  ISDN: Clean up isdnhdlc code
  ISDN: Add support for none reverse bitstreams to isdnhdc
  ISDN: Fix isdnhdlc for one byte hdlc packets
  mISDN: Make clearing B-channel a common function
  mISDN: Add driver for Infineon ISDN chipset family
  mISDN: Driver for AVM Fritz!CARD PCI
  mISDN: Add support for Speedfax+ cards
  mISDN: Add driver for Winbond cards
  mISDN: Add support for Traverse Technologies NETJet PCI cards
  ISDN: ARRAY_SIZE changes
  mISDN: hfcmulti display real PCI ids for not supported cards

 drivers/isdn/Kconfig                        |    6 +-
 drivers/isdn/act2000/capi.c                 |    3 +-
 drivers/isdn/act2000/module.c               |   31 +-
 drivers/isdn/hardware/eicon/message.c       |    4 +-
 drivers/isdn/hardware/eicon/os_4bri.c       |    3 +-
 drivers/isdn/hardware/mISDN/Kconfig         |   51 +
 drivers/isdn/hardware/mISDN/Makefile        |    8 +
 drivers/isdn/hardware/mISDN/avmfritz.c      | 1152 ++++++++++++++++++
 drivers/isdn/hardware/mISDN/hfcmulti.c      |   23 +-
 drivers/isdn/hardware/mISDN/hfcpci.c        |   16 +-
 drivers/isdn/hardware/mISDN/hfcsusb.c       |   16 +-
 drivers/isdn/hardware/mISDN/iohelper.h      |  109 ++
 drivers/isdn/hardware/mISDN/ipac.h          |  405 +++++++
 drivers/isdn/hardware/mISDN/isar.h          |  269 +++++
 drivers/isdn/hardware/mISDN/mISDNinfineon.c | 1178 ++++++++++++++++++
 drivers/isdn/hardware/mISDN/mISDNipac.c     | 1655 +++++++++++++++++++++++++
 drivers/isdn/hardware/mISDN/mISDNisar.c     | 1726 +++++++++++++++++++++++++++
 drivers/isdn/hardware/mISDN/netjet.c        | 1156 ++++++++++++++++++
 drivers/isdn/hardware/mISDN/netjet.h        |   58 +
 drivers/isdn/hardware/mISDN/speedfax.c      |  526 ++++++++
 drivers/isdn/hardware/mISDN/w6692.c         | 1440 ++++++++++++++++++++++
 drivers/isdn/hardware/mISDN/w6692.h         |  190 +++
 drivers/isdn/hisax/Kconfig                  |    6 +-
 drivers/isdn/hisax/Makefile                 |    4 -
 drivers/isdn/hisax/amd7930_fn.c             |    2 -
 drivers/isdn/hisax/callc.c                  |    4 +-
 drivers/isdn/hisax/hfc_pci.c                |    2 -
 drivers/isdn/hisax/hfc_sx.c                 |    2 -
 drivers/isdn/hisax/icc.c                    |    2 -
 drivers/isdn/hisax/isac.c                   |    2 -
 drivers/isdn/hisax/isdnhdlc.c               |  603 ----------
 drivers/isdn/hisax/isdnhdlc.h               |   70 --
 drivers/isdn/hisax/isdnl1.c                 |   12 +-
 drivers/isdn/hisax/isdnl2.c                 |    4 +-
 drivers/isdn/hisax/isdnl3.c                 |    4 +-
 drivers/isdn/hisax/l3_1tr6.c                |   20 +-
 drivers/isdn/hisax/l3dss1.c                 |   26 +-
 drivers/isdn/hisax/l3ni1.c                  |   26 +-
 drivers/isdn/hisax/q931.c                   |   24 +-
 drivers/isdn/hisax/st5481.h                 |    2 +-
 drivers/isdn/hisax/st5481_b.c               |    5 +-
 drivers/isdn/hisax/st5481_d.c               |    2 +-
 drivers/isdn/hisax/st5481_usb.c             |   11 +-
 drivers/isdn/hisax/tei.c                    |    4 +-
 drivers/isdn/hisax/w6692.c                  |    2 -
 drivers/isdn/i4l/Kconfig                    |   11 +
 drivers/isdn/i4l/Makefile                   |    1 +
 drivers/isdn/i4l/isdnhdlc.c                 |  630 ++++++++++
 drivers/isdn/mISDN/hwchannel.c              |   15 +-
 drivers/isdn/mISDN/layer2.c                 |    2 -
 include/linux/isdn/hdlc.h                   |   82 ++
 include/linux/mISDNhw.h                     |    1 +
 include/linux/mISDNif.h                     |   16 +-
 53 files changed, 10758 insertions(+), 864 deletions(-)
 create mode 100644 drivers/isdn/hardware/mISDN/avmfritz.c
 create mode 100644 drivers/isdn/hardware/mISDN/iohelper.h
 create mode 100644 drivers/isdn/hardware/mISDN/ipac.h
 create mode 100644 drivers/isdn/hardware/mISDN/isar.h
 create mode 100644 drivers/isdn/hardware/mISDN/mISDNinfineon.c
 create mode 100644 drivers/isdn/hardware/mISDN/mISDNipac.c
 create mode 100644 drivers/isdn/hardware/mISDN/mISDNisar.c
 create mode 100644 drivers/isdn/hardware/mISDN/netjet.c
 create mode 100644 drivers/isdn/hardware/mISDN/netjet.h
 create mode 100644 drivers/isdn/hardware/mISDN/speedfax.c
 create mode 100644 drivers/isdn/hardware/mISDN/w6692.c
 create mode 100644 drivers/isdn/hardware/mISDN/w6692.h
 delete mode 100644 drivers/isdn/hisax/isdnhdlc.c
 delete mode 100644 drivers/isdn/hisax/isdnhdlc.h
 create mode 100644 drivers/isdn/i4l/isdnhdlc.c
 create mode 100644 include/linux/isdn/hdlc.h
