From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable
 call"
Date: Sun, 28 Apr 2013 11:39:17 +0200
Message-ID: <20130428093917.GA4540@electric-eye.fr.zoreil.com>
References: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
 <CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
 <20130426134415.GS1366@pengutronix.de>
 <20130426.143309.1011152996477262852.davem@davemloft.net>
 <20130427090545.GY1366@pengutronix.de>
 <CAHrpEqSi+caO5gSo1BZRGqytxhCOs-OuyjiCaG+7fnsnFBj77g@mail.gmail.com>
 <20130427120619.GA26097@electric-eye.fr.zoreil.com>
 <CAHrpEqTE-oGcdMVk2LMffW0JWNgJ-b_+RakpCOVBy6WxA_ARGg@mail.gmail.com>
 <20130427191600.GA30373@electric-eye.fr.zoreil.com>
 <CAHrpEqRnWXV7jC+QuQe+chiEJCXOkmOz1tEdna2SPfPBQ2E=1Q@mail.gmail.com>
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
Received: from violet.fr.zoreil.com ([92.243.8.30]:49379 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305Ab3D1Jj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 05:39:59 -0400
Content-Disposition: inline
In-Reply-To: <CAHrpEqRnWXV7jC+QuQe+chiEJCXOkmOz1tEdna2SPfPBQ2E=1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank Li <lznuaa@gmail.com> :
[...]
> This is lockless design if only one read and one write. It likes kfifo.
> 
> Assume CPU1 run xmit.  CPU2 run napi fec_enet_tx
> 
> (1)       if (fep->cur_tx == fep->dirty_tx)
> (2)                 netif_stop_queue(ndev);
> 
> if CPU2 update fep->dirty_tx before CPU1 run (1).  the condition is false.
> if CPU2 update fep->dirty_tx after (1) before (2),   netif_stop_queue
> will be called.  There are not problem at this time even though queue
> is not full here.  queue is not empty for sure here. fec_enet_tx will
> be called again when NAPI trigger by one frame finished transfer,
> fec_enet_tx will wake up send queue.

"before" and "after" may not work as expected between different CPU without
explicit synchronization (or barrier). It won't oops but it would be careful
to envision something like drivers/net/ethernet/broadcom/tg3.c::tg3_tx.

-- 
Ueimor
