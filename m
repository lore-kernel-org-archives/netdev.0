From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH 0/8] net: mvpp2: add TX interrupts support
Date: Wed, 26 Jul 2017 08:18:18 +0200
Message-ID: <CAPv3WKeC4Ry+cR5FMh5BGgp=+UdzkxRf6=EqKBmWMNQtb+YLdg@mail.gmail.com>
References: <20170725155509.10574-1-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Russell King <linux@arm.linux.org.uk>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        =?UTF-8?Q?Miqu=C3=A8l_Raynal?= <miquel.raynal@free-electrons.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Stefan Chulski <stefanc@marvell.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34775 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750772AbdGZGST (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 02:18:19 -0400
Received: by mail-io0-f179.google.com with SMTP id l7so64393854iof.1
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 23:18:19 -0700 (PDT)
In-Reply-To: <20170725155509.10574-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

I tested patchset on A8040-DB, everything seems fine.

Best regards,
Marcin

2017-07-25 17:55 GMT+02:00 Thomas Petazzoni
<thomas.petazzoni@free-electrons.com>:
> Hello,
>
> So far, the mvpp2 driver was using an hrtimer to handle TX
> completion. This patch series adds support for using TX interrupts
> (for each CPU) on PPv2.2, the variant of the IP used on Marvell Armada
> 7K/8K.
>
> This series has been tested on Marvell Armada 7K (PPv2.2) and Armada
> 375 (PPv2.1).
>
> Dave:
>
>  - This series depends on the previous series sent by Antoine T=C3=A9nart
>    "net: mvpp2: MAC/GoP configuration and optional PHYs". Functionally
>    speaking there is no real dependency, but we touch in a few areas
>    the same piece of code, so I based my patch series on top of
>    Antoine's.
>
>  - Please do not apply the last patch of this series "arm64: dts:
>    marvell: add TX interrupts for PPv2.2", it will be taken by the ARM
>    mvebu maintainers.
>
> Thanks!
>
> Thomas
>
> Thomas Petazzoni (8):
>   net: mvpp2: fix MVPP21_ISR_RXQ_GROUP_REG definition
>   net: mvpp2: remove RX queue group reset code
>   net: mvpp2: introduce per-port nrxqs/ntxqs variables
>   net: mvpp2: move from cpu-centric naming to "software thread" naming
>   net: mvpp2: introduce queue_vector concept
>   net: mvpp2: add support for TX interrupts and RX queue distribution
>     modes
>   dt-bindings: net: marvell-pp2: update interrupt-names with TX
>     interrupts
>   arm64: dts: marvell: add TX interrupts for PPv2.2
>
>  .../devicetree/bindings/net/marvell-pp2.txt        |  33 +-
>  .../boot/dts/marvell/armada-cp110-master.dtsi      |  21 +-
>  .../arm64/boot/dts/marvell/armada-cp110-slave.dtsi |  21 +-
>  drivers/net/ethernet/marvell/mvpp2.c               | 638 +++++++++++++++=
------
>  4 files changed, 534 insertions(+), 179 deletions(-)
>
> --
> 2.9.4
>
