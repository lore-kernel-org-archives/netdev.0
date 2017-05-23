From: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Subject: [PATCH 0/2] net: phy: Support managed Cortina phys
Date: Tue, 23 May 2017 15:53:17 +0000
Message-ID: <1495554799-23060-1-git-send-email-bogdan.purcareata@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So far, the Cortina family phys (CS4340 in this particular case) are only
supported in fixed link mode (via fixed_phy_register). The generic 10G
phy driver does not work well with the phylib state machine, when the phy
is registered via of_phy_connect. This prohibits the user from describing the
phy nodes in the device tree.

In order to support this scenario, and to properly describe the board
device tree, add a minimal Cortina driver that reads the status from the
right register. With the generic 10G C45 driver, the kernel will print
messages like:
[    0.226521] mdio_bus 8b96000: Error while reading PHY16 reg at 1.6
[    0.232780] mdio_bus 8b96000: Error while reading PHY16 reg at 1.5

Bogdan Purcareata (2):
  net: phy: Update get_phy_c45_ids for Cortina PHYs
  drivers: phy: Add Cortina CS4340 driver

 drivers/net/phy/Kconfig        |  5 +++
 drivers/net/phy/Makefile       |  1 +
 drivers/net/phy/mdio-cortina.c | 90 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/phy_device.c   | 10 +++--
 4 files changed, 102 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/phy/mdio-cortina.c

-- 
1.9.1
