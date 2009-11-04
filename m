From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 00/13] WiMAX patches for 2.6.33 (batch #4)
Date: Wed,  4 Nov 2009 13:39:55 -0800
Message-ID: <cover.1257370737.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:17987 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932752AbZKDVmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  [this series of patches has been split in four batches as it was too
  long; the grouping is just sequential as they are not really
  related, except for dependencies].

Misc independent small fixes; most relevant are: don't overwrite MAC
headers so tcpdump/wireshark can use it, fix of an OOPS during TX
shutdown; fix OOPS when exiting USB kthreads.

Please pull from:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git

Patches follow for ease of review.


Cindy H Kao (2):
  wimax/i2400m: use JUMP cmd for last FW chunk indication
  wimax/i2400m: change the bcf_len to exclude the extended header size

Inaky Perez-Gonzalez (11):
  wimax/i2400m: reduce verbosity of debug messages in boot mode
  wimax/i2400m: fix race condition with tcpdump et al
  wimax: allow user space to send messages once the device is
    registered
  wimax: allow WIMAX_RF_QUERY calls when state is still uninitialized
  wimax/i2400m: when stopping the device, cancel any pending message
  wimax/i2400m: fix deadlock: don't do BUS reset under
    i2400m->init_mutex
  wimax/i2400m: move i2400m_init() out of i2400m.h
  wimax/i2400m: queue device's report until the driver is ready for
    them
  wimax/i2400m: fix oops in TX when tearing down the device
  wimax/i2400m: Let device's status reports change the device state
  wimax/i2400m: fix oops caused by race condition when exiting USB
    kthreads

 drivers/net/wimax/i2400m/driver.c  |  117 +++++++++++-------------------
 drivers/net/wimax/i2400m/fw.c      |   30 +++++---
 drivers/net/wimax/i2400m/i2400m.h  |   48 ++++--------
 drivers/net/wimax/i2400m/netdev.c  |   21 +++++-
 drivers/net/wimax/i2400m/rx.c      |  142 ++++++++++++++++++++++++++++-------
 drivers/net/wimax/i2400m/sdio-rx.c |    2 +-
 drivers/net/wimax/i2400m/sdio-tx.c |    5 +-
 drivers/net/wimax/i2400m/tx.c      |   18 ++++-
 drivers/net/wimax/i2400m/usb-rx.c  |   35 +++++++--
 drivers/net/wimax/i2400m/usb-tx.c  |   35 ++++++++-
 drivers/net/wimax/i2400m/usb.c     |   14 +++-
 net/wimax/op-msg.c                 |    2 +
 net/wimax/op-rfkill.c              |    9 ++-
 13 files changed, 310 insertions(+), 168 deletions(-)

