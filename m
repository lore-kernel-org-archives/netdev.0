From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 3/5] net: dsa: complete dsa_switch_destroy
Date: Sat, 3 Oct 2015 13:25:19 -0700
Message-ID: <561039AF.8080706@gmail.com>
References: <560FE57C.5070608@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:32822 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbbJCUZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 16:25:22 -0400
In-Reply-To: <560FE57C.5070608@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/10/2015 07:26, Neil Armstrong a =C3=A9crit :
> When unbinding dsa, complete the dsa_switch_destroy to unregister the
> fixed link phy then cleanly unregister and destroy the net devices.
>=20
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---

[snip]

> +		port_dn =3D cd->port_dn[port];
> +		if (of_phy_is_fixed_link(port_dn)) {
> +			phydev =3D of_phy_find_device(port_dn);
> +			if (phydev) {
> +				int addr =3D phydev->addr;
> +				phy_device_free(phydev);
> +				of_node_put(port_dn);
> +				fixed_phy_del(addr);

fixed_phy_del() removes the fixed PHY from the platform fixed MDIO bus
list of PHYs, so we should be okay even with switch drivers which
register a link_update callback via fixed_phy_set_link_update(), but I
have not checked that. The sequence of call looks (phy_device_free then
fixed_phy_del) looks sane though.

Eventually this logic might be better moved into net/dsa/slave.c such
that it is easy to see how it balances dsa_slave_phy_setup().

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
