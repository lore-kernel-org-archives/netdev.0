From: Marcel Holtmann <marcel@holtmann.org>
Subject: Two more Bluetooth btusb fixes for 2.6.27-rc8
Date: Wed, 01 Oct 2008 00:13:37 +0200
Message-ID: <1222812817.1825.75.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:39593 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832AbYI3WNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 18:13:38 -0400
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

I also added a second patch for two new Bluetooth 2.1 devices that came
to market recently that need a quirk to make them work. Both are based
on the same chip, but use different vendor ids. I tested the Targus one
personally.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 drivers/bluetooth/bpa10x.c |    2 --
 drivers/bluetooth/btusb.c  |    7 ++++---
 2 files changed, 4 insertions(+), 5 deletions(-)

through these ChangeSets:

Marcel Holtmann (2):
    [Bluetooth] Fix double frees on error paths of btusb and bpa10x drivers
    [Bluetooth] Add reset quirk for new Targus and Belkin dongles



