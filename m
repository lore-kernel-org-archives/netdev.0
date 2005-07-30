From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] add new nfnetlink_log subsystem
Date: Sat, 30 Jul 2005 19:33:15 +0200
Message-ID: <20050730173315.GG6620@rama.de.gnumonks.org>
References: <20050730103005.GB6620@rama.de.gnumonks.org>
	<20050730164121.GA14794@zion.homelinux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ncX6roZrNNHXnAbh"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Sven Schuster <schuster.sven@gmx.de>
Content-Disposition: inline
In-Reply-To: <20050730164121.GA14794@zion.homelinux.com>
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


--ncX6roZrNNHXnAbh
Content-Type: multipart/mixed; boundary="fpolVoprVozDR81Y"
Content-Disposition: inline


--fpolVoprVozDR81Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Thanks for your comments, Sven.

Dave: Please apply the attached patch on top of all other patches I sent
you. It also fixes the same bug in nfnetlink_queue. Thanks!

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--fpolVoprVozDR81Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="20-proc_net_remove.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] add proc_net_remove() to nfnetlink_queue and nfnetlink_log

Also fixes a typo inside a comment.
Thanks to Sven Schuster <schuster.sven@gmx.de>

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit a04a82e4fe4be531383909217bcb2d4ad096ecda
tree 1424e9d687c2b5217d82bcf04abb97a2f8aced69
parent bd4123d85f932f9bd60da9d2ed3523dc7b792075
author laforge <laforge@netfilter.org> Sa, 30 Jul 2005 19:30:32 +0200
committer laforge <laforge@netfilter.org> Sa, 30 Jul 2005 19:30:32 +0200

 net/netfilter/nfnetlink_log.c   |    3 ++-
 net/netfilter/nfnetlink_queue.c |    1 +
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -314,7 +314,7 @@ static struct sk_buff *nfulnl_alloc_skb(
=20
 	UDEBUG("entered (%u, %u)\n", inst_size, pkt_size);
=20
-	/* alloc skb whihc should be big enough for a whole multipart
+	/* alloc skb which should be big enough for a whole multipart
 	 * message.  WARNING: has to be <=3D 128k due to slab restrictions */
=20
 	skb =3D alloc_skb(inst_size, GFP_ATOMIC);
@@ -965,6 +965,7 @@ init_or_cleanup(int init)
 cleanup:
 	nf_log_unregister_logger(&nfulnl_logger);
 #ifdef CONFIG_PROC_FS
+	remove_proc_entry("nfnetlink_log", proc_net_netfilter);
 cleanup_subsys:
 #endif
 	nfnetlink_subsys_unregister(&nfulnl_subsys);
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queu=
e.c
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1041,6 +1041,7 @@ cleanup:
 	nf_unregister_queue_handlers(nfqnl_enqueue_packet);
 	unregister_netdevice_notifier(&nfqnl_dev_notifier);
 #ifdef CONFIG_PROC_FS
+	remove_proc_entry("nfnetlink_queue", proc_net_netfilter);
 cleanup_subsys:
 #endif=09
 	nfnetlink_subsys_unregister(&nfqnl_subsys);

--fpolVoprVozDR81Y--

--ncX6roZrNNHXnAbh
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC67naXaXGVTD0i/8RAhtVAJ4m/adRzL9Hf0JewyIdbKIeC3ucDgCgo6VZ
ZvCwlfz93xRqvUSV5Yrk4d8=
=1YDf
-----END PGP SIGNATURE-----

--ncX6roZrNNHXnAbh--
