From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/9] DSA port configuration and status
Date: Sun, 23 Aug 2015 11:46:51 +0200
Message-ID: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38095 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752236AbbHWJzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2015 05:55:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset allows various switch port settings to be configured and
port status to be sampled. Some of these patches have been posted
before.

The first three patches provide infrastructure for configuring a
switch ports link speed and duplex from a fixed_link phy.

Patch four then uses this infrastructure to allow the CPU and DSA
ports of a switch to be configured using a fixed-link property in the
device tree.

Patches five and six allow a phy-mode property to be specified in the
device tree, and allow this to be used for configuring RGMII delays.

Patches seven through nine allow link status, for example that of an
SFP module, to be read from a gpio.

Please don't merge these patches until Florian Fainelli has reviewed
them.

Andrew Lunn (8):
  dsa: mv88e6xxx: Allow speed/duplex of port to be configured
  phy: fixed_phy: Set supported speed in phydev
  net: dsa: Allow configuration of CPU & DSA port speeds/duplex
  net: dsa: Allow DSA and CPU ports to have a phy-mode property
  dsa: mv88e6xxx: Set the RGMII delay based on phy interface
  dsa: mv88e6xxx: Don't poll forced interfaces for state changes
  phy: fixed_phy: Add gpio to determine link up/down.
  phy: fixed_phy: Set phy capabilities even when link is down

Florian Fainelli (1):
  net: phy: Allow PHY devices to identify themselves as Ethernet
    switches, etc.

 .../devicetree/bindings/net/fixed-link.txt         | 14 ++++-
 Documentation/networking/stmmac.txt                |  2 +-
 arch/m68k/coldfire/m5272.c                         |  2 +-
 arch/mips/ar7/platform.c                           |  5 +-
 arch/mips/bcm47xx/setup.c                          |  2 +-
 drivers/net/dsa/mv88e6123_61_65.c                  |  1 +
 drivers/net/dsa/mv88e6131.c                        |  1 +
 drivers/net/dsa/mv88e6171.c                        |  1 +
 drivers/net/dsa/mv88e6352.c                        |  1 +
 drivers/net/dsa/mv88e6xxx.c                        | 73 ++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h                        |  4 ++
 drivers/net/ethernet/broadcom/genet/bcmmii.c       |  2 +-
 drivers/net/phy/fixed_phy.c                        | 45 ++++++++++---
 drivers/of/of_mdio.c                               | 13 +++-
 include/linux/phy.h                                | 12 ++++
 include/linux/phy_fixed.h                          |  8 ++-
 net/dsa/dsa.c                                      | 43 +++++++++++++
 17 files changed, 210 insertions(+), 19 deletions(-)

-- 
2.5.0
