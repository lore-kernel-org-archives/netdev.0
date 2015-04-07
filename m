From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 7 Apr 2015 13:21:36 +1000
Message-ID: <20150407132136.23da9e91@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/vRGsqPvmxOkKfLoXK7mS_Hk"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	WANG Cong <xiyou.wangcong@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/vRGsqPvmxOkKfLoXK7mS_Hk
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/core/fib_rules.c between commit 419df12fb5fa ("net: move
fib_rules_unregister() under rtnl lock") from the net tree and commit
efd7ef1c1929 ("net: Kill hold_net release_net") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/core/fib_rules.c
index e4fdc9dfb2c7,68ea6950cad1..000000000000
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@@ -175,10 -165,10 +165,10 @@@ void fib_rules_unregister(struct fib_ru
 =20
  	spin_lock(&net->rules_mod_lock);
  	list_del_rcu(&ops->list);
 -	fib_rules_cleanup_ops(ops);
  	spin_unlock(&net->rules_mod_lock);
 =20
 +	fib_rules_cleanup_ops(ops);
- 	call_rcu(&ops->rcu, fib_rules_put_rcu);
+ 	kfree_rcu(ops, rcu);
  }
  EXPORT_SYMBOL_GPL(fib_rules_unregister);
 =20

--Sig_/vRGsqPvmxOkKfLoXK7mS_Hk
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVI01DAAoJEMDTa8Ir7ZwVV/oP/3nanMZHx1GM0zLDfg5VCYx8
AN43yWAbOp9nGxJxHXtEfqQONsiUGp9MWidBovG22xM+lBOa/LYneaaHf7hIQgUm
gqLz0bwlOyssEu9hQXFKQimF1VpxfAWfYYNW1aCPWkMsSIU+1YV7/siGXfhQySHN
vQjn5s/ipZ0xgcgBwWVG1W3lFBfnFiEXfWsa3dD9fTkvHZIy4ZSyQChFSk1HlJdS
cv5OKIBJ6LuZUDOkMyf06JzHJEIKSp2UKEQQoWve+Yr90gpYXlGJvbPznajdNxXx
USHJo/XawIhX7/aV9pbqyxhmqK3VudISe4I3hqLDZiSOesfSTXRxXvGRpQH/ATzA
KRXegkJEXjiAsrZn1+tTBa18lgA06eSrugJIQpP/qQaKeMEjdNjgGlYJt1xIC1yh
EIOJgq4c1CUQ7xpBvMbUFsnCtXJW9yRffmeIEYHAIJo0clkBT/bISsXSRg5eVzrj
yL1N/eT51SBPDLDVr2+tJUxfrUmUOsuR++aTR/t7ZFrKjWQNSZ+oLvdqn43Imz2I
dbww94qPg2qztTlZe++nv6uKOSJXwQeXWV8hTW1ZvRXH3ZcfGMVorK0pPMon0E8m
YfusOKMOJkQiHocWjoYw8A/Ci83p69ip8lQZ4TGBGHXdewu9fGkrL4kRXOduHCeM
s51qpKeHaH3G0jm9+YPe
=thRv
-----END PGP SIGNATURE-----

--Sig_/vRGsqPvmxOkKfLoXK7mS_Hk--
