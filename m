From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-2.6 2010-01-30
Date: Sat, 30 Jan 2010 06:08:43 -0800
Message-ID: <cover.1264859950.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:60242 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab0A3OJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 09:09:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

this includes two L2CAP fixes. One for a memory leak and another one for
a double free.

For Bluetooth PCMCIA cards a BUG_ON caused a few issues when we have
shared interrupts. So revert this and put a clear comment in the source
that this is what we actually want.

The Bluetooth HID fix for raw reports has a big diffstat, but the logical
change is small. By accident we send the reports on the interrupt channel
and the original test device seems to cope with that. Devices that follow
the specification more closer will break. The right thing is to use the
control channel. This is similar to what is done via USB.

And by request from Luis, include the driver for Atheros Bluetooth chipset
AR3011. It is a new driver and by itself small and self contained. If you
feel that it should not be merged, then let me know and I redo this
patchset.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 drivers/bluetooth/Kconfig       |   13 +++-
 drivers/bluetooth/Makefile      |    1 +
 drivers/bluetooth/ath3k.c       |  187 +++++++++++++++++++++++++++++++++++++++
 drivers/bluetooth/bluecard_cs.c |    4 +-
 drivers/bluetooth/bt3c_cs.c     |    4 +-
 drivers/bluetooth/btuart_cs.c   |    4 +-
 drivers/bluetooth/dtl1_cs.c     |    4 +-
 net/bluetooth/hidp/core.c       |   70 ++++++++-------
 net/bluetooth/l2cap.c           |   14 ++--
 9 files changed, 254 insertions(+), 47 deletions(-)
 create mode 100644 drivers/bluetooth/ath3k.c

through these ChangeSets:

Andrei Emeltchenko (2):
    Bluetooth: Remove double free of SKB pointer in L2CAP
    Bluetooth: Fix memory leak in L2CAP

Bastien Nocera (1):
    Bluetooth: Use the control channel for raw HID reports

Mike Frysinger (1):
    Bluetooth: Redo checks in IRQ handler for shared IRQ support

Vikram Kandukuri (1):
    Bluetooth: Add DFU driver for Atheros Bluetooth chipset AR3011

