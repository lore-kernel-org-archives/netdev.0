From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Tue, 14 Jul 2015 11:46:17 +1000
Message-ID: <20150714114617.1eae8765@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/PZNWV_ctqcA7iJcMtd5LVft"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:48318 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818AbbGNBqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 21:46:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/PZNWV_ctqcA7iJcMtd5LVft
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/bridge/br_mdb.c

between commit:

  f1158b74e54f ("bridge: mdb: zero out the local br_ip variable before use")

from Linus' tree and commit:

  74fe61f17e99 ("bridge: mdb: add vlan support for user entries")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/bridge/br_mdb.c
index c11cf2611db0,a8d0e93d43f2..000000000000
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@@ -348,10 -352,8 +353,10 @@@ static int br_mdb_add_group(struct net_
  	if (unlikely(!p))
  		return -ENOMEM;
  	rcu_assign_pointer(*pp, p);
 +	if (state =3D=3D MDB_TEMPORARY)
 +		mod_timer(&p->timer, now + br->multicast_membership_interval);
 =20
- 	br_mdb_notify(br->dev, port, group, RTM_NEWMDB);
+ 	br_mdb_notify(br->dev, port, group, RTM_NEWMDB, state);
  	return 0;
  }
 =20
@@@ -374,7 -376,7 +379,8 @@@ static int __br_mdb_add(struct net *net
  	if (!p || p->br !=3D br || p->state =3D=3D BR_STATE_DISABLED)
  		return -EINVAL;
 =20
 +	memset(&ip, 0, sizeof(ip));
+ 	ip.vid =3D entry->vid;
  	ip.proto =3D entry->addr.proto;
  	if (ip.proto =3D=3D htons(ETH_P_IP))
  		ip.u.ip4 =3D entry->addr.u.ip4;
@@@ -421,14 -423,21 +427,15 @@@ static int __br_mdb_del(struct net_brid
  	if (!netif_running(br->dev) || br->multicast_disabled)
  		return -EINVAL;
 =20
 +	memset(&ip, 0, sizeof(ip));
+ 	ip.vid =3D entry->vid;
  	ip.proto =3D entry->addr.proto;
 -	if (ip.proto =3D=3D htons(ETH_P_IP)) {
 -		if (timer_pending(&br->ip4_other_query.timer))
 -			return -EBUSY;
 -
 +	if (ip.proto =3D=3D htons(ETH_P_IP))
  		ip.u.ip4 =3D entry->addr.u.ip4;
  #if IS_ENABLED(CONFIG_IPV6)
 -	} else {
 -		if (timer_pending(&br->ip6_other_query.timer))
 -			return -EBUSY;
 -
 +	else
  		ip.u.ip6 =3D entry->addr.u.ip6;
  #endif
 -	}
 =20
  	spin_lock_bh(&br->multicast_lock);
  	mdb =3D mlock_dereference(br->mdb, br);

--Sig_/PZNWV_ctqcA7iJcMtd5LVft
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVpGnuAAoJEMDTa8Ir7ZwVWAEQAIdYMkivEVpPezV4HkIdorxf
U46Z63BnKX5u9yllRP7uMCvck3Mf8HJLOAy8qiCMI0Jhtf9PvytmhLOuvaBdC3dx
VDS5POu0r39RFRG7G//ywIofMuNtTQDM5DKXPNX8xQ8+YkLLzWCGm8zYXdlULMLA
fKUDv/E2SXVgHMBYQI0cf0gzE/rQrjC7TxEidjvHFs545PNhA4l8N7nUJ1Is4F6T
ekNwesF8Z9w2AN4d+dn0QxE+HZjBqIwG36mLJmgoPd/moIPf/FbLMWov78vS9QVt
Lu610K0AJ+EmUyaCyCft5Z1dxl2mortmteEyRbHzgwkUq50UD6mGm+/xKmPVKEk5
OTJk8ewJ5MeHD/VWlshEuky5YZrhFdw1tnLfYql0+9R9QbzNnOUaCgW21c/Q9LnV
RZpBNVvUQXal5CHadfTIxNA/OnCaJfNh57BjW/v9Axy4mqeaUBHnwAkuslC3oBJ8
k7q01r2ExJ3lzzVKA3+sbz2aBF9+wC5tdQQtrPL49M9mkFHGK3+tDTRodWmtDciO
FwCMZHW5VqiqjoidbhhjopnK8jChS9LSnzmssPWTWDhY7LYDrUcghtGhp+alpjF1
KKwocVR8tEb2Ltam+lL9dlehx9d4e1g5sTtl7pyT0WoyRnlTyGcG9Nvrck+1tVLJ
1yX+fWbCbo1NhulFIlKj
=vzT4
-----END PGP SIGNATURE-----

--Sig_/PZNWV_ctqcA7iJcMtd5LVft--
