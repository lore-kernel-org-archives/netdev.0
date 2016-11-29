From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v3 net-next 0/6] Support Armada 37xx SoC (ARMv8 64-bits) in mvneta driver
Date: Tue, 29 Nov 2016 11:05:37 +0100
Message-ID: <871sxuha8e.fsf@free-electrons.com>
References: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Jisheng Zhang <jszhang@marvell.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Dmitri Epshtein <dima@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
        (Gregory CLEMENT's message of "Tue, 29 Nov 2016 10:37:20 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
 
 On mar., nov. 29 2016, Gregory CLEMENT <gregory.clement@free-electrons.com> wrote:

> Hi,
>
> The Armada 37xx is a new ARMv8 SoC from Marvell using same network
> controller as the older Armada 370/38x/XP SoCs. This series adapts the
> driver in order to be able to use it on this new SoC. The main changes
> are:
>
> - 64-bits support: the first patches allow using the driver on a 64-bit
>   architecture.
>
> - MBUS support: the mbus configuration is different on Armada 37xx
>   from the older SoCs.
>
> - per cpu interrupt: Armada 37xx do not support per cpu interrupt for
>   the NETA IP, the non-per-CPU behavior was added back.
>
> The first item is solved by patches 1 to 3.
> The 2 last items are solved by patch 4.
> In patch 5 the dt support is added.
>
> Beside Armada 37xx, the series have been tested on Armada XP and
> Armada 38x (with Hardware Buffer Management and with Software Buffer
> Managment).
>
> Thanks,
>

I forgot to commit my cover with git series, so it was the old one. It
should have been the following one:

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

The first patch is an optimization in the rx path in swbm mode.
The first item is solved by patches 2 to 3.
The 2 last items are solved by patch 5.
In patch 6 the dt support is added.

Beside Armada 37xx, this new series have been again tested on Armada
XP and Armada 38x (with Hardware Buffer Management and with Software
Buffer Management).

This is the 3th version of the series:

- 1st version:
http://lists.infradead.org/pipermail/linux-arm-kernel/2016-November/469588.html

- 2nd version:
http://lists.infradead.org/pipermail/linux-arm-kernel/2016-November/470476.html

Changelog:
v2 -> v3:

 - Adding patch 1 "Optimize rx path for small frame"

 - Fix the kbuild error by moving the "phys_addr += pp->rx_offset_correction;"
  line from patch 2 to patch 3 where rx_offset_correction is introduced.

 - Move the memory allocation of the buf_virt_addr of the rxq to be
   called by the probe function in order to avoid a memory leak.


> Gregory
>
> Gregory CLEMENT (4):
>   net: mvneta: Optimize rx path for small frame
>   net: mvneta: Use cacheable memory to store the rx buffer virtual address
>   net: mvneta: Only disable mvneta_bm for 64-bits
>   ARM64: dts: marvell: Add network support for Armada 3700
>
> Marcin Wojtas (2):
>   net: mvneta: Convert to be 64 bits compatible
>   net: mvneta: Add network support for Armada 3700 SoC
>
>  Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt |   7 +-
>  arch/arm64/boot/dts/marvell/armada-3720-db.dts                    |  23 ++++-
>  arch/arm64/boot/dts/marvell/armada-37xx.dtsi                      |  23 ++++-
>  drivers/net/ethernet/marvell/Kconfig                              |  10 +-
>  drivers/net/ethernet/marvell/mvneta.c                             | 400 ++++++++++++++++++++++++++++++++++++++++++++++++++++++------------------
>  5 files changed, 361 insertions(+), 102 deletions(-)
>
> base-commit: 436accebb53021ef7c63535f60bda410aa87c136
> -- 
> git-series 0.8.10

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
