From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] fsl/fman: Delete one function call "put_device" in
 dtsec_config()
Date: Thu, 14 Jan 2016 17:27:41 +0100
Message-ID: <20160114162741.GC19773@lunn.ch>
References: <5696BFAD.9030905@users.sourceforge.net>
 <20160113213537.GD4399@mwanda>
 <20160113220923.GE5527@lunn.ch>
 <5697B81E.4050303@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Igal Liberman <igal.liberman@freescale.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5697B81E.4050303@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 14, 2016 at 04:00:46PM +0100, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Thu, 14 Jan 2016 15:46:28 +0100
> 
> The Coccinelle semantic patch script "deref_null.cocci" pointed a problem
> out in the implementation of the function "dtsec_config".
> 
> A null pointer was assigned to the data structure member "tbiphy" of the
> variable "dtsec" if a matching device was not found.
> A call of the function "put_device" was unnecessary then because
> a previous call of the function "get_device" was not triggered.
> Thus remove the function call "put_device" after the printing of the
> desired error message.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Fixes: 57ba4c9b56d8 ("fsl/fman: Add FMan MAC support")
Reviewd-by: Andrew Lunn <andrew@lunn.ch>

	    Andrew
> ---
>  drivers/net/ethernet/freescale/fman/fman_dtsec.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fman/fman_dtsec.c b/drivers/net/ethernet/freescale/fman/fman_dtsec.c
> index 6b1261c..7c92eb8 100644
> --- a/drivers/net/ethernet/freescale/fman/fman_dtsec.c
> +++ b/drivers/net/ethernet/freescale/fman/fman_dtsec.c
> @@ -1434,7 +1434,6 @@ struct fman_mac *dtsec_config(struct fman_mac_params *params)
>  	dtsec->tbiphy = of_phy_find_device(params->internal_phy_node);
>  	if (!dtsec->tbiphy) {
>  		pr_err("of_phy_find_device (TBI PHY) failed\n");
> -		put_device(&dtsec->tbiphy->mdio.dev);
>  		goto err_dtsec_drv_param;
>  	}
>  
> -- 
> 2.6.3
> 
