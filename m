From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/5] External MDIO support for mv88e6xxx
Date: Tue, 24 Jan 2017 14:53:46 +0100
Message-ID: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43697 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750708AbdAXN4T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 08:56:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 family of switches has two MDIO busses, one internal to
the switch and a second one for external usage. Older generations of switches
have a single MDIO bus, which is used both internally and externally.

Refactor the existing MDIO driver code to allow for multiple MDIO
busses, and implement the second MDIO bus on mv88e6390.

This is a rewrite of a patch previously submitted as part of "Batch
3". It has been broken up into 5 smaller patches. A compatible string
is now used in the device tree to indicate the external MDIO bus.

Andrew Lunn (5):
  net: dsa: mv88e6xxx: Abstract mv88e6165 PHY operations
  net: dsa: mv88e6xxx: Pass mii_bus to all PHY operations
  net: dsa: mv88e6xxx: Add mdio private structure
  net: dsa: mv88e6xxx: Support multiple MDIO busses
  net: dsa: mv88e6xxx: Implement the 6390 external MDIO bus

 .../devicetree/bindings/net/dsa/marvell.txt        |  41 ++++-
 drivers/net/dsa/mv88e6xxx/chip.c                   | 169 ++++++++++++++++-----
 drivers/net/dsa/mv88e6xxx/global2.c                |  18 ++-
 drivers/net/dsa/mv88e6xxx/global2.h                |  12 +-
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  25 +--
 5 files changed, 206 insertions(+), 59 deletions(-)

-- 
2.11.0
