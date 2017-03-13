From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 2/2] ARM: dts: am335x-icev2: Add CPSW ethernet0 and
 ethernet1
Date: Mon, 13 Mar 2017 14:24:21 -0500
Message-ID: <51a2471f-dace-6d8b-b198-9bd5efe41387@ti.com>
References: <1489412554-2054-1-git-send-email-rogerq@ti.com>
 <1489412554-2054-3-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <nsekhar@ti.com>, <jsarha@ti.com>, <linux-omap@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Roger Quadros <rogerq@ti.com>, <davem@davemloft.net>,
        <tony@atomide.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489412554-2054-3-git-send-email-rogerq@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03/13/2017 08:42 AM, Roger Quadros wrote:
> Enable the 2 ethernet ports as CPSW ports in dual-mac mode
>
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> [nsekhar@ti.com: use AM33XX_IOPAD()]
> Signed-off-by: Sekhar Nori <nsekhar@ti.com>
> ---
>  arch/arm/boot/dts/am335x-icev2.dts | 113 +++++++++++++++++++++++++++++++++++++
>  1 file changed, 113 insertions(+)
>
> diff --git a/arch/arm/boot/dts/am335x-icev2.dts b/arch/arm/boot/dts/am335x-icev2.dts
> index a2ad076..cc343b0 100644
> --- a/arch/arm/boot/dts/am335x-icev2.dts
> +++ b/arch/arm/boot/dts/am335x-icev2.dts
> @@ -201,6 +201,69 @@
>  			AM33XX_IOPAD(0x938, PIN_OUTPUT_PULLUP | MUX_MODE1) /* (L16) gmii1_rxd2.uart3_txd */
>  		>;
>  	};
> +

>
>  &i2c0 {
> @@ -350,3 +413,53 @@
>  	pinctrl-0 = <&uart3_pins_default>;
>  	status = "okay";
>  };
> +
> +&gpio3 {
> +	p4 {
> +		gpio-hog;
> +		gpios = <4 GPIO_ACTIVE_HIGH>;
> +		output-high;
> +		line-name = "PR1_MII_CTRL";
> +	};
> +
> +	p10 {
> +		gpio-hog;
> +		gpios = <10 GPIO_ACTIVE_HIGH>;
> +		/* ETH1 mux: Low for MII-PRU, high for RMII-CPSW */
> +		output-high;
> +		line-name = "MUX_MII_CTL1";
> +	};
> +};
> +
> +&cpsw_emac0 {
> +	phy_id = <&davinci_mdio>, <1>;

this is deprecated definition.
pls, use phy-handle.

> +	phy-mode = "rmii";
> +	dual_emac_res_vlan = <1>;
> +};
> +
> +&cpsw_emac1 {
> +	phy_id = <&davinci_mdio>, <3>;

same

> +	phy-mode = "rmii";
> +	dual_emac_res_vlan = <2>;
> +};
> +
> +&mac {
> +	pinctrl-names = "default", "sleep";
> +	pinctrl-0 = <&cpsw_default>;
> +	pinctrl-1 = <&cpsw_sleep>;
> +	status = "okay";
> +	dual_emac;
> +};
> +
> +&phy_sel {
> +	rmii-clock-ext;
> +};
> +
> +&davinci_mdio {
> +	pinctrl-names = "default", "sleep";
> +	pinctrl-0 = <&davinci_mdio_default>;
> +	pinctrl-1 = <&davinci_mdio_sleep>;
> +	status = "okay";
> +	reset-gpios = <&gpio2 5 GPIO_ACTIVE_LOW>;
> +	reset-delay-us = <2>;   /* PHY datasheet states 1uS min */
> +};
>

-- 
regards,
-grygorii
