From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/4] net: phy: at803x: Clean up duplicate register
 definitions
Date: Sat, 26 Dec 2015 19:28:56 -0800
Message-ID: <567F5AF8.6090402@gmail.com>
References: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
 <1451089622-14957-4-git-send-email-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: slash.tmp@free.fr
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:34744 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451AbbL0D26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2015 22:28:58 -0500
Received: by mail-ob0-f175.google.com with SMTP id iw8so214512457obc.1
        for <netdev@vger.kernel.org>; Sat, 26 Dec 2015 19:28:58 -0800 (PST)
In-Reply-To: <1451089622-14957-4-git-send-email-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/12/2015 16:27, Martin Blumenstingl a =C3=A9crit :
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.co=
m>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/at803x.c | 19 +++++++++++--------
>  1 file changed, 11 insertions(+), 8 deletions(-)
>=20
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index 0b262a2..6e8aafd 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -20,9 +20,12 @@
>  #include <linux/gpio/consumer.h>
> =20
>  #define AT803X_INTR_ENABLE			0x12
> +#define AT803X_INTR_ENABLE_INIT			0xec00
>  #define AT803X_INTR_STATUS			0x13
> +
>  #define AT803X_SMART_SPEED			0x14
>  #define AT803X_LED_CONTROL			0x18
> +
>  #define AT803X_WOL_ENABLE			0x01
>  #define AT803X_DEVICE_ADDR			0x03
>  #define AT803X_LOC_MAC_ADDR_0_15_OFFSET		0x804C
> @@ -31,13 +34,13 @@
>  #define AT803X_MMD_ACCESS_CONTROL		0x0D
>  #define AT803X_MMD_ACCESS_CONTROL_DATA		0x0E
>  #define AT803X_FUNC_DATA			0x4003
> -#define AT803X_INER				0x0012
> -#define AT803X_INER_INIT			0xec00
> -#define AT803X_INSR				0x0013
> +
>  #define AT803X_DEBUG_ADDR			0x1D
>  #define AT803X_DEBUG_DATA			0x1E
> +
>  #define AT803X_DEBUG_REG_0			0x00
>  #define AT803X_DEBUG_RX_CLK_DLY_EN		BIT(15)
> +
>  #define AT803X_DEBUG_REG_5			0x05
>  #define AT803X_DEBUG_TX_CLK_DLY_EN		BIT(8)
> =20
> @@ -295,7 +298,7 @@ static int at803x_ack_interrupt(struct phy_device=
 *phydev)
>  {
>  	int err;
> =20
> -	err =3D phy_read(phydev, AT803X_INSR);
> +	err =3D phy_read(phydev, AT803X_INTR_STATUS);
> =20
>  	return (err < 0) ? err : 0;
>  }
> @@ -305,13 +308,13 @@ static int at803x_config_intr(struct phy_device=
 *phydev)
>  	int err;
>  	int value;
> =20
> -	value =3D phy_read(phydev, AT803X_INER);
> +	value =3D phy_read(phydev, AT803X_INTR_ENABLE);
> =20
>  	if (phydev->interrupts =3D=3D PHY_INTERRUPT_ENABLED)
> -		err =3D phy_write(phydev, AT803X_INER,
> -				value | AT803X_INER_INIT);
> +		err =3D phy_write(phydev, AT803X_INTR_ENABLE,
> +				value | AT803X_INTR_ENABLE_INIT);
>  	else
> -		err =3D phy_write(phydev, AT803X_INER, 0);
> +		err =3D phy_write(phydev, AT803X_INTR_ENABLE, 0);
> =20
>  	return err;
>  }
>=20


--=20
=46lorian
