From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] b43: Fix a memory leak in b43_bus_dev_ssb_init
Date: Mon, 11 Jan 2016 17:21:53 +0100
Message-ID: <20160111172153.37a9613f@wiggum>
References: <1452483457-568-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6808541052572487924=="
Cc: johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
To: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1452483457-568-1-git-send-email-baijiaju1990-9Onoh4P/yGk@public.gmane.org>
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

--===============6808541052572487924==
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/GnvxRiYlWXY+V_2Fc2mecJy"; protocol="application/pgp-signature"

--Sig_/GnvxRiYlWXY+V_2Fc2mecJy
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 11 Jan 2016 11:37:36 +0800
Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org> wrote:

> The memory allocated by kzalloc in b43_bus_dev_ssb_init is not freed.
> This patch fixes the bug by adding kfree in b43_ssb_remove.
>=20
> Signed-off-by: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
> ---
>  drivers/net/wireless/b43/main.c |    1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/m=
ain.c
> index ec013fb..6d251a0 100644
> --- a/drivers/net/wireless/b43/main.c
> +++ b/drivers/net/wireless/b43/main.c
> @@ -5798,6 +5798,7 @@ static void b43_ssb_remove(struct ssb_device *sdev)
> =20
>  	b43_leds_unregister(wl);
>  	b43_wireless_exit(dev, wl);
> +	kfree(dev);
>  }
> =20
>  static struct ssb_driver b43_ssb_driver =3D {



Nice catch.
The kfree is also missing in b43_bcma_remove().
And also in the error paths of b43_bcma_probe().

Can you please extend the patch to cover these, too?

--=20
Michael

--Sig_/GnvxRiYlWXY+V_2Fc2mecJy
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWk9ahAAoJEPUyvh2QjYsOJy0QAKj6GI9KB8AXWUiZ3Ev6q97Y
JPmYZOmMcM0viRj6NEoJMLOn6P+fbodpASw+i2Zy1wnHlaWxBA6vJEQdRLWTzqyA
Z7Np67tp18ZwJatR47TuXOn3BGJTqkwNpZgjKviNIppqSZIL9u9xRYMSeMx2/Y7Z
Ghwmgc5RgzK5+CAUZUJSbwbihX0B/FDP6qyYAie0f6UJvqqWV6nC1pwKUgAFxMEz
R549brvd627OiwJ2qPaP6CylWVmsNgnMm0XyyQgNKRowpuualhhavBPVWCmuDKDq
yZbuUpIWwZ3ikXYbw++AhQ7nJBHiuwPSRI1yTKT0D3ayaT43RPVz0SC7IXryLUP6
6ic8YO2pg25lojmfR8GBhdzaugNzd+lSpTsLFrHA9PsFY7pnZ/fTQpvyTVyT+ZZM
UqeZBpeLZs6frsQNhZB1loQ6maIKQf7Cr4gDq1c7A/6vZuwZlXZStepBGl5B8kwU
0jIWyUPpLwnypcrc3LCriDfYNEl7rjTt9hP3E58/IqvzaxBd9ZZPka5Wk9q2JhGE
NTTQlzYooHqlOvdUYvuq04kZfikr3L7xB+go947h6gcsfKMr7RaLLUVVsJHn2lFU
nZdNpwpCS2Zq1oxsppVoCdHlBcpa+kOQoSHm3Xo5I64KoJ8oQr9RDxuN7SwPH7TE
JdwCjFjs9c7KhwsGa5vJ
=DMiL
-----END PGP SIGNATURE-----

--Sig_/GnvxRiYlWXY+V_2Fc2mecJy--


--===============6808541052572487924==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
b43-dev mailing list
b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
http://lists.infradead.org/mailman/listinfo/b43-dev

--===============6808541052572487924==--
