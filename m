From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 0/7] More enabler patches for DSA probing
Date: Tue, 10 May 2016 23:27:18 +0200
Message-ID: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34990 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752577AbcEJV2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 17:28:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The complete set of patches for the reworked DSA probing is too big to
post as once. These subset contains some enablers which are easy to
review.

Eventually, the Marvell driver will instantiate its own internal MDIO
bus, rather than have the framework do it, thus allows devices on the
bus to be listed in the device tree. Initialize the main mutex as soon
as it is created, to avoid lifetime issues with the mdio bus.

A previous patch renamed all the DSA probe functions to make room for
a true device probe. However the recent merging of all the Marvell
switch drivers resulted in mv88e6xxx going back to the old probe
name. Rename it again, so we can have a driver probe function.

Add minimum support for the Marvell switch driver to probe as an MDIO
device, as well as an DSA driver. Later patches will then register
this device with the new DSA core framework.

Move the GPIO reset code out of the DSA code. Different drivers may
need different reset mechanisms, e.g. via a reset controller for
memory mapped devices. Don't clutter up the core with this. Let each
driver implement what it needs.

master_dev is no longer needed in the switch drivers, since they have
access to a device pointer from the probe function. Remove it.

Let the switch parse the eeprom length from its one device tree
node. This is required with the new binding when the central DSA
platform device no longer exists.

Andrew Lunn (7):
  dsa: mv88e6xxx: Initialise the mutex as soon as it is created
  dsa: mv88e6xxx: Rename probe function to fit the normal pattern
  dsa: Add mdio device support to Marvell switches
  dsa: Move gpio reset into switch driver
  dsa: Remove master_dev from switch structure
  dsa: Rename switch chip data to cd
  dsa: mv88e6xxx: Handle eeprom-length property

 Documentation/devicetree/bindings/net/dsa/dsa.txt  |   2 -
 .../devicetree/bindings/net/dsa/marvell.txt        |  35 ++++++
 drivers/net/dsa/bcm_sf2.c                          |   4 +-
 drivers/net/dsa/mv88e6xxx.c                        | 137 +++++++++++++++++----
 drivers/net/dsa/mv88e6xxx.h                        |  10 ++
 include/net/dsa.h                                  |  19 +--
 net/dsa/dsa.c                                      |  36 ++----
 net/dsa/slave.c                                    |  12 +-
 8 files changed, 177 insertions(+), 78 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/marvell.txt

-- 
2.8.1
