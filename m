From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH] net/macb: add support for resetting PHY using GPIO
Date: Thu, 10 Dec 2015 16:08:08 +0100
Message-ID: <871tau8hpj.fsf@free-electrons.com>
References: <1449683383-5022-1-git-send-email-gregory.clement@free-electrons.com>
	<20151210073756.GA11966@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:34981 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753798AbbLJPIu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 10:08:50 -0500
In-Reply-To: <20151210073756.GA11966@pengutronix.de> (Sascha Hauer's message
	of "Thu, 10 Dec 2015 08:37:56 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sascha,
=20
 On jeu., d=C3=A9c. 10 2015, Sascha Hauer <s.hauer@pengutronix.de> wrot=
e:

> Hi Gregory,
>
> On Wed, Dec 09, 2015 at 06:49:43PM +0100, Gregory CLEMENT wrote:
>> With device tree it is no more possible to reset the PHY at board
>> level. Furthermore, doing in the driver allow to power down the PHY =
when
>> the network interface is no more used.
>>=20
>> The patch introduces a new optional property "phy-reset-gpio" inspir=
ed
>> from the one use for the FEC.
>
> I don't think it's a good idea to further extend the usage of this
> binding. The driver should use the phy-handle property and
> of_phy_connect() which gives you a proper device node for the phy. Th=
en
> the phy device node should get the reset gpio. I know it's more work,

So you suggest to pass from this binding:
macb1: ethernet@fc028000 {
	phy-mode =3D "rmii";
	status =3D "okay";
	#address-cells =3D <1>;
	#size-cells =3D <0>;
	status =3D "okay";
	phy-reset-gpio =3D <&pioE 6 GPIO_ACTIVE_HIGH>;

	ethernet-phy@1 {
		reg =3D <0x1>;
		interrupt-parent =3D <&pioB>;
		interrupts =3D <31 IRQ_TYPE_EDGE_FALLING>;

	};
};

to this binding
macb1: ethernet@fc028000 {
	phy-mode =3D "rmii";
	status =3D "okay";
	#address-cells =3D <1>;
	#size-cells =3D <0>;
	status =3D "okay";

	ethernet-phy@1 {
		reg =3D <0x1>;
		interrupt-parent =3D <&pioB>;
		interrupts =3D <31 IRQ_TYPE_EDGE_FALLING>;
                phy-reset-gpio =3D <&pioE 6 GPIO_ACTIVE_HIGH>;
	};
};

> but doing it like this gives you additional goodies like proper handl=
ing
> of the max-speed property, a fixed-link if necessary and picking the

Currently there is phy_connect_direct so we can already handle the
preperty of the phy.

> correct phy if there are muliple phys on the bus.

but I agree with this one.

Gregory

>
> Sascha
>
> --=20
> Pengutronix e.K.                           |                         =
    |
> Industrial Linux Solutions                 | http://www.pengutronix.d=
e/  |
> Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0=
    |
> Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5=
555 |

--=20
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
