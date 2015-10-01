From: Arun Parameswaran <arunp@broadcom.com>
Subject: [PATCH v2 0/5] Add support for Broadcom's iProc MDIO and Cygnus Ethernet PHY
Date: Wed, 30 Sep 2015 17:16:38 -0700
Message-ID: <1443658603-1848-1-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<bcm-kernel-feedback-list@broadcom.com>,
	Arun Parameswaran <arunp@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:26090 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381AbbJAAQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 20:16:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Changes from v1:
- Updated device tree documentation for the iProc MDIO driver
  based on Florian's feedback.
- Moved the core register defines from the Cygnus PHY driver to
  'include/linux/brcmphy.h' based on Florian's feedback.
- Created a new patch/commit to modify the bcm7xxx phy driver
  to use the new core register defines.
- Modified the Kconfig entry for the Broadcom PHY library to
  'tristate' instead of 'bool'

Arun Parameswaran (5):
  dt-bindings: net: Broadcom iProc MDIO bus driver device tree binding
  net: phy: Broadcom iProc MDIO bus driver
  net: phy: Add Broadcom phy library for common interfaces
  net: phy: Broadcom Cygnus internal Etherent PHY driver
  net: phy: bcm7xxx: Modified to use global core register defines

 .../devicetree/bindings/net/brcm,iproc-mdio.txt    |  23 +++
 drivers/net/phy/Kconfig                            |  28 +++
 drivers/net/phy/Makefile                           |   3 +
 drivers/net/phy/bcm-cygnus.c                       | 158 +++++++++++++++
 drivers/net/phy/bcm-phy-lib.c                      | 209 ++++++++++++++++++++
 drivers/net/phy/bcm-phy-lib.h                      |  37 ++++
 drivers/net/phy/bcm63xx.c                          |  38 +---
 drivers/net/phy/bcm7xxx.c                          | 136 +++----------
 drivers/net/phy/broadcom.c                         | 149 +++++---------
 drivers/net/phy/mdio-bcm-iproc.c                   | 213 +++++++++++++++++++++
 include/linux/brcmphy.h                            |  29 +--
 11 files changed, 761 insertions(+), 262 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt
 create mode 100644 drivers/net/phy/bcm-cygnus.c
 create mode 100644 drivers/net/phy/bcm-phy-lib.c
 create mode 100644 drivers/net/phy/bcm-phy-lib.h
 create mode 100644 drivers/net/phy/mdio-bcm-iproc.c

-- 
2.5.2
