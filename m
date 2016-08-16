From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: macb: add phy-handle support for the macb
Date: Tue, 16 Aug 2016 22:14:36 +0200
Message-ID: <20160816201436.GB3751@lunn.ch>
References: <1471082509-11764-1-git-send-email-appanad@xilinx.com>
 <20160813.115222.443333178659469072.davem@davemloft.net>
 <C246CAC1457055469EF09E3A7AC4E11A4A5E27C6@XAP-PVEXMBX01.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
	"sergio.prado@e-labworks.com" <sergio.prado@e-labworks.com>,
	"gregory.clement@free-electrons.com"
	<gregory.clement@free-electrons.com>,
	"narmstrong@baylibre.com" <narmstrong@baylibre.com>,
	Michal Simek <michals@xilinx.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C246CAC1457055469EF09E3A7AC4E11A4A5E27C6@XAP-PVEXMBX01.xlnx.xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Agree with you my intention is if there is a MDIO bus on the device-tree
> The MAC driver should create PHY/MDIO devices using of_mdiobus_register().

What you suggest is better, and is similar to what other drivers use.

In order to keep backwards compatibility with phy nodes in the MAC
node, you have to do of_mdiobus_register() with the MAC node. However,
please change the binding documentation to say this is deprecated, all
phy nodes should be placed inside an mdio node.

Using some better variable names would also help. mac_np and mdio_np
for example.

    Andrew

> 
> How about below code...
> 
> -       struct device_node *np;
> +       struct device_node *np, *np1;
>         int err = -ENXIO, i;
>  
>         /* Enable management port */
> @@ -445,7 +445,14 @@ static int macb_mii_init(struct macb *bp)
>         dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
>  
>         np = bp->pdev->dev.of_node;
> -       if (np) {
> +       np1 = of_get_child_by_name(np, "mdio");
> +       if (np1) {
> +               of_node_put(np1);
> +               err = of_mdiobus_register(bp->mii_bus, np1);
> +               if (err)
> +                       goto err_out_unregister_bus;
> +       } else if (np) {
>                 /* try dt phy registration */
>                 err = of_mdiobus_register(bp->mii_bus, np);
> 
> If you are ok with the above code please let me know will post it as v2...
> 
> Regards,
> Kedar.
