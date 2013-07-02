From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v6 0/7] ARM: mvebu: switch to DT probed mv643xx_eth
Date: Tue,  2 Jul 2013 13:00:17 +0200
Message-ID: <1372762824-12202-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Russell King <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch set converts Marvell Dove, Kirkwood, and Orion5x DT enabled
boards to probe mv643xx_eth by DT. The corresponding DT support patches
for mv643xx_eth driver have already been taked by David Miller and are
available in next-20130701. This only contains the ARM part of
mv643xx_eth DT support patches and therefore patch counting is
continued as v6 with respect to the combined patch set.

The first three patches add nodes for ethernet-controller, mdio-bus,
and ethernet PHYs found on the three SoCs and their boards.

The last four patches convert DT boards for each SoC from platform_device
registration to DT based probing by removing the corresponding calls.
For Kirkwood this makes almost all DT board setup (except board-dnskw)
obsolete. Therefore, patch 5 removes board setup files, Kconfig, Makefile,
and defconfig entries for those boards.

This patch set has been tested on Marvell Dove, and compile-tested for
Kirkwood and Orion5x defconfig on top of next-20130701 with some fixes
sent earlier applied (DMA_MEMSET fixes and missing include on edmini_v2).

netdev is added on Cc for completeness, this is all Marvell related and
should go through Jason Cooper's branch if there are no objections.

Sebastian Hesselbarth (7):
  ARM: dove: add gigabit ethernet and mvmdio device tree nodes
  ARM: kirkwood: add gigabit ethernet and mvmdio device tree nodes
  ARM: orion5x: add gigabit ethernet and mvmdio device tree nodes
  ARM: dove: remove legacy mv643xx_eth setup
  ARM: kirkwood: remove redundant DT board files
  ARM: kirkwood: remove legacy clk alias for mv643xx_eth
  ARM: orion5x: remove legacy mv643xx_eth board setup

 arch/arm/boot/dts/dove-cubox.dts                   |    7 +
 arch/arm/boot/dts/dove.dtsi                        |   35 +++++
 arch/arm/boot/dts/kirkwood-cloudbox.dts            |   16 ++
 arch/arm/boot/dts/kirkwood-db.dtsi                 |   16 ++
 arch/arm/boot/dts/kirkwood-dnskw.dtsi              |   16 ++
 arch/arm/boot/dts/kirkwood-dockstar.dts            |   17 ++
 arch/arm/boot/dts/kirkwood-dreamplug.dts           |   28 ++++
 arch/arm/boot/dts/kirkwood-goflexnet.dts           |   16 ++
 .../arm/boot/dts/kirkwood-guruplug-server-plus.dts |   30 ++++
 arch/arm/boot/dts/kirkwood-ib62x0.dts              |   16 ++
 arch/arm/boot/dts/kirkwood-iconnect.dts            |   16 ++
 arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts      |   24 +++
 arch/arm/boot/dts/kirkwood-is2.dts                 |    2 +
 arch/arm/boot/dts/kirkwood-km_kirkwood.dts         |   16 ++
 arch/arm/boot/dts/kirkwood-lsxl.dtsi               |   28 ++++
 arch/arm/boot/dts/kirkwood-mplcec4.dts             |   27 ++++
 .../boot/dts/kirkwood-netgear_readynas_duo_v2.dts  |   16 ++
 arch/arm/boot/dts/kirkwood-ns2-common.dtsi         |   16 ++
 arch/arm/boot/dts/kirkwood-ns2.dts                 |    2 +
 arch/arm/boot/dts/kirkwood-ns2lite.dts             |    2 +
 arch/arm/boot/dts/kirkwood-ns2max.dts              |    2 +
 arch/arm/boot/dts/kirkwood-ns2mini.dts             |    2 +
 arch/arm/boot/dts/kirkwood-openblocks_a6.dts       |   16 ++
 arch/arm/boot/dts/kirkwood-sheevaplug-common.dtsi  |   16 ++
 arch/arm/boot/dts/kirkwood-topkick.dts             |   16 ++
 arch/arm/boot/dts/kirkwood-ts219-6281.dts          |    4 +-
 arch/arm/boot/dts/kirkwood-ts219-6282.dts          |    4 +-
 arch/arm/boot/dts/kirkwood-ts219.dtsi              |   16 ++
 arch/arm/boot/dts/kirkwood.dtsi                    |   52 +++++++
 .../dts/orion5x-lacie-ethernet-disk-mini-v2.dts    |   17 ++
 arch/arm/boot/dts/orion5x.dtsi                     |   29 ++++
 arch/arm/configs/kirkwood_defconfig                |   22 ---
 arch/arm/mach-dove/board-dt.c                      |    9 -
 arch/arm/mach-kirkwood/Kconfig                     |  156 --------------------
 arch/arm/mach-kirkwood/Makefile                    |   23 +---
 arch/arm/mach-kirkwood/board-db88f628x-bp.c        |   24 ---
 arch/arm/mach-kirkwood/board-dnskw.c               |    7 -
 arch/arm/mach-kirkwood/board-dockstar.c            |   32 ----
 arch/arm/mach-kirkwood/board-dreamplug.c           |   35 -----
 arch/arm/mach-kirkwood/board-dt.c                  |   86 +-----------
 arch/arm/mach-kirkwood/board-goflexnet.c           |   34 -----
 arch/arm/mach-kirkwood/board-guruplug.c            |   33 ----
 arch/arm/mach-kirkwood/board-ib62x0.c              |   29 ----
 arch/arm/mach-kirkwood/board-iconnect.c            |   24 ---
 arch/arm/mach-kirkwood/board-iomega_ix2_200.c      |   34 -----
 arch/arm/mach-kirkwood/board-km_kirkwood.c         |   44 ------
 arch/arm/mach-kirkwood/board-lsxl.c                |   36 -----
 arch/arm/mach-kirkwood/board-mplcec4.c             |   35 -----
 arch/arm/mach-kirkwood/board-ns2.c                 |   35 -----
 arch/arm/mach-kirkwood/board-openblocks_a6.c       |   26 ----
 arch/arm/mach-kirkwood/board-readynas.c            |   27 ----
 arch/arm/mach-kirkwood/board-sheevaplug.c          |   27 ----
 arch/arm/mach-kirkwood/board-ts219.c               |   40 -----
 arch/arm/mach-kirkwood/board-usi_topkick.c         |   29 ----
 arch/arm/mach-orion5x/edmini_v2-setup.c            |   10 --
 55 files changed, 520 insertions(+), 857 deletions(-)
 delete mode 100644 arch/arm/mach-kirkwood/board-db88f628x-bp.c
 delete mode 100644 arch/arm/mach-kirkwood/board-dockstar.c
 delete mode 100644 arch/arm/mach-kirkwood/board-dreamplug.c
 delete mode 100644 arch/arm/mach-kirkwood/board-goflexnet.c
 delete mode 100644 arch/arm/mach-kirkwood/board-guruplug.c
 delete mode 100644 arch/arm/mach-kirkwood/board-ib62x0.c
 delete mode 100644 arch/arm/mach-kirkwood/board-iconnect.c
 delete mode 100644 arch/arm/mach-kirkwood/board-iomega_ix2_200.c
 delete mode 100644 arch/arm/mach-kirkwood/board-km_kirkwood.c
 delete mode 100644 arch/arm/mach-kirkwood/board-lsxl.c
 delete mode 100644 arch/arm/mach-kirkwood/board-mplcec4.c
 delete mode 100644 arch/arm/mach-kirkwood/board-ns2.c
 delete mode 100644 arch/arm/mach-kirkwood/board-openblocks_a6.c
 delete mode 100644 arch/arm/mach-kirkwood/board-readynas.c
 delete mode 100644 arch/arm/mach-kirkwood/board-sheevaplug.c
 delete mode 100644 arch/arm/mach-kirkwood/board-ts219.c
 delete mode 100644 arch/arm/mach-kirkwood/board-usi_topkick.c

---
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
-- 
1.7.2.5
