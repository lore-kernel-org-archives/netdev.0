From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: do not invalidate cache for RX buffer twice
Date: Wed, 15 Jul 2015 13:45:34 +0300
Message-ID: <55A639CE.2030201@cogentembedded.com>
References: <4759713.2ulGRKsd9L@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4759713.2ulGRKsd9L@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 7/15/2015 12:56 AM, Sergei Shtylyov wrote:

> First, dma_sync_single_for_cpu() shouldn't have been called in the first place
> (it's a streaming DMA API). dma_unmap_single() should have been called instead.
                             ^
    Oops, I meant comma here.

> Second, dma_unmap_single() call after handing the buffer to napi_gro_receive()
> makes little sense.

    Moreover, 'desc->dptr' may not be valid at this point...

> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> ---
> The patch is against Dave Miller's 'net.git' repo.

> Don't know why I missed this DMA API misuse while working on the driver. :-<

    Dave, do you want me to resend the patch with fixed up changelog?

>   drivers/net/ethernet/renesas/ravb_main.c |   10 +++-------
>   1 file changed, 3 insertions(+), 7 deletions(-)
>
> Index: net/drivers/net/ethernet/renesas/ravb_main.c
> ===================================================================
> --- net.orig/drivers/net/ethernet/renesas/ravb_main.c
> +++ net/drivers/net/ethernet/renesas/ravb_main.c
[...]
> @@ -584,9 +583,6 @@ static bool ravb_rx(struct net_device *n
>   			if (!skb)
>   				break;	/* Better luck next round. */
>   			ravb_set_buffer_align(skb);
> -			dma_unmap_single(&ndev->dev, le32_to_cpu(desc->dptr),
> -					 ALIGN(PKT_BUF_SZ, 16),
> -					 DMA_FROM_DEVICE);
>   			dma_addr = dma_map_single(&ndev->dev, skb->data,
>   						  le16_to_cpu(desc->ds_cc),
>   						  DMA_FROM_DEVICE);

WBR, Sergei

