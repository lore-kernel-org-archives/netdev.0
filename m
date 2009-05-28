From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 00/10] WiMAX pull request
Date: Wed, 27 May 2009 18:05:05 -0700
Message-ID: <cover.1243472509.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:59892 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752550AbZE1BFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 21:05:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pull request for 2.6.31 adds a new WiMAX API call for getting the
device state (from Paulius Zaleckas), fixes random stuff in the
i2400m, adds a debug facility to trace commands sent to the device and
cleans up state-report handling code.

The following changes since commit 7d18f114897ff4358419b14d551e704a4299a440:
  David S. Miller (1):
        net: Fix arg to trace_napi_poll() in netpoll.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git linux-2.6.31.y

Patches follow for reviewing convenience.

Inaky Perez-Gonzalez (9):
      wimax/i2400m: generate fake source MAC address with random_ether_addr()
      wimax/i2400m: trace commands sent from user space on the "echo" pipe
      wimax/i2400m: allow kernel commands to device to be logged too
      wimax/i2400m: factor out 'state report's TLV handling to a function
      wimax/i2400m: remove redundant readiness checks from i2400m_report_tlv_*()
      wimax: document why wimax_msg_*() operations can be used in any state
      wimax/i2400m: sdio: set the block size before enabling the function
      wimax/i2400m: usb: fix device reset on autosuspend while not yet idle
      wimax: a new API call was added, increment minor protocol version number

Paulius Zaleckas (1):
      wimax: Add netlink interface to get device state

 drivers/net/wimax/i2400m/control.c |  100 ++++++++++++++++++++----------------
 drivers/net/wimax/i2400m/driver.c  |    5 +-
 drivers/net/wimax/i2400m/i2400m.h  |    5 ++
 drivers/net/wimax/i2400m/netdev.c  |    3 +-
 drivers/net/wimax/i2400m/rx.c      |    6 ++-
 drivers/net/wimax/i2400m/sdio.c    |   18 +++---
 drivers/net/wimax/i2400m/usb.c     |   35 +++++++++++--
 include/linux/wimax.h              |    7 ++-
 net/wimax/Makefile                 |    1 +
 net/wimax/debug-levels.h           |    1 +
 net/wimax/debugfs.c                |    1 +
 net/wimax/op-msg.c                 |   17 +++++-
 net/wimax/op-state-get.c           |   86 +++++++++++++++++++++++++++++++
 net/wimax/stack.c                  |    5 ++-
 14 files changed, 221 insertions(+), 69 deletions(-)
 create mode 100644 net/wimax/op-state-get.c
