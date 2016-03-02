From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next V2 01/16] net: fec: only check queue 0 if
 RXF_0/TXF_0 interrupt is set
Date: Wed, 2 Mar 2016 14:57:32 +0000
Message-ID: <VI1PR0401MB18556705FA5E8111DF0C6A44FFBC0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-2-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"laci@boundarydevices.com" <laci@boundarydevices.com>,
	"shawnguo@kernel.org" <shawnguo@kernel.org>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"stillcompiling@gmail.com" <stillcompiling@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"arnd@arndb.de" <arnd@arndb.de>
To: Troy Kisky <troy.kisky@boundarydevices.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"b38611@freescale.com" <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0093.outbound.protection.outlook.com ([157.55.234.93]:38440
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750936AbcCBO5g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 09:57:36 -0500
In-Reply-To: <1456360619-24390-2-git-send-email-troy.kisky@boundarydevices.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Thursday, February 25, 2016 8:37 AM
> To: netdev@vger.kernel.org; davem@davemloft.net; b38611@freescale.com
> Cc: fabio.estevam@freescale.com; l.stach@pengutronix.de; andrew@lunn.ch;
> tremyfr@gmail.com; linux@arm.linux.org.uk; linux-arm-
> kernel@lists.infradead.org; laci@boundarydevices.com; shawnguo@kernel.org;
> johannes@sipsolutions.net; stillcompiling@gmail.com;
> sergei.shtylyov@cogentembedded.com; arnd@arndb.de; Troy Kisky
> <troy.kisky@boundarydevices.com>
> Subject: [PATCH net-next V2 01/16] net: fec: only check queue 0 if
> RXF_0/TXF_0 interrupt is set
> 
> Before queue 0 was always checked if any queue caused an interrupt.
> It is better to just mark queue 0 if queue 0 has caused an interrupt.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index bad0ba2..dbac975 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1534,14 +1534,14 @@ fec_enet_collect_events(struct fec_enet_private
> *fep, uint int_events)
>  	if (int_events == 0)
>  		return false;
> 
> -	if (int_events & FEC_ENET_RXF)
> +	if (int_events & FEC_ENET_RXF_0)
>  		fep->work_rx |= (1 << 2);
>  	if (int_events & FEC_ENET_RXF_1)
>  		fep->work_rx |= (1 << 0);
>  	if (int_events & FEC_ENET_RXF_2)
>  		fep->work_rx |= (1 << 1);
> 
> -	if (int_events & FEC_ENET_TXF)
> +	if (int_events & FEC_ENET_TXF_0)
>  		fep->work_tx |= (1 << 2);
>  	if (int_events & FEC_ENET_TXF_1)
>  		fep->work_tx |= (1 << 0);
> --
> 2.5.0

Acked-by: Fugang Duan <Fugang.duan@nxp.com>
