From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/4 ethtool] ethtool: Support for configurable RSS hash
 key.
Date: Sun, 19 Jan 2014 18:35:49 +0000
Message-ID: <1390156549.16433.119.camel@deadeye.wl.decadent.org.uk>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8D4@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-kv3A4LMu7S3qa7q5lHIS"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60046 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751538AbaASSgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 13:36:01 -0500
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8D4@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kv3A4LMu7S3qa7q5lHIS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-01-17 at 13:02 +0000, Venkata Duvvuru wrote:
> This ethtool patch will primarily implement the parser for the options pr=
ovided by the user for set and get hashkey before invoking the ioctl.
> This patch also has Ethtool man page changes which describes the Usage of=
 set and get hashkey options.

I'd prefer to have this combined with the -x/-X options (and add new
long options to reflect that they cover the key as well).

[...]
> diff --git a/ethtool.c b/ethtool.c
> index b06dfa3..4b05b0c 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -471,6 +471,59 @@ static int rxflow_str_to_type(const char *str)
>  	return flow_type;
>  }
> =20
> +static inline int is_hkey_char_valid(const char rss_hkey_string) {

A char is not a string.

> +	/* Are there any invalid characters in the string */
> +	return ((rss_hkey_string >=3D '0' && rss_hkey_string <=3D '9') ||
> +	       (rss_hkey_string >=3D 'a' && rss_hkey_string <=3D 'f') ||
> +	       (rss_hkey_string >=3D 'A' && rss_hkey_string <=3D 'F')); }

Braces are in the wrong places.  And the whole function is redundant
with isxdigit() anyway.

> +static int convert_string_to_hashkey(struct ethtool_rss_hkey *rss_hkey,
> +				      const char *rss_hkey_string)
> +{
> +	int i =3D 0;
> +	int hex_byte;
> +
> +	do {
> +		if (i > (RSS_HASH_KEY_LEN - 1)) {

Comparing with the wrong limit.

[...]
> +static int get_hashkey(struct cmd_context *ctx) {

Brace in the wrong place.

[...]
> +	for (i =3D 0; i < RSS_HASH_KEY_LEN; i++) {
> +		if (i =3D=3D (RSS_HASH_KEY_LEN - 1))

Wrong length.

> +			printf("%02x\n", rss_hkey->data[i]);
> +		else
> +			printf("%02x:", rss_hkey->data[i]);
> +	}
> +
> +done:
> +	free(rss_hkey);
> +	return rc;
> +}
[...]

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.

--=-kv3A4LMu7S3qa7q5lHIS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUtwbBee/yOyVhhEJAQquXg/+NheZ7G/Mk2hCSOCeK8O6RF/5u+4PqCn9
JRBdvj1EZP7yv9jxdKYlcNwv45huc3iqWid1BCgJqqb1e0q4YuBue+kosYI5DeKU
GKfij2MkVtmqUynsfARieKGO2uJhHdh4AQYHzy59RoUPMFYtavnttF25pias3Dar
D2JcLM8GnSXrByHm3PI6Uvv9luPP7WqD8U+os3fkGAR8vm4ZX3H4At9KtTVth+2X
iwRRzY3rhkXlA/Y9uJB0X4mIcrk/mOPXunoD1PFI+ooPILB1JeFzhJY6uUnKGJGd
Q18gr/8if6yP3OpjtfsWJ3sS8+4WveGDfIuXtrFfKfMTaHRhuVRjaNXEZytXWdTX
6n82N7GYZ7SwBmZKl/P5/CBbwlY2ln0ojkdq5CVU5zCQzGjLnVn8qWnjw+A9Xivx
cPe2H+6nn8RGs6p30KKcZa/VJ9tffgqH6E35xi7Dj1mNSzIjAR2lCMPwjc7VVYwC
aBc+t2jM9VjVjSEbUODtIpzGpsBqto0pEuxtcFVtKME2JweHwLx+lWBcTvmR1pBo
N7Tb5YkbVJrQduoUbc5WFJLlEM1EMaW8p64yJGdoTv3F3U54Y47vRYXE6CZhrlPT
wZQi3+EE9i3NH4OesSVXI3+EALyeYan7Wr0rcOEkQ46KnuWe1AoHbDNkO6dsfwLk
LR3Y2yt38vo=
=zjp3
-----END PGP SIGNATURE-----

--=-kv3A4LMu7S3qa7q5lHIS--
