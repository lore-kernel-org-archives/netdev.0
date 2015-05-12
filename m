From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] net: ll_temac: Fix DMA map size bug
Date: Tue, 12 May 2015 08:03:39 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1505120801390.2075@localhost6.localdomain6>
References: <d76f13c52ce740544e8fac27f2a5904b9537a226.1431410298.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	=?ISO-8859-15?Q?S=F6ren_Brinkmann?= <soren.brinkmann@xilinx.com>,
	monstr@monstr.eu, Fabian Frederick <fabf@skynet.be>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	=?ISO-8859-15?Q?Manuel_Sch=F6lling?= <manuel.schoelling@gmx.de>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Markus Elfring <elfring@users.sourceforge.net>,
	Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>,
	linux-arm-kernel@lists.infradead.org
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d76f13c52ce740544e8fac27f2a5904b9537a226.1431410298.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 May 2015, Michal Simek wrote:

> DMA allocates skb->len instead of headlen
> which is used for DMA.
> 
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> ---
> 
>  drivers/net/ethernet/xilinx/ll_temac_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
> index ca640d04fd93..cfb6bdb37fdc 100644
> --- a/drivers/net/ethernet/xilinx/ll_temac_main.c
> +++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
> @@ -705,8 +705,8 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  
>  	cur_p->app0 |= STS_CTRL_APP0_SOP;
>  	cur_p->len = skb_headlen(skb);
> -	cur_p->phys = dma_map_single(ndev->dev.parent, skb->data, skb->len,
> -				     DMA_TO_DEVICE);
> +	cur_p->phys = dma_map_single(ndev->dev.parent, skb->data,
> +				skb_headlen(skb), DMA_TO_DEVICE);

I think you could align the later arguments with the right side of the 
parenthesis, as done in the original code.

julia



>  	cur_p->app4 = (unsigned long)skb;
>  
>  	for (ii = 0; ii < num_frag; ii++) {
> -- 
> 2.3.5
> 
> 
