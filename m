From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Fri, 15 Feb 2013 17:56:27 +1100
Message-ID: <20130215175627.33aa3b62763438465e34d42f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__15_Feb_2013_17_56_27_+1100_bfS_WqYXhP5JfWcx"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__15_Feb_2013_17_56_27_+1100_bfS_WqYXhP5JfWcx
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
net/bridge/br_fdb.c between commit 2ba071ecb6d4 ("bridge: Add vlan to
unicast fdb entries") from the net-next tree and commit "hlist: drop the
node parameter from iterators" from the akpm tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/bridge/br_fdb.c
index 8117900,4fb0461..0000000
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@@ -263,16 -231,12 +263,15 @@@ void br_fdb_delete_by_port(struct net_b
 =20
  /* No locking or refcounting, assumes caller has rcu_read_lock */
  struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
 -					  const unsigned char *addr)
 +					  const unsigned char *addr,
 +					  __u16 vid)
  {
- 	struct hlist_node *h;
  	struct net_bridge_fdb_entry *fdb;
 =20
- 	hlist_for_each_entry_rcu(fdb, h,
 -	hlist_for_each_entry_rcu(fdb, &br->hash[br_mac_hash(addr)], hlist) {
 -		if (ether_addr_equal(fdb->addr.addr, addr)) {
++	hlist_for_each_entry_rcu(fdb,
 +				&br->hash[br_mac_hash(addr, vid)], hlist) {
 +		if (ether_addr_equal(fdb->addr.addr, addr) &&
 +		    fdb->vlan_id =3D=3D vid) {
  			if (unlikely(has_expired(br, fdb)))
  				break;
  			return fdb;
@@@ -360,30 -323,24 +358,28 @@@ int br_fdb_fillbuf(struct net_bridge *b
  }
 =20
  static struct net_bridge_fdb_entry *fdb_find(struct hlist_head *head,
 -					     const unsigned char *addr)
 +					     const unsigned char *addr,
 +					     __u16 vid)
  {
- 	struct hlist_node *h;
  	struct net_bridge_fdb_entry *fdb;
 =20
- 	hlist_for_each_entry(fdb, h, head, hlist) {
+ 	hlist_for_each_entry(fdb, head, hlist) {
 -		if (ether_addr_equal(fdb->addr.addr, addr))
 +		if (ether_addr_equal(fdb->addr.addr, addr) &&
 +		    fdb->vlan_id =3D=3D vid)
  			return fdb;
  	}
  	return NULL;
  }
 =20
  static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
 -						 const unsigned char *addr)
 +						 const unsigned char *addr,
 +						 __u16 vid)
  {
- 	struct hlist_node *h;
  	struct net_bridge_fdb_entry *fdb;
 =20
- 	hlist_for_each_entry_rcu(fdb, h, head, hlist) {
+ 	hlist_for_each_entry_rcu(fdb, head, hlist) {
 -		if (ether_addr_equal(fdb->addr.addr, addr))
 +		if (ether_addr_equal(fdb->addr.addr, addr) &&
 +		    fdb->vlan_id =3D=3D vid)
  			return fdb;
  	}
  	return NULL;

--Signature=_Fri__15_Feb_2013_17_56_27_+1100_bfS_WqYXhP5JfWcx
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRHdwbAAoJEECxmPOUX5FE4isP/Ax9eDN7klh7TAPW5AF6Y6cp
vyrTROeduAWiUZ0jfpkzA60sD6wA55zKmNnpEdZpwXxD30p/DFgHiXpFmKGcYXCK
Z631fCX5T6P9DVqkz7ooVxKjaHx4tHvW0WIWAta2ZhBuepXHY9q2YFy8zZPm1WiT
e30dT7QUioNJPAGWuFwVd1qGEJfkcCRejjcURMTzOoP1tlS/Wl4DMxyrKhbXWaAP
8OH1cECNdmRh3Q5MMaDqbn11czo+leIL/YGiYIN3ljxpGaFw98yHawib0qRdk1sX
44eHaiP3a5TjhpjUb+HY4aExnEpDE99juPnfSB+vKzq7RJ0YXU9K3Vym1ZE5uNvb
ao5RVeGYP1aIFOdRyLU3RNdS9WqPaSMdttIHm2EB8j6ZD56nNUqJYF5QQSbPpZRX
D+8ISL7YjHF8UsAiImhxr61hVb91UFl8yr4fIsyk4v8ViM8clP3T6INsEAlYdEuW
jgVYIU/QSoihZX7U87a2STbtGqLGsk6KKJHx3FTonRg/YYIBLGnSWTCn/Bci6BZ4
dIJLiZ9ICUUFUGtnj50KUsGGT7PSAGYBGatYVMobM+hIg4yR1s7d6PN7xvt+pN+6
VRzWXpUIvsVArkglWtMdN6gaKGfP46g/sdp5zqyG/rM90ys/CJW7ZlM+7XV9RQJv
lzv7u/Ag1FCyok0ue+ek
=+NGQ
-----END PGP SIGNATURE-----

--Signature=_Fri__15_Feb_2013_17_56_27_+1100_bfS_WqYXhP5JfWcx--
