From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH v2 0/3] net/phy: Improvements to Cavium Thunder MDIO code.
Date: Fri, 11 Mar 2016 09:53:08 -0800
Message-ID: <1457718791-6505-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	David Daney <david.daney@cavium.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Robert Richter <rric@kernel.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	Kumar Gala <galak@codeaurora.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

Changes from v1:

 - In 1/3 Add back check for non-OF objects in bgx_init_of_phy().  It
   is probably not necessary, but better safe than sorry...

The firmware on many Cavium Thunder systems configures the MDIO bus
hardware to be probed as a PCI device.  In order to use the MDIO bus
drivers in this configuration, we must add PCI probing to the driver.

There are two parts to this set of three patches:

 1) Cleanup the PHY probing code in thunder_bgx.c to handle the case
    where there is no PHY attached to a port, as well as being more
    robust in the face of driver loading order by use of
    -EPROBE_DEFER.

 2) Split mdio-octeon.c into two drivers, one with platform probing,
 and the other with PCI probing.  Common code is shared between the
 two.

Tested on several different Thunder and OCTEON systems, also compile
tested on x86_64.

David Daney (3):
  net: thunderx: Cleanup PHY probing code.
  phy: mdio-octeon: Refactor into two files/modules
  phy: mdio-thunder:  Add driver for Cavium Thunder SoC MDIO buses.

 .../devicetree/bindings/net/cavium-mdio.txt        |  61 ++++-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |  29 ++-
 drivers/net/phy/Kconfig                            |  22 +-
 drivers/net/phy/Makefile                           |   2 +
 drivers/net/phy/mdio-cavium.c                      | 149 +++++++++++
 drivers/net/phy/mdio-cavium.h                      | 119 +++++++++
 drivers/net/phy/mdio-octeon.c                      | 280 ++-------------------
 drivers/net/phy/mdio-thunder.c                     | 154 ++++++++++++
 8 files changed, 535 insertions(+), 281 deletions(-)
 create mode 100644 drivers/net/phy/mdio-cavium.c
 create mode 100644 drivers/net/phy/mdio-cavium.h
 create mode 100644 drivers/net/phy/mdio-thunder.c

-- 
1.7.11.7
