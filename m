From: Christian Hesse <mail@eworm.de>
Subject: Re: [PATCH 1/1] ip-link: in human readable output use dynamic
 precision length
Date: Tue, 4 Nov 2014 11:44:21 +0100
Message-ID: <20141104114421.6a7f9de5@leda.localdomain>
References: <1415093990-22632-1-git-send-email-mail@eworm.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/WN+NKVznVYpoGii3D5DERRZ"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:58485 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbaKDKoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 05:44:32 -0500
In-Reply-To: <1415093990-22632-1-git-send-email-mail@eworm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/WN+NKVznVYpoGii3D5DERRZ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Christian Hesse <mail@eworm.de> on Tue, 2014/11/04 10:39:
> Now that we use floating point numbers for human readable output we can
> calculate precision length on the fly.
> ---
>  ip/ipaddress.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index e240bb5..0ddcb0d 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -343,8 +343,8 @@ static void print_num(FILE *fp, unsigned width,
> uint64_t count) ++prefix;
>  	}
> =20
> -	snprintf(buf, sizeof(buf), "%.1f%c%s", (double) count / powi,=20
> -		 *prefix, use_iec ? "i" : "");
> +	snprintf(buf, sizeof(buf), "%.*f%c%s", 3 - snprintf(NULL, 0,
> "%"PRIu64, count / powi),
> +		(double) count / powi, *prefix, use_iec ? "i" : "");
> =20
>  	fprintf(fp, "%-*s ", width, buf);
>  }

Damn... In IEC mode we have negative precision length for values between 10=
00
and 1024. Will send a new patch.
--=20
Best Regards,
Christian Hesse

--Sig_/WN+NKVznVYpoGii3D5DERRZ
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUWK4JAAoJEFTtyRYJvJGD7wEP/1IbMT7XDjwoIQ2JrMPFAPUo
uTAQBs6aRDaVNLbp/0vaX7t+UPorx0HIvnpmzJDsvaZgUiL4sh9/z2Ov06YfC2Gf
ElHD1z+BZD+jVQa0MckWzs8n7OHTWeyoEt9g2opBO79+GWi+QG6e11MVYwuOOCdz
RwHzwOktAjRYSi9exdvV6iTgU50gGWpto8GJp+EZHKCBv7XnaeFJsA0uGBwJUHt9
E31WhnCw0ahXDjTL3VWmiITDipf31q7bpf2Il6os7AJCq14qsovWEYHYTNaWa3fd
6c49F6o7SkVBezNaSVrR38X/3gxUKIjFMPhWjssaEgsvOawrA0qoRWRRANbr4sAl
FAmm5ag53uPj2WZWIJoktfiWlzgMmr3WuzCXrCe8lTq6mEyAZU9I8BE1ez4WbX4v
JgBodZjyKC28ejlmWByKPUb+aQg5nuM+t6FnOzLwTazkHOb8M5AqApLcg7hNoocG
BqMYjROkquVpfsOWZbC/u4EF9MX+eUQRdQL13/mJSZ0gMEPjIjH3D5N8WL/DgrN2
oHrEp8V0X34AnaUNmlcaATX7nNvguPoND+EOUhILiwU3IFSMUVT6lGgXG2+htSvy
Wo8HXO2XjDGr4CuLCBpy/eph8lhpraQTSkGe9jFLU5sxN0YpcUpN2EFGF9WLhGqv
10b8cNm5N0mymr7aH/Jc
=47Y4
-----END PGP SIGNATURE-----

--Sig_/WN+NKVznVYpoGii3D5DERRZ--
