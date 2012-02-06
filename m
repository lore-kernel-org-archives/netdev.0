From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fec: fix tx bounce handling
Date: Mon, 06 Feb 2012 17:25:09 +0100
Message-ID: <1328545509.2220.70.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328520810-28030-1-git-send-email-hector.palacios@digi.com>
	 <1328532924.2220.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328535883.2220.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <201202061709.31406.tim.sander@hbm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hector Palacios <hector.palacios@digi.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shawn.guo@linaro.org, jgq516@gmail.com,
	rostedt@goodmis.org, u.kleine-koenig@pengutronix.de,
	tglx@linutronix.de, Zeng Zhaoming <b32542@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: Tim Sander <tim.sander@hbm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35181 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753003Ab2BFQZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 11:25:13 -0500
Received: by wgbdt10 with SMTP id dt10so6394380wgb.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 08:25:12 -0800 (PST)
In-Reply-To: <201202061709.31406.tim.sander@hbm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 f=C3=A9vrier 2012 =C3=A0 17:09 +0100, Tim Sander a =C3=A9cr=
it :
> Hi
>=20
> I forward ported the patch i have for 3.0-rt (which was working on a =
quick test)=20
> to the net-dev  branch with the patch from Eric mixed in.=20
>=20
> But a quick test revealed that dmesg is full of:
> eth0: tx queue full!.
> Not good! Any suggestions on this?
>=20

Please dont mix things.

My patch has nothing to do with the TX ring handling.

> Tim
>=20
> Heres my patch for 3.3:
>=20
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ether=
net/freescale/fec.c
> index 336edd7..74d5865 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -284,11 +284,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct =
net_device *ndev)
>         unsigned short  status;
>         unsigned long flags;
> =20
> -       if (!fep->link) {



We first must fix the driver before removing this work around.


> -               /* Link is down or autonegotiation is in progress. */
> -               return NETDEV_TX_BUSY;
> -       }
> -

In fact, returning NETDEV_TX_BUSY here is proof driver is buggy.

We should not enter fec_enet_start_xmit() is device is not ready to sen=
d
frames.

There are missing netif_stop_queue(dev) in this driver.
