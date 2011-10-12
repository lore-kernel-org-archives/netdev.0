From: David Daney <david.daney@cavium.com>
Subject: [PATCH 0/3] netdev/phy/of: Improve 10G Ethernet PHY support.
Date: Wed, 12 Oct 2011 11:06:20 -0700
Message-ID: <1318442783-29058-1-git-send-email-david.daney@cavium.com>
Cc: afleming@gmail.com, David Daney <david.daney@cavium.com>
To: devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PHY driver core needs a couple of adjustments to be able to
support 10G PHYs.  The main issue being that they use a different MDIO
bus protocol (IEEE802.3 clause 45).

The changes are not large:

1) The addr argument to get_phy_id() and get_phy_device() can be
   flagged to indicate clause 45 addressing.

2) The device tree helper of_mdiobus_register() uses a new
   "compatible" value to hook up the 10G phys.

3) A driver for the BCM8706 which makes use of it all.

David Daney (3):
  netdev/phy: Handle IEEE802.3 clause 45 Ethernet PHYs
  netdev/phy/of: Handle IEEE802.3 clause 45 Ethernet PHYs in
    of_mdiobus_register()
  netdev/phy: Add driver for Broadcom BCM8706 10G Ethernet PHY

 .../devicetree/bindings/net/broadcom-bcm8706.txt   |   28 +++
 Documentation/devicetree/bindings/net/phy.txt      |   12 +-
 drivers/net/phy/Kconfig                            |    5 +
 drivers/net/phy/Makefile                           |    1 +
 drivers/net/phy/bcm8706.c                          |  212 ++++++++++++++++++++
 drivers/net/phy/phy_device.c                       |   25 ++-
 drivers/of/of_mdio.c                               |    4 +
 include/linux/brcmphy.h                            |    1 +
 include/linux/phy.h                                |    3 +
 9 files changed, 287 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-bcm8706.txt
 create mode 100644 drivers/net/phy/bcm8706.c

-- 
1.7.2.3
