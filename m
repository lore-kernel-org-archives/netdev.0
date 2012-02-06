From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/fec: infinite spin on sirq-net-tx on real-time
Date: Mon, 06 Feb 2012 13:55:24 +0100
Message-ID: <1328532924.2220.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328520810-28030-1-git-send-email-hector.palacios@digi.com>
	 <1328522191.2220.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F2FB39B.9010205@digi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"jgq516@gmail.com" <jgq516@gmail.com>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>,
	"tim.sander@hbm.com" <tim.sander@hbm.com>,
	"u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	Zeng Zhaoming <b32542@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
To: Hector Palacios <hector.palacios@digi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:51302 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754653Ab2BFMz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 07:55:28 -0500
Received: by werb13 with SMTP id b13so4242746wer.19
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 04:55:27 -0800 (PST)
In-Reply-To: <4F2FB39B.9010205@digi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 f=C3=A9vrier 2012 =C3=A0 12:03 +0100, Hector Palacios a =C3=
=A9crit :

> I'm no network driver expert so I'll leave it up to others to comment=
=2E I just forward=20
> ported a patch I came across in Freescale's BSP which solves the prob=
lem in mainline=20
> and in RT.

I understood you didnt write the patch alone, and my question was
addressed to all people involved, not only to you.

=46EC driver needs some bugfixes, before diverging too much from the st=
ate
of the art.

=46or example, fec_enet_alloc_buffers()  doesnt check for allocation
failures :

fep->tx_bounce[i] =3D kmalloc(FEC_ENET_TX_FRSIZE, GFP_KERNEL);

NULL dereferences are then possible later in fec_enet_start_xmit()

By the way, I am not even sure kmalloc(2048) has a guarantee on
alignement of the result, depending on the slub/slab debugging options.
