From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH 08/15] drivers: net: Drop unlikely before IS_ERR(_OR_NULL)
Date: Fri, 31 Jul 2015 11:04:27 -0400
Message-ID: <55BB8E7B.7050307@ti.com>
References: <cover.1438331416.git.viresh.kumar@linaro.org> <ceb569d147977a4138a7dd334fe7b9b0efdac8ac.1438331416.git.viresh.kumar@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linaro-kernel@lists.linaro.org>, <linux-kernel@vger.kernel.org>,
	open list: TI NETCP ETHERNET DRIVER <netdev@vger.kernel.org>,
	Wingman Kwok <w-kwok2@ti.com>, ;
To: Viresh Kumar <viresh.kumar@linaro.org>, <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ceb569d147977a4138a7dd334fe7b9b0efdac8ac.1438331416.git.viresh.kumar@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/31/2015 04:38 AM, Viresh Kumar wrote:
> IS_ERR(_OR_NULL) already contain an 'unlikely' compiler flag and there
> is no need to do that again from its callers. Drop it.
>

IS_ERR_OR_NULL() is defined as

static inline bool __must_check IS_ERR_OR_NULL(__force const void *ptr)
{
         return !ptr || IS_ERR_VALUE((unsigned long)ptr);
}

So the unlikely() applies only to second part. Wouldn't that be a 
problem for optimization?

Murali

> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
> ---
>   drivers/net/ethernet/ti/netcp_core.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
> index ec8ed30196f3..f685a19a3703 100644
> --- a/drivers/net/ethernet/ti/netcp_core.c
> +++ b/drivers/net/ethernet/ti/netcp_core.c
> @@ -1016,7 +1016,7 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
>   	}
>
>   	desc = knav_pool_desc_get(netcp->tx_pool);
> -	if (unlikely(IS_ERR_OR_NULL(desc))) {
> +	if (IS_ERR_OR_NULL(desc)) {
>   		dev_err(netcp->ndev_dev, "out of TX desc\n");
>   		dma_unmap_single(dev, dma_addr, pkt_len, DMA_TO_DEVICE);
>   		return NULL;
> @@ -1049,7 +1049,7 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
>   		}
>
>   		ndesc = knav_pool_desc_get(netcp->tx_pool);
> -		if (unlikely(IS_ERR_OR_NULL(ndesc))) {
> +		if (IS_ERR_OR_NULL(ndesc)) {
>   			dev_err(netcp->ndev_dev, "out of TX desc for frags\n");
>   			dma_unmap_page(dev, dma_addr, buf_len, DMA_TO_DEVICE);
>   			goto free_descs;
>


-- 
Murali Karicheri
Linux Kernel, Keystone
