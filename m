From: John Crispin <john@phrozen.org>
Subject: Re: [RESEND PATCH net 05/10] net: ethernet: mediatek: fix logic
 unbalance between probe and remove
Date: Thu, 25 Aug 2016 14:22:35 +0200
Message-ID: <2730e1f7-466e-39b7-3fba-4f31343c9cb3@phrozen.org>
References: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
 <1472121901-15629-6-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbd@openwrt.org,
        linux-mediatek@lists.infradead.org, keyhaede@gmail.com
To: Sean Wang <sean.wang@mediatek.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:52802 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758722AbcHYMWk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 08:22:40 -0400
In-Reply-To: <1472121901-15629-6-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 25/08/2016 12:44, Sean Wang wrote:
> original mdio_cleanup is not in the symmetric place against where
> mdio_init is, so relocate mdio_cleanup to the right one.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

Acked-by: John Crispin <john@phrozen.org>

> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 9883dac..5bd31f8 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -1504,7 +1504,6 @@ static void mtk_uninit(struct net_device *dev)
>  	struct mtk_eth *eth = mac->hw;
>  
>  	phy_disconnect(mac->phy_dev);
> -	mtk_mdio_cleanup(eth);
>  	mtk_irq_disable(eth, ~0);
>  }
>  
> @@ -1915,6 +1914,7 @@ static int mtk_remove(struct platform_device *pdev)
>  	netif_napi_del(&eth->tx_napi);
>  	netif_napi_del(&eth->rx_napi);
>  	mtk_cleanup(eth);
> +	mtk_mdio_cleanup(eth);
>  
>  	return 0;
>  }
> 
