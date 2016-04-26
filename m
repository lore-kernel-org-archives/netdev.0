From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ravb: Remove rx buffer ALIGN
Date: Tue, 26 Apr 2016 22:14:41 +0300
Message-ID: <571FBE21.4050908@cogentembedded.com>
References: <1461514567-23444-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1461514567-23444-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/24/2016 07:16 PM, Yoshihiro Kaneko wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> Aligning the reception data size is not required.

    OK, the gen 2/3 manuals indeed don't require this. I assume the patch has 
been tested...

> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

    I have a few comments though...

> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 238b56f..66ed80c 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -246,10 +246,10 @@ static void ravb_ring_format(struct net_device *ndev, int q)
>   	for (i = 0; i < priv->num_rx_ring[q]; i++) {
>   		/* RX descriptor */
>   		rx_desc = &priv->rx_ring[q][i];
> -		/* The size of the buffer should be on 16-byte boundary. */
> -		rx_desc->ds_cc = cpu_to_le16(ALIGN(PKT_BUF_SZ, 16));
> -		dma_addr = dma_map_single(ndev->dev.parent, priv->rx_skb[q][i]->data,
> -					  ALIGN(PKT_BUF_SZ, 16),
> +		rx_desc->ds_cc = cpu_to_le16(PKT_BUF_SZ);
> +		dma_addr = dma_map_single(ndev->dev.parent,
> +					  priv->rx_skb[q][i]->data,

    Please don't reformat the lines above.

> +					  PKT_BUF_SZ,
>   					  DMA_FROM_DEVICE);
>   		/* We just set the data size to 0 for a failed mapping which
>   		 * should prevent DMA from happening...
> @@ -557,8 +557,9 @@ static bool ravb_rx(struct net_device *ndev, int *quota, int q)
>
>   			skb = priv->rx_skb[q][entry];
>   			priv->rx_skb[q][entry] = NULL;
> -			dma_unmap_single(ndev->dev.parent, le32_to_cpu(desc->dptr),
> -					 ALIGN(PKT_BUF_SZ, 16),
> +			dma_unmap_single(ndev->dev.parent,
> +					 le32_to_cpu(desc->dptr),

   Same here.

[...]

MBR, Sergei
