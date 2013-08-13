From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 0/7] add FlexRay support
Date: Tue, 13 Aug 2013 11:08:34 +0200
Message-ID: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:48265 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756Ab3HMJIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 05:08:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds FlexRay support to the Linux Kernel. FlexRay is designed and
used as a successor of Controller Area Network (CAN) in the automotive fields.
FlexRay is specified in ISO 10681. A quick overview is available here:

http://en.wikipedia.org/wiki/FlexRay

The driver implementation adds support for the Eberspaecher Electronics
FlexCard. The FlexCard is a PCI Mezzanine Card with piggybacks for automotive
buses like CAN, LIN and FlexRay. An implementation based on multifunctional
devices (MFD) was choosen. The independant IP cores (FlexRay, CAN, etc) can be
supported by separate drivers. In addition to the automotive busses the
FlexCard provides some generic functions coverd by the clocksoure and the UIO
drivers. The AF_FLEXRAY protocol can be used to send and receive flexray frames
from the userland.

Benedikt Spranger (7):
  uio: add module owner to prevent inappropriate module unloading
  uio: Allow to create custom UIO attributes
  mfd: core: copy DMA mask and params from parent
  mfd: add MFD based flexcard driver
  clocksource: Add flexcard support
  net: add the AF_FLEXRAY protocol
  net: add a flexray driver

 Documentation/networking/00-INDEX             |    2 +
 Documentation/networking/flexray.txt          |   24 +
 drivers/clocksource/Kconfig                   |   13 +
 drivers/clocksource/Makefile                  |    2 +
 drivers/clocksource/flexcard_clk.c            |  297 +++
 drivers/clocksource/flexcard_evt.c            |  161 ++
 drivers/mfd/Kconfig                           |   42 +
 drivers/mfd/Makefile                          |    2 +
 drivers/mfd/flexcard-core.c                   | 1059 +++++++++++
 drivers/mfd/flexcard-dma.c                    |  561 ++++++
 drivers/mfd/flexcard-irq.c                    |  333 ++++
 drivers/mfd/flexcard.h                        |    8 +
 drivers/mfd/mfd-core.c                        |    2 +
 drivers/net/Makefile                          |    1 +
 drivers/net/flexray/Kconfig                   |   41 +
 drivers/net/flexray/Makefile                  |   12 +
 drivers/net/flexray/dev.c                     |  700 +++++++
 drivers/net/flexray/flexcard_fr.c             | 2480 +++++++++++++++++++++++++
 drivers/net/flexray/vflexray.c                |   99 +
 drivers/uio/uio.c                             |  115 +-
 include/linux/eray.h                          |  650 +++++++
 include/linux/flexcard.h                      |   95 +
 include/linux/flexray.h                       |  168 ++
 include/linux/flexray/core.h                  |   45 +
 include/linux/flexray/dev.h                   |   64 +
 include/linux/socket.h                        |    4 +-
 include/linux/uio_driver.h                    |   38 +-
 include/uapi/linux/Kbuild                     |    2 +
 include/uapi/linux/eray.h                     |   34 +
 include/uapi/linux/flexcard.h                 |  429 +++++
 include/uapi/linux/flexray/Kbuild             |    4 +
 include/uapi/linux/flexray/flexcard_netlink.h |   53 +
 include/uapi/linux/flexray/netlink.h          |  203 ++
 include/uapi/linux/flexray/raw.h              |   16 +
 include/uapi/linux/if_arp.h                   |    1 +
 include/uapi/linux/if_ether.h                 |    1 +
 net/Kconfig                                   |    1 +
 net/Makefile                                  |    1 +
 net/core/sock.c                               |    9 +-
 net/flexray/Kconfig                           |   30 +
 net/flexray/Makefile                          |    9 +
 net/flexray/af_flexray.c                      |  548 ++++++
 net/flexray/af_flexray.h                      |   59 +
 net/flexray/proc.c                            |  196 ++
 net/flexray/raw.c                             |  446 +++++
 45 files changed, 9047 insertions(+), 13 deletions(-)
 create mode 100644 Documentation/networking/flexray.txt
 create mode 100644 drivers/clocksource/flexcard_clk.c
 create mode 100644 drivers/clocksource/flexcard_evt.c
 create mode 100644 drivers/mfd/flexcard-core.c
 create mode 100644 drivers/mfd/flexcard-dma.c
 create mode 100644 drivers/mfd/flexcard-irq.c
 create mode 100644 drivers/mfd/flexcard.h
 create mode 100644 drivers/net/flexray/Kconfig
 create mode 100644 drivers/net/flexray/Makefile
 create mode 100644 drivers/net/flexray/dev.c
 create mode 100644 drivers/net/flexray/flexcard_fr.c
 create mode 100644 drivers/net/flexray/vflexray.c
 create mode 100644 include/linux/eray.h
 create mode 100644 include/linux/flexcard.h
 create mode 100644 include/linux/flexray.h
 create mode 100644 include/linux/flexray/core.h
 create mode 100644 include/linux/flexray/dev.h
 create mode 100644 include/uapi/linux/eray.h
 create mode 100644 include/uapi/linux/flexcard.h
 create mode 100644 include/uapi/linux/flexray/Kbuild
 create mode 100644 include/uapi/linux/flexray/flexcard_netlink.h
 create mode 100644 include/uapi/linux/flexray/netlink.h
 create mode 100644 include/uapi/linux/flexray/raw.h
 create mode 100644 net/flexray/Kconfig
 create mode 100644 net/flexray/Makefile
 create mode 100644 net/flexray/af_flexray.c
 create mode 100644 net/flexray/af_flexray.h
 create mode 100644 net/flexray/proc.c
 create mode 100644 net/flexray/raw.c

-- 
1.8.4.rc2
