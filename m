From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 2 Mar 2015 11:31:40 +1100
Message-ID: <20150302113140.084ba95a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/luId0BZkcXy.hWZJELPAgJS"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Scott Feldman <sfeldma@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/luId0BZkcXy.hWZJELPAgJS
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/rocker/rocker.c between commit 5f2ebfbee688
("rocker: silence shift wrapping warning") from the net tree and commit
4a6bb6d35980 ("rocker: rename lport to pport") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/rocker/rocker.c
index 9fb6948e14c6,e5a15a4c4e8f..000000000000
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@@ -1257,9 -1280,9 +1280,9 @@@ static void rocker_port_set_enable(stru
  	u64 val =3D rocker_read64(rocker_port->rocker, PORT_PHYS_ENABLE);
 =20
  	if (enable)
- 		val |=3D 1ULL << rocker_port->lport;
 -		val |=3D 1 << rocker_port->pport;
++		val |=3D 1ULL << rocker_port->pport;
  	else
- 		val &=3D ~(1ULL << rocker_port->lport);
 -		val &=3D ~(1 << rocker_port->pport);
++		val &=3D ~(1ULL << rocker_port->pport);
  	rocker_write64(rocker_port->rocker, PORT_PHYS_ENABLE, val);
  }
 =20

--Sig_/luId0BZkcXy.hWZJELPAgJS
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU869xAAoJEMDTa8Ir7ZwV1+EP/1swmNBJ7hytq2WvjHHYMUIC
9aKA0nmDJKN/2JajYS5HEnzOcfWoeeIgPSTua9Pr+jt2uxhy85ZWH2g2n6UaZ/SB
udgxt14rkINR/gGFIyZlk2fx4/Hem2ff+MTm5UMI9WU7mBD6kO/xK4ZQ95ilnVLN
wTlNExWZb7rfoz0E7+Fd3Mr0wSO6Tg+ibcwgFretauFFOkzGqN5mjb52Qwz2Zdyn
nwLwJf9jXvHBbprGEH+pbblapioTNZJ4xk/hGUvMK54zFvM0Ak2skrdTzycH0WoS
PEq1i+PoWSnCGPMk0saZftcBGz6V3QnJZvNX+YTiRzc3+RaTJH0sHvLUY5rwdHSI
Gc5iTkf1S9YNB3Ba/n3Advla/qanUst5dYbyeOy2wP0sGkWMvXcszytC3l1Yacqq
/HGUrsAUhCkv5K5AGO5sVearIqXN2IsNw4svDmGR/sEVoXyYZba2Q9CfIPgDFR/6
DHQKchc0bATiIFP6MA5ALTMeYrQpaRyus+PTCTrOiAO2OtwKzRcSf8zPa8LDXY1r
ofq5iYFTdhS2XDPG0F+p8ZfeAMch3exHgxNpYUujn9WbGjaEcjZ+uwdaIvy9bphm
Q+fSs0U63i4chivdBJ0D8RPe4tGhHnRIe3kc5BfGwQ2wBqYdMPB7BuUi0N7hVpbZ
lZp0G3AmyJWu31IHiAbT
=l8Ra
-----END PGP SIGNATURE-----

--Sig_/luId0BZkcXy.hWZJELPAgJS--
