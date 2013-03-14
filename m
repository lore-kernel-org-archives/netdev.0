From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Thu, 14 Mar 2013 16:14:37 +0000
Message-ID: <20130314161436.GC2512@raven>
References: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
 <1362695800-8633-2-git-send-email-tparkin@katalix.com>
 <1362696444.15793.220.camel@edumazet-glaptop>
 <20130307.181527.390191009324148471.davem@davemloft.net>
 <20130313232743.GA3686@raven>
 <1363223884.29475.0.camel@edumazet-glaptop>
 <20130314144550.GB2512@raven>
 <1363273531.29475.21.camel@edumazet-glaptop>
 <1363274946.29475.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZmUaFz6apKcXQszQ"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:35967 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755850Ab3CNQOk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 12:14:40 -0400
Content-Disposition: inline
In-Reply-To: <1363274946.29475.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZmUaFz6apKcXQszQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 14, 2013 at 04:29:06PM +0100, Eric Dumazet wrote:
> OK, I tested the following one instead, please test it so that I can send=
 an official patch.
>=20
> Thanks
>=20
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index b6d30ac..2d23830 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -529,6 +529,7 @@ found:
>  	    qp->q.meat =3D=3D qp->q.len)
>  		return ip_frag_reasm(qp, prev, dev);
> =20
> +	skb_dst_drop(skb);
>  	inet_frag_lru_move(&qp->q);
>  	return -EINPROGRESS;
>

Thanks again, Eric.

Sadly, with this patch the oops is back :-(  It falls over quite
quickly for me.
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--ZmUaFz6apKcXQszQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRQfdsAAoJEJSMBmUKuovQ2n4H/AkzgYGXFvSHRcUdsgvwEk4I
vfZaouFKScJftRx64NOollRtou90BhTusZNEFR1VMZdjw7SwfSN0pL1OuXFpCSif
86RgXuweHfsq1+onm5oQWpFxPUSpteLFk+MkM2SMn1FkLxeE5uo1zQb2enozBvji
QcUJcpNSZHHQu6RGWlo9WIA6zEQddtnatnj6ZEOXeCKj0g+wt7Nu4CXezvC9Kmgg
fW5rMBV2d2KwaD/rgDUORlxN1WjRIBQO3gASGZsknlM+yUQn4L3uEi9rw0ALGTwI
gAmGSvGdeXJh+T8eVR9g6rAkNqaQ2LumA08ZpLWKmiy0QFLCPHI+LK6WqF0BEm0=
=AELb
-----END PGP SIGNATURE-----

--ZmUaFz6apKcXQszQ--
