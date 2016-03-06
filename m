From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH RESEND] net:fec:Fix error checking in the function
 fec_enet_init
Date: Sun, 6 Mar 2016 00:00:11 +0000
Message-ID: <HE1PR0401MB184955CA43469AEE38664467FFB00@HE1PR0401MB1849.eurprd04.prod.outlook.com>
References: <1457121614-9360-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "b38611@freescale.com" <b38611@freescale.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>,
	"haokexin@gmail.com" <haokexin@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0075.outbound.protection.outlook.com ([157.56.112.75]:40592
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750836AbcCFAAR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 19:00:17 -0500
In-Reply-To: <1457121614-9360-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicholas Krause <xerofoify@gmail.com> Sent: Saturday, March 05, 2016 4:00 AM
> To: davem@davemloft.net
> Cc: b38611@freescale.com; andrew@lunn.ch; fabio.estevam@freescale.com;
> l.stach@pengutronix.de; rmk+kernel@arm.linux.org.uk; tremyfr@gmail.com;
> johannes@sipsolutions.net; u.kleine-koenig@pengutronix.de;
> haokexin@gmail.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH RESEND] net:fec:Fix error checking in the function
> fec_enet_init
> 
> This fixes error checking in the function fec_enet_init to properly check if the
> internal call to the function fec_enet_alloc_queue fails and if so immediately
> return the error code to the caller for it to handle it's own intended error paths.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index b349e6f..18c625f 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3123,6 +3123,7 @@ static int fec_enet_init(struct net_device *ndev)
>  	dma_addr_t bd_dma;
>  	int bd_size;
>  	unsigned int i;
> +	int ret;
> 
>  #if defined(CONFIG_ARM)
>  	fep->rx_align = 0xf;
> @@ -3132,7 +3133,9 @@ static int fec_enet_init(struct net_device *ndev)
>  	fep->tx_align = 0x3;
>  #endif
> 
> -	fec_enet_alloc_queue(ndev);
> +	ret = fec_enet_alloc_queue(ndev);
> +	if (ret)
> +		return ret;
> 
>  	if (fep->bufdesc_ex)
>  		fep->bufdesc_size = sizeof(struct bufdesc_ex);
> --
> 2.1.4
Thanks.

Acked-by: Fugang Duan <Fugang.duan@nxp.com>
