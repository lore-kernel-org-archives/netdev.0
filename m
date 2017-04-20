From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] mdio_bus: Issue GPIO RESET to PHYs.
Date: Thu, 20 Apr 2017 15:13:05 +0200
Message-ID: <20170420131305.GB6152@lunn.ch>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <64d6494d-41d2-0faf-a434-057f796637fe@ti.com>
 <daa29a99-0a17-d316-57eb-3e6162938d8d@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
        tony@atomide.com, nsekhar@ti.com, jsarha@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <daa29a99-0a17-d316-57eb-3e6162938d8d@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2017 at 11:39:20AM +0300, Roger Quadros wrote:
> Some boards [1] leave the PHYs at an invalid state
> during system power-up or reset thus causing unreliability
> issues with the PHY which manifests as PHY not being detected
> or link not functional. To fix this, these PHYs need to be RESET
> via a GPIO connected to the PHY's RESET pin.
> 
> Some boards have a single GPIO controlling the PHY RESET pin of all
> PHYs on the bus whereas some others have separate GPIOs controlling
> individual PHY RESETs.
> 
> In both cases, the RESET de-assertion cannot be done in the PHY driver
> as the PHY will not probe till its reset is de-asserted.
> So do the RESET de-assertion in the MDIO bus driver.

Hi Roger

Networking patches should include in the subject line which tree they
are for. In this case, net-next. So please make the Subject

[patch v3 net-next] .....

> [1] - am572x-idk, am571x-idk, a437x-idk
> 
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
> v2:
> - add device tree binding document (mdio.txt)
> - specify default reset delay in of_mdio.c instead of mdio_bus.c
> 
>  Documentation/devicetree/bindings/net/mdio.txt | 20 ++++++++++++++++++++
>  drivers/net/phy/mdio_bus.c                     | 22 ++++++++++++++++++++++
>  drivers/of/of_mdio.c                           |  7 +++++++
>  include/linux/phy.h                            |  5 +++++
>  4 files changed, 54 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/mdio.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/mdio.txt b/Documentation/devicetree/bindings/net/mdio.txt
> new file mode 100644
> index 0000000..6e703d7
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/mdio.txt
> @@ -0,0 +1,20 @@
> +Common MDIO bus properties.
> +
> +These are generic properties that can apply to any MDIO bus.
> +
> +Optional properties:
> +- reset-gpios: List of one or more GPIOs that control the RESET lines
> +  of the PHYs on that MDIO bus.
> +- reset-delay-us: RESET pulse width as per PHY datasheet.

It would be good to explicitly say that it is in uS as part of the
comment.

Also, please document that we expect a list of child nodes, one per
device on the bus. These should follow the generic phy.txt, or a
device specific binding document.

> +
> +Example :
> +

It would be good to say something like:

This example shows these optional properties, plus other properties
required for the TI Davinci MDIO driver.

Pointing this out may stop people cut/past the ti,hwmods property.

> +	davinci_mdio: ethernet@0x5c030000 {
> +		compatible = "ti,davinci_mdio";
> +		ti,hwmods = "davinci_mdio";
> +		reg = <0x5c030000 0x1000>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		reset-gpios = <&gpio2 5 GPIO_ACTIVE_LOW>;
> +		reset-delay-us = <2>;   /* PHY datasheet states 1uS min */
> +	};

And please include at least one PHY on the bus.

Sorry for asking for so much in the documentation. That is the problem
with the documentation being missing to start with.

The code looks good now.

    Andrew
