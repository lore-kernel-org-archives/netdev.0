From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 00/16] New DSA bind, switches as devices
Date: Fri, 27 May 2016 03:20:34 +0200
Message-ID: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52528 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755774AbcE0BX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 21:23:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an RFC patchset and should not be accepted yet.

The interesting patches here are the last three. They implement a new
binding for DSA, which removes a few limitations of the current DSA
binding. In particular, it allows switches to be true Linux devices.
These devices can be on any type of bus, unlike the old DSA binding
which assumes MDIO. See the commit log for more details. The second to
last patch modifies an existing boards device tree to use the new
binding, giving a good example of how switches can be true MDIO
devices. The last patch documents the new binding.

I know both John Crispin and Bryan Whitehead are interesting in
implementing DSA drivers, hence i have CC: you. Comments welcome.

Thanks go to Florian and Vivien for reviewing, testing and bug fixing
these patches.

Andrew Lunn (15):
  dsa: slave: chip data is optional, don't dereference NULL
  dsa: slave: Remove MDIO address from switch MDIO bus name
  dsa: tag_{e}dsa.c: Remove dependency on platform data
  dsa: Add a ports structure and use it in the switch structure
  dsa: Move port device node into port structure
  dsa: Remove dynamic allocate of routing table
  dsa: Copy the routing table into the switch structure
  dsa: dsa: Split up creating/destroying of DSA and CPU ports
  net: dsa: mv88e6xxx: Only support EDSA tagging
  net: dsa: Refactor selection of tag ops into a function
  dsa: Make mdio bus optional
  net: dsa: mv88e6xxx: Refactor MDIO so driver registers mdio bus
  net: dsa: Add new binding implementation
  arm: dt: vf610-zii-devel-b: Make use of new DSA binding
  dsa: Document new binding

Vivien Didelot (1):
  net: dsa: mv88e6xxx: fix circular lock in PPU work

 Documentation/devicetree/bindings/net/dsa/dsa.txt | 278 ++++++++-
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts         | 328 +++++------
 drivers/net/dsa/bcm_sf2.c                         |   4 +-
 drivers/net/dsa/mv88e6xxx.c                       | 264 ++++++---
 drivers/net/dsa/mv88e6xxx.h                       |   6 +
 include/net/dsa.h                                 |  57 +-
 net/dsa/Makefile                                  |   2 +-
 net/dsa/dsa.c                                     | 210 ++++---
 net/dsa/dsa2.c                                    | 653 ++++++++++++++++++++++
 net/dsa/dsa_priv.h                                |   6 +-
 net/dsa/slave.c                                   |  57 +-
 net/dsa/tag_brcm.c                                |   4 +-
 net/dsa/tag_dsa.c                                 |  10 +-
 net/dsa/tag_edsa.c                                |  10 +-
 net/dsa/tag_trailer.c                             |   4 +-
 15 files changed, 1485 insertions(+), 408 deletions(-)
 create mode 100644 net/dsa/dsa2.c

-- 
2.8.1
