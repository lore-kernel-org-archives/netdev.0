From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the infiniband tree with the net-next
 tree
Date: Wed, 15 Jan 2014 13:46:51 +1100
Message-ID: <20140115134651.5da1a0da6a77891739562279@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__15_Jan_2014_13_46_51_+1100_8WTi_GZ9Q6haM.y6"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
To: Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__15_Jan_2014_13_46_51_+1100_8WTi_GZ9Q6haM.y6
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the infiniband tree got a conflict in
include/linux/mlx4/device.h between commit 7ffdf726cfe0 ("net/mlx4_core:
Add basic support for TCP/IP offloads under tunneling") from the net-next
tree and commits 4de658036086 ("mlx4_core: Add support for steerable IB
UD QPs") and dd5f03beb4f7 ("IB/core: Ethernet L2 attributes in verbs/cm
structures") from the infiniband tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/linux/mlx4/device.h
index c99ecf6d2c67,ac5cb1d92487..000000000000
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@@ -166,7 -161,7 +166,8 @@@ enum=20
  	MLX4_DEV_CAP_FLAG2_VLAN_CONTROL		=3D 1LL <<  6,
  	MLX4_DEV_CAP_FLAG2_FSM			=3D 1LL <<  7,
  	MLX4_DEV_CAP_FLAG2_UPDATE_QP		=3D 1LL <<  8,
- 	MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS	=3D 1LL <<  9
 -	MLX4_DEV_CAP_FLAG2_DMFS_IPOIB		=3D 1LL <<  9
++	MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS	=3D 1LL <<  9,
++	MLX4_DEV_CAP_FLAG2_DMFS_IPOIB		=3D 1LL <<  10
  };
 =20
  enum {
@@@ -1130,7 -1096,7 +1131,8 @@@ int mlx4_SET_PORT_qpn_calc(struct mlx4_
  int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc);
  int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
  		u8 *pg, u16 *ratelimit);
 +int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering);
+ int mlx4_find_cached_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *idx=
);
  int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *id=
x);
  int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *inde=
x);
  void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, u16 vlan);

--Signature=_Wed__15_Jan_2014_13_46_51_+1100_8WTi_GZ9Q6haM.y6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS1fafAAoJEMDTa8Ir7ZwVRUwP/0Nz7/5ftIorq7G9FZVDns+G
bOy5k3MJxNMSjJbNSN4DDC4PzFDWSjMXLSLUaJwzNjQ50c7QDIQbK7N4w6PZT8Mx
6RRTZJyJTYPdc7U7LHJBAN04L8WhFxUnDBxgWaYC69ktkPaK2voXfB68R6bZpsdL
qTDjCUIaSJKuyMwuneMIsrxe5/l7dNPvr5xcWqhhryYPeIPtJUSLadPAq37lcVkD
tfis0YxDqy4QmmALZmpXFz+frooyWEBLNi1JLi7nAANnHGt4zilVNIRc8Lzu3P7x
jDRknrF2xhqMNC/zCHpV1auDKrkkEQXbAfIzpD6JH4LPRqvAB4Bs555uwd3q0PIx
eGpbTGIKdfWeUhIa4/zllPYMZD0Fv/YDJhkpS+HGLAH0ulj95GCKYElzasWcHBlO
cHeiO/ulEHKYXjDiP7qJa9W3yepIcj1nSviLHWzMzzXtjTqljCStixbxP1F+FYz7
DlTAimJwEc/GYfAU3fXbbd2P+sf5XHiYdy3c9OZJOTiQcbrvqndqotN6XSZeVyXX
j3Hq6Z8Y0KQX70J8bL943WOLDPkivB9rhPpQMrAYQ2aGZ8LMPcrFllM8rcngdvV4
Lp2FpSGtFr0CKU4rMelNhgM/KgMc093uSu1eEH20u5v4dvvNeIIu/2o+MwLYvNX2
Z6B861cMMY1QBataNRXq
=sqOl
-----END PGP SIGNATURE-----

--Signature=_Wed__15_Jan_2014_13_46_51_+1100_8WTi_GZ9Q6haM.y6--
