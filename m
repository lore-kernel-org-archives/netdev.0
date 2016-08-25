From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH net-next v3 2/2] net: ethernet: mediatek: modify GDM to
 send packets to the PDMA for RX
Date: Thu, 25 Aug 2016 14:10:33 +0200
Message-ID: <8d3d9d71-9497-5e57-2c51-f360aa7d7849@phrozen.org>
References: <1472091991-1814-1-git-send-email-nelson.chang@mediatek.com>
 <1472091991-1814-3-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbd@openwrt.org,
        linux-mediatek@lists.infradead.org, nelsonch.tw@gmail.com
To: Nelson Chang <nelson.chang@mediatek.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:52354 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933423AbcHYMKi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 08:10:38 -0400
In-Reply-To: <1472091991-1814-3-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 25/08/2016 04:26, Nelson Chang wrote:
> Because we change to use the PDMA as the Ethernet RX DMA engine,
> the patch modifies to set GDM to send packets to PDMA for RX.
> 
> Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 4 ++--
>  drivers/net/ethernet/mediatek/mtk_eth_soc.h | 0
>  2 files changed, 2 insertions(+), 2 deletions(-)
>  mode change 100755 => 100644 drivers/net/ethernet/mediatek/mtk_eth_soc.c
>  mode change 100755 => 100644 drivers/net/ethernet/mediatek/mtk_eth_soc.h
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> old mode 100755
> new mode 100644
> index cbeb793..c47fef4
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -1473,9 +1473,9 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
>  	for (i = 0; i < 2; i++) {
>  		u32 val = mtk_r32(eth, MTK_GDMA_FWD_CFG(i));
>  
> -		/* setup the forward port to send frame to QDMA */
> +		/* setup the forward port to send frame to PDMA */
>  		val &= ~0xffff;
> -		val |= 0x5555;
> +		val |= 0x0000;

masking it and then setting it to 0 makes no sense. simply remove the
2nd line.

	John

>  
>  		/* Enable RX checksum */
>  		val |= MTK_GDMA_ICS_EN | MTK_GDMA_TCS_EN | MTK_GDMA_UCS_EN;
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> old mode 100755
> new mode 100644
> 
