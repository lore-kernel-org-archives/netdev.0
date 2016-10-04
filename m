From: Nelson Chang <nelson.chang@mediatek.com>
Subject: Re: [PATCH net-next 2/3] net: ethernet: mediatek: get hw lro
 capability by the chip id instead of by the dtsi
Date: Tue, 4 Oct 2016 20:22:41 +0800
Message-ID: <1475583761.7983.12.camel@mtksdaap41>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <nbd@openwrt.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:34445 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752220AbcJDMWq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 08:22:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

do you plan to add more chips to the mtk_is_hwlro_supporte() function ?
=> yes, there will be more chips with hw lro in the future, so i think
using mtk_is_hwlro_supporte() function can have the scalability.

Thanks.


Nelson

-----Original Message-----
From: John Crispin [mailto:john@phrozen.org] 
Sent: Tuesday, October 04, 2016 3:19 AM
To: Nelson Chang (張家祥); davem@davemloft.net
Cc: netdev@vger.kernel.org; nbd@openwrt.org;
linux-mediatek@lists.infradead.org; nelsonch.tw@gmail.com
Subject: Re: [PATCH net-next 2/3] net: ethernet: mediatek: get hw lro
capability by the chip id instead of by the dtsi

Hi Nelson,

comment inline

On 03/10/2016 09:18, Nelson Chang wrote:
> Because hw lro started to be supported from MT7623, the proper way to 
> check if the feature is capable is to judge by the chip id instead of
by the dtsi.
> 
> Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 12 ++++++++++--  
> drivers/net/ethernet/mediatek/mtk_eth_soc.h |  1 +
>  2 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c 
> b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index a3e4ae6..3d16a0c 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -2344,6 +2344,14 @@ static u32 mtk_get_chip_id(struct mtk_eth *eth)
>  	return chip_id;
>  }
>  
> +static bool mtk_is_hwlro_supported(struct mtk_eth *eth) {
> +	if (eth->chip_id == MT7623_ETH)
> +		return true;
> +	else
> +		return false;
> +}
> +
>  static int mtk_probe(struct platform_device *pdev)  {
>  	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 
> 0); @@ -2383,8 +2391,6 @@ static int mtk_probe(struct platform_device
*pdev)
>  		return PTR_ERR(eth->pctl);
>  	}
>  
> -	eth->hwlro = of_property_read_bool(pdev->dev.of_node,
"mediatek,hwlro");
> -
>  	for (i = 0; i < 3; i++) {
>  		eth->irq[i] = platform_get_irq(pdev, i);
>  		if (eth->irq[i] < 0) {
> @@ -2415,6 +2421,8 @@ static int mtk_probe(struct platform_device
*pdev)
>  		return -ENODEV;
>  	}
>  
> +	eth->hwlro = mtk_is_hwlro_supported(eth);
> +

do you plan to add more chips to the mtk_is_hwlro_supporte() function ?
if not a simple

	eth->hwlro = (eth->chip_id == MT7623_ETH);

might be enough

	John


>  	for_each_child_of_node(pdev->dev.of_node, mac_np) {
>  		if (!of_device_is_compatible(mac_np,
>  					     "mediatek,eth-mac"))
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h 
> b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> index a5b422b..58738fd 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> @@ -345,6 +345,7 @@
>  /* ethernet subsystem chip id register */
>  #define ETHSYS_CHIPID0_3	0x0
>  #define ETHSYS_CHIPID4_7	0x4
> +#define MT7623_ETH		(7623)
>  
>  /* ethernet subsystem config register */
>  #define ETHSYS_SYSCFG0		0x14
> 
