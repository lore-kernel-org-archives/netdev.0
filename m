From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Tue, 22 Aug 2017 09:59:58 +0200
Message-ID: <20170822075958.GA20320@Red>
References: <20170818122118.4925-4-clabbe.montjoie@gmail.com>
 <CAGb2v66KcZkiDDHryMmVzm4WroXePPy3V44SLpVdoO3ZEjgC=g@mail.gmail.com>
 <20170819185025.GB13266@Red>
 <20170819203836.GA21567@lunn.ch>
 <20170820065757.GA6081@Red>
 <20170820142545.GB24150@lunn.ch>
 <CAGb2v67hQXSoCKP7qW+KRUYX+0djQ1Z23cQ67Lyg6G7ozGyfGQ@mail.gmail.com>
 <20170821132015.GB1703@lunn.ch>
 <20170821133104.qvrhvwin2rdg4aqo@flea.lan>
 <20170821142321.GE1703@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>,
        Chen-Yu Tsai <wens@csie.org>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        devicetree <devicetree@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170821142321.GE1703@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 04:23:21PM +0200, Andrew Lunn wrote:
> > All muxes are mostly always represented the same way afaik, or do you
> > want to simply introduce a new compatible / property?
> 
> +      	  mdio-mux {
> +		compatible = "allwinner,sun8i-h3-mdio-switch";
> +		mdio-parent-bus = <&mdio_parent>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +
> +		internal_mdio: mdio@1 {
> 			reg = <1>;
> -			clocks = <&ccu CLK_BUS_EPHY>;
> -			resets = <&ccu RST_BUS_EPHY>;
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			int_mii_phy: ethernet-phy@1 {
> +				compatible = "ethernet-phy-ieee802.3-c22";
> +				reg = <1>;
> +				clocks = <&ccu CLK_BUS_EPHY>;
> +				resets = <&ccu RST_BUS_EPHY>;
> +				phy-is-integrated;
> +			};
> +		};
> +		mdio: mdio@0 {
> +			reg = <0>;
> +			#address-cells = <1>;
> +			#size-cells = <0>;
>  		};
>  		
> Hi Maxim
> 
> Anybody who knows the MDIO-mux code/binding, knows that it is a run
> time mux. You swap the mux per MDIO transaction. You can access all
> the PHY and switches on the mux'ed MDIO bus.
> 
> However here, it is effectively a boot-time MUX. You cannot change it
> on the fly. What happens when somebody has a phandle to a PHY on the
> internal and a phandle to a phy on the external? Does the driver at
> least return -EINVAL, or -EBUSY? Is there a representation which
> eliminates this possibility?
> 

Exactly you can change it on the fly, but you need to reset the MAC for enabling the new configuration.
The stmmac driver does not handle mdio-mux. It is why I have a patch which automaticly select parent MDIO node of the PHY node.

For representation we could keep the current. (With a big comment stating that it is a switch)

We can also add a mdio-switch type node, or add a mdio-switch property to mdio-mux.

Regards
