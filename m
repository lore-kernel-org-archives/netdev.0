From: Li Frank-B20596 <B20596@freescale.com>
Subject: RE: [PATCH] net: fec: fix the error to get the previous BD entry
Date: Thu, 22 Aug 2013 14:14:38 +0000
Message-ID: <1F990F8245A4214A8CC4BFFBD9F790F908B16A7C@039-SN1MPN1-002.039d.mgd.msft.net>
References: <1377168036-8359-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Duan Fugang-B38611 <B38611@freescale.com>,
	Zhou Luwei-B45643 <B45643@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:45576
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752850Ab3HVOOl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 10:14:41 -0400
In-Reply-To: <1377168036-8359-1-git-send-email-B38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> -	bdp_pre = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
> +	if (bdp == fep->tx_bd_base)
> +		bdp_pre = bdp + TX_RING_SIZE - 1;

You need consider both extended BD format and legacy format. 
The size of BD is difference, you can NOT directly you bdp+TX_RING_SIZE -1

Best regards
Frank Li

> +	else
> +		bdp_pre = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
>  	if ((id_entry->driver_data & FEC_QUIRK_ERR006358) &&
>  	    !(bdp_pre->cbd_sc & BD_ENET_TX_READY)) {
>  		fep->delay_work.trig_tx = true;
> --
> 1.7.1
