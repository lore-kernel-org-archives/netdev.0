From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth fixes for 2.6.27
Date: Tue, 19 Aug 2008 10:23:27 +0200
Message-ID: <1219134207.7591.112.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:57595 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577AbYHSIX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 04:23:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are three fixes for the Bluetooth subsystem.

The removal of the /sys/class/bluetooth symlinks broke userspace
assumption. This has been fixed now in a way we should have done it a
long time ago.

For the btusb driver this adds the promised SCO support. The btusb
driver is a new driver and will eventually replace hci_usb. Adding SCO
support was the last missing piece. All distributions are using the
hci_usb driver at the moment and you can only select one of them. So
this can't introduce any regression. With this change the distributions
are now able to select the new driver if they really want to.

I have one pending optimization for this driver, but that depends on the
USB patches. The usb_unlink_anchored_urbs() is currently broken and thus
we can't use it. I will submit this patch once the USB fixes got merged.

In addition, I finally cleaned out the MAINTAINERS file and the
MODULE_AUTHOR tags to reflect maintainer information.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 MAINTAINERS                   |   87 +---------
 drivers/bluetooth/Kconfig     |   10 +-
 drivers/bluetooth/bt3c_cs.c   |    2 +-
 drivers/bluetooth/btusb.c     |  282 +++++++++++++++++++++++++++++--
 drivers/bluetooth/hci_ldisc.c |    2 +-
 drivers/bluetooth/hci_usb.c   |    2 +-
 drivers/bluetooth/hci_vhci.c  |    2 +-
 net/bluetooth/af_bluetooth.c  |    2 +-
 net/bluetooth/bnep/core.c     |    2 +-
 net/bluetooth/hci_sysfs.c     |  376 +++++++++++++++++++++--------------------
 net/bluetooth/l2cap.c         |    2 +-
 net/bluetooth/rfcomm/core.c   |    2 +-
 net/bluetooth/sco.c           |    2 +-
 13 files changed, 476 insertions(+), 297 deletions(-)

through these ChangeSets:

Marcel Holtmann (3):
    [Bluetooth] Add SCO support to btusb driver
    [Bluetooth] Fix userspace breakage due missing class links
    [Bluetooth] Consolidate maintainers information



