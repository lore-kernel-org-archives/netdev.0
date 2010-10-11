From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] atl1c: Add support for Atheros AR8152 and AR8152
Date: Mon, 11 Oct 2010 02:18:50 +0100
Message-ID: <1286759930.2955.285.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-2VpGs4O8J64zyfkBriUS"
Cc: netdev <netdev@vger.kernel.org>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57450 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752671Ab0JKBSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Oct 2010 21:18:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2VpGs4O8J64zyfkBriUS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Your commit 496c185c9495629ef1c65387cb2594578393cfe0 "atl1c: Add support
for Atheros AR8152 and AR8152" included the following changes:

> --- a/drivers/net/atl1c/atl1c_hw.c
> +++ b/drivers/net/atl1c/atl1c_hw.c
> @@ -70,17 +70,39 @@ static int atl1c_get_permanent_address(struct atl1c_h=
w *hw)
[...]
> -		/* Enable OTP CLK */
> -		if (!(otp_ctrl_data & OTP_CTRL_CLK_EN)) {
> -			otp_ctrl_data |=3D OTP_CTRL_CLK_EN;
> -			AT_WRITE_REG(hw, REG_OTP_CTRL, otp_ctrl_data);
> -			AT_WRITE_FLUSH(hw);
> -			msleep(1);
> +		if (hw->nic_type =3D=3D athr_l1c || hw->nic_type =3D=3D athr_l2c_b) {
> +			/* Enable OTP CLK */
> +			if (!(otp_ctrl_data & OTP_CTRL_CLK_EN)) {
> +				otp_ctrl_data |=3D OTP_CTRL_CLK_EN;
> +				AT_WRITE_REG(hw, REG_OTP_CTRL, otp_ctrl_data);
> +				AT_WRITE_FLUSH(hw);
> +				msleep(1);
> +			}
> +		}
[...]
> @@ -96,11 +118,31 @@ static int atl1c_get_permanent_address(struct atl1c_=
hw *hw)
>  			return -1;
>  	}
>  	/* Disable OTP_CLK */
> -	if (otp_ctrl_data & OTP_CTRL_CLK_EN) {
> -		otp_ctrl_data &=3D ~OTP_CTRL_CLK_EN;
> -		AT_WRITE_REG(hw, REG_OTP_CTRL, otp_ctrl_data);
> -		AT_WRITE_FLUSH(hw);
> -		msleep(1);
> +	if ((hw->nic_type =3D=3D athr_l1c || hw->nic_type =3D=3D athr_l2c)) {
> +		if (otp_ctrl_data & OTP_CTRL_CLK_EN) {
> +			otp_ctrl_data &=3D ~OTP_CTRL_CLK_EN;
> +			AT_WRITE_REG(hw, REG_OTP_CTRL, otp_ctrl_data);
> +			AT_WRITE_FLUSH(hw);
> +			msleep(1);
> +		}
> +	}

Shouldn't the first if-statement use the same condition as the second
i.e. matching the previously-defined hardware types athr_l1c and
athr_l2c?

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-2VpGs4O8J64zyfkBriUS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATLJl9ee/yOyVhhEJAQJ/iRAAmVZ0DOBJkG2PTp31a57ySoDeB3hNUVdJ
mnLesn7e2NdFX6+3osingFlytGjM2q4gkPv+f1bp6HGxv7V/aLY6jq86F1kUg7hk
Ee4CW0TL9RGkeXsf88sCnEsDjz/yDm1VxbF5y5/tt0cm1TeavCXXIlazyoHi5ex4
KussJwzbMKMRJbeyiSsO2e1NWDWvLZaxEZpd7WMgim5Add9djObLT1Dn5VjN+yrK
PgETw5PobMAe901YxxNXnQ3QCd/p4wVWoRy1IYJKayXMx+AYj+eFbtwXBuaExsPU
jmIt48yfHB7BFB41fw1ApG3kMW6IfQLBtDq7BeXV6Dlz8sdv2PZFrVfoT3G8YvUG
0b1TgiPewrRjlr1upgQBA34zhFvkZoSdNgRFahi7sZ5SwZTbsoqnjdQUwprh6Gat
+jvXexRJhoFczFvMKup/CxyOVlQsBSoAJwo3SyQ7fe/aSD94CMPxYsNsjaHht7uG
dJZCDIMHSFG95zFn3FnqVpwM44C8A3FqIIu2NNsyKNHKUI5MP+keMcVJgzB5ESN4
hs4fXmfAqu1f14KgJ+TTNRrsUO/e3crcvzuBKtrWMUCpLfN8dFJ4MbMTG2QX+qCy
eChRbfmYsJAdWGn+fx2orckPrAUwrdPd1wpnpeDap/WdETA9mHlnbkMU8xz29ZsK
r4xsVx8ySBI=
=XTT1
-----END PGP SIGNATURE-----

--=-2VpGs4O8J64zyfkBriUS--
