From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v5 05/10] dt-bindings: net: dwmac-sun8i: update
 documentation about integrated PHY
Date: Wed, 20 Sep 2017 20:23:50 +0200
Message-ID: <20170920182350.GA21482@Red>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-6-clabbe.montjoie@gmail.com>
 <20170908072538.rqsp6dobwsqmzrsr@flea.lan>
 <20170908074325.GB29999@Red>
 <20170913182004.uniyo5opeilcfk7r@rob-hp-laptop>
 <20170914185301.GB4021@Red>
 <20170914191949.GA3796@lunn.ch>
 <CAL_JsqJ2eVA9Zg60Hagqm732ZoOzHWTwVBqOabOhjE5aQ26L+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Chen-Yu Tsai <wens@csie.org>, netdev <netdev@vger.kernel.org>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAL_JsqJ2eVA9Zg60Hagqm732ZoOzHWTwVBqOabOhjE5aQ26L+g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 19, 2017 at 09:49:52PM -0500, Rob Herring wrote:
> On Thu, Sep 14, 2017 at 2:19 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> >> > Is the MDIO controller "allwinner,sun8i-h3-emac" or "snps,dwmac-mdio"?
> >> > If the latter, then I think the node is fine, but then the mux should be
> >> > a child node of it. IOW, the child of an MDIO controller should either
> >> > be a mux node or slave devices.
> >
> > Hi Rob
> >
> > Up until now, children of an MDIO bus have been MDIO devices. Those
> > MDIO devices are either Ethernet PHYs, Ethernet Switches, or the
> > oddball devices that Broadcom iProc has, like generic PHYs.
> >
> > We have never had MDIO-muxes as MDIO children. A Mux is not an MDIO
> > device, and does not have the properties of an MDIO device. It is not
> > addressable on the MDIO bus. The current MUXes are addressed via GPIOs
> > or MMIO.
> 
> The DT parent/child relationship defines the bus topology. We describe
> MDIO buses in that way and if a mux is sitting between the controller
> and the devices, then the DT hierarchy should reflect that. Now
> sometimes we have 2 options for what interface has the parent/child
> relationship (e.g. an I2C controlled USB hub chip), but in this case
> we don't.
> 

Putting mdio-mux as a child of it (the mdio node) give me:
[   18.175338] libphy: stmmac: probed
[   18.175379] mdio_bus stmmac-0: /soc/ethernet@1c30000/mdio/mdio-mux has invalid PHY address
[   18.175408] mdio_bus stmmac-0: scan phy mdio-mux at address 0
[   18.175450] mdio_bus stmmac-0: scan phy mdio-mux at address 1
[   18.175482] mdio_bus stmmac-0: scan phy mdio-mux at address 2
[   18.175513] mdio_bus stmmac-0: scan phy mdio-mux at address 3
[   18.175544] mdio_bus stmmac-0: scan phy mdio-mux at address 4
[   18.175575] mdio_bus stmmac-0: scan phy mdio-mux at address 5
[   18.175607] mdio_bus stmmac-0: scan phy mdio-mux at address 6
[   18.175638] mdio_bus stmmac-0: scan phy mdio-mux at address 7
[   18.175669] mdio_bus stmmac-0: scan phy mdio-mux at address 8
[   18.175700] mdio_bus stmmac-0: scan phy mdio-mux at address 9
[   18.175731] mdio_bus stmmac-0: scan phy mdio-mux at address 10
[   18.175762] mdio_bus stmmac-0: scan phy mdio-mux at address 11
[   18.175795] mdio_bus stmmac-0: scan phy mdio-mux at address 12
[   18.175827] mdio_bus stmmac-0: scan phy mdio-mux at address 13
[   18.175858] mdio_bus stmmac-0: scan phy mdio-mux at address 14
[   18.175889] mdio_bus stmmac-0: scan phy mdio-mux at address 15
[   18.175919] mdio_bus stmmac-0: scan phy mdio-mux at address 16
[   18.175951] mdio_bus stmmac-0: scan phy mdio-mux at address 17
[   18.175982] mdio_bus stmmac-0: scan phy mdio-mux at address 18
[   18.176014] mdio_bus stmmac-0: scan phy mdio-mux at address 19
[   18.176045] mdio_bus stmmac-0: scan phy mdio-mux at address 20
[   18.176076] mdio_bus stmmac-0: scan phy mdio-mux at address 21
[   18.176107] mdio_bus stmmac-0: scan phy mdio-mux at address 22
[   18.176139] mdio_bus stmmac-0: scan phy mdio-mux at address 23
[   18.176170] mdio_bus stmmac-0: scan phy mdio-mux at address 24
[   18.176202] mdio_bus stmmac-0: scan phy mdio-mux at address 25
[   18.176233] mdio_bus stmmac-0: scan phy mdio-mux at address 26
[   18.176271] mdio_bus stmmac-0: scan phy mdio-mux at address 27
[   18.176320] mdio_bus stmmac-0: scan phy mdio-mux at address 28
[   18.176371] mdio_bus stmmac-0: scan phy mdio-mux at address 29
[   18.176420] mdio_bus stmmac-0: scan phy mdio-mux at address 30
[   18.176452] mdio_bus stmmac-0: scan phy mdio-mux at address 31

Adding a fake <reg> to mdio-mux remove it, but I found that a bit ugly.
Or perhaps patching of_mdiobus_register() to not scan node with compatible "mdio-mux".

What do you think ?

Regards
