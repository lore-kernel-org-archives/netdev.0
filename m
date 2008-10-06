From: Marcel Holtmann <marcel@holtmann.org>
Subject: Final Bluetooth driver fixes for 2.6.27-rc8
Date: Mon, 06 Oct 2008 13:02:35 +0200
Message-ID: <1223290955.11272.154.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:59363 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393AbYJFLCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 07:02:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the btusb and bpa10x drivers have double frees due to a thinking mistake
with the URB_FREE_BUFFER flag. Rafael confirmed that this fixes his last
hibernation issue. I think that was the last regression that we had for
this driver. All full suspend/resume and auto-suspend/remote-wakeup
patches are queued for 2.6.28 now. I am happy that we finally fixed the
real cause and not worked around it with adding suspend and resume
callbacks. We did that for the old hci_usb driver and it was a bad idea.

During the last two weeks also new Bluetooth 2.1 dongles appeared on the
market and finally I tested all three of them. All of them need a quirk
entry to make them work. They are all based on the same chip, but they
are using different vendor and product ids.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 drivers/bluetooth/bpa10x.c |    2 --
 drivers/bluetooth/btusb.c  |    8 +++++---
 2 files changed, 5 insertions(+), 5 deletions(-)

through these ChangeSets:

Marcel Holtmann (3):
    [Bluetooth] Fix double frees on error paths of btusb and bpa10x drivers
    [Bluetooth] Add reset quirk for new Targus and Belkin dongles
    [Bluetooth] Add reset quirk for A-Link BlueUSB21 dongle



