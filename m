From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 25 Jun 2012 13:38:12 +1000
Message-ID: <20120625133812.aad5804dca97e504650b7dd1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__25_Jun_2012_13_38_12_+1000_018ECF58LML2wX/1"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Antonio Quartulli <ordex@autistici.org>,
	Sven Eckelmann <sven@narfation.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__25_Jun_2012_13_38_12_+1000_018ECF58LML2wX/1
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/batman-adv/translation-table.c between commit 8b8e4bc0391f
("batman-adv: fix race condition in TT full-table replacement") from the
net tree and commit 7d211efc5087 ("batman-adv: Prefix originator
non-static functions with batadv_") from the net-next tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/batman-adv/translation-table.c
index 2ab83d7,5180d50..0000000
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@@ -141,7 -139,8 +139,7 @@@ static void tt_orig_list_entry_free_rcu
  	struct tt_orig_list_entry *orig_entry;
 =20
  	orig_entry =3D container_of(rcu, struct tt_orig_list_entry, rcu);
- 	orig_node_free_ref(orig_entry->orig_node);
 -	atomic_dec(&orig_entry->orig_node->tt_size);
+ 	batadv_orig_node_free_ref(orig_entry->orig_node);
  	kfree(orig_entry);
  }
 =20

--Signature=_Mon__25_Jun_2012_13_38_12_+1000_018ECF58LML2wX/1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP590kAAoJEECxmPOUX5FEnnYP/RfND0karGD/tYe8VLA2WkYH
9VN7PPjqQKYLJk3hT0TSGfcZwaqDYU72LXsyNIn7t5pdEjz582jLnXaw63uf8lt1
UhP1FKEjXWsMcgV3eKgdQ/LmWMlFHdHP7yYIill1kQeppsEtoxyqnKtxcUixEiPa
W9zQhRJZ69e0Fi+GUes6EX8n8Bi2rBIcY2YchXDArd2wWM6VrP3qy4qEqk9uWYdb
paOzaRnLmDW2tax4ObNnEvKrkPGr1lG851Fv8Z3llaDyZpEWMa/0amJB8OQuGauN
1AVzEw6f9S7LAvRPP8MOT/Y+qeBTjcq/0ttIZA+hdWtvtF6oEkae0fDqK34vk2dv
8jGco7yUXrqrnJaLUMrH6LdodSKU5rpcsFfxSB2eAfkPNd5s4CN8Ti/rLFRO5yvn
//kiBxW1su2scahA9/WiHxXR/aNMpOidf7e5c40qTaoY66E6P5RFH+rKOYx+WZXf
dM80uvE/kimSW9HYMrhCHkimmXC3jixRyr5tjqxoJ+Ry6crw1PQvLCH73p1d9G1E
bR7CvaqSlqOt9MLcIfkRxpaCqElpn4oFwrl26o7KkST270ebWPv1+q9Qd8NHky4p
T22TzWj4yOBtkPZ61kHpUwVmlXDIMqtjW6fuB1kt+ILzaH753GZr5DG9S2UwDuo+
a1s0M/qCiYtNKMJqLjQS
=CDXq
-----END PGP SIGNATURE-----

--Signature=_Mon__25_Jun_2012_13_38_12_+1000_018ECF58LML2wX/1--
