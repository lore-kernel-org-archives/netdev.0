From: John Crispin <blogic@openwrt.org>
Subject: Re: [PATCH 1/3] net: mediatek: use dma_addr_t correctly
Date: Mon, 14 Mar 2016 19:01:26 +0100
Message-ID: <56E6FC76.8010409@openwrt.org>
References: <1457964435-2945038-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
	Matthias Brugger <matthias.bgg@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457964435-2945038-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 14/03/2016 15:07, Arnd Bergmann wrote:
> dma_alloc_coherent() expects a dma_addr_t pointer as its argument,
> not an 'unsigned int', and gcc correctly warns about broken
> code in the mtk_init_fq_dma function:
> 
> drivers/net/ethernet/mediatek/mtk_eth_soc.c: In function 'mtk_init_fq_dma':
> drivers/net/ethernet/mediatek/mtk_eth_soc.c:463:13: error: passing argument 3 of 'dma_alloc_coherent' from incompatible pointer type [-Werror=incompatible-pointer-types]
> 
> This changes the type of the local variable to dma_addr_t.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

thanks for the fixes



> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index ba3afa5d4640..3e42204adfe5 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -453,7 +453,7 @@ static inline void mtk_rx_get_desc(struct mtk_rx_dma *rxd,
>  /* the qdma core needs scratch memory to be setup */
>  static int mtk_init_fq_dma(struct mtk_eth *eth)
>  {
> -	unsigned int phy_ring_head, phy_ring_tail;
> +	dma_addr_t phy_ring_head, phy_ring_tail;
>  	int cnt = MTK_DMA_SIZE;
>  	dma_addr_t dma_addr;
>  	int i;
> 
