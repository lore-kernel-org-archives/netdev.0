From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [Nios2-dev] [PATCH] Altera TSE: Add missing phydev
Date: Thu, 25 Dec 2014 13:52:39 +0100
Message-ID: <20141225125239.GP16916@distanz.ch>
References: <BLU436-SMTP58313D55680097A2C4AAA0B6560@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nios2-dev <nios2-dev@lists.rocketboards.org>,
	Vince Bridgers <vbridgers2013@gmail.com>,
	netdev@vger.kernel.org
To: Kostya Belezko <bkostya@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:44377 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136AbaLYMwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Dec 2014 07:52:43 -0500
Content-Disposition: inline
In-Reply-To: <BLU436-SMTP58313D55680097A2C4AAA0B6560@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-12-22 at 23:37:19 +0100, Kostya Belezko <bkostya@hotmail.com> wrote:
> Altera network device doesn't come up after
> 
> ifconfig eth0 down
> ifconfig eth0 up
> 
> The reason behind is clearing priv->phydev during tse_shutdown().
> The phydev is not restored back at tse_open().
> 
> Signed-off-by: Kostya Belezko <bkostya@hotmail.com>

Please Cc: netdev@vger.kernel.org for network driver patches.

> ---
>  drivers/net/ethernet/altera/altera_tse_main.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
> index 4efc435..361bf35 100644
> --- a/drivers/net/ethernet/altera/altera_tse_main.c
> +++ b/drivers/net/ethernet/altera/altera_tse_main.c
> @@ -1150,6 +1150,9 @@ static int tse_open(struct net_device *dev)
>  
>  	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
>  
> +	if (!priv->phydev)
> +		init_phy(dev);

That way the PHY will be initialized twice on first start.

IMO the proper solution would be to disconnect and NULL the phydev in
altera_tse_remove, not in tse_shutdown. There, only phy_stop should be
called.
