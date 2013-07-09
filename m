From: Florian Fainelli <florian@openwrt.org>
Subject: Re: Fixed PHY Device Tree usage?
Date: Tue, 09 Jul 2013 19:02:05 +0100
Message-ID: <1733937.SiPWt3mDlH@lenovo>
References: <20130709183312.6c4d052d@skate> <CAGVrzcZ7ZLSDy5sTUR_XuSAUH=5q8ddiXx5n1y680WwGrdFfTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory =?ISO-8859-1?Q?Cl=E9ment?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	afleming@freescale.com
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:58580 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312Ab3GISCL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 14:02:11 -0400
Received: by mail-ee0-f51.google.com with SMTP id e52so3901799eek.24
        for <netdev@vger.kernel.org>; Tue, 09 Jul 2013 11:02:09 -0700 (PDT)
In-Reply-To: <CAGVrzcZ7ZLSDy5sTUR_XuSAUH=5q8ddiXx5n1y680WwGrdFfTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Widening audience

=46lorianLe mardi 9 juillet 2013 17:44:55  Fainelli a =E9crit :
> Hello Thomas,
>=20
> 2013/7/9 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>:
> > Hello,
> >=20
> > We have a case of an hardware platform that uses the mvneta network
> > driver, but instead of the SoC being connected to a PHY, it's conne=
cted
> > directly to a switch, so my understanding is that there's no MDIO b=
us,
> > and we should have a kind of a "fake PHY" to make the mvneta driver
> > believe that the link is up, at a given speed.
>=20
> Good timing, I was about to post questions/suggestions about how we
> should represent fixed PHYs in device tree.
>=20
> > Looking at this problem, I stumbled across the "fixed PHY" driver i=
n
> > drivers/net/phy/fixed.c, which registers a fake "Fixed MDIO bus", a=
nd
> > then provides a fixed_phy_add() API to add one "fake" PHY. This see=
ms
> > to fit my need, except that my ARM platform is obviously Device Tre=
e
> > based, so I'm wondering what I should do. One option is to implemen=
t a
> > Device Tree binding for the fixed PHY driver (the exact DT binding
> > would have to be discussed), but I'm wondering whether describing a
> > fixed PHY in the DT is actually correct, because describing a fixed=
 PHy
> > is not really describing the hardware, the hardware is actually a
> > switch.
>=20
> Well, it does not seem to be too far from the "hardware" reality to
> describe a link between a switch CPU port and an Ethernet MAC as a
> fixed PHY because that is what it really is in fact. Once you have a
> drivers for your switch you can start using this PHY along with its
> corresponding driver.
>=20
> There is a helper: of_phy_connect_fixed_link() in drivers/of/of_mdio.=
c
> is flagged as being a
> temporary solution for Freescale Ethernet drivers to move to somethin=
g else,
> so I would like to discuss what the "something else should be".
>=20
> Here what I would like to see the new "fixed-link" phy node look like=
:
>=20
> ethernet-phy@0 {
>      reg =3D <0>;
>      id =3D "deadbeef";
>      speed =3D <1000>;
>      full-duplex;
>      pause;
>      asym-pause;
> };
>=20
> It has the same properties as the binding described in:
> Documentation/devicetree/bindings/net/fsl-tsec-phy.txt but expressed =
in a
> more explicit way instead of using an array of integers.
>=20
> > Do you have some thoughts about this situation? Maybe there's alrea=
dy
> > some solutions that I'm not aware of?
> >=20
> > Thanks,
>=20
> --
> Florian
--=20
=46lorian
