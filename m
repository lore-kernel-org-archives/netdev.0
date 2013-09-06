From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [RFC PATCHv2 0/4] Add DT support for fixed PHYs
Date: Fri, 06 Sep 2013 21:42:42 +0100
Message-ID: <2916397.Vz9aZYzLyb@lenovo>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:41082 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070Ab3IFUmr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 16:42:47 -0400
In-Reply-To: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas,

Le vendredi 6 septembre 2013 17:18:17 Thomas Petazzoni a =E9crit :
> Hello,
>=20
> Here is a second version of the patch set that adds a Device Tree
> binding and the related code to support fixed PHYs. Marked as RFC,
> this patch set is obviously not intended for merging in 3.12.

Thanks a lot for continuing on this work, I really like the state of it=
 now.

>=20
> Since the first version, the changes have been:
>=20
>  * Instead of using a 'fixed-link' property inside the Ethernet devic=
e
>    DT node, with a fairly cryptic succession of integer values, we no=
w
>    use a PHY subnode under the Ethernet device DT node, with explicit
>    properties to configure the duplex, speed, pause and other PHY
>    properties.
>=20
>  * The PHY address is automatically allocated by the kernel and no
>    longer visible in the Device Tree binding.
>=20
>  * The PHY device is created directly when the network driver calls
>    of_phy_connect_fixed_link(), and associated to the PHY DT node,
>    which allows the existing of_phy_connect() function to work,
>    without the need to use the deprecated of_phy_connect_fixed_link()=
=2E
>=20
> The things I am not entirely happy with yet are:
>=20
>  * The PHY ID is hardcoded to 0xdeadbeef. Ideally, it should be a
>    properly reserved vendor/device identifier, but it isn't clear how
>    to get one allocated for this purpose.

Right, we should try to get something better, but we obviously cannot u=
se an=20
already allocated OUI for this. Can we ask the Linux foundation or a Li=
nux-
friendly company to allocate one maybe?

>=20
>  * The fixed_phy_register() function in drivers/net/phy/fixed.c has
>    some OF references. So ideally, I would have preferred to put this
>    code in drivers/of/of_mdio.c, but to call get_phy_device(), we nee=
d
>    a reference to the mii_bus structure that represents the fixed MDI=
O
>    bus.

This is not a big deal, not everything in drivers/ is consistent with t=
his,=20
and making the fixed MDIO bus globally accessible does not sound too gr=
eat.

>=20
>  * There is some error management missing in fixed_phy_register(), bu=
t
>    it can certainly be added easily. This RFC is meant to sort out th=
e
>    general idea.

Do you think you could add these to got beyond the RFC state? The patch=
set as=20
it currently is fine with me if you can address these.
--=20
=46lorian
