From: =?UTF-8?B?QW5kcsOp?= Roth <neolynx@gmail.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Thu, 17 Nov 2016 19:44:05 +0100
Message-ID: <20161117194405.4ca7899b@gmail.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
        <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
        <CAFBinCC0HiEXx5mELztH6jYfUq2f1u0Tb+pSzAvwQSu9vYydGQ@mail.gmail.com>
        <20161031112524.4c4ee8f8@gmail.com>
        <1478192276.6632.34.camel@baylibre.com>
        <20161113201339.667ac1f7@gmail.com>
        <1479120574.29252.29.camel@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Johnson Leung <r58129@freescale.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        linux-amlogic@lists.infradead.org,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org
To: Jerome Brunet <jbrunet@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35999 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753268AbcKQSoK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 13:44:10 -0500
Received: by mail-wm0-f68.google.com with SMTP id m203so23874574wma.3
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 10:44:09 -0800 (PST)
In-Reply-To: <1479120574.29252.29.camel@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

> I checked again the kernel
> at=C2=A0https://github.com/hardkernel/linux/tree/ odroidc2-3.14.y. The
> version you mention (3.14.65-73) seems to be:
> sha1:=C2=A0c75d5f4d1516cdd86d90a9d1c565bb0ed9251036 tag: jenkins-deb s905
> kernel-73

I downloaded the prebuilt image from hardkernel, I did not build the
kernel myself. but hardkernel has an earlier release of the same kernel
version, which works fine too. I assume they would have committed the
change in the newer version..
=20
> In this particular version, both realtek drivers:
> - drivers/net/phy/realtek.c
> - drivers/amlogic/ethernet/phy/am_realtek.c
>=20
> have the hack to disable 1000M advertisement. I don't understand how
> it possible for you to have 1000Base-T Full Duplex with this, maybe
> I'm missing something here ?

that's what I don't understand as well...

the patched kernel shows the following:

$ uname -a
Linux T-06 4.9.0-rc4+ #21 SMP PREEMPT Sun Nov 13 12:07:19 UTC 2016

$ sudo ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Link partner advertised link modes:  10baseT/Half 10baseT/Full=20
                                             100baseT/Half
100baseT/Full 1000baseT/Half 1000baseT/Full=20
        Link partner advertised pause frame use: Symmetric Receive-only
        Link partner advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 0
        Transceiver: external
        Auto-negotiation: on
        Supports Wake-on: ug
        Wake-on: d
        Current message level: 0x0000003f (63)
                               drv probe link timer ifdown ifup
        Link detected: yes

$ sudo ethtool --show-eee eth0
EEE Settings for eth0:
        EEE status: disabled
        Tx LPI: disabled
        Supported EEE link modes:  100baseT/Full=20
                                   1000baseT/Full=20
        Advertised EEE link modes:  100baseT/Full=20
        Link partner advertised EEE link modes:  100baseT/Full=20
                                                 1000baseT/Full=20

can it be that "EEE link modes" and the "normal" link modes are two
different things ?=20

> If you did compile the kernel yourself, could you check the 2 file
> mentioned above ? Just to be sure there was no patch applied at the
> last minute, which would not show up in the git history of
> hardkernel ?

I cannot check this easily at the moment..

Regards,

 Andr=C3=A9
