From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/2] sh_eth: check platform data pointer
Date: Wed, 4 Sep 2013 15:48:34 +0900
Message-ID: <20130904064833.GB7233@verge.net.au>
References: <201308310423.30322.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201308310423.30322.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 31, 2013 at 04:23:29AM +0400, Sergei Shtylyov wrote:
> Check the platform data pointer before dereferencing it and error out of the
> probe() method if it's NULL.
> 
> This has additional effect of preventing kernel oops with outdated platform data
> containing zero PHY address instead (such as on SolutionEngine7710).
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>


Reviewed-by: Simon Horman <horms@verge.net.au>

> 
> ---
> This patch is against Dave's 'net-next.git' repo.
> 
>  drivers/net/ethernet/renesas/sh_eth.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
> ===================================================================
> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net-next/drivers/net/ethernet/renesas/sh_eth.c
> @@ -2653,6 +2653,12 @@ static int sh_eth_drv_probe(struct platf
>  	pm_runtime_enable(&pdev->dev);
>  	pm_runtime_resume(&pdev->dev);
>  
> +	if (!pd) {
> +		dev_err(&pdev->dev, "no platform data\n");
> +		ret = -EINVAL;
> +		goto out_release;
> +	}
> +
>  	/* get PHY ID */
>  	mdp->phy_id = pd->phy;
>  	mdp->phy_interface = pd->phy_interface;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sh" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
