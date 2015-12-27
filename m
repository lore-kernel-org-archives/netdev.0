From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 4/4] net: phy: at803x: Add the interrupt register bit
 definitions
Date: Sat, 26 Dec 2015 19:29:22 -0800
Message-ID: <567F5B12.4080301@gmail.com>
References: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
 <1451089622-14957-5-git-send-email-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: slash.tmp@free.fr
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:35760 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754356AbbL0D3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2015 22:29:24 -0500
Received: by mail-ob0-f181.google.com with SMTP id 18so216164593obc.2
        for <netdev@vger.kernel.org>; Sat, 26 Dec 2015 19:29:23 -0800 (PST)
In-Reply-To: <1451089622-14957-5-git-send-email-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/12/2015 16:27, Martin Blumenstingl a =C3=A9crit :
> Also use them instead of a magic value when enabling the interrupts.
>=20
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.co=
m>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/at803x.c | 32 +++++++++++++++++++++++---------
>  1 file changed, 23 insertions(+), 9 deletions(-)
>=20
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index 6e8aafd..edb0a5f 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -20,13 +20,21 @@
>  #include <linux/gpio/consumer.h>
> =20
>  #define AT803X_INTR_ENABLE			0x12
> -#define AT803X_INTR_ENABLE_INIT			0xec00
> +#define AT803X_INTR_ENABLE_AUTONEG_ERR		BIT(15)
> +#define AT803X_INTR_ENABLE_SPEED_CHANGED	BIT(14)
> +#define AT803X_INTR_ENABLE_DUPLEX_CHANGED	BIT(13)
> +#define AT803X_INTR_ENABLE_PAGE_RECEIVED	BIT(12)
> +#define AT803X_INTR_ENABLE_LINK_FAIL		BIT(11)
> +#define AT803X_INTR_ENABLE_LINK_SUCCESS		BIT(10)
> +#define AT803X_INTR_ENABLE_WIRESPEED_DOWNGRADE	BIT(5)
> +#define AT803X_INTR_ENABLE_POLARITY_CHANGED	BIT(1)
> +#define AT803X_INTR_ENABLE_WOL			BIT(0)
> +
>  #define AT803X_INTR_STATUS			0x13
> =20
>  #define AT803X_SMART_SPEED			0x14
>  #define AT803X_LED_CONTROL			0x18
> =20
> -#define AT803X_WOL_ENABLE			0x01
>  #define AT803X_DEVICE_ADDR			0x03
>  #define AT803X_LOC_MAC_ADDR_0_15_OFFSET		0x804C
>  #define AT803X_LOC_MAC_ADDR_16_31_OFFSET	0x804B
> @@ -179,14 +187,14 @@ static int at803x_set_wol(struct phy_device *ph=
ydev,
>  		}
> =20
>  		value =3D phy_read(phydev, AT803X_INTR_ENABLE);
> -		value |=3D AT803X_WOL_ENABLE;
> +		value |=3D AT803X_INTR_ENABLE_WOL;
>  		ret =3D phy_write(phydev, AT803X_INTR_ENABLE, value);
>  		if (ret)
>  			return ret;
>  		value =3D phy_read(phydev, AT803X_INTR_STATUS);
>  	} else {
>  		value =3D phy_read(phydev, AT803X_INTR_ENABLE);
> -		value &=3D (~AT803X_WOL_ENABLE);
> +		value &=3D (~AT803X_INTR_ENABLE_WOL);
>  		ret =3D phy_write(phydev, AT803X_INTR_ENABLE, value);
>  		if (ret)
>  			return ret;
> @@ -205,7 +213,7 @@ static void at803x_get_wol(struct phy_device *phy=
dev,
>  	wol->wolopts =3D 0;
> =20
>  	value =3D phy_read(phydev, AT803X_INTR_ENABLE);
> -	if (value & AT803X_WOL_ENABLE)
> +	if (value & AT803X_INTR_ENABLE_WOL)
>  		wol->wolopts |=3D WAKE_MAGIC;
>  }
> =20
> @@ -217,7 +225,7 @@ static int at803x_suspend(struct phy_device *phyd=
ev)
>  	mutex_lock(&phydev->lock);
> =20
>  	value =3D phy_read(phydev, AT803X_INTR_ENABLE);
> -	wol_enabled =3D value & AT803X_WOL_ENABLE;
> +	wol_enabled =3D value & AT803X_INTR_ENABLE_WOL;
> =20
>  	value =3D phy_read(phydev, MII_BMCR);
> =20
> @@ -310,9 +318,15 @@ static int at803x_config_intr(struct phy_device =
*phydev)
> =20
>  	value =3D phy_read(phydev, AT803X_INTR_ENABLE);
> =20
> -	if (phydev->interrupts =3D=3D PHY_INTERRUPT_ENABLED)
> -		err =3D phy_write(phydev, AT803X_INTR_ENABLE,
> -				value | AT803X_INTR_ENABLE_INIT);
> +	if (phydev->interrupts =3D=3D PHY_INTERRUPT_ENABLED) {
> +		value |=3D AT803X_INTR_ENABLE_AUTONEG_ERR;
> +		value |=3D AT803X_INTR_ENABLE_SPEED_CHANGED;
> +		value |=3D AT803X_INTR_ENABLE_DUPLEX_CHANGED;
> +		value |=3D AT803X_INTR_ENABLE_LINK_FAIL;
> +		value |=3D AT803X_INTR_ENABLE_LINK_SUCCESS;
> +
> +		err =3D phy_write(phydev, AT803X_INTR_ENABLE, value);
> +	}
>  	else
>  		err =3D phy_write(phydev, AT803X_INTR_ENABLE, 0);
> =20
>=20


--=20
=46lorian
