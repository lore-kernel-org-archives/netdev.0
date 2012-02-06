From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] net/fec: infinite spin on sirq-net-tx on real-time
Date: Mon, 06 Feb 2012 08:25:21 -0500
Message-ID: <1328534721.5882.225.camel@gandalf.stny.rr.com>
References: <1328520810-28030-1-git-send-email-hector.palacios@digi.com>
	 <1328522191.2220.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F2FB39B.9010205@digi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"jgq516@gmail.com" <jgq516@gmail.com>,
	"tim.sander@hbm.com" <tim.sander@hbm.com>,
	"u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	Zeng Zhaoming <b32542@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: Hector Palacios <hector.palacios@digi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:44334 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004Ab2BFNZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 08:25:24 -0500
In-Reply-To: <4F2FB39B.9010205@digi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-02-06 at 12:03 +0100, Hector Palacios wrote:

> >>
> >> @@ -530,6 +531,7 @@ fec_stop(struct net_device *ndev)
> >>   	udelay(10);
> >>   	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
> >>   	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
> >> +	fep->link = 0;
> >
> >
> > Why not call netif_stop_queue(dev) here ?
> >

> I'm no network driver expert so I'll leave it up to others to comment. I just forward 
> ported a patch I came across in Freescale's BSP which solves the problem in mainline 
> and in RT.

Hector,

Eric's suggestion may also work. Could your revert this patch and add
the netif_stop_queue(dev) there, and see if it fixes the problems in
both mainline and -rt?

Thanks!

-- Steve
