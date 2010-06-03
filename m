From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: [patch] isdn/kcapi: return -EFAULT on copy_from_user errors
Date: Thu, 03 Jun 2010 12:26:42 +0200
Message-ID: <4C078362.1080005@web.de>
References: <20100603095613.GP5483@bicker>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig16F7EAAD134EE5745258FDA8"
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:57719 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933486Ab0FCK0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:26:45 -0400
In-Reply-To: <20100603095613.GP5483@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig16F7EAAD134EE5745258FDA8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Dan Carpenter wrote:
> copy_from_user() returns the number of bytes remaining but we should
> return -EFAULT here.  The error code gets returned to the user.  Both=20
> old_capi_manufacturer() and capi20_manufacturer() had other places
> that already returned -EFAULT so this won't break anything.
>=20

Good point.

> Signed-off-by: Dan Carpenter <error27@gmail.com>
>=20
> diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
> index bde3c88..b054494 100644
> --- a/drivers/isdn/capi/kcapi.c
> +++ b/drivers/isdn/capi/kcapi.c
> @@ -1020,12 +1020,12 @@ static int old_capi_manufacturer(unsigned int c=
md, void __user *data)
>  		if (cmd =3D=3D AVMB1_ADDCARD) {
>  		   if ((retval =3D copy_from_user(&cdef, data,
>  					    sizeof(avmb1_carddef))))
> -			   return retval;
> +			   return -EFAULT;
>  		   cdef.cardtype =3D AVM_CARDTYPE_B1;
>  		} else {
>  		   if ((retval =3D copy_from_user(&cdef, data,
>  					    sizeof(avmb1_extcarddef))))
> -			   return retval;
> +			   return -EFAULT;
>  		}
>  		cparams.port =3D cdef.port;
>  		cparams.irq =3D cdef.irq;
> @@ -1218,7 +1218,7 @@ int capi20_manufacturer(unsigned int cmd, void __=
user *data)
>  		kcapi_carddef cdef;
> =20
>  		if ((retval =3D copy_from_user(&cdef, data, sizeof(cdef))))
> -			return retval;
> +			return -EFAULT;
> =20
>  		cparams.port =3D cdef.port;
>  		cparams.irq =3D cdef.irq;

No need to assign retval anymore, it is overwritten in all non-error case=
s.

Jan


--------------enig16F7EAAD134EE5745258FDA8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAkwHg2IACgkQitSsb3rl5xRiWwCg6k7ubr+H4CU64ypNAucbKVEA
lCcAoO2UXz/ASGwm7jKqOYbT/IM8JLd0
=o5pa
-----END PGP SIGNATURE-----

--------------enig16F7EAAD134EE5745258FDA8--
