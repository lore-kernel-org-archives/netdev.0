From: Ian Molton <ian.molton@codethink.co.uk>
Subject: [PATCH v2 0/6] mv643xx Ethernet DT support and CSB1724 board support.
Date: Tue, 31 Jul 2012 16:45:23 +0100
Message-ID: <1343749529-17571-1-git-send-email-ian.molton@codethink.co.uk>
Cc: andrew@lunn.ch, thomas.petazzoni@free-electrons.com,
	ben.dooks@codethink.co.uk, arnd@arndb.de, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:59913 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755137Ab2GaPzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 11:55:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Respin of the previous patch. All comments have been addressed.

Addressed: 

* Typos
* Docs
* Automatic clock detection / setup
* PHY addresses are not | 0x80 anymore
  - which is a horrid way for the driver to be doing things but hey...
* property added to DT bindings for tx_csum_limit
* GFP_ATOMIC allocations demoted to GFP_KERNEL (cpoypaste error)
* devide order in .dts(i) files fixed

Outstanding:

* Should the tx_csum_limit issue be addressed by:
  - a new device name
  - detecting the host platform
  - a property (present solution).

Ian Molton (6):
  Initial csb1724 board support (FDT)
  mv643xx.c: Remove magic numbers.
  mv643xx.c: Add basic device tree support.
  kirkwood: Add a clock setup helper for mv643xx ethernet.
  csb1724: Enable device tree based mv643xx ethernet support.
  DT: Convert all kirkwood boards with mv643xx that use DT

 Documentation/devicetree/bindings/net/mv643xx.txt |   75 +++++++++++++
 arch/arm/boot/dts/kirkwood-csb1724.dts            |   49 +++++++++
 arch/arm/boot/dts/kirkwood-dnskw.dtsi             |    9 ++
 arch/arm/boot/dts/kirkwood-dreamplug.dts          |   18 +++
 arch/arm/boot/dts/kirkwood-goflexnet.dts          |    8 ++
 arch/arm/boot/dts/kirkwood-ib62x0.dts             |   10 ++
 arch/arm/boot/dts/kirkwood-iconnect.dts           |   10 ++
 arch/arm/boot/dts/kirkwood-lsxl.dtsi              |   17 +++
 arch/arm/boot/dts/kirkwood-ts219-6281.dts         |    8 +-
 arch/arm/boot/dts/kirkwood-ts219-6282.dts         |    8 +-
 arch/arm/boot/dts/kirkwood-ts219.dtsi             |    3 +
 arch/arm/boot/dts/kirkwood.dtsi                   |   33 ++++++
 arch/arm/configs/csb1724_defconfig                |   92 ++++++++++++++++
 arch/arm/mach-kirkwood/Kconfig                    |    7 ++
 arch/arm/mach-kirkwood/Makefile                   |    1 +
 arch/arm/mach-kirkwood/Makefile.boot              |    1 +
 arch/arm/mach-kirkwood/board-csb1724.c            |   60 ++++++++++
 arch/arm/mach-kirkwood/board-dnskw.c              |    7 +-
 arch/arm/mach-kirkwood/board-dreamplug.c          |   13 +--
 arch/arm/mach-kirkwood/board-dt.c                 |   11 ++
 arch/arm/mach-kirkwood/board-goflexnet.c          |    7 +-
 arch/arm/mach-kirkwood/board-ib62x0.c             |    7 +-
 arch/arm/mach-kirkwood/board-iconnect.c           |    7 +-
 arch/arm/mach-kirkwood/board-lsxl.c               |   13 +--
 arch/arm/mach-kirkwood/board-ts219.c              |   10 +-
 arch/arm/mach-kirkwood/common.c                   |   22 ++++
 arch/arm/mach-kirkwood/common.h                   |    9 ++
 drivers/net/ethernet/marvell/mv643xx_eth.c        |  122 ++++++++++++++++++---
 28 files changed, 565 insertions(+), 72 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/mv643xx.txt
 create mode 100644 arch/arm/boot/dts/kirkwood-csb1724.dts
 create mode 100644 arch/arm/configs/csb1724_defconfig
 create mode 100644 arch/arm/mach-kirkwood/board-csb1724.c

-- 
1.7.9.5
