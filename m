From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 6/6] wl1251: Set generated MAC address back to NVS data
Date: Sat, 24 Dec 2016 19:17:30 +0100
Message-ID: <20161224181730.GD13590@amd>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-7-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="RYJh/3oyKhIjGcML"
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
In-Reply-To: <1482598381-16513-7-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--RYJh/3oyKhIjGcML
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> In case there is no valid MAC address kernel generates random one. This
> patch propagate this generated MAC address back to NVS data which will be
> uploaded to wl1251 chip. So HW would have same MAC address as linux kernel
> uses.

>  	return 0;
>  }
> =20
> +static int wl1251_write_nvs_mac(struct wl1251 *wl)
> +{

The name is quite confusing, this sounds like writing into
non-volatile storage.

> +	int i;
> +
> +	if (wl->nvs_len < 0x24)
> +		return -ENODATA;
> +
> +	/* length is 2 and data address is 0x546c (mask is 0xfffe) */

You don't actually check for the mask.

> +	if (wl->nvs[0x19] !=3D 2 || wl->nvs[0x1a] !=3D 0x6d || wl->nvs[0x1b] !=
=3D 0x54)
> +		return -EINVAL;

You have two copies of these. Does it make sense to move it to helper
function?

Thanks,
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--RYJh/3oyKhIjGcML
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlheu7oACgkQMOfwapXb+vJfSwCgrwQYFkfPI2CSIlLo2J07YCoK
afwAniXEYCwILW244Gn3kA1bPezLPNCO
=FNYC
-----END PGP SIGNATURE-----

--RYJh/3oyKhIjGcML--
