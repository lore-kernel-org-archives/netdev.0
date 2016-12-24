From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 3/6] wl1251: Update wl->nvs_len after wl->nvs is valid
Date: Sat, 24 Dec 2016 19:02:11 +0100
Message-ID: <20161224180211.GA13590@amd>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-4-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="EVF5PPMfhYS0aIcm"
Cc: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1482598381-16513-4-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat 2016-12-24 17:52:58, Pali Roh=E1r wrote:
> In case kmemdup fails thne wl->nvs_len will contains invalid non-zero siz=
e.
> This patch fixes it.

If kmemdup fails, then wl->nvs_len will contain invalid non-zero size.

?

This probably should go as first in series, as it is bugfix?

									Pavel
Acked-by: Pavel Machek <pavel@ucw.cz>


> Signed-off-by: Pali Roh=E1r <pali.rohar@gmail.com>
> ---
>  drivers/net/wireless/ti/wl1251/main.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless=
/ti/wl1251/main.c
> index 24f8866..8971b64 100644
> --- a/drivers/net/wireless/ti/wl1251/main.c
> +++ b/drivers/net/wireless/ti/wl1251/main.c
> @@ -124,8 +124,7 @@ static int wl1251_fetch_nvs(struct wl1251 *wl)
>  		goto out;
>  	}
> =20
> -	wl->nvs_len =3D fw->size;
> -	wl->nvs =3D kmemdup(fw->data, wl->nvs_len, GFP_KERNEL);
> +	wl->nvs =3D kmemdup(fw->data, fw->size, GFP_KERNEL);
> =20
>  	if (!wl->nvs) {
>  		wl1251_error("could not allocate memory for the nvs file");
> @@ -133,6 +132,8 @@ static int wl1251_fetch_nvs(struct wl1251 *wl)
>  		goto out;
>  	}
> =20
> +	wl->nvs_len =3D fw->size;
> +
>  	ret =3D 0;
> =20
>  out:

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--EVF5PPMfhYS0aIcm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlheuCMACgkQMOfwapXb+vJiTgCfaj9HPfGWc0/SEbego9rsuAGE
I18AnjPiY3ZPyBEdyM0Il07BoZ3schcn
=Hnrh
-----END PGP SIGNATURE-----

--EVF5PPMfhYS0aIcm--
