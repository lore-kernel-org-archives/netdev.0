From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH] net: davinci_emac: Add support for fixed-link PHY
Date: Tue, 22 Sep 2015 18:10:20 -0700
Message-ID: <20150923011019.GE23801@atomide.com>
References: <560117E0.20307@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>,
	"Mark A. Greer" <mgreer@animalcreek.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:53464 "EHLO muru.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759871AbbIWBKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 21:10:25 -0400
Content-Disposition: inline
In-Reply-To: <560117E0.20307@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Neil Armstrong <narmstrong@baylibre.com> [150922 02:01]:
> In case the DaVinci Emac is directly connected to a
> non-mdio PHY/device, it should be possible to provide
> a fixed link configuration in the DT.
> 
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

Ethernet works for me with this patch:

Tested-by: Tony Lindgren <tony@atomide.com>

> ---
>  drivers/net/ethernet/ti/davinci_emac.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> index aeebc0a..6521dfb 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -1861,8 +1861,12 @@ davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
>  	pdata->no_bd_ram = of_property_read_bool(np, "ti,davinci-no-bd-ram");
> 
>  	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
> -	if (!priv->phy_node)
> -		pdata->phy_id = NULL;
> +	if (!priv->phy_node) {
> +		if (!of_phy_is_fixed_link(np))
> +			pdata->phy_id = NULL;
> +		else if (of_phy_register_fixed_link(np) >= 0)
> +			priv->phy_node = of_node_get(np);
> +	}
> 
>  	auxdata = pdev->dev.platform_data;
>  	if (auxdata) {
> -- 
> 1.9.1
