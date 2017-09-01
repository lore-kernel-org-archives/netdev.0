From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v4 4/5] net: stmmac: dwmac-sun8i: choose internal PHY via phy-is-integrated
Date: Fri, 1 Sep 2017 09:04:46 -0500
Message-ID: <CAL_JsqJMZG-X7erY_87mS7N+RfPLdL2VPBaAMBhVYxNCGhbrrA@mail.gmail.com>
References: <20170826073311.25612-1-clabbe.montjoie@gmail.com>
 <20170826073311.25612-5-clabbe.montjoie@gmail.com> <20170826212051.GA10418@lunn.ch>
 <20170831201803.x6vwftfcllrfpk6q@rob-hp-laptop> <20170831205928.GS22289@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Chen-Yu Tsai <wens@csie.org>,
        Russell King <linux@armlinux.org.uk>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Icenowy Zheng <icenowy@aosc.io>,
        netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831205928.GS22289@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2017 at 3:59 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Thu, Aug 31, 2017 at 03:18:03PM -0500, Rob Herring wrote:
>> On Sat, Aug 26, 2017 at 11:20:51PM +0200, Andrew Lunn wrote:
>> > Hi Corentin
>> >
>> > I think we have now all agreed this is an mdio-mux, plus it is also an
>> > MII mux. We should represent that in device tree. This patchset does
>> > this. However, as it is now, the mux structure in DT is ignored. All
>> > it does is search for the phy-is-integrated flags and goes on that.
>> >
>> > I made the comment that the device tree representation cannot be
>> > implemented using an MDIO mux driver, because of driver loading
>> > issues.  However, the core of the MDIO mux code is just a library,
>> > symbols exported as GPL, free for anything to use.
>> >
>> > What i think should happen is the mdio-mux is implemented inside the
>> > MAC driver, using the mux-core as a library. The device tree structure
>> > of a mix is then reflected within Linux. The mux switch callback is
>> > implemented within the MAC driver. So it can reset the MAC when the
>> > mux is switched. The 'phy-is-integrated' property is then no longer
>> > needed.
>> >
>> > I would suggest a binding something like:
>>
>> This is looks better to me, but...
>>
>> > emac: ethernet@1c0b000 {
>> >         compatible = "allwinner,sun8i-h3-emac";
>> >         syscon = <&syscon>;
>> >         reg = <0x01c0b000 0x104>;
>> >         interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
>> >         interrupt-names = "macirq";
>> >         resets = <&ccu RST_BUS_EMAC>;
>> >         reset-names = "stmmaceth";
>> >         clocks = <&ccu CLK_BUS_EMAC>;
>> >         clock-names = "stmmaceth";
>> >         #address-cells = <1>;
>> >         #size-cells = <0>;
>> >
>> >         phy-handle = <&int_mii_phy>;
>> >         phy-mode = "mii";
>> >         allwinner,leds-active-low;
>> >
>> >         mdio: mdio {
>> >                 #address-cells = <1>;
>> >                 #size-cells = <0>;
>> >     }
>>
>> Why do you need this node still?
>
> Hi Rob
>
> It might not be needed, depending on how it is implemented. But:
>
> Documentation/devicetree/bindings/net/mdio-mux.txt
>
> It is normal for an mdio bus mux to have a phandle back to the parent
> mdio bus.  Also, i think the stmmac driver will only instantiate the
> mdio bus if there is a node for it in the device tree.

You don't have a phandle to the parent mdio bus though.

I think we should allow for both case. The mux could be within the bus
hierarchy. Depends where the controls are. Another alternative someone
will try sooner or later is using the new mux control binding.

Rob
