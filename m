From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v3] sh_eth: check platform data pointer
Date: Thu, 31 Oct 2013 15:05:27 +0900
Message-ID: <20131031060527.GV1603@verge.net.au>
References: <201310302330.19491.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org, 'David Miller' <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201310302330.19491.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Cc Dave Miller ]

On Wed, Oct 30, 2013 at 11:30:19PM +0300, Sergei Shtylyov wrote:
> Check the platform data pointer before dereferencing it and error out of the
> probe() method if it's NULL.
> 
> This has additional effect of preventing kernel oops with outdated platform data
> containing zero PHY address instead (such as on SolutionEngine7710).
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Simon Horman <horms+renesas@verge.net.au>

Dave, is it too late to for this to be considered for net-next?

> 
> ---
> This patch is against David Miller's 'net-next.git' repo.
> 
> Changes in version 3:
> - refreshed the patch.
> 
> Changes in version 2:
> - refreshed the patch.
> 
>  drivers/net/ethernet/renesas/sh_eth.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
> ===================================================================
> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net-next/drivers/net/ethernet/renesas/sh_eth.c
> @@ -2663,6 +2663,12 @@ static int sh_eth_drv_probe(struct platf
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
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
