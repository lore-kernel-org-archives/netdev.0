From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 04/10] i2c: i2c-sam: Add device tree bindings
Date: Mon, 10 Oct 2016 14:54:58 -0500
Message-ID: <20161010195458.GA20134@rob-hp-laptop>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
 <1475853518-22264-5-git-send-email-pantelis.antoniou@konsulko.com>
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
Return-path: <linux-i2c-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1475853518-22264-5-git-send-email-pantelis.antoniou@konsulko.com>
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 07, 2016 at 06:18:32PM +0300, Pantelis Antoniou wrote:
> From: Georgi Vlaev <gvlaev@juniper.net>
> 
> Add binding document for the i2c driver of SAM FPGA.
> 
> Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
> [Ported from Juniper kernel]
> Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
> ---
>  .../devicetree/bindings/i2c/i2c-sam-mux.txt        | 20 ++++++++++
>  Documentation/devicetree/bindings/i2c/i2c-sam.txt  | 44 ++++++++++++++++++++++
>  2 files changed, 64 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/i2c/i2c-sam-mux.txt
>  create mode 100644 Documentation/devicetree/bindings/i2c/i2c-sam.txt
> 
> diff --git a/Documentation/devicetree/bindings/i2c/i2c-sam-mux.txt b/Documentation/devicetree/bindings/i2c/i2c-sam-mux.txt
> new file mode 100644
> index 0000000..10ddffa
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/i2c/i2c-sam-mux.txt
> @@ -0,0 +1,20 @@
> +Juniper's SAM FPGA I2C accelerator mux
> +
> +The SAM FPGA I2C mux is present only on Juniper SAM FPGA PTX series
> +of routers.
> +
> +The definition of the i2c sam bus is located in the i2c-sam.txt document.
> +
> +Required properties:
> +- compatible: should be "jnx,i2c-sam-mux".
> +- reg: master number and mux number.

This is not how i2c muxes are done.

> +
> +Optional properties:
> +- speed: If present must be either 100000 or 400000. No other values supported.
> +
> +Examples:
> +
> +pe1i2c: i2c-sam-mux@1,0 {

i2c-mux@...

> +	compatible = "jnx,i2c-sam-mux";
> +	reg = <1 0>;
> +};
> diff --git a/Documentation/devicetree/bindings/i2c/i2c-sam.txt b/Documentation/devicetree/bindings/i2c/i2c-sam.txt
> new file mode 100644
> index 0000000..4830b48
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/i2c/i2c-sam.txt
> @@ -0,0 +1,44 @@
> +Juniper's SAM FPGA I2C accelerator
> +
> +The SAM FPGA accelerator is used to connect the large number of
> +I2C muxes that are present on Juniper PTX series of routers.
> +While it's an i2c bus, no other devices are located besides
> +i2c-sam-mux devices.
> +
> +The definition of the i2c sam mux is located in the i2c-sam-mux.txt document.
> +
> +Required properties:
> +- compatible: should be "jnx,i2c-sam".
> +- #address-cells: should be 2.
> +- #size-cells: should be 0.
> +- mux-channels: number of mux channels present

What is this needed for?

> +
> +Optional properties:
> +- reg: offset and length of the register set for the device are optional since
> +  typically the register range is provided by the parent SAM MFD device.
> +- master-offset: Offset of where the master register memory starts.
> +  Default value is 0x8000.

Make this required.

> +- reverse-fill: Fill the start entries of transactions in reverse order

Needs a better explanation.

> +- priority-tables: Use the pre-programmed priority tables in the FPGA

What does not present mean?

> +- i2c-options: list of options to be written to the option field in the
> +  FPGA controlling things like SCL push-pull drives, hold-times, etc.

> +- bus-range: start of bus master range and number of masters.

Needs a better explanation.

> +
> +Examples:
> +
> +i2c-sam {
> +	compatible = "jnx,i2c-sam";
> +	mux-channels = <2>;
> +	#size-cells = <0>;
> +	#address-cells = <2>;
> +
> +	/* PE0 */ pe0i2c: i2c-sam-mux@0,0 {

i2c-mux@...

> +		compatible = "jnx,i2c-sam-mux";
> +		reg = <0 0>;
> +	};
> +
> +	/* PE1 */ pe1i2c: i2c-sam-mux@1,0 {
> +		compatible = "jnx,i2c-sam-mux";
> +		reg = <1 0>;
> +	};
> +};
> -- 
> 1.9.1
> 
