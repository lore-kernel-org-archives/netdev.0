From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] MASQUERADE: inherit masq_index to slave connections
Date: Sat, 30 Jul 2005 15:55:12 +0200
Message-ID: <20050730135511.GE6620@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sdEQJo40s7ofW8iR"
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


--sdEQJo40s7ofW8iR
Content-Type: multipart/mixed; boundary="8jNwmpfkpox/fiJK"
Content-Disposition: inline


--8jNwmpfkpox/fiJK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

This fixes a bug with MASQUERADE and nat helpers.  The fix applies to
both net-2.6.14 and Linus' current git tree.

I'll send a 2.4.31 version of the patch directly to Marcelo (will Cc
you).

Please apply, thanks.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--8jNwmpfkpox/fiJK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="19-masq_index-inheritance.patch"

[NETFILTER] Inherit masq_index to slave connections

masq_index is used for cleanup in case the interface address changes
(such as a dialup ppp link with dynamic addreses).  Without this patch,
slave connections are not evicted in such a case, since they don't inherit
masq_index.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit bd4123d85f932f9bd60da9d2ed3523dc7b792075
tree a0218fc4d42630d33d99b4167f6dccf209cfd091
parent f00815c7d2b718eccbc3e7ec77592faff45e9ccc
author laforge <laforge@netfilter.org> Sa, 30 Jul 2005 15:35:35 +0200
committer laforge <laforge@netfilter.org> Sa, 30 Jul 2005 15:35:35 +0200

 net/ipv4/netfilter/ip_conntrack_core.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip_conntrack_core.c
--- a/net/ipv4/netfilter/ip_conntrack_core.c
+++ b/net/ipv4/netfilter/ip_conntrack_core.c
@@ -726,6 +726,11 @@ init_conntrack(struct ip_conntrack_tuple
 #if CONFIG_IP_NF_CONNTRACK_MARK
 		conntrack->mark = exp->master->mark;
 #endif
+#if defined(CONFIG_IP_NF_TARGET_MASQUERADE) || \
+    defined(CONFIG_IP_NF_TARGET_MASQUERADE_MODULE)
+		/* this is ugly, but there is no other place where to put it */
+		conntrack->nat.masq_index = exp->master->nat.masq_index;
+#endif
 		nf_conntrack_get(&conntrack->master->ct_general);
 		CONNTRACK_STAT_INC(expect_new);
 	} else {

--8jNwmpfkpox/fiJK--

--sdEQJo40s7ofW8iR
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC64a/XaXGVTD0i/8RAjdTAJsFJiUgcL12DrTQybeVvXSdGCK1ygCfd/nF
YGMRWS6mh4GI1yJp+HkBw8I=
=jlkg
-----END PGP SIGNATURE-----

--sdEQJo40s7ofW8iR--
