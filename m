From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Wed, 31 Aug 2016 17:24:02 +0200
Message-ID: <20160831152402.GH15078@lunn.ch>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
 <20160831150043.GA575@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        sdharia@codeaurora.org, shankerd@codeaurora.org,
        vikrams@codeaurora.org, cov@codeaurora.org, gavidov@codeaurora.org,
        bjorn.andersson@linaro.org, mlangsdo@redhat.com, jcm@redhat.com,
        agross@codeaurora.org, davem@davemloft.net, f.fainelli@gmail.com,
        LinoSanfilippo@gmx.de
To: Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160831150043.GA575@rob-hp-laptop>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +soc {
> > +	#address-cells = <1>;
> > +	#size-cells = <1>;
> > +
> > +	emac0: ethernet@feb20000 {
> > +		compatible = "qcom,fsm9900-emac";
> > +		reg = <0xfeb20000 0x10000>,
> > +		      <0xfeb36000 0x1000>;
> > +		interrupts = <76>;
> > +
> > +		clocks = <&gcc 0>, <&gcc 1>, <&gcc 3>, <&gcc 4>, <&gcc 5>,
> > +			<&gcc 6>, <&gcc 7>;
> > +		clock-names = "axi_clk", "cfg_ahb_clk", "high_speed_clk",
> > +			"mdio_clk", "tx_clk", "rx_clk", "sys_clk";
> > +
> > +		internal-phy = <&emac_sgmii>;
> 
> Can't this use the standard generic phy binding (i.e. 'phys'). It's a 
> bit confusing as there's the ethernet phy binding (phy-handle) and the 
> generic one. 

Hi Rob

An ethernet PHY is much more complex than a generic PHY. The generic
phy API basically allows you to turn on/off or power up/down. An
Ethernet phy you can find out if there is anybody on the other end,
what speed is being used, set parameters used to negotiate what speed
to use, turn power saving features on off, find out if the other end
has power saving features, change the signal delays between the MAC
and the PHY, configure and handle interrupts when something changes,
configure WoL, etc.

If generic PHYs would of come first, things might be different, but
given that Ethernet PHYs are much much older and well entrenched into
device tree bindings, i don't see them merging.

> > +
> > +		phy-handle = <&phy0>;
> 
> This is bit redundant as the phy is the child node.

The Internal PHY is a child node. However, there is no reason an
external phy is a child. You sometimes see it connected to another
devices MDIO bus.

> I guess if you had multiple devices on the mdio bus you would need
> it.

And this is where people make errors. They hard code in the driver
that it should use the first phy on the bus. Then some hardware
engineer comes along and adds a second phy to the bus, and it
breaks. It is more robust to explicitly indicate which PHY is
connected to this MAC.

> > +		#address-cells = <1>;
> > +		#size-cells = <0>;
> > +		phy0: ethernet-phy@0 {
> 
> It's just an example, but don't we require compatible strings for phys 
> now?

We have never required compatibility strings for Ethernet PHYs. And
due to the stable binding rules, we now never can. The binding
documentation says it may contain compatible strings.

	      Andrew
