From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] nf_{log,queue}: more verbose error reporting
Date: Mon, 8 Aug 2005 19:03:05 +0200
Message-ID: <20050808170304.GJ25303@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IjNIXuzrMEaOuFwn"
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


--IjNIXuzrMEaOuFwn
Content-Type: multipart/mixed; boundary="N5iGxCIPT7YMRg16"
Content-Disposition: inline


--N5iGxCIPT7YMRg16
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

Please apply to your net-2.6.14, thanks

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--N5iGxCIPT7YMRg16
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="39-nf_log_register-EBUSY.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] more verbose return codes from nf_{log,queue}

This adds EEXIST to distinguish between the following return values:
0: 	nobody was registered, registration successful
EEXIST:	the exact same handler was already registered, no registration
	required
EBUSY:	somebody else is registered, registration unsuccessful.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 2f20e47c7aaf09749b1bb0684fbd30a1921d2de2
tree d8bf732f6a40d56f1a1e8b54a421473e2d40df98
parent 5f748d529c9bf1f0f52453d02a5e3aa9eca351e3
author Harald Welte <laforge@netfilter.org> Mo, 08 Aug 2005 18:55:39 +0200
committer Harald Welte <laforge@netfilter.org> Mo, 08 Aug 2005 18:55:39 +02=
00

 net/netfilter/nf_log.c   |    6 +++++-
 net/netfilter/nf_queue.c |    6 +++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -17,6 +17,8 @@
 static struct nf_logger *nf_logging[NPROTO]; /* =3D NULL */
 static DEFINE_SPINLOCK(nf_log_lock);
=20
+/* return EBUSY if somebody else is registered, EEXIST if the same logger
+ * is registred, 0 on success. */
 int nf_log_register(int pf, struct nf_logger *logger)
 {
 	int ret =3D -EBUSY;
@@ -27,7 +29,9 @@ int nf_log_register(int pf, struct nf_lo
 	if (!nf_logging[pf]) {
 		rcu_assign_pointer(nf_logging[pf], logger);
 		ret =3D 0;
-	}
+	} else if (nf_logging[pf] =3D=3D logger)
+		ret =3D -EEXIST;
+
 	spin_unlock(&nf_log_lock);
 	return ret;
 }	=09
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -19,6 +19,8 @@ static struct nf_queue_rerouter *queue_r
=20
 static DEFINE_RWLOCK(queue_handler_lock);
=20
+/* return EBUSY when somebody else is registered, return EEXIST if the
+ * same handler is registered, return 0 in case of success. */
 int nf_register_queue_handler(int pf, struct nf_queue_handler *qh)
 {     =20
 	int ret;
@@ -27,7 +29,9 @@ int nf_register_queue_handler(int pf, st
 		return -EINVAL;
=20
 	write_lock_bh(&queue_handler_lock);
-	if (queue_handler[pf])
+	if (queue_handler[pf] =3D=3D qh)
+		ret =3D -EEXIST;
+	else if (queue_handler[pf])
 		ret =3D -EBUSY;
 	else {
 		queue_handler[pf] =3D qh;

--N5iGxCIPT7YMRg16--

--IjNIXuzrMEaOuFwn
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC95BIXaXGVTD0i/8RAuiWAJ9PcIXT4/yRUcfXLd8AndhCQjd7ewCeNxvU
tntr2x8zW8LgX/CLXYjWWS8=
=rM/7
-----END PGP SIGNATURE-----

--IjNIXuzrMEaOuFwn--
