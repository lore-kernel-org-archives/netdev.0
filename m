From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 31 Oct 2013 15:19:12 +1100
Message-ID: <20131031151912.3802d9b50ac5a3a09a69e63d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__31_Oct_2013_15_19_12_+1100_dvadapgdUST=sYt6"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__31_Oct_2013_15_19_12_+1100_dvadapgdUST=sYt6
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/bridge/br_private.h between commit 06499098a02b ("bridge: pass
correct vlan id to multicast code") from the net tree and commit
348662a1429f ("net: 8021q/bluetooth/bridge/can/ceph: Remove extern from
function prototypes") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/bridge/br_private.h
index 2e8244efb262,d1ca6d956633..000000000000
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@@ -449,44 -434,40 +434,40 @@@ int br_ioctl_deviceless_stub(struct ne
  /* br_multicast.c */
  #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
  extern unsigned int br_mdb_rehash_seq;
- extern int br_multicast_rcv(struct net_bridge *br,
- 			    struct net_bridge_port *port,
- 			    struct sk_buff *skb,
- 			    u16 vid);
- extern struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
- 					       struct sk_buff *skb, u16 vid);
- extern void br_multicast_add_port(struct net_bridge_port *port);
- extern void br_multicast_del_port(struct net_bridge_port *port);
- extern void br_multicast_enable_port(struct net_bridge_port *port);
- extern void br_multicast_disable_port(struct net_bridge_port *port);
- extern void br_multicast_init(struct net_bridge *br);
- extern void br_multicast_open(struct net_bridge *br);
- extern void br_multicast_stop(struct net_bridge *br);
- extern void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
- 				 struct sk_buff *skb);
- extern void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
- 				 struct sk_buff *skb, struct sk_buff *skb2);
- extern int br_multicast_set_router(struct net_bridge *br, unsigned long v=
al);
- extern int br_multicast_set_port_router(struct net_bridge_port *p,
- 					unsigned long val);
- extern int br_multicast_toggle(struct net_bridge *br, unsigned long val);
- extern int br_multicast_set_querier(struct net_bridge *br, unsigned long =
val);
- extern int br_multicast_set_hash_max(struct net_bridge *br, unsigned long=
 val);
- extern struct net_bridge_mdb_entry *br_mdb_ip_get(
- 				struct net_bridge_mdb_htable *mdb,
- 				struct br_ip *dst);
- extern struct net_bridge_mdb_entry *br_multicast_new_group(struct net_bri=
dge *br,
- 				struct net_bridge_port *port, struct br_ip *group);
- extern void br_multicast_free_pg(struct rcu_head *head);
- extern struct net_bridge_port_group *br_multicast_new_port_group(
- 				struct net_bridge_port *port,
- 				struct br_ip *group,
- 				struct net_bridge_port_group __rcu *next,
- 				unsigned char state);
- extern void br_mdb_init(void);
- extern void br_mdb_uninit(void);
- extern void br_mdb_notify(struct net_device *dev, struct net_bridge_port =
*port,
- 			  struct br_ip *group, int type);
+ int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 -		     struct sk_buff *skb);
++		     struct sk_buff *skb, u16 vid);
+ struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
+ 					struct sk_buff *skb, u16 vid);
+ void br_multicast_add_port(struct net_bridge_port *port);
+ void br_multicast_del_port(struct net_bridge_port *port);
+ void br_multicast_enable_port(struct net_bridge_port *port);
+ void br_multicast_disable_port(struct net_bridge_port *port);
+ void br_multicast_init(struct net_bridge *br);
+ void br_multicast_open(struct net_bridge *br);
+ void br_multicast_stop(struct net_bridge *br);
+ void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
+ 			  struct sk_buff *skb);
+ void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
+ 			  struct sk_buff *skb, struct sk_buff *skb2);
+ int br_multicast_set_router(struct net_bridge *br, unsigned long val);
+ int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long=
 val);
+ int br_multicast_toggle(struct net_bridge *br, unsigned long val);
+ int br_multicast_set_querier(struct net_bridge *br, unsigned long val);
+ int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val);
+ struct net_bridge_mdb_entry *
+ br_mdb_ip_get(struct net_bridge_mdb_htable *mdb, struct br_ip *dst);
+ struct net_bridge_mdb_entry *
+ br_multicast_new_group(struct net_bridge *br, struct net_bridge_port *por=
t,
+ 		       struct br_ip *group);
+ void br_multicast_free_pg(struct rcu_head *head);
+ struct net_bridge_port_group *
+ br_multicast_new_port_group(struct net_bridge_port *port, struct br_ip *g=
roup,
+ 			    struct net_bridge_port_group __rcu *next,
+ 			    unsigned char state);
+ void br_mdb_init(void);
+ void br_mdb_uninit(void);
+ void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
+ 		   struct br_ip *group, int type);
 =20
  #define mlock_dereference(X, br) \
  	rcu_dereference_protected(X, lockdep_is_held(&br->multicast_lock))

--Signature=_Thu__31_Oct_2013_15_19_12_+1100_dvadapgdUST=sYt6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJScdpFAAoJEMDTa8Ir7ZwVT1YP/3FAuPmTjeGTqsR9n0h9raZk
sNRYruI7i4RH2+pGR0VdOsFF0n1XsYEEd2ulb+a4sPgrjh1zv1z/ca+wTHuGnqPP
ZlHwVO/1fMWlBPpUoBsMB68YkR3lFkz6dw4WCPBvx3al7/WkYX4t/ZEndl16Gkbd
JPY6QJc1kgxEW+9BWCyfgOE7B/Nov5qGQ8GQK2u68wRj63ajQEUlnD/40vDtqLs/
JmfbY+ngpBM+4EALdBEtxh7I+W8zERjPwOLtNmDYzc1tomVIqyBL1x8zW58y8JMs
IKC4GVksiAJmG5Xf8hoFLJnD3Ukg3dpvpi69OvtCIQ4KtVjK5TZ+/fiLBaJ7q72q
6bm3WM/nGpNcRgvZQC2ScoZESSrq1q9bqEqZh3yIYhI3dckCH+r1LvMXQ1H9OhHO
w8y/szRG6cgperb1G/2jvXrnFRyANTgc9yZAaFk/AVpiBxRoHbYYWNcCq0b/sH/e
vXSvJysB6QmQXm7VzTrjzdHjrZVWMOEyh4ETegubpexmPxMfBzcz6S9ptDcKcCte
EjjafvBruDF1lOP5AhLAhNapCzGPzixRfXUnDFdiSqs3+7/S6lbI9TOIh7CWyDfD
jS8UJimEuO+cMbSt5y8UqV/XB7Yg2I7IXvJzzSf9c4LtYfkL9aTwuZSIyOQRx0op
wp1fjXQZDu8RrkZihZno
=SBGw
-----END PGP SIGNATURE-----

--Signature=_Thu__31_Oct_2013_15_19_12_+1100_dvadapgdUST=sYt6--
