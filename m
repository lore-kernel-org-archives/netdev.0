From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 2/3] net: ethernet: mediatek: get hw lro
 capability by the chip id instead of by the dtsi
Date: Wed, 5 Oct 2016 15:18:24 +0300
Message-ID: <6fdb5e81-0e95-0242-02bc-c2a8e15a9bf7@cogentembedded.com>
References: <1475669532-23894-1-git-send-email-nelson.chang@mediatek.com>
 <1475669532-23894-3-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, nelsonch.tw@gmail.com
To: Nelson Chang <nelson.chang@mediatek.com>, john@phrozen.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:35709 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752213AbcJEMS2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 08:18:28 -0400
Received: by mail-lf0-f49.google.com with SMTP id l131so209536245lfl.2
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 05:18:27 -0700 (PDT)
In-Reply-To: <1475669532-23894-3-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/05/2016 03:12 PM, Nelson Chang wrote:

> Because hw lro started to be supported from MT7623, the proper way to check if
> the feature is capable is to judge by the chip id instead of by the dtsi.
>
> Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 12 ++++++++++--
>  drivers/net/ethernet/mediatek/mtk_eth_soc.h |  1 +
>  2 files changed, 11 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 0c67ab1..07f3ffa 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -2348,6 +2348,14 @@ static int mtk_get_chip_id(struct mtk_eth *eth, u32 *chip_id)
>  	return 0;
>  }
>
> +static bool mtk_is_hwlro_supported(struct mtk_eth *eth)
> +{
> +	if (eth->chip_id == MT7623_ETH)
> +		return true;
> +	else
> +		return false;

	return eth->chip_id == MT7623_ETH;

[...]
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
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
