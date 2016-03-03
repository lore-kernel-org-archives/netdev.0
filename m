From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net/ethoc: do not free array priv->mdio->irq
Date: Thu, 3 Mar 2016 15:27:28 +0100
Message-ID: <20160303142728.GG15541@lunn.ch>
References: <1457012614-19564-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Max Filippov <jcmvbkbc@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48705 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757253AbcCCO1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 09:27:31 -0500
Content-Disposition: inline
In-Reply-To: <1457012614-19564-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2016 at 01:43:34PM +0000, Colin King wrote:
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
>  drivers/net/ethernet/ethoc.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
> index 62fa136..41b0106 100644
> --- a/drivers/net/ethernet/ethoc.c
> +++ b/drivers/net/ethernet/ethoc.c
> @@ -1265,7 +1265,6 @@ static int ethoc_remove(struct platform_device *pdev)
>  
>  		if (priv->mdio) {
>  			mdiobus_unregister(priv->mdio);
> -			kfree(priv->mdio->irq);
>  			mdiobus_free(priv->mdio);
>  		}
>  		if (priv->clk)
> -- 
> 2.7.0
> 
