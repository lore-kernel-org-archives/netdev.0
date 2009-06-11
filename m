From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 00/21] WiMAX pull request
Date: Thu, 11 Jun 2009 14:35:37 -0700
Message-ID: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27879 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752365AbZFKVgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pull requests contains a long set of fixes to bugs and issues
found while debugging the SDIO version of the i2400m WiMAX
device. Most of them are in the generic part of the i2400m, and thus,
apply to both the USB and SDIO versions:

 - tweaks and fixes to the firmware loader to ensure it can recover
   the device from corner cases we can get it into and that it can
   support more different varities of hardware

 - SDIO driver improvements: support bus-level reset, make RX fully
   IRQ driven (even in firmware load mode)

 - misc validation/debug assists

 - fix panics caused by some corner cases in the TX code

 - miscellaneous small cleanups in code and documentation

 - compiler warnings in the sh4 architecture


The following changes since commit 0ed586d075ef65c0268982e5b7f36d0ffaa95547:
  Roel Kluin (1):
        atl1c: WAKE_MCAST tested twice, not WAKE_UCAST

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git linux-2.6.31.y

Patches follow for reviewing convenience.

Cindy H Kao (2):
      wimax/i2400m: when bootstrap fails, reinitialize the bootrom
      wimax/i2400m: use -EL3RST to indicate device reset instead of -ERESTARTSYS

Dirk Brandewie (4):
      wimax/i2400m: Change d_printf() level for secure boot messages
      wimax/i2400m/sdio: Implement I2400M_RT_BUS reset type
      wimax/i2400m: move boot time poke table out of common driver
      wimax/i2400m/sdio: Add device specific poke table.

Inaky Perez-Gonzalez (15):
      wimax/i2400m: introduce module parameter to disable entering power save
      wimax/i2400m: don't call netif_start_queue() in _tx_msg_sent()
      wimax/i2400m: i2400m's work queue should be initialized before RX support
      wimax/i2400m: i2400m_schedule_work() doesn't need i2400m->work_queue
      wimax/i2400m: rename misleading I2400M_PL_PAD to I2400M_PL_ALIGN
      wimax/i2400m: fix panic/warnings caused by missed check on empty TX message
      wimax/i2400m: fix panic due to missed corner cases on tail_room calculation
      wimax/i2400m: don't reset device on i2400m_dev_shutdown()
      wimax/i2400m: fix oops when the TX FIFO fills up due to a missing check
      wimax/i2400m: if a device reboot happens during probe, handle it
      wimax/i2400m: Allow bus-specific driver to specify retry count
      wimax/i2400m: don't reset device when bootrom init retries are exceeded
      wimax/i2400m/sdio: Move all the RX code to a unified, IRQ based receive routine
      wimax: fix warning caused by not checking retval of rfkill_set_hw_state()
      wimax: fix gcc warnings in sh4 when calling BUG()

 drivers/net/wimax/i2400m/control.c     |   24 +++++---
 drivers/net/wimax/i2400m/driver.c      |   40 ++++++++----
 drivers/net/wimax/i2400m/fw.c          |   58 ++++++-----------
 drivers/net/wimax/i2400m/i2400m-sdio.h |    9 +++
 drivers/net/wimax/i2400m/i2400m.h      |   43 +++++++++++++
 drivers/net/wimax/i2400m/op-rfkill.c   |    4 +-
 drivers/net/wimax/i2400m/rx.c          |    4 +-
 drivers/net/wimax/i2400m/sdio-fw.c     |  109 ++++++++++++++------------------
 drivers/net/wimax/i2400m/sdio-rx.c     |   47 +++++++++++---
 drivers/net/wimax/i2400m/sdio.c        |   50 ++++++++++++---
 drivers/net/wimax/i2400m/tx.c          |   75 ++++++++++++++++++++--
 drivers/net/wimax/i2400m/usb.c         |    5 +-
 include/linux/wimax/i2400m.h           |    2 +-
 net/wimax/op-rfkill.c                  |    3 +-
 14 files changed, 320 insertions(+), 153 deletions(-)
