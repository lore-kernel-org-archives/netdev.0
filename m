From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH] fec: Do not access unexisting register in Coldfire
Date: Fri, 1 Apr 2016 01:39:27 +0000
Message-ID: <VI1PR0401MB1855CB589F417686E859C76BFF9A0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1459436717-12809-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "troy.kisky@boundarydevices.com" <troy.kisky@boundarydevices.com>,
	"gerg@uclinux.org" <gerg@uclinux.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@nxp.com>
To: Fabio Estevam <festevam@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0084.outbound.protection.outlook.com ([157.55.234.84]:56880
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752422AbcDABy6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 21:54:58 -0400
In-Reply-To: <1459436717-12809-1-git-send-email-festevam@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com> Sent: Thursday, March 31, 2016 11:05 PM
> To: davem@davemloft.net
> Cc: Fugang Duan <fugang.duan@nxp.com>; troy.kisky@boundarydevices.com;
> gerg@uclinux.org; netdev@vger.kernel.org; Fabio Estevam
> <fabio.estevam@nxp.com>
> Subject: [PATCH] fec: Do not access unexisting register in Coldfire
> 
> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> Commit 55cd48c821de ("net: fec: stop the "rcv is not +last, " error
> messages") introduces a write to a register that does not exist in Coldfire.
> 
> Move the FEC_FTRL register access inside the FEC_QUIRK_HAS_RACC 'if' block,
> so that we guarantee it will not be used on Coldfire CPUs.
> 
> Reported-by: Greg Ungerer <gerg@uclinux.org>
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 37c0815..08243c2 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -943,8 +943,8 @@ fec_restart(struct net_device *ndev)
>  		else
>  			val &= ~FEC_RACC_OPTIONS;
>  		writel(val, fep->hwp + FEC_RACC);
> +		writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
>  	}
> -	writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
>  #endif
> 
>  	/*
> --
> 1.9.1

If you stick to do it like this,  you must add comments on the quirk flag FEC_QUIRK_HAS_RACC. 
