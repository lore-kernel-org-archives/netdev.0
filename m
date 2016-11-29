From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v3 net-next 0/6] Support Armada 37xx SoC (ARMv8 64-bits) in mvneta driver
Date: Tue, 29 Nov 2016 10:37:20 +0100
Message-ID: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
Cc: Jisheng Zhang <jszhang@marvell.com>, Arnd Bergmann <arnd@arndb.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Dmitri Epshtein <dima@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47106 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754310AbcK2Jh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 04:37:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The Armada 37xx is a new ARMv8 SoC from Marvell using same network
controller as the older Armada 370/38x/XP SoCs. This series adapts the
driver in order to be able to use it on this new SoC. The main changes
are:

- 64-bits support: the first patches allow using the driver on a 64-bit
  architecture.

- MBUS support: the mbus configuration is different on Armada 37xx
  from the older SoCs.

- per cpu interrupt: Armada 37xx do not support per cpu interrupt for
  the NETA IP, the non-per-CPU behavior was added back.

The first item is solved by patches 1 to 3.
The 2 last items are solved by patch 4.
In patch 5 the dt support is added.

Beside Armada 37xx, the series have been tested on Armada XP and
Armada 38x (with Hardware Buffer Management and with Software Buffer
Managment).

Thanks,

Gregory

Gregory CLEMENT (4):
  net: mvneta: Optimize rx path for small frame
  net: mvneta: Use cacheable memory to store the rx buffer virtual address
  net: mvneta: Only disable mvneta_bm for 64-bits
  ARM64: dts: marvell: Add network support for Armada 3700

Marcin Wojtas (2):
  net: mvneta: Convert to be 64 bits compatible
  net: mvneta: Add network support for Armada 3700 SoC

 Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt |   7 +-
 arch/arm64/boot/dts/marvell/armada-3720-db.dts                    |  23 ++++-
 arch/arm64/boot/dts/marvell/armada-37xx.dtsi                      |  23 ++++-
 drivers/net/ethernet/marvell/Kconfig                              |  10 +-
 drivers/net/ethernet/marvell/mvneta.c                             | 400 ++++++++++++++++++++++++++++++++++++++++++++++++++++++------------------
 5 files changed, 361 insertions(+), 102 deletions(-)

base-commit: 436accebb53021ef7c63535f60bda410aa87c136
-- 
git-series 0.8.10
