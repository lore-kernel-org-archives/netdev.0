From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] net/macb: add support for resetting PHY using GPIO
Date: Fri, 11 Dec 2015 09:46:30 +0100
Message-ID: <20151211084630.GW11966@pengutronix.de>
References: <1449683383-5022-1-git-send-email-gregory.clement@free-electrons.com>
 <20151210073756.GA11966@pengutronix.de>
 <871tau8hpj.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:51480 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754121AbbLKIqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 03:46:39 -0500
Content-Disposition: inline
In-Reply-To: <871tau8hpj.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2015 at 04:08:08PM +0100, Gregory CLEMENT wrote:
> Hi Sascha,
> =20
>  On jeu., d=E9c. 10 2015, Sascha Hauer <s.hauer@pengutronix.de> wrote=
:
>=20
> > Hi Gregory,
> >
> > On Wed, Dec 09, 2015 at 06:49:43PM +0100, Gregory CLEMENT wrote:
> >> With device tree it is no more possible to reset the PHY at board
> >> level. Furthermore, doing in the driver allow to power down the PH=
Y when
> >> the network interface is no more used.
> >>=20
> >> The patch introduces a new optional property "phy-reset-gpio" insp=
ired
> >> from the one use for the FEC.
> >
> > I don't think it's a good idea to further extend the usage of this
> > binding. The driver should use the phy-handle property and
> > of_phy_connect() which gives you a proper device node for the phy. =
Then
> > the phy device node should get the reset gpio. I know it's more wor=
k,
>=20
> So you suggest to pass from this binding:
> macb1: ethernet@fc028000 {
> 	phy-mode =3D "rmii";
> 	status =3D "okay";
> 	#address-cells =3D <1>;
> 	#size-cells =3D <0>;
> 	status =3D "okay";
> 	phy-reset-gpio =3D <&pioE 6 GPIO_ACTIVE_HIGH>;
>=20
> 	ethernet-phy@1 {
> 		reg =3D <0x1>;
> 		interrupt-parent =3D <&pioB>;
> 		interrupts =3D <31 IRQ_TYPE_EDGE_FALLING>;
>=20
> 	};
> };
>=20
> to this binding
> macb1: ethernet@fc028000 {
> 	phy-mode =3D "rmii";
> 	status =3D "okay";
> 	#address-cells =3D <1>;
> 	#size-cells =3D <0>;
> 	status =3D "okay";
>=20
> 	ethernet-phy@1 {
> 		reg =3D <0x1>;
> 		interrupt-parent =3D <&pioB>;
> 		interrupts =3D <31 IRQ_TYPE_EDGE_FALLING>;
>                 phy-reset-gpio =3D <&pioE 6 GPIO_ACTIVE_HIGH>;
> 	};
> };

s/phy-reset-gpio/reset-gpios/, but yes.

I had assumed you do not use a phy description in the device tree at al=
l
since the macb driver doesn't use of_phy_connect(). Apparently there ar=
e
other possibilities to connect the phy device nodes with the phys

Sascha

--=20
Pengutronix e.K.                           |                           =
  |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0  =
  |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-555=
5 |
