From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH iproute2] ss: better 32bit support
Date: Sat, 14 Mar 2015 19:19:20 +0000
Message-ID: <1426360760.4173.101.camel@decadent.org.uk>
References: <1426006607.11398.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dWlx9kO9u+GeD39WMqRd"
Cc: Stephen Hemminger <shemming@brocade.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53705 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751837AbbCNTTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 15:19:34 -0400
In-Reply-To: <1426006607.11398.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dWlx9kO9u+GeD39WMqRd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-03-10 at 09:56 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> Socket cookies are 64bit, even if ss happens to be
> a 32bit binary, running on a 64 bit host.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  misc/ss.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/misc/ss.c b/misc/ss.c
> index 21a4366..ba58894 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -679,9 +679,9 @@ static inline char *sock_addr_get_str(const inet_pref=
ix *prefix)
>      return tmp;
>  }
> =20
> -static unsigned long cookie_sk_get(uint32_t *cookie)
> +static unsigned long long cookie_sk_get(const uint32_t *cookie)
>  {
> -	return (((unsigned long)cookie[1] << 31) << 1) | cookie[0];
> +	return (((unsigned long long)cookie[1] << 31) << 1) | cookie[0];

Then you should also use << 32 instead of splitting it into two shifts.

Ben.

>  }
> =20
>  static const char *sstate_name[] =3D {

--=20
Ben Hutchings
Q.  Which is the greater problem in the world today, ignorance or apathy?
A.  I don't know and I couldn't care less.

--=-dWlx9kO9u+GeD39WMqRd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVQSJvee/yOyVhhEJAQoxkBAAwirW2et9yP07YvPVpacYIDkGfiKkvIbk
xvsSOug4/hNRsvpUOc1saulqJoOR8MHjvu59T+A+eyvmMVDqgqV6vNK0QorYq5fH
NQahGXHU/OTa11ZXsHpvn8jIxHytD327m4dTquEVa27oZGelBnsggGXNNtzqM2pC
C/J/GelmRDJM71Cja2zOu5s2FaevffqcFcR1JdfO3g8gsQNsf/GwxlpEuV3w1zlE
a6LQR2/ZCuTvSw05UVZqH6rkPHwnZXny/eRG+lVmhaMavHco6+IAudTp/0/iMRyI
XdVcmgL9rAFcdWDmdwU6OpzgWkpWPD3VyPQYlH2UZwwaJYOran7pXRsPerEgazyP
NYmyGCplmpzR45mcGfMxBjVsqQaS7tbxShWo5tGMJmCZ7tspQ/cPj5KkVA62M26S
78yUPUzRfNcViSwFCpnd6THCP5PTDwPG/k/v1otv8aVTj6KVBT0n+tuX71TWBlOu
8k84n7QCyCp5GgWyNulxtDEONHwMMZNtAkx9F1zfYVlAwh+NjS2pTASm5GxrzMDz
mUiPx416QKKJnbb55qamfRjM7VZbPRna3eIEQ68zL0kgccnSaCHLZx3ggrK6oOT+
U+MExUwLSdUGhFo6+gzn+590AZRLLOc/8DUx85rhyFLavSlsODTZPrbYrB3qcTGh
0wUQSTV3M/A=
=To79
-----END PGP SIGNATURE-----

--=-dWlx9kO9u+GeD39WMqRd--
