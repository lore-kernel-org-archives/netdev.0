From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 0/2] net: dsa: Move temperature sensor code into PHY.
Date: Fri, 20 Jan 2017 01:37:48 +0100
Message-ID: <1484872670-32585-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38962 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753600AbdATAiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 19:38:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell Ethernet switches contain a temperature sensor. There appears
to be one sensor, which is shared by each of the internal PHYs. Each
PHY has independent registers to read this sensor, and to set a limit
for when an alarm should be raised.

Some Marvell discrete PHY also have the same sensor and registers.
Moving the HWMON code from DSA into the PHY makes the sensor available
in discrete PHYs, and removes the layering violation, the switch
driver poking around in PHY registers.

While moving the code into the PHY driver, it has been re-written to
use the new HWMON APIs.

v2:

Better Cover note explaining one sensor, but multiple independent
registers

Simply error checking.


Andrew Lunn (2):
  phy: marvell: Add support for temperature sensor
  net: dsa: Remove hwmon support

 drivers/net/dsa/mv88e6xxx/chip.c      | 154 -------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  16 --
 drivers/net/phy/marvell.c             | 423 +++++++++++++++++++++++++++++++++-
 include/net/dsa.h                     |   8 -
 net/dsa/Kconfig                       |  11 -
 net/dsa/Makefile                      |   1 -
 net/dsa/dsa.c                         |   4 -
 net/dsa/dsa_priv.h                    |   9 -
 net/dsa/hwmon.c                       | 147 ------------
 9 files changed, 420 insertions(+), 353 deletions(-)
 delete mode 100644 net/dsa/hwmon.c

-- 
2.11.0
