From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: eth: altera: do not free array priv->mdio->irq
Date: Thu, 3 Mar 2016 16:16:31 +0100
Message-ID: <20160303151631.GL15541@lunn.ch>
References: <1457012838-19743-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vince Bridgers <vbridger@opensource.altera.com>,
	netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org,
	linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48791 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756498AbcCCPQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 10:16:35 -0500
Content-Disposition: inline
In-Reply-To: <1457012838-19743-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2016 at 01:47:18PM +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> priv->mdio->irq used to be allocated and required freeing, but it
> is now a fixed sized array and should no longer be free'd.
> 
> Issue detected using static analysis with CoverityScan
> 
> Fixes: e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew

> ---
>  drivers/net/ethernet/altera/altera_tse_main.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
> index 1747285..f749e4d 100644
> --- a/drivers/net/ethernet/altera/altera_tse_main.c
> +++ b/drivers/net/ethernet/altera/altera_tse_main.c
> @@ -193,7 +193,6 @@ static void altera_tse_mdio_destroy(struct net_device *dev)
>  			    priv->mdio->id);
>  
>  	mdiobus_unregister(priv->mdio);
> -	kfree(priv->mdio->irq);
>  	mdiobus_free(priv->mdio);
>  	priv->mdio = NULL;
>  }
> -- 
> 2.7.0
> 
