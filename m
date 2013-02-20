From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Wed, 20 Feb 2013 17:02:23 +1100
Message-ID: <20130220170223.806c3c5e9f240d8bacc7c940@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__20_Feb_2013_17_02_23_+1100_lbYgBziUiX8aPR9e"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__20_Feb_2013_17_02_23_+1100_lbYgBziUiX8aPR9e
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
net/core/dev.c between commit 900ff8c63214 ("net: move procfs code to
net/core/net-procfs.c") from the net-next tree and commit "hlist: drop
the node parameter from iterators" from the akpm tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index 0f6bb6f..3174f19 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -16,12 +16,11 @@ static inline struct net_device *dev_from_same_bucket(s=
truct seq_file *seq, loff
 {
 	struct net *net =3D seq_file_net(seq);
 	struct net_device *dev;
-	struct hlist_node *p;
 	struct hlist_head *h;
 	unsigned int count =3D 0, offset =3D get_offset(*pos);
=20
 	h =3D &net->dev_name_head[get_bucket(*pos)];
-	hlist_for_each_entry_rcu(dev, p, h, name_hlist) {
+	hlist_for_each_entry_rcu(dev, h, name_hlist) {
 		if (++count =3D=3D offset)
 			return dev;
 	}

--Signature=_Wed__20_Feb_2013_17_02_23_+1100_lbYgBziUiX8aPR9e
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRJGbvAAoJEECxmPOUX5FErycP+QFd4ST4vTLwJb9dWubVtIIp
ZtX8oaoCHFy+KW6c1PfJJPnRywP7qLgRKK4MIZSIx5qSbOyRq6fwLx8eVCQljwDG
yH7n/Xuy06MzotdsHUULZXEw9lZA6A2HWJ6q8RC3142QQS4VspZ+gdj54fpmmlbQ
SOSgzty1v8d296f8EG7I9KHIdHqmgGC6CCjyQcArSUSJnS8KB18ylwMHIcu4ENnW
nLjCrtQrME0uDCN8A++/A4EOO1fVFCAsuC40oj6lE4KH6pe3UaHWtHuqS1gah9Fa
/YOx0iuHf234j0GhMXP2wGcr6PSf9ibTm7PJg5hO8uST4qs9j9oUvduc8UVaMhx+
JsLW1DXMaFQ2FJwmrdCq9vUKJAhMvXG6M4MOXrLGxaYv8wCFYd0I2TWK9uIUEKZP
cFaxxJZXxKL+OyNOJOpiinLzhxV39Cm/dg1GrKu5n4QodRpkuIa5bqBqol98HStt
vznuR36TWf13Nh2MUR1lNMMZEoR54vSOUX37Tq2T5z3/mFz/fwT+eoucH+ZUTyI0
7KG6YNVEH06HEZ37g0uy0oXr3eEAnow++/CvS7pNZmwVYGhJd7kmufo10aNwgGeU
8pidjyD4YWLIZb59PEj8nxIiVE7Bd6bywry6vr4ZoBluajtyMwD+epjH+92Rq3+u
pwPws8LwMJnHRUgczMeh
=pdR/
-----END PGP SIGNATURE-----

--Signature=_Wed__20_Feb_2013_17_02_23_+1100_lbYgBziUiX8aPR9e--
