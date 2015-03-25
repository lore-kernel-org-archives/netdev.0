From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 25 Mar 2015 13:18:37 +1100
Message-ID: <20150325131837.358e10a2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ocDZd=87+KOUS/VKVh3Fg9s"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michal =?UTF-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/ocDZd=87+KOUS/VKVh3Fg9s
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got conflicts in
net/ipv4/tcp_ipv4.c and net/ipv6/tcp_ipv6.c between commit d0c294c53a77
("tcp: prevent fetching dst twice in early demux code") from the  tree
and commit f7e4eb03f9d9 ("inet: ip early demux should avoid request
sockets") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/tcp_ipv4.c
index f1756ee02207,4e90217003e8..000000000000
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@@ -1517,8 -1521,8 +1521,8 @@@ void tcp_v4_early_demux(struct sk_buff=20
  	if (sk) {
  		skb->sk =3D sk;
  		skb->destructor =3D sock_edemux;
- 		if (sk->sk_state !=3D TCP_TIME_WAIT) {
+ 		if (sk_fullsock(sk)) {
 -			struct dst_entry *dst =3D sk->sk_rx_dst;
 +			struct dst_entry *dst =3D READ_ONCE(sk->sk_rx_dst);
 =20
  			if (dst)
  				dst =3D dst_check(dst, 0);
diff --cc net/ipv6/tcp_ipv6.c
index b283a498f7a4,4a4e6d30c448..000000000000
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@@ -1584,8 -1544,8 +1544,8 @@@ static void tcp_v6_early_demux(struct s
  	if (sk) {
  		skb->sk =3D sk;
  		skb->destructor =3D sock_edemux;
- 		if (sk->sk_state !=3D TCP_TIME_WAIT) {
+ 		if (sk_fullsock(sk)) {
 -			struct dst_entry *dst =3D sk->sk_rx_dst;
 +			struct dst_entry *dst =3D READ_ONCE(sk->sk_rx_dst);
 =20
  			if (dst)
  				dst =3D dst_check(dst, inet6_sk(sk)->rx_dst_cookie);

--Sig_/ocDZd=87+KOUS/VKVh3Fg9s
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVEhsBAAoJEMDTa8Ir7ZwV5NgP/iSXrtfGmUs6wJSogkEQXQHe
5dkPMWJYC0y69jEcWJde+WuHTiD8a0lovflPtj3m6B03AFsEPZR5why9nO2gezow
2N2CqEGScywxaW/XCVUNjGRbINUlemhW3sPRI46u6+TYDWdvtRbiNAY98pmGyS3f
Xzk3KqrkihNm2SDqYVAPtz7JQbNNLekwDesz8EarKRz+AvO87ebdQxzxUK1cXuKk
Y+auqkXjdob9Jka/D7X+i04vFQxaY3pddxuunP+Ns+iw51vNM7/uf98QHtCS3dIV
4GEKRAT9fHFKO6lo7ih7CY2GEwd/UoLpWFmmS07AovJzF7rfYZrBXjYOM8qJOkix
MTsRjvxfq86p7IRYGcGJQsdqp6nRiJE7nD0tS6ND8fDSYp3pYAvupOkRs77TOnKw
wrqHMuU8xK9W3TYFidhBkMyJpRpqr0b5/y4f6otqejpyYYG44nKCusVdiCQPcK8h
3kt3R5pjMTPsGAIKLsKyHOtP2Ot4RBqy3KAzTc0LNvjc8iNh9Q7hSIQhDP/IhTfQ
fiSaSgzzAKVEE2txj4uMKsf6W3e1R2O6+RCulBZqnGB5YQD95jj6y68QXVnogq/g
lEEFhkgboCB55lLrV+NaVjnWL0oWZZl9l1CTEvC3CE1hwqqm9t1/PgAoyMuuX2Qe
KdPTwglehCaGzUvLjuTM
=rbGI
-----END PGP SIGNATURE-----

--Sig_/ocDZd=87+KOUS/VKVh3Fg9s--
