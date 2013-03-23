From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCHv2 0/5] ARM: sunxi: Add support for A10 Ethernet controller
Date: Sat, 23 Mar 2013 23:30:09 +0100
Message-ID: <1364077814-2233-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com, netdev@vger.kernel.org,
	Stefan Roese <sr@denx.de>, Alejandro Mery <amery@geeks.cl>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:42280 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab3CWWaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 18:30:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The Allwinner A10 SoC has an ethernet controller that seem to be specific to
Allwinner. This IP has no public documentation, so exact
details are quite sparse, and this code come from refactored Allwinner
code.

Since we don't have any clock support yet for the Allwinner SoCs, we
rely on the bootloader to enable and gate the EMAC clock.

Thanks,
Maxime

Changes from v1:
  - Use phylib for the phy-related functions
  - Use an optional regulator to power up the phy
  - Rename the driver from Davicom Wemac to Allwinner EMAC, since it's the name
    mentionned in the datasheet, and we have no strong evidence of a
    relationship with Davicom
  - Fix various small things around the driver: add defines for undocumented
    values, fix documentation name and compatible example, etc.

Maxime Ripard (3):
  ARM: sunxi: Add EMAC controller node to sun4i DTSI
  ARM: sun4i: Add muxing options for the ethernet controller
  ARM: hackberry: dt: Add Ethernet controller to the Hackberry device
    tree

Stefan Roese (2):
  net: Add EMAC ethernet driver found on Allwinner A10 SoC's
  ARM: cubieboard: Enable ethernet (WEMAC) support in dts

 .../bindings/net/allwinner,sun4i-emac.txt          |   19 +
 arch/arm/boot/dts/sun4i-a10-cubieboard.dts         |    6 +
 arch/arm/boot/dts/sun4i-a10-hackberry.dts          |   32 +
 arch/arm/boot/dts/sun4i-a10.dtsi                   |   18 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/allwinner/Kconfig             |   36 +
 drivers/net/ethernet/allwinner/Makefile            |    5 +
 drivers/net/ethernet/allwinner/sun4i-emac.c        | 1033 ++++++++++++++++++++
 drivers/net/ethernet/allwinner/sun4i-emac.h        |  114 +++
 10 files changed, 1265 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
 create mode 100644 drivers/net/ethernet/allwinner/Kconfig
 create mode 100644 drivers/net/ethernet/allwinner/Makefile
 create mode 100644 drivers/net/ethernet/allwinner/sun4i-emac.c
 create mode 100644 drivers/net/ethernet/allwinner/sun4i-emac.h

-- 
1.7.10.4
