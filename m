From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH 1/2] b43: fix unitialized reads of ret by initializing
 the array to zero
Date: Tue, 5 Sep 2017 22:18:22 +0200
Message-ID: <20170905221654.64f2aae5@wiggum>
References: <20170905181550.23839-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8706438870927906326=="
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170905181550.23839-1-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "b43-dev" <b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============8706438870927906326==
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/80wMKUt39IjFt4bU2T+R9fe"; protocol="application/pgp-signature"

--Sig_/80wMKUt39IjFt4bU2T+R9fe
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue,  5 Sep 2017 19:15:50 +0100
Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:

> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>=20
> The u8 char array ret is not being initialized and elements outside
> the range start to end contain just garbage values from the stack.
> This results in a later scan of the array to read potentially
> uninitialized values.  Fix this by initializing the array to zero.
> This seems to have been an issue since the very first commit.
>=20
> Detected by CoverityScan CID#139652 ("Uninitialized scalar variable")
>=20
> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  drivers/net/wireless/broadcom/b43/phy_g.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/wireless/broadcom/b43/phy_g.c b/drivers/net/wire=
less/broadcom/b43/phy_g.c
> index 822dcaa8ace6..f59c02166462 100644
> --- a/drivers/net/wireless/broadcom/b43/phy_g.c
> +++ b/drivers/net/wireless/broadcom/b43/phy_g.c
> @@ -2297,7 +2297,7 @@ static u8 b43_gphy_aci_detect(struct b43_wldev *dev=
, u8 channel)
>  static u8 b43_gphy_aci_scan(struct b43_wldev *dev)
>  {
>  	struct b43_phy *phy =3D &dev->phy;
> -	u8 ret[13];
> +	u8 ret[13] =3D { 0 };
>  	unsigned int channel =3D phy->channel;
>  	unsigned int i, j, start, end;
> =20


This fix seems to be correct.
Thanks for finding and fixing the issue.

Reviewed-by: Michael Buesch <m@bues.ch>


--=20
Michael

--Sig_/80wMKUt39IjFt4bU2T+R9fe
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEihRzkKVZOnT2ipsS9TK+HZCNiw4FAlmvBo4ACgkQ9TK+HZCN
iw7zaxAAs7Uqd0BT1c8Z3sXa1HPcjbQzxm5mtMoVjGrByYHr1WXGseE7xvYAvrX0
PUZrPxcmZKM8BiCx81ohzxTJ+GiyBVt57HQLlMOKwK+hLtQLUM0XWCuPYgMK/4FQ
5XhHy9300lVnR/DvOxNMP7UIdDNru2oYQttUuuPI81G2Pm3JLr71YOXuofgGHpyB
rL60jSAKm0QipEf+NopH3WRNwG5HPTEhA9D+kE6n44Juiri12/SJHUNtUKxSauSt
iAyLm8WuSxxtd3zTw1prgYHaa2hdtNbIf+V8Bkch9oAJabeBVYXXqZBjaLN259m1
Y5aRY1Um0xPmwm4Cmf3cE8WGdQ1mf0KCRJp/WSpbF0TVBs/o7D5cFxUtzeu6SOEr
vTDtcM0qfaUpThuikWBrYLHDvWsBThRrt+LymxehQiI/rU8XYKtfcX0X9adK5ULU
1rvjKI9Dio6E7jMQqWgF4Rbde2w5OSYCvrdK+n+NVkN+S+LjQhJk1eG1ikpAkLAf
MWac/guu6NpsHttk+gu5BV1S7Lglw3Z/ryTeg9RkQrn7GAQV2wp8uEMrR2CyDQyj
WJ4P0FzBS3P4Q1dIxop+M9NZ28WDo4NzRjuBqVsJJm2MQH9EnSIminJkPqyY4oL+
PzUgjn0d1x7ZfslfB6IGNv0UZ39w3c5+dA0CuF/0ez4d/TZBieM=
=bh3L
-----END PGP SIGNATURE-----

--Sig_/80wMKUt39IjFt4bU2T+R9fe--


--===============8706438870927906326==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
b43-dev mailing list
b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
http://lists.infradead.org/mailman/listinfo/b43-dev

--===============8706438870927906326==--
