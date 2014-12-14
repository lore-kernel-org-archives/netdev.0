From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool v2 2/3] ethtool: Add copybreak support
Date: Sun, 14 Dec 2014 17:46:27 +0000
Message-ID: <1418579187.3599.130.camel@decadent.org.uk>
References: <1412637141-3205-1-git-send-email-_govind@gmx.com>
	 <1412637141-3205-3-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AxjrXbC3thZ0bS3sR/L5"
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33668 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750701AbaLNRro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 12:47:44 -0500
In-Reply-To: <1412637141-3205-3-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AxjrXbC3thZ0bS3sR/L5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-10-07 at 04:42 +0530, Govindarajulu Varadarajan wrote:
> This patch adds support for setting/getting driver's rx_copybreak value.
> copybreak is set/get using new ethtool tunable interface.
>=20
> This was added to net-next in
> commit: f0db9b073415848709dd59a6394969882f517da9
>=20
> 	ethtool: Add generic options for tunables
>=20
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  ethtool.c | 177 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  1 file changed, 177 insertions(+)
>=20
> diff --git a/ethtool.c b/ethtool.c
> index bf583f3..4045356 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -179,6 +179,12 @@ static const struct flag_info flags_msglvl[] =3D {
>  	{ "wol",	NETIF_MSG_WOL },
>  };
> =20
> +static const char *tunable_name[] =3D {
> +	[ETHTOOL_ID_UNSPEC]	=3D "Unspec",
> +	[ETHTOOL_RX_COPYBREAK]	=3D "rx",
> +	[ETHTOOL_TX_COPYBREAK]	=3D "tx",
> +};

Tunables should be named by a string set defined in the kernel.

[...]
> @@ -4055,6 +4228,10 @@ static const struct option {
>           "             [ rx-mini N ]\n"
>           "             [ rx-jumbo N ]\n"
>           "             [ tx N ]\n" },
> +       { "-b|--show-copybreak", 1, do_gcopybreak, "Show copybreak values=
" },
> +       { "-B|--set-copybreak", 1, do_scopybreak, "Set copybreak values",
> +         "             [ rx N]\n"
> +         "             [ tx N]\n" },
>         { "-k|--show-features|--show-offload", 1, do_gfeatures,
>           "Get state of protocol offload and other features" },
>         { "-K|--features|--offload", 1, do_sfeatures,
[...]

T don't think this is worth two options of its own.  You should be able
to add generic get/set-tunable optins.  You'll need to get the string
set to find out the names of tunables.  When setting a tunable, you'll
need to get it first to find out its type.

Ben.

--=20
Ben Hutchings
The two most common things in the universe are hydrogen and stupidity.

--=-AxjrXbC3thZ0bS3sR/L5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVI3M+Oe/yOyVhhEJAQr5PA//Vzod18jeOBNUDKP7uhYEQwNQv22nnncW
4+Sj2T5+6psGy8qG3GWKRXzTqQJKSU6N1ZNr+CQ8d2poYSUaWzkZVcj0SRaVOMbP
wlIaSNmhda1sbBe5io/KzkOC+6RhJYj2A5lkpVURNohrneUFRiw1rTllGTAMrI7r
cQZMPXBOHQaNve4gUEBmWzGjr2xAQkgb6V8e7qmusfSlevO5mOWPr6SCcQDUtEwY
2CDBEVgnDaN6fxJ9zT4K7gogjGiGEbBq2aSHN1w99SjNyjSshCkPlUp/tLY9bKVF
rMCr3M0qp5hEuhrXzyeItBezd5SQYsHRhIfAcetpOrJ+SfPKqMOSx73YeV5yYVUX
grN9Cexwbyqg/i7dX0XZfbJaFGkjLVBT/OtgcqgMQyrvHH6VqDlY5xmGExT7QfD1
gQUjNJi9EptlCD11BzrYMNesgHIOBwLmImiu+mHg59EWTYVYlngEWClbqaY+vzia
1aEqsLjJZQ8LdVKKyf6+jJcTWsVrQTtBWQMH6CqEOu/Bz5tbb01vfGk9D5iX85oC
m1oebhCaXrahJrtRDpD4mLmwMrk0rOOtxN5EhCkyQmdiTeqyNr7os5pAFzus9A0P
vrJLp73Q5cKaG/pLBdABRs0hJfuTGfOaD2DGv17lgG1UPBB9D/4Jwq8atzAhnFlV
Kg9x47Haq/o=
=TaLn
-----END PGP SIGNATURE-----

--=-AxjrXbC3thZ0bS3sR/L5--
