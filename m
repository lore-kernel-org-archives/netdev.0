From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCH] net: fec: fix enet_out clock handling
Date: Mon, 30 Nov 2015 06:37:02 +0100
Message-ID: <20151130063702.22d24834@ipc1.ka-ro>
References: <1448631550-943-1-git-send-email-LW@KARO-electronics.de>
	<20151130020731.GB32662@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Nimrod Andy <B38611@freescale.com>,
	Philippe Reynes <tremyfr@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Uwe =?UTF-8?B?S2xlaW5lLUvDtm5pZw==?=
	<u.kleine-koenig@pengutronix.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Stefan Agner <stefan@agner.ch>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151130020731.GB32662@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> On Fri, Nov 27, 2015 at 02:39:10PM +0100, Lothar Wa=C3=9Fmann wrote:
> > When ENET_OUT is being used as reference clock for an external PHY,
> > the clock must not be disabled while the PHY is active. Otherwise t=
he
> > PHY may lose its internal state and require a reset to become
> > functional again.
> >=20
> > A symptom for this bug is a network interface that constantly toggl=
es
> > between UP and DOWN state:
> > fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - flow contro=
l rx/tx
> > fec 800f0000.ethernet eth0: Link is Down
> > fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - flow contro=
l rx/tx
> > fec 800f0000.ethernet eth0: Link is Down
>=20
> Hi Lothar
>=20
> When does this up/down happen? During normal operation when the link
> is administrative up?
>=20
If booting with NFSROOT the rootfs cannot be mounted, because when the
interface is brought up the PHY starts toggling the link state.

> When did this start happening? Did it happen before=20
> 8fff755e9f8d net: fec: Ensure clocks are enabled while using mdio bus
>=20
No. The behaviour started exactly with this commit.

Lothar Wa=C3=9Fmann
