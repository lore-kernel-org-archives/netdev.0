From: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: [PATCH v2 0/6] Add phylib support for MV88X3310 10G phy
Date: Mon, 5 Jun 2017 12:22:03 +0100
Message-ID: <20170605112203.GA10680@n2100.armlinux.org.uk>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170601102327.GF27796-l+eeeJia6m9URfEZ8mYm6t73F7V6hmMc@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This patch series adds support for the Marvell 88x3310 PHY found on
the SolidRun Macchiatobin board.

The first patch introduces a set of generic Clause 45 PHY helpers that
C45 PHY drivers can make use of if they wish.

Patch 2 ensures that the Clause 22 aneg_done function will not be
called for incompatible Clause 45 PHYs.

Patch 3 fixes the aneg restart to be compatible with C45 PHYs - it can
currently only cope with C22 PHYs.

Patch 4 moves the "gen10g" driver into the Clause 45 code, grouping all
core clause 45 code together.

Patch 5 adds the phy_interface_t types for XAUI and 10GBase-KR links.
As 10GBase-KR appears to be compatible with XFI and SFI, XFI and SFI,
I currently see no reason to add XFI and SFI interface modes.  There
seems to be vendor code out there using these, but they all alias back
to the same hardware settings.

Patch 6 adds support for the MV88X3310 PHY, which supports both the
copper and fiber interfaces.  It should be noted that the MV88X3310
automatically switches its MAC facing interface between 10GBase-KR
and SGMII depending on the negotiated speed.  This was discussed with
Florian, and we agreed to update the phy interface mode depending on
the properties of the actual link mode to the PHY.

v2:
- update sysfs-class-net-phydev documentation
- avoid genphy_aneg_done for non-C22 PHYs
- expand comment about 0x30 constant
- add comment about lack of reset
- configure driver using MARVELL_10G_PHY

 Documentation/ABI/testing/sysfs-class-net-phydev   |   2 +-
 Documentation/devicetree/bindings/net/ethernet.txt |   2 +
 MAINTAINERS                                        |   6 +
 drivers/net/phy/Kconfig                            |   5 +
 drivers/net/phy/Makefile                           |   3 +-
 drivers/net/phy/marvell10g.c                       | 368 +++++++++++++++++++++
 drivers/net/phy/phy-c45.c                          | 298 +++++++++++++++++
 drivers/net/phy/phy.c                              |  29 +-
 drivers/net/phy/phy_device.c                       | 113 ++-----
 include/linux/phy.h                                |  20 ++
 10 files changed, 748 insertions(+), 98 deletions(-)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
