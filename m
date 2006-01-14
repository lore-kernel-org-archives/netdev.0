From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] fix ip[6]t_policy compiler warnings after x_tables merge
Date: Sat, 14 Jan 2006 21:40:53 +0100
Message-ID: <20060114204052.GF6740@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="z3ND3gJe4e1E4uwh"
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


--z3ND3gJe4e1E4uwh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

Please apply, thanks.

[NETFILTER] ip[6]t_policy: Fix compilation warnings

ip[6]t_policy argument conversion slipped when merging with x_tables

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Signed-off-by: Harald Welte <laforge@netfilter.org>

--- a/net/ipv4/netfilter/ipt_policy.c	2006-01-14 16:11:52.000000000 +0100
+++ b/net/ipv4/netfilter/ipt_policy.c	2006-01-14 18:55:26.000000000 +0100
@@ -95,7 +95,10 @@
 static int match(const struct sk_buff *skb,
                  const struct net_device *in,
                  const struct net_device *out,
-                 const void *matchinfo, int offset, int *hotdrop)
+                 const void *matchinfo,
+                 int offset,
+                 unsigned int protoff,
+                 int *hotdrop)
 {
 	const struct ipt_policy_info *info =3D matchinfo;
 	int ret;
@@ -113,7 +116,7 @@
 	return ret;
 }
=20
-static int checkentry(const char *tablename, const struct ipt_ip *ip,
+static int checkentry(const char *tablename, const void *ip_void,
                       void *matchinfo, unsigned int matchsize,
                       unsigned int hook_mask)
 {
--- a/net/ipv6/netfilter/ip6t_policy.c	2006-01-14 16:11:52.000000000 +0100
+++ b/net/ipv6/netfilter/ip6t_policy.c	2006-01-14 18:52:58.000000000 +0100
@@ -118,7 +118,7 @@
 	return ret;
 }
=20
-static int checkentry(const char *tablename, const struct ip6t_ip6 *ip,
+static int checkentry(const char *tablename, const void *ip_void,
                       void *matchinfo, unsigned int matchsize,
                       unsigned int hook_mask)
 {

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--z3ND3gJe4e1E4uwh
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDyWHUXaXGVTD0i/8RAm+xAJ4pDvS5gCfZgJzhAVkCzNmywN0eowCgp/ug
jdHAeIhDNqF7L7Jsv9KXrGQ=
=5m4g
-----END PGP SIGNATURE-----

--z3ND3gJe4e1E4uwh--
