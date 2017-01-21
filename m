From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net-next] ipv6: add NUMA awareness to seg6_hmac_init_algo()
Date: Sat, 21 Jan 2017 13:18:55 +0100
Message-ID: <588351AF.6060203@uclouvain.be>
References: <1484928536.16328.127.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="GT8iw7jxKB6TPjagnGd1Lt1n0eQAcnMOp"
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:51918 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdAUMSS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 07:18:18 -0500
In-Reply-To: <1484928536.16328.127.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--GT8iw7jxKB6TPjagnGd1Lt1n0eQAcnMOp
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2017 05:08 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> Since we allocate per cpu storage, let's also use NUMA hints.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv6/seg6_hmac.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/ipv6/seg6_hmac.c b/net/ipv6/seg6_hmac.c
> index 5215e1eba01030dc9345b847eee5ac5ef3bed1b9..b274f1d95e037c93e8e0e65=
31cfc51709f71297c 100644
> --- a/net/ipv6/seg6_hmac.c
> +++ b/net/ipv6/seg6_hmac.c
> @@ -389,7 +389,8 @@ static int seg6_hmac_init_algo(void)
>  			return -ENOMEM;
> =20
>  		for_each_possible_cpu(cpu) {
> -			shash =3D kzalloc(shsize, GFP_KERNEL);
> +			shash =3D kzalloc_node(shsize, GFP_KERNEL,
> +					     cpu_to_node(cpu));
>  			if (!shash)
>  				return -ENOMEM;
>  			*per_cpu_ptr(algo->shashs, cpu) =3D shash;
>=20
>=20

Thanks

Acked-by: David Lebrun <david.lebrun@uclouvain.be>


--GT8iw7jxKB6TPjagnGd1Lt1n0eQAcnMOp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAliDUa8ACgkQjbzn67sZ6AP9hQCfcsfOyzKBqv8TW8OQLuqvT/Kh
Ct8AnimrTjs4e62/Mz6fo8bEuu+u7v7k
=LPP/
-----END PGP SIGNATURE-----

--GT8iw7jxKB6TPjagnGd1Lt1n0eQAcnMOp--
