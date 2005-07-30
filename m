From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] MASQUERADE: inherit masq_index to slave connections
Date: Sat, 30 Jul 2005 16:00:43 +0200
Message-ID: <20050730140043.GF6620@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HL3CiL6n73+IAdG4"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Marcelo Tossati <marcelo@conectiva.com.br>
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


--HL3CiL6n73+IAdG4
Content-Type: multipart/mixed; boundary="4e5ZDkbgLEOfWmLx"
Content-Disposition: inline


--4e5ZDkbgLEOfWmLx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Marcelo!

Pleae apply the following trivial fix to your 2.4.x tree.  I've already
submitted a 2.6.x fix for this to davem.

Thanks!

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--4e5ZDkbgLEOfWmLx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="19-masq_index-inheritance.patch"

[NETFILTER] Inherit masq_index to slave connections

masq_index is used for cleanup in case the interface address changes
(such as a dialup ppp link with dynamic addreses).  Without this patch,
slave connections are not evicted in such a case, since they don't inherit
masq_index.

Signed-off-by: Harald Welte <laforge@netfilter.org>

Index: linux-2.4.31/net/ipv4/netfilter/ip_conntrack_core.c
===================================================================
--- linux-2.4.31.orig/net/ipv4/netfilter/ip_conntrack_core.c	2005-04-04 03:42:20.000000000 +0200
+++ linux-2.4.31/net/ipv4/netfilter/ip_conntrack_core.c	2005-07-30 15:59:41.000000000 +0200
@@ -741,6 +741,11 @@
 		/* Welcome, Mr. Bond.  We've been expecting you... */
 		__set_bit(IPS_EXPECTED_BIT, &conntrack->status);
 		conntrack->master = expected;
+#if defined(CONFIG_IP_NF_TARGET_MASQUERADE) || \
+    defined(CONFIG_IP_NF_TARGET_MASQUERADE_MODULE)
+		/* this is ugly, but there is no other place where to put it */
+		conntrack->nat.masq_index = expected->expectant->nat.masq_index;
+#endif
 		expected->sibling = conntrack;
 		LIST_DELETE(&ip_conntrack_expect_list, expected);
 		expected->expectant->expecting--;

--4e5ZDkbgLEOfWmLx--

--HL3CiL6n73+IAdG4
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC64gKXaXGVTD0i/8RAj9tAJ0UUWe5ztFMTt2VnJzXGyTBGiKC/gCghCeo
hpC1MaDBTgU7lO/64io56p0=
=20ro
-----END PGP SIGNATURE-----

--HL3CiL6n73+IAdG4--
