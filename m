From: John Crispin <blogic@openwrt.org>
Subject: Re: [patch 1/2 net-next] mediatek: checking for IS_ERR() instead of
 NULL
Date: Tue, 15 Mar 2016 08:27:47 +0100
Message-ID: <56E7B973.4050604@openwrt.org>
References: <20160315071849.GH13560@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Matthias Brugger <matthias.bgg@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-mediatek@lists.infradead.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caladan.dune.hu ([78.24.191.180]:60326 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752216AbcCOH1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2016 03:27:52 -0400
In-Reply-To: <20160315071849.GH13560@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 15/03/2016 08:18, Dan Carpenter wrote:
> of_phy_connect() returns NULL on error, it never returns error pointers.
> 
> Fixes: 656e705243fd ('net-next: mediatek: add support for MT7623 ethernet')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
Acked-by: John Crispin <blogic@openwrt.org>

Thanks !

> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index ba3afa5..9759fe5 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -186,9 +186,9 @@ static int mtk_phy_connect_node(struct mtk_eth *eth, struct mtk_mac *mac,
>  
>  	phydev = of_phy_connect(eth->netdev[mac->id], phy_node,
>  				mtk_phy_link_adjust, 0, phy_mode);
> -	if (IS_ERR(phydev)) {
> +	if (!phydev) {
>  		dev_err(eth->dev, "could not connect to PHY\n");
> -		return PTR_ERR(phydev);
> +		return -ENODEV;
>  	}
>  
>  	dev_info(eth->dev,
> 
> _______________________________________________
> Linux-mediatek mailing list
> Linux-mediatek@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-mediatek
> 
