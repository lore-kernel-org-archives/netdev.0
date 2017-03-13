From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/4] net-next: ethernet: mediatek: add CDM able
 to recognize the tag for DSA
Date: Mon, 13 Mar 2017 17:30:32 +0100
Message-ID: <20170313163032.GC3953@lunn.ch>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com>
 <1489421488-300-4-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        matthias.bgg@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        davem@davemloft.net, Landen.Chao@mediatek.com, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46182 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753930AbdCMQai (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 12:30:38 -0400
Content-Disposition: inline
In-Reply-To: <1489421488-300-4-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 12:11:27AM +0800, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
> 
> Allowing CDM can recognize these packets with carrying port-distinguishing
> tag when CONFIG_NET_DSA_TAG_MTK is enabled. Otherwise, these packets will
> be dropped by CDM ingress.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> Signed-off-by: Landen Chao <Landen.Chao@mediatek.com>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 8 ++++++++
>  drivers/net/ethernet/mediatek/mtk_eth_soc.h | 5 +++++
>  2 files changed, 13 insertions(+)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 3dd8788..19944e0 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -1848,6 +1848,14 @@ static int mtk_hw_init(struct mtk_eth *eth)
>  	/* GE2, Force 1000M/FD, FC ON */
>  	mtk_w32(eth, MAC_MCR_FIXED_LINK, MTK_MAC_MCR(1));
>  
> +#if defined(CONFIG_NET_DSA_TAG_MTK)
> +	/* Tell CDMQ to parse the MTK special tag from CPU  */
> +	/* QDMA Tx Use CDMQ */
> +	u32 val2 = mtk_r32(eth, MTK_CDMQ_IG_CTRL);
> +
> +	mtk_w32(eth, val2 | MTK_CDMQ_STAG_EN, MTK_CDMQ_IG_CTRL);
> +#endif

Hi Sean

Does this need to be conditional on CONFIG_NET_DSA_TAG_MTK? 
Is there any downside on always having MTK_CDMQ_STAG_EN set?

Thanks
   Andrew
