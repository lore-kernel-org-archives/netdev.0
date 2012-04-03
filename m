From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] stmmac: re-add IFF_UNICAST_FLT for dwmac1000
Date: Tue, 03 Apr 2012 20:20:24 +0200
Message-ID: <1333477224.18626.289.camel@edumazet-glaptop>
References: <1333475057-3752-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, rayagond@vayavyalabs.com,
	netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:62797 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558Ab2DCSU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 14:20:28 -0400
Received: by wgbdr13 with SMTP id dr13so1704wgb.1
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 11:20:27 -0700 (PDT)
In-Reply-To: <1333475057-3752-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-03 at 19:44 +0200, Marc Kleine-Budde wrote:
> In commit (bfab27a stmmac: add the experimental PCI support) the
> IFF_UNICAST_FLT flag has been removed from the stmmac_mac_device_setup()
> function. This patch re-adds the flag.
> 
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
> 
> Just compile time tested, since I don't have the hardware.
> Applies to net-next/master (and v3.3).
> 
> regards, Marc
> 
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index e85ffbd..07e0c78 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1737,9 +1737,10 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
>  	struct mac_device_info *mac;
>  
>  	/* Identify the MAC HW device */
> -	if (priv->plat->has_gmac)
> +	if (priv->plat->has_gmac) {
> +		priv->dev->priv_flags |= IFF_UNICAST_FLT;
>  		mac = dwmac1000_setup(priv->ioaddr);
> -	else
> +	} else
>  		mac = dwmac100_setup(priv->ioaddr);
>  	if (!mac)
>  		return -ENOMEM;


	if (priv->plat->has_gmac) {
		priv->dev->priv_flags |= IFF_UNICAST_FLT;
		mac = dwmac1000_setup(priv->ioaddr);
	} else {
		mac = dwmac100_setup(priv->ioaddr);
	}

(Documentation/CodingStyle line 175)
