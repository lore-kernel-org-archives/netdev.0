From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phylib: add driver for aquantia phy
Date: Thu, 23 Jul 2015 21:39:23 -0700
Message-ID: <55B1C17B.1000704@gmail.com>
References: <1437709605-42980-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: shh.xie@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:34587 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563AbbGXEj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 00:39:26 -0400
Received: by obre1 with SMTP id e1so9774290obr.1
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 21:39:25 -0700 (PDT)
In-Reply-To: <1437709605-42980-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/23/15 20:46, shh.xie@gmail.com a =C3=A9crit :
> From: Shaohui Xie <Shaohui.Xie@freescale.com>
>=20
> This patch added driver to support Aquantia PHYs AQ1202, AQ2104, AQR1=
05,
> AQR405, which accessed through clause 45.

Could you prefix your patches with "net: phy: " in the future to be
consistent with what is typically used?

See comments below

>=20
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---

[snip]

> +static int aquantia_read_status(struct phy_device *phydev)
> +{
> +	int reg;
> +
> +	phydev->speed =3D SPEED_10000;
> +	phydev->duplex =3D DUPLEX_FULL;
> +
> +	reg =3D phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
> +	reg =3D phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
> +	if (reg & MDIO_STAT1_LSTATUS)
> +		phydev->link =3D 1;
> +	else
> +		phydev->link =3D 0;
> +
> +	reg =3D phy_read_mmd(phydev, MDIO_MMD_AN, 0xc800);
> +	mdelay(10);
> +	reg =3D phy_read_mmd(phydev, MDIO_MMD_AN, 0xc800);
> +	if (reg =3D=3D 0x9)
> +		phydev->speed =3D SPEED_2500;
> +	else if (reg =3D=3D 0x5)
> +		phydev->speed =3D SPEED_1000;
> +	else if (reg =3D=3D 0x3)
> +		phydev->speed =3D SPEED_100;

Could we use a switch/case here? How about 10Mbits/sec and duplex are w=
e
guaranteed to be full-duplex at e.g: 100 or 10Mbits/sec?

> +
> +	return 0;
> +}
> +
> +static struct phy_driver aquantia_driver[] =3D {
> +{
> +	.phy_id		=3D PHY_ID_AQ1202,
> +	.phy_id_mask	=3D 0xfffffff0,
> +	.name		=3D "Aquantia AQ1202",
> +	.features	=3D PHY_GBIT_FEATURES,

If these are 10GbE PHYs, should not we start defining a new features
bitmask here to reflect that accordingly? That way MAC

> +	.soft_reset	=3D aquantia_soft_reset,
> +	.aneg_done	=3D aquantia_aneg_done,
> +	.config_init    =3D aquantia_config_init,
> +	.config_aneg    =3D aquantia_config_aneg,
> +	.read_status	=3D aquantia_read_status,
> +	.driver		=3D { .owner =3D THIS_MODULE,},
> +},
> +{
> +	.phy_id		=3D PHY_ID_AQ2104,
> +	.phy_id_mask	=3D 0xfffffff0,
> +	.name		=3D "Aquantia AQ2104",
> +	.features	=3D PHY_GBIT_FEATURES,
> +	.soft_reset	=3D aquantia_soft_reset,
> +	.aneg_done	=3D aquantia_aneg_done,
> +	.config_init    =3D aquantia_config_init,
> +	.config_aneg    =3D aquantia_config_aneg,
> +	.read_status	=3D aquantia_read_status,
> +	.driver		=3D { .owner =3D THIS_MODULE,},
> +},
> +{
> +	.phy_id		=3D PHY_ID_AQR105,
> +	.phy_id_mask	=3D 0xfffffff0,
> +	.name		=3D "Aquantia AQR105",
> +	.features	=3D PHY_GBIT_FEATURES,
> +	.soft_reset	=3D aquantia_soft_reset,
> +	.aneg_done	=3D aquantia_aneg_done,
> +	.config_init    =3D aquantia_config_init,
> +	.config_aneg    =3D aquantia_config_aneg,
> +	.read_status	=3D aquantia_read_status,
> +	.driver		=3D { .owner =3D THIS_MODULE,},
> +},
> +{
> +	.phy_id		=3D PHY_ID_AQR405,
> +	.phy_id_mask	=3D 0xfffffff0,
> +	.name		=3D "Aquantia AQR405",
> +	.features	=3D PHY_GBIT_FEATURES,
> +	.soft_reset	=3D aquantia_soft_reset,
> +	.aneg_done	=3D aquantia_aneg_done,
> +	.config_init    =3D aquantia_config_init,
> +	.config_aneg    =3D aquantia_config_aneg,
> +	.read_status	=3D aquantia_read_status,
> +	.driver		=3D { .owner =3D THIS_MODULE,},
> +},
> +};
> +
> +static int __init aquantia_init(void)
> +{
> +	return phy_drivers_register(aquantia_driver,
> +				    ARRAY_SIZE(aquantia_driver));
> +}
> +
> +static void __exit aquantia_exit(void)
> +{
> +	return phy_drivers_unregister(aquantia_driver,
> +				      ARRAY_SIZE(aquantia_driver));
> +}
> +
> +module_init(aquantia_init);
> +module_exit(aquantia_exit);
> +
> +static struct mdio_device_id __maybe_unused aquantia_tbl[] =3D {
> +	{ PHY_ID_AQ1202, 0xfffffff0 },
> +	{ PHY_ID_AQ2104, 0xfffffff0 },
> +	{ PHY_ID_AQR105, 0xfffffff0 },
> +	{ PHY_ID_AQR405, 0xfffffff0 },
> +	{ }
> +};
> +
> +MODULE_DEVICE_TABLE(mdio, aquantia_tbl);
> +
> +MODULE_DESCRIPTION("Aquantia PHY driver");
> +MODULE_AUTHOR("Shaohui Xie <Shaohui.Xie@freescale.com>");
> +MODULE_LICENSE("GPL v2");
>=20


--=20
=46lorian
