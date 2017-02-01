From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 0/2] Work around missing PHY prodcut ID in mv88e6390
Date: Wed,  1 Feb 2017 03:40:04 +0100
Message-ID: <1485916806-27299-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51915 "EHLO vps0.lunn.ch"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1750784AbdBACla (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 21:41:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The internal PHYs of the MV88E6390 have a Marvell OUI, but the product
ID is zero. Work around this by trapping reads to the ID, and if it is
zero, return the MV88E6390 family ID.

v2: Move the workaround into the central mdio read function.
    Enable the temperature sensor, even though it does not work on the 6390,
    but it does on the 6341, which has the same ID problem.

Andrew Lunn (2):
  net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
  net: phy: Marvell: Add mv88e6390 internal PHY

 drivers/net/dsa/mv88e6xxx/chip.c |  8 ++++++++
 drivers/net/phy/marvell.c        | 20 ++++++++++++++++++++
 include/linux/marvell_phy.h      |  6 ++++++
 3 files changed, 34 insertions(+)

-- 
2.11.0
