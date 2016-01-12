From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCHv2 0/2] net: fec: Reset ethernet PHY whenever the
 enet_out clock is being enabled
Date: Tue, 12 Jan 2016 17:04:44 +0100
Message-ID: <20160112170444.11c412c5@ipc1.ka-ro>
References: <1452611876-451-1-git-send-email-LW@KARO-electronics.de>
	<20160112152405.GZ19062@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
	Uwe =?UTF-8?B?S2xlaW5lLUvDtm5pZw==?=
	<u.kleine-koenig@pengutronix.de>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>,
	Sascha Hauer <kernel@pengutronix.de>,
	Shawn Guo <shawnguo@kernel.org>, devicetree@vger.kernel.org,
	linux-arm-kern
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160112152405.GZ19062@n2100.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> On Tue, Jan 12, 2016 at 04:17:54PM +0100, Lothar Wa=C3=9Fmann wrote:
> > This patchset fixes a regression introduced by
> > commit e8fcfcd5684a ("net: fec: optimize the clock management to sa=
ve power")
> > for ethernet PHYs that are using ENET_OUT as reference clock (on i.=
MX6 or i.MX28)
> >=20
> > Changes vs. v1:
> > - fixed reference to the commit that introduced the regression.
> > - dropped patch to use gpiod framework. This should be added later,
> >   after the affected DTBs have been updated to specify the correct
> >   gpio_flags.
> >=20
> > Patch overview:
> > 1. cleanup patch to remove redundant NULL checks
> > 2. call fec_reset_phy() after the ENET_OUT clock has been enabled
>=20
> I definitely want to test these on my SolidRun boards before these ge=
t
> merged: the AR8035 on there is configured via pin-straps, and then
> further tweaked with PHY quirks.  Resetting with the iMX6 in the
> wrong state may result in the AR8035 being reconfigured (even jumping
> to a different MDIO address) and certainly would need the PHY quirks
> re-running.
>=20
As far as I can tell, all SolidRun boards do not specify the enet_out
clock in the dtb, so the PHY reset behaviour should be unaffected by
this patch on those boards, since the additional fec_reset_phy() call i=
s
framed by:
if (fep->clk_enet_out) {
	...
}

But verifying this explicitly is of course a good idea.


Lothar Wa=C3=9Fmann
