From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: fec: fix runtime PM when probing MII bus
Date: Mon, 20 Jul 2015 15:59:49 +0200
Message-ID: <20150720135949.GC14842@lunn.ch>
References: <1437400094-11453-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Duan Andy <fugang.duan@freescale.com>,
	Frank Li <Frank.Li@freescale.com>, netdev@vger.kernel.org,
	kernel@pengutronix.de, patchwork-lst@pengutronix.de
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44261 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755850AbbGTOG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 10:06:27 -0400
Content-Disposition: inline
In-Reply-To: <1437400094-11453-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 20, 2015 at 03:48:14PM +0200, Lucas Stach wrote:
> In the case where there is no "mdio" bus specified in the devicetree a plain
> mdiobus_register() will be called, which tries to probe the connected PHY
> by doing mdio_read() on the bus.
> Since 6c3e921b18ed (net: fec: Ensure clocks are enabled while using mdio bus)
> this needs runtime PM to be available, but as RPM is only later set up in the
> FEC probe function those calls will fail, which in turn prevents the FEC
> driver to be registered successfully.
> 
> Fix this by moving the RPM setup calls before the MII bus probing.
> 
> Also move autosuspend init calls before runtime_pm_enable() so that the RPM
> callbacks aren't invoked several times during the probe function.
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
> The offending commit got in with v4.2-rc3, so this should be applied as
> a fix for 4.2.

Hi Lucas

The patch adding runtime PM has been reverted by David.

Are you O.K. if i fold you fix into my patch and resubmit. I will add
your Signed-off-by.

Thanks
	Andrew
