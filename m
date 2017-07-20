From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH net] net: ethernet: mediatek: avoid potential invalid
 memory access
Date: Thu, 20 Jul 2017 09:04:01 +0200
Message-ID: <78a7c50a-841b-cf23-558f-f5688692ef17@phrozen.org>
References: <3a9d3ee4bcfd47487c5dbac4c658f10e0233b723.1500532842.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbd@openwrt.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: sean.wang@mediatek.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3a9d3ee4bcfd47487c5dbac4c658f10e0233b723.1500532842.git.sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 20/07/17 08:52, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
>
> Potential dangerous invalid memory might be accessed if invalid mac value
> reflected from the forward port field in rxd4 caused by possible potential
> hardware defects. So added a simple sanity checker to avoid the kind of
> situation happening.
>
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

Thanks, i ran into the same problem last week and was going to send a 
fix shortly.

Acked-by: John Crispin <john@phrozen.org>

> ---
>   drivers/net/ethernet/mediatek/mtk_eth_soc.c | 6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index c1dc08c..8175433 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -999,6 +999,12 @@ static int mtk_poll_rx(struct napi_struct *napi, int budget,
>   		      RX_DMA_FPORT_MASK;
>   		mac--;
>   
> +		if (unlikely(mac < 0 || mac >= MTK_MAC_COUNT ||
> +			     !eth->netdev[mac])) {
> +			netdev->stats.rx_dropped++;
> +			goto release_desc;
> +		}
> +
>   		netdev = eth->netdev[mac];
>   
>   		if (unlikely(test_bit(MTK_RESETTING, &eth->state)))
