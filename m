From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 0/3] net: phy: Allow splitting MDIO bus/device support
Date: Thu, 23 Mar 2017 10:01:16 -0700
Message-ID: <20170323170119.4004-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        arnd@arndb.de, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33237 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755850AbdCWRBZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 13:01:25 -0400
Received: by mail-oi0-f65.google.com with SMTP id f193so1604851oib.0
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 10:01:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series allows building support for MDIO bus controllers which
are sometimes usable and necessary in cases where there are no Ethernet PHYs.

Changes in v3:
- corrected of_mdio compile guards for prototypes vs. stubs
- added a missing OF_MDIO dependency for MDIO_BCM_UNIMAC
- fixed Kbuild bot reported errors against mdio-bitbang

Changes in v2:
- implement Russell's feedback
- solve the circular dependency in the CONFIG_MDIO_DEVICE + CONFIG_PHYLIB case


Florian Fainelli (3):
  of_mdio: Correct check against CONFIG_OF
  net: phy: MDIO_BCM_UNIMAC should depend on OF_MDIO
  net: phy: Allow splitting MDIO bus/device support from PHYs

 drivers/net/Makefile             |  2 +-
 drivers/net/phy/Kconfig          | 62 +++++++++++++++++++++++-----------------
 drivers/net/phy/Makefile         | 13 +++++++--
 drivers/net/phy/mdio-boardinfo.c |  1 +
 drivers/net/phy/mdio_bus.c       |  9 ++++++
 include/linux/of_mdio.h          |  4 +--
 include/linux/phy.h              | 21 ++++++++++++--
 7 files changed, 79 insertions(+), 33 deletions(-)

-- 
2.9.3
