From: John Crispin <john@phrozen.org>
Subject: Re: [RESEND PATCH net 04/10] net: ethernet: mediatek: remove
 redundant free_irq for devm_request_irq allocated irq
Date: Thu, 25 Aug 2016 14:20:19 +0200
Message-ID: <f65c371f-f5c7-ac63-9398-2dd51864f6b2@phrozen.org>
References: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
 <1472121901-15629-5-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbd@openwrt.org,
        linux-mediatek@lists.infradead.org, keyhaede@gmail.com
To: Sean Wang <sean.wang@mediatek.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:52677 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758214AbcHYMUq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 08:20:46 -0400
In-Reply-To: <1472121901-15629-5-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 25/08/2016 12:44, Sean Wang wrote:
> these irqs are not used for shared irq and disabled during ethernet stops.
> irq requested by devm_request_irq is safe to be freed automatically on
> driver detach.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

Acked-by: John Crispin <john@phrozen.org>

> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 1b131a1..9883dac 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -1506,8 +1506,6 @@ static void mtk_uninit(struct net_device *dev)
>  	phy_disconnect(mac->phy_dev);
>  	mtk_mdio_cleanup(eth);
>  	mtk_irq_disable(eth, ~0);
> -	free_irq(eth->irq[1], dev);
> -	free_irq(eth->irq[2], dev);
>  }
>  
>  static int mtk_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
> 
