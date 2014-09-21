From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH 1/1] ethtool: Support cpsw ale-table registers
 in -d
Date: Sun, 21 Sep 2014 23:58:46 +0100
Message-ID: <1411340326.20019.32.camel@decadent.org.uk>
References: <1406107764-1737-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5XiaAI4GAcQC9B1vDnk5"
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33342 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751498AbaIUW7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 18:59:16 -0400
In-Reply-To: <1406107764-1737-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5XiaAI4GAcQC9B1vDnk5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Sorry I didn't respond to this earlier.

On Wed, 2014-07-23 at 14:59 +0530, Mugunthan V N wrote:
[...]
> --- /dev/null
> +++ b/cpsw.c
[...]
> +static inline void cpsw_ale_set_field(u32 *ale_entry, u32 start, u32 bit=
s,
> +				      u32 value)
> +{
> +	int idx;
> +
> +	value &=3D BITMASK(bits);
> +	idx    =3D start / 32;
> +	start -=3D idx * 32;
> +	idx    =3D 2 - idx; /* flip */
> +	ale_entry[idx] &=3D ~(BITMASK(bits) << start);
> +	ale_entry[idx] |=3D  (value << start);
> +}
> +
> +#define DEFINE_ALE_FIELD(name, start, bits)				\
> +static inline int cpsw_ale_get_##name(u32 *ale_entry)			\
> +{									\
> +	return cpsw_ale_get_field(ale_entry, start, bits);		\
> +}									\
> +static inline void cpsw_ale_set_##name(u32 *ale_entry, u32 value)	\
> +{									\
> +	cpsw_ale_set_field(ale_entry, start, bits, value);		\
> +}

The setter functions are unused.

[...]
> +int cpsw_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *re=
gs)
> +{
> +	u32 *reg =3D (u8 *)regs->data;
> +	u32 len =3D regs->len / 3;
> +	int i;
> +
> +	fprintf(stdout, "cpsw hw version %d.%d (%d)\n",
> +		CPSW_MAJOR_VERSION(regs->version),
> +		CPSW_MINOR_VERSION(regs->version),
> +		CPSW_RTL_VERSION(regs->version));
[...]

There needs to be a version check here.  Some future version of the
hardware or driver may introduce an incompatible dump format.

Ben.

--=20
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camu=
s

--=-5XiaAI4GAcQC9B1vDnk5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVB9YO+e/yOyVhhEJAQqBfBAAiJq/DkiqUzXQtNo3Cxyh6VDNR1IPsQ2W
W5M2J0AYfn3q0/1IRh8czNFdtOyW3k4LAh65pVBuU1nFXGkNhSX4K1+Yyj1GbVS5
fTSrgNvxjzFRsEprhqKCKLu6Us2a6aNdner+e2odB+NLqQSQEmL3hhqSVde6pO+k
z8iVoj2kbZv+HFISEu1LVva/eBA5q6n+z0ZUzY+rwhuyxrRd8RTQYprbikCbCq/i
fOh9fhB3THKhZ6YMwAGMiBH9/QjQPAAj44AI0BlRrDxST5VsOSTaBT8rnzscKguC
k4l/rxUOlWX6044Z1DnI1YrN3xrrQJqoRz+yyOIJtl9kardvjos1Gcecc0yS3VoZ
FRl9BH9FB+oXjl1WUOcHIgfvqI4wsRL5Io0RHxAI2HewsR9tigsco0IZsPEj9INY
06b0rItGQmlirD1viRzBP8hfckKlSHEP4hPfRycopEpZqz95nFNHZc5H7aeQ5CeU
9BhH1jTBObhj3u3bt6LbnwOPKqXZzzz+2ajDSfOcNtzwtzde0nGq+9GHHFSWvvel
uLA13ldG0xGa1IRiTYc4cdgzPJVZWS4lzOhUWiThsGgajiCIqUjHNg3cmCY3NJZc
DDxlHs0YXJ15r+kTHdNMGCf6TusmtXnX+E9Tj+x588rVadP8v0UUWkbPnhTYLIiS
Rxw1DNlRqxk=
=gV28
-----END PGP SIGNATURE-----

--=-5XiaAI4GAcQC9B1vDnk5--
