From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 18 Feb 2014 12:52:35 +1100
Message-ID: <20140218125235.255d20c138b514902bd9fd0c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__18_Feb_2014_12_52_35_+1100_CZX=QCV6juD2VVq8"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	dingtianhong <dingtianhong@huawei.com>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__18_Feb_2014_12_52_35_+1100_CZX=QCV6juD2VVq8
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/bonding/bond_main.c between commit f80889a5b79c ("bonding:
Fix deadlock in bonding driver when using netpoll") from the net tree and
commit 90194264ceff ("bonding: Neaten pr_<level>") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/bonding/bond_main.c
index 1c6104d3501d,3bce855e627b..000000000000
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@@ -1547,13 -1544,12 +1545,13 @@@ int bond_enslave(struct net_device *bon
  		write_lock_bh(&bond->curr_slave_lock);
  		bond_select_active_slave(bond);
  		write_unlock_bh(&bond->curr_slave_lock);
 +		unblock_netpoll_tx();
  	}
 =20
- 	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
+ 	pr_info("%s: Enslaving %s as %s interface with %s link\n",
  		bond_dev->name, slave_dev->name,
- 		bond_is_active_slave(new_slave) ? "n active" : " backup",
- 		new_slave->link !=3D BOND_LINK_DOWN ? "n up" : " down");
+ 		bond_is_active_slave(new_slave) ? "an active" : "a backup",
+ 		new_slave->link !=3D BOND_LINK_DOWN ? "an up" : "a down");
 =20
  	/* enslave is successful */
  	return 0;
@@@ -2865,11 -2858,9 +2862,11 @@@ static int bond_slave_netdev_event(unsi
  			break;
  		}
 =20
- 		pr_info("%s: Primary slave changed to %s, reselecting active slave.\n",
- 			bond->dev->name, bond->primary_slave ? slave_dev->name :
- 							       "none");
+ 		pr_info("%s: Primary slave changed to %s, reselecting active slave\n",
+ 			bond->dev->name,
+ 			bond->primary_slave ? slave_dev->name : "none");
 +
 +		block_netpoll_tx();
  		write_lock_bh(&bond->curr_slave_lock);
  		bond_select_active_slave(bond);
  		write_unlock_bh(&bond->curr_slave_lock);

--Signature=_Tue__18_Feb_2014_12_52_35_+1100_CZX=QCV6juD2VVq8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTArzoAAoJEMDTa8Ir7ZwVEP8P+gLhzr8/LuMY7B8iHeBNKFsB
vIaDS0TyhZC8F4awQkHY5D9HeQaVbHZzE+1EOMS6qwp/RaDqHxd39XVjgFLp3GxZ
4kSDyxTK6iinPQbLtjWMBE0CYjLkrgvtAGnhyi1Frz8fH0gqr7NBx6aYvvotSgsX
sZIP6AY2/p7d7ZPwKzCYAX5Icdn7Y4vzJW/tmFCmXXEZoM/WKrXXkM5tI2czRFLW
s8yS4ThwrwsXIU28ImJlPuvTkMmz6X1WKmzdhMy3ER44/U77brNlLRgJqGntJz+A
LGMdlTEiEfjNIcsbgJRhBYLVsq3PsuVOnRPUq4I/xm3+cUx0Py2MjBXOFsGVrRic
6INCafXW+TsadaB8N6Pe+z4X7TCNuNWGf2nWcUbkUpN6/4Y7bO2h1weaOpZecHNB
ZhfSjdlF5NrjIOk7ESyh/OGYgzscVhPgBwkMqz50+9jEjd708hv95YoVOp5f+gYz
bDKiAdmWsXgjMS6M95uo0VWFYrMz79XuwgI8Hx8QJIJU54f7lCx2Sy1bwnxKmttP
ljUiWNpu5+qGJ1KqMfLMxsZasoQF4tDAIplpw24UIyUkFMJgR3KTkU3XOavoBuIT
EamWmdamR/R6mP/Bm4vL4G7+zxkJZ5DfOrbU9J/p+be7EPFqUiEL8P/eVaZ3GeIR
dUCRxcdkR0wdK0fdhRYF
=a1jx
-----END PGP SIGNATURE-----

--Signature=_Tue__18_Feb_2014_12_52_35_+1100_CZX=QCV6juD2VVq8--
