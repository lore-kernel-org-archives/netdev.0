From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH] net: fec: fix runtime PM when probing MII bus
Date: Mon, 20 Jul 2015 16:12:54 +0200
Message-ID: <1437401574.3071.6.camel@pengutronix.de>
References: <1437400094-11453-1-git-send-email-l.stach@pengutronix.de>
	 <20150720135949.GC14842@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Duan Andy <fugang.duan@freescale.com>,
	Frank Li <Frank.Li@freescale.com>, netdev@vger.kernel.org,
	kernel@pengutronix.de, patchwork-lst@pengutronix.de
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50528 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbbGTONA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 10:13:00 -0400
In-Reply-To: <20150720135949.GC14842@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, den 20.07.2015, 15:59 +0200 schrieb Andrew Lunn:
> On Mon, Jul 20, 2015 at 03:48:14PM +0200, Lucas Stach wrote:
> > In the case where there is no "mdio" bus specified in the devicetree a plain
> > mdiobus_register() will be called, which tries to probe the connected PHY
> > by doing mdio_read() on the bus.
> > Since 6c3e921b18ed (net: fec: Ensure clocks are enabled while using mdio bus)
> > this needs runtime PM to be available, but as RPM is only later set up in the
> > FEC probe function those calls will fail, which in turn prevents the FEC
> > driver to be registered successfully.
> > 
> > Fix this by moving the RPM setup calls before the MII bus probing.
> > 
> > Also move autosuspend init calls before runtime_pm_enable() so that the RPM
> > callbacks aren't invoked several times during the probe function.
> > 
> > Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> > ---
> > The offending commit got in with v4.2-rc3, so this should be applied as
> > a fix for 4.2.
> 
> Hi Lucas
> 
> The patch adding runtime PM has been reverted by David.
> 
> Are you O.K. if i fold you fix into my patch and resubmit. I will add
> your Signed-off-by.
> 
Oh, I had missed that. Thanks for the hint.

I'm ok with folding this patch into yours. Please mention that this
fixes the regression seen on i.MX6 witch caused the revert of the
original patch.

Regards,
Lucas

-- 
Pengutronix e.K.             | Lucas Stach                 |
Industrial Linux Solutions   | http://www.pengutronix.de/  |
