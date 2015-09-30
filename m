From: Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 0/4] Add support for Broadcom's iProc MDIO and Cygnus Ethernet PHY
Date: Wed, 30 Sep 2015 13:32:39 -0700
Message-ID: <1443645163-2822-1-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi
This patchset adds support for the iProc MDIO interface and the
Broadcom Cygnus SoC's internal Ethernet PHY.

The internal Ethernet PHY(s) in the Cygnus SoC's are accessed
via the MDIO interface found in most of the iProc based chips.

The patch also consolidates the common API's used by the
Broadcom phys to a common library. Existing Broadcom phy
drivers have been modified to use the common library API's.

The Ethernet driver for the iProc family will be submitted soon,
as will the device tree configurations for the different iProc
family SoCs.

Arun Parameswaran (4):
  dt-bindings: net: Broadcom iProc MDIO bus driver device tree binding
  net: phy: Broadcom iProc MDIO bus driver
  net: phy: Add Broadcom phy library for common interfaces
  net: phy: Broadcom Cygnus internal Etherent PHY driver

 .../devicetree/bindings/net/brcm,iproc-mdio.txt    |  23 +++
 drivers/net/phy/Kconfig                            |  28 +++
 drivers/net/phy/Makefile                           |   3 +
 drivers/net/phy/bcm-cygnus.c                       | 162 ++++++++++++++++
 drivers/net/phy/bcm-phy-lib.c                      | 209 ++++++++++++++++++++
 drivers/net/phy/bcm-phy-lib.h                      |  37 ++++
 drivers/net/phy/bcm63xx.c                          |  38 +---
 drivers/net/phy/bcm7xxx.c                          | 127 +++---------
 drivers/net/phy/broadcom.c                         | 149 +++++---------
 drivers/net/phy/mdio-bcm-iproc.c                   | 213 +++++++++++++++++++++
 include/linux/brcmphy.h                            |  24 +--
 11 files changed, 757 insertions(+), 256 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt
 create mode 100644 drivers/net/phy/bcm-cygnus.c
 create mode 100644 drivers/net/phy/bcm-phy-lib.c
 create mode 100644 drivers/net/phy/bcm-phy-lib.h
 create mode 100644 drivers/net/phy/mdio-bcm-iproc.c

-- 
2.5.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
