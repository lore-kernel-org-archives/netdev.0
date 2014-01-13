From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] sh_eth: fix garbled TX error message
Date: Mon, 13 Jan 2014 09:45:32 +0900
Message-ID: <20140113004532.GJ15296@verge.net.au>
References: <201401110241.49471.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201401110241.49471.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 11, 2014 at 02:41:49AM +0300, Sergei Shtylyov wrote:
> sh_eth_error() in case of a TX error tries to print a message using 2 dev_err()
> calls with the first string not finished by '\n', so that the resulting message
> would inevitably come out garbled, with something like "3net eth0: " inserted
> in the middle.  Avoid that by merging 2 calls into one.
> 
> While at it, insert an empty line after the nearby declaration.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Simon Horman <horms+renesas@verge.net.au>

> 
> ---
> Although being a fix, this patch is against the 'net-next.git' repo as it's does
> not seem important enough at this time in the release cycle. Please consider it
> for the stable kernel though...
> 
>  drivers/net/ethernet/renesas/sh_eth.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
> ===================================================================
> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net-next/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1513,11 +1513,11 @@ ignore_link:
>  	if (intr_status & mask) {
>  		/* Tx error */
>  		u32 edtrr = sh_eth_read(ndev, EDTRR);
> +
>  		/* dmesg */
> -		dev_err(&ndev->dev, "TX error. status=%8.8x cur_tx=%8.8x ",
> -			intr_status, mdp->cur_tx);
> -		dev_err(&ndev->dev, "dirty_tx=%8.8x state=%8.8x EDTRR=%8.8x.\n",
> -			mdp->dirty_tx, (u32) ndev->state, edtrr);
> +		dev_err(&ndev->dev, "TX error. status=%8.8x cur_tx=%8.8x dirty_tx=%8.8x state=%8.8x EDTRR=%8.8x.\n",
> +			intr_status, mdp->cur_tx, mdp->dirty_tx,
> +			(u32)ndev->state, edtrr);
>  		/* dirty buffer free */
>  		sh_eth_txfree(ndev);
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sh" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
