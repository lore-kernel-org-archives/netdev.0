From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] sh_eth: Fix cache invalidation omission
 of receive buffer
Date: Thu, 29 Aug 2013 16:15:53 -0400 (EDT)
Message-ID: <20130829.161553.755954777649764863.davem@davemloft.net>
References: <1377650589-20960-1-git-send-email-horms+renesas@verge.net.au>
	<1377650589-20960-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	magnus.damm@gmail.com, sergei.shtylyov@cogentembedded.com,
	kouei.abe.cp@renesas.com
To: horms+renesas@verge.net.au
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1377650589-20960-2-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms+renesas@verge.net.au>
Date: Wed, 28 Aug 2013 09:43:08 +0900

> From: Kouei Abe <kouei.abe.cp@renesas.com>
> 
> Signed-off-by: Kouei Abe <kouei.abe.cp@renesas.com>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> ---
>  drivers/net/ethernet/renesas/sh_eth.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index c357076..f386a8f 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1342,6 +1342,8 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
>  			mdp->rx_skbuff[entry] = NULL;
>  			if (mdp->cd->rpadir)
>  				skb_reserve(skb, NET_IP_ALIGN);
> +			dma_sync_single_for_cpu(&ndev->dev, rxdesc->addr,
> +				mdp->rx_buf_sz,	DMA_FROM_DEVICE);

Please indent the second line of the dma sync call properly.

The arguments should start at the first column after the openning
parenthesis of the function call on the first line, using the
appropriate number of TAB then space characters (as needed).

Thanks.
