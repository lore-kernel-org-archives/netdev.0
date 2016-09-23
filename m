From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V3 1/3] Documentation: devicetree: add qca8k binding
Date: Fri, 23 Sep 2016 10:23:24 -0500
Message-ID: <20160923152324.GA15847@rob-hp-laptop>
References: <1473949601-20674-1-git-send-email-john@phrozen.org>
 <1473949601-20674-2-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        qsdk-review-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1473949601-20674-2-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 15, 2016 at 04:26:39PM +0200, John Crispin wrote:
> Add device-tree binding for ar8xxx switch families.
> 
> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
> ---
> Changes in V2
> * fixup example to include phy nodes and corresponding phandles
> * add a note explaining why we need to phy nodes
> 
> Changes in V3
> * add note stating that the cpu port is always 0
> 
>  .../devicetree/bindings/net/dsa/qca8k.txt          |   89 ++++++++++++++++++++
>  1 file changed, 89 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/qca8k.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/dsa/qca8k.txt b/Documentation/devicetree/bindings/net/dsa/qca8k.txt
> new file mode 100644
> index 0000000..9c67ee4
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/dsa/qca8k.txt
> @@ -0,0 +1,89 @@
> +* Qualcomm Atheros QCA8xxx switch family
> +
> +Required properties:
> +
> +- compatible: should be "qca,qca8337"
> +- #size-cells: must be 0
> +- #address-cells: must be 1
> +
> +Subnodes:
> +
> +The integrated switch subnode should be specified according to the binding
> +described in dsa/dsa.txt. As the QCA8K switches do not have a N:N mapping of
> +port and PHY id, each subnode describing a port needs to have a valid phandle
> +referencing the internal PHY connected to it. The CPU port of this switch is
> +always port 0.
> +
> +Example:
> +
> +
> +	&mdio0 {
> +		phy_port1: phy@0 {
> +			reg = <0>;
> +		};
> +
> +		phy_port2: phy@1 {
> +			reg = <1>;
> +		};
> +
> +		phy_port3: phy@2 {
> +			reg = <2>;
> +		};
> +
> +		phy_port4: phy@3 {
> +			reg = <3>;
> +		};
> +
> +		phy_port5: phy@4 {
> +			reg = <4>;
> +		};
> +
> +		switch0@0 {

The unit address here is the mdio device address and should be unique. 
You have 2 devices at 0.

> +			compatible = "qca,qca8337";
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +
> +			reg = <0>;

Not documented.

> +
> +			ports {
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +				port@0 {
> +					reg = <0>;
> +					label = "cpu";
> +					ethernet = <&gmac1>;
> +					phy-mode = "rgmii";
> +				};
> +
> +				port@1 {
> +					reg = <1>;
> +					label = "lan1";
> +					phy-handle = <&phy_port1>;
> +				};
> +
> +				port@2 {
> +					reg = <2>;
> +					label = "lan2";
> +					phy-handle = <&phy_port2>;
> +				};
> +
> +				port@3 {
> +					reg = <3>;
> +					label = "lan3";
> +					phy-handle = <&phy_port3>;
> +				};
> +
> +				port@4 {
> +					reg = <4>;
> +					label = "lan4";
> +					phy-handle = <&phy_port4>;
> +				};
> +
> +				port@5 {
> +					reg = <5>;
> +					label = "wan";
> +					phy-handle = <&phy_port5>;
> +				};
> +			};
> +		};
> +	};
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
