From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH 2/3] d80211: fix wme.c breakage
Date: Tue, 12 Dec 2006 12:53:52 -0500
Message-ID: <200612121253.57165.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4522741.1ockAJALd6";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:52346 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932307AbWLLR4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 12:56:42 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4522741.1ockAJALd6
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: fix wme.c breakage

This fixes wme.c, which was broken by a recent qdisc api change.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 net/d80211/wme.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index b9505dc..bffdce9 100644
=2D-- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -432,7 +432,8 @@ static int wme_qdiscop_init(struct Qdisc
 	/* create child queues */
 	for (i =3D 0; i < queues; i++) {
 		skb_queue_head_init(&q->requeued[i]);
=2D		q->queues[i] =3D qdisc_create_dflt(qd->dev, &CHILD_QDISC_OPS);
+		q->queues[i] =3D qdisc_create_dflt(qd->dev, &CHILD_QDISC_OPS,
+						 qd->handle);
 		if (q->queues[i] =3D=3D 0) {
 			q->queues[i] =3D &noop_qdisc;
 			printk(KERN_ERR "%s child qdisc %i creation failed", dev->name, i);
@@ -658,7 +659,7 @@ void ieee80211_install_qdisc(struct net_
 {
 	struct Qdisc *qdisc;
=20
=2D	qdisc =3D qdisc_create_dflt(dev, &wme_qdisc_ops);
+	qdisc =3D qdisc_create_dflt(dev, &wme_qdisc_ops, TC_H_ROOT);
 	if (!qdisc) {
 		printk(KERN_ERR "%s: qdisc installation failed\n", dev->name);
 		return;

--nextPart4522741.1ockAJALd6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFfuy1T3Oqt9AH4aERAvO6AJ9M1kezDJ4kMj1hdfPy671q/j/WegCaAvxV
DHytkkyztxboDjZ7X3/55QY=
=jkrH
-----END PGP SIGNATURE-----

--nextPart4522741.1ockAJALd6--
