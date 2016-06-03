From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 00/17] New DSA bind, switches as devices
Date: Fri,  3 Jun 2016 18:43:59 +0200
Message-ID: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58737 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932822AbcFCQv4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2016 12:51:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Since RFC:

* Split the mv88e6xxx MDIO refactor into a rename patch and a refactor
  patch.
* Extend commit message with comment about wrong of_node_put()
* Fix destroy of cpu and dsa ports.
* Rename _DSA_TAG_LAST to DSA_TAG_LAST and add a comment.

Andrew Lunn (16):
  net: dsa: slave: chip data is optional, don't dereference NULL
  net: dsa: slave: Remove MDIO address from switch MDIO bus name
  net: dsa: tag_{e}dsa.c: Remove dependency on platform data
  net: dsa: Add a ports structure and use it in the switch structure
  net: dsa: Move port device node into port structure
  net: dsa: Remove dynamic allocate of routing table
  net: dsa: Copy the routing table into the switch structure
  net: dsa: Split up creating/destroying of DSA and CPU ports
  net: dsa: mv88e6xxx: Only support EDSA tagging
  net: dsa: Refactor selection of tag ops into a function
  net: dsa: Make mdio bus optional
  net: dsa: mv88e6xxx: Rename _phy_ to _mdio_
  net: dsa: mv88e6xxx: Refactor MDIO so driver registers mdio bus
  net: dsa: Add new binding implementation
  arm: dt: vf610-zii-devel-b: Make use of new DSA binding
  net: dsa: Document new binding

Vivien Didelot (1):
  net: dsa: mv88e6xxx: fix circular lock in PPU work

 Documentation/devicetree/bindings/net/dsa/dsa.txt | 278 ++++++++-
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts         | 328 +++++------
 drivers/net/dsa/bcm_sf2.c                         |   4 +-
 drivers/net/dsa/mv88e6xxx.c                       | 267 ++++++---
 drivers/net/dsa/mv88e6xxx.h                       |   6 +
 include/net/dsa.h                                 |  56 +-
 net/dsa/Makefile                                  |   2 +-
 net/dsa/dsa.c                                     | 210 ++++---
 net/dsa/dsa2.c                                    | 653 ++++++++++++++++++++++
 net/dsa/dsa_priv.h                                |   6 +-
 net/dsa/slave.c                                   |  57 +-
 net/dsa/tag_brcm.c                                |   4 +-
 net/dsa/tag_dsa.c                                 |  10 +-
 net/dsa/tag_edsa.c                                |  10 +-
 net/dsa/tag_trailer.c                             |   4 +-
 15 files changed, 1485 insertions(+), 410 deletions(-)
 create mode 100644 net/dsa/dsa2.c

-- 
2.8.1
