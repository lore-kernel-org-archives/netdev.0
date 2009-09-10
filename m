From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-09-09
Date: Wed, 9 Sep 2009 20:10:25 -0400
Message-ID: <20090910001025.GA19645@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46599 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762AbZIJALJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 20:11:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

One last batch of wireless bits for the 2.6.32 merge window... :-)

This includes a number of ath9k updates related especially to bluetooth
coexistance, as well as a number of b43 changes related to support of SDIO
and the associated SSB over SDIO bus support.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 6ec1c69a8f6492fd25722f4762721921da074c12:
  David S. Miller (1):
        net_sched: add classful multiqueue dummy scheduler

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Albert Herranz (1):
      ssb: Implement SDIO host bus support

Christian Lamparter (1):
      ar9170: implement frequency calibration for one-stage/openfw

Holger Schurig (1):
      cfg80211: allow scanning on specified frequencies when using wext-compatibility

Ivo van Doorn (1):
      rt2x00: Hardcode TX ack timeout and consume time

Joe Perches (1):
      MAINTAINERS: Add Atheros Linux wireless drivers home page

Joerg Albert (3):
      ar9170: added phy register initialisation from eeprom values
      ath,ar9170: move CTL_ defines into regd.h
      ath,ar9170: implemented conformance test limit calc. for tx power

Luis R. Rodriguez (5):
      ath9k: propagate ieee80211_alloc_hw() failure
      ath9k: propagate errors on ath_init_device() and request_irq()
      ath9k: claim irq for ath9k, not ath for pci
      wireless: update cfg80211 kconfig entry
      wireless: mark prism54 as deprecated and mark for removal

Michael Buesch (10):
      b43: Use a threaded IRQ handler
      b43: Remove TX spinlock
      b43: Remove DMA/PIO queue locks
      b43: Remove PIO RX workqueue
      b43: remove SHM spinlock
      ssb: Fail ssb modinit, if attach of the buses failed.
      b43: PCMCIA is not experimental anymore
      b43: Really disable QoS, if requested
      b43: Fix sparse warning in hw-tkip code
      b44/b43/b43legacy: Fix switch warnings introduced by SSB-SDIO

Sujith (2):
      ath9k: Fix RX Filter handling for BAR
      ath9k: Fix channelFlags for 2GHZ

Vasanthakumar Thiagarajan (6):
      ath9k: Disable ASPM when btcoex is active
      ath9k: Remove unnecessary casting to u8 in pci_read_config_byte() call
      ath9k: Store subsystem id in struct hw_version
      ath9k: Enable btcoex based on the subsystem id of the device
      ath9k: Get rid of the modparam btcoex_enable
      ath9k: Initialize the priority gpio for BT coex 3-wire

 Documentation/feature-removal-schedule.txt |   29 ++
 MAINTAINERS                                |    2 +
 drivers/net/b44.c                          |   10 +-
 drivers/net/wireless/Kconfig               |   57 +--
 drivers/net/wireless/ath/ar9170/phy.c      |  420 +++++++++++++++++++-
 drivers/net/wireless/ath/ath9k/ahb.c       |   10 +-
 drivers/net/wireless/ath/ath9k/ath9k.h     |    2 +-
 drivers/net/wireless/ath/ath9k/btcoex.c    |   23 +
 drivers/net/wireless/ath/ath9k/btcoex.h    |    2 +
 drivers/net/wireless/ath/ath9k/hw.c        |   30 +-
 drivers/net/wireless/ath/ath9k/hw.h        |   10 +
 drivers/net/wireless/ath/ath9k/mac.h       |    1 +
 drivers/net/wireless/ath/ath9k/main.c      |   12 +-
 drivers/net/wireless/ath/ath9k/pci.c       |   22 +-
 drivers/net/wireless/ath/ath9k/recv.c      |    3 +
 drivers/net/wireless/ath/ath9k/reg.h       |    1 -
 drivers/net/wireless/ath/regd.h            |    6 +
 drivers/net/wireless/ath/regd_common.h     |    6 -
 drivers/net/wireless/b43/Kconfig           |    4 +-
 drivers/net/wireless/b43/b43.h             |   30 +-
 drivers/net/wireless/b43/debugfs.c         |   67 +---
 drivers/net/wireless/b43/debugfs.h         |    3 +-
 drivers/net/wireless/b43/dma.c             |   31 +--
 drivers/net/wireless/b43/dma.h             |    3 -
 drivers/net/wireless/b43/main.c            |  460 +++++++++++-----------
 drivers/net/wireless/b43/main.h            |    4 -
 drivers/net/wireless/b43/phy_common.c      |    1 -
 drivers/net/wireless/b43/phy_common.h      |    3 +-
 drivers/net/wireless/b43/phy_g.c           |    7 -
 drivers/net/wireless/b43/phy_g.h           |    3 +-
 drivers/net/wireless/b43/pio.c             |   71 +---
 drivers/net/wireless/b43/pio.h             |    6 -
 drivers/net/wireless/b43/sysfs.c           |    3 -
 drivers/net/wireless/b43/xmit.c            |   10 +-
 drivers/net/wireless/b43legacy/main.c      |    8 +-
 drivers/net/wireless/rt2x00/rt2400pci.c    |    5 +-
 drivers/net/wireless/rt2x00/rt2500pci.c    |    5 +-
 drivers/net/wireless/rt2x00/rt2500usb.c    |    4 -
 drivers/net/wireless/rt2x00/rt2800usb.c    |    3 +-
 drivers/net/wireless/rt2x00/rt2x00.h       |    3 -
 drivers/net/wireless/rt2x00/rt2x00config.c |   11 -
 drivers/net/wireless/rt2x00/rt61pci.c      |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c      |    2 +-
 drivers/ssb/Kconfig                        |   14 +
 drivers/ssb/Makefile                       |    1 +
 drivers/ssb/main.c                         |   64 +++-
 drivers/ssb/scan.c                         |   11 +
 drivers/ssb/sdio.c                         |  610 ++++++++++++++++++++++++++++
 drivers/ssb/ssb_private.h                  |   40 ++
 include/linux/ssb/ssb.h                    |   25 +-
 net/wireless/Kconfig                       |   11 +-
 net/wireless/scan.c                        |   41 ++-
 52 files changed, 1673 insertions(+), 539 deletions(-)
 create mode 100644 drivers/ssb/sdio.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-09-09.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
