From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: phy: Add config option to specify external switch port to be used if switch is used as PHY
Date: Thu, 8 Sep 2011 12:13:15 +0200
Message-ID: <20110908101315.GA27909@electric-eye.fr.zoreil.com>
References: <4E68668F.9060008@televic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>
To: Lambrecht =?utf-8?Q?J=C3=BCrgen?= <J.Lambrecht@TELEVIC.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37945 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769Ab1IHKcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 06:32:17 -0400
Content-Disposition: inline
In-Reply-To: <4E68668F.9060008@televic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lambrecht J=C3=BCrgen <J.Lambrecht@TELEVIC.com> :
[...]
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 6c58da2..016437a 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -112,7 +112,14 @@ int mdiobus_register(struct mii_bus *bus)
>          if (bus->reset)
>                  bus->reset(bus);
>=20
> +       /* The config below is always availble with CONFIG_PHYLIB. If=
 0, the
> +          behavior is as before without this patch (or P0 of the swi=
tch is
> +          taken because it is the first one found). */
> +#if CONFIG_SWITCH_PHY
> +       i =3D CONFIG_SWITCH_PHY;
> +#else
>          for (i =3D 0; i < PHY_MAX_ADDR; i++) {
> +#endif
>                  if ((bus->phy_mask & (1 << i)) =3D=3D 0) {
>                          struct phy_device *phydev;

This config option may help your platform but it is nowhere reusable on=
 a
slightly different one (each mii_bus behavior is changed).

Which driver(s) do you use that you can not set phy_mask directly ?

--=20
Ueimor
