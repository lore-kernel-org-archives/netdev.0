From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] net: ixp4xx_eth: Return proper error for eth_init_one
Date: Wed, 05 Jan 2011 18:43:22 +0100
Message-ID: <m3bp3vi6v9.fsf@intrepid.localdomain>
References: <1294205046.8294.2.camel@mola>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Axel Lin <axel.lin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294205046.8294.2.camel@mola> (Axel Lin's message of "Wed, 05
	Jan 2011 13:24:06 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Axel Lin <axel.lin@gmail.com> writes:

> Return PTR_ERR(port->phydev) instead of 1 if phy_connect failed.
>
> Signed-off-by: Axel Lin <axel.lin@gmail.com>

> --- a/drivers/net/arm/ixp4xx_eth.c
> +++ b/drivers/net/arm/ixp4xx_eth.c
> @@ -1229,8 +1229,10 @@ static int __devinit eth_init_one(struct platform_device *pdev)
>  	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, "0", plat->phy);
>  	port->phydev = phy_connect(dev, phy_id, &ixp4xx_adjust_link, 0,
>  				   PHY_INTERFACE_MODE_MII);
> -	if ((err = IS_ERR(port->phydev)))
> +	if (IS_ERR(port->phydev)) {
> +		err = PTR_ERR(port->phydev);
>  		goto err_free_mem;
> +	}
>  
>  	port->phydev->irq = PHY_POLL;

Right. Thanks.

Acked-by: Krzysztof Halasa <khc@pm.waw.pl>
-- 
Krzysztof Halasa
