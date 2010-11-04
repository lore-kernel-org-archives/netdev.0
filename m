From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: Freeing alive fib_info caused by ebc0ffae5
Date: Thu, 04 Nov 2010 22:35:26 +1100
Message-ID: <1288870526.30549.19.camel@concordia>
References: <1288866186.30549.10.camel@concordia>
	 <1288866626.2659.71.camel@edumazet-laptop>
	 <1288869699.2659.77.camel@edumazet-laptop>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-LaYp6z8jkNNWik/KQNbb"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57718 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154Ab0KDLf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 07:35:28 -0400
In-Reply-To: <1288869699.2659.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LaYp6z8jkNNWik/KQNbb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-11-04 at 12:21 +0100, Eric Dumazet wrote:
>=20
> Hmm, a review of the code spotted a bug in fib_result_assign()
>=20
> Please try following patch :
>=20
> Thanks again !
>=20
> [PATCH] fib: fib_result_assign() should not change fib refcounts
>=20
> After commit ebc0ffae5 (RCU conversion of fib_lookup()),
> fib_result_assign()  should not change fib refcounts anymore.
>=20
> Thanks to Michael who did the bisection and bug report.
>=20
> Reported-by: Michael Ellerman <michael@ellerman.id.au>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/fib_lookup.h |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>=20
> diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
> index a29edf2..c079cc0 100644
> --- a/net/ipv4/fib_lookup.h
> +++ b/net/ipv4/fib_lookup.h
> @@ -47,11 +47,8 @@ extern int fib_detect_death(struct fib_info *fi, int o=
rder,
>  static inline void fib_result_assign(struct fib_result *res,
>  				     struct fib_info *fi)
>  {
> -	if (res->fi !=3D NULL)
> -		fib_info_put(res->fi);
> +	/* we used to play games with refcounts, but we now use RCU */
>  	res->fi =3D fi;
> -	if (fi !=3D NULL)
> -		atomic_inc(&fi->fib_clntref);
>  }
> =20
>  #endif /* _FIB_LOOKUP_H */

Perfect, that fixes it, thanks!

cheers



--=-LaYp6z8jkNNWik/KQNbb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkzSmn4ACgkQdSjSd0sB4dKjTQCcCGn8xZZB+26ejbhZKzns93Cr
TdoAoI6GdfzJqvkrq/QDrlUx7xY12gXI
=QroF
-----END PGP SIGNATURE-----

--=-LaYp6z8jkNNWik/KQNbb--

