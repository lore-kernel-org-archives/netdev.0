From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 2 Feb 2015 13:33:54 +1100
Message-ID: <20150202133354.06329e97@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/QQRAE=g5SYDa_QeidqcBEsA"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/QQRAE=g5SYDa_QeidqcBEsA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/vxlan.c between commit 33564bbb2cf1 ("vxlan: setup the
right link netns in newlink hdlr") from the net tree and commit
ac5132d1a03f ("vxlan: Only bind to sockets with compatible flags
enabled") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/vxlan.c
index a8c755dcab14,31bac2a21ce3..000000000000
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@@ -2557,8 -2761,19 +2761,19 @@@ static int vxlan_newlink(struct net *sr
  	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
  		vxlan->flags |=3D VXLAN_F_UDP_ZERO_CSUM6_RX;
 =20
+ 	if (data[IFLA_VXLAN_REMCSUM_TX] &&
+ 	    nla_get_u8(data[IFLA_VXLAN_REMCSUM_TX]))
+ 		vxlan->flags |=3D VXLAN_F_REMCSUM_TX;
+=20
+ 	if (data[IFLA_VXLAN_REMCSUM_RX] &&
+ 	    nla_get_u8(data[IFLA_VXLAN_REMCSUM_RX]))
+ 		vxlan->flags |=3D VXLAN_F_REMCSUM_RX;
+=20
+ 	if (data[IFLA_VXLAN_GBP])
+ 		vxlan->flags |=3D VXLAN_F_GBP;
+=20
 -	if (vxlan_find_vni(net, vni, use_ipv6 ? AF_INET6 : AF_INET,
 +	if (vxlan_find_vni(src_net, vni, use_ipv6 ? AF_INET6 : AF_INET,
- 			   vxlan->dst_port)) {
+ 			   vxlan->dst_port, vxlan->flags)) {
  		pr_info("duplicate VNI %u\n", vni);
  		return -EEXIST;
  	}

--Sig_/QQRAE=g5SYDa_QeidqcBEsA
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUzuIXAAoJEMDTa8Ir7ZwVLgsP/1DLNLhHJKwsBdmtuPjnE0m9
qqAN5RLA2EMgY4NMbBl2x8IsRNlZtt2ZTvevTPT62LQpTmz9Ez1y6L9++Gs4HJBK
WR0LsneMdv05WxJoEsKMiRftwQpV1dqslYaTKXrWWmnwxpxP0KA6u760Klh2xynX
d8LzS8TYvdeqKWPj8WbjnyWj0k8z8Uu33oIuvTypUaCOp72am7LpjjlMxgNUcuGW
IF6lRffW10cQB97GkDIpDE6wpRKu9sz51kZEdWdLwiBmE5BVk8EFNpBSdh7QuW9M
wm3BIMfjnN4SgoEstNriwQq0LPY3v5WCWKpIgucDU1/wcKvFHUIsucTEaRzfEppW
WGW1rnsKaLziDsYmXiihJWuyuTF11l2A8LoelGbwRwX1JmKGBz+we5uG/GQWynZ9
cgg1polUHxpJos+/Ss+M5REQqnMeEf+kT4TTnWECjx03OPNTFxZ30DKrwX2K028w
1UFtbpRiQLPNacE2Jg+Wq56f8Nhn3t23L0VqH4HEezCONqkwOYG5GIl7pFo8CLLR
/DhESLzeOuo1uWYCKtiqTc7TFPcSB+H56mQKHN4u+vWo1xZR3+uRbKx+cCw9v/LH
6qJ5We8UM6QOlvSHTWEbZO/IJExWAQTzPwDdNraZI0NWiKP2ueKyUS/oTBpY9yvv
+oHc1SfpwNV18An2tVT/
=fBkM
-----END PGP SIGNATURE-----

--Sig_/QQRAE=g5SYDa_QeidqcBEsA--
