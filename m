From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 00/12] WiMAX patches for 2.6.33 (batch #1)
Date: Wed,  4 Nov 2009 13:39:36 -0800
Message-ID: <cover.1257370735.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:31748 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758252AbZKDVlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  [this series of patches has been split in four batches as it was too
  long; the grouping is just sequential as they are not really
  related, except for dependencies].

Misc fixes: add minimal ethtool support, silly typo fixes, and
dwelve in a set of bad SDIO subdriver's boot-mode interactions with
the hardware timings and ways it managed to corner itself into a
deadlock. 

Please pull from:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git

Patches follow for ease of review.


Cindy H Kao (4):
  wimax/i2400m: fix the bootmode RX deadlock in SDIO driver
  wimax/iwmc3200: overwrite SDIO IOR timeout value to avoid platform
    hang
  wimax/iwmc3200: don't disable the SDIO function if enable fails
  wimax/iwmc3200: increase wait time before enable retry

Dan Williams (1):
  i2400m: minimal ethtool support

Dirk Brandewie (3):
  wimax/i2400m: Update comments to talk about SDIO reset and not USB.
  wimax/i2400m: Ensure boot mode cmd and ack buffers are alloc'd before
    first message
  wimax/i2400m: Make boot retries a BUS-specific parameter

Inaky Perez-Gonzalez (1):
  wimax: indicate initial SW rfkill state is "blocked"

Oliver Neukum (1):
  wimax/i2400m/usb: remove unnecessary power management primitive in
    i2400m

Roel Kluin (2):
  i2400m: keep index within ms_to_errno[]
  wimax: misplaced parenthesis

 drivers/net/wimax/i2400m/control.c     |    2 +-
 drivers/net/wimax/i2400m/driver.c      |   54 +++++++++++++++++++++++--------
 drivers/net/wimax/i2400m/fw.c          |    2 +-
 drivers/net/wimax/i2400m/i2400m-sdio.h |    5 ++-
 drivers/net/wimax/i2400m/i2400m-usb.h  |    1 +
 drivers/net/wimax/i2400m/i2400m.h      |    5 +--
 drivers/net/wimax/i2400m/netdev.c      |   18 ++++++++++
 drivers/net/wimax/i2400m/sdio-fw.c     |    8 ++--
 drivers/net/wimax/i2400m/sdio-rx.c     |    7 ++++
 drivers/net/wimax/i2400m/sdio.c        |   38 +++++++++++++++++-----
 drivers/net/wimax/i2400m/tx.c          |    2 +-
 drivers/net/wimax/i2400m/usb.c         |   11 +++++-
 net/wimax/op-rfkill.c                  |    1 +
 13 files changed, 118 insertions(+), 36 deletions(-)

