From: Pierre Ossman <drzeus@drzeus.cx>
Subject: net: alignment problem in icmp code
Date: Sat, 20 Oct 2007 23:35:40 +0200
Message-ID: <20071020233540.43d2f103@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=PGP-SHA1; boundary="=_hera.drzeus.cx-16700-1192916114-0001-2"
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.drzeus.cx ([85.8.24.16]:47476 "EHLO smtp.drzeus.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759AbXJUCJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2007 22:09:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_hera.drzeus.cx-16700-1192916114-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Structure assignment have to be aligned just like any assignment, and the s=
kb could point to anything. So take the safe route and use a memcpy().

Signed-off-by: Pierre Ossman <drzeus@drzeus.cx>
---

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 272c69e..a7e2ec9 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -783,7 +783,7 @@ static void icmp_echo(struct sk_buff *skb)
 	if (!sysctl_icmp_echo_ignore_all) {
 		struct icmp_bxm icmp_param;
=20
-		icmp_param.data.icmph	   =3D *icmp_hdr(skb);
+		memcpy(&icmp_param.data.icmph, icmp_hdr(skb), sizeof(struct icmphdr));
 		icmp_param.data.icmph.type =3D ICMP_ECHOREPLY;
 		icmp_param.skb		   =3D skb;
 		icmp_param.offset	   =3D 0;
@@ -819,7 +819,7 @@ static void icmp_timestamp(struct sk_buff *skb)
 	icmp_param.data.times[2] =3D icmp_param.data.times[1];
 	if (skb_copy_bits(skb, 0, &icmp_param.data.times[0], 4))
 		BUG();
-	icmp_param.data.icmph	   =3D *icmp_hdr(skb);
+	memcpy(&icmp_param.data.icmph, icmp_hdr(skb), sizeof(struct icmphdr));
 	icmp_param.data.icmph.type =3D ICMP_TIMESTAMPREPLY;
 	icmp_param.data.icmph.code =3D 0;
 	icmp_param.skb		   =3D skb;

--=_hera.drzeus.cx-16700-1192916114-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFHGnSt7b8eESbyJLgRAuNXAKCsMavy2Ic8tjTNQ4gIzCyHUqZivgCdGHWf
vvjr/8ynfQqYkymxNVCp6/k=
=i1CQ
-----END PGP SIGNATURE-----

--=_hera.drzeus.cx-16700-1192916114-0001-2--
