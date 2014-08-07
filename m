From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] net: gianfar: no need to check parameter being != NULL
 for of_node_put
Date: Thu, 7 Aug 2014 21:49:22 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1408072148400.2043@localhost6.localdomain6>
References: <1407439212-16661-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-149610876-1407440964=:2043"
Cc: netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	kernel@pengutronix.de, Florian Fainelli <f.fainelli@gmail.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: =?ISO-8859-15?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:16343
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751399AbaHGTtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 15:49:25 -0400
In-Reply-To: <1407439212-16661-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-149610876-1407440964=:2043
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Thu, 7 Aug 2014, Uwe Kleine-König wrote:

> of_node_put is a noop when being called with NULL.
> 
> Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
> ---
> Hello,
> 
> @Julia: I'm sure it's easy to create a coccinelle rule for this.

@@
expression e;
@@

-if (e)
   of_node_put(e);

It matches in 25 files.

julia

> 
> Best regards
> Uwe
> 
>  drivers/net/ethernet/freescale/gianfar.c | 12 ++++--------
>  1 file changed, 4 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index a6cf40e62f3a..6b0c4775cd0d 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -1435,10 +1435,8 @@ register_fail:
>  	unmap_group_regs(priv);
>  	gfar_free_rx_queues(priv);
>  	gfar_free_tx_queues(priv);
> -	if (priv->phy_node)
> -		of_node_put(priv->phy_node);
> -	if (priv->tbi_node)
> -		of_node_put(priv->tbi_node);
> +	of_node_put(priv->phy_node);
> +	of_node_put(priv->tbi_node);
>  	free_gfar_dev(priv);
>  	return err;
>  }
> @@ -1447,10 +1445,8 @@ static int gfar_remove(struct platform_device *ofdev)
>  {
>  	struct gfar_private *priv = platform_get_drvdata(ofdev);
>  
> -	if (priv->phy_node)
> -		of_node_put(priv->phy_node);
> -	if (priv->tbi_node)
> -		of_node_put(priv->tbi_node);
> +	of_node_put(priv->phy_node);
> +	of_node_put(priv->tbi_node);
>  
>  	unregister_netdev(priv->ndev);
>  	unmap_group_regs(priv);
> -- 
> 2.0.1
> 
> 
--8323328-149610876-1407440964=:2043--
