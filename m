From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 27 Jun 2013 13:49:56 +1000
Message-ID: <20130627134956.7f7854bef31558c2a4bfb037@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__27_Jun_2013_13_49_56_+1000_paMiyakmMdZEaTvx"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>,
	Chris Healy <cphealy@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__27_Jun_2013_13_49_56_+1000_paMiyakmMdZEaTvx
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/freescale/fec_main.c between commits 32bc9b46d840
("fec: Add support to restart autonegotiate") and d13919301d9a ("net:
fec: Fix build for MCF5272") from the net tree and commit 38ae92dc215e
("ec: Add support for reading RMON registers") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/freescale/fec_main.c
index d48099f,ed6180e..0000000
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@@ -1444,13 -1443,121 +1451,122 @@@ static int fec_enet_set_pauseparam(stru
  	return 0;
  }
 =20
- #endif /* !defined(CONFIG_M5272) */
 -#ifndef CONFIG_M5272
+ static const struct fec_stat {
+ 	char name[ETH_GSTRING_LEN];
+ 	u16 offset;
+ } fec_stats[] =3D {
+ 	/* RMON TX */
+ 	{ "tx_dropped", RMON_T_DROP },
+ 	{ "tx_packets", RMON_T_PACKETS },
+ 	{ "tx_broadcast", RMON_T_BC_PKT },
+ 	{ "tx_multicast", RMON_T_MC_PKT },
+ 	{ "tx_crc_errors", RMON_T_CRC_ALIGN },
+ 	{ "tx_undersize", RMON_T_UNDERSIZE },
+ 	{ "tx_oversize", RMON_T_OVERSIZE },
+ 	{ "tx_fragment", RMON_T_FRAG },
+ 	{ "tx_jabber", RMON_T_JAB },
+ 	{ "tx_collision", RMON_T_COL },
+ 	{ "tx_64byte", RMON_T_P64 },
+ 	{ "tx_65to127byte", RMON_T_P65TO127 },
+ 	{ "tx_128to255byte", RMON_T_P128TO255 },
+ 	{ "tx_256to511byte", RMON_T_P256TO511 },
+ 	{ "tx_512to1023byte", RMON_T_P512TO1023 },
+ 	{ "tx_1024to2047byte", RMON_T_P1024TO2047 },
+ 	{ "tx_GTE2048byte", RMON_T_P_GTE2048 },
+ 	{ "tx_octets", RMON_T_OCTETS },
+=20
+ 	/* IEEE TX */
+ 	{ "IEEE_tx_drop", IEEE_T_DROP },
+ 	{ "IEEE_tx_frame_ok", IEEE_T_FRAME_OK },
+ 	{ "IEEE_tx_1col", IEEE_T_1COL },
+ 	{ "IEEE_tx_mcol", IEEE_T_MCOL },
+ 	{ "IEEE_tx_def", IEEE_T_DEF },
+ 	{ "IEEE_tx_lcol", IEEE_T_LCOL },
+ 	{ "IEEE_tx_excol", IEEE_T_EXCOL },
+ 	{ "IEEE_tx_macerr", IEEE_T_MACERR },
+ 	{ "IEEE_tx_cserr", IEEE_T_CSERR },
+ 	{ "IEEE_tx_sqe", IEEE_T_SQE },
+ 	{ "IEEE_tx_fdxfc", IEEE_T_FDXFC },
+ 	{ "IEEE_tx_octets_ok", IEEE_T_OCTETS_OK },
+=20
+ 	/* RMON RX */
+ 	{ "rx_packets", RMON_R_PACKETS },
+ 	{ "rx_broadcast", RMON_R_BC_PKT },
+ 	{ "rx_multicast", RMON_R_MC_PKT },
+ 	{ "rx_crc_errors", RMON_R_CRC_ALIGN },
+ 	{ "rx_undersize", RMON_R_UNDERSIZE },
+ 	{ "rx_oversize", RMON_R_OVERSIZE },
+ 	{ "rx_fragment", RMON_R_FRAG },
+ 	{ "rx_jabber", RMON_R_JAB },
+ 	{ "rx_64byte", RMON_R_P64 },
+ 	{ "rx_65to127byte", RMON_R_P65TO127 },
+ 	{ "rx_128to255byte", RMON_R_P128TO255 },
+ 	{ "rx_256to511byte", RMON_R_P256TO511 },
+ 	{ "rx_512to1023byte", RMON_R_P512TO1023 },
+ 	{ "rx_1024to2047byte", RMON_R_P1024TO2047 },
+ 	{ "rx_GTE2048byte", RMON_R_P_GTE2048 },
+ 	{ "rx_octets", RMON_R_OCTETS },
+=20
+ 	/* IEEE RX */
+ 	{ "IEEE_rx_drop", IEEE_R_DROP },
+ 	{ "IEEE_rx_frame_ok", IEEE_R_FRAME_OK },
+ 	{ "IEEE_rx_crc", IEEE_R_CRC },
+ 	{ "IEEE_rx_align", IEEE_R_ALIGN },
+ 	{ "IEEE_rx_macerr", IEEE_R_MACERR },
+ 	{ "IEEE_rx_fdxfc", IEEE_R_FDXFC },
+ 	{ "IEEE_rx_octets_ok", IEEE_R_OCTETS_OK },
+ };
+=20
+ static void fec_enet_get_ethtool_stats(struct net_device *dev,
+ 	struct ethtool_stats *stats, u64 *data)
+ {
+ 	struct fec_enet_private *fep =3D netdev_priv(dev);
+ 	int i;
+=20
+ 	for (i =3D 0; i < ARRAY_SIZE(fec_stats); i++)
+ 		data[i] =3D readl(fep->hwp + fec_stats[i].offset);
+ }
+=20
+ static void fec_enet_get_strings(struct net_device *netdev,
+ 	u32 stringset, u8 *data)
+ {
+ 	int i;
+ 	switch (stringset) {
+ 	case ETH_SS_STATS:
+ 		for (i =3D 0; i < ARRAY_SIZE(fec_stats); i++)
+ 			memcpy(data + i * ETH_GSTRING_LEN,
+ 				fec_stats[i].name, ETH_GSTRING_LEN);
+ 		break;
+ 	}
+ }
+=20
+ static int fec_enet_get_sset_count(struct net_device *dev, int sset)
+ {
+ 	switch (sset) {
+ 	case ETH_SS_STATS:
+ 		return ARRAY_SIZE(fec_stats);
+ 	default:
+ 		return -EOPNOTSUPP;
+ 	}
+ }
+ #endif
+=20
+ static int fec_enet_nway_reset(struct net_device *dev)
+ {
+ 	struct fec_enet_private *fep =3D netdev_priv(dev);
+ 	struct phy_device *phydev =3D fep->phy_dev;
+=20
+ 	if (!phydev)
+ 		return -ENODEV;
+=20
+ 	return genphy_restart_aneg(phydev);
+ }
 =20
  static const struct ethtool_ops fec_enet_ethtool_ops =3D {
 +#if !defined(CONFIG_M5272)
  	.get_pauseparam		=3D fec_enet_get_pauseparam,
  	.set_pauseparam		=3D fec_enet_set_pauseparam,
 +#endif
  	.get_settings		=3D fec_enet_get_settings,
  	.set_settings		=3D fec_enet_set_settings,
  	.get_drvinfo		=3D fec_enet_get_drvinfo,
@@@ -1891,9 -2001,13 +2011,14 @@@ fec_probe(struct platform_device *pdev
  	if (pdev->id_entry &&
  	    (pdev->id_entry->driver_data & FEC_QUIRK_HAS_GBIT))
  		fep->pause_flag |=3D FEC_PAUSE_FLAG_AUTONEG;
 +#endif
 =20
- 	fep->hwp =3D devm_request_and_ioremap(&pdev->dev, r);
+ 	fep->hwp =3D devm_ioremap_resource(&pdev->dev, r);
+ 	if (IS_ERR(fep->hwp)) {
+ 		ret =3D PTR_ERR(fep->hwp);
+ 		goto failed_ioremap;
+ 	}
+=20
  	fep->pdev =3D pdev;
  	fep->dev_id =3D dev_id++;
 =20

--Signature=_Thu__27_Jun_2013_13_49_56_+1000_paMiyakmMdZEaTvx
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRy7ZoAAoJEECxmPOUX5FErmsQAKdRnoqebv0pCsGItDH5qi1n
yMVshC2kdcS/j9p3E4G1RAqWSPkHE2Gv8a2tV3Iz0dGfo4h5l0q7pCQtl1kh3Y05
3+f4ObnRSV7eQ9JXWkMAE9pmFZxURoxsQK37f3XoAiAbp+87sKWocWlpoVVFOIfg
Lj1nMXU+OXwsZS1SjFWpKjrC66/S0Ni/YATqfYyvBnVossBAJ4BEU+aGPBVqEghJ
UU85G0Edll75cS3sT3T7G6EAXL0/XYBYT2z3DgwUoRDC9rg77dkYI4QXgsz8wWnO
n4ss9c6QSM2oJqm19EK+Van+QhfeOwISdYHgC495wDS489puYaRjYNvgV7HBPf/X
N4sTLFqpLk2+JoMlMUc8d7WqFEemlmSzszEBu8ysnsg8Xth4nW8fiK4S213sYk9y
Xm5i09U+Cuq0YamB4MBHRFiVU753Gh42UM6JrHLL3LlRjkq2T+gf9C5bvpbLCDOF
wwtjE4gNBthZNV6g6sp0ZWQNwFktJhQeOk49/yFafz4AgC5Myx1wN9hUom+cubVh
lyD5vGQSJ1TJY5n5L4wel/bOuCW4WzP54QF1bxKPUm2c3JTvxCFTuIMSd06EaATQ
DsahELFF3PdsjtxQiwMZKLZK5pGddp455+BEa2BuavTcpgNJFQJUZ3eD2qUYJOZs
SV7nvF7EWRd1T/hHtLEw
=q0Ji
-----END PGP SIGNATURE-----

--Signature=_Thu__27_Jun_2013_13_49_56_+1000_paMiyakmMdZEaTvx--
