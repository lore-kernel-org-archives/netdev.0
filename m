From: Jerome Brunet <jbrunet@baylibre.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Thu, 17 Nov 2016 22:47:31 +0100
Message-ID: <1479419251.17538.73.camel@baylibre.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
         <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
         <CAFBinCC0HiEXx5mELztH6jYfUq2f1u0Tb+pSzAvwQSu9vYydGQ@mail.gmail.com>
         <20161031112524.4c4ee8f8@gmail.com> <1478192276.6632.34.camel@baylibre.com>
         <20161113201339.667ac1f7@gmail.com>
         <1479120574.29252.29.camel@baylibre.com>
         <20161117194405.4ca7899b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Johnson Leung <r58129@freescale.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        linux-amlogic@lists.infradead.org,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Andr=E9?= Roth <neolynx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:33887 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751593AbcKQVrf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 16:47:35 -0500
Received: by mail-wm0-f50.google.com with SMTP id u144so420411wmu.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 13:47:34 -0800 (PST)
In-Reply-To: <20161117194405.4ca7899b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-11-17 at 19:44 +0100, André Roth wrote:
> Hi all,
> 
> > 
> > I checked again the kernel
> > at https://github.com/hardkernel/linux/tree/ odroidc2-3.14.y. The
> > version you mention (3.14.65-73) seems to be:
> > sha1: c75d5f4d1516cdd86d90a9d1c565bb0ed9251036 tag: jenkins-deb
> > s905
> > kernel-73
> 
> I downloaded the prebuilt image from hardkernel, I did not build the
> kernel myself. but hardkernel has an earlier release of the same
> kernel
> version, which works fine too. I assume they would have committed the
> change in the newer version..
>  
> > 
> > In this particular version, both realtek drivers:
> > - drivers/net/phy/realtek.c
> > - drivers/amlogic/ethernet/phy/am_realtek.c
> > 
> > have the hack to disable 1000M advertisement. I don't understand
> > how
> > it possible for you to have 1000Base-T Full Duplex with this, maybe
> > I'm missing something here ?
> 
> that's what I don't understand as well...
> 
> the patched kernel shows the following:
> 
> $ uname -a
> Linux T-06 4.9.0-rc4+ #21 SMP PREEMPT Sun Nov 13 12:07:19 UTC 2016
> 
> $ sudo ethtool eth0
> Settings for eth0:
>         Supported ports: [ TP MII ]
>         Supported link modes:   10baseT/Half 10baseT/Full 
>                                 100baseT/Half 100baseT/Full 
>                                 1000baseT/Full 
>         Supported pause frame use: No
>         Supports auto-negotiation: Yes
>         Advertised link modes:  10baseT/Half 10baseT/Full 
>                                 100baseT/Half 100baseT/Full 
>                                 1000baseT/Full 
>         Advertised pause frame use: No
>         Advertised auto-negotiation: Yes
>         Link partner advertised link modes:  10baseT/Half
> 10baseT/Full 
>                                              100baseT/Half
> 100baseT/Full 1000baseT/Half 1000baseT/Full 
>         Link partner advertised pause frame use: Symmetric Receive-
> only
>         Link partner advertised auto-negotiation: Yes
>         Speed: 1000Mb/s
>         Duplex: Full
>         Port: MII
>         PHYAD: 0
>         Transceiver: external
>         Auto-negotiation: on
>         Supports Wake-on: ug
>         Wake-on: d
>         Current message level: 0x0000003f (63)
>                                drv probe link timer ifdown ifup
>         Link detected: yes
> 
> $ sudo ethtool --show-eee eth0
> EEE Settings for eth0:
>         EEE status: disabled
>         Tx LPI: disabled
>         Supported EEE link modes:  100baseT/Full 
>                                    1000baseT/Full 
>         Advertised EEE link modes:  100baseT/Full 
>         Link partner advertised EEE link modes:  100baseT/Full 
>                                                  1000baseT/Full 
> 
> can it be that "EEE link modes" and the "normal" link modes are two
> different things ? 

Exactly, They are.
Hardkernel code disable both.

With hardkernel's kernel, you should not have 1000baseT/Full in
"Advertised link modes" and you would have nothing reported in
"Advertised EEE link modes"

> 
> > 
> > If you did compile the kernel yourself, could you check the 2 file
> > mentioned above ? Just to be sure there was no patch applied at the
> > last minute, which would not show up in the git history of
> > hardkernel ?
> 
> I cannot check this easily at the moment..
> 
> Regards,
> 
>  André
> 
