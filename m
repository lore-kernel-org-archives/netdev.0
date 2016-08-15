From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 4/5] net: ethernet: mediatek: enable rx path by reducing
 memory barrier
Date: Mon, 15 Aug 2016 22:06:30 +0300
Message-ID: <2b336217-2711-a716-78be-4df51591761e@cogentembedded.com>
References: <1471273430-19942-1-git-send-email-sean.wang@mediatek.com>
 <1471273430-19942-4-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1471273430-19942-4-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/15/2016 06:03 PM, Sean Wang wrote:

> The patch makes moving wmb() to outside the loop that could help
> rx path handling more faster although that rx descriptors aren't

    RX.

> freed for DMA to use as soon as possible, but based on my experiment
> and the result show it still can reach about 943Mbpis tested on the

    Shows.

> setup with one port using gigaphy and 256 rx descriptors for

    RX.

> DMA to move.
>
> Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c |   11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index b782330..53e24c1 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -893,14 +893,15 @@ release_desc:
>  		rxd->rxd2 = RX_DMA_PLEN0(ring->buf_size);
>
>  		ring->calc_idx = idx;
> -		/* make sure that all changes to the dma ring are flushed before
> -		 * we continue
> -		 */
> -		wmb();
> -		mtk_w32(eth, ring->calc_idx, MTK_QRX_CRX_IDX0);
>  		done++;
>  	}
>
> +    /* make sure that all changes to the dma ring are flushed before
> +     * we continue
> +     */

    Please indent the comment with a tab, like the code after it.

> +	wmb();
> +	mtk_w32(eth, ring->calc_idx, MTK_QRX_CRX_IDX0);
> +
>  	if (done < budget)
>  		mtk_w32(eth, MTK_RX_DONE_INT, MTK_QMTK_INT_STATUS);
>

MBR, Sergei
