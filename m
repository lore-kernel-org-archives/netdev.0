From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 6/8] ethtool, be2net: constify array pointer
 parameters to ethtool_ops::set_rxfh
Date: Mon, 02 Jun 2014 02:02:39 +0100
Message-ID: <1401670959.14007.100.camel@deadeye.wl.decadent.org.uk>
References: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-73U80RQNtlPYtxWDWxu9"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46343 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752655AbaFBBCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 21:02:46 -0400
In-Reply-To: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-73U80RQNtlPYtxWDWxu9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c    | 2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h    | 2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 3 ++-
 include/linux/ethtool.h                        | 3 ++-
 4 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethe=
rnet/emulex/benet/be_cmds.c
index 476752d..7b59da2 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2033,7 +2033,7 @@ int be_cmd_reset_function(struct be_adapter *adapter)
 }
=20
 int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
-		      u32 rss_hash_opts, u16 table_size, u8 *rss_hkey)
+		      u32 rss_hash_opts, u16 table_size, const u8 *rss_hkey)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_rss_config *req;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethe=
rnet/emulex/benet/be_cmds.h
index 228d4b6..451f313 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2068,7 +2068,7 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u=
32 *port_num,
 			u32 *function_mode, u32 *function_caps, u16 *asic_rev);
 int be_cmd_reset_function(struct be_adapter *adapter);
 int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
-		      u32 rss_hash_opts, u16 table_size, u8 *rss_hkey);
+		      u32 rss_hash_opts, u16 table_size, const u8 *rss_hkey);
 int be_process_mcc(struct be_adapter *adapter);
 int be_cmd_set_beacon_state(struct be_adapter *adapter, u8 port_num, u8 be=
acon,
 			    u8 status, u8 state);
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/e=
thernet/emulex/benet/be_ethtool.c
index 970ae33..e2da4d2 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -1117,7 +1117,8 @@ static int be_get_rxfh(struct net_device *netdev, u32=
 *indir, u8 *hkey)
 	return 0;
 }
=20
-static int be_set_rxfh(struct net_device *netdev, u32 *indir, u8 *hkey)
+static int be_set_rxfh(struct net_device *netdev, const u32 *indir,
+		       const u8 *hkey)
 {
 	int rc =3D 0, i, j;
 	struct be_adapter *adapter =3D netdev_priv(netdev);
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index de687a9..874fde0 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -246,7 +246,8 @@ struct ethtool_ops {
 	u32	(*get_rxfh_key_size)(struct net_device *);
 	u32	(*get_rxfh_indir_size)(struct net_device *);
 	int	(*get_rxfh)(struct net_device *, u32 *indir, u8 *key);
-	int	(*set_rxfh)(struct net_device *, u32 *indir, u8 *key);
+	int	(*set_rxfh)(struct net_device *, const u32 *indir,
+			    const u8 *key);
 	int	(*get_rxfh_indir)(struct net_device *, u32 *);
 	int	(*set_rxfh_indir)(struct net_device *, const u32 *);
 	void	(*get_channels)(struct net_device *, struct ethtool_channels *);


--=20
Ben Hutchings
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-73U80RQNtlPYtxWDWxu9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4vNL+e/yOyVhhEJAQqA0w/9H0YqjyBp0sGKlp4a4jfizpA0SOTWEbns
R0EMVC2cPssbmeiS72lmv7brWNVO1cn8RD0E5Hx5vJRnGRt+2lZKdC13pH3Qf7H3
hYJvimyF/GCtTQBNYWH8uaP4tAjHatmTi0jm4UIsL0yaBcED0ryLlcjbtAJ50e47
URAOP+QsLgrUsVqZYK8yl3QI4furjOVh+TJ3PCpuCgnK3Sytgu1QkXFs16Ykcs/Z
LB0uFDmf/ZmuH0b9AMGhEZFlB0PbInnpKXszVLY/Y9+/Uo3+q/jyIGXIZVei0bZm
mm2pqQBtcIlT10QRXJJL+ARzqXQWoazCyO5429xwWlhvriAhpuvcEAS7/XLudxRr
oBbAMBk+TYU/BJ3YxZOJIOvklfUH+pHDQPGp79ZTbeFOhK7adItQiWfT2BTm9Zd9
DhA8vZ8BRcG790u3ITaGsteaFsEC2Zt1PnwK0awNmLV/ukWM2YtbBfnEy5Y7aWvu
0aGDVS2iMms+4ijInHjcNkbgY5GvipvUgPDz7PtSZcKMu/QapuOY/WpUKZwPPy8u
7LQPotB46xiZExhA+7TKFtiQvjQ4UYCGePlx0xzOm5Xc5EAu2cylMNS4hWFBiQHW
8oGYyu9SCO805Q0rs0YN+UTN6WxEK48y6Ek70msKJzddooxKt6/Vh3Bq7vcLOwjV
08hkuotELug=
=qsIv
-----END PGP SIGNATURE-----

--=-73U80RQNtlPYtxWDWxu9--
