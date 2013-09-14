From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [patch 2/4] mISDN: add support for group membership check
Date: Sun, 15 Sep 2013 00:28:56 +0100
Message-ID: <1379201336.19779.35.camel@deadeye.wl.decadent.org.uk>
References: <20130913215202.7D16C31C1BF@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-kG3z8p22S7D2OrsQNINH"
Cc: davem@davemloft.net, netdev@vger.kernel.org, isdn4linux@koppen.de,
	isdn@linux-pingi.de, jslaby@suse.cz,
	sergei.shtylyov@cogentembedded.com
To: akpm@linux-foundation.org, jeffm@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52656 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756791Ab3INX30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Sep 2013 19:29:26 -0400
In-Reply-To: <20130913215202.7D16C31C1BF@corp2gmr1-1.hot.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kG3z8p22S7D2OrsQNINH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-09-13 at 14:52 -0700, akpm@linux-foundation.org wrote:
> From: Jeff Mahoney <jeffm@suse.com>
> Subject: mISDN: add support for group membership check
>=20
> This patch adds a module parameter to allow a group access to the mISDN
> devices.

This doesn't just 'add support' or 'allow a group access'.  It also
changes the default behaviour.

[...]
> --- a/drivers/isdn/mISDN/core.c~misdn-add-support-for-group-membership-ch=
eck
> +++ a/drivers/isdn/mISDN/core.c
> @@ -21,10 +21,14 @@
>  #include "core.h"
> =20
>  static u_int debug;
> +static u_int gid;
> +kgid_t misdn_permitted_gid;
> =20
>  MODULE_AUTHOR("Karsten Keil");
>  MODULE_LICENSE("GPL");
>  module_param(debug, uint, S_IRUGO | S_IWUSR);
> +module_param(gid, uint, 0);

So you can't change the privileged gid after loading, or even see what
it is.

[...]
> --- a/drivers/isdn/mISDN/socket.c~misdn-add-support-for-group-membership-=
check
> +++ a/drivers/isdn/mISDN/socket.c
> @@ -612,6 +612,11 @@ data_sock_create(struct net *net, struct
>  {
>  	struct sock *sk;
> =20
> +	if (!capable(CAP_SYS_ADMIN) &&
> +			!gid_eq(misdn_permitted_gid, current_gid()) &&
> +			!in_group_p(misdn_permitted_gid))
> +		return -EPERM;
> +
>  	if (sock->type !=3D SOCK_DGRAM)
>  		return -ESOCKTNOSUPPORT;
> =20

I'm pretty sure you could restrict this with LSMs, in a much more
flexible way.

> @@ -694,6 +699,10 @@ base_sock_ioctl(struct socket *sock, uns
>  	case IMSETDEVNAME:
>  	{
>  		struct mISDN_devrename dn;
> +		if (!capable(CAP_SYS_ADMIN) &&
> +				!gid_eq(misdn_permitted_gid, current_gid()) &&
> +				!in_group_p(misdn_permitted_gid))
> +			return -EPERM;
>  		if (copy_from_user(&dn, (void __user *)arg,
>  				   sizeof(dn))) {
>  			err =3D -EFAULT;

This seems to be the important bit: renaming of devices (if allowed at
all) ought to be limited to CAP_SYS_ADMIN or possibly CAP_NET_ADMIN.
But why should the group that is allowed to use mISDN data sockets also
be allowed to do this?

Ben.

--=20
Ben Hutchings
In a hierarchy, every employee tends to rise to his level of incompetence.

--=-kG3z8p22S7D2OrsQNINH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIVAwUAUjTxOOe/yOyVhhEJAQrWChAAlwzljjEfV4hud38OPcvD3s3N1Hd54cPE
pAC7VJSSZwfXfuw1BFfbfnlLTU3pnyieJP7PdgBoWYFJirS2F0I+cN0w5otMy2Ta
jskW8va0NDJ2mBKGU1F23SohZRx2d1rptSFtm2FEgqH0al/vrON7lYPuKm+426qH
nTZXcCg0SkuO2cR8Z0z25txfSbklYz2C2/E5TdLgLdtT1WKIY3O7l5EZO05uBk9+
TJ5z+C0sGlAkkPK/J1WXH0x5PeE6Y1tqMr7u5hiTrk61YdKaabozU+UC9zREqVlQ
j8wdGTSwZ+8poa1/fuX/HPdcUvNJjqVsmrkevoBiTqjBs2T14uZ0GQkAhqCthcQ7
+WL04QFYD3l/gF4eReU4qYkAjmqt0o02NBpk472hSfXPDiLfFK3vzzkNaJd+gXF2
lZVhuC/sJwCACn4CYyFxcDhx+Jf9bCzOK9wekXYrVh2U6tMV7wBfSlkxELRlaGE0
AY0V0Qt62F6DqyOPXsXkUIolY6vpKtlkEYGGiYcWPyFiiOcQ3SZGo2xzIA/v6ioI
dUoiAAF/nI5IcGQOYsqNzP4Adk219WOM6X57IHBm9k8GyA71IOweP5z0qV7XrT5K
ONlu7NLdGCxj24QRvdKD2tMK1JJTbkglGLJ+MytwtDQMBZYVPp4QZA1tzLmxsOxu
BLcYLa9b1FI=
=d2ks
-----END PGP SIGNATURE-----

--=-kG3z8p22S7D2OrsQNINH--
