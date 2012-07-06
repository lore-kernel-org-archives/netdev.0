From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH 0/4] Add a driver for the ASIX AX88172A
Date: Fri, 6 Jul 2012 13:33:04 +0200
Message-ID: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>,
	Christian Riesch <christian.riesch@omicron.at>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:54477 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030243Ab2GFLqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:46:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch adds a driver for the ASIX AX88172A USB 2.0 to 10/100M
Fast Ethernet Controller.

Although this chip is already supported by the AX88772 code in
drivers/net/usb/asix.c, I submit a new driver since the existing
driver lacks an important feature: It only supports an
Ethernet connection using the internal PHY embedded in the AX88172A.

The driver for the AX88172A is based on drivers/net/usb/asix.c
and the work of Michael Riesch <michael@riesch.at>.

The first patch in the patchset fixes checkpatch warnings in asix.c.

The second and the third patch factor out common code which is shared
between the existing drivers and the new driver for the AX88172A.

The fourth patch finally adds support for the AX88172A.

The patchset applies on top of net-next.

I have a few questions:

1) Is it ok to factor out the common code like I did? Or should
   it go into a separate kernel module?

2) phylib/usbnet: Currently I have an empty .status function
   in my const struct driver_info ax88172a_info. I think this
   notifies me of a link change, right? I don't know
   what I should do in this function. Trigger the phy state machine
   like a phy interrupt would do, since link changes are handled
   by the phy state machine?

I have tested the patch with the ASIX AX88172A demo board (using the
internal PHY) and a custom board (AX88172A and National DP83640 PHY).

I am looking forward to your comments. Since this is my first submission
of a larger patchset to a kernel mailing list, I would like to thank you
in advance for your patience :-) The patch is in an early state and
certainly needs improvement!

Regards, Christian

Christian Riesch (4):
  asix: Fix checkpatch warnings
  asix: Rename asix.c to asix_devices.c
  asix: Factor out common code
  asix: Add a new driver for the AX88172A

 drivers/net/usb/Makefile       |    1 +
 drivers/net/usb/asix.c         | 1660 ----------------------------------------
 drivers/net/usb/asix.h         |  211 +++++
 drivers/net/usb/asix_common.c  |  525 +++++++++++++
 drivers/net/usb/asix_devices.c | 1033 +++++++++++++++++++++++++
 drivers/net/usb/ax88172a.c     |  407 ++++++++++
 6 files changed, 2177 insertions(+), 1660 deletions(-)
 delete mode 100644 drivers/net/usb/asix.c
 create mode 100644 drivers/net/usb/asix.h
 create mode 100644 drivers/net/usb/asix_common.c
 create mode 100644 drivers/net/usb/asix_devices.c
 create mode 100644 drivers/net/usb/ax88172a.c
