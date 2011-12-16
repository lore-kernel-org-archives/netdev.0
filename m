From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 16 Dec 2011 12:07:58 +1100
Message-ID: <20111216120758.60f967a88c934890e77fa7bd@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__16_Dec_2011_12_07_58_+1100_5hdKTycW7OZ7XfXb"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__16_Dec_2011_12_07_58_+1100_5hdKTycW7OZ7XfXb
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv6/route.c between commit bb3c36863e80 ("ipv6: Check dest prefix
length on original route not copied one in rt6_alloc_cow()") from the net
tree and commit 3830847396fa ("ipv6: Various cleanups in route.c") from
the net-next tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv6/route.c
index b582a0a,4bf362b..0000000
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@@ -727,11 -727,11 +727,11 @@@ static struct rt6_info *rt6_alloc_cow(c
  		struct neighbour *neigh;
  		int attempts =3D !in_softirq();
 =20
- 		if (!(rt->rt6i_flags&RTF_GATEWAY)) {
+ 		if (!(rt->rt6i_flags & RTF_GATEWAY)) {
 -			if (rt->rt6i_dst.plen !=3D 128 &&
 +			if (ort->rt6i_dst.plen !=3D 128 &&
  			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
  				rt->rt6i_flags |=3D RTF_ANYCAST;
- 			ipv6_addr_copy(&rt->rt6i_gateway, daddr);
+ 			rt->rt6i_gateway =3D *daddr;
  		}
 =20
  		rt->rt6i_flags |=3D RTF_CACHE;

--Signature=_Fri__16_Dec_2011_12_07_58_+1100_5hdKTycW7OZ7XfXb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJO6pnuAAoJEECxmPOUX5FEzRUQAI9QGCRHfZJxIgDwF+xCtj5+
zrUnCOKfv9FV5pZVJHsKbJ8T8DjbBz4IG1XXb6iVN7EynkRqm7xgTDc5gHG7iT6z
NZSGZKKSWoZxWPGRzIidIXxzIg+l31AIGFZNQPDjyjj8V3JcjKOhp0Zuto/kHxYt
t7kzrBpkWukwL7miMWCTER/hbO5u4gf8+eaVZRjVzGBwDVkkdBsRABoSDAaUJxBp
lOxtYNGo/vDT1Kc4sHaowo+LowBqmT0b6N2MG90uzpnFVF1UAoHZrNZvD1QUBJLw
t8+XzGM1mLuMDKzehbpXmQJzwDXRqxuCoOzhO6TMt4hAkz+AzLjOdEpbvzm1jHn4
yonQUYepB1Wr4qDJsWjth3Gs8hegAH/RUSXo1L6ecwIN8vG+Ut0sBDQLfy07DE2Z
yfR+q9i0dHEQrbAyoWYFptwWn45NfofqVcWDe7hd86Km/D3KooWlXVqg4TN+Yo4J
WSs6dHOCWr0Vg6VocVOHrNKdVHYRLDZk/kNCRn2I1QqpoW6AZwj4LjwvvTbcL1yQ
vXAasUdeDBmsJ8kW31fEc+wkamczgohCvF7cAtsN7aIdtKYiylpKH1vy8omGYNrn
DtjWTQAd9pMmcW2kDNfGF9SJxb1YduK4up1BKYwolYleT3s2ekSYFVm1qTasfjqL
n5Upm5WB9aVh9HL68FFG
=2UKO
-----END PGP SIGNATURE-----

--Signature=_Fri__16_Dec_2011_12_07_58_+1100_5hdKTycW7OZ7XfXb--
