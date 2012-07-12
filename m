From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH v2 0/3] Add a driver for the ASIX AX88172A with phylib support
Date: Thu, 12 Jul 2012 10:18:23 +0200
Message-ID: <1342081106-8647-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Joe Perches <joe@perches.com>,
	Michael Riesch <michael@riesch.at>,
	Christian Riesch <christian.riesch@omicron.at>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:59139 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757170Ab2GLIRj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 04:17:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this is v2 of my patchset that adds a driver for the ASIX AX88172A USB 2.0
to 10/100M Fast Ethernet Controller.

Although this chip is already supported by the AX88772 code in
drivers/net/usb/asix.c, I submit a new driver since the existing
driver lacks an important feature: It only supports an
Ethernet connection that is using the internal PHY embedded in the
AX88172A, although the chip also provides an MII interface to connect
an external PHY.

The new driver supports both the internal and the external PHY using
the phylib.

The driver for the AX88172A is based on drivers/net/usb/asix.c
and the work of Michael Riesch <michael@riesch.at>.

The first and the second patch factor out common code which is shared
between the existing drivers and the new driver for the AX88172A. The
third patch adds support for the AX88172A.

The patchset applies on top of net-next.

Changes for v2:
- Rebased to current net-next.
- Dropped the first patch with ridiculous checkpatch fixes, the new version
  of the patchset only fixes the code that it touches.
- Changed the way the code is factored out in the patchset. This allows
  git to detect that the code was just moved, not changed.
- In v1 I accidentally duplicated the code for reading the phy address
  from the asix chip. Now the drivers use common code in asix_common.c.
- Moved phy_connect(), phy_start() to ax88172a_reset() (called when
  the network interface is started) and phy_stop() to ax88172a_stop().
  It seems to me that this is the way to do it since other drivers
  do the same.
- Changed the naming of the mdio bus, since the way it was done in v1
  could lead to bus names that are too long. Now the mdio bus is labeled 
  usb-<usb bus number>-<usb device number>.
- Cleanup of debug and error messages, in v1 dbg() was used instead
  of netdev_err() for some error messages.
- Changed to order of the fields in struct ax88172a_private (comment from
  Grant Grundler).
- Use #defines instead of magic numbers in ax88172a_bind()

I have tested the patch with the ASIX AX88172A demo board (using the
internal PHY) and a custom board (AX88172A and National DP83640 PHY).

I am looking forward to your comments! :-)

Regards, Christian


Christian Riesch (3):
  asix: Rename asix.c to asix_devices.c
  asix: Factor out common code
  asix: Add a new driver for the AX88172A

 drivers/net/usb/Makefile       |    1 +
 drivers/net/usb/asix.c         | 1680 ----------------------------------------
 drivers/net/usb/asix.h         |  217 ++++++
 drivers/net/usb/asix_common.c  |  545 +++++++++++++
 drivers/net/usb/asix_devices.c | 1028 ++++++++++++++++++++++++
 drivers/net/usb/ax88172a.c     |  423 ++++++++++
 6 files changed, 2214 insertions(+), 1680 deletions(-)
 delete mode 100644 drivers/net/usb/asix.c
 create mode 100644 drivers/net/usb/asix.h
 create mode 100644 drivers/net/usb/asix_common.c
 create mode 100644 drivers/net/usb/asix_devices.c
 create mode 100644 drivers/net/usb/ax88172a.c
