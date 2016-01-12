From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCHv2 0/2] net: fec: Reset ethernet PHY whenever the enet_out
 clock is being enabled
Date: Tue, 12 Jan 2016 21:30:02 +0100
Message-ID: <20160112203002.GZ24441@pengutronix.de>
References: <1452611876-451-1-git-send-email-LW@KARO-electronics.de>
 <20160112152405.GZ19062@n2100.arm.linux.org.uk>
 <20160112170444.11c412c5@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Lunn <andrew@lunn.ch>, Stefan Agner <stefan@agner.ch>,
	Greg Ungerer <gerg@uclinux.org>,
	Nimrod Andy <B38611@freescale.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	devicetree@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Richard Cochran <richardcochran@gmail.com>,
	Rob Herring <robh+dt@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Kevin Hao <haokexin@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Sascha Hauer <kernel@pengutronix.de>,
	Kumar Gala <galak@codeaurora.org>,
	Lucas Stach <l.stach@pengutronix.de>,
	Shawn Guo <shawnguo@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Philippe Reynes <tremyfr@gmail.com>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48191 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753508AbcALUab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 15:30:31 -0500
Content-Disposition: inline
In-Reply-To: <20160112170444.11c412c5@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, Jan 12, 2016 at 05:04:44PM +0100, Lothar Wa=DFmann wrote:
> > On Tue, Jan 12, 2016 at 04:17:54PM +0100, Lothar Wa=DFmann wrote:
> > > This patchset fixes a regression introduced by
> > > commit e8fcfcd5684a ("net: fec: optimize the clock management to =
save power")
> > > for ethernet PHYs that are using ENET_OUT as reference clock (on =
i.MX6 or i.MX28)
> > >=20
> > > Changes vs. v1:
> > > - fixed reference to the commit that introduced the regression.
> > > - dropped patch to use gpiod framework. This should be added late=
r,
> > >   after the affected DTBs have been updated to specify the correc=
t
> > >   gpio_flags.
> > >=20
> > > Patch overview:
> > > 1. cleanup patch to remove redundant NULL checks
> > > 2. call fec_reset_phy() after the ENET_OUT clock has been enabled
> >=20
> > I definitely want to test these on my SolidRun boards before these =
get
> > merged: the AR8035 on there is configured via pin-straps, and then
> > further tweaked with PHY quirks.  Resetting with the iMX6 in the
> > wrong state may result in the AR8035 being reconfigured (even jumpi=
ng
> > to a different MDIO address) and certainly would need the PHY quirk=
s
> > re-running.
> >=20
> As far as I can tell, all SolidRun boards do not specify the enet_out
> clock in the dtb, so the PHY reset behaviour should be unaffected by
> this patch on those boards, since the additional fec_reset_phy() call=
 is
> framed by:
> if (fep->clk_enet_out) {
> 	...
> }
>=20
> But verifying this explicitly is of course a good idea.

If the SolidRun boards don't do this, this doesn't mean it's safe in
general. The problem is real, isn't it?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
