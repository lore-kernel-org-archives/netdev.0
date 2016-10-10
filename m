From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 02/10] mfd: sam: Add documentation for the SAM FPGA
Date: Mon, 10 Oct 2016 14:47:55 -0500
Message-ID: <20161010194755.GA16910@rob-hp-laptop>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
 <1475853518-22264-3-git-send-email-pantelis.antoniou@konsulko.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lee Jones <lee.jones@linaro.org>,
        Linus Walleij <linus.walleij@linaro.org>,
        Alexandre Courbot <gnurou@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Frank Rowand <frowand.list@gmail.com>,
        Wolfram Sang <wsa@the-dreams.de>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Wim Van Sebroeck <wim@iguana.be>,
        Peter Rosin <peda@axentia.se>,
        Debjit Ghosh <dghosh@juniper.net>,
        Georgi Vlaev <gvlaev@juniper.net>,
        Guenter Roeck <linux@roeck-us.net>,
        Maryam Seraj <mseraj@juniper.net>, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-gpio@vger.kernel.org,
        linux-i2c@vger.kernel.org, linux-mtd@lists.infradead.org,
        linux-watchdog@vger.kernel.org, netdev@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1475853518-22264-3-git-send-email-pantelis.antoniou@konsulko.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 07, 2016 at 06:18:30PM +0300, Pantelis Antoniou wrote:
> From: Georgi Vlaev <gvlaev@juniper.net>
> 
> Add DT bindings document for the SAM MFD device.
> 
> Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
> [Ported from Juniper kernel]
> Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
> ---
>  Documentation/devicetree/bindings/mfd/jnx-sam.txt | 94 +++++++++++++++++++++++
>  1 file changed, 94 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/mfd/jnx-sam.txt
> 
> diff --git a/Documentation/devicetree/bindings/mfd/jnx-sam.txt b/Documentation/devicetree/bindings/mfd/jnx-sam.txt
> new file mode 100644
> index 0000000..b4af7ea
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/mfd/jnx-sam.txt
> @@ -0,0 +1,94 @@
> +Device-Tree bindings for Juniper Networks SAM MFD
> +
> +Required properties:
> +
> +- compatible - Must be: "jnx,sam"

Kind of generic. Only 1 FPGA version or some other way to tell the 
version?

> +
> +Optional properties:
> +
> +- pma-coefficients: A set of tupples containing the configuration of the PMA.

What's a PMA? What type of configuration? How many entries?

> +Device                   Description
> +------                   -----------
> +jnx,i2c-sam		: I2C mux driver
> +jnx,gpio-sam		: GPIO block
> +jnx,flash-sam		: MTD Flash
> +jnx,mdio-sam		: MDIO interfaces
> +
> +All these optional nodes are described in their respective binding
> +documents.
> +
> +Example node:
> +
> +pci-0000-10-00.0 {

What are the numbers?

> +	compatible = "jnx,sam";

If this is a PCI device, then it should use PCI compatible string 
syntax.

> +	#address-cells = <1>;
> +	#size-cells = <0>;
> +	pma-coefficients = <4 0x0>;
> +
> +	i2c-sam@10 {
> +		compatible = "jnx,i2c-sam";
> +		mux-channels = <2>;
> +		master-offset = <0x10000>;
> +	};
> +
> +	gpiogpqam0: gpio-sam@10 {

gpio@...

Where does 10 come from?

> +		compatible = "jnx,gpio-sam";
> +		gpio-controller;
> +		#gpio-cells = <2>;
> +		gpio-count = <297>;
> +		interrupt-controller;
> +		/*
> +		* 1st cell: gpio interrupt status bit
> +		* 2nd cell: 1st pin
> +		* 3rd cell: # of pins
> +		*/
> +		gpio-interrupts =
> +			<0 0 12>,   /* phy_int_monitor_en [16] */
> +			<1 235 24>, /* qsfpp_fpga_int_monitor [17] */
> +			<2 259 24>, /* qsfpp_fpga_modprs_monitor [18] */
> +			<3 295 1>,  /* si5345_fpga_monitor [19] */
> +			<4 294 1>;  /* fpc_pic_int_monitor [20] */
> +	};
> +
> +	flash-sam@10 {
> +		compatible = "jnx,flash-sam";
> +		#address-cells = <1>;
> +		#size-cells = <1>;
> +		partition@0 {
> +		reg = <0x0 0x400000>;
> +			label = "pic0-golden";
> +			read-only;
> +		};
> +		partition@400000 {
> +			reg = <0x400000 0x400000>;
> +			label = "pic0-user";
> +		};
> +	};
> +
> +	mdio-sam@10 {
> +		compatible = "jnx,mdio-sam";
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		reg = <0x40000>;
> +
> +		/* mii_bus types */
> +		mdio0: mdio-sam@0 {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			reg = <0x0>;
> +		};
> +
> +		mdio1: mdio-sam@4000 {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			reg = <0x4000>;
> +		};
> +
> +		mdio2: mdio-sam@8000 {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			reg = <0x8000>;
> +		};
> +	};
> +};
> -- 
> 1.9.1
> 
