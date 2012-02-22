From: Heiko Schocher <hs@denx.de>
Subject: [PATCH v2 0/7] ARM: davinci: add support for the am1808 based enbw_cmc board
Date: Wed, 22 Feb 2012 07:50:03 +0100
Message-ID: <1329893410-24413-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs@denx.de>, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org, linux-mtd@lists.infradead.org,
	linux-i2c@vger.kernel.org, netdev@vger.kernel.org,
	David Woodhouse <dwmw2@infradead.org>,
	Ben Dooks <ben-linux@fluff.org>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Sekhar Nori <nsekhar@ti.com>, Kevin Hilman <khilman@ti.com>,
	Wolfgang Denk <wd@denx.de>
To: davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:54917 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab2BVGuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 01:50:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchserie adds support for the davinci am1808 based
enbw_cmc board.

Post this patchserie now as v2, as reworked in the
comments I got for the RFC serie.

Important: I rebased this patchserie against the irqdomain/next
branch from grant likely, as he suggested to rework the OF
intcontroller changes to the irqdomain work, branch found here:

http://git.secretlab.ca/?p=linux-2.6.git;a=shortlog;h=refs/heads/irqdomain/next

commit 2462bacd0334d918f9fcd79fc59c403b76b36f8a
Author: Grant Likely <grant.likely@secretlab.ca>
Date:   Thu Jan 26 14:10:13 2012 -0700

    irq_domain/microblaze: Convert microblaze to use irq_domains

Got no comments to the following points, I noted in the
RFC series, so posting this patchseries with them:

- ARM: davinci: configure davinci aemif chipselects through OF
  not moved to mfd, as mentioned in this discussion:
  http://davinci-linux-open-source.1494791.n2.nabble.com/PATCH-arm-davinci-configure-davinci-aemif-chipselects-through-OF-td7059739.html
  instead use a phandle in the DTS, so drivers which
  uses the davinci aemif, can call davinci_aemif_setup_timing_of()

  This is just thought as an RFC ... The enbw_cmc board
  support not really need to setup this bus timings, as
  they are setup in U-Boot ... but I want to post this,
  as I think, it is a nice to have, and I am not really
  sure, if this has to be a MFD device (If so, all bus
  interfaces for other SoCs should be converted also to
  MFD devices) ... as an example how this can be used
  I add this to the davinci nand controller OF support
  patch, in this patchserie.

- ARM: davinci: mux: add OF support
  I want to get rid of the pin setup code in board code ...
  This patch introduces a davinci_cfg_reg_of() function,
  which davinci drivers can call, if they found a
  "pinmux-handle", so used in the following drivers in
  this patchserie:

  drivers/net/ethernet/ti/davinci_emac
  drivers/i2c/busses/i2c-davinci.c
  drivers/mtd/nand/davinci_nand.c

- post this board support with USB support, even though
  USB is only working with the 10 ms "workaround", posted here:
  http://comments.gmane.org/gmane.linux.usb.general/54505
  I see this issue also on the AM1808 TMDXEXP1808L evalboard.

- MMC and USB are not using OF support yet, ideas how to port
  this are welcome. I need for USB and MMC board specific
  callbacks, how to solve this with OF support?

Signed-off-by: Heiko Schocher <hs@denx.de>
Cc: linux-arm-kernel@lists.infradead.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: davinci-linux-open-source@linux.davincidsp.com
Cc: linux-mtd@lists.infradead.org
Cc: linux-i2c@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Ben Dooks <ben-linux@fluff.org>
Cc: Wolfram Sang <w.sang@pengutronix.de>
Cc: Sekhar Nori <nsekhar@ti.com>
Cc: Kevin Hilman <khilman@ti.com>
Cc: Wolfgang Denk <wd@denx.de>

Heiko Schocher (7):
  ARM: davinci, intc: Add OF support for TI interrupt controller
  ARM: davinci: configure davinci aemif chipselects through OF
  ARM: davinci: mux: add OF support
  ARM: davinci: net: davinci_emac: add OF support
  ARM: davinci: i2c: add OF support
  ARM: mtd: nand: davinci: add OF support for davinci nand controller
  ARM: davinci: add support for the am1808 based enbw_cmc board

 .../devicetree/bindings/arm/davinci/aemif.txt      |  119 ++++++
 .../bindings/arm/davinci/davinci_emac.txt          |   43 +++
 .../devicetree/bindings/arm/davinci/i2c.txt        |   33 ++
 .../devicetree/bindings/arm/davinci/intc.txt       |   26 ++
 .../devicetree/bindings/arm/davinci/mux.txt        |   40 ++
 .../devicetree/bindings/arm/davinci/nand.txt       |   74 ++++
 arch/arm/boot/dts/enbw_cmc.dts                     |  268 ++++++++++++++
 arch/arm/configs/enbw_cmc_defconfig                |  123 +++++++
 arch/arm/mach-davinci/Kconfig                      |    9 +
 arch/arm/mach-davinci/Makefile                     |    1 +
 arch/arm/mach-davinci/aemif.c                      |   86 +++++-
 arch/arm/mach-davinci/board-enbw-cmc.c             |  380 ++++++++++++++++++++
 arch/arm/mach-davinci/cp_intc.c                    |  133 +++++++
 arch/arm/mach-davinci/include/mach/aemif.h         |    1 +
 arch/arm/mach-davinci/include/mach/cp_intc.h       |    1 +
 arch/arm/mach-davinci/include/mach/mux.h           |    2 +
 arch/arm/mach-davinci/include/mach/uncompress.h    |    1 +
 arch/arm/mach-davinci/mux.c                        |   73 ++++-
 drivers/i2c/busses/i2c-davinci.c                   |   37 ++
 drivers/mtd/nand/davinci_nand.c                    |   85 +++++-
 drivers/net/ethernet/ti/davinci_emac.c             |   94 +++++-
 21 files changed, 1625 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/aemif.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/i2c.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/intc.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/mux.txt
 create mode 100644 Documentation/devicetree/bindings/arm/davinci/nand.txt
 create mode 100644 arch/arm/boot/dts/enbw_cmc.dts
 create mode 100644 arch/arm/configs/enbw_cmc_defconfig
 create mode 100644 arch/arm/mach-davinci/board-enbw-cmc.c

-- 
1.7.7.6
