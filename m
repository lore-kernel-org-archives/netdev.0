From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2] ethtool: allow for a smaller build
Date: Sun, 16 Mar 2014 02:24:20 +0000
Message-ID: <1394936660.15764.65.camel@deadeye.wl.decadent.org.uk>
References: <1393544581-1252-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/dowtqaNTc7BNFuvqTJH"
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44500 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753159AbaCPCYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2014 22:24:31 -0400
In-Reply-To: <1393544581-1252-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/dowtqaNTc7BNFuvqTJH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-02-27 at 15:43 -0800, Florian Fainelli wrote:
> Introduce a new configure script option: --disable-pretty-dump which will
> disable building the driver specific register, EEPROM and SFP
> pretty printing objects, the saving are:
>=20
> ~500 Kbytes on a x86_64 build
> ~337 Kbytes on a arm build
>=20
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2:
> - reworked the small build around the ETHTOOL_ENABLE_PRETTY_DUMP
>   option which is enabled by default

But not if you actually specify the option.

[...]
> --- a/configure.ac
> +++ b/configure.ac
> @@ -30,5 +30,14 @@ dnl Checks for library functions.
>  AC_HEADER_STDC
>  AC_CHECK_FUNCS(socket strtol)
> =20
> +dnl Check for options
> +AC_ARG_ENABLE(pretty-dump,
> +	       [  --enable-pretty-dump	  enable registers, EEPROM and SFP prett=
y dumps (enabled by default)],,

Too many commas there!  The following logic needs to be the third
argument to AC_ARG_ENABLE:

> +	       [if test x$enableval !=3D xno; then
> +			AC_DEFINE(ETHTOOL_ENABLE_PRETTY_DUMP, 1,
> +			[Define this to enable register, EEPROM and SFP pretty dumps.]) enabl=
e_prettydump=3Dyes
> +		fi])

And then the fourth argument is for the default, which must set
enable_prettydump=3Dyes.

[...]
> --- a/ethtool.c
> +++ b/ethtool.c
[...]
> @@ -973,13 +979,13 @@ static int dump_eeprom(int geeprom_dump_raw, struct=
 ethtool_drvinfo *info,
>  		fwrite(ee->data, 1, ee->len, stdout);
>  		return 0;
>  	}
> -
> +#ifdef ETHTOOL_ENABL_PRETTY_DUMP
[...]

Typo.

Ben.

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-/dowtqaNTc7BNFuvqTJH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyULVOe/yOyVhhEJAQpzZA//d2SkZs+qg1KUiFEpVgJh3ac37E4XswQz
gdzYxTTIh6fF40rFqI1lvjZ4xbwC/DzXlNoDqb3WYVNnJgoFDjGrDGLG0wTPV/uN
APkRoM1mLS+tENTnlgqimKiFwZ4pt7FyDrlGX2UXZqNpw38g2g12f8OC9lCY+GO8
ce7fg1shdcU+BpGR4swtPWx9I3CjR/qGuWLt4/mHsPQO2Vb6skVq7Zx0ZDJnQQWp
ffNm6Sj8+YV6sqUhm/scdZa4PScuGvm0gPoTAVUJlf63diY/7b2ZE3oGt08rah0P
xLtIKjvpPOmxyf5v2tqMUS8f1oq0MnA+FMdCWJST3YK9UOyVlaHBnuPgvVzCI93G
au2gF6VoE76Lx5XASfBJGtns78VDEPqqdpc59cIs4xbSUyuVPgXcyijdUvP/umJ6
M4vhCaJXDJs03BSZ/UeOo+9MnVQLaXbOh7cKF2cY2YQv3XgP4KwM9/804MKpx5mv
s+5GPvb1V4jUltsbjli7BJg5E1dzJRZMti2exfkFDChXVUNDPFsU21M7LypV1a5d
nV5Zd33mmLaF0d9Fl7KIaBeFUgDDd/uzsT6a75M+DJkvouDec/x6ZusFp1X9/kKx
OF24lvbUBS91fbPm3s7d8aN74WBYR6wSohV7EA8CtZ4+KQMh7t2OHPOGlbi8cufS
j4XuWR6u+w4=
=IYwk
-----END PGP SIGNATURE-----

--=-/dowtqaNTc7BNFuvqTJH--
