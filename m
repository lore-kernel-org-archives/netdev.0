From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/fec: infinite spin on sirq-net-tx on real-time
Date: Mon, 06 Feb 2012 14:39:59 +0100
Message-ID: <1328535599.2220.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328520810-28030-1-git-send-email-hector.palacios@digi.com>
	 <1328522191.2220.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F2FB39B.9010205@digi.com> <1328534721.5882.225.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hector Palacios <hector.palacios@digi.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"jgq516@gmail.com" <jgq516@gmail.com>,
	"tim.sander@hbm.com" <tim.sander@hbm.com>,
	"u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	Zeng Zhaoming <b32542@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:45545 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996Ab2BFNkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 08:40:04 -0500
Received: by wics10 with SMTP id s10so4167804wic.19
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 05:40:02 -0800 (PST)
In-Reply-To: <1328534721.5882.225.camel@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 f=C3=A9vrier 2012 =C3=A0 08:25 -0500, Steven Rostedt a =C3=A9=
crit :
> On Mon, 2012-02-06 at 12:03 +0100, Hector Palacios wrote:
>=20
> > >>
> > >> @@ -530,6 +531,7 @@ fec_stop(struct net_device *ndev)
> > >>   	udelay(10);
> > >>   	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
> > >>   	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
> > >> +	fep->link =3D 0;
> > >
> > >
> > > Why not call netif_stop_queue(dev) here ?
> > >
>=20
> > I'm no network driver expert so I'll leave it up to others to comme=
nt. I just forward=20
> > ported a patch I came across in Freescale's BSP which solves the pr=
oblem in mainline=20
> > and in RT.
>=20
> Hector,
>=20
> Eric's suggestion may also work. Could your revert this patch and add
> the netif_stop_queue(dev) there, and see if it fixes the problems in
> both mainline and -rt?

Not sure it will be enough to call netif_stop_queue(dev) in fec_stop()

We probably need to start the device with its tx queue stopped, then
later when device is really ready wakeup the queue.
