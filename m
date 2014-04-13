From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 3.2] ipv6: don't set DST_NOCOUNT for remotely added routes
Date: Mon, 14 Apr 2014 00:02:22 +0100
Message-ID: <1397430142.10849.91.camel@deadeye.wl.decadent.org.uk>
References: <20140410.215420.576903689381200176.davem@davemloft.net>
	 <1397392513.10849.75.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5dGuN/hr2TOytUgXxc7X"
Cc: stable@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52540 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751475AbaDMXCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2014 19:02:30 -0400
In-Reply-To: <1397392513.10849.75.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5dGuN/hr2TOytUgXxc7X
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

From: Sabrina Dubroca <sd@queasysnail.net>

commit c88507fbad8055297c1d1e21e599f46960cbee39 upstream.

DST_NOCOUNT should only be used if an authorized user adds routes
locally. In case of routes which are added on behalf of router
advertisments this flag must not get used as it allows an unlimited
number of routes getting added remotely.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
[bwh: Backported to 3.2: adjust context]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This is untested, but looks almost identical to what you sent for 3.4.
Please ack/nak.

Ben.

 net/ipv6/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1250,7 +1250,7 @@ int ip6_route_add(struct fib6_config *cf
 		goto out;
 	}
=20
-	rt =3D ip6_dst_alloc(&net->ipv6.ip6_dst_ops, NULL, DST_NOCOUNT);
+	rt =3D ip6_dst_alloc(&net->ipv6.ip6_dst_ops, NULL, (cfg->fc_flags & RTF_A=
DDRCONF) ? 0 : DST_NOCOUNT);
=20
 	if (rt =3D=3D NULL) {
 		err =3D -ENOMEM;


--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-5dGuN/hr2TOytUgXxc7X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU0sXfue/yOyVhhEJAQrINg/9ErqN5H9XD91eT/iDRjG4kB3ZxwpuMZUp
DsMdzZ6NYwMzCVMJ2SKkpHu3X0lDOTSy1BGky+4qnthUbtxv/ZgjM8uUlMx/EoW9
S9kaLLZ60+VuRGgMMU0DyUEbpRJ9gpdw/r7RqCO2ylXOLorQeJCu2AnaBW2LVhma
DvCk18EqtydKrvqpLsZCneVQqSJo/pQ9ul2XLuQqdBj6hA2VErtYYAiHK9fHYkFD
ouoAAwmaoDFDAtxGAfzHq+uGvHaTszy12Z7znbo/NeyuIuSSOw/BVw+U8eEDeZJv
+AZb2sSj/2UwahbMy1/1gYZRbQpA2E8ph5Inr05D1NaRBecfnpL6X5GwUYpF75ZJ
Y4mO8gq1P7ymxcitHXJGGh/n7ZrJBE1XgL7SFgp0srQyNnrglphmjASxZqn05VSF
Iuk/IvBkVRtuYf/EZ4pB2gcfWUieWXGz+NgR4T6yl1YWvaekYu26gG7BERN0i/ho
Txc8mKg8WJyvDcM3ku8Jebhk+lu2w8GI71wJgkjovDPBH1jtOEuoAjkmdZmrJioG
3okAysPrb3jTb/KlxOBZCe2awbHUTwHZ1ap3b07y6rnrsI6lByNgWsPV2M3jtTAJ
/NtkVUC0QM7Qw/UcQn3bMp2mpyh0ktkJOX4HDS5w3S6OqSXgq2MAasTiAW7cJkiT
9hSJ/vR+xhY=
=+i+c
-----END PGP SIGNATURE-----

--=-5dGuN/hr2TOytUgXxc7X--
