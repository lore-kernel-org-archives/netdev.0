From: maximilian attems <janitor@sternwelten.at>
Subject: [PATCH] list_for_each net/
Date: Wed, 3 Sep 2003 10:22:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903082202.GB13662@mail.sternwelten.at>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lEGEL1/lMxI0MVQ2"
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com,
   marcel@holtmann.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kj <kernel-janitors@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--lEGEL1/lMxI0MVQ2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

again pure cosmetical changes!!
i checked the FOR_WALKERS and it seems to work.
- for (list =3D ymf_devs.next; list !=3D &ymf_devs; list =3D list->next) {
+ list_for_each(list, &ymf_devs) {
tested, please apply

a++ maks


 bluetooth/rfcomm/core.c                  |    2 +-
 core/netfilter.c                         |    4 ++--
 ipv4/netfilter/ip_conntrack_standalone.c |    5 ++---
 ipv4/netfilter/ip_nat_standalone.c       |    2 +-
 ipv6/ip6_fib.c                           |    2 +-
 5 files changed, 7 insertions(+), 8 deletions(-)

--- linux-2.6.0-test4/net/core/netfilter.c	Sat Aug 23 01:55:34 2003
+++ linux/net/core/netfilter.c	Wed Sep  3 09:55:25 2003
@@ -101,7 +101,7 @@
 	if (down_interruptible(&nf_sockopt_mutex) !=3D 0)
 		return -EINTR;
=20
-	for (i =3D nf_sockopts.next; i !=3D &nf_sockopts; i =3D i->next) {
+	list_for_each(i, &nf_sockopts) {
 		struct nf_sockopt_ops *ops =3D (struct nf_sockopt_ops *)i;
 		if (ops->pf =3D=3D reg->pf
 		    && (overlap(ops->set_optmin, ops->set_optmax,=20
@@ -296,7 +296,7 @@
 	if (down_interruptible(&nf_sockopt_mutex) !=3D 0)
 		return -EINTR;
=20
-	for (i =3D nf_sockopts.next; i !=3D &nf_sockopts; i =3D i->next) {
+	list_for_each(i, &nf_sockopts) {
 		ops =3D (struct nf_sockopt_ops *)i;
 		if (ops->pf =3D=3D pf) {
 			if (get) {


--- linux-2.6.0-test4/net/ipv4/netfilter/ip_conntrack_standalone.c	Sat Aug =
23 01:55:11 2003
+++ linux/net/ipv4/netfilter/ip_conntrack_standalone.c	Wed Sep  3 09:56:47 =
2003
@@ -151,8 +151,7 @@
 	}
=20
 	/* Now iterate through expecteds. */
-	for (e =3D ip_conntrack_expect_list.next;=20
-	     e !=3D &ip_conntrack_expect_list; e =3D e->next) {
+	list_for_each(e, &ip_conntrack_expect_list) {
 		unsigned int last_len;
 		struct ip_conntrack_expect *expect
 			=3D (struct ip_conntrack_expect *)e;
@@ -320,7 +319,7 @@
 	struct list_head *i;
=20
 	WRITE_LOCK(&ip_conntrack_lock);
-	for (i =3D protocol_list.next; i !=3D &protocol_list; i =3D i->next) {
+	list_for_each(i, &protocol_list) {
 		if (((struct ip_conntrack_protocol *)i)->proto
 		    =3D=3D proto->proto) {
 			ret =3D -EBUSY;


--- linux-2.6.0-test4/net/ipv4/netfilter/ip_nat_standalone.c	Sat Aug 23 01:=
58:40 2003
+++ linux/net/ipv4/netfilter/ip_nat_standalone.c	Wed Sep  3 09:57:27 2003
@@ -272,7 +272,7 @@
 	struct list_head *i;
=20
 	WRITE_LOCK(&ip_nat_lock);
-	for (i =3D protos.next; i !=3D &protos; i =3D i->next) {
+	list_for_each(i, &protos) {
 		if (((struct ip_nat_protocol *)i)->protonum
 		    =3D=3D proto->protonum) {
 			ret =3D -EBUSY;


--- linux-2.6.0-test4/net/bluetooth/rfcomm/core.c	Sat Aug 23 01:50:53 2003
+++ linux/net/bluetooth/rfcomm/core.c	Wed Sep  3 09:58:11 2003
@@ -1794,7 +1794,7 @@
 	if (p->next !=3D &s->dlcs)
 		return p->next;
=20
-	for (p =3D s->list.next; p !=3D &session_list; p =3D p->next) {
+	list_for_each(p, &session_list) {
 		s =3D list_entry(p, struct rfcomm_session, list);
 		__list_for_each(pp, &s->dlcs) {
 			seq->private =3D s;


--- linux-2.6.0-test4/net/ipv6/ip6_fib.c	Sat Aug 23 01:58:45 2003
+++ linux/net/ipv6/ip6_fib.c	Wed Sep  3 10:00:51 2003
@@ -99,7 +99,7 @@
 	.next	=3D &fib6_walker_list,=20
 };
=20
-#define FOR_WALKERS(w) for ((w)=3Dfib6_walker_list.next; (w) !=3D &fib6_wa=
lker_list; (w)=3D(w)->next)
+#define FOR_WALKERS(w) list_for_each((w), &fib6_walker_list)
=20
 static __inline__ u32 fib6_new_sernum(void)
 {



--lEGEL1/lMxI0MVQ2
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD4DBQE/VaSq6//kSTNjoX0RAkY4AJiPGbnGTe4Xp+PFuPeQz9MRrw/gAJ4hZG0K
isrpztY9UWxY8oz1k3cXPQ==
=c0TI
-----END PGP SIGNATURE-----

--lEGEL1/lMxI0MVQ2--
