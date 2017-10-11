From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v1 RFC 7/7] Modify tag_ksz.c so that tail tag code can be
 used by other KSZ switch drivers
Date: Wed, 11 Oct 2017 22:45:28 +0200
Message-ID: <20171011204528.GA31288@amd>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
 <1507321985-15097-8-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="2oS5YaxWCcQjTEyO"
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>,
        muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507321985-15097-8-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> +#define	KSZ_INGRESS_TAG_LEN		1

This define is now (or should be) unused, so you can delete it, no?

> _#define	KSZ_EGRESS_TAG_LEN	1

And I'd delete this define, too. Having constant for something that's
variable is quite confusing :-).

Plus you are really doing too much inside single patch.

> + * For Egress (KSZ9477 -> Host), 1 byte is added before FCS.
> + * ---------------------------------------------------------------------=
------
> + * DA(6bytes)|SA(6bytes)|....|Data(nbytes)|tag0(1byte)|FCS(4bytes)
> + * ---------------------------------------------------------------------=
------
> + * tag0 : zero-based value represents port
> + *	  (eg, 0x00=3Dport1, 0x02=3Dport3, 0x06=3Dport7)
> + */
> +
> +#define KSZ9477_INGRESS_TAG_LEN		2
> +#define KSZ9477_PTP_TAG_LEN		4
> +#define KSZ9477_PTP_TAG_INDICATION	0x80
> +
> +#define KSZ9477_TAIL_TAG_OVERRIDE	BIT(9)
> +#define KSZ9477_TAIL_TAG_LOOKUP		BIT(10)
> +
> +static int ksz9477_get_tag(u8 *tag, int *port)
> +{
> +	int len =3D KSZ_EGRESS_TAG_LEN;
> +
> +	/* Extra 4-bytes PTP timestamp */
> +	if (tag[0] & KSZ9477_PTP_TAG_INDICATION)
> +		len +=3D KSZ9477_PTP_TAG_LEN;
> +	*port =3D tag[0] & 7;
> +	return len;
> +}
> +
> +static void ksz9477_set_tag(void *ptr, u8 *addr, int p)
> +{
> +	u16 *tag =3D (u16 *)ptr;
> +
> +	*tag =3D 1 << p;
> +	if (!memcmp(addr, special_mult_addr, ETH_ALEN))
> +		*tag |=3D KSZ9477_TAIL_TAG_OVERRIDE;
> +	*tag =3D cpu_to_be16(*tag);
> +}

These are new features that were not there before, right?
								Pavel
							=09
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--2oS5YaxWCcQjTEyO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnegugACgkQMOfwapXb+vLuRQCfQJY5qbvDg8Mc0Bs8UcIxvYFs
jqAAnRyKAVJSPJuP4/T2f5dT+ihBxJhk
=N+Hg
-----END PGP SIGNATURE-----

--2oS5YaxWCcQjTEyO--
