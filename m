From: Andrew Lunn <andrew@lunn.ch>
Subject: [net-next 0/8] More MV88E6390 patches
Date: Sat, 21 Jan 2017 00:30:54 +0100
Message-ID: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40333 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752474AbdATXcg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 18:32:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the ongoing work to add support for the Marvell 9390 family of
switches. There are now two MDIO busses, one for the internal PHYs and
an external bus for external PHYs. Add support for this external bus.

This switch supports 2Gbps, 2.5Gbps and 10Gbps ports. Add phy-modes
for these speeds/interfaces. These modes are then used to configure
ports 9 and 10, which support these speeds.

The internal PHYs oddly use a Marvell Vendor ID, but have empty
product ID. Trap reads of the product ID, and if it returns 0,
instead return the switch family ID. The Marvell PHY driver is then
extended to support this ID, treating the PHY as compatible with the
1540.

Both the internal and external MDIO busses are capable of clause 45
addressing, and is required to accessing the SERDES
interfaces. Implement support for clause 45.

And two fixes are included. There is no need to port these to stable,
the current support for the 6390 is not sufficient to be usable.

Andrew Lunn (8):
  net: dsa: mv88e6xxx: Implement external MDIO bus on mv88e6390
  net: phy: Add 2000base-x, 2500base-x and rxaui modes
  net: dsa: mv88e6xxx: Fix ATU age timer for MV88E6390
  net: dsa: mv88e6xxx: Set the CMODE for mv88e6390 ports 9 & 10
  net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
  net: phy: Marvell: Add mv88e6390 internal PHY
  net: dsa: mv88e6xxx: Implement Clause 45 access to SMI devices
  net: dsa: mv88e6xxx: Fix typ0 when configuring 2.5Gbps

 .../devicetree/bindings/net/dsa/marvell.txt        |   4 +
 Documentation/devicetree/bindings/net/ethernet.txt |   3 +
 drivers/net/dsa/mv88e6xxx/chip.c                   | 168 ++++++++++++++++-----
 drivers/net/dsa/mv88e6xxx/global2.c                | 130 +++++++++++++++-
 drivers/net/dsa/mv88e6xxx/global2.h                |   4 +-
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  55 +++++--
 drivers/net/dsa/mv88e6xxx/port.c                   |  66 +++++++-
 drivers/net/dsa/mv88e6xxx/port.h                   |   3 +
 drivers/net/phy/marvell.c                          |  20 +++
 include/linux/marvell_phy.h                        |   6 +
 include/linux/phy.h                                |   9 ++
 11 files changed, 409 insertions(+), 59 deletions(-)

-- 
2.11.0
