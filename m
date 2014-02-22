From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: vitesse: advertise PAUSE frame capabilities on Vitesse PHY drivers
Date: Sat, 22 Feb 2014 10:08:44 -0800
Message-ID: <5168669.8QxsYLHynZ@lenovo>
References: <1392999584-29836-1-git-send-email-cristian.bercaru@freescale.com> <1393076336.15717.97.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cristian.bercaru@freescale.com, netdev@vger.kernel.org,
	madalin.bucur@freescale.com, shaohui.xie@freescale.com,
	shruti@freescale.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:62130 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959AbaBVSIy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 13:08:54 -0500
Received: by mail-ob0-f179.google.com with SMTP id wn1so472852obc.24
        for <netdev@vger.kernel.org>; Sat, 22 Feb 2014 10:08:53 -0800 (PST)
In-Reply-To: <1393076336.15717.97.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 22 f=E9vrier 2014, 13:38:56 Ben Hutchings a =E9crit :
> On Fri, 2014-02-21 at 18:19 +0200, cristian.bercaru@freescale.com wro=
te:
> > From: Cristian Bercaru <cristian.bercaru@freescale.com>
> >=20
> > Enable the advertisment of symmetric and asymmetric PAUSE frame
> > capabilities on all Vitesse PHY drivers.
>=20
> I don't think this makes sense.  So far as I know, pause frame suppor=
t
> depends only on the MAC, not the PHY.

Agreed.

>=20
> I realise there are already other PHY drivers setting these flags, bu=
t
> why should they be added to every PHY driver individually when any
> autonegotiating PHY can advertise pause capability?

It looks like this might be abusing a PHY driver features to ensure tha=
t the=20
initial value fed to phydev->supported will make us advertise the pause=
=20
capabilities. This should be set by the Ethernet MAC driver prior to=20
phy_start(), not by the PHY driver.

>=20
> Ben.
>=20
> > Signed-off-by: Cristian Bercaru <cristian.bercaru@freescale.com>
> > ---
> >=20
> >  drivers/net/phy/vitesse.c | 21 ++++++++++++++-------
> >  1 file changed, 14 insertions(+), 7 deletions(-)
> >=20
> > diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
> > index 14372c6..3124b31 100644
> > --- a/drivers/net/phy/vitesse.c
> > +++ b/drivers/net/phy/vitesse.c
> > @@ -227,7 +227,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
> >=20
> >  	.phy_id         =3D PHY_ID_VSC8234,
> >  	.name           =3D "Vitesse VSC8234",
> >  	.phy_id_mask    =3D 0x000ffff0,
> >=20
> > -	.features       =3D PHY_GBIT_FEATURES,
> > +	.features       =3D PHY_GBIT_FEATURES |
> > +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
> >=20
> >  	.flags          =3D PHY_HAS_INTERRUPT,
> >  	.config_init    =3D &vsc824x_config_init,
> >  	.config_aneg    =3D &vsc82x4_config_aneg,
> >=20
> > @@ -239,7 +240,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
> >=20
> >  	.phy_id		=3D PHY_ID_VSC8244,
> >  	.name		=3D "Vitesse VSC8244",
> >  	.phy_id_mask	=3D 0x000fffc0,
> >=20
> > -	.features	=3D PHY_GBIT_FEATURES,
> > +	.features       =3D PHY_GBIT_FEATURES |
> > +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
> >=20
> >  	.flags		=3D PHY_HAS_INTERRUPT,
> >  	.config_init	=3D &vsc824x_config_init,
> >  	.config_aneg	=3D &vsc82x4_config_aneg,
> >=20
> > @@ -251,7 +253,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
> >=20
> >  	.phy_id		=3D PHY_ID_VSC8514,
> >  	.name		=3D "Vitesse VSC8514",
> >  	.phy_id_mask	=3D 0x000ffff0,
> >=20
> > -	.features	=3D PHY_GBIT_FEATURES,
> > +	.features       =3D PHY_GBIT_FEATURES |
> > +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
> >=20
> >  	.flags		=3D PHY_HAS_INTERRUPT,
> >  	.config_init	=3D &vsc824x_config_init,
> >  	.config_aneg	=3D &vsc82x4_config_aneg,
> >=20
> > @@ -263,7 +266,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
> >=20
> >  	.phy_id         =3D PHY_ID_VSC8574,
> >  	.name           =3D "Vitesse VSC8574",
> >  	.phy_id_mask    =3D 0x000ffff0,
> >=20
> > -	.features       =3D PHY_GBIT_FEATURES,
> > +	.features       =3D PHY_GBIT_FEATURES |
> > +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
> >=20
> >  	.flags          =3D PHY_HAS_INTERRUPT,
> >  	.config_init    =3D &vsc824x_config_init,
> >  	.config_aneg    =3D &vsc82x4_config_aneg,
> >=20
> > @@ -275,7 +279,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
> >=20
> >  	.phy_id         =3D PHY_ID_VSC8662,
> >  	.name           =3D "Vitesse VSC8662",
> >  	.phy_id_mask    =3D 0x000ffff0,
> >=20
> > -	.features       =3D PHY_GBIT_FEATURES,
> > +	.features       =3D PHY_GBIT_FEATURES |
> > +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
> >=20
> >  	.flags          =3D PHY_HAS_INTERRUPT,
> >  	.config_init    =3D &vsc824x_config_init,
> >  	.config_aneg    =3D &vsc82x4_config_aneg,
> >=20
> > @@ -288,7 +293,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
> >=20
> >  	.phy_id		=3D PHY_ID_VSC8221,
> >  	.phy_id_mask	=3D 0x000ffff0,
> >  	.name		=3D "Vitesse VSC8221",
> >=20
> > -	.features	=3D PHY_GBIT_FEATURES,
> > +	.features       =3D PHY_GBIT_FEATURES |
> > +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
> >=20
> >  	.flags		=3D PHY_HAS_INTERRUPT,
> >  	.config_init	=3D &vsc8221_config_init,
> >  	.config_aneg	=3D &genphy_config_aneg,
> >=20
> > @@ -301,7 +307,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
> >=20
> >  	.phy_id		=3D PHY_ID_VSC8211,
> >  	.phy_id_mask	=3D 0x000ffff0,
> >  	.name		=3D "Vitesse VSC8211",
> >=20
> > -	.features	=3D PHY_GBIT_FEATURES,
> > +	.features       =3D PHY_GBIT_FEATURES |
> > +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
> >=20
> >  	.flags		=3D PHY_HAS_INTERRUPT,
> >  	.config_init	=3D &vsc8221_config_init,
> >  	.config_aneg	=3D &genphy_config_aneg,

--=20
=46lorian
