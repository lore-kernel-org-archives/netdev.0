From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2.4] 1/2:  Rename NAT helper structures
Date: Fri, 3 Sep 2004 09:03:57 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040903070357.GR26263@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bxF9Dep5HzwGj9mC"
Cc: netdev@oss.sgi.com,
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
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--bxF9Dep5HzwGj9mC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

This is the first of a two part patch.

Part one fixes confusing naming of some NAT helper data structures
(ct_ are part of ip_conntrack, exp_ are part of ip_conntrack_expect).

This patch is required to make the second apply, which fixes NAT helper
locking.

Please apply, thanks.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/08 12:26:16+02:00 kaber@coreworks.de=20
#   [NETFILTER]: Fix confusing naming in NAT-helpers
#  =20
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
#   Signed-off-by: Harald Welte <laforge@netfilter.org>
#=20
# net/ipv4/netfilter/ip_nat_irc.c
#   2004/08/08 12:26:12+02:00 kaber@coreworks.de +9 -9
#   [NETFILTER]: Fix confusing naming in NAT-helpers
#=20
# net/ipv4/netfilter/ip_nat_ftp.c
#   2004/08/08 12:26:12+02:00 kaber@coreworks.de +12 -12
#   [NETFILTER]: Fix confusing naming in NAT-helpers
#=20
diff -Nru a/net/ipv4/netfilter/ip_nat_ftp.c b/net/ipv4/netfilter/ip_nat_ftp=
=2Ec
--- a/net/ipv4/netfilter/ip_nat_ftp.c	2004-08-08 12:49:36 +02:00
+++ b/net/ipv4/netfilter/ip_nat_ftp.c	2004-08-08 12:49:36 +02:00
@@ -166,7 +166,7 @@
     [IP_CT_FTP_EPSV] mangle_epsv_packet
 };
=20
-static int ftp_data_fixup(const struct ip_ct_ftp_expect *ct_ftp_info,
+static int ftp_data_fixup(const struct ip_ct_ftp_expect *exp_ftp_info,
 			  struct ip_conntrack *ct,
 			  struct sk_buff **pskb,
 			  enum ip_conntrack_info ctinfo,
@@ -180,13 +180,13 @@
=20
 	MUST_BE_LOCKED(&ip_ftp_lock);
 	DEBUGP("FTP_NAT: seq %u + %u in %u\n",
-	       expect->seq, ct_ftp_info->len,
+	       expect->seq, exp_ftp_info->len,
 	       ntohl(tcph->seq));
=20
 	/* Change address inside packet to match way we're mapping
 	   this connection. */
-	if (ct_ftp_info->ftptype =3D=3D IP_CT_FTP_PASV
-	    || ct_ftp_info->ftptype =3D=3D IP_CT_FTP_EPSV) {
+	if (exp_ftp_info->ftptype =3D=3D IP_CT_FTP_PASV
+	    || exp_ftp_info->ftptype =3D=3D IP_CT_FTP_EPSV) {
 		/* PASV/EPSV response: must be where client thinks server
 		   is */
 		newip =3D ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.ip;
@@ -208,7 +208,7 @@
 	newtuple.src.u.tcp.port =3D expect->tuple.src.u.tcp.port;
=20
 	/* Try to get same port: if not, try to change it. */
-	for (port =3D ct_ftp_info->port; port !=3D 0; port++) {
+	for (port =3D exp_ftp_info->port; port !=3D 0; port++) {
 		newtuple.dst.u.tcp.port =3D htons(port);
=20
 		if (ip_conntrack_change_expect(expect, &newtuple) =3D=3D 0)
@@ -217,9 +217,9 @@
 	if (port =3D=3D 0)
 		return 0;
=20
-	if (!mangle[ct_ftp_info->ftptype](pskb, newip, port,
+	if (!mangle[exp_ftp_info->ftptype](pskb, newip, port,
 					  expect->seq - ntohl(tcph->seq),
-					  ct_ftp_info->len, ct, ctinfo))
+					  exp_ftp_info->len, ct, ctinfo))
 		return 0;
=20
 	return 1;
@@ -236,12 +236,12 @@
 	struct tcphdr *tcph =3D (void *)iph + iph->ihl*4;
 	unsigned int datalen;
 	int dir;
-	struct ip_ct_ftp_expect *ct_ftp_info;
+	struct ip_ct_ftp_expect *exp_ftp_info;
=20
 	if (!exp)
 		DEBUGP("ip_nat_ftp: no exp!!");
=20
-	ct_ftp_info =3D &exp->help.exp_ftp_info;
+	exp_ftp_info =3D &exp->help.exp_ftp_info;
=20
 	/* Only mangle things once: original direction in POST_ROUTING
 	   and reply direction on PRE_ROUTING. */
@@ -259,10 +259,10 @@
 	datalen =3D (*pskb)->len - iph->ihl * 4 - tcph->doff * 4;
 	LOCK_BH(&ip_ftp_lock);
 	/* If it's in the right range... */
-	if (between(exp->seq + ct_ftp_info->len,
+	if (between(exp->seq + exp_ftp_info->len,
 		    ntohl(tcph->seq),
 		    ntohl(tcph->seq) + datalen)) {
-		if (!ftp_data_fixup(ct_ftp_info, ct, pskb, ctinfo, exp)) {
+		if (!ftp_data_fixup(exp_ftp_info, ct, pskb, ctinfo, exp)) {
 			UNLOCK_BH(&ip_ftp_lock);
 			return NF_DROP;
 		}
@@ -271,7 +271,7 @@
 		   It's a cracker being funky. */
 		if (net_ratelimit()) {
 			printk("FTP_NAT: partial packet %u/%u in %u/%u\n",
-			       exp->seq, ct_ftp_info->len,
+			       exp->seq, exp_ftp_info->len,
 			       ntohl(tcph->seq),
 			       ntohl(tcph->seq) + datalen);
 		}
diff -Nru a/net/ipv4/netfilter/ip_nat_irc.c b/net/ipv4/netfilter/ip_nat_irc=
=2Ec
--- a/net/ipv4/netfilter/ip_nat_irc.c	2004-08-08 12:49:36 +02:00
+++ b/net/ipv4/netfilter/ip_nat_irc.c	2004-08-08 12:49:36 +02:00
@@ -89,7 +89,7 @@
 	return ip_nat_setup_info(ct, &mr, hooknum);
 }
=20
-static int irc_data_fixup(const struct ip_ct_irc_expect *ct_irc_info,
+static int irc_data_fixup(const struct ip_ct_irc_expect *exp_irc_info,
 			  struct ip_conntrack *ct,
 			  struct sk_buff **pskb,
 			  enum ip_conntrack_info ctinfo,
@@ -107,7 +107,7 @@
 	MUST_BE_LOCKED(&ip_irc_lock);
=20
 	DEBUGP("IRC_NAT: info (seq %u + %u) in %u\n",
-	       expect->seq, ct_irc_info->len,
+	       expect->seq, exp_irc_info->len,
 	       ntohl(tcph->seq));
=20
 	newip =3D ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.ip;
@@ -120,7 +120,7 @@
=20
 	t =3D expect->tuple;
 	t.dst.ip =3D newip;
-	for (port =3D ct_irc_info->port; port !=3D 0; port++) {
+	for (port =3D exp_irc_info->port; port !=3D 0; port++) {
 		t.dst.u.tcp.port =3D htons(port);
 		if (ip_conntrack_change_expect(expect, &t) =3D=3D 0) {
 			DEBUGP("using port %d", port);
@@ -150,7 +150,7 @@
=20
 	return ip_nat_mangle_tcp_packet(pskb, ct, ctinfo,=20
 					expect->seq - ntohl(tcph->seq),
-					ct_irc_info->len, buffer,=20
+					exp_irc_info->len, buffer,=20
 					strlen(buffer));
 }
=20
@@ -165,12 +165,12 @@
 	struct tcphdr *tcph =3D (void *) iph + iph->ihl * 4;
 	unsigned int datalen;
 	int dir;
-	struct ip_ct_irc_expect *ct_irc_info;
+	struct ip_ct_irc_expect *exp_irc_info;
=20
 	if (!exp)
 		DEBUGP("ip_nat_irc: no exp!!");
 	=09
-	ct_irc_info =3D &exp->help.exp_irc_info;
+	exp_irc_info =3D &exp->help.exp_irc_info;
=20
 	/* Only mangle things once: original direction in POST_ROUTING
 	   and reply direction on PRE_ROUTING. */
@@ -189,10 +189,10 @@
 	datalen =3D (*pskb)->len - iph->ihl * 4 - tcph->doff * 4;
 	LOCK_BH(&ip_irc_lock);
 	/* Check wether the whole IP/address pattern is carried in the payload */
-	if (between(exp->seq + ct_irc_info->len,
+	if (between(exp->seq + exp_irc_info->len,
 		    ntohl(tcph->seq),
 		    ntohl(tcph->seq) + datalen)) {
-		if (!irc_data_fixup(ct_irc_info, ct, pskb, ctinfo, exp)) {
+		if (!irc_data_fixup(exp_irc_info, ct, pskb, ctinfo, exp)) {
 			UNLOCK_BH(&ip_irc_lock);
 			return NF_DROP;
 		}
@@ -202,7 +202,7 @@
 		if (net_ratelimit()) {
 			printk
 			    ("IRC_NAT: partial packet %u/%u in %u/%u\n",
-			     exp->seq, ct_irc_info->len,
+			     exp->seq, exp_irc_info->len,
 			     ntohl(tcph->seq),
 			     ntohl(tcph->seq) + datalen);
 		}
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--bxF9Dep5HzwGj9mC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBOBddXaXGVTD0i/8RAjD2AJ0d2eu3tiW8CgGBQmfLfMQ6fMsXjQCff2qV
iiENgsMIUj+DlK6U5GumqEc=
=F4Nx
-----END PGP SIGNATURE-----

--bxF9Dep5HzwGj9mC--
