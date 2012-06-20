From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the  tree
Date: Wed, 20 Jun 2012 13:18:54 +1000
Message-ID: <20120620131854.583604935bf9fd9f69f7ebe1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__20_Jun_2012_13_18_54_+1000_msYOeJIq6E/zySxt"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__20_Jun_2012_13_18_54_+1000_msYOeJIq6E/zySxt
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv6/route.c between commit d189634ecab9 ("ipv6: Move ipv6 proc file
registration to end of init order") from the net tree and commit
c3426b47190d ("inet: Initialize per-netns inetpeer roots in net/ipv
{4,6}/route.c") from the net-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv6/route.c
index becb048,e649cd7..0000000
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@@ -3007,11 -2929,31 +2938,36 @@@ static struct pernet_operations ip6_rou
  	.exit =3D ip6_route_net_exit,
  };
 =20
 +static struct pernet_operations ip6_route_net_late_ops =3D {
 +	.init =3D ip6_route_net_init_late,
 +	.exit =3D ip6_route_net_exit_late,
 +};
 +
+ static int __net_init ipv6_inetpeer_init(struct net *net)
+ {
+ 	struct inet_peer_base *bp =3D kmalloc(sizeof(*bp), GFP_KERNEL);
+=20
+ 	if (!bp)
+ 		return -ENOMEM;
+ 	inet_peer_base_init(bp);
+ 	net->ipv6.peers =3D bp;
+ 	return 0;
+ }
+=20
+ static void __net_exit ipv6_inetpeer_exit(struct net *net)
+ {
+ 	struct inet_peer_base *bp =3D net->ipv6.peers;
+=20
+ 	net->ipv6.peers =3D NULL;
+ 	inetpeer_invalidate_tree(bp);
+ 	kfree(bp);
+ }
+=20
+ static struct pernet_operations ipv6_inetpeer_ops =3D {
+ 	.init	=3D	ipv6_inetpeer_init,
+ 	.exit	=3D	ipv6_inetpeer_exit,
+ };
+=20
  static struct notifier_block ip6_route_dev_notifier =3D {
  	.notifier_call =3D ip6_route_dev_notify,
  	.priority =3D 0,

--Signature=_Wed__20_Jun_2012_13_18_54_+1000_msYOeJIq6E/zySxt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP4UEeAAoJEECxmPOUX5FE2P4P/jq6etcqtes7J8xS3jsk5732
BYhfN5HqgvoWRlJ+z2B6xHxrbO0XCnw5sueytgxZxcX+t0YjDMvMKQpCJlg/4Emk
mKDnh0dlayRRiR9f9DCexhuiTMPSiM1sXqcX7Yrx866GJ60WJKsWCOw1th9QWwB4
Z5mBUdbe6hGsysO+54e3wn/+TSKA5k2ec7+FyJ9Tqnum3h4G0ec8GzH8lh1ybCCQ
Ba+fTsT8BhLHLO/Z1vUMoAI1o3FiGDZUV6D+Jb+63b1f57ZxSuCF4A1AdyEYEVvs
OLGcjP8Nqil9gogfv3cVGG7Fu5eTOaD8J2vrhiahTM2ifCsgdlSkzRNS0EurOFbB
en2BG+QfS7OddXrG9T1SZy72uwlOdWaVYtoCYDaTik1mlWfmRJnkXhGfG49EkatF
qAYpbKCNrKk+wPzEtp+xRQukbmqpFs0e4IfRd20ssWl2G586bKxol2BNpFCPnUFe
R2opsVcO9IjV1Y6atP/ju4wBfjcE9s4xyOaGhwhNKNpLd0tL0PugfC7O0i2cXcCh
LKgJEagXctGnzNqzZbtR/JqlmAP4d6v+C/rOGZfJYvCX9iq0mSrcq0PoTEuFasHj
M8PV+2PVXLhSZTuZJQ+i8XWO5s1a7uTlD4C7itwurdYkO1lK6HhgkxaDIGe9xBkG
spY8uOfE/XsFPqN0lS7z
=f9tL
-----END PGP SIGNATURE-----

--Signature=_Wed__20_Jun_2012_13_18_54_+1000_msYOeJIq6E/zySxt--
