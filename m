From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 00/13] WiMAX patches for 2.6.33 (batch #3)
Date: Wed,  4 Nov 2009 13:39:51 -0800
Message-ID: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20716 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932731AbZKDVmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  [this series of patches has been split in four batches as it was too
  long; the grouping is just sequential as they are not really
  related, except for dependencies].

Add support for two new SKUs of the USB and SDIO devices. USB: fix
resume timing out when requesting firmware (caching it); add
reset_resume support. Initialization sequence cleanup, introducing
bus_setup/bus_release() function pointers to allow simpler .pre and
.post reset implementations that move complexity away from the bus
specific subdrivers. 

Please pull from:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git

Patches follow for ease of review.


Cindy H Kao (1):
  wimax/iwmc3200: add new sdio device ID to support iwmc3200 2.5GHz sku

Dirk Brandewie (1):
  wimax/i6x50: add Intel WiFi/WiMAX Link 6050 Series support

Inaky Perez-Gonzalez (11):
  wimax/i2400m: clean up & add a payload argument to
    i2400m_schedule_work()
  wimax/i2400m: add reason argument to i2400m_dev_reset_handle()
  wimax/i2400m: cache firmware on system suspend
  wimax/i2400m: implement .reset_resume in USB subdriver
  wimax/i2400m: don't overwrite error codes when failing to load
    firmware
  wimax/i2400m: on device stop, clean up pending wake & TX work
  wimax/i2400m: cleanup initialization/destruction flow
  wimax/i2400m: clarify and fix i2400m->{ready,updown}
  wimax/i2400m: introduce i2400m->bus_setup/release
  wimax/i2400m: do bootmode buffer management in i2400m_setup/release()
  wimax/i2400m: Implement pre/post reset support in the USB driver

 drivers/net/wimax/i2400m/driver.c     |  332 ++++++++++++++++++++++++++-------
 drivers/net/wimax/i2400m/fw.c         |  163 +++++++++++++++--
 drivers/net/wimax/i2400m/i2400m-usb.h |    3 +
 drivers/net/wimax/i2400m/i2400m.h     |  109 +++++++++--
 drivers/net/wimax/i2400m/netdev.c     |   63 ++++---
 drivers/net/wimax/i2400m/rx.c         |   16 +-
 drivers/net/wimax/i2400m/sdio-rx.c    |    2 +-
 drivers/net/wimax/i2400m/sdio.c       |  116 +++++++-----
 drivers/net/wimax/i2400m/usb-notif.c  |    2 +-
 drivers/net/wimax/i2400m/usb.c        |   92 ++++++++--
 include/linux/mmc/sdio_ids.h          |    1 +
 include/linux/wimax/i2400m.h          |    1 +
 include/net/wimax.h                   |    6 +
 13 files changed, 705 insertions(+), 201 deletions(-)

