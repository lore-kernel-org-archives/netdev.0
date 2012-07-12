From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the infiniband
 tree
Date: Thu, 12 Jul 2012 12:13:07 +1000
Message-ID: <20120712121307.a482863a98848e3813690ef2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__12_Jul_2012_12_13_07_+1000_tEWlQid_UR9sKBNS"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__12_Jul_2012_12_13_07_+1000_tEWlQid_UR9sKBNS
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
include/linux/mlx4/device.h between commit 396f2feb05d7 ("mlx4_core:
Implement mechanism for reserved Q_Keys") from the infiniband tree and
commit 0ff1fb654bec ("{NET, IB}/mlx4: Add device managed flow steering
firmware API") from the net-next tree.

Just context changes.  I fixed it up (see below) and can carry the fix
as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/linux/mlx4/device.h
index 441caf1,6f0d133..0000000
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@@ -540,83 -542,10 +573,85 @@@ struct mlx4_dev=20
  	u8			rev_id;
  	char			board_id[MLX4_BOARD_ID_LEN];
  	int			num_vfs;
+ 	u64			regid_promisc_array[MLX4_MAX_PORTS + 1];
+ 	u64			regid_allmulti_array[MLX4_MAX_PORTS + 1];
  };
 =20
 +struct mlx4_eqe {
 +	u8			reserved1;
 +	u8			type;
 +	u8			reserved2;
 +	u8			subtype;
 +	union {
 +		u32		raw[6];
 +		struct {
 +			__be32	cqn;
 +		} __packed comp;
 +		struct {
 +			u16	reserved1;
 +			__be16	token;
 +			u32	reserved2;
 +			u8	reserved3[3];
 +			u8	status;
 +			__be64	out_param;
 +		} __packed cmd;
 +		struct {
 +			__be32	qpn;
 +		} __packed qp;
 +		struct {
 +			__be32	srqn;
 +		} __packed srq;
 +		struct {
 +			__be32	cqn;
 +			u32	reserved1;
 +			u8	reserved2[3];
 +			u8	syndrome;
 +		} __packed cq_err;
 +		struct {
 +			u32	reserved1[2];
 +			__be32	port;
 +		} __packed port_change;
 +		struct {
 +			#define COMM_CHANNEL_BIT_ARRAY_SIZE	4
 +			u32 reserved;
 +			u32 bit_vec[COMM_CHANNEL_BIT_ARRAY_SIZE];
 +		} __packed comm_channel_arm;
 +		struct {
 +			u8	port;
 +			u8	reserved[3];
 +			__be64	mac;
 +		} __packed mac_update;
 +		struct {
 +			__be32	slave_id;
 +		} __packed flr_event;
 +		struct {
 +			__be16  current_temperature;
 +			__be16  warning_threshold;
 +		} __packed warming;
 +		struct {
 +			u8 reserved[3];
 +			u8 port;
 +			union {
 +				struct {
 +					__be16 mstr_sm_lid;
 +					__be16 port_lid;
 +					__be32 changed_attr;
 +					u8 reserved[3];
 +					u8 mstr_sm_sl;
 +					__be64 gid_prefix;
 +				} __packed port_info;
 +				struct {
 +					__be32 block_ptr;
 +					__be32 tbl_entries_mask;
 +				} __packed tbl_change_info;
 +			} params;
 +		} __packed port_mgmt_change;
 +	}			event;
 +	u8			slave_id;
 +	u8			reserved3[2];
 +	u8			owner;
 +} __packed;
 +
  struct mlx4_init_port_param {
  	int			set_guid0;
  	int			set_node_guid;
@@@ -783,6 -793,8 +908,10 @@@ int mlx4_wol_write(struct mlx4_dev *dev
  int mlx4_counter_alloc(struct mlx4_dev *dev, u32 *idx);
  void mlx4_counter_free(struct mlx4_dev *dev, u32 idx);
 =20
 +int mlx4_get_parav_qkey(struct mlx4_dev *dev, u32 qpn, u32 *qkey);
 +
+ int mlx4_flow_attach(struct mlx4_dev *dev,
+ 		     struct mlx4_net_trans_rule *rule, u64 *reg_id);
+ int mlx4_flow_detach(struct mlx4_dev *dev, u64 reg_id);
+=20
  #endif /* MLX4_DEVICE_H */

--Signature=_Thu__12_Jul_2012_12_13_07_+1000_tEWlQid_UR9sKBNS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP/jKzAAoJEECxmPOUX5FEiegP/16PKg/2wh3Ezcm6r34qQtnU
Oc9+JOWdDVol1HusRZobFL7Ob9TPPW2XDYZ6ndJEmaqcfAgyHZVI26r4CQL0O1Zb
v+FdQ1rOqmFd5oDppNFFZJm21FUyl4VUB8RUZ8BNreCyQaU4ylmK8T7elOdqbVry
5YYX0IGKOO93Hb4FGTJt8UQZyj4MWcBXIdIeAc5xpY6GogJE/GdI41q/Dt5MtWIA
vKYcCwciawoTydv+320u2O0RgK6Tex9x3A1pOcmutpBX4BNJMB73k+uSGXY/7XRA
Bno6qYQq78owA/Hhz4ZIApBsSCCq5/flnfFBrT24aT/sIZUl9Qx+/H00pWAeb0yv
d1/zbg82uLnH+tRdZ6jSyKyDEvAzvh3UJZyG3pRlPfi4r3U5DDglIIo8AhUO4+0/
NcQbHD5oIVspcQvYpOCbgEO/UFCqz4UPfvYCP3HkmH4hmgtP0Ia+IBOJ0vLdu+/0
GJiqr3FLhX5HDMEcKCwPDkhs2g3yTRuQhvcRIO+0aWPc7Tjn2o2bj6OA2HDqJxmu
MO4ElNYoFDHakV5zaAa1M6Z1MTt/Z0fMgO9qDZ86PXP54NneizdTn3MIikMgOhZU
pQQ4GiOz00m6y0qo5IsYSP+ZgYjhyfxWeXcsuTAPrAd2EjcfBCOzZaQjHKcPv8od
0f7H/6pokzMaMrejGNut
=ubhu
-----END PGP SIGNATURE-----

--Signature=_Thu__12_Jul_2012_12_13_07_+1000_tEWlQid_UR9sKBNS--
