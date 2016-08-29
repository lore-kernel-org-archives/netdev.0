From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net v2 9/9] net: ethernet: mediatek: fix error handling
 inside mtk_mdio_init
Date: Mon, 29 Aug 2016 18:36:28 +0200
Message-ID: <20160829163628.GC17231@lunn.ch>
References: <1472447003-30726-1-git-send-email-sean.wang@mediatek.com>
 <1472447003-30726-10-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john@phrozen.org, davem@davemloft.net, nbd@openwrt.org,
        netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com
To: sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46969 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752597AbcH2Qgh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 12:36:37 -0400
Content-Disposition: inline
In-Reply-To: <1472447003-30726-10-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2016 at 01:03:23PM +0800, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
> 
> return -ENODEV if no child is found in MDIO bus.

The "no child" is wrong here, and got me confused. What the code is
actually doing is of_device_is_available() which is looking to see if
there is a status = "okay". So what the change log should say is:

Return -ENODEV if the MDIO bus is disabled in the device tree.

Once that has been corrected:

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew


> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> Acked-by: John Crispin <john@phrozen.org>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index f741c6a..e48b2a4 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -304,7 +304,7 @@ static int mtk_mdio_init(struct mtk_eth *eth)
>  	}
>  
>  	if (!of_device_is_available(mii_np)) {
> -		ret = 0;
> +		ret = -ENODEV;
>  		goto err_put_node;
>  	}
>  
> -- 
> 1.9.1
> 
