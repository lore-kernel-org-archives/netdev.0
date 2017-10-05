From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] ARM: dts: gr-peach: Add ETHER pin group
Date: Thu, 5 Oct 2017 18:48:26 +0200
Message-ID: <20171005164826.GL13247@lunn.ch>
References: <1507193900-23801-1-git-send-email-jacopo+renesas@jmondi.org>
 <1507193900-23801-4-git-send-email-jacopo+renesas@jmondi.org>
 <CAMuHMdWLt9EYp21YiMp7uEGWgjEO_VztbDOyvhr+RxkrAKRYYA@mail.gmail.com>
 <20171005093915.GP4037@w540>
 <20171005134339.GJ13247@lunn.ch>
 <20171005154239.GB19008@w540>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        Chris Brandt <Chris.Brandt@renesas.com>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: jacopo mondi <jacopo@jmondi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:40672 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751331AbdJEQsa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Oct 2017 12:48:30 -0400
Content-Disposition: inline
In-Reply-To: <20171005154239.GB19008@w540>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 05, 2017 at 05:42:39PM +0200, jacopo mondi wrote:
> Hi Andrew,
> 
> On Thu, Oct 05, 2017 at 03:43:39PM +0200, Andrew Lunn wrote:
> > On Thu, Oct 05, 2017 at 11:39:15AM +0200, jacopo mondi wrote:
> > > Hi Geert
> > >
> > > On Thu, Oct 05, 2017 at 11:09:40AM +0200, Geert Uytterhoeven wrote:
> > > > Hi Jacopo,
> > > >
> > > > On Thu, Oct 5, 2017 at 10:58 AM, Jacopo Mondi <jacopo+renesas@jmondi.org> wrote:
> > > > > Add pin configuration subnode for ETHER pin group and enable the interface.
> > > > >
> > > > > Signed-off-by: Jacopo Mondi <jacopo+renesas@jmondi.org>
> > > >
> > > > Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>
> > > >
> > > > > --- a/arch/arm/boot/dts/r7s72100-gr-peach.dts
> > > > > +++ b/arch/arm/boot/dts/r7s72100-gr-peach.dts
> > > >
> > > > > @@ -88,3 +110,19 @@
> > > > >
> > > > >         status = "okay";
> > > > >  };
> > > > > +
> > > > > +&ether {
> > > > > +       pinctrl-names = "default";
> > > > > +       pinctrl-0 = <&ether_pins>;
> > > > > +
> > > > > +       status = "okay";
> > > > > +
> > > > > +       reset-gpios = <&port4 2 GPIO_ACTIVE_LOW>;
> > > > > +       reset-delay-us = <5>;
> > > >
> > > > I'm afraid the PHY people (not CCed ;-) will want you to move these reset
> > > > properties to the phy subnode these days, despite
> > > > Documentation/devicetree/bindings/net/mdio.txt...
> >
> > Hi Jocopo
> >
> > So what is this reset resetting?
> >
> > The MAC?
> > The PHY?
> 
> The reset line goes from our SoC to LAN8710A PHY chip external reset pin.

So yes, this is a PHY property, and should be in the PHY node.

Documentation/devicetree/bindings/net/mdio.txt does not apply here
anyway. That is for an MDIO binding. This node is an ethernet MAC.

So your binding whats to look something like

        ether: ethernet@e8203000 {
                compatible = "renesas,ether-r7s72100";
                reg = <0xe8203000 0x800>,
                      <0xe8204800 0x200>;
                interrupts = <GIC_SPI 327 IRQ_TYPE_LEVEL_HIGH>;
                clocks = <&mstp7_clks R7S72100_CLK_ETHER>;
                power-domains = <&cpg_clocks>;
                phy-mode = "mii";
		phy-handle = <&phy0>;
                #address-cells = <1>;
                #size-cells = <0>;

                mdio: bus-bus {
                      #address-cells = <1>;
                      #size-cells = <0>;

                      phy0: ethernet-phy@1 {
                            reg = <1>;
                            reset-gpios = <&port4 2 GPIO_ACTIVE_LOW>;
                            reset-delay-us = <5>;
                      };
                };
        };

	Andrew
