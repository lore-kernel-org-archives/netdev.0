From: John Crispin <john@phrozen.org>
Subject: Re: [RESEND PATCH net 03/10] net: ethernet: mediatek: fix API usage
 with skb_free_frag
Date: Thu, 25 Aug 2016 14:20:58 +0200
Message-ID: <f2adea70-e456-3655-71c7-028c4990a62a@phrozen.org>
References: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
 <1472121901-15629-4-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbd@openwrt.org,
        linux-mediatek@lists.infradead.org, keyhaede@gmail.com
To: Sean Wang <sean.wang@mediatek.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:52730 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758214AbcHYMVC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 08:21:02 -0400
In-Reply-To: <1472121901-15629-4-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 25/08/2016 12:44, Sean Wang wrote:
> use skb_free_frag() instead of legacy put_page()
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

Acked-by: John Crispin <john@phrozen.org>

> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 02b048f..1b131a1 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -864,7 +864,7 @@ static int mtk_poll_rx(struct napi_struct *napi, int budget,
>  		/* receive data */
>  		skb = build_skb(data, ring->frag_size);
>  		if (unlikely(!skb)) {
> -			put_page(virt_to_head_page(new_data));
> +			skb_free_frag(new_data);
>  			netdev->stats.rx_dropped++;
>  			goto release_desc;
>  		}
> 
