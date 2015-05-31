From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 RESEND] ethtool: Include SFP serial number and date
 in EEPROM dump
Date: Sun, 31 May 2015 21:09:42 +0100
Message-ID: <1433102982.6319.112.camel@decadent.org.uk>
References: <1432003608-87071-1-git-send-email-eswierk@skyportsystems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GL4gwI2s2/sg+Uq642xb"
Cc: Ben Hutchings <bwh@kernel.org>, netdev@vger.kernel.org
To: Ed Swierk <eswierk@skyportsystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58578 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751142AbbEaUJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 16:09:50 -0400
In-Reply-To: <1432003608-87071-1-git-send-email-eswierk@skyportsystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GL4gwI2s2/sg+Uq642xb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-05-18 at 19:46 -0700, Ed Swierk wrote:
> ethtool -m currently omits the serial number, date code, and other useful
> EEPROM fields defined in INF-8074, which is part of the SFF-8079 standard=
.
> This patch adds them.
>=20
> It also trims space characters from the end of ASCII text fields.
>=20
> $ ethtool -m eth0
> ...
> 	Option values                             : 0x00 0x10
> 	Option                                    : TX_DISABLE implemented
> 	BR margin, max                            : 0%
> 	BR margin, min                            : 0%
> 	Vendor SN                                 : AGC143953079
> 	Date code                                 : 140926
>=20
> Signed-off-by: Ed Swierk <eswierk@skyportsystems.com>

Applied, thanks.

Ben.

> ---
>  sfpid.c | 41 +++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 41 insertions(+)
>=20
> diff --git a/sfpid.c b/sfpid.c
> index 4f88aa2..b1a5044 100644
> --- a/sfpid.c
> +++ b/sfpid.c
> @@ -355,6 +355,8 @@ static void sff8079_show_ascii(const __u8 *id, unsign=
ed int first_reg,
>  	unsigned int reg, val;
> =20
>  	printf("\t%-41s : ", name);
> +	while (first_reg <=3D last_reg && id[last_reg] =3D=3D ' ')
> +		last_reg--;
>  	for (reg =3D first_reg; reg <=3D last_reg; reg++) {
>  		val =3D id[reg];
>  		putchar(((val >=3D 32) && (val <=3D 126)) ? val : '_');
> @@ -362,6 +364,40 @@ static void sff8079_show_ascii(const __u8 *id, unsig=
ned int first_reg,
>  	printf("\n");
>  }
> =20
> +static void sff8079_show_options(const __u8 *id)
> +{
> +	static const char *pfx =3D
> +		"\tOption                                    :";
> +
> +	printf("\t%-41s : 0x%02x 0x%02x\n", "Option values", id[64], id[65]);
> +	if (id[65] & (1 << 1))
> +		printf("%s RX_LOS implemented\n", pfx);
> +	if (id[65] & (1 << 2))
> +		printf("%s RX_LOS implemented, inverted\n", pfx);
> +	if (id[65] & (1 << 3))
> +		printf("%s TX_FAULT implemented\n", pfx);
> +	if (id[65] & (1 << 4))
> +		printf("%s TX_DISABLE implemented\n", pfx);
> +	if (id[65] & (1 << 5))
> +		printf("%s RATE_SELECT implemented\n", pfx);
> +	if (id[65] & (1 << 6))
> +		printf("%s Tunable transmitter technology\n", pfx);
> +	if (id[65] & (1 << 7))
> +		printf("%s Receiver decision threshold implemented\n", pfx);
> +	if (id[64] & (1 << 0))
> +		printf("%s Linear receiver output implemented\n", pfx);
> +	if (id[64] & (1 << 1))
> +		printf("%s Power level 2 requirement\n", pfx);
> +	if (id[64] & (1 << 2))
> +		printf("%s Cooled transceiver implemented\n", pfx);
> +	if (id[64] & (1 << 3))
> +		printf("%s Retimer or CDR implemented\n", pfx);
> +	if (id[64] & (1 << 4))
> +		printf("%s Paging implemented\n", pfx);
> +	if (id[64] & (1 << 5))
> +		printf("%s Power level 3 requirement\n", pfx);
> +}
> +
>  void sff8079_show_all(const __u8 *id)
>  {
>  	sff8079_show_identifier(id);
> @@ -385,5 +421,10 @@ void sff8079_show_all(const __u8 *id)
>  		sff8079_show_oui(id);
>  		sff8079_show_ascii(id, 40, 55, "Vendor PN");
>  		sff8079_show_ascii(id, 56, 59, "Vendor rev");
> +		sff8079_show_options(id);
> +		sff8079_show_value_with_unit(id, 66, "BR margin, max", 1, "%");
> +		sff8079_show_value_with_unit(id, 67, "BR margin, min", 1, "%");
> +		sff8079_show_ascii(id, 68, 83, "Vendor SN");
> +		sff8079_show_ascii(id, 84, 91, "Date code");
>  	}
>  }

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-GL4gwI2s2/sg+Uq642xb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWtqhue/yOyVhhEJAQpukw//ZxBEOP0nkbiQetCcjQMwqbK4yq892/TG
6a/QrlAF3hVOWeL3MRN6TnzRDQPn2ey0+P/D8hAYt3mcr2bbRtNxn3TH1nVnXns0
VROQELJaTUco31fDeC3xLdYjzyJv1+IYCVvQcZUEUW1KlW7hnRxJZh+CydToqbUR
ZC6r0hT7439JzcV5ae4haNQwBoMHU3h371bC0i3USTWvmuh3+z1exLyN8gsrn6P2
oKmLb9tA6s5Xtr0/ZxQUG5TlCByih/tGxVC7LaPdEQnxK+fitxeSHj2gubJBdP/9
z/mZjfs9uuvk2PYIzMLC6+eehY5n1YpGjF7ulaxosHQYicOJA4j8RkX7NrD6j/w8
vnvUSozL3eSrrfSPKZcMjlqBnAp4lHb03zMiHvn5XX5ENyslKOUAnrTVF3kVxEZL
TWIiDyTotTqF3rOu1Deu1TiFcP5/CWrYAOUoDoOzabRV805iteo5Y4FLvHK2rM4L
32jz9SErU6DxORBvrc6yw/a9rFfabSfE/YbqaBwMWjL4R6Eu7Pg19coKN9IhAS2s
75HP65g6aG/FF/j7T0AGc0zi1lvMhFF74BvL6KmhsAQ41aduzUPhwHMU+qbRnhvM
8R8nJ9GVlW4swLvFWobYPgy7d9s+jiY7hEFCb4hiqW10vbduWCuKd9toupgbtqoU
f5sds0y4FGo=
=w3FC
-----END PGP SIGNATURE-----

--=-GL4gwI2s2/sg+Uq642xb--
