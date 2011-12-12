From: Richard Zhao <richard.zhao@freescale.com>
Subject: Re: [PATCH 1/1] net/fec: add KSZ9021RN phy fixup
Date: Mon, 12 Dec 2011 21:51:19 +0800
Message-ID: <20111212135119.GE16835@b20223-02.ap.freescale.net>
References: <1323684558-16796-1-git-send-email-richard.zhao@linaro.org>
 <CAOMZO5DNRrt7ULuBkh9y8bz2_fpCHOcSWxAbJOqTHA2Nrv1V_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Zhao <richard.zhao@linaro.org>, <patches@linaro.org>,
	<netdev@vger.kernel.org>, <jgq516@gmail.com>,
	<eric.miao@linaro.org>, <shawn.guo@linaro.org>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:42248
	"EHLO VA3EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751131Ab1LLNxC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Dec 2011 08:53:02 -0500
Content-Disposition: inline
In-Reply-To: <CAOMZO5DNRrt7ULuBkh9y8bz2_fpCHOcSWxAbJOqTHA2Nrv1V_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2011 at 10:56:48AM -0200, Fabio Estevam wrote:
> On Mon, Dec 12, 2011 at 8:09 AM, Richard Zhao <richard.zhao@linaro.or=
g> wrote:
> > For imx6q sabrelite board, set phy RGMII pad skew.
> >
> > Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
> > ---
> > =A0drivers/net/ethernet/freescale/fec.c | =A0 19 ++++++++++++++++++=
+
> > =A01 files changed, 19 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/eth=
ernet/freescale/fec.c
> > index 112af9b..d3b4463 100644
> > --- a/drivers/net/ethernet/freescale/fec.c
> > +++ b/drivers/net/ethernet/freescale/fec.c
> > @@ -1513,6 +1513,21 @@ static inline void fec_reset_phy(struct plat=
form_device *pdev)
> > =A0}
> > =A0#endif /* CONFIG_OF */
> >
> > +/* For imx6q sabrelite board: set KSZ9021RN RGMII pad skew */
> > +static int ksz9021rn_phy_fixup(struct phy_device *phydev)
> > +{
> > + =A0 =A0 =A0 /* min rx data delay */
> > + =A0 =A0 =A0 phy_write(phydev, 0x0b, 0x8105);
> > + =A0 =A0 =A0 phy_write(phydev, 0x0c, 0x0000);
> > +
> > + =A0 =A0 =A0 /* max rx/tx clock delay, min rx/tx control delay */
> > + =A0 =A0 =A0 phy_write(phydev, 0x0b, 0x8104);
> > + =A0 =A0 =A0 phy_write(phydev, 0x0c, 0xf0f0);
> > + =A0 =A0 =A0 phy_write(phydev, 0x0b, 0x104);
> > +
> > + =A0 =A0 =A0 return 0;
>=20
> This should go to drivers/net/phy/micrel.c.
Why? It's specific to fec.

Thanks
Richard
>=20
> Regards,
>=20
> Fabio Estevam
>=20
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
