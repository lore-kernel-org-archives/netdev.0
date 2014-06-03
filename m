From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH v2 net-next 7/8] ethtool: Replace
 ethtool_ops::{get,set}_rxfh_indir() with {get,set}_rxfh()
Date: Tue, 03 Jun 2014 02:51:15 +0100
Message-ID: <1401760275.14007.186.camel@deadeye.wl.decadent.org.uk>
References: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-p6i82H3KnbdJt8u8X+3r"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49658 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751777AbaFCBvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 21:51:22 -0400
In-Reply-To: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-p6i82H3KnbdJt8u8X+3r
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ETHTOOL_{G,S}RXFHINDIR and ETHTOOL_{G,S}RSSH should work for drivers
regardless of whether they expose the hash key, unless you try to
set a hash key for a driver that doesn't expose it.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 15 ++++++++-------
 drivers/net/ethernet/broadcom/tg3.c                 |  8 ++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     |  8 ++++----
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c  | 15 +++++++++------
 drivers/net/ethernet/intel/igb/igb_ethtool.c        |  9 +++++----
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c     | 10 +++++-----
 drivers/net/ethernet/sfc/ethtool.c                  | 10 +++++-----
 drivers/net/vmxnet3/vmxnet3_ethtool.c               |  8 ++++----
 include/linux/ethtool.h                             |  6 ------
 net/core/ethtool.c                                  |  8 ++++----
 10 files changed, 48 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 0322409..af138f8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -3316,7 +3316,7 @@ static u32 bnx2x_get_rxfh_indir_size(struct net_devic=
e *dev)
 	return T_ETH_INDIRECTION_TABLE_SIZE;
 }
=20
-static int bnx2x_get_rxfh_indir(struct net_device *dev, u32 *indir)
+static int bnx2x_get_rxfh(struct net_device *dev, u32 *indir, u8 *key)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
 	u8 ind_table[T_ETH_INDIRECTION_TABLE_SIZE] =3D {0};
@@ -3340,14 +3340,15 @@ static int bnx2x_get_rxfh_indir(struct net_device *=
dev, u32 *indir)
 	return 0;
 }
=20
-static int bnx2x_set_rxfh_indir(struct net_device *dev, const u32 *indir)
+static int bnx2x_set_rxfh(struct net_device *dev, const u32 *indir,
+			  const u8 *key)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
 	size_t i;
=20
 	for (i =3D 0; i < T_ETH_INDIRECTION_TABLE_SIZE; i++) {
 		/*
-		 * The same as in bnx2x_get_rxfh_indir: we can't use a memcpy()
+		 * The same as in bnx2x_get_rxfh: we can't use a memcpy()
 		 * as an internal storage of an indirection table is a u8 array
 		 * while indir->ring_index points to an array of u32.
 		 *
@@ -3471,8 +3472,8 @@ static const struct ethtool_ops bnx2x_ethtool_ops =3D=
 {
 	.get_rxnfc		=3D bnx2x_get_rxnfc,
 	.set_rxnfc		=3D bnx2x_set_rxnfc,
 	.get_rxfh_indir_size	=3D bnx2x_get_rxfh_indir_size,
-	.get_rxfh_indir		=3D bnx2x_get_rxfh_indir,
-	.set_rxfh_indir		=3D bnx2x_set_rxfh_indir,
+	.get_rxfh		=3D bnx2x_get_rxfh,
+	.set_rxfh		=3D bnx2x_set_rxfh,
 	.get_channels		=3D bnx2x_get_channels,
 	.set_channels		=3D bnx2x_set_channels,
 	.get_module_info	=3D bnx2x_get_module_info,
@@ -3498,8 +3499,8 @@ static const struct ethtool_ops bnx2x_vf_ethtool_ops =
=3D {
 	.get_rxnfc		=3D bnx2x_get_rxnfc,
 	.set_rxnfc		=3D bnx2x_set_rxnfc,
 	.get_rxfh_indir_size	=3D bnx2x_get_rxfh_indir_size,
-	.get_rxfh_indir		=3D bnx2x_get_rxfh_indir,
-	.set_rxfh_indir		=3D bnx2x_set_rxfh_indir,
+	.get_rxfh		=3D bnx2x_get_rxfh,
+	.set_rxfh		=3D bnx2x_set_rxfh,
 	.get_channels		=3D bnx2x_get_channels,
 	.set_channels		=3D bnx2x_set_channels,
 };
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/bro=
adcom/tg3.c
index ccd9015..8c2314e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12501,7 +12501,7 @@ static u32 tg3_get_rxfh_indir_size(struct net_devic=
e *dev)
 	return size;
 }
=20
-static int tg3_get_rxfh_indir(struct net_device *dev, u32 *indir)
+static int tg3_get_rxfh(struct net_device *dev, u32 *indir, u8 *key)
 {
 	struct tg3 *tp =3D netdev_priv(dev);
 	int i;
@@ -12512,7 +12512,7 @@ static int tg3_get_rxfh_indir(struct net_device *de=
v, u32 *indir)
 	return 0;
 }
=20
-static int tg3_set_rxfh_indir(struct net_device *dev, const u32 *indir)
+static int tg3_set_rxfh(struct net_device *dev, const u32 *indir, const u8=
 *key)
 {
 	struct tg3 *tp =3D netdev_priv(dev);
 	size_t i;
@@ -14044,8 +14044,8 @@ static const struct ethtool_ops tg3_ethtool_ops =3D=
 {
 	.get_sset_count		=3D tg3_get_sset_count,
 	.get_rxnfc		=3D tg3_get_rxnfc,
 	.get_rxfh_indir_size    =3D tg3_get_rxfh_indir_size,
-	.get_rxfh_indir		=3D tg3_get_rxfh_indir,
-	.set_rxfh_indir		=3D tg3_set_rxfh_indir,
+	.get_rxfh		=3D tg3_get_rxfh,
+	.set_rxfh		=3D tg3_set_rxfh,
 	.get_channels		=3D tg3_get_channels,
 	.set_channels		=3D tg3_set_channels,
 	.get_ts_info		=3D tg3_get_ts_info,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/=
ethernet/chelsio/cxgb4/cxgb4_main.c
index 266a5bc..8cf6be9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2739,7 +2739,7 @@ static u32 get_rss_table_size(struct net_device *dev)
 	return pi->rss_size;
 }
=20
-static int get_rss_table(struct net_device *dev, u32 *p)
+static int get_rss_table(struct net_device *dev, u32 *p, u8 *key)
 {
 	const struct port_info *pi =3D netdev_priv(dev);
 	unsigned int n =3D pi->rss_size;
@@ -2749,7 +2749,7 @@ static int get_rss_table(struct net_device *dev, u32 =
*p)
 	return 0;
 }
=20
-static int set_rss_table(struct net_device *dev, const u32 *p)
+static int set_rss_table(struct net_device *dev, const u32 *p, const u8 *k=
ey)
 {
 	unsigned int i;
 	struct port_info *pi =3D netdev_priv(dev);
@@ -2851,8 +2851,8 @@ static const struct ethtool_ops cxgb_ethtool_ops =3D =
{
 	.set_wol           =3D set_wol,
 	.get_rxnfc         =3D get_rxnfc,
 	.get_rxfh_indir_size =3D get_rss_table_size,
-	.get_rxfh_indir    =3D get_rss_table,
-	.set_rxfh_indir    =3D set_rss_table,
+	.get_rxfh	   =3D get_rss_table,
+	.set_rxfh	   =3D set_rss_table,
 	.flash_device      =3D set_flash,
 };
=20
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/n=
et/ethernet/intel/i40evf/i40evf_ethtool.c
index 77e786d..dbc8986 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -626,13 +626,14 @@ static u32 i40evf_get_rxfh_indir_size(struct net_devi=
ce *netdev)
 }
=20
 /**
- * i40evf_get_rxfh_indir - get the rx flow hash indirection table
+ * i40evf_get_rxfh - get the rx flow hash indirection table
  * @netdev: network interface device structure
  * @indir: indirection table
+ * @key: hash key (will be %NULL until get_rxfh_key_size is implemented)
  *
  * Reads the indirection table directly from the hardware. Always returns =
0.
  **/
-static int i40evf_get_rxfh_indir(struct net_device *netdev, u32 *indir)
+static int i40evf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key)
 {
 	struct i40evf_adapter *adapter =3D netdev_priv(netdev);
 	struct i40e_hw *hw =3D &adapter->hw;
@@ -650,14 +651,16 @@ static int i40evf_get_rxfh_indir(struct net_device *n=
etdev, u32 *indir)
 }
=20
 /**
- * i40evf_set_rxfh_indir - set the rx flow hash indirection table
+ * i40evf_set_rxfh - set the rx flow hash indirection table
  * @netdev: network interface device structure
  * @indir: indirection table
+ * @key: hash key (will be %NULL until get_rxfh_key_size is implemented)
  *
  * Returns -EINVAL if the table specifies an inavlid queue id, otherwise
  * returns 0 after programming the table.
  **/
-static int i40evf_set_rxfh_indir(struct net_device *netdev, const u32 *ind=
ir)
+static int i40evf_set_rxfh(struct net_device *netdev, const u32 *indir,
+			   const u8 *key)
 {
 	struct i40evf_adapter *adapter =3D netdev_priv(netdev);
 	struct i40e_hw *hw =3D &adapter->hw;
@@ -691,8 +694,8 @@ static struct ethtool_ops i40evf_ethtool_ops =3D {
 	.get_rxnfc		=3D i40evf_get_rxnfc,
 	.set_rxnfc		=3D i40evf_set_rxnfc,
 	.get_rxfh_indir_size	=3D i40evf_get_rxfh_indir_size,
-	.get_rxfh_indir		=3D i40evf_get_rxfh_indir,
-	.set_rxfh_indir		=3D i40evf_set_rxfh_indir,
+	.get_rxfh		=3D i40evf_get_rxfh,
+	.set_rxfh		=3D i40evf_set_rxfh,
 	.get_channels		=3D i40evf_get_channels,
 };
=20
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/eth=
ernet/intel/igb/igb_ethtool.c
index a84297c..d8bbcf1 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2830,7 +2830,7 @@ static u32 igb_get_rxfh_indir_size(struct net_device =
*netdev)
 	return IGB_RETA_SIZE;
 }
=20
-static int igb_get_rxfh_indir(struct net_device *netdev, u32 *indir)
+static int igb_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
 	int i;
@@ -2876,7 +2876,8 @@ void igb_write_rss_indir_tbl(struct igb_adapter *adap=
ter)
 	}
 }
=20
-static int igb_set_rxfh_indir(struct net_device *netdev, const u32 *indir)
+static int igb_set_rxfh(struct net_device *netdev, const u32 *indir,
+			const u8 *key)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
 	struct e1000_hw *hw =3D &adapter->hw;
@@ -3025,8 +3026,8 @@ static const struct ethtool_ops igb_ethtool_ops =3D {
 	.get_module_info	=3D igb_get_module_info,
 	.get_module_eeprom	=3D igb_get_module_eeprom,
 	.get_rxfh_indir_size	=3D igb_get_rxfh_indir_size,
-	.get_rxfh_indir		=3D igb_get_rxfh_indir,
-	.set_rxfh_indir		=3D igb_set_rxfh_indir,
+	.get_rxfh		=3D igb_get_rxfh,
+	.set_rxfh		=3D igb_set_rxfh,
 	.get_channels		=3D igb_get_channels,
 	.set_channels		=3D igb_set_channels,
 	.begin			=3D igb_ethtool_begin,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/=
ethernet/mellanox/mlx4/en_ethtool.c
index a72d99f..263a1c7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -564,7 +564,7 @@ static u32 mlx4_en_get_rxfh_indir_size(struct net_devic=
e *dev)
 	return priv->rx_ring_num;
 }
=20
-static int mlx4_en_get_rxfh_indir(struct net_device *dev, u32 *ring_index)
+static int mlx4_en_get_rxfh(struct net_device *dev, u32 *ring_index, u8 *k=
ey)
 {
 	struct mlx4_en_priv *priv =3D netdev_priv(dev);
 	struct mlx4_en_rss_map *rss_map =3D &priv->rss_map;
@@ -582,8 +582,8 @@ static int mlx4_en_get_rxfh_indir(struct net_device *de=
v, u32 *ring_index)
 	return err;
 }
=20
-static int mlx4_en_set_rxfh_indir(struct net_device *dev,
-		const u32 *ring_index)
+static int mlx4_en_set_rxfh(struct net_device *dev, const u32 *ring_index,
+			    const u8 *key)
 {
 	struct mlx4_en_priv *priv =3D netdev_priv(dev);
 	struct mlx4_en_dev *mdev =3D priv->mdev;
@@ -1224,8 +1224,8 @@ const struct ethtool_ops mlx4_en_ethtool_ops =3D {
 	.get_rxnfc =3D mlx4_en_get_rxnfc,
 	.set_rxnfc =3D mlx4_en_set_rxnfc,
 	.get_rxfh_indir_size =3D mlx4_en_get_rxfh_indir_size,
-	.get_rxfh_indir =3D mlx4_en_get_rxfh_indir,
-	.set_rxfh_indir =3D mlx4_en_set_rxfh_indir,
+	.get_rxfh =3D mlx4_en_get_rxfh,
+	.set_rxfh =3D mlx4_en_set_rxfh,
 	.get_channels =3D mlx4_en_get_channels,
 	.set_channels =3D mlx4_en_set_channels,
 	.get_ts_info =3D mlx4_en_get_ts_info,
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/=
ethtool.c
index 0de8b07..74739c4 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1033,7 +1033,7 @@ static u32 efx_ethtool_get_rxfh_indir_size(struct net=
_device *net_dev)
 		0 : ARRAY_SIZE(efx->rx_indir_table));
 }
=20
-static int efx_ethtool_get_rxfh_indir(struct net_device *net_dev, u32 *ind=
ir)
+static int efx_ethtool_get_rxfh(struct net_device *net_dev, u32 *indir, u8=
 *key)
 {
 	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
@@ -1041,8 +1041,8 @@ static int efx_ethtool_get_rxfh_indir(struct net_devi=
ce *net_dev, u32 *indir)
 	return 0;
 }
=20
-static int efx_ethtool_set_rxfh_indir(struct net_device *net_dev,
-				      const u32 *indir)
+static int efx_ethtool_set_rxfh(struct net_device *net_dev,
+				const u32 *indir, const u8 *key)
 {
 	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
@@ -1125,8 +1125,8 @@ const struct ethtool_ops efx_ethtool_ops =3D {
 	.get_rxnfc		=3D efx_ethtool_get_rxnfc,
 	.set_rxnfc		=3D efx_ethtool_set_rxnfc,
 	.get_rxfh_indir_size	=3D efx_ethtool_get_rxfh_indir_size,
-	.get_rxfh_indir		=3D efx_ethtool_get_rxfh_indir,
-	.set_rxfh_indir		=3D efx_ethtool_set_rxfh_indir,
+	.get_rxfh		=3D efx_ethtool_get_rxfh,
+	.set_rxfh		=3D efx_ethtool_set_rxfh,
 	.get_ts_info		=3D efx_ethtool_get_ts_info,
 	.get_module_info	=3D efx_ethtool_get_module_info,
 	.get_module_eeprom	=3D efx_ethtool_get_module_eeprom,
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vm=
xnet3_ethtool.c
index 00e1202..9396cca 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -579,7 +579,7 @@ vmxnet3_get_rss_indir_size(struct net_device *netdev)
 }
=20
 static int
-vmxnet3_get_rss_indir(struct net_device *netdev, u32 *p)
+vmxnet3_get_rss(struct net_device *netdev, u32 *p, u8 *key)
 {
 	struct vmxnet3_adapter *adapter =3D netdev_priv(netdev);
 	struct UPT1_RSSConf *rssConf =3D adapter->rss_conf;
@@ -592,7 +592,7 @@ vmxnet3_get_rss_indir(struct net_device *netdev, u32 *p=
)
 }
=20
 static int
-vmxnet3_set_rss_indir(struct net_device *netdev, const u32 *p)
+vmxnet3_set_rss(struct net_device *netdev, const u32 *p, const u8 *key)
 {
 	unsigned int i;
 	unsigned long flags;
@@ -628,8 +628,8 @@ static const struct ethtool_ops vmxnet3_ethtool_ops =3D=
 {
 	.get_rxnfc         =3D vmxnet3_get_rxnfc,
 #ifdef VMXNET3_RSS
 	.get_rxfh_indir_size =3D vmxnet3_get_rss_indir_size,
-	.get_rxfh_indir    =3D vmxnet3_get_rss_indir,
-	.set_rxfh_indir    =3D vmxnet3_set_rss_indir,
+	.get_rxfh          =3D vmxnet3_get_rss,
+	.set_rxfh          =3D vmxnet3_set_rss,
 #endif
 };
=20
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 874fde0..e658229 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -158,15 +158,11 @@ static inline u32 ethtool_rxfh_indir_default(u32 inde=
x, u32 n_rx_rings)
  *	Returns zero if not supported for this specific device.
  * @get_rxfh_indir_size: Get the size of the RX flow hash indirection tabl=
e.
  *	Returns zero if not supported for this specific device.
- * @get_rxfh_indir: Get the contents of the RX flow hash indirection table=
.
- *	Will not be called if @get_rxfh_indir_size returns zero.
  * @get_rxfh: Get the contents of the RX flow hash indirection table and h=
ash
  *	key.
  *	Will only be called if one or both of @get_rxfh_indir_size and
  *	@get_rxfh_key_size are implemented and return non-zero.
  *	Returns a negative error code or zero.
- * @set_rxfh_indir: Set the contents of the RX flow hash indirection table=
.
- *	Will not be called if @get_rxfh_indir_size returns zero.
  * @set_rxfh: Set the contents of the RX flow hash indirection table and/o=
r
  *	hash key.  In case only the indirection table or hash key is to be
  *	changed, the other argument will be %NULL.
@@ -248,8 +244,6 @@ struct ethtool_ops {
 	int	(*get_rxfh)(struct net_device *, u32 *indir, u8 *key);
 	int	(*set_rxfh)(struct net_device *, const u32 *indir,
 			    const u8 *key);
-	int	(*get_rxfh_indir)(struct net_device *, u32 *);
-	int	(*set_rxfh_indir)(struct net_device *, const u32 *);
 	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
 	int	(*set_channels)(struct net_device *, struct ethtool_channels *);
 	int	(*get_dump_flag)(struct net_device *, struct ethtool_dump *);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index b885734..8ae452a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -582,7 +582,7 @@ static noinline_for_stack int ethtool_get_rxfh_indir(st=
ruct net_device *dev,
 	int ret;
=20
 	if (!dev->ethtool_ops->get_rxfh_indir_size ||
-	    !dev->ethtool_ops->get_rxfh_indir)
+	    !dev->ethtool_ops->get_rxfh)
 		return -EOPNOTSUPP;
 	dev_size =3D dev->ethtool_ops->get_rxfh_indir_size(dev);
 	if (dev_size =3D=3D 0)
@@ -608,7 +608,7 @@ static noinline_for_stack int ethtool_get_rxfh_indir(st=
ruct net_device *dev,
 	if (!indir)
 		return -ENOMEM;
=20
-	ret =3D dev->ethtool_ops->get_rxfh_indir(dev, indir);
+	ret =3D dev->ethtool_ops->get_rxfh(dev, indir, NULL);
 	if (ret)
 		goto out;
=20
@@ -632,7 +632,7 @@ static noinline_for_stack int ethtool_set_rxfh_indir(st=
ruct net_device *dev,
 	int ret;
 	u32 ringidx_offset =3D offsetof(struct ethtool_rxfh_indir, ring_index[0])=
;
=20
-	if (!ops->get_rxfh_indir_size || !ops->set_rxfh_indir ||
+	if (!ops->get_rxfh_indir_size || !ops->set_rxfh ||
 	    !ops->get_rxnfc)
 		return -EOPNOTSUPP;
=20
@@ -669,7 +669,7 @@ static noinline_for_stack int ethtool_set_rxfh_indir(st=
ruct net_device *dev,
 			goto out;
 	}
=20
-	ret =3D ops->set_rxfh_indir(dev, indir);
+	ret =3D ops->set_rxfh(dev, indir, NULL);
=20
 out:
 	kfree(indir);


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-p6i82H3KnbdJt8u8X+3r
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU40qFOe/yOyVhhEJAQqA5w/+J3uqVqx2cE2/dP2lZk4M85IPfjIOFEji
mt+wHhUZ49lvGakStMPX1SK/S4ChRLlRXPXmCBgu2hhKeLdzWdRO5hbBueJRKYOe
rpp0HrFLtFbW1RX5bQcFmQKTI5IBYUso6SJ9C9k19Zam2/2yHrWyXix6aUbZjMJv
KmuecYwPmeyEomX1GmfaltOUJ70nL6BumImyGTdHw7qfelY5o4tbD4bqsf+FSFSX
D5n2mWknrsd9aVyIq0o1DAArooMJ14kQzCelIHenJ+B1gb4PBsO26RYFcMwFDdy6
E998dvXYsZGqfbamYYODflZ+ad/0hBo3D8PnbVGX8IrcJSLgOo+YQZ1+CqvAvA9R
AZrawzCvmRozT1yWHJjHh6wOKfWdJ4R2E1wvmTovPO6n9DhC6Zk/STO1eeqKodbY
Odrv/7R60LlPYAbAxdYb41B8Ys5EFvNs8idQhP8nJ1YewQHX6n1jaPFgZDpDXgcN
4Wn1C+CoeuZUVTbxJymGcSrXK8bV5onMCTI4QRA8oRy18/1hQPaUPOARjvA0ouf9
O4G+Q8iaYNdp+GJqGR31AFQUgUuztCQMycr8qnKnKYqpQVcUMFAXzc8iiT6QQa01
yXJ1p1bRXIfZJQnOdMDKrYjJIO4LfEBFkJtXumngU1P95n08TR16u8SMIUZcJLX3
7a5tEIjoykU=
=Z6jV
-----END PGP SIGNATURE-----

--=-p6i82H3KnbdJt8u8X+3r--
