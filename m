From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCH] can: Fix bug in suspend/resume
Date: Thu, 13 Nov 2014 12:32:18 +0100
Message-ID: <20141113123218.79850236@ipc1.ka-ro>
References: <a44efc1fb0144cca9d0c4851cc51db25@BL2FFO11FD024.protection.gbl>
	<546484D9.4030005@pengutronix.de>
	<54648BF4.60007@pengutronix.de>
	<9455da2b86c74d5aafe9bf118edec7bb@BN1AFFO11FD045.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	Michal Simek <michals@xilinx.com>,
	Soren Brinkmann <sorenb@xilinx.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <9455da2b86c74d5aafe9bf118edec7bb@BN1AFFO11FD045.protection.gbl>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Appana Durga Kedareswara Rao wrote:
> Hi Marc,
>=20
> -----Original Message-----
> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
> Sent: Thursday, November 13, 2014 4:16 PM
> To: Appana Durga Kedareswara Rao; wg@grandegger.com; Michal Simek; So=
ren Brinkmann; grant.likely@linaro.org; robh+dt@kernel.org
> Cc: linux-can@vger.kernel.org; netdev@vger.kernel.org; linux-arm-kern=
el@lists.infradead.org; linux-kernel@vger.kernel.org; devicetree@vger.k=
ernel.org; Appana Durga Kedareswara Rao
> Subject: Re: [PATCH] can: Fix bug in suspend/resume
>=20
> On 11/13/2014 11:15 AM, Marc Kleine-Budde wrote:
> > On 11/13/2014 07:58 AM, Kedareswara rao Appana wrote:
> >> When accessing the priv structure use container_of instead of dev_=
get_drvdata.
> >
> > Why?
>=20
> The drvdata here is the struct net_device, not the platform device.
> Please state this in the commit message.
>=20
> If I understand the code correct, you can make use of the existing he=
lper function to_platform_device():
>=20
> http://lxr.free-electrons.com/source/include/linux/platform_device.h#=
L42
>=20
> Thanks for the suggestion.
>  Will use this macro(to_platform_device)  .
>=20
> >
> >> Enable the clocks in the suspend before accessing the registers of=
 the CAN.
> >>
> >> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> >> ---
> >>  drivers/net/can/xilinx_can.c |   20 ++++++++++++++++++--
> >>  1 files changed, 18 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/drivers/net/can/xilinx_can.c
> >> b/drivers/net/can/xilinx_can.c index 5e8b560..63ef645 100644
> >> --- a/drivers/net/can/xilinx_can.c
> >> +++ b/drivers/net/can/xilinx_can.c
> >> @@ -972,15 +972,30 @@ static const struct net_device_ops xcan_netd=
ev_ops =3D {
> >>   */
> >>  static int __maybe_unused xcan_suspend(struct device *dev)  {
> >> -    struct platform_device *pdev =3D dev_get_drvdata(dev);
> >> +    struct platform_device *pdev =3D container_of(dev,
> >> +                    struct platform_device, dev);
> >>      struct net_device *ndev =3D platform_get_drvdata(pdev);
> >>      struct xcan_priv *priv =3D netdev_priv(ndev);
>
Why not simply:
	struct net_device *ndev =3D dev_get_drvdata(dev);

There is no need for a struct platform_device* at all.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
