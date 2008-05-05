From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC/T] [NET] give truesize warning when truesize differs
Date: Mon, 05 May 2008 15:11:20 +0200
Message-ID: <1209993080.8245.16.camel@johannes.berg>
References: <1209924728.3655.7.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3h2r9nCewhkC51MfSQ2n"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:39244 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758054AbYEENMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 09:12:22 -0400
In-Reply-To: <1209924728.3655.7.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3h2r9nCewhkC51MfSQ2n
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-05-04 at 20:12 +0200, Johannes Berg wrote:
> This patch makes the truesize warning be printed when the truesize
> actually changed, not just when the header was increased and the
> additional size actually used.
>=20
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> It'll trigger with mac80211, should hold it until I fixed that.
>=20
>  include/linux/skbuff.h |    8 ++++++--
>  net/core/skbuff.c      |   10 ++++++++--
>  2 files changed, 14 insertions(+), 4 deletions(-)
>=20
> --- everything.orig/include/linux/skbuff.h	2008-05-03 15:47:00.000000000 =
+0200
> +++ everything/include/linux/skbuff.h	2008-05-04 00:30:34.000000000 +0200
> @@ -387,9 +387,13 @@ extern void	      skb_truesize_bug(struc
> =20
>  static inline void skb_truesize_check(struct sk_buff *skb)
>  {
> -	int len =3D sizeof(struct sk_buff) + skb->len;
> +#ifdef NET_SKBUFF_DATA_USES_OFFSET
> +	int len =3D sizeof(struct sk_buff) + skb->end;
> +#else
> +	int len =3D sizeof(struct sk_buff) + (skb->end - skb->head);
> +#endif

Umm, is this even correct? Should it check data_len? I seem to get the
truesize warning a bit now:

[11381.081709] SKB BUG: Invalid truesize (16864) size=3D4112, sizeof(sk_buf=
f)=3D272
[11381.081725] last reallocate at:
[11381.081729]  [<c0274194>] __alloc_skb+0xdc/0x140
[11381.081745]  [<c02aeca8>] sk_stream_alloc_skb+0x38/0x134
[11381.081758]  [<c02af16c>] tcp_sendmsg+0x3c8/0xcbc
[11381.081767]  [<c026bcc4>] sock_sendmsg+0xac/0xe4
[11381.081780]  [<c026c058>] sys_sendto+0xbc/0xec
[11381.081790]  [<c026cbc8>] sys_socketcall+0x14c/0x1dc
[11381.081800]  [<c00124cc>] ret_from_syscall+0x0/0x38


johannes

--=-3h2r9nCewhkC51MfSQ2n
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB8Hd6Vg1VMiehFYAQIchg//aUGnQ2vtvliZ6zrF0ID7AqPrnhXIU3M7
XQPXz05cMMb1XemsU3ue4m1BqFUP53vq3k/Q/Lkwgvumz39XXz6SKLioM4kojzJ0
z18GNG84mpqooatWLBQbzXXW4NbFMDzfovWr61A8f021J0GAB6zQXxtzKjyyCSNm
IjRZz/jkquFHRjddcBiruQeZBHiPOWUN6PoMS4v4jGX+z/foWrZDl/KKuXWJKp6G
5721sNPPxAUs0McJNF9gQaUubTPBn3oEQwWctZnDQytvQtVy8S5JoB4ZfpVADWGV
XaBopKfSag1T5WVGNVeJBmso6Oz4BHyUQOzsxkwFHHYisRUqCyp17TpaI2IxKX76
zXT3lEh6PeykgynLhn7J0hO9BeM8scGx9Q38Iob+pIQEMYdvfExmX9Bil3PjbnsV
yAYhcZ0Axhtk0QVBwr0w6j31baJewyDhVvdmjZpmkozQBo6MVbxhT+mJHkcgOaHV
+7yr+uDOHJ+SamgwN3c5mfOxa7eBCrUQ+HYX2khzPcKp11J7rOEpXVdBz7KJboZa
LiEtIU9KlicLDXU8qyoTCFuacWd0YIUqFeWsGpcWD2kI5l7t4yrNHUIuWJgBOt54
GJ06EyUG9CTAhxjI6CRp5ltYUIAkqUuAW3O10RMa8uwFf1yccGmHwrDYYHfOAZhk
6WaPDFQw6+U=
=NLQc
-----END PGP SIGNATURE-----

--=-3h2r9nCewhkC51MfSQ2n--

