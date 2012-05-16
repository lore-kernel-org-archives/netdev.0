From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH v2 0/8] mISDN: Fixes and enhancements for the data channels
Date: Wed, 16 May 2012 11:51:00 +0200
Message-ID: <1337161868-19399-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:56660 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966799Ab2EPKA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 06:00:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

Thanks for the detailed review.

v2: All fixes from Dave Millers review
   - comment format
   - use bool type for boolean parameter
   - use (var == CONSTANT)

This series improve the stability of streaming raw voice data when the
system is under high load. With the fixes in place you can send and
receive multiple faximilies (using SPANDSP) in parallel
while compiling a kernel without a getting a transfer aborted.

for net-next


Karsten Keil (7):
  mISDN: Cleanup channel also if it already was deactivated
  mISDN: Early confirm for transparent data
  mISDN: avmfritz use the bigger fifo of chip version 2
  mISDN: Reduce RX buffer allocation for transparent data
  mISDN: Allow to set a minimum length for transparent data
  mISDN: Implement MISDN_CTRL_FILL_EMPTY for more drivers
  mISDN: Implement MISDN_CTRL_RX_OFF for more drivers

Martin Bachem (1):
  mISDN: Bugfix hfcsusb: usb endpoint activation/deactivation

 drivers/isdn/hardware/mISDN/avmfritz.c  |  223 +++++++++++++++++--------------
 drivers/isdn/hardware/mISDN/hfcmulti.c  |  117 +++++++----------
 drivers/isdn/hardware/mISDN/hfcpci.c    |   98 +++++---------
 drivers/isdn/hardware/mISDN/hfcsusb.c   |  137 ++++++++-----------
 drivers/isdn/hardware/mISDN/mISDNipac.c |  128 ++++++++----------
 drivers/isdn/hardware/mISDN/mISDNisar.c |  131 ++++++++-----------
 drivers/isdn/hardware/mISDN/netjet.c    |  213 +++++++++++++++---------------
 drivers/isdn/hardware/mISDN/w6692.c     |  135 +++++++++----------
 drivers/isdn/mISDN/dsp_core.c           |    1 +
 drivers/isdn/mISDN/hwchannel.c          |  162 ++++++++++++++++++++---
 drivers/isdn/mISDN/l1oip_core.c         |    2 +-
 include/linux/mISDNhw.h                 |   22 +++-
 include/linux/mISDNif.h                 |    9 +-
 13 files changed, 711 insertions(+), 667 deletions(-)

-- 
1.7.3.4
