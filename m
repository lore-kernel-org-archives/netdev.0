From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: include/linux/netlink.h: problem when included by an
 application
Date: Sun, 07 Aug 2011 02:15:07 +0100
Message-ID: <1312679707.2591.987.camel@deadeye>
References: <1312580748.2326.15.camel@Thor>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-h2p8Y6CZ8juJIz2MD7cE"
Cc: netdev@vger.kernel.org
To: Michel Machado <michel@digirati.com.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60274 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755266Ab1HGBPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 21:15:11 -0400
In-Reply-To: <1312580748.2326.15.camel@Thor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-h2p8Y6CZ8juJIz2MD7cE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-08-05 at 17:45 -0400, Michel Machado wrote:
> Hi there,
>=20
>    When an application includes header <linux/netlink.h> obtained with
> 'make headers_install' or from /usr/include/, it produces the following
> error:
>=20
> /usr/include/linux/netlink.h:31:2: error: expected
> specifier-qualifier-list before =E2=80=98sa_family_t=E2=80=99

Yeah, I know.

>    The error doesn't come up in the kernel because
> include/linux/netlink.h has the following line:
>=20
> #include <linux/socket.h> /* for sa_family_t */
>=20
>    However, <linux/socket.h> from /usr/include/ doesn't have sa_family_t
> because it's protected by an $ifdef __KERNEL__ in
> include/linux/socket.h.

Which is correct, as it would otherwise conflict with <sys/socket.h>.

Previous history:
http://thread.gmane.org/gmane.linux.debian.devel.bugs.general/622621
http://thread.gmane.org/gmane.linux.network/143380

>    A workaround for an application is to include <sys/socket.h> before
> <linux/netlink.h>. However, shouldn't include/linux/netlink.h be fixed?
>=20
>    The simplest solution that I came up was replacing sa_family_t in
> include/linux/netlink.h to 'unsigned short' as header
> include/linux/socket.h does for struct __kernel_sockaddr_storage
> available to applications.

Maybe we should do something like this in <linux/socket.h>:

typedef unsigned short __kernel_sa_family_t;
#ifdef __KERNEL__
typedef __kernel_sa_family_t sa_family_t;
#endif

and then use __kernel_sa_family_t in <linux/netlink.h>.

Ben.



--=-h2p8Y6CZ8juJIz2MD7cE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATj3nGue/yOyVhhEJAQqAUA/8Dj4DIHC6blr9fPpTTZ7maqGrN2kO113N
8ygerzZfSNeS3tNen+Ue3YqgqbKH3bFI8qKXOyVnbjZ9iDzE3lvEhSpCFBc8SFc8
5kcdSpUwb1mse1C0w70BlgZYUk/BWibU6c2RRFktl9wFQgZUH3xfqjGJfjMwBuU6
7pnXOzEyedv0iM5ffk0Rtgvfu24AtfYRhrxP8NklMRUKzE9byd4Sy2GLjrPND0pB
jnYyLNkIYsa9jobNP0cQkuGZdwDJKWay86Vpa5Ae31j1afx4fWtQakoS6iEXq6m0
PrgT8Uo3IYDzru8Yzz2p2mvTvvC7+lDjDTR0liMpx4fdCkKh1h/CUraSVesoWt9w
8bdQOCOD8A/fT6WLYYtU2VsxuFkWgtLldkY1TXTkshLDhXrOJXJV+YWQ8Jf7G5rW
0gviILpT931EIkytCITWmajDMURrPl+iRwLBmi/uJt5TIixU/TB9lBTzosw0nZKr
Z/U/zaAb7YB+TlSmJuHTJn8GGc4VII4kA6CkcbYucftZGOF6lurJVeX698t/hzOr
mFkZpn2wS2sBHZBMizRAfk8JNxpsAKomBRObbMWrf+ilVly4mAW2UaE/8boT+GJu
CY+nQFdnIVoTJ+EigYD4Sq4dmK7wedYmOGwO7/+VTkz1UtcKwpnX8wkGYLk1XDCU
60zCuoksaoY=
=OoRa
-----END PGP SIGNATURE-----

--=-h2p8Y6CZ8juJIz2MD7cE--
