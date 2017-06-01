From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: [PATCH 0/5] Add phylib support for MV88X3310 10G phy
Date: Thu, 1 Jun 2017 11:23:27 +0100
Message-ID: <20170601102327.GF27796@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree@vger.kernel.org, Mark Rutland <mark.rutland@arm.com>,
        netdev@vger.kernel.org, Rob Herring <robh+dt@kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:52976 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbdFAKYu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 06:24:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds support for the Marvell 88x3310 PHY found on
the SolidRun Macchiatobin board.

The first patch introduces a set of generic Clause 45 PHY helpers that
C45 PHY drivers can make use of if they wish.

Patch 2 fixes the aneg restart to be compatible with C45 PHYs - it can
currently only cope with C22 PHYs.

Patch 3 moves the "gen10g" driver into the Clause 45 code, grouping all
core clause 45 code together.

Patch 4 adds the phy_interface_t types for XAUI and 10GBase-KR links.
As 10GBase-KR appears to be compatible with XFI and SFI, XFI and SFI,
I currently see no reason to add XFI and SFI interface modes.  There
seems to be vendor code out there using these, but they all alias back
to the same hardware settings.

Patch 5 adds support for the MV88X3310 PHY, which supports both the
copper and fiber interfaces.  It should be noted that the MV88X3310
automatically switches its MAC facing interface between 10GBase-KR
and SGMII depending on the negotiated speed.  This was discussed with
Florian, and we agreed to update the phy interface mode depending on
the properties of the actual link mode to the PHY.

 Documentation/devicetree/bindings/net/ethernet.txt |   2 +
 MAINTAINERS                                        |   6 +
 drivers/net/phy/Makefile                           |   4 +-
 drivers/net/phy/marvell10g.c                       | 364 +++++++++++++++++++++
 drivers/net/phy/phy-c45.c                          | 295 +++++++++++++++++
 drivers/net/phy/phy.c                              |  23 +-
 drivers/net/phy/phy_device.c                       | 113 ++-----
 include/linux/phy.h                                |  20 ++
 8 files changed, 729 insertions(+), 98 deletions(-)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
