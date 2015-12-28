From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] /drivers/net/wireless/ath/ath9k remove unnecessary ?:
 operator
Date: Mon, 28 Dec 2015 09:56:52 -0800
Message-ID: <1451325412.3219.12.camel@perches.com>
References: <20151228134852.GA10572@alpha.sfu-kras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ivan Safonov <insafonov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151228134852.GA10572-99FyVxquhxHwodmfrJTGkIdd74u8MsAO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-12-28 at 20:48 +0700, Ivan Safonov wrote:
> ((thermometer < 0) ? 0 : (thermometer =3D=3D X)) and (thermometer =3D=
=3D X) are equal for X >=3D 0.

X is not guaranteed to be >=3D 0 here

> Signed-off-by: Ivan Safonov <insafonov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> =A0drivers/net/wireless/ath/ath9k/ar9003_eeprom.c | 6 +++---
> =A01 file changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers=
/net/wireless/ath/ath9k/ar9003_eeprom.c
[]
> @@ -4097,16 +4097,16 @@ static void ar9003_hw_thermometer_apply(struc=
t ath_hw *ah)
> =A0		REG_RMW_FIELD(ah, AR_PHY_65NM_CH2_RXTX4,
> =A0			=A0=A0=A0=A0=A0=A0AR_PHY_65NM_CH0_RXTX4_THERM_ON_OVR, therm_on)=
;
> =A0
> -	therm_on =3D (thermometer < 0) ? 0 : (thermometer =3D=3D 0);
> +	therm_on =3D thermometer =3D=3D 0;

This code is not equivalent.

Check what happens when thermometer is -1.

> =A0	REG_RMW_FIELD(ah, AR_PHY_65NM_CH0_RXTX4,
> =A0		=A0=A0=A0=A0=A0=A0AR_PHY_65NM_CH0_RXTX4_THERM_ON, therm_on);
> =A0	if (pCap->chip_chainmask & BIT(1)) {
> -		therm_on =3D (thermometer < 0) ? 0 : (thermometer =3D=3D 1);
> +		therm_on =3D thermometer =3D=3D 1;
> =A0		REG_RMW_FIELD(ah, AR_PHY_65NM_CH1_RXTX4,
> =A0			=A0=A0=A0=A0=A0=A0AR_PHY_65NM_CH0_RXTX4_THERM_ON, therm_on);
> =A0	}
> =A0	if (pCap->chip_chainmask & BIT(2)) {
> -		therm_on =3D (thermometer < 0) ? 0 : (thermometer =3D=3D 2);
> +		therm_on =3D thermometer =3D=3D 2;
> =A0		REG_RMW_FIELD(ah, AR_PHY_65NM_CH2_RXTX4,
> =A0			=A0=A0=A0=A0=A0=A0AR_PHY_65NM_CH0_RXTX4_THERM_ON, therm_on);
> =A0	}

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
