From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] netfilter: fix unused variable warning in xt_hashlimit.c
Date: Wed, 11 Jan 2012 11:52:17 +1100
Message-ID: <20120111115217.b5db064c4bf233a4e1df42b8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__11_Jan_2012_11_52_17_+1100_B.oiuv/7=ykjb1zD"
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__11_Jan_2012_11_52_17_+1100_B.oiuv/7=ykjb1zD
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Fixes this warning when CONFIG_IP6_NF_IPTABLES is not enabled:

net/netfilter/xt_hashlimit.c: In function =E2=80=98hashlimit_init_dst=E2=80=
=99:
net/netfilter/xt_hashlimit.c:448:9: warning: unused variable =E2=80=98frag_=
off=E2=80=99 [-Wunused-variable]

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/netfilter/xt_hashlimit.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

Sorry for the wide posting, but the MAINTAINERS file is not clear about
which mailing lists are relevant.

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 8e49921..d95f9c9 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -445,7 +445,6 @@ hashlimit_init_dst(const struct xt_hashlimit_htable *hi=
nfo,
 {
 	__be16 _ports[2], *ports;
 	u8 nexthdr;
-	__be16 frag_off;
 	int poff;
=20
 	memset(dst, 0, sizeof(*dst));
@@ -466,6 +465,9 @@ hashlimit_init_dst(const struct xt_hashlimit_htable *hi=
nfo,
 		break;
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	case NFPROTO_IPV6:
+	{
+		__be16 frag_off;
+
 		if (hinfo->cfg.mode & XT_HASHLIMIT_HASH_DIP) {
 			memcpy(&dst->ip6.dst, &ipv6_hdr(skb)->daddr,
 			       sizeof(dst->ip6.dst));
@@ -485,6 +487,7 @@ hashlimit_init_dst(const struct xt_hashlimit_htable *hi=
nfo,
 		if ((int)protoff < 0)
 			return -1;
 		break;
+	}
 #endif
 	default:
 		BUG();
--=20
1.7.8.197.g73c6b

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__11_Jan_2012_11_52_17_+1100_B.oiuv/7=ykjb1zD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPDN1BAAoJEECxmPOUX5FEr0wP/3/an3mvFqpWxZe25LjlMpzT
3qjaVWOX5zmelm8IU5MUcjLFw5ofMxy6vUAH6CUFnCqy0di0fIOUnIXkGhcDuMI1
O8sXILErzoV/klu5vut6RMdtQvdKj6U2CBAvBqEcAacQ3Er2r3hUXM0D4JwXhZYq
sf5DuA7RtFCNuscLXgHJKpkEXe1WJW7bnRVOpfT6ECzu+ZreLQkoVNyAs9pWb8oK
Zl4tspaWztat74uyMhytSiTPD07tJycIEwd6Lw/214gvi86sDmXc7pzgi/wFQgSQ
ZNcG+DuDrDrSjPk2TzX9xol+J9PZoOEQCgQDVzSWcDgV6bokEe6qlv/Vts1tyGxp
6o/+Yz9MtQpqlZHDfCuofQVeayTe+t+X1MYF175B5G+vdc07itn5SFnKAuRfSB2s
u6RjGBYPm3TbwIJbijvzrhPD+oZotY+a3hTX+kWFDPZKYoLv1PTPAnc/jM3a6i+p
8THwbtnFMAmlPkI1zW1NYrHlR+UqUpm5rMck34RqM8P+ZI2s2dLgpxZnSxGd0n7v
umQPWDNyW5vcygZEZMiTb1AlKvhVy9p12YhiHikb/HdnIWUf/hlu41we4mw9HORM
qSwCwVRx2HN5+e0WDR31bxUpvjQ+U+nL8RSCwIRlhyzVB5JY+JDNCdWbvZ1xCziL
QjRWKTP9z9645O7eHyZY
=3ZMy
-----END PGP SIGNATURE-----

--Signature=_Wed__11_Jan_2012_11_52_17_+1100_B.oiuv/7=ykjb1zD--
