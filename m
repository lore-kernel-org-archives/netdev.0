From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 5 Sep 2013 15:23:08 +1000
Message-ID: <20130905152308.d0a720cfb23b8b647e6558e6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__5_Sep_2013_15_23_08_+1000_HigrxOBgWcQ2gCbG"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__5_Sep_2013_15_23_08_+1000_HigrxOBgWcQ2gCbG
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv6/sit.c between commit 3d483058c8c8 ("ipv6: wire up
skb->encapsulation") from Linus' tree and commit 8b7ed2d91d6a
("iptunnels: remove net arg from iptunnel_xmit()") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv6/sit.c
index 21b25dd,19abcc9..0000000
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@@ -886,13 -881,8 +879,13 @@@ static netdev_tx_t ipip6_tunnel_xmit(st
  		ttl =3D iph6->hop_limit;
  	tos =3D INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
 =20
 +	if (likely(!skb->encapsulation)) {
 +		skb_reset_inner_headers(skb);
 +		skb->encapsulation =3D 1;
 +	}
 +
- 	err =3D iptunnel_xmit(dev_net(dev), rt, skb, fl4.saddr, fl4.daddr,
- 			    IPPROTO_IPV6, tos, ttl, df);
+ 	err =3D iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, IPPROTO_IPV6, tos,
+ 			    ttl, df, !net_eq(tunnel->net, dev_net(dev)));
  	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
  	return NETDEV_TX_OK;
 =20

--Signature=_Thu__5_Sep_2013_15_23_08_+1000_HigrxOBgWcQ2gCbG
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSKBU8AAoJEECxmPOUX5FELvkQAKBk1VIghskjnDz4tlAKIItF
xYK2PnL47WbsD+wIMzq0hROrrCcKMolCToOsdKdEHpny8C1jbymKCnJwP4IRGXyn
GmHDZmTeydKptaRUFtMQXcxHUyJpa+jp6jNfwCfa1pqOX1czLTIpoNXeq2tz4Y75
GGcbuYuYd+N+NrPXJtDh7Jx1igTPQUpYp7+QXcvv1c9M7iS+ntXMnUy4kC1PaGvF
gptvVYf/OpZmzimDiFQbpfXei3axOqqT0xwXy5XDrBEKjJSJwSLvnVOICl/9ytB2
KHI3iSY6xCtcyfkg33W8+0Ji3j2ZbU0t/Dh3iu5KF78DVUx+/1q/ESnUDWw2E30F
wVZ4kYnJtPFrrjfl6EJ3iRkfnZIZef3aJkrd4lNmfJGbzGN5/wgH19+DAfllezX3
ZHWZpMQngFJiIQvAg7i6MVhDjFeVwr3fhjUTcGmXFjamHvvBiS2hd4g+qenuV4aY
UKgdPiUINlFNmrPmMyWXDSALO5/LA8fgcjb6QBPvasqoLKkIneH8+ejY0xu+ahz9
JF2EX4RZjhboDnDE7FcnVs7JUaTCLAaJnacfX38tSgT7/wZ293heeKJqd5QOTJlj
cj/qCm+qIVbYH0WVTW4BHRS7lYxQqZKuDs8t/NO9Pco8voieCTl4LdVuzn7rytjB
XbVY5neTW90EHkgYa+p4
=1NFJ
-----END PGP SIGNATURE-----

--Signature=_Thu__5_Sep_2013_15_23_08_+1000_HigrxOBgWcQ2gCbG--
