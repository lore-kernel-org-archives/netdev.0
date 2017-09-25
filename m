From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net v2 2/3] net: mvpp2: fix port list indexing
Date: Mon, 25 Sep 2017 15:09:44 +0200
Message-ID: <20170925130944.GF19364@kwain>
References: <20170925125948.13507-1-antoine.tenart@free-electrons.com>
 <20170925125948.13507-3-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Yan Markman <ymarkman@marvell.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org,
        Antoine Tenart <antoine.tenart@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170925125948.13507-3-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2017 at 02:59:47PM +0200, Antoine Tenart wrote:
> From: Yan Markman <ymarkman@marvell.com>
> 
> The private port_list array has a list of pointers to mvpp2_port
> instances. This list is allocated given the number of ports enabled in
> the device tree, but the pointers are set using the port-id property. If
> on a single port is enabled, the port_list array will be of size 1, but
> when registering the port, if its id is not 0 the driver will crash.
> Other crashes were encountered in various situations.
> 
> This fixes the issue by using an index not equal to the value of the
> port-id property.
> 
> Fixes: 3f518509dedc ("ethernet: Add new driver for Marvell Armada 375 network unit")

With,

Signed-off-by: Yan Markman <ymarkman@marvell.com>

I don't know why it was removed, but this SoB should be added back.

Antoine

> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvpp2.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index da04939a2748..b2f99df81e9c 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -7504,7 +7504,7 @@ static void mvpp2_port_copy_mac_addr(struct net_device *dev, struct mvpp2 *priv,
>  /* Ports initialization */
>  static int mvpp2_port_probe(struct platform_device *pdev,
>  			    struct device_node *port_node,
> -			    struct mvpp2 *priv)
> +			    struct mvpp2 *priv, int index)
>  {
>  	struct device_node *phy_node;
>  	struct phy *comphy;
> @@ -7678,7 +7678,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
>  	}
>  	netdev_info(dev, "Using %s mac address %pM\n", mac_from, dev->dev_addr);
>  
> -	priv->port_list[id] = port;
> +	priv->port_list[index] = port;
>  	return 0;
>  
>  err_free_port_pcpu:
> @@ -8013,10 +8013,12 @@ static int mvpp2_probe(struct platform_device *pdev)
>  	}
>  
>  	/* Initialize ports */
> +	i = 0;
>  	for_each_available_child_of_node(dn, port_node) {
> -		err = mvpp2_port_probe(pdev, port_node, priv);
> +		err = mvpp2_port_probe(pdev, port_node, priv, i);
>  		if (err < 0)
>  			goto err_mg_clk;
> +		i++;
>  	}
>  
>  	platform_set_drvdata(pdev, priv);
> -- 
> 2.13.5
> 

-- 
Antoine Ténart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
