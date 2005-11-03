From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2/2] [NETFILTER] PPTP helper: Fix endianness bug in GRE key
	/ CallID NAT
Date: Thu, 3 Nov 2005 13:05:20 +0100
Message-ID: <20051103120520.GC4479@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="QnuZwYTmj5MY7O+D"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--QnuZwYTmj5MY7O+D
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Acme!

Please merge this to both 2.6.15 mainline and 2.6.14.x stable series,
thanks.

[NETFILTER] PPTP helper: Fix endianness bug in GRE key / CallID NAT

This endianness bug slipped through while changing the 'gre.key' field in t=
he
conntrack tuple from 32bit to 16bit.

None of my tests caught the problem, since the linux pptp client always has
'0' as call id / gre key.  Only windows clients actually trigger the bug.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 66d73ebf14b8bb18647eabca9975d7ceb787cb29
tree b92bab972b99c11ead4ca05d152ab78f741fc41f
parent f6447dcd8a4f13b144c9f49df76682c31562a003
author Harald Welte <laforge@hanuman.de.gnumonks.org> Thu, 03 Nov 2005 12:5=
5:06 +0100
committer Harald Welte <laforge@hanuman.de.gnumonks.org> Thu, 03 Nov 2005 1=
2:55:06 +0100

 net/ipv4/netfilter/ip_nat_proto_gre.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/ip_nat_proto_gre.c b/net/ipv4/netfilter/ip_=
nat_proto_gre.c
--- a/net/ipv4/netfilter/ip_nat_proto_gre.c
+++ b/net/ipv4/netfilter/ip_nat_proto_gre.c
@@ -139,8 +139,8 @@ gre_manip_pkt(struct sk_buff **pskb,
 			break;
 		case GRE_VERSION_PPTP:
 			DEBUGP("call_id -> 0x%04x\n",=20
-				ntohl(tuple->dst.u.gre.key));
-			pgreh->call_id =3D htons(ntohl(tuple->dst.u.gre.key));
+				ntohs(tuple->dst.u.gre.key));
+			pgreh->call_id =3D tuple->dst.u.gre.key;
 			break;
 		default:
 			DEBUGP("can't nat unknown GRE version\n");
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--QnuZwYTmj5MY7O+D
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDaf0AXaXGVTD0i/8RAvR/AKCPlPbhfm4aunfl7s7rK6dvt2vq/gCcCFzG
oA+7tZs/Um8djNp+Vi9gR7I=
=sky8
-----END PGP SIGNATURE-----

--QnuZwYTmj5MY7O+D--
