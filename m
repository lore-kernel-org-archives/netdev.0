From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH v2 1/2] b43: Remove unused phy_a code
Date: Sat, 4 Jun 2016 10:01:40 +0200
Message-ID: <20160604100140.43ca7621@wiggum>
References: <1465013512-30301-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ARXZz6nF1DU.aW8+ynAz7ZG"; protocol="application/pgp-signature"
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465013512-30301-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/ARXZz6nF1DU.aW8+ynAz7ZG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri,  3 Jun 2016 21:11:51 -0700
Guenter Roeck <linux@roeck-us.net> wrote:

> +static void __b43_phy_initg(struct b43_wldev *dev)
> +{
> +	struct b43_phy *phy =3D &dev->phy;
> +
> +	might_sleep();
> +
> +	if (phy->rev >=3D 6) {
> +		if (b43_phy_read(dev, B43_PHY_ENCORE) & B43_PHY_ENCORE_EN)
> +			b43_phy_set(dev, B43_PHY_ENCORE, 0x0010);
> +		else
> +			b43_phy_mask(dev, B43_PHY_ENCORE, ~0x1010);
> +	}
> +
> +	b43_wa_all(dev);
> +
> +	if (dev->dev->bus_sprom->boardflags_lo & B43_BFL_PACTRL)
> +		b43_phy_maskset(dev, B43_PHY_OFDM(0x6E), 0xE000, 0x3CF);
> +}
> +
>  static void b43_phy_initg(struct b43_wldev *dev)
>  {
>  	struct b43_phy *phy =3D &dev->phy;
> @@ -1999,7 +2019,7 @@ static void b43_phy_initg(struct b43_wldev *dev)
>  		b43_phy_initb6(dev);
> =20
>  	if (phy->rev >=3D 2 || phy->gmode)
> -		b43_phy_inita(dev);
> +		__b43_phy_initg(dev);

This actually is correctly called inita(), because there are A-phy parts
in the G-phy.
So I wasn't 100% correct saying that _all_ a-phy code is unused.
I'm Ok with moving that into the g-phy file though. But don't rename it.


--=20
Michael

--Sig_/ARXZz6nF1DU.aW8+ynAz7ZG
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXUorkAAoJEPUyvh2QjYsOe/gQAI5qWGqNekiB4NSp/+UX/CVX
zIDkCiAqivdDG7fucktLCvjBxzfQzBaI1cw+kSVjcFwANs1JPvh5rP/QwiW5TZeV
RQbODg60P/Lkza415eVWlTT6AZqvlzcGx4i/O8RjAPmtaA3OKSt5fTRIJDCiqSPL
WyTnjFjZd4GPnmkt9tTfNWQiiLAKRFzFG0t/gwPT1lqy2eHl3dZc+sJ2yVLAcdZ3
roPhNkYy6wCBcGQ3cTBIemYvR/KN7hak1ihtGIF9y708ClBiy8qNBJuO0oDSQ6oL
H9QvCiqkndAhAPaiy0WGh1uMIxKEueQyb3z5WWrtNyBLcEMDnv1q3U/z/CSCWBGg
9UUmYUS9EMyVEgfQFZAZ7GiPO3CDDkazkkc59V79oYr9S1QLkbxs+XWjcs0XavgS
uvXI+VlyJUsoxivzlzGOvx5FAyPk5CN32MBjs8WADFHIuy6t2jySP+IxpEwQmxtJ
bZoI2E9gdM/h2BmpfzOOIMRywtxRkhD8nu6G3HBlvrY3LLyaPhxUpTce5xcQ2aHL
tww9Yjjo+YZFr2WV4PfoCbqRGSoSJZ9/XfgrYiLG65fQ98Tct1vDm42+YrDmhs8+
lXDRT9IKoRj83OiWkxKZ/Pm61DWxAznD5gIs/qfhJU7EiQGeUCq4LAGIc22/KjLU
6lj7WuLS/JUdG4gKWAkx
=nC7Y
-----END PGP SIGNATURE-----

--Sig_/ARXZz6nF1DU.aW8+ynAz7ZG--
