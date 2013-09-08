From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [RFC PATCH 0/4] cpsw: support for control module register
Date: Sun, 8 Sep 2013 16:53:54 +0530
Message-ID: <1378639438-27686-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <zonque@gmail.com>, <davem@davemloft.net>, <bcousson@baylibre.com>,
	<tony@atomide.com>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:47207 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440Ab3IHLYT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Sep 2013 07:24:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds the support for configuring GMII_SEL register
of control module to select the phy mode type and also to configure
the clock source for RMII phy mode whether to use internal clock or
the external clock from the phy itself.

Till now CPSW works as this configuration is done in U-Boot and carried
over to the kernel. But during suspend/resume Control module tends to
lose its configured value for GMII_SEL register in AM33xx PG1.0, so
if CPSW is used in RMII or RGMII mode, on resume cpsw is not working
as GMII_SEL register lost its configuration values.

The initial version of the patch is done by Daniel Mack but as per
Tony's comment he wants it as a seperate driver as it is done in USB
control module. I have created a seperate driver for the same and as
the merge window is open now and no feature request is accepted I am
submitting it as RFC for reviews.

Daniel Mack (1):
  net: ethernet: cpsw: switch to devres allocations

Mugunthan V N (3):
  drivers: net: cpsw-phy-sel: Add new driver for phy mode selection for
    cpsw
  drivers: net: cpsw: use cpsw-phy-sel driver to configure phy mode
  ARM: dts: am33xx: adopt to cpsw-phy-sel driver to configure phy mode

 .../devicetree/bindings/net/cpsw-phy-sel.txt       |  28 ++++
 arch/arm/boot/dts/am33xx.dtsi                      |   6 +
 drivers/net/ethernet/ti/Kconfig                    |   8 +
 drivers/net/ethernet/ti/Makefile                   |   1 +
 drivers/net/ethernet/ti/cpsw-phy-sel.c             | 161 +++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw.c                     | 157 ++++++--------------
 drivers/net/ethernet/ti/cpsw.h                     |   2 +
 7 files changed, 253 insertions(+), 110 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/cpsw-phy-sel.txt
 create mode 100644 drivers/net/ethernet/ti/cpsw-phy-sel.c

-- 
1.8.4
