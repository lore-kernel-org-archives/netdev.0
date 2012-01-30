From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH 1/1] net: fec: correct phy_name buffer length when init
 phy_name
Date: Mon, 30 Jan 2012 17:51:36 +0800
Message-ID: <20120130095134.GA11428@S2101-09.ap.freescale.net>
References: <1327910892-11251-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	u.kleine-koenig@pengutronix.de, LW@KARO-electronics.de,
	linux-arm-kernel@lists.infradead.org, patches@linaro.org
To: Richard Zhao <richard.zhao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:45382 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab2A3Jj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 04:39:27 -0500
Received: by pbaa10 with SMTP id a10so3612208pba.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 01:39:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1327910892-11251-1-git-send-email-richard.zhao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2012 at 04:08:12PM +0800, Richard Zhao wrote:
> Fix the bug that we got wrong phy_name on imx6q sabrelite board.
> snprintf used wrong length of phy_name.
> phy_name length is MII_BUS_ID_SIZE + 3 rather not MII_BUS_ID_SIZE.
> I change it to sizeof(phy_name).
> 
> Signed-off-by: Richard Zhao <richard.zhao@linaro.org>

Acked-by: Shawn Guo <shawn.guo@linaro.org>

Since this patch fixes a regression seen on v3.3-rc1, it may be
suitable for -rc series.

The offending commit for the regression would be 391420f
(fec: use an unique MDIO bus name.) which increases the string
length of fep->mii_bus->id consequently mdio_bus_id.

Regards,
Shawn

> ---
>  drivers/net/ethernet/freescale/fec.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index 7b25e9c..1c7aad8 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -990,7 +990,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
>  		phy_id = 0;
>  	}
>  
> -	snprintf(phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
> +	snprintf(phy_name, sizeof(phy_name), PHY_ID_FMT, mdio_bus_id, phy_id);
>  	phy_dev = phy_connect(ndev, phy_name, &fec_enet_adjust_link, 0,
>  			      fep->phy_interface);
>  	if (IS_ERR(phy_dev)) {
> -- 
> 1.7.5.4
> 
> 
