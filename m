From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Wed, 18 Dec 2013 12:46:57 +1100
Message-ID: <20131218124657.f573d9ae178ea37fa971456d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__18_Dec_2013_12_46_57_+1100_=TZRK9paHkOF+ET8"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Anjali Singhai Jain <anjali.singhai@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35210 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875Ab3LRBrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 20:47:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__18_Dec_2013_12_46_57_+1100_=TZRK9paHkOF+ET8
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/intel/i40e/i40e_main.c between commit 3c325ced6aef
("i40e: fix null dereference") from Linus' tree and commit bc7d338fbb3f
("i40e: reinit flow for the main VSI") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/intel/i40e/i40e_main.c
index 12b0932204ba,fba0aada062a..000000000000
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@@ -354,8 -354,8 +354,10 @@@ static struct rtnl_link_stats64 *i40e_g
  	struct rtnl_link_stats64 *vsi_stats =3D i40e_get_vsi_stats_struct(vsi);
  	int i;
 =20
 +	if (!vsi->tx_rings)
 +		return stats;
+ 	if (test_bit(__I40E_DOWN, &vsi->state))
+ 		return stats;
 =20
  	rcu_read_lock();
  	for (i =3D 0; i < vsi->num_queue_pairs; i++) {

--Signature=_Wed__18_Dec_2013_12_46_57_+1100_=TZRK9paHkOF+ET8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSsP6VAAoJEMDTa8Ir7ZwVFGYP/iKa9Jk4cybLV+M1dOSPlNTm
I1VgTGMpts/EN+/I4+L1ztPdrc4BhtugPdcHRzsfIr7BJIt0E0CJfOnU8uPjU5z7
7KW0QBV6evvQN14PLpQyGaptsYLnq0zpCkkY7+Xf7zk1pgeFhdT38hHzAkDKsnAP
UaPsT5fKdLC4pZtbcHQfNTwL2xnhooN+R2dIOaNQDAsJB86V2NM6Jf+X1/iwd3gE
O4ZLeiwAY/yAOghshEDtEop7x0YXlx4BCKU76vQVov8WIxw//doGoyazlqaJzL/3
H+zeHzYy6vUT958iuug5IImke3+rIQLAwJPKVhT3asYVNLZoHjxqnORDNl4Kp4Hg
QIOz/vIayR0cz2MDGseAGN8/mcd4Z4l5ufJqeNKIw1YZzdQunJHrrwR3DLAWPRtJ
livsqcrYl15VtE5xR7JTM4/vHt/IKlkkvZUCPJ/G1hz6q8GvFyd2GTRxyJO6pROZ
eQ5cJiCq1ZmwfJrQ0g0IzjY3zagknFr6NBEh7rS3eyf5NCWYXmN5burSlY2hW3Fq
DF1q5G0uy/GZqZoWJCJipK3POEu15v8tV8RTeL50flUuNJh1JwZsXTqx62NqgwfB
FJLiKIlbLj39bq6Eo1gZ+1Aj0paT58ieSt7Mb2epRaE7fYbYqlG1dbW3KIk5ETV8
AbBFIryzQBwF5uSN7mHg
=rlje
-----END PGP SIGNATURE-----

--Signature=_Wed__18_Dec_2013_12_46_57_+1100_=TZRK9paHkOF+ET8--
