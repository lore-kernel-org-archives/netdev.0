From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 0/8] Add irq controller support to Marvell switches
Date: Mon, 14 Mar 2016 01:33:43 +0100
Message-ID: <1457915631-16696-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55962 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933113AbcCNAfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Mar 2016 20:35:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell switches contain one or two interrupt controllers,
depending on switch features. If the switch contains embedded PHYs,
one of these controllers contains the interrupts from these PHYs. In
order that the phylib can make use of these interrupts, they need to
be exported from the driver so a phandle can be used to reference
them. So this patchset make use of the core interrupt infrastructure
to implement one or two interrupt drivers within the switch
driver. The device controller, which contains the PHY interrupts, has
a IRQ domain associated to it, so it can be accessed outside of the
switch driver.

I have a further patch to a dts file to make use of this, but that
board has not yet been accepted into arm-soc.

It would be good if somebody with core IRQ knowledge could review
the second patch. Hi Jason :-)

    Andrew

Andrew Lunn (8):
  net: dsa: Add parsing of an interrupt property
  dsa: mv88e6xxx: Add support for switch and device interrupts
  dsa: mv88e6352: Wire up the mv88e6xxx interrupt code
  dsa: mv88e6171: Wire up the mv88e6xxx interrupt code
  dsa: mv88e6123_61_65: Wire up the mv88e6xxx interrupt code
  dsa: mv88e6131: Wire up the mv88e6xxx interrupt code
  net: dsa: Support phy interrupt property for switch ports.
  net: phy: Use threaded IRQ, to allow IRQ from sleeping devices

 Documentation/devicetree/bindings/net/dsa/dsa.txt |  10 +-
 drivers/net/dsa/mv88e6123_61_65.c                 |   6 +-
 drivers/net/dsa/mv88e6131.c                       |   7 +-
 drivers/net/dsa/mv88e6171.c                       |   6 +-
 drivers/net/dsa/mv88e6352.c                       |   6 +-
 drivers/net/dsa/mv88e6xxx.c                       | 312 ++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h                       |  22 ++
 drivers/net/phy/phy.c                             |   5 +-
 include/net/dsa.h                                 |   6 +
 net/dsa/dsa.c                                     |   8 +
 net/dsa/dsa_priv.h                                |   1 +
 net/dsa/slave.c                                   |  11 +-
 12 files changed, 389 insertions(+), 11 deletions(-)

-- 
2.7.0
