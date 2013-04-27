From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable
 call"
Date: Sat, 27 Apr 2013 21:16:00 +0200
Message-ID: <20130427191600.GA30373@electric-eye.fr.zoreil.com>
References: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
 <CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
 <20130426134415.GS1366@pengutronix.de>
 <20130426.143309.1011152996477262852.davem@davemloft.net>
 <20130427090545.GY1366@pengutronix.de>
 <CAHrpEqSi+caO5gSo1BZRGqytxhCOs-OuyjiCaG+7fnsnFBj77g@mail.gmail.com>
 <20130427120619.GA26097@electric-eye.fr.zoreil.com>
 <CAHrpEqTE-oGcdMVk2LMffW0JWNgJ-b_+RakpCOVBy6WxA_ARGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48789 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756143Ab3D0TQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 15:16:13 -0400
Content-Disposition: inline
In-Reply-To: <CAHrpEqTE-oGcdMVk2LMffW0JWNgJ-b_+RakpCOVBy6WxA_ARGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank Li <lznuaa@gmail.com> :
> 2013/4/27, Francois Romieu <romieu@fr.zoreil.com>:
[...]
> > napi_disable may sleep.
> >
> > fec_restart can be called with spinlock held in fec_enet_adjust_link
> 
> You are right. Spin lock in FEC enet adjust link can be removed when
> remove spinlock in tx and RX.

fec_restart is also called from the netdev watchdog handler (fec_timeout)
and tasklet can't sleep either. You should imho schedule_work from
fec_timeout.

How is the driver supposed to avoid the napi context
fec_enet_tx:netif_queue_stopped vs fec_enet_start_xmit:netif_stop_queue
race since both can run on different cpu without any read/write ordering
enforcement between one thread netif_* and its peer {dirty/cur}_tx ?

-- 
Ueimor
