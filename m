From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-2.6 2010-02-05
Date: Fri,  5 Feb 2010 12:05:33 -0800
Message-ID: <cover.1265399549.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54196 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809Ab0BEUGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 15:06:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are a few more fixes that are mostly a result from the Bluetooth
UnPlugFest testing in Seattle during this week.

The important one are the fix for the sleeping function call in the
RFCOMM timer that show up with certain hardware (not all of them) and
also the fix for double release of the underlaying L2CAP session.

With the HID subsystem changes that turns it into a proper bus, the
HIDP code ended up with a potential case where we access userspace
memory out of the scop of its ioctl() command. Fix this by just keeping
a copy of the HID report descriptor around. The HID subsystem will need
that anyway.

The rest are some SCO/eSCO audio setup fixes with broken hardware and
closing a memory leak in the Marvell driver.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 drivers/bluetooth/btmrvl_sdio.c |    1 +
 net/bluetooth/hci_conn.c        |    3 ++
 net/bluetooth/hci_event.c       |    1 +
 net/bluetooth/hidp/core.c       |   49 +++++++++++++++++++--------------------
 net/bluetooth/hidp/hidp.h       |    4 ++-
 net/bluetooth/rfcomm/core.c     |    8 ++++-
 6 files changed, 38 insertions(+), 28 deletions(-)

through these ChangeSets:

Marcel Holtmann (1):
    Bluetooth: Fix sleeping function in RFCOMM within invalid context

Michael Poole (1):
    Bluetooth: Keep a copy of each HID device's report descriptor

Nick Pelly (3):
    Bluetooth: Fallback eSCO to SCO on error 0x1a (Unsupported Remote
    Bluetooth: Do not call rfcomm_session_put() for RFCOMM UA on closed
    Bluetooth: Enter active mode before establishing a SCO link.

Yoichi Yuasa (1):
    Bluetooth: Fix memory leak in Marvell BT-over-SDIO driver

