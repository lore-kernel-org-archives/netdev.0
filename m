From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 1/2] [NETFILTER] PPTP helper: Fix compilation of
	conntrack helper without NAT
Date: Thu, 3 Nov 2005 14:27:07 +0100
Message-ID: <20051103132707.GK4479@sunbeam.de.gnumonks.org>
References: <20051103120404.GB4479@sunbeam.de.gnumonks.org>
	<20051103131917.GJ4479@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hQksn6klg06e4Mnq"
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline
In-Reply-To: <20051103131917.GJ4479@sunbeam.de.gnumonks.org>
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


--hQksn6klg06e4Mnq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Ok, here goes the real fix for [1/2]:


[NETFILTER] PPTP helper: Fix compilation of conntrack helper without NAT

This patch fixes compilation of the PPTP conntrack helper when NAT is
configured off.

Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit f6447dcd8a4f13b144c9f49df76682c31562a003
tree e5f7c3a472ba896ee793727fbe4de02f42047d75
parent 928f936ad8e099bd2a84d6e875e1a8c59f55bf7d
author Harald Welte <laforge@hanuman.de.gnumonks.org> Thu, 03 Nov 2005 10:5=
6:16 +0100
committer Harald Welte <laforge@hanuman.de.gnumonks.org> Thu, 03 Nov 2005 1=
0:56:16 +0100

 net/ipv4/netfilter/ip_conntrack_helper_pptp.c |    4 ----
 net/ipv4/netfilter/ip_nat_helper_pptp.c       |    2 ++
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_helper_pptp.c b/net/ipv4/netfi=
lter/ip_conntrack_helper_pptp.c
--- a/net/ipv4/netfilter/ip_conntrack_helper_pptp.c
+++ b/net/ipv4/netfilter/ip_conntrack_helper_pptp.c
@@ -270,14 +270,10 @@ exp_gre(struct ip_conntrack *master,
 	exp_orig->expectfn =3D pptp_expectfn;
 	exp_orig->flags =3D 0;
=20
-	exp_orig->dir =3D IP_CT_DIR_ORIGINAL;
-
 	/* both expectations are identical apart from tuple */
 	memcpy(exp_reply, exp_orig, sizeof(*exp_reply));
 	memcpy(&exp_reply->tuple, &exp_tuples[1], sizeof(exp_reply->tuple));
=20
-	exp_reply->dir =3D !exp_orig->dir;
-
 	if (ip_nat_pptp_hook_exp_gre)
 		ret =3D ip_nat_pptp_hook_exp_gre(exp_orig, exp_reply);
 	else {
diff --git a/net/ipv4/netfilter/ip_nat_helper_pptp.c b/net/ipv4/netfilter/i=
p_nat_helper_pptp.c
--- a/net/ipv4/netfilter/ip_nat_helper_pptp.c
+++ b/net/ipv4/netfilter/ip_nat_helper_pptp.c
@@ -216,6 +216,7 @@ pptp_exp_gre(struct ip_conntrack_expect=20
 	expect_orig->saved_proto.gre.key =3D htons(nat_pptp_info->pac_call_id);
 	expect_orig->tuple.src.u.gre.key =3D htons(nat_pptp_info->pns_call_id);
 	expect_orig->tuple.dst.u.gre.key =3D htons(ct_pptp_info->pac_call_id);
+	expect_orig->dir =3D IP_CT_DIR_ORIGINAL;
 	inv_t.src.ip =3D reply_t->src.ip;
 	inv_t.dst.ip =3D reply_t->dst.ip;
 	inv_t.src.u.gre.key =3D htons(nat_pptp_info->pac_call_id);
@@ -233,6 +234,7 @@ pptp_exp_gre(struct ip_conntrack_expect=20
 	expect_reply->saved_proto.gre.key =3D htons(nat_pptp_info->pns_call_id);
 	expect_reply->tuple.src.u.gre.key =3D htons(nat_pptp_info->pac_call_id);
 	expect_reply->tuple.dst.u.gre.key =3D htons(ct_pptp_info->pns_call_id);
+	expect_reply->dir =3D IP_CT_DIR_REPLY;
 	inv_t.src.ip =3D orig_t->src.ip;
 	inv_t.dst.ip =3D orig_t->dst.ip;
 	inv_t.src.u.gre.key =3D htons(nat_pptp_info->pns_call_id);
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--hQksn6klg06e4Mnq
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDahArXaXGVTD0i/8RAtIWAJ4zWv4cZAjs/7+H2MAGcFuv2NRqfQCglnk7
c+tE77GFGUsj6FkH8PAVGU0=
=OgzA
-----END PGP SIGNATURE-----

--hQksn6klg06e4Mnq--
