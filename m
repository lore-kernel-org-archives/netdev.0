From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCH] net: fec: fix enet_out clock handling
Date: Mon, 30 Nov 2015 07:56:17 +0100
Message-ID: <20151130075617.0f880cd1@ipc1.ka-ro>
References: <1448631550-943-1-git-send-email-LW@KARO-electronics.de>
	<BN3PR0301MB1219C4D8E1B09F1AE27E18FAF5020@BN3PR0301MB1219.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Philippe Reynes <tremyfr@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Uwe Kleine-K?nig <u.kleine-koenig@pengutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stefan Agner <stefan@agner.ch>
To: Duan Andy <fugang.duan@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN3PR0301MB1219C4D8E1B09F1AE27E18FAF5020@BN3PR0301MB1219.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> From: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de> Sent: Friday, Nove=
mber 27, 2015 9:39 PM
> > To: Andrew Lunn; David S. Miller; Estevam Fabio-R49496; Kevin Hao; =
Lothar
> > Wa=C3=9Fmann; Lucas Stach; Duan Fugang-B38611; Philippe Reynes; Rus=
sell King;
> > Uwe Kleine-K=C3=B6nig; linux-kernel@vger.kernel.org; netdev@vger.ke=
rnel.org;
> > Stefan Agner
> > Subject: [PATCH] net: fec: fix enet_out clock handling
> >=20
> > When ENET_OUT is being used as reference clock for an external PHY,=
 the
> > clock must not be disabled while the PHY is active. Otherwise the P=
HY may
> > lose its internal state and require a reset to become functional ag=
ain.
> >=20
> > A symptom for this bug is a network interface that constantly toggl=
es
> > between UP and DOWN state:
> > fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - flow contro=
l
> > rx/tx fec 800f0000.ethernet eth0: Link is Down fec 800f0000.etherne=
t eth0:
> > Link is Up - 100Mbps/Full - flow control rx/tx fec 800f0000.etherne=
t eth0:
> > Link is Down [...]
> >=20
> > Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> > ---
> >  drivers/net/ethernet/freescale/fec_main.c | 34 +++++++++++++------=
------
> > ------
> >  1 file changed, 14 insertions(+), 20 deletions(-)
> >=20
>=20
> When MAC is not ready with clocks disabled,  it is not necessary to s=
upply clock for PHY. In fact, PHY also is not ready, why does it need c=
lock ?
> For your problem, you must add PHY reset in your dts file to resolve =
your problem.
>=20
The phy-reset-gpio property is set in the DTB. But fec_reset_phy()
which asserts the RESET is only called from within the probe() function=
=2E
It should probably be called from fec_restart() instead?


Lothar Wa=C3=9Fmann
