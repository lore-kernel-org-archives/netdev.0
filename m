From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv2 0/2] net: fec: Reset ethernet PHY whenever the enet_out
 clock is being enabled
Date: Tue, 12 Jan 2016 15:24:05 +0000
Message-ID: <20160112152405.GZ19062@n2100.arm.linux.org.uk>
References: <1452611876-451-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Greg Ungerer <gerg@uclinux.org>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Nimrod Andy <B38611@freescale.com>,
	Philippe Reynes <tremyfr@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Stefan Agner <stefan@agner.ch>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>,
	Sascha Hauer <kernel@pengutronix.de>,
	Shawn Guo <shawnguo@kernel.org>, devicetree@vger.kernel.org,
	linux-arm-kerne
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60465 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965427AbcALPYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 10:24:39 -0500
Content-Disposition: inline
In-Reply-To: <1452611876-451-1-git-send-email-LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2016 at 04:17:54PM +0100, Lothar Wa=DFmann wrote:
> This patchset fixes a regression introduced by
> commit e8fcfcd5684a ("net: fec: optimize the clock management to save=
 power")
> for ethernet PHYs that are using ENET_OUT as reference clock (on i.MX=
6 or i.MX28)
>=20
> Changes vs. v1:
> - fixed reference to the commit that introduced the regression.
> - dropped patch to use gpiod framework. This should be added later,
>   after the affected DTBs have been updated to specify the correct
>   gpio_flags.
>=20
> Patch overview:
> 1. cleanup patch to remove redundant NULL checks
> 2. call fec_reset_phy() after the ENET_OUT clock has been enabled

I definitely want to test these on my SolidRun boards before these get
merged: the AR8035 on there is configured via pin-straps, and then
further tweaked with PHY quirks.  Resetting with the iMX6 in the
wrong state may result in the AR8035 being reconfigured (even jumping
to a different MDIO address) and certainly would need the PHY quirks
re-running.

--=20
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
