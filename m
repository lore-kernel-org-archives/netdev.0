From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Thu, 14 Mar 2013 14:45:51 +0000
Message-ID: <20130314144550.GB2512@raven>
References: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
 <1362695800-8633-2-git-send-email-tparkin@katalix.com>
 <1362696444.15793.220.camel@edumazet-glaptop>
 <20130307.181527.390191009324148471.davem@davemloft.net>
 <20130313232743.GA3686@raven>
 <1363223884.29475.0.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hHWLQfXTYDoKhP50"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:35961 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756801Ab3CNOpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 10:45:54 -0400
Content-Disposition: inline
In-Reply-To: <1363223884.29475.0.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--hHWLQfXTYDoKhP50
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 14, 2013 at 02:18:04AM +0100, Eric Dumazet wrote:
> Ah thanks for this, as this definitely makes more sense ;)
>=20
> Could you try the following fix ?
>=20
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index b6d30ac..87f4ecb 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -529,6 +529,7 @@ found:
>  	    qp->q.meat =3D=3D qp->q.len)
>  		return ip_frag_reasm(qp, prev, dev);
> =20
> +	skb_dst_force(skb);
>  	inet_frag_lru_move(&qp->q);
>  	return -EINPROGRESS;
>

Thanks Eric, with this patch I can no longer reproduce the oops :-)
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--hHWLQfXTYDoKhP50
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRQeKeAAoJEJSMBmUKuovQlXsH/iT7YmScoxtbsnrcJKeoV9UE
xyr4TW0N40PJu4cZKWDab/9not2wAiLP2uR/D6plAngM/iMQ9YVKYJi/95spjYv2
A2OLrGuJTu4EwP7UH4UaGMyzUdtNf5dSaRFGFGMg4xAEc+A/U/F6u0mvrO3MkCt3
vXy59nOF9Jz4Ym2QI+HFDfgUFxiIGz1JGIrwPIoqgwvVdnCT6XRVVFGHZNFrO+2Q
rIgstht9y8Lvoz0zxxBp12ypQXwZ+8vLPH1hI9SEQg0kskJZROn5/nxJWRtkVEZE
Co8X9xlheTPqbrbMiX5/M921gou4LVwL+Pm/ONJTMEUvSEUNUVBCkLdzSGaLJ7I=
=kNiH
-----END PGP SIGNATURE-----

--hHWLQfXTYDoKhP50--
