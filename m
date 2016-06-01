From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v2 3/5] drivers: net: phy: Add MDIO driver
Date: Wed, 1 Jun 2016 03:11:48 +0200
Message-ID: <20160601011148.GD31982@lunn.ch>
References: <1464739840-21971-1-git-send-email-isubramanian@apm.com>
 <1464739840-21971-4-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	patches-qTEPVZfXA3Y@public.gmane.org, matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1464739840-21971-4-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2016 at 05:10:38PM -0700, Iyappan Subramanian wrote:
> +static int xgene_mdio_reset(struct xgene_mdio_pdata *pdata)
> +{
> +	int ret;
> +
> +	if (pdata->mdio_id == XGENE_MDIO_RGMII) {
> +		if (pdata->dev->of_node) {
> +			clk_prepare_enable(pdata->clk);
> +			clk_disable_unprepare(pdata->clk);
> +			clk_prepare_enable(pdata->clk);

Hi Iyappan

Is that a workaround for a hardware problem? If so, i would suggest
adding a comment, to stop people submitting a patch simplifying it.


> +static int xgene_mdio_probe(struct platform_device *pdev)
> +{
> +	struct device *dev = &pdev->dev;
> +	struct mii_bus *mdio_bus;
> +	const struct of_device_id *of_id;
> +	struct resource *res;
> +	struct xgene_mdio_pdata *pdata;
> +	void __iomem *csr_addr;
> +	int mdio_id = 0, ret = 0;
> +


> +	of_id = of_match_device(xgene_mdio_of_match, &pdev->dev);
> +	if (mdio_id == XGENE_MDIO_RGMII) {
> +		mdio_bus->read = xgene_mdio_rgmii_read;
> +		mdio_bus->write = xgene_mdio_rgmii_write;
> +	} else {
> +		mdio_bus->read = xgene_xfi_mdio_read;
> +		mdio_bus->write = xgene_xfi_mdio_write;
> +	}

> +static const struct of_device_id xgene_mdio_of_match[] = {
> +	{
> +		.compatible = "apm,xgene-mdio-rgmii",
> +		.data = (void *)XGENE_MDIO_RGMII
> +	},
> +	{
> +		.compatible = "apm,xgene-mdio-xfi",
> +		.data = (void *)XGENE_MDIO_XFI},
> +	{},
> +};


This all makes me think you should have two separate MDIO drivers, one
for each compatible string. There is not that much shared code.

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
