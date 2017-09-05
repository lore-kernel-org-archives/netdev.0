From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH 2/2] b43legacy: fix unitialized reads of ret by
 initializing the array to zero
Date: Tue, 5 Sep 2017 22:18:28 +0200
Message-ID: <20170905221705.3a5c4ffa@wiggum>
References: <20170905181658.23893-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1102255435011226649=="
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
 Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170905181658.23893-1-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
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

--===============1102255435011226649==
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/rTL4C4h=cV3+DjO11=n_ZB9"; protocol="application/pgp-signature"

--Sig_/rTL4C4h=cV3+DjO11=n_ZB9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue,  5 Sep 2017 19:16:58 +0100
Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:

> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>=20
> The u8 char array ret is not being initialized and elements outside
> the range start to end contain just garbage values from the stack.
> This results in a later scan of the array to read potentially
> uninitialized values.  Fix this by initializing the array to zero.
> This seems to have been an issue since the very first commit.
>=20
> Detected by CoverityScan CID#139653 ("Uninitialized scalar variable")
>=20
> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  drivers/net/wireless/broadcom/b43legacy/radio.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/wireless/broadcom/b43legacy/radio.c b/drivers/ne=
t/wireless/broadcom/b43legacy/radio.c
> index 9501420340a9..eab1c9387846 100644
> --- a/drivers/net/wireless/broadcom/b43legacy/radio.c
> +++ b/drivers/net/wireless/broadcom/b43legacy/radio.c
> @@ -280,7 +280,7 @@ u8 b43legacy_radio_aci_detect(struct b43legacy_wldev =
*dev, u8 channel)
>  u8 b43legacy_radio_aci_scan(struct b43legacy_wldev *dev)
>  {
>  	struct b43legacy_phy *phy =3D &dev->phy;
> -	u8 ret[13];
> +	u8 ret[13] =3D { 0 };
>  	unsigned int channel =3D phy->channel;
>  	unsigned int i;
>  	unsigned int j;


This fix seems to be correct.
Thanks for finding and fixing the issue.

Reviewed-by: Michael Buesch <m@bues.ch>



--=20
Michael

--Sig_/rTL4C4h=cV3+DjO11=n_ZB9
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEihRzkKVZOnT2ipsS9TK+HZCNiw4FAlmvBpUACgkQ9TK+HZCN
iw7mcxAAuwPN4Hx9k9uBlKOS/Qdd4vDkyEBZ4NpLrTu8+8VcXgD/RWa0LACvQQEy
zJN1IEeFD34yl8eX16+eRaeEzzDuDsmHUwZB8zyWu1KlUpXEGTf1Pkm1cwZTROL0
8IAyUdmXt+jO0O/xOcb+9+p9LXGSL99R1PTPof1SK2y9zUd9UnadMWJXS2cc3NpM
02v3J3r7fXVg7IDAt3YpZ7M5fH7Pri+2BiM2xkNinb7L1KIcBhSF2pEJJLtFk2Ww
xO9wOwAwqCZkeT27C+jv8XQrwEZSL3/F+fzbBpKl8Bhj6LaptB3JRWio1n7fG9iM
IUrXsgNJtLqPW3H5+e3O51zcyggMMw/Iyj5KdAayAkouvf7n880MC++9bbWnsZcz
KBrhna9wrG5O5Qo1HiO1QgomtsWfsaZ45pH5AmK/MnVDlnVjI0f6w+FyYPwlSE5b
mad3PyAfUD7ALG3+fxIgXe/GtuzZO/KTDB4G4zJPpZamdnl4s63Hei6K3YbtruTG
SffWyZR2tsiEgJ8w/ABNCg1fOUIypEtuf6v6IW6kkjEqxyviuI6C1BtyRjhS7rfM
gRs6SHzj9NsnXaYv7neTG6a9aPl6X149+YRmNLpj1pWSEoOofbLiKC0qvYQcugw6
SZjt7kTNNRiyO+O2rxDfOI6uKnIWISFPZoNpVKyf9vc1j5ehuRc=
=L1fw
-----END PGP SIGNATURE-----

--Sig_/rTL4C4h=cV3+DjO11=n_ZB9--


--===============1102255435011226649==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
b43-dev mailing list
b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
http://lists.infradead.org/mailman/listinfo/b43-dev

--===============1102255435011226649==--
