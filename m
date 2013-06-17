From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 17 Jun 2013 12:38:58 +1000
Message-ID: <20130617123858.863db3849d3db0adb1a79d77@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__17_Jun_2013_12_38_58_+1000_tPAJ8whWeIG65RcK"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Beulich <JBeulich@suse.com>, Wei Liu <wei.liu2@citrix.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__17_Jun_2013_12_38_58_+1000_tPAJ8whWeIG65RcK
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/xen-netback/netback.c between commit 94f950c4060c
("xen-netback: don't de-reference vif pointer after having called
xenvif_put()") from Linus' tree and commit e1f00a69ec26 ("xen-netback:
split event channels support for Xen backend driver") from the net-next
tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/xen-netback/netback.c
index 8c20935,82576ff..0000000
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@@ -783,9 -789,8 +790,9 @@@ static void xen_netbk_rx_action(struct=20
  	}
 =20
  	list_for_each_entry_safe(vif, tmp, &notify, notify_list) {
- 		notify_remote_via_irq(vif->irq);
+ 		notify_remote_via_irq(vif->rx_irq);
  		list_del_init(&vif->notify_list);
 +		xenvif_put(vif);
  	}
 =20
  	/* More work to do? */

--Signature=_Mon__17_Jun_2013_12_38_58_+1000_tPAJ8whWeIG65RcK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRvnbHAAoJEECxmPOUX5FEqAIP/1EYub4i9bj2npHaNMz1PTzY
hiDAA+i0i9+zaKRwwpE6dDYY6eFHjWU9Ck3Sz/xgie7sGOBeWvBRzizOPt12Kno0
Uwy7fD/o0u4QTDrjKbDAE6BlcRzc9Vx08j+/QayprNm6cHupQc9PzuNLv1IoOgH0
9Buy4vlFM/WFyNPgDbwiVA25Ls5IrREDeF/rXY+YrCmnB/kY+q5a5NP3aCJXIu2x
3iU4Vop7qDl+UZVjPq5IemmIux7IjKvNeuAWRNaeunFljvR3BPthIeZKPVK9aQhM
9SZica0zVp0oqCrpTz62U9alpFJ7KRTsHZ5QuG96+UApALi63DYfhxmdUc0GhhGJ
FKm6Mq0hgkDB/JacZnDY0kiv4E368kUdKADYtrZ05iJ6GBlyDUKFsZdLiI0nLD+2
G+eIjTQmT4XhE31d2/CISeDVfI9RJqeDOjt9DTbxn352AYgT2ednymqjNJTsKk5r
BeL29nnsuj6yFAiblqCvhKRF7UwAwtrchH2QabaMovgFXTYGLJrry/0l4GgyZ7JZ
kS0RpTu0N70M/7MIjRdvMZGO7t7sCJljdHCEOKq8G6SJMAd1IcXVKxqmQ42UZi9d
jqlToHHPfAexHO0nbGZFg1Gk0DICig5WPx6sSojEqiBP+z75OC4a9atO097xd2fV
mvWn7wwTeJXyXRmKaenA
=u2Am
-----END PGP SIGNATURE-----

--Signature=_Mon__17_Jun_2013_12_38_58_+1000_tPAJ8whWeIG65RcK--
