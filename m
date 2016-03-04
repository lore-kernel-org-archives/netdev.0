From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next V2 06/16] net: fec: don't clear all rx queue bits
 when just one is being checked
Date: Fri, 4 Mar 2016 09:11:57 +0000
Message-ID: <VI1PR0401MB18550FD3A944783B88BEDB64FFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-7-git-send-email-troy.kisky@boundarydevices.com>
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
Received: from mail-am1on0067.outbound.protection.outlook.com ([157.56.112.67]:63952
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759017AbcCDJMB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 04:12:01 -0500
In-Reply-To: <1456360619-24390-7-git-send-email-troy.kisky@boundarydevices.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com>Sent: Thursday, February 25, 2016 8:37 AM
> To: netdev@vger.kernel.org; davem@davemloft.net; b38611@freescale.com
> Cc: fabio.estevam@freescale.com; l.stach@pengutronix.de; andrew@lunn.ch;
> tremyfr@gmail.com; linux@arm.linux.org.uk; linux-arm-
> kernel@lists.infradead.org; laci@boundarydevices.com; shawnguo@kernel.org;
> johannes@sipsolutions.net; stillcompiling@gmail.com;
> sergei.shtylyov@cogentembedded.com; arnd@arndb.de; Troy Kisky
> <troy.kisky@boundarydevices.com>
> Subject: [PATCH net-next V2 06/16] net: fec: don't clear all rx queue bits when
> just one is being checked
> 
> FEC_ENET_RXF is 3 separate bits, we only check one queue at a time. So, when
> the last queue is being checked, it is bad to remove the interrupt on the 1st
> queue.
> 
> Also, since this is now done in the napi routine and not the interrupt, it is not
> needed.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 610cf6c..791f385 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1338,8 +1338,6 @@ static int fec_rxq(struct net_device *ndev, struct
> fec_enet_private *fep,
>  			break;
>  		pkt_received++;
> 
> -		writel(FEC_ENET_RXF, fep->hwp + FEC_IEVENT);
> -

We should clear the related rx queue ievent, not remove the code.
Pls see commit: db3421c114cf that was submitted by Russell King.

No ack the patch.

>  		/* Check for errors. */
>  		status ^= BD_ENET_RX_LAST;
>  		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH |
> BD_ENET_RX_NO |
> --
> 2.5.0
