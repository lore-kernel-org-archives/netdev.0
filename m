From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] ctnetlink: fix conntrack expect refcount leak
Date: Fri, 5 Aug 2005 18:28:20 +0200
Message-ID: <20050805162820.GE4033@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CGDBiGfvSTbxKZlW"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
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


--CGDBiGfvSTbxKZlW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please apply.

[NETFILTER] fix conntrack refcount leak in unlink_expect()

In unlink_expect(), the expectation is removed from the list so the
refcount must be dropped as well.

Signed-off-by: Pablo Neira Ayuso <pablo@eurodev.net>
Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit ed8612c164a21e71cf6139c4e67a98b7a417b1cb
tree 4d4493874742690f9d997c4846a7e4b6becf3da2
parent 1d35273dd7935f4b6a64f3526d85c5df9ba254de
author Harald Welte <laforge@netfilter.org> Fr, 05 Aug 2005 15:19:35 +0200
committer Harald Welte <laforge@netfilter.org> Fr, 05 Aug 2005 15:19:35 +02=
00

 net/ipv4/netfilter/ip_conntrack_core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip=
_conntrack_core.c
--- a/net/ipv4/netfilter/ip_conntrack_core.c
+++ b/net/ipv4/netfilter/ip_conntrack_core.c
@@ -204,6 +204,7 @@ static void unlink_expect(struct ip_conn
 	list_del(&exp->list);
 	CONNTRACK_STAT_INC(expect_delete);
 	exp->master->expecting--;
+	ip_conntrack_expect_put(exp);
 }
=20
 void __ip_ct_expect_unlink_destroy(struct ip_conntrack_expect *exp)
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--CGDBiGfvSTbxKZlW
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC85OjXaXGVTD0i/8RAr3yAJ9uP+zUBRClqvuqlkWZo5sk57T2oQCfbdxl
Dqbcoug13v3RvD+HV1traJc=
=sC/u
-----END PGP SIGNATURE-----

--CGDBiGfvSTbxKZlW--
