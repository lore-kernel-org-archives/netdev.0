From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/2] ethtool: allow for a smaller build
Date: Thu, 27 Feb 2014 22:52:50 +0000
Message-ID: <1393541570.14067.73.camel@deadeye.wl.decadent.org.uk>
References: <1393464911-21593-1-git-send-email-f.fainelli@gmail.com>
	 <1393464911-21593-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gFWJKowHnictyJVBGEX0"
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46654 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751775AbaB0WxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:53:02 -0500
In-Reply-To: <1393464911-21593-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gFWJKowHnictyJVBGEX0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-02-26 at 17:35 -0800, Florian Fainelli wrote:
> Introduce a new configure script option: --enable-small which will
> disable building the driver specific register dump objects, the savings
> are:
>=20
> ~500 Kbytes on a x86_64 build
> ~337 Kbytes on a arm build

OK, I can see that will be useful in some environments.

[...]
> --- a/configure.ac
> +++ b/configure.ac
> @@ -30,5 +30,13 @@ dnl Checks for library functions.
>  AC_HEADER_STDC
>  AC_CHECK_FUNCS(socket strtol)
> =20
> +dnl Check for options
> +AC_ARG_ENABLE(small,
> +	       [  --enable-small	  disable registers and EEPROM pretty dumps (d=
isabled by default)],

That's a slightly confusing description.  It could be read as meaning
that the pretty dumps are disabled by default.

Maybe change the sense of this and call it --enable-pretty-dump, enabled
by default?

> +	       [if test x$enableval =3D xyes; then
> +			AC_DEFINE(SMALL, 1, [Define this to disable register and EEPROM prett=
y dumps.]) enable_small=3Dyes
> +		fi])
> +AM_CONDITIONAL([SMALL], [test x$enable_small =3D xyes])
[...]

As this is defining a macro which is effectively global, please rename
it to a more specific name like ETHTOOL_SMALL (or reversing the sense,
ETHTOOL_ENABLE_PRETTY_DUMP).

Please also make the ethtool --version option report whether it's a
small build.

Ben.

--=20
Ben Hutchings
It is easier to change the specification to fit the program than vice versa=
.

--=-gFWJKowHnictyJVBGEX0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUw/Bwue/yOyVhhEJAQpYxg//RrXLGniBDmG9yUxDMKZpWQznWD1+CyP6
ciQ8qW6YOEURlkBmzl540njNs3tNhNl4whK0OvKlmK2evcff/GwddZqdAFzFm/w+
5+HBn/uz8UOmfFfgluGjmvDsCc8pVRRg9AGUq+sEmhykfSwzAs/NJaADA/9gZa5t
rCM9nJ514DEzORPlR9lqRquh2r+GupK3k0kGJSaf0yv3Bj7hlDKIIIp8yL8LTnu9
Fu5JqG8Hyt2L7Dh1kdHSEkFVIAQzWoxZXYF8DOk5PPR0qXi3LK7fztzlOXtwDJde
E5mJiE3U+HWtF+46N2ha8gxxaWkNsa8J5vVaCidNi39Q+YiqxPCxBPow9AYfwaLu
iORMEcJ+JmfuvHrzDj/IoGlUynpJGR0uoFtYV0FA3LD2xdMTrf3jZ+SxDZwc/MsH
TNp0tHRp4LERJx/TcNx0KT4RJA//r/Wm47bUuOaZvtFDgpYRHhqDYwMlL//nPd5p
/IgOzV6pGzR3XHKYHoL8rrqt8ms3pahi4wolLFWFp6Yik36NoHFm5dUEvyBVuiv7
0wtlkAPTVS0P53mV4VO/eeGHUYOF7V2KrF1uyh/cBZ0FutTxPJ/ZdgV527FzzjU7
mQPC/Qq+yZ4yz9T4O/5sKsGi558Knib+eAntgfFY4h96/GgXhUIK874s1okzhLP1
NNP7dIZ+OHg=
=o/aq
-----END PGP SIGNATURE-----

--=-gFWJKowHnictyJVBGEX0--
