From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next V3 03/16] net: fec: return IRQ_HANDLED if
 fec_ptp_check_pps_event handled it
Date: Wed, 6 Apr 2016 09:12:31 +0000
Message-ID: <VI1PR0401MB18556863D9FD7D4590D2DD38FF9F0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
 <1459909562-22865-4-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Fabio Estevam <fabio.estevam@nxp.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"gerg@uclinux.org" <gerg@uclinux.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"stillcompiling@gmail.com" <stillcompiling@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"arnd@arndb.de" <arnd@arndb.de>
To: Troy Kisky <troy.kisky@boundarydevices.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"lznuaa@gmail.com" <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0056.outbound.protection.outlook.com ([157.56.112.56]:47825
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933911AbcDFJMg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 05:12:36 -0400
In-Reply-To: <1459909562-22865-4-git-send-email-troy.kisky@boundarydevices.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Wednesday, April 06, 2016 10:26 AM
> To: netdev@vger.kernel.org; davem@davemloft.net; Fugang Duan
> <fugang.duan@nxp.com>; lznuaa@gmail.com
> Cc: Fabio Estevam <fabio.estevam@nxp.com>; l.stach@pengutronix.de;
> andrew@lunn.ch; tremyfr@gmail.com; gerg@uclinux.org; linux-arm-
> kernel@lists.infradead.org; johannes@sipsolutions.net;
> stillcompiling@gmail.com; sergei.shtylyov@cogentembedded.com;
> arnd@arndb.de; Troy Kisky <troy.kisky@boundarydevices.com>
> Subject: [PATCH net-next V3 03/16] net: fec: return IRQ_HANDLED if
> fec_ptp_check_pps_event handled it
> 
> fec_ptp_check_pps_event will return 1 if FEC_T_TF_MASK caused an interrupt.
> Don't return IRQ_NONE in this case.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> 
> ---
> v3: New patch, came from feedback from another patch.
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index a011719..7993040 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1579,8 +1579,8 @@ fec_enet_interrupt(int irq, void *dev_id)
>  	}
> 
>  	if (fep->ptp_clock)
> -		fec_ptp_check_pps_event(fep);
> -
> +		if (fec_ptp_check_pps_event(fep))
> +			ret = IRQ_HANDLED;
>  	return ret;
>  }
> 
> --
> 2.5.0

Acked-by: Fugang Duan <fugang.duan@nxp.com>
