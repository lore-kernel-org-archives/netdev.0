From: jacopo mondi <jacopo@jmondi.org>
Subject: Re: [PATCH 3/3] ARM: dts: gr-peach: Add ETHER pin group
Date: Fri, 6 Oct 2017 14:24:45 +0200
Message-ID: <20171006122445.GA30375@w540>
References: <1507193900-23801-1-git-send-email-jacopo+renesas@jmondi.org>
 <1507193900-23801-4-git-send-email-jacopo+renesas@jmondi.org>
 <CAMuHMdWLt9EYp21YiMp7uEGWgjEO_VztbDOyvhr+RxkrAKRYYA@mail.gmail.com>
 <20171005093915.GP4037@w540>
 <20171005134339.GJ13247@lunn.ch>
 <20171005154239.GB19008@w540>
 <20171005164826.GL13247@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        Chris Brandt <Chris.Brandt@renesas.com>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:41071 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751807AbdJFMc6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 08:32:58 -0400
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 47F28486D8E
        for <netdev@vger.kernel.org>; Fri,  6 Oct 2017 14:25:34 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20171005164826.GL13247@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,
   thanks for the suggestion

On Thu, Oct 05, 2017 at 06:48:26PM +0200, Andrew Lunn wrote:
> On Thu, Oct 05, 2017 at 05:42:39PM +0200, jacopo mondi wrote:
> > Hi Andrew,

[snip]

> > > Hi Jocopo
> > >
> > > So what is this reset resetting?
> > >
> > > The MAC?
> > > The PHY?
> >
> > The reset line goes from our SoC to LAN8710A PHY chip external reset pin.
>
> So yes, this is a PHY property, and should be in the PHY node.
>
> Documentation/devicetree/bindings/net/mdio.txt does not apply here
> anyway. That is for an MDIO binding. This node is an ethernet MAC.
>
> So your binding whats to look something like
>
>         ether: ethernet@e8203000 {
>                 compatible = "renesas,ether-r7s72100";
>                 reg = <0xe8203000 0x800>,
>                       <0xe8204800 0x200>;
>                 interrupts = <GIC_SPI 327 IRQ_TYPE_LEVEL_HIGH>;
>                 clocks = <&mstp7_clks R7S72100_CLK_ETHER>;
>                 power-domains = <&cpg_clocks>;
>                 phy-mode = "mii";
> 		          phy-handle = <&phy0>;
>                 #address-cells = <1>;
>                 #size-cells = <0>;
>
>                 mdio: bus-bus {
>                       #address-cells = <1>;
>                       #size-cells = <0>;
>
>                       phy0: ethernet-phy@1 {
>                             reg = <1>;

Why reg = <1> ?
Shouldn't this be 0, or even better with no reg property at all?

        mdio: bus-bus {
              phy-0 {
                  reset-gpios = <&port4 2 GPIO_ACTIVE_LOW>;
                  reset-delay-us = <5>;
              };
        };

Thanks
   j

>                             reset-gpios = <&port4 2 GPIO_ACTIVE_LOW>;
>                             reset-delay-us = <5>;
>                       };
>                 };
>         };
>
> 	Andrew
