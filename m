From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/4] net: mvneta: mmc: get optional axi clk
Date: Wed, 20 Jan 2016 10:31:18 +0100
Message-ID: <1525e5fba70.2764.107cef0f820c2f5d7b7f41463071c310@gmail.com>
References: <1453277183-5412-1-git-send-email-jszhang@marvell.com>
 <1453277183-5412-4-git-send-email-jszhang@marvell.com>
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Jisheng Zhang <jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	<thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1453277183-5412-4-git-send-email-jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On January 20, 2016 9:15:22 AM Jisheng Zhang <jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org> wrote:

> Some platforms may provide more than one clk for the mvneta IP, for
> example Marvell BG4CT provides "core" clk for the mac core, and
> "axi" clk for the AXI bus logic. Obviously this "axi" clk also need to
> be enabled. This patch adds this optional "axi" clk support.

Jisheng,

although I do not expect mvneta to appear on a non-AXI bus
anytime soon, how about naming the clock "bus" instead?

If you know the clock is only required for bus master DMA but
not for register access, "dma" would be an even better name.

Sebastian


> Signed-off-by: Jisheng Zhang <jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c 
> b/drivers/net/ethernet/marvell/mvneta.c
> index aca0a73..6bb709a 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -373,6 +373,8 @@ struct mvneta_port {
>
>  	/* Core clock */
>  	struct clk *clk;
> +	/* AXI clock */
> +	struct clk *clk_axi;
>  	u8 mcast_count[256];
>  	u16 tx_ring_size;
>  	u16 rx_ring_size;
> @@ -3615,6 +3617,10 @@ static int mvneta_probe(struct platform_device *pdev)
>
>  	clk_prepare_enable(pp->clk);
>
> +	pp->clk_axi = devm_clk_get(&pdev->dev, "axi");
> +	if (!IS_ERR(pp->clk_axi))
> +		clk_prepare_enable(pp->clk_axi);
> +
>  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	pp->base = devm_ioremap_resource(&pdev->dev, res);
>  	if (IS_ERR(pp->base)) {
> @@ -3727,6 +3733,7 @@ err_free_ports:
>  	free_percpu(pp->ports);
>  err_clk:
>  	clk_disable_unprepare(pp->clk);
> +	clk_disable_unprepare(pp->clk_axi);
>  err_put_phy_node:
>  	of_node_put(phy_node);
>  err_free_irq:
> @@ -3744,6 +3751,7 @@ static int mvneta_remove(struct platform_device *pdev)
>
>  	unregister_netdev(dev);
>  	clk_disable_unprepare(pp->clk);
> +	clk_disable_unprepare(pp->clk_axi);
>  	free_percpu(pp->ports);
>  	free_percpu(pp->stats);
>  	irq_dispose_mapping(dev->irq);
> --
> 2.7.0.rc3
>


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
