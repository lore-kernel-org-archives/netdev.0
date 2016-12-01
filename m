From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH v5 net-next 0/7] Support Armada 37xx SoC (ARMv8 64-bits)
 in mvneta driver
Date: Thu, 1 Dec 2016 17:07:01 +0100
Message-ID: <CAPv3WKdWyS0wCVsRKR86qpMx4r8NN9=RmjM9oHFy2mmvaR5PAA@mail.gmail.com>
References: <cover.0270f6d2413a709521fe2c8c17fbebea6f2e78d1.1480542157.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Jisheng Zhang <jszhang@marvell.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Nadav Haklai <nadavh@marvell.com>,
        Dmitri Epshtein <dima@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33941 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760693AbcLAQHF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:07:05 -0500
Received: by mail-io0-f181.google.com with SMTP id c21so394851679ioj.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:07:04 -0800 (PST)
In-Reply-To: <cover.0270f6d2413a709521fe2c8c17fbebea6f2e78d1.1480542157.git-series.gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gregory,

Checked on a388-gp with and without HWBM, also both ports work on
a3700 (second one after changing to sgmii).

Tested-by: Marcin Wojtas <mw@semihalf.com>

Best regards,
Marcin

2016-11-30 22:42 GMT+01:00 Gregory CLEMENT <gregory.clement@free-electrons.com>:
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
> The first patch is an optimization in the rx path in swbm mode.
> The second patch remove unnecessary allocation for HWBM.
> The first item is solved by patches 4 and 5.
> The 2 last items are solved by patch 6.
> In patch 7 the dt support is added.
>
> Beside Armada 37xx, this series have been again tested on Armada XP
> and Armada 38x (with Hardware Buffer Management and with Software
> Buffer Management).
>
> This is the 5th version of the series:
> - 1st version:
> http://lists.infradead.org/pipermail/linux-arm-kernel/2016-November/469588.html
>
> - 2nd version:
> http://lists.infradead.org/pipermail/linux-arm-kernel/2016-November/470476.html
>
> - 3rd version:
> http://lists.infradead.org/pipermail/linux-arm-kernel/2016-November/470901.html
>
> - 4th version:
> http://lists.infradead.org/pipermail/linux-arm-kernel/2016-November/471039.html
>
> Changelog:
> v4 -> v5:
>  - remove unnecessary cast in patch 3
>
> v3 -> v4:
>  - Adding new patch: "net: mvneta: do not allocate buffer in rxq init
>    with HWBM"
>
>  - Simplify the HWBM case in patch 3 as suggested by Marcin
>
> v2 -> v3:
>  - Adding patch 1 "Optimize rx path for small frame"
>
>  - Fix the kbuild error by moving the "phys_addr += pp->rx_offset_correction;"
>   line from patch 2 to patch 3 where rx_offset_correction is introduced.
>
>  - Move the memory allocation of the buf_virt_addr of the rxq to be
>    called by the probe function in order to avoid a memory leak.
>
> Thanks,
>
> Gregory
>
> Gregory CLEMENT (5):
>   net: mvneta: Optimize rx path for small frame
>   net: mvneta: Do not allocate buffer in rxq init with HWBM
>   net: mvneta: Use cacheable memory to store the rx buffer virtual address
>   net: mvneta: Only disable mvneta_bm for 64-bits
>   ARM64: dts: marvell: Add network support for Armada 3700
>
> Marcin Wojtas (2):
>   net: mvneta: Convert to be 64 bits compatible
>   net: mvneta: Add network support for Armada 3700 SoC
>
>  Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt |   7 +-
>  arch/arm64/boot/dts/marvell/armada-3720-db.dts                    |  23 +++++-
>  arch/arm64/boot/dts/marvell/armada-37xx.dtsi                      |  23 +++++-
>  drivers/net/ethernet/marvell/Kconfig                              |  10 +-
>  drivers/net/ethernet/marvell/mvneta.c                             | 344 +++++++++++++++++++++++++++++++++++++++++++++++++++---------------------
>  5 files changed, 305 insertions(+), 102 deletions(-)
>
> base-commit: 436accebb53021ef7c63535f60bda410aa87c136
> --
> git-series 0.8.10
