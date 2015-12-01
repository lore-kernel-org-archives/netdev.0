From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCH 1/3] net: fec: Remove redundant checks for NULL clk
 pointer
Date: Tue, 1 Dec 2015 08:24:16 +0100
Message-ID: <20151201082416.4ce7dd4c@ipc1.ka-ro>
References: <1448883168-30742-1-git-send-email-LW@KARO-electronics.de>
	<1448883168-30742-2-git-send-email-LW@KARO-electronics.de>
	<BN3PR0301MB1219B4C39D2D9202A5C96349F50F0@BN3PR0301MB1219.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Greg Ungerer <gerg@uclinux.org>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Philippe Reynes <tremyfr@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	"Stefan Agner" <stefan@agner.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Uwe Kleine-K?nig" <u.kleine-koenig@pengutronix.de>
To: Duan Andy <fugang.duan@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN3PR0301MB1219B4C39D2D9202A5C96349F50F0@BN3PR0301MB1219.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> From: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de> Sent: Monday, Nove=
mber 30, 2015 7:33 PM
> > To: Andrew Lunn; David S. Miller; Estevam Fabio-R49496; Greg Ungere=
r;
> > Kevin Hao; Lothar Wa=C3=9Fmann; Lucas Stach; Duan Fugang-B38611; Ph=
ilippe
> > Reynes; Richard Cochran; Russell King; Sascha Hauer; Stefan Agner; =
linux-
> > kernel@vger.kernel.org; netdev@vger.kernel.org; Jeff Kirsher; Uwe K=
leine-
> > K=C3=B6nig
> > Subject: [PATCH 1/3] net: fec: Remove redundant checks for NULL clk
> > pointer
> >=20
> > NULL is a valid argument to clk_enable()/clk_disable(). Remove redu=
ndant
> > checks before calling those functions.
> >=20
> > Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> > ---
> >  drivers/net/ethernet/freescale/fec_main.c | 23 +++++++++----------=
----
> >  1 file changed, 9 insertions(+), 14 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > b/drivers/net/ethernet/freescale/fec_main.c
> > index d2328fc..e17d74f 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -1873,35 +1873,30 @@ static int fec_enet_clk_enable(struct net_d=
evice
> > *ndev, bool enable)
> >  			}
> >  			mutex_unlock(&fep->ptp_clk_mutex);
> >  		}
> > -		if (fep->clk_ref) {
> > -			ret =3D clk_prepare_enable(fep->clk_ref);
> > -			if (ret)
> > -				goto failed_clk_ref;
> > -		}
> > +
> > +		ret =3D clk_prepare_enable(fep->clk_ref);
> > +		if (ret)
> > +			goto failed_clk_ref;
>=20
> If you want to clean up the code, pls also remove "fep->clk_enet_out"=
 check in this brace.
>=20
I would have to reintroduce it in the later patch to frame the call to
fec_reset_phy().


Lothar Wa=C3=9Fmann
