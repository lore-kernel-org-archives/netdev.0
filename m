From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 00/28] MISDN patchset for net-next
Date: Mon, 23 Apr 2012 18:03:51 +0200
Message-ID: <20120423170549.33CDA9FB80@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:51031 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333Ab2DWRIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

please include thes patches into netnext.

This patch collection contains bugfixes and enhancemets to make
the mISDN stack ready for Fax G3 support in CAPI20 (in userspace).

Tested against net-next from today.

Andreas Eversberg (7):
  mISDN: Fix NULL pointer bug in if-condition of mISDN_dsp
  mISDN: Fixed hardware bridging/conference check routine of
    mISDN_dsp.ko.
  mISDN: Fixed false interruption of audio during bridging change.
  mISDN: Added PH_* state info to tei manager.
  mISDN: Using FLG_ACTIVE flag to determine if layer 1 is active or
    not.
  mISDN: Rework of LED status display for HFC-4S/8S/E1 cards.
  mISDN: Added support for fragmentation of E1 interfaces of hfcmulti
    driver.

Karsten Keil (20):
  mISDN: Fix division by zero
  mISDN: Fix refcounting bug
  mISDN: Add interface for PCM only access
  mISDN: Add PCM only B-channel protocol to socket functions
  mISDN: L2 timeouts need to be queued as L2 event
  mISDN: Make layer1 timer 3 value configurable
  mISDN: Layer1 statemachine fix
  mISDN: DSP scheduling fix
  mISDN: Help to identify L2 issues
  mISDN: Add 2MBit mode for HFC E1 card
  mISDN: Cleanup channel also if it already was deactivated
  mISDN: Early confirm for transparent data
  mISDN: Allow the driver to set a minimum length for transparent data
  mISDN: Add interface to allow upper layers to modify RX buffer limits
  mISDN: More support for MISDN_CTRL_FILL_EMPTY and MISDN_CTRL_RX_OFF
  mISDN: Fix compiler warnings
  mISDN: Bufferlimits for hfcmulti
  mISDN: Enhance hfcsusb driver
  mISDN: Add X-Tensions USB ISDN TA XC-525
  mISDN: Remove additonal PH_DATA confirm for raw data

Martin Bachem (1):
  mISDN: Bugfix hfcsusb: usb endpoint activation/deactivation

 drivers/isdn/hardware/mISDN/avmfritz.c  |  254 ++++++--
 drivers/isdn/hardware/mISDN/hfc_multi.h |   94 ++--
 drivers/isdn/hardware/mISDN/hfcmulti.c  | 1059 +++++++++++++++++++++----------
 drivers/isdn/hardware/mISDN/hfcpci.c    |   12 +-
 drivers/isdn/hardware/mISDN/hfcsusb.c   |  224 ++++---
 drivers/isdn/hardware/mISDN/hfcsusb.h   |   16 +-
 drivers/isdn/hardware/mISDN/mISDNipac.c |   62 ++-
 drivers/isdn/hardware/mISDN/mISDNisar.c |   22 +-
 drivers/isdn/hardware/mISDN/netjet.c    |   21 +-
 drivers/isdn/hardware/mISDN/w6692.c     |   22 +-
 drivers/isdn/mISDN/core.c               |   16 +
 drivers/isdn/mISDN/dsp.h                |    4 +-
 drivers/isdn/mISDN/dsp_cmx.c            |   19 +-
 drivers/isdn/mISDN/dsp_dtmf.c           |   19 +-
 drivers/isdn/mISDN/hwchannel.c          |    9 +-
 drivers/isdn/mISDN/l1oip_core.c         |    2 +-
 drivers/isdn/mISDN/layer1.c             |   37 +-
 drivers/isdn/mISDN/layer2.c             |  119 +++-
 drivers/isdn/mISDN/socket.c             |    3 +
 drivers/isdn/mISDN/tei.c                |   71 ++-
 include/linux/mISDNhw.h                 |   13 +-
 include/linux/mISDNif.h                 |   88 ++-
 22 files changed, 1485 insertions(+), 701 deletions(-)

-- 
1.7.3.4
