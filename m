From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 3/4] net/fec: set phy_speed to the optimal frequency 2.5
 MHz
Date: Tue, 20 Sep 2011 16:14:39 +0800
Message-ID: <20110920081438.GB28389@S2100-06.ap.freescale.net>
References: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org>
 <1316346852-17090-4-git-send-email-shawn.guo@linaro.org>
 <20088.17849.987651.196256@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@linaro.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <patches@linaro.org>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:19493
	"EHLO AM1EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753890Ab1ITIFS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 04:05:18 -0400
Content-Disposition: inline
In-Reply-To: <20088.17849.987651.196256@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2011 at 09:50:17AM +0200, Lothar Wa=DFmann wrote:
> Hi,
>=20
> Shawn Guo writes:
> > With the unnecessary 1 bit left-shift on fep->phy_speed during the
> > calculation, the phy_speed always runs at the half frequency of the
> > optimal one 2.5 MHz.
> >=20
> > The patch removes that 1 bit left-shift to get the optimal phy_spee=
d.
> >=20
> > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> > ---
> >  drivers/net/fec.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> > index 5ef0e34..04206e4 100644
> > --- a/drivers/net/fec.c
> > +++ b/drivers/net/fec.c
> > @@ -1007,7 +1007,7 @@ static int fec_enet_mii_init(struct platform_=
device *pdev)
> >  	/*
> >  	 * Set MII speed to 2.5 MHz (=3D clk_get_rate() / 2 * phy_speed)
> >  	 */
> > -	fep->phy_speed =3D DIV_ROUND_UP(clk_get_rate(fep->clk), 5000000) =
<< 1;
> > +	fep->phy_speed =3D DIV_ROUND_UP(clk_get_rate(fep->clk), 5000000);
> >  	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
> > =20
> >  	fep->mii_bus =3D mdiobus_alloc();
> >
> The left shift accounts for the fact, that the MII_SPEED bitfield
> starts at pos 1 in the register. Thus the divider value has to be
> shifted left to occupy the correct bit positions in the register.
>=20
Oops, I missed that.

> According to my measurements on the TX28 the original code works
> correctly!
> Did you measure the actual frequency on the MDC pin after you change?
>=20
I should have done that before sending this patch.  I'm working home
these days and have not got the chance get into the lab.  Yes, I
should have sent this patch as an RFC at least.  Sorry about this,
and thank you for pointing this out.

Will drop this patch from the v2 of the series.

--=20
Regards,
Shawn
