From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] net/fec: call netif_carrier_off when not having link
Date: Fri, 26 Jul 2013 12:52:17 +0200
Message-ID: <20130726105217.GG2737@pengutronix.de>
References: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <20130725090352.574b874d@nehalam.linuxnetplumber.net>
 <9848F2DB572E5649BA045B288BE08FBE015C9315@039-SN2MPN1-023.039d.mgd.msft.net>
 <CAGVrzcZMg28Cj=KncE=qDq8qLKY1WkiH5PiwrJECTYdBOe16sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Duan Fugang-B38611 <B38611@freescale.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Uwe =?iso-8859-15?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Li Frank-B20596 <B20596@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	Hector Palacios <hector.palacios@digi.com>,
	Tim Sander <tim.sander@hbm.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:36488 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983Ab3GZKw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 06:52:26 -0400
Content-Disposition: inline
In-Reply-To: <CAGVrzcZMg28Cj=KncE=qDq8qLKY1WkiH5PiwrJECTYdBOe16sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 26, 2013 at 11:06:06AM +0100, Florian Fainelli wrote:
> Hello,
> 
> 2013/7/26 Duan Fugang-B38611 <B38611@freescale.com>:
> > On Fir, 26 Jul 2013 12:04, Stephen Hemminger wrote:
> >>> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> >>> b/drivers/net/ethernet/freescale/fec_main.c
> >>> index 0642006..631bd5a 100644
> >>> --- a/drivers/net/ethernet/freescale/fec_main.c
> >>> +++ b/drivers/net/ethernet/freescale/fec_main.c
> >>> @@ -280,11 +280,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> >>>      unsigned short  status;
> >>>      unsigned int index;
> >>>
> >>> -    if (!fep->link) {
> >>> -            /* Link is down or auto-negotiation is in progress. */
> >>> -            return NETDEV_TX_BUSY;
> >>> -    }
> >>> -
> >>
> >>That is a bug anyway. Since it would cause spin loop in transmit code (even without -rt).
> >>If the driver cared to test it (most drivers just let hardware deal with this situation),
> >>then it should free packet and return TX_OK.
> >
> > When link is down, the logic is
> >         - call netif_stop_queue() to stop queue
> >         - and then notify there have no link using netif_carrier_off().
> 
> netif_carrier_off() is handled by the PHY library before calling the
> adjust_link callback in FEC.
> 
> >
> > But the flow must be handled in fec_enet_adjust_link() function, not in xmit().
> 
> What is special about this hardware that fec_restart() needs to do all
> that work?

The special thing is that the driver is written in a braindamaged way.
fec_restart is kind of a suicide-and-resurrect function which is called
whenever something changes.

> Can't you just update the duplex/speed/pause settings
> directly without doing a full hardware re-init?

Yes, that's possible. I made some initial patches for this which we'll
probably send soon.

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
