From: Nelson Chang <nelson.chang@mediatek.com>
Subject: RE: [PATCH net-next v2 2/3] net: ethernet: mediatek: get hw lro
 capability by the chip id instead of by the dtsi
Date: Wed, 5 Oct 2016 20:38:42 +0800
Message-ID: <1475671122.6101.1.camel@mtksdaap41>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>
To: <sergei.shtylyov@cogentembedded.com>, <john@phrozen.org>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:65530 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751392AbcJEMit (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 08:38:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

Thanks for your comments.
Modified.


Nelson

-----Original Message-----
From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com] 
Sent: Wednesday, October 05, 2016 8:18 PM
To: Nelson Chang (張家祥); john@phrozen.org; davem@davemloft.net
Cc: nbd@openwrt.org; netdev@vger.kernel.org;
linux-mediatek@lists.infradead.org; nelsonch.tw@gmail.com
Subject: Re: [PATCH net-next v2 2/3] net: ethernet: mediatek: get hw lro
capability by the chip id instead of by the dtsi

Hello.

On 10/05/2016 03:12 PM, Nelson Chang wrote:

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
> index 0c67ab1..07f3ffa 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -2348,6 +2348,14 @@ static int mtk_get_chip_id(struct mtk_eth *eth,
u32 *chip_id)
>  	return 0;
>  }
>
> +static bool mtk_is_hwlro_supported(struct mtk_eth *eth) {
> +	if (eth->chip_id == MT7623_ETH)
> +		return true;
> +	else
> +		return false;

	return eth->chip_id == MT7623_ETH;

[...]
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

    () not needed at all.

MBR, Sergei
