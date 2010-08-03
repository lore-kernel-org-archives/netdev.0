From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 0/8] split out emac cpdma and mdio for reuse
Date: Tue,  3 Aug 2010 09:31:45 -0400
Message-ID: <1280842313-3743-1-git-send-email-cyril@ti.com>
Cc: nsekhar@ti.com, srk@ti.com, Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
      netdev: switch davinci emac to new mdio driver
  - Cleanup left over cruft
      davinci: cleanup unused davinci mdio arch code
      netdev: cleanup unused davinci mdio emac code

CPDMA:
  - Add new functionality
     netdev: separate out davinci cpdma controller code
  - Hookup new functionality
     netdev: switch davinci emac to new cpdma layer
  - Cleanup left over cruft
     netdev: cleanup unused davinci emac cpdma code

This series has been tested on dm365 and tnetv107x (with additional cpsw
patches) hardware.  Additional omap tree patches will be required for am35xx
as well (not included here).


Cyril Chemparathy (8):
  netdev: separate out davinci mdio controller code
  davinci: add mdio platform devices
  netdev: switch davinci emac to new mdio driver
  davinci: cleanup unused davinci mdio arch code
  netdev: cleanup unused davinci mdio emac code
  netdev: separate out davinci cpdma controller code
  netdev: switch davinci emac to new cpdma layer
  netdev: cleanup unused davinci emac cpdma code

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
 arch/arm/mach-davinci/dm646x.c              |   23 +-
 arch/arm/mach-davinci/include/mach/dm365.h  |    2 +-
 arch/arm/mach-davinci/include/mach/dm644x.h |    2 +-
 arch/arm/mach-davinci/include/mach/dm646x.h |    2 +-
 drivers/net/Kconfig                         |   21 +
 drivers/net/Makefile                        |    2 +
 drivers/net/davinci_cpdma.c                 |  836 +++++++++++++++++
 drivers/net/davinci_cpdma.h                 |  105 +++
 drivers/net/davinci_emac.c                  | 1335 ++++-----------------------
 drivers/net/davinci_mdio.c                  |  386 ++++++++
 include/linux/davinci_emac.h                |    8 +-
 21 files changed, 1615 insertions(+), 1231 deletions(-)
 create mode 100644 drivers/net/davinci_cpdma.c
 create mode 100644 drivers/net/davinci_cpdma.h
 create mode 100644 drivers/net/davinci_mdio.c

