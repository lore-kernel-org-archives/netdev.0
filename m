From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net/fec: call netif_carrier_off when not having link
Date: Thu, 25 Jul 2013 09:03:52 -0700
Message-ID: <20130725090352.574b874d@nehalam.linuxnetplumber.net>
References: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>, kernel@pengutronix.de,
	Hector Palacios <hector.palacios@digi.com>,
	Tim Sander <tim.sander@hbm.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Uwe =?ISO-8859-1?B?S2xlaW5lLUv2bmln?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:40740 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755778Ab3GYQDz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 12:03:55 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz10so1177788pad.2
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 09:03:55 -0700 (PDT)
In-Reply-To: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Jul 2013 15:27:55 +0200
Uwe Kleine-K=F6nig  <u.kleine-koenig@pengutronix.de> wrote:

> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/=
ethernet/freescale/fec_main.c
> index 0642006..631bd5a 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -280,11 +280,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct =
net_device *ndev)
>  	unsigned short	status;
>  	unsigned int index;
> =20
> -	if (!fep->link) {
> -		/* Link is down or auto-negotiation is in progress. */
> -		return NETDEV_TX_BUSY;
> -	}
> -

That is a bug anyway. Since it would cause spin loop in transmit
code (even without -rt). If the driver cared to test it (most
drivers just let hardware deal with this situation), then it should
free packet and return TX_OK.
