From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2 net-next 0/8] API set for HW Buffer management
Date: Tue, 16 Feb 2016 16:33:35 +0100
Message-ID: <1455636823-14470-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Timor Kardashov <timork@marvell.com>,
	Sebastian Careba <nitroshift@yahoo.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:59785 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755236AbcBPPeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 10:34:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

A few weeks ago I sent a proposal for a API set for HW Buffer
management, to have a better view of the motivation for this API see
the cover letter of this proposal:
http://thread.gmane.org/gmane.linux.kernel/2125152

Since this version I took into account the review from Florian:
- The hardware buffer management helpers are no more built by default
  and now depend on a hidden config symbol which has to be selected
  by the driver if needed
- The hwbm_pool_refill() and hwbm_pool_add() now receive a gfp_t as
  argument allowing the caller to specify the flag it needs.
- buf_num is now tested to ensure there is no wrapping
- A spinlock has been added to protect the hwbm_pool_add() function in
  SMP or irq context.

I also used pr_warn instead of pr_debug in case of errors.

I fixed the mvneta implementation by returning the buffer to the pool
at various place instead of ignoring it.

About the series itself I tried to make this series easier to merge:
- Squashed "bus: mvenus-mbus: Fix size test for
   mvebu_mbus_get_dram_win_info" into bus: mvebu-mbus: provide api for
   obtaining IO and DRAM window information.
- Added my signed-otf-by on all the patches as submitter of the series.
- Renamed the dts patches with the pattern "ARM: dts: platform:"
- Removed the patch "ARM: mvebu: enable SRAM support in
  mvebu_v7_defconfig" of this series and already applied it
- Rodified the order of the patches.

In order to ease the test the branch mvneta-BM-framework-v2 is
available at git@github.com:MISL-EBU-System-SW/mainline-public.git.

David,

I would like to merge the 4 first patches myself once you will have
take the 4 last patches of the series. Patch 5 do not modify files in
the net subsystem, but as there is a build dependency it is better if
you merge it in the same time as the 3 other ones.

Thanks,

Gregory

Gregory CLEMENT (2):
  net: add a hardware buffer management helper API
  net: mvneta: Use the new hwbm framework

Marcin Wojtas (6):
  ARM: dts: armada-38x: add buffer manager nodes
  ARM: dts: armada-38x: enable buffer manager support on Armada 38x
    boards
  ARM: dts: armada-xp: add buffer manager nodes
  ARM: dts: armada-xp: enable buffer manager support on Armada XP boards
  bus: mvebu-mbus: provide api for obtaining IO and DRAM window
    information
  net: mvneta: bm: add support for hardware buffer management

 .../bindings/net/marvell-armada-370-neta.txt       |  19 +-
 .../devicetree/bindings/net/marvell-neta-bm.txt    |  49 +++
 arch/arm/boot/dts/armada-385-db-ap.dts             |  20 +-
 arch/arm/boot/dts/armada-388-clearfog.dts          |   6 +
 arch/arm/boot/dts/armada-388-db.dts                |  17 +-
 arch/arm/boot/dts/armada-388-gp.dts                |  17 +-
 .../arm/boot/dts/armada-38x-solidrun-microsom.dtsi |  15 +-
 arch/arm/boot/dts/armada-38x.dtsi                  |  18 +
 arch/arm/boot/dts/armada-xp-db.dts                 |  19 +-
 arch/arm/boot/dts/armada-xp-gp.dts                 |  19 +-
 arch/arm/boot/dts/armada-xp.dtsi                   |  18 +
 drivers/bus/mvebu-mbus.c                           |  51 +++
 drivers/net/ethernet/marvell/Kconfig               |  15 +
 drivers/net/ethernet/marvell/Makefile              |   1 +
 drivers/net/ethernet/marvell/mvneta.c              | 430 +++++++++++++++---
 drivers/net/ethernet/marvell/mvneta_bm.c           | 486 +++++++++++++++++++++
 drivers/net/ethernet/marvell/mvneta_bm.h           | 162 +++++++
 include/linux/mbus.h                               |   3 +
 include/net/hwbm.h                                 |  21 +
 net/Kconfig                                        |   3 +
 net/core/Makefile                                  |   1 +
 net/core/hwbm.c                                    |  87 ++++
 22 files changed, 1415 insertions(+), 62 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-neta-bm.txt
 create mode 100644 drivers/net/ethernet/marvell/mvneta_bm.c
 create mode 100644 drivers/net/ethernet/marvell/mvneta_bm.h
 create mode 100644 include/net/hwbm.h
 create mode 100644 net/core/hwbm.c

-- 
2.5.0
