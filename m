From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] igmp: Avoid zero delay when receiving odd mixture
 of IGMP queries
Date: Tue, 10 Jan 2012 00:23:09 +0000
Message-ID: <1326154989.3432.18.camel@deadeye>
References: <20120109220428.GS20752@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Eyl/mHJ7XWKZXfQb7sUj"
Cc: netdev@vger.kernel.org, Simon McVittie <smcv@debian.org>,
	654876@bugs.debian.org, security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33513 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933521Ab2AJAXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 19:23:21 -0500
In-Reply-To: <20120109220428.GS20752@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Eyl/mHJ7XWKZXfQb7sUj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-01-09 at 22:04 +0000, Ben Hutchings wrote:
> Commit 5b7c84066733c5dfb0e4016d939757b38de189e4 ('ipv4: correct IGMP
> behavior on v3 query during v2-compatibility mode') added yet another
> case for query parsing, which can result in max_delay =3D 0.  Substitute
> a value of 1, as in the usual v3 case.

This has been assigned CVE-2012-0207.

Ben.

> Reported-by: Simon McVittie <smcv@debian.org>
> References: http://bugs.debian.org/654876
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
>  net/ipv4/igmp.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index d577199..e0d42db 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -875,6 +875,8 @@ static void igmp_heard_query(struct in_device *in_dev=
, struct sk_buff *skb,
>  		 * to be intended in a v3 query.
>  		 */
>  		max_delay =3D IGMPV3_MRC(ih3->code)*(HZ/IGMP_TIMER_SCALE);
> +		if (!max_delay)
> +			max_delay =3D 1;	/* can't mod w/ 0 */
>  	} else { /* v3 */
>  		if (!pskb_may_pull(skb, sizeof(struct igmpv3_query)))
>  			return;

--=20
Ben Hutchings
Life is what happens to you while you're busy making other plans.
                                                               - John Lenno=
n

--=-Eyl/mHJ7XWKZXfQb7sUj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATwuE7ee/yOyVhhEJAQrkzBAAtHiXT8x5s2s9CQqm6bx8WH1qCzvUC2Ni
ZIFsmDmHfKhonYwz05eB+D34wGSuphRkIPZqlJyWsHy9e7OkdYm4WT9I/QM8OnKf
omatJJP0+I33/YBVa+jHm3EaLoEPFSToPDuOad6+XToNPpPmKvIat4/nsK/G5fxb
QJtAp8ergg84i2EAnZR2Qy3O9GAgsZDLhkFEbuQGj97yH+nVggnj5VQ2oepeDP8b
a/RPnzmKzH4kMesmJostUlak3T/MOxC60mFKMg0P3ZXtUjTAxDTPmataaVbO4msY
E/4bvVdWDe9+DZE7fEZFs+2NpB+3/L8vci+pOYOM9pba8hcbu8RcWMaAS85hctH2
p7dFMjYEE1qhizwF3jdfYSfqngRMpFMxVd1WplFttpwPmDfxYmhDK+jRGYA1ry0X
A1lNDLqywKNlEKehjRqUcLexYSJsLeuffqgL2wBxqtLM4MqSLq3FO8jyUoIXV+at
L1rZyhHXez8Go4IChZ7IqR8K5VIZAzTFytKiiXM60fuyEmmno7iyCS11cFyEcS+p
qowv1J+/fUu4A52W/wk0RBE0GipoBnGfs6JLJbzx9+R58sHl+MtlO4/r0xGK3cTs
hbuCLKOlBddWJCZFHFiXVfYnRYCl9u/gPSfLe/dfCH25cruxwY8LeRIlcS7qTqOs
tNd8N/T+3nw=
=Rygv
-----END PGP SIGNATURE-----

--=-Eyl/mHJ7XWKZXfQb7sUj--
