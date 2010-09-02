From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH v2 00/10] split out emac cpdma and mdio for reuse
Date: Thu,  2 Sep 2010 18:03:18 -0400
Message-ID: <1283465008-18606-1-git-send-email-cyril@ti.com>
Cc: davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org, nsekhar@ti.com, srk@ti.com,
	omar.ramirez@ti.com, bparrot@ti.com,
	Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:33940 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752759Ab0IBWDh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Sep 2010 18:03:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Davinci's EMAC device has an in-built MDIO controller and a CPDMA engine.
These hardware modules are not restricted to EMAC device alone.  For example,
CPSW3G (3-port gigabit ethernet switch) hardware uses these very same modules
internally.  This patch series separates out EMAC's MDIO and CPDMA
functionality, allowing these individual pieces to be reused across TI
hardware.  

This patch series has been broadly organized as follows:

MDIO:
  - Add new functionality
      netdev: separate out davinci mdio controller code
  - Hookup new functionality
      davinci: add mdio platform devices
      omap: add mdio platform devices
      netdev: switch davinci emac to new mdio driver
  - Cleanup left over cruft
      davinci: cleanup unused davinci mdio arch code
      omap: cleanup unused davinci mdio arch code
      netdev: cleanup unused davinci mdio emac code

CPDMA:
  - Add new functionality
     netdev: separate out davinci cpdma controller code
  - Hookup new functionality
     netdev: switch davinci emac to new cpdma layer
  - Cleanup left over cruft
     netdev: cleanup unused davinci emac cpdma code

This series has been tested on dm365 and tnetv107x (with additional cpsw
patches) hardware.  Although am3517 (omap) board support code has been updated
as needed, emac does not work on this platform.

Changes from v1:
  1. Fixed memory leak in cpdma_chan_create() failure case
  2. Included new omap patches for am3517, avoids build breakage

Cyril Chemparathy (8):
  netdev: separate out davinci mdio controller code
  davinci: add mdio platform devices
  omap: add mdio platform devices
  net: davinci_emac: switch to new mdio
  davinci: cleanup unused davinci mdio arch code
  omap: cleanup unused davinci mdio arch code
  net: davinci_emac: cleanup unused mdio emac code
  net: davinci_emac: separate out cpdma code
  net: davinci_emac: switch to new cpdma layer
  net: davinci_emac: cleanup unused cpdma code

 arch/arm/mach-davinci/board-da830-evm.c     |    5 -
 arch/arm/mach-davinci/board-da850-evm.c     |    6 -
 arch/arm/mach-davinci/board-dm365-evm.c     |    7 -
 arch/arm/mach-davinci/board-dm644x-evm.c    |    7 -
 arch/arm/mach-davinci/board-dm646x-evm.c    |    8 -
 arch/arm/mach-davinci/board-neuros-osd2.c   |    7 -
 arch/arm/mach-davinci/board-sffsdr.c        |    7 -
 arch/arm/mach-davinci/devices-da8xx.c       |   31 +-
 arch/arm/mach-davinci/dm365.c               |   23 +-
 arch/arm/mach-davinci/dm644x.c              |   23 +-
 arch/arm/mach-davinci/dm646x.c              |   22 +-
 arch/arm/mach-davinci/include/mach/dm365.h  |    2 +-
 arch/arm/mach-davinci/include/mach/dm644x.h |    2 +-
 arch/arm/mach-davinci/include/mach/dm646x.h |    2 +-
 arch/arm/mach-omap2/board-am3517evm.c       |   31 +-
 drivers/net/Kconfig                         |   21 +
 drivers/net/Makefile                        |    2 +
 drivers/net/davinci_cpdma.c                 |  837 +++++++++++++++++
 drivers/net/davinci_cpdma.h                 |  105 +++
 drivers/net/davinci_emac.c                  | 1325 ++++-----------------------
 drivers/net/davinci_mdio.c                  |  386 ++++++++
 include/linux/davinci_emac.h                |    8 +-
 22 files changed, 1635 insertions(+), 1232 deletions(-)
 create mode 100644 drivers/net/davinci_cpdma.c
 create mode 100644 drivers/net/davinci_cpdma.h
 create mode 100644 drivers/net/davinci_mdio.c

