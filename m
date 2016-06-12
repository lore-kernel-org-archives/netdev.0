From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next RFT] net: fec: handle small PHY reset durations
 more precisely
Date: Sun, 12 Jun 2016 05:16:02 +0000
Message-ID: <VI1PR0401MB1855C3B3CF0634BAE6D8063CFF520@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1465418567-2694-1-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Fabio Estevam <fabio.estevam@nxp.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"holgerschurig@gmail.com" <holgerschurig@gmail.com>,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stefan Wahren <stefan.wahren@i2se.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0096.outbound.protection.outlook.com ([157.56.112.96]:35760
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750773AbcFLFQJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 01:16:09 -0400
In-Reply-To: <1465418567-2694-1-git-send-email-stefan.wahren@i2se.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Wahren <stefan.wahren@i2se.com> Sent: Thursday, June 09, 2016 4:43 AM
> To: David Miller <davem@davemloft.net>; Fugang Duan
> <fugang.duan@nxp.com>
> Cc: Fabio Estevam <fabio.estevam@nxp.com>; Lucas Stach
> <l.stach@pengutronix.de>; andrew@lunn.ch; holgerschurig@gmail.com; Troy
> Kisky <troy.kisky@boundarydevices.com>; linux-arm-kernel@lists.infradead.org;
> netdev@vger.kernel.org; Stefan Wahren <stefan.wahren@i2se.com>
> Subject: [PATCH net-next RFT] net: fec: handle small PHY reset durations more
> precisely
> 
> Since msleep is based on jiffies the PHY reset could take longer than expected.
> So use msleep for values greater than 20 msec otherwise usleep_range.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 3c0255e..49f8055 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3191,7 +3191,12 @@ static void fec_reset_phy(struct platform_device
> *pdev)
>  		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
>  		return;
>  	}
> -	msleep(msec);
> +
> +	if (msec > 20)
> +		msleep(msec);
> +	else
> +		usleep_range(msec * 1000, msec * 1000 + 1000);
> +
>  	gpio_set_value_cansleep(phy_reset, !active_high);  }  #else /*
> CONFIG_OF */
> --
> 1.7.9.5

Thanks. You are correct base on Documentation/timers/timers-howto.txt.

Acked-by: Fugang Duan <fugang.duan@nxp.com>
