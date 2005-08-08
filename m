From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] nf_log: check function arguments
Date: Mon, 8 Aug 2005 19:04:31 +0200
Message-ID: <20050808170431.GK25303@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PkEWctFf+8E2rcii"
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


--PkEWctFf+8E2rcii
Content-Type: multipart/mixed; boundary="nQUlLD2FJeKEtFpv"
Content-Disposition: inline


--nQUlLD2FJeKEtFpv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

Please apply to your net-2.6.14, thanks

Ok, this will be my last patch for some time, I promise.  Guess you must
be bored by now...

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--nQUlLD2FJeKEtFpv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="40-nf_log-nproto-check.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] check nf_log function call arguments

Check whether pf is too large in order to prevent array overflow.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 041cf7f2c1158ae8e9b6d8173b77cbcc878cb54c
tree dd3f91ef47ed9867f4baaaa240161f9ee2210d3c
parent 2f20e47c7aaf09749b1bb0684fbd30a1921d2de2
author Harald Welte <laforge@netfilter.org> Mo, 08 Aug 2005 19:02:07 +0200
committer Harald Welte <laforge@netfilter.org> Mo, 08 Aug 2005 19:02:07 +02=
00

 include/linux/netfilter.h |    2 +-
 net/netfilter/nf_log.c    |   10 +++++++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -157,7 +157,7 @@ struct nf_logger {
=20
 /* Function to register/unregister log function. */
 int nf_log_register(int pf, struct nf_logger *logger);
-void nf_log_unregister_pf(int pf);
+int nf_log_unregister_pf(int pf);
 void nf_log_unregister_logger(struct nf_logger *logger);
=20
 /* Calls the registered backend logging function */
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -23,6 +23,9 @@ int nf_log_register(int pf, struct nf_lo
 {
 	int ret =3D -EBUSY;
=20
+	if (pf >=3D NPROTO)
+		return -EINVAL;
+
 	/* Any setup of logging members must be done before
 	 * substituting pointer. */
 	spin_lock(&nf_log_lock);
@@ -37,14 +40,19 @@ int nf_log_register(int pf, struct nf_lo
 }	=09
 EXPORT_SYMBOL(nf_log_register);
=20
-void nf_log_unregister_pf(int pf)
+int nf_log_unregister_pf(int pf)
 {
+	if (pf >=3D NPROTO)
+		return -EINVAL;
+
 	spin_lock(&nf_log_lock);
 	nf_logging[pf] =3D NULL;
 	spin_unlock(&nf_log_lock);
=20
 	/* Give time to concurrent readers. */
 	synchronize_net();
+
+	return 0;
 }
 EXPORT_SYMBOL(nf_log_unregister_pf);
=20

--nQUlLD2FJeKEtFpv--

--PkEWctFf+8E2rcii
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC95CeXaXGVTD0i/8RAjbDAJkBo/n+Jyd7pLUEgjK4OsjW7CBxIgCgqkZ7
dUtRSYm0m6NbjR70P7MRLeI=
=dFQn
-----END PGP SIGNATURE-----

--PkEWctFf+8E2rcii--
