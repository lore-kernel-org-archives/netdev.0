From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2] ravb: Remove rx buffer ALIGN
Date: Wed, 4 May 2016 14:13:56 +0300
Message-ID: <33c6a511-3532-4dd1-9116-39792c8eb86c@cogentembedded.com>
References: <1462115991-27241-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:36033 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757273AbcEDLOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 07:14:01 -0400
Received: by mail-lf0-f54.google.com with SMTP id u64so55533194lff.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 04:14:00 -0700 (PDT)
In-Reply-To: <1462115991-27241-1-git-send-email-ykaneko0929@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 5/1/2016 6:19 PM, Yoshihiro Kaneko wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> Aligning the reception data size is not required.
>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> Tested-by: Simon Horman <horms+renesas@verge.net.au>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> ---
>
> This patch is based on the master branch of David Miller's next networking
> tree.
>
> v2 [Yoshihiro Kaneko]
> * As suggested by Sergei Shtylyov
>   remove re-formattings which is not related to the subject of this patch.
>
>  drivers/net/ethernet/renesas/ravb_main.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 238b56f..34066e0 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -246,10 +246,9 @@ static void ravb_ring_format(struct net_device *ndev, int q)
>  	for (i = 0; i < priv->num_rx_ring[q]; i++) {
>  		/* RX descriptor */
>  		rx_desc = &priv->rx_ring[q][i];
> -		/* The size of the buffer should be on 16-byte boundary. */
> -		rx_desc->ds_cc = cpu_to_le16(ALIGN(PKT_BUF_SZ, 16));
> +		rx_desc->ds_cc = cpu_to_le16(PKT_BUF_SZ);
>  		dma_addr = dma_map_single(ndev->dev.parent, priv->rx_skb[q][i]->data,
> -					  ALIGN(PKT_BUF_SZ, 16),
> +					  PKT_BUF_SZ,
>  					  DMA_FROM_DEVICE);

    I'd expect you to make 2 above lines a single line. Oh well...

>  		/* We just set the data size to 0 for a failed mapping which
>  		 * should prevent DMA from happening...
> @@ -558,7 +557,7 @@ static bool ravb_rx(struct net_device *ndev, int *quota, int q)
>  			skb = priv->rx_skb[q][entry];
>  			priv->rx_skb[q][entry] = NULL;
>  			dma_unmap_single(ndev->dev.parent, le32_to_cpu(desc->dptr),
> -					 ALIGN(PKT_BUF_SZ, 16),
> +					 PKT_BUF_SZ,

    Likewise.

>  					 DMA_FROM_DEVICE);
>  			get_ts &= (q == RAVB_NC) ?
>  					RAVB_RXTSTAMP_TYPE_V2_L2_EVENT :
[...]

MBR, Sergei
