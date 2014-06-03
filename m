From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 6/8] ethtool, be2net: constify array pointer
 parameters to ethtool_ops::set_rxfh
Date: Tue, 03 Jun 2014 02:51:06 +0100
Message-ID: <1401760266.14007.185.camel@deadeye.wl.decadent.org.uk>
References: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-NuiFADxQOLKOpRQcqCxt"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49652 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751511AbaFCBvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 21:51:13 -0400
In-Reply-To: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NuiFADxQOLKOpRQcqCxt
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
If more than one person is responsible for a bug, no one is at fault.

--=-NuiFADxQOLKOpRQcqCxt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU40qCue/yOyVhhEJAQrO1RAArTSZ0C1hXKCg6Xf8Oc88ojyUev/btlwE
2a6liofxCKnQveCuxIXjb/jMxiOqssCpIxgN1O53fj7cRcZhDqn0aXBAIz2LuBO+
jYA7sCCK4v8s+RNqM/dabjcK3tO5CQEauTAAIfT1WfUAh/YNxeKorGOIg0pH5pbo
S2AuXIUkMniJw0QI7rOcQQtFtXSU64JtKSyXL6bY7qDlMp8c7J/+O2W9tBq8zkKz
uey/GnGho7QAhM7TjltCRzcqAgy29Aqev8NfBnA106/8yngwkZgE4galRNqn/aG9
yymCBwMPQ3W0MIJVIvivkzB+QckKAJ50shUrXxpy/Xe8v73aw6Y2wql01XV6Iu/w
NbyEKpik4qDdV36xjN6kZqO1Qbvb0dLmMyVIH/nyypY6l62JtS2I/FA3AbM2pb2q
uIK5ECKVmb0aeIgg+REa47KpPP3cVN0L9TtpOgjKBss8/6KmwFFtzgyIYuGt3Vjr
I1kmwkNX7Y43vhoKjrKNsGTU72/jIsB+9L0Oe9LgPc6TwiEd/F197BHjauBs0FfH
Zf/YgWOY1MbPsv0ny0kG120jA6P2jfZvGdzkw0MXH83rR0XcUfdQRfaxsOKcVXe9
jU/D0LjRWKhNYVKSPF3UZI/btnc9a4MvuwFuc2Y1pAW9OqubSxrfh0TSo576Nywp
nP43z++eOTw=
=G50W
-----END PGP SIGNATURE-----

--=-NuiFADxQOLKOpRQcqCxt--
