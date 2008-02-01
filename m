From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] ieee80211: fix section mismatch warning
Date: Fri, 01 Feb 2008 13:07:12 +0100
Message-ID: <1201867632.4188.0.camel@johannes.berg>
References: <20080201115206.GA12678@uranus.ravnborg.org>
	 (sfid-20080201_125234_351197_7981BA3B)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-UFIPivt3Qk2UG4SsN4wh"
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:39122 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763248AbYBAMKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 07:10:07 -0500
In-Reply-To: <20080201115206.GA12678@uranus.ravnborg.org> (sfid-20080201_125234_351197_7981BA3B)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-UFIPivt3Qk2UG4SsN4wh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Fri, 2008-02-01 at 12:52 +0100, Sam Ravnborg wrote:
> Fix the following warnings:
> WARNING: net/built-in.o(.init.text+0xd6c0): Section mismatch in reference=
 from the function ieee80211_init() to the function .exit.text:rc80211_simp=
le_exit()
> WARNING: net/built-in.o(.init.text+0xd6c5): Section mismatch in reference=
 from the function ieee80211_init() to the function .exit.text:rc80211_pid_=
exit()
>=20
> The fix was simple - I just did as modpost told me and removed the
> wrong __exit annotation of rc80211_simple_exit and rc80211_pid_exit.

Heh, I just sent the same patch.

> Signed-off-by: Sam Ravnborg <sam@ravnborg.org>

Acked-by: Johannes Berg <johannes@sipsolutions.net>

> Cc: Johannes Berg <johannes@sipsolutions.net>
> Cc: John W. Linville <linville@tuxdriver.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>=20
> With this patch my allyesconfig build on x86 (64 bit)
> is section mismatch clean in net/
>=20
> 	Sam
>=20
> diff --git a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_a=
lgo.c
> index 554c4ba..c339571 100644
> --- a/net/mac80211/rc80211_pid_algo.c
> +++ b/net/mac80211/rc80211_pid_algo.c
> @@ -538,7 +538,7 @@ int __init rc80211_pid_init(void)
>  	return ieee80211_rate_control_register(&mac80211_rcpid);
>  }
> =20
> -void __exit rc80211_pid_exit(void)
> +void rc80211_pid_exit(void)
>  {
>  	ieee80211_rate_control_unregister(&mac80211_rcpid);
>  }
> diff --git a/net/mac80211/rc80211_simple.c b/net/mac80211/rc80211_simple.=
c
> index 934676d..9a78b11 100644
> --- a/net/mac80211/rc80211_simple.c
> +++ b/net/mac80211/rc80211_simple.c
> @@ -389,7 +389,7 @@ int __init rc80211_simple_init(void)
>  	return ieee80211_rate_control_register(&mac80211_rcsimple);
>  }
> =20
> -void __exit rc80211_simple_exit(void)
> +void rc80211_simple_exit(void)
>  {
>  	ieee80211_rate_control_unregister(&mac80211_rcsimple);
>  }
>=20

--=-UFIPivt3Qk2UG4SsN4wh
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR6MLb6Vg1VMiehFYAQJigA/9Hje7tdwJOMK5dTMg2Eltx77hQXTmJ69/
1oo1fPYBV4TxXBapRfOrk2LGkavW2uxP3g4eDaS6OTT42wB0zO6W3f+XNPkc/amt
LG796TUhUt34ty1lYApW038oYsesOGjk2mqB/AoDDnOuYgD4PtL8iXJEmD5Edz36
otakvfGtTtWHP45T404gzWiKEATMM/anXhgMWaYbjdPIoASQwHqynnxQ2u/aANvL
rLoKoRloBTbM6rNz2SqVPUDvmHi1g1ZYKM2YzZNZnRLaF5EKaO8mz+yxq0LR0s+R
SK1RmChqjyYFegX5nJAiKtyzA5s0UfKeirCCFoIwklnc6fNGvg3EtyA+C4MCeTC1
WEafawkMjMAiXUZFyMtZ0DNZgodMqXmeeGm+Z74BUoN/k2TmcBU5gpssdkGALW6a
AmqDG6JWJp1ZnpGQvHd0+U5D9sirFErEaTKCLXk9Ba0q/1OU8857iYvYnKmUxbD1
zfh8R23FB7Z31C7GMyOnegL6ObkL8FSsn/Z7vTWPZ0AtchxoPTdiYxHMmv4fdoyf
sFIdOrSA4BIn2l+xL10eumljJxe5jeNppgNTRZ8hmrqkZoa45mEW44ubo/mXnMFg
G5pBJkdEwUrMk3GsIaG4WcGzmZwYrBvdxtY4ii6PAhVYQspmMxICgWsawWFOerFm
A3OtuQONnxI=
=WBEc
-----END PGP SIGNATURE-----

--=-UFIPivt3Qk2UG4SsN4wh--

