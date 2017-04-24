From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] ARM: dts: Add the ethernet and ethernet PHY to the
 cygnus core DT.
Date: Mon, 24 Apr 2017 14:54:04 -0700
Message-ID: <1759fb29-0678-0ec5-5398-16c4a3ba9660@gmail.com>
References: <20170424215022.30382-1-eric@anholt.net>
 <20170424215022.30382-3-eric@anholt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Ray Jui <rjui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Scott Branden <sbranden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Jon Mason <jonmason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170424215022.30382-3-eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/24/2017 02:50 PM, Eric Anholt wrote:
> Cygnus has a single amac controller connected to the B53 switch with 2
> PHYs.  On the BCM911360_EP platform, those two PHYs are connected to
> the external ethernet jacks.
> 
> Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

This looks fine, just a few nits on the label names:

> ---
>  arch/arm/boot/dts/bcm-cygnus.dtsi      | 60 ++++++++++++++++++++++++++++++++++
>  arch/arm/boot/dts/bcm911360_entphn.dts |  8 +++++
>  2 files changed, 68 insertions(+)
> 
> diff --git a/arch/arm/boot/dts/bcm-cygnus.dtsi b/arch/arm/boot/dts/bcm-cygnus.dtsi
> index 009f1346b817..318899df9972 100644
> --- a/arch/arm/boot/dts/bcm-cygnus.dtsi
> +++ b/arch/arm/boot/dts/bcm-cygnus.dtsi
> @@ -142,6 +142,56 @@
>  			interrupts = <0>;
>  		};
>  
> +		mdio: mdio@18002000 {
> +			compatible = "brcm,iproc-mdio";
> +			reg = <0x18002000 0x8>;
> +			#size-cells = <1>;
> +			#address-cells = <0>;
> +
> +			gphy0: eth-gphy@0 {
> +				reg = <0>;
> +				max-speed = <1000>;
> +			};
> +
> +			gphy1: eth-gphy@1 {
> +				reg = <1>;
> +				max-speed = <1000>;
> +			};
> +		};
> +
> +		dsa: dsa@18007000 {

This would be better named switch: switch@18007000

> +			compatible = "brcm,bcm11360-srab", "brcm,cygnus-srab";
> +			reg = <0x18007000 0x1000>;
> +			status = "disabled";
> +
> +			ports {
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +
> +				port0@0 {

You can probably just put port@0

> +					reg = <0>;
> +					phy-handle = <&gphy0>;
> +					phy-mode = "rgmii";
> +				};
> +
> +				port1@1 {

And so on

> +					reg = <1>;
> +					phy-handle = <&gphy1>;
> +					phy-mode = "rgmii";
> +				};
> +
> +				port8@8 {

And so forth

> +					reg = <8>;
> +					label = "cpu";
> +					ethernet = <&eth0>;
> +					fixed-link {
> +						speed = <1000>;
> +						full-duplex;
> +					};
> +				};
> +			};
> +		};
> +
>  		i2c0: i2c@18008000 {
>  			compatible = "brcm,cygnus-iproc-i2c", "brcm,iproc-i2c";
>  			reg = <0x18008000 0x100>;
> @@ -295,6 +345,16 @@
>  			status = "disabled";
>  		};
>  
> +		eth0: enet@18042000 {
> +			compatible = "brcm,amac";
> +			reg = <0x18042000 0x1000>,
> +			      <0x18110000 0x1000>;
> +			reg-names = "amac_base", "idm_base";
> +			interrupts = <GIC_SPI 110 IRQ_TYPE_LEVEL_HIGH>;
> +			max-speed = <1000>;
> +			status = "disabled";
> +		};
> +
>  		nand: nand@18046000 {
>  			compatible = "brcm,nand-iproc", "brcm,brcmnand-v6.1";
>  			reg = <0x18046000 0x600>, <0xf8105408 0x600>,
> diff --git a/arch/arm/boot/dts/bcm911360_entphn.dts b/arch/arm/boot/dts/bcm911360_entphn.dts
> index 8b3800f46288..2a1f54ab3574 100644
> --- a/arch/arm/boot/dts/bcm911360_entphn.dts
> +++ b/arch/arm/boot/dts/bcm911360_entphn.dts
> @@ -57,6 +57,14 @@
>  	};
>  };
>  
> +&dsa {
> +	status = "okay";
> +};

And that would be &switch here then.

With that fixed:

Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> +
> +&eth0 {
> +	status = "okay";
> +};
> +
>  &uart3 {
>  	status = "okay";
>  };
> 


-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
