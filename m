From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 2/4] net: phy: Initialize mdio clock at probe function
Date: Wed, 1 Feb 2017 14:08:14 -0800
Message-ID: <dbb296f0-5b48-6005-b9a3-fe148e5ce4e3@gmail.com>
References: <1484669670-4201-1-git-send-email-yendapally.reddy@broadcom.com>
 <1484669670-4201-3-git-send-email-yendapally.reddy@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Ray Jui <rjui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Scott Branden <sbranden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Jon Mason <jonmason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1484669670-4201-3-git-send-email-yendapally.reddy-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/17/2017 08:14 AM, Yendapally Reddy Dhananjaya Reddy wrote:
> Initialize mdio clock divisor in probe function. The ext bus
> bit available in the same register will be used by mdio mux
> to enable external mdio.
> 
> Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>

David, this patch should go through your tree (but we forgot to CC you),
patch in patchwork is here:

http://patchwork.ozlabs.org/patch/716281/

Thanks!

> ---
>  drivers/net/phy/mdio-bcm-iproc.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/phy/mdio-bcm-iproc.c b/drivers/net/phy/mdio-bcm-iproc.c
> index c0b4e65..46fe1ae 100644
> --- a/drivers/net/phy/mdio-bcm-iproc.c
> +++ b/drivers/net/phy/mdio-bcm-iproc.c
> @@ -81,8 +81,6 @@ static int iproc_mdio_read(struct mii_bus *bus, int phy_id, int reg)
>  	if (rc)
>  		return rc;
>  
> -	iproc_mdio_config_clk(priv->base);
> -
>  	/* Prepare the read operation */
>  	cmd = (MII_DATA_TA_VAL << MII_DATA_TA_SHIFT) |
>  		(reg << MII_DATA_RA_SHIFT) |
> @@ -112,8 +110,6 @@ static int iproc_mdio_write(struct mii_bus *bus, int phy_id,
>  	if (rc)
>  		return rc;
>  
> -	iproc_mdio_config_clk(priv->base);
> -
>  	/* Prepare the write operation */
>  	cmd = (MII_DATA_TA_VAL << MII_DATA_TA_SHIFT) |
>  		(reg << MII_DATA_RA_SHIFT) |
> @@ -163,6 +159,8 @@ static int iproc_mdio_probe(struct platform_device *pdev)
>  	bus->read = iproc_mdio_read;
>  	bus->write = iproc_mdio_write;
>  
> +	iproc_mdio_config_clk(priv->base);
> +
>  	rc = of_mdiobus_register(bus, pdev->dev.of_node);
>  	if (rc) {
>  		dev_err(&pdev->dev, "MDIO bus registration failed\n");
> 


-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
