From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 6/6] wl1251: Set generated MAC address back to NVS data
Date: Sat, 24 Dec 2016 19:44:33 +0100
Message-ID: <201612241944.33216@pali>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com> <1482598381-16513-7-git-send-email-pali.rohar@gmail.com> <20161224181730.GD13590@amd>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1718528.OXHjyr1GyY";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
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
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161224181730.GD13590@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1718528.OXHjyr1GyY
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Saturday 24 December 2016 19:17:30 Pavel Machek wrote:
> Hi!
>=20
> > In case there is no valid MAC address kernel generates random one.
> > This patch propagate this generated MAC address back to NVS data
> > which will be uploaded to wl1251 chip. So HW would have same MAC
> > address as linux kernel uses.
> >=20
> >  	return 0;
> > =20
> >  }
> >=20
> > +static int wl1251_write_nvs_mac(struct wl1251 *wl)
> > +{
>=20
> The name is quite confusing, this sounds like writing into
> non-volatile storage.
>=20
> > +	int i;
> > +
> > +	if (wl->nvs_len < 0x24)
> > +		return -ENODATA;
> > +
> > +	/* length is 2 and data address is 0x546c (mask is 0xfffe) */
>=20
> You don't actually check for the mask.

It is quite complicated. { 0x6d, 0x54 } (=3D 0x546d) in data represent=20
address 0x546c and content are data. You need to apply mask 0xfffe for=20
0x546d and you get address where data will be written (so 0x546c).

> > +	if (wl->nvs[0x19] !=3D 2 || wl->nvs[0x1a] !=3D 0x6d || wl->nvs[0x1b]
> > !=3D 0x54) +		return -EINVAL;
>=20
> You have two copies of these. Does it make sense to move it to helper
> function?

I'm thinking if checks is really needed. But probably moving it to=20
separate function is good idea.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1718528.OXHjyr1GyY
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlhewhEACgkQi/DJPQPkQ1KV5wCdGd7wafObsgLTcfTkxUj7dS7I
eU8An1whabSZSpk6AdMmYVTliBhTZSpm
=krdG
-----END PGP SIGNATURE-----

--nextPart1718528.OXHjyr1GyY--
