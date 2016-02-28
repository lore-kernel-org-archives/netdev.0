From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 00/32] Make DSA switches linux devices.
Date: Sun, 28 Feb 2016 17:41:08 +0100
Message-ID: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45004 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759643AbcB1Qnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:43:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second RFC for rearchitecturing how DSA devices are
probed. This patchset allows switches to be linux devices, probed by
the ususal mechanism for whatever bus they hang off. They then
register with the DSA core.

DSA has been limited to devices which hang off an MDIO bus, or with a
bit of work, memory mapped devices. This refactoring generalizes DSA
so that switches on other sorts of busses, eg. SPI can be supported.

The code should remain backwards compatible. The old device tree
binding are still supported. It is extended with phandles to switch
devices.

The changes also make it eaiser for the drivers to be kernel modules,
and the patches contain cleanups and fixes so that the modules can be
unloaded and loaded.

Patches can be found in

https://github.com/lunn/linux.git v4.5-rc2-net-next-dsa-proposal-4


Andrew Lunn (30):
  dsa: Rename mv88e6123_61_65 to mv88e6123 to be consistent
  dsa: Make setup and finish more symmetrical
  net: dsa: Pass the dsa device to the switch drivers
  net: dsa: Have the switch driver allocate there own private memory
  net: dsa: Remove allocation of driver private memory
  net: dsa: Keep the mii bus and address in the private structure
  net: dsa: dsa.c: Refactor to increase symmetry
  driver: component: Add support for empty match table
  net: dsa: Add basic support for component master support
  net: dsa: Keep a reference to the switch device for component matching
  net: dsa: Add slave component matches based on a phandle to the slave.
  net: dsa: Make dsa,mii-bus optional
  net: dsa: Add register/unregister functions for switch drivers
  net: dsa: Rename DSA probe function.
  dsa: mv88e6xxx: Use bus in mv88e6xxx_lookup_name()
  dsa: mv88e6xxx: Add shared code for binding/unbinding a switch driver.
  dsa: mv88e6xxx: Prepare for turning this into a library module
  dsa: mv88e6xxx: Add macro for registering the drivers
  dsa: Add mdio device support to Marvell switches
  net: mdio: Add mdiodev_{read|write} helpers
  net: dsa: Better integrate the drivers with mdio device
  net: dsa: Add some debug prints for error cases
  net: dsa: Setup the switches after all have been probed
  net: dsa: Only setup platform switches, not device switches
  net: dsa: If a switch fails to probe, defer probing
  Documentation: DSA: Describe how probe of DSA and switches work.
  dsa: slave: Don't reference NULL pointer during phy_disconnect
  dsa: Destroy fixed link phys after the phy has been disconnected
  dsa: dsa: Fix freeing of fixed-phys from user ports.
  phy: fixed: Fix removal of phys.

Florian Fainelli (2):
  net: dsa: Move platform data allocation for OF
  net: dsa: bcm_sf2: make it a real platform driver

 .../devicetree/bindings/net/dsa/broadcom.txt       |  54 +++
 Documentation/devicetree/bindings/net/dsa/dsa.txt  |   5 +-
 .../devicetree/bindings/net/dsa/marvell.txt        |  29 ++
 Documentation/networking/dsa/dsa.txt               |  48 +++
 drivers/base/component.c                           |  33 +-
 drivers/net/dsa/Kconfig                            |   2 +-
 drivers/net/dsa/Makefile                           |  19 +-
 drivers/net/dsa/bcm_sf2.c                          | 292 +++++++++-------
 drivers/net/dsa/mv88e6060.c                        | 138 +++++++-
 drivers/net/dsa/mv88e6060.h                        |  10 +
 drivers/net/dsa/mv88e6123.c                        | 173 ++++++++++
 drivers/net/dsa/mv88e6123_61_65.c                  | 124 -------
 drivers/net/dsa/mv88e6131.c                        |  70 +++-
 drivers/net/dsa/mv88e6171.c                        |  70 +++-
 drivers/net/dsa/mv88e6352.c                        |  72 +++-
 drivers/net/dsa/mv88e6xxx.c                        | 200 +++++++----
 drivers/net/dsa/mv88e6xxx.h                        |  40 ++-
 drivers/net/phy/fixed_phy.c                        |  10 +-
 drivers/net/phy/mdio_device.c                      |  68 ++++
 include/linux/mdio.h                               |   5 +
 include/linux/phy_fixed.h                          |   2 +-
 include/net/dsa.h                                  |  17 +-
 net/dsa/dsa.c                                      | 372 ++++++++++++++-------
 net/dsa/slave.c                                    |  12 +-
 24 files changed, 1339 insertions(+), 526 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/broadcom.txt
 create mode 100644 Documentation/devicetree/bindings/net/dsa/marvell.txt
 create mode 100644 drivers/net/dsa/mv88e6123.c
 delete mode 100644 drivers/net/dsa/mv88e6123_61_65.c

-- 
2.7.0
