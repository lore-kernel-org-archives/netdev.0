From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: [PATCH 0/3] net: phy: prevent linking breakage
Date: Mon, 27 May 2013 18:18:41 +0200
Message-ID: <1369671524-14797-1-git-send-email-alexandre.belloni@free-electrons.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Russell King <linux@arm.linux.org.uk>,
	Shawn Guo <shawn.guo@linaro.org>,
	Sascha Hauer <kernel@pengutronix.de>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a linking issue when using phy_register_fixup{,_for_uid,_for_id} and
CONFIG_PHYLIB is not a builtin:

arch/arm/mach-at91/built-in.o: In function `ksz9021rn_phy_fixup':
:(.text+0x1174): undefined reference to `mdiobus_write'
:(.text+0x1188): undefined reference to `mdiobus_write'
:(.text+0x119c): undefined reference to `mdiobus_write'
:(.text+0x11b0): undefined reference to `mdiobus_write'
arch/arm/mach-at91/built-in.o: In function `sama5_dt_device_init':
:(.init.text+0x1e34): undefined reference to `phy_register_fixup_for_uid'

This has been solved for arch/arm/mach-mxs/ and arch/arm/mach-imx/ by testing
IS_BUILTIN(CONFIG_PHYLIB) before calling the functions.

The first patch is an attempt at solving that issue globally.

The following patches remove the unnecessary IS_BUILTIN(CONFIG_PHYLIB) checks.

Quickly greping into the code shows that the issue may arise in:

arch/powerpc/platforms/85xx/mpc85xx_mds.c
arch/arm/mach-davinci/board-dm644x-evm.c
arch/arm/mach-orion5x/dns323-setup.c
arch/arm/mach-at91/board-dt-sama5.c

Alexandre Belloni (3):
  net: phy: prevent linking breakage
  arm: mxs: don't check for CONFIG_PHYLIB as builtin
  arm: imx: don't check for CONFIG_PHYLIB as builtin

 arch/arm/mach-imx/mach-imx6q.c | 23 ++++++++++-------------
 arch/arm/mach-mxs/mach-mxs.c   |  5 ++---
 drivers/net/phy/phy_device.c   |  6 ++++++
 include/linux/phy.h            | 12 ++++++++++++
 4 files changed, 30 insertions(+), 16 deletions(-)

-- 
1.8.1.2
