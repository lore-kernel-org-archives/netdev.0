From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 5 Mar 2012 13:11:03 +1100
Message-ID: <20120305131103.71d87f250accd238b7d7630e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__5_Mar_2012_13_11_03_+1100_r.7lZImHPi7/cNDR"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:33984 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab2CECLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 21:11:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__5_Mar_2012_13_11_03_+1100_r.7lZImHPi7/cNDR
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/vmxnet3/vmxnet3_drv.c between commit efead8710aad ("vmxnet3:
Fix transport header size") from the net tree and commit 8bca5d1ebb8b
("vmxnet3: cleanup tso headers manipulation") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/vmxnet3/vmxnet3_drv.c
index 756c0f5,adf527e..0000000
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@@ -824,14 -820,17 +820,12 @@@ vmxnet3_parse_and_copy_hdr(struct sk_bu
  			ctx->eth_ip_hdr_size =3D skb_checksum_start_offset(skb);
 =20
  			if (ctx->ipv4) {
- 				struct iphdr *iph =3D (struct iphdr *)
- 						    skb_network_header(skb);
+ 				const struct iphdr *iph =3D ip_hdr(skb);
+=20
  				if (iph->protocol =3D=3D IPPROTO_TCP)
- 					ctx->l4_hdr_size =3D ((struct tcphdr *)
- 					   skb_transport_header(skb))->doff * 4;
+ 					ctx->l4_hdr_size =3D tcp_hdrlen(skb);
  				else if (iph->protocol =3D=3D IPPROTO_UDP)
- 					ctx->l4_hdr_size =3D
- 							sizeof(struct udphdr);
 -					/*
 -					 * Use tcp header size so that bytes to
 -					 * be copied are more than required by
 -					 * the device.
 -					 */
 -					ctx->l4_hdr_size =3D sizeof(struct tcphdr);
++					ctx->l4_hdr_size =3D sizeof(struct udphdr);
  				else
  					ctx->l4_hdr_size =3D 0;
  			} else {

--Signature=_Mon__5_Mar_2012_13_11_03_+1100_r.7lZImHPi7/cNDR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPVCC3AAoJEECxmPOUX5FEVTkQAIlY66e5lMPOnU/VQY5eY4E6
OwGJK99sqlS6rKHrVT0hVnZdUmUJNJqP2fDPnv5dy4A5gPK15IWTcwgoWiOcr/M9
Rxugdhs9ZBCCywh7XHNHEnKBal3OjwkwNcNsLTuikf6OFa/O7BYtV9sQdyR7sq4O
9o+SoNdzNlC7D9FkbCLOFKR+6IhttOdkye4honB/8bl8MDYRleE9Hqcg62eVoLMM
uEKYpPvLsvFHi/B5b6vgDR3ux7bpwwpVczUxdvUZogmZAvlUGw81KbwZ2rrfH3hS
1PodVyUFN1JtMxKrnlBhD9kF7f0/a6skPYd691gzFdd8rLdZ7z9s1rNEDBx1DgZy
ELA+rmg8OiYLgDFIm1Ssc6XexMWWElQ7VlZlZXk+BHm3F2AhEMgjlPhIA3rQG9vX
z1/WQpSowvoVPJ6kP3GX0hdqDyDJFaK5zKD+ZtNeq0/QoGlilF65tpw+TQKP+Bq3
awwkGcXfdDurN+QdbB8Y1kJ4c4A92ym1xE/3y766PgDCzimtUse4fwBUwHYoeoti
VKkNocWp7n7deKw+04Tczg7rpTQt2ZK/R9hJ5/ZuRxo73Vgj2hfMl4tgLiLfE3IQ
17cU0kECm0jkdE+RDn8tTl2FEIhvmDs/LjqEL2SlM0UK98W3QjroYvfF+h6tRYDf
5n8yTTpvYK4jYuRYvT28
=DItd
-----END PGP SIGNATURE-----

--Signature=_Mon__5_Mar_2012_13_11_03_+1100_r.7lZImHPi7/cNDR--
