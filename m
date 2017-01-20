From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net] ipv6: seg6_genl_set_tunsrc() must check kmemdup()
 return value
Date: Fri, 20 Jan 2017 17:06:40 +0100
Message-ID: <58823590.5080406@uclouvain.be>
References: <1484927862.16328.123.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="rfvvE4k6C4MUlnasUehQHhKrkn4enDxKg"
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:52019 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752139AbdATQFp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:05:45 -0500
In-Reply-To: <1484927862.16328.123.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--rfvvE4k6C4MUlnasUehQHhKrkn4enDxKg
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2017 04:57 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> seg6_genl_get_tunsrc() and set_tun_src() do not handle tun_src being
> possibly NULL, so we must check kmemdup() return value and abort if
> it is NULL
>=20
> Fixes: 915d7e5e5930 ("ipv6: sr: add code base for control plane support=
 of SR-IPv6")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: David Lebrun <david.lebrun@uclouvain.be>
> ---
>  net/ipv6/seg6.c |    2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
> index b172d85c650a376f541ea05d72046c76b8404303..a855eb325b030a666fe92c5=
6a2d432c77d9dfe7a 100644
> --- a/net/ipv6/seg6.c
> +++ b/net/ipv6/seg6.c
> @@ -176,6 +176,8 @@ static int seg6_genl_set_tunsrc(struct sk_buff *skb=
, struct genl_info *info)
> =20
>  	val =3D nla_data(info->attrs[SEG6_ATTR_DST]);
>  	t_new =3D kmemdup(val, sizeof(*val), GFP_KERNEL);
> +	if (!t_new)
> +		return -ENOMEM;
> =20
>  	mutex_lock(&sdata->lock);
> =20
>=20
>=20

Thanks :)

Acked-by: David Lebrun <david.lebrun@uclouvain.be>


--rfvvE4k6C4MUlnasUehQHhKrkn4enDxKg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAliCNZQACgkQjbzn67sZ6AMkKACePWjqwwzGp+cOncZRl2e6ZDX7
jksAn1Zc9s3H/9hlg7saF4LVS8ibXUSs
=1HlL
-----END PGP SIGNATURE-----

--rfvvE4k6C4MUlnasUehQHhKrkn4enDxKg--
