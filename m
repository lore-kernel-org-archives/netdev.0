From: "Frank.Li@freescale.com" <Frank.Li@freescale.com>
Subject: RE: [PATCH] net: fec: fix potential issue to avoid fec interrupt
 lost and crc error
Date: Thu, 20 Feb 2014 14:12:08 +0000
Message-ID: <6ee3541ba7d14a57aea08d503bb7a61d@BLUPR03MB486.namprd03.prod.outlook.com>
References: <1392891279-11194-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0189.outbound.protection.outlook.com ([207.46.163.189]:25335
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754470AbaBTO14 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 09:27:56 -0500
In-Reply-To: <1392891279-11194-1-git-send-email-B38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Fugang Duan [mailto:B38611@freescale.com]
> Sent: Thursday, February 20, 2014 4:15 AM
> To: Li Frank-B20596; davem@davemloft.net
> Cc: netdev@vger.kernel.org
> Subject: [PATCH] net: fec: fix potential issue to avoid fec interrupt lost
> and crc error
> 
> The current flow: Set TX BD ready, and then set "INT" and "PINS" bit to
> enable tx interrupt generation and crc checksum.
> 
> There has potential issue like as:
> CPU			fec uDMA
> Set tx ready bit
> 			uDMA start the BD transmission
> Set "INT" bit
> Set "PINS" bit
> ...
> 
> Above situation cause fec tx interrupt lost and fec MAC don't do CRC checksum.
> The patch fix the potential issue.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Acked-by: Frank Li <Frank.li@freescale.com>

> ---
>  drivers/net/ethernet/freescale/fec_main.c |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 45b8b22..739608b 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -390,12 +390,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct
> net_device *ndev)
>  			netdev_err(ndev, "Tx DMA memory map failed\n");
>  		return NETDEV_TX_OK;
>  	}
> -	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
> -	 * it's the last BD of the frame, and to put the CRC on the end.
> -	 */
> -	status |= (BD_ENET_TX_READY | BD_ENET_TX_INTR
> -			| BD_ENET_TX_LAST | BD_ENET_TX_TC);
> -	bdp->cbd_sc = status;
> 
>  	if (fep->bufdesc_ex) {
> 
> @@ -417,6 +411,13 @@ fec_enet_start_xmit(struct sk_buff *skb, struct
> net_device *ndev)
>  		}
>  	}
> 
> +	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
> +	 * it's the last BD of the frame, and to put the CRC on the end.
> +	 */
> +	status |= (BD_ENET_TX_READY | BD_ENET_TX_INTR
> +			| BD_ENET_TX_LAST | BD_ENET_TX_TC);
> +	bdp->cbd_sc = status;
> +
>  	bdp_pre = fec_enet_get_prevdesc(bdp, fep);
>  	if ((id_entry->driver_data & FEC_QUIRK_ERR006358) &&
>  	    !(bdp_pre->cbd_sc & BD_ENET_TX_READY)) {
> --
> 1.7.2.rc3
> 
