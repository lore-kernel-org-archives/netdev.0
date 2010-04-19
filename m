From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: tip: origin tree build failure, [patch] fix isdn/gigaset build
 failure
Date: Mon, 19 Apr 2010 23:52:26 +0200
Message-ID: <4BCCD09A.4040205@imap.cc>
References: <20100419.003857.260094283.davem@davemloft.net> <20100419172731.GA4358@elte.hu> <20100419.103304.35342954.davem@davemloft.net> <20100419180520.GA9244@elte.hu> <alpine.LFD.2.00.1004191112550.14500@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC3F2EF1F61AD8624EE0C6337"
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1004191112550.14500@i5.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC3F2EF1F61AD8624EE0C6337
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 19.04.2010 20:14 schrieb Linus Torvalds:
> Maybe add the #include <linux/sched.h> into gigaset.h, instead of=20
> common.c?

Yes, that's the correct fix. Thanks a lot!

For the record, the cause of the build failure was my removal of
#include <linux/usb.h> from gigaset.h, entailing the loss of one
indirect inclusion of sched.h. There's another indirect inclusion
of sched.h from gigaset.h via interrupt.h, hardirq.h and
smp_lock.h, but that one only operates if CONFIG_PREEMPT is set.
So the reason I did not see the build failure myself was that I
only tested with CONFIG_PREEMPT=3Dy.

> ---
>  drivers/isdn/gigaset/gigaset.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/giga=
set.h
> index d32efb6..05947f9 100644
> --- a/drivers/isdn/gigaset/gigaset.h
> +++ b/drivers/isdn/gigaset/gigaset.h
> @@ -20,6 +20,7 @@
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> =20
>  #include <linux/kernel.h>
> +#include <linux/sched.h>
>  #include <linux/compiler.h>
>  #include <linux/types.h>
>  #include <linux/ctype.h>

Acked-by: Tilman Schmidt <tilman@imap.cc>

in case it still matters.

Thanks again,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enigC3F2EF1F61AD8624EE0C6337
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org/

iEYEARECAAYFAkvM0KwACgkQQ3+did9BuFs6+QCfWTWNIGnEda6mVCZqmGEbnYPi
3oIAoIzvHLbgXLh2YePYwUKL7ijKyNoQ
=w8PZ
-----END PGP SIGNATURE-----

--------------enigC3F2EF1F61AD8624EE0C6337--
