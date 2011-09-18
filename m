From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/4] net/fec: add imx6q enet support
Date: Sun, 18 Sep 2011 20:09:12 +0200
Message-ID: <20110918180912.GA3734@electric-eye.fr.zoreil.com>
References: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org> <1316346852-17090-5-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, patches@linaro.org
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51205 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755923Ab1IRSKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 14:10:04 -0400
Content-Disposition: inline
In-Reply-To: <1316346852-17090-5-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shawn Guo <shawn.guo@linaro.org> :
[...]
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 04206e4..849cb0b 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -442,18 +453,23 @@ fec_restart(struct net_device *ndev, int duplex)
>  		/* Enable flow control and length check */
>  		rcntl |= 0x40000000 | 0x00000020;
>  
> -		/* MII or RMII */
> +		/* RGMII, RMII or MII */
> +		if (fep->phy_interface == PHY_INTERFACE_MODE_RGMII)
> +			rcntl |= (1 << 6);
>  		if (fep->phy_interface == PHY_INTERFACE_MODE_RMII)
           ^^^^ missing "else"

[...]
> +		/* 1G, 100M or 10M */
> +		if (fep->phy_dev) {
> +			if (fep->phy_dev->speed == SPEED_1000)
> +				ecntl |= (1 << 8);
> +			else if (fep->phy_dev->speed == SPEED_100)
> +				rcntl &= ~(1 << 9);
> +			else
> +				rcntl |= (1 << 9);
> +		}
[...]
> +	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
> +		/* enable ENET endian swap */
> +		ecntl |= (1 << 8);

I do not understand why the endian swap bit of ecntl needs to be
set the same in these two different paths, especially as the latter
handles the old faulty imx28 and the former the newly fixed imx6q.
Typo ?

-- 
Ueimor
