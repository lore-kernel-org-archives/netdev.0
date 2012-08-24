From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-08-24
Date: Fri, 24 Aug 2012 12:13:31 -0400
Message-ID: <20120824161330.GC27147@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SLDf9lqlvOQaIe6s"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56646 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759600Ab2HXQT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 12:19:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit e72615f6abde92e961feee13e1078a1352cde4f7

Dave,

This batch of fixes is intended for 3.6...

Johannes Berg gives us a pair of iwlwifi fixes.  One corrects some
improperly defined ifdefs that lead to crashes and BUG_ONs.  The other
prevents attempts to read SRAM for devices that aren't actually started.

Julia Lawall provides an ipw2100 fix to properly set the return code
=66rom a function call before testing it! :-)

Thomas Huehn corrects the improper use of a constant related to a power
setting in ath5k.

Thomas Pedersen offers a mac80211 fix to properly handle destination
addresses of unicast frames passing though a mesh gate.

Vladimir Zapolskiy provides a brcmsmac fix to properly mark the
interface state when the device goes down.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit a0dfb2634e5671770f598cda08002d8cda66ac77:

  af_packet: match_fanout_group() can be static (2012-08-23 09:27:12 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to e72615f6abde92e961feee13e1078a1352cde4f7:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2012-08-24 11:16:58 -0400)

----------------------------------------------------------------

Johannes Berg (2):
      iwlwifi: fix flow handler debug code
      iwlwifi: protect SRAM debugfs

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Julia Lawall (1):
      drivers/net/wireless/ipw2x00/ipw2100.c: introduce missing initializat=
ion

Thomas Huehn (1):
      ath5k: fix wrong max power per rate eeprom reads for 802.11a

Thomas Pedersen (1):
      mac80211: fix DS to MBSS address translation

Vladimir Zapolskiy (1):
      brcm80211: smac: set interface down on reset

 drivers/net/wireless/ath/ath5k/eeprom.c            |  2 +-
 drivers/net/wireless/ath/ath5k/eeprom.h            |  1 +
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |  3 ++
 drivers/net/wireless/ipw2x00/ipw2100.c             |  3 +-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |  3 ++
 drivers/net/wireless/iwlwifi/pcie/internal.h       |  2 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |  2 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          | 30 +++++++++--------
 net/mac80211/tx.c                                  | 38 +++++++++---------=
----
 9 files changed, 44 insertions(+), 40 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/eeprom.c b/drivers/net/wireless=
/ath/ath5k/eeprom.c
index 4026c90..b7e0258 100644
--- a/drivers/net/wireless/ath/ath5k/eeprom.c
+++ b/drivers/net/wireless/ath/ath5k/eeprom.c
@@ -1482,7 +1482,7 @@ ath5k_eeprom_read_target_rate_pwr_info(struct ath5k_h=
w *ah, unsigned int mode)
 	case AR5K_EEPROM_MODE_11A:
 		offset +=3D AR5K_EEPROM_TARGET_PWR_OFF_11A(ee->ee_version);
 		rate_pcal_info =3D ee->ee_rate_tpwr_a;
-		ee->ee_rate_target_pwr_num[mode] =3D AR5K_EEPROM_N_5GHZ_CHAN;
+		ee->ee_rate_target_pwr_num[mode] =3D AR5K_EEPROM_N_5GHZ_RATE_CHAN;
 		break;
 	case AR5K_EEPROM_MODE_11B:
 		offset +=3D AR5K_EEPROM_TARGET_PWR_OFF_11B(ee->ee_version);
diff --git a/drivers/net/wireless/ath/ath5k/eeprom.h b/drivers/net/wireless=
/ath/ath5k/eeprom.h
index dc2bcfe..94a9bbe 100644
--- a/drivers/net/wireless/ath/ath5k/eeprom.h
+++ b/drivers/net/wireless/ath/ath5k/eeprom.h
@@ -182,6 +182,7 @@
 #define AR5K_EEPROM_EEP_DELTA		10
 #define AR5K_EEPROM_N_MODES		3
 #define AR5K_EEPROM_N_5GHZ_CHAN		10
+#define AR5K_EEPROM_N_5GHZ_RATE_CHAN	8
 #define AR5K_EEPROM_N_2GHZ_CHAN		3
 #define AR5K_EEPROM_N_2GHZ_CHAN_2413	4
 #define	AR5K_EEPROM_N_2GHZ_CHAN_MAX	4
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/driver=
s/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index 192ad5c..a5edebe 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -1233,6 +1233,9 @@ uint brcms_reset(struct brcms_info *wl)
 	/* dpc will not be rescheduled */
 	wl->resched =3D false;
=20
+	/* inform publicly that interface is down */
+	wl->pub->up =3D false;
+
 	return 0;
 }
=20
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/=
ipw2x00/ipw2100.c
index 95aa8e1..83324b3 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -2042,7 +2042,8 @@ static void isr_indicate_associated(struct ipw2100_pr=
iv *priv, u32 status)
 		return;
 	}
 	len =3D ETH_ALEN;
-	ipw2100_get_ordinal(priv, IPW_ORD_STAT_ASSN_AP_BSSID, &bssid, &len);
+	ret =3D ipw2100_get_ordinal(priv, IPW_ORD_STAT_ASSN_AP_BSSID, bssid,
+				  &len);
 	if (ret) {
 		IPW_DEBUG_INFO("failed querying ordinals at line %d\n",
 			       __LINE__);
diff --git a/drivers/net/wireless/iwlwifi/dvm/debugfs.c b/drivers/net/wirel=
ess/iwlwifi/dvm/debugfs.c
index 46782f1..a47b306 100644
--- a/drivers/net/wireless/iwlwifi/dvm/debugfs.c
+++ b/drivers/net/wireless/iwlwifi/dvm/debugfs.c
@@ -124,6 +124,9 @@ static ssize_t iwl_dbgfs_sram_read(struct file *file,
 	const struct fw_img *img;
 	size_t bufsz;
=20
+	if (!iwl_is_ready_rf(priv))
+		return -EAGAIN;
+
 	/* default is to dump the entire data segment */
 	if (!priv->dbgfs_sram_offset && !priv->dbgfs_sram_len) {
 		priv->dbgfs_sram_offset =3D 0x800000;
diff --git a/drivers/net/wireless/iwlwifi/pcie/internal.h b/drivers/net/wir=
eless/iwlwifi/pcie/internal.h
index d9694c5..4ffc18d 100644
--- a/drivers/net/wireless/iwlwifi/pcie/internal.h
+++ b/drivers/net/wireless/iwlwifi/pcie/internal.h
@@ -350,7 +350,7 @@ int iwl_queue_space(const struct iwl_queue *q);
 /*****************************************************
 * Error handling
 ******************************************************/
-int iwl_dump_fh(struct iwl_trans *trans, char **buf, bool display);
+int iwl_dump_fh(struct iwl_trans *trans, char **buf);
 void iwl_dump_csr(struct iwl_trans *trans);
=20
 /*****************************************************
diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c b/drivers/net/wireless/=
iwlwifi/pcie/rx.c
index 39a6ca1..d1a61ba 100644
--- a/drivers/net/wireless/iwlwifi/pcie/rx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/rx.c
@@ -555,7 +555,7 @@ static void iwl_irq_handle_error(struct iwl_trans *tran=
s)
 	}
=20
 	iwl_dump_csr(trans);
-	iwl_dump_fh(trans, NULL, false);
+	iwl_dump_fh(trans, NULL);
=20
 	iwl_op_mode_nic_error(trans->op_mode);
 }
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wirele=
ss/iwlwifi/pcie/trans.c
index 939c2f7..1e86ea2 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -1649,13 +1649,9 @@ static const char *get_fh_string(int cmd)
 #undef IWL_CMD
 }
=20
-int iwl_dump_fh(struct iwl_trans *trans, char **buf, bool display)
+int iwl_dump_fh(struct iwl_trans *trans, char **buf)
 {
 	int i;
-#ifdef CONFIG_IWLWIFI_DEBUG
-	int pos =3D 0;
-	size_t bufsz =3D 0;
-#endif
 	static const u32 fh_tbl[] =3D {
 		FH_RSCSR_CHNL0_STTS_WPTR_REG,
 		FH_RSCSR_CHNL0_RBDCB_BASE_REG,
@@ -1667,29 +1663,35 @@ int iwl_dump_fh(struct iwl_trans *trans, char **buf=
, bool display)
 		FH_TSSR_TX_STATUS_REG,
 		FH_TSSR_TX_ERROR_REG
 	};
-#ifdef CONFIG_IWLWIFI_DEBUG
-	if (display) {
-		bufsz =3D ARRAY_SIZE(fh_tbl) * 48 + 40;
+
+#ifdef CONFIG_IWLWIFI_DEBUGFS
+	if (buf) {
+		int pos =3D 0;
+		size_t bufsz =3D ARRAY_SIZE(fh_tbl) * 48 + 40;
+
 		*buf =3D kmalloc(bufsz, GFP_KERNEL);
 		if (!*buf)
 			return -ENOMEM;
+
 		pos +=3D scnprintf(*buf + pos, bufsz - pos,
 				"FH register values:\n");
-		for (i =3D 0; i < ARRAY_SIZE(fh_tbl); i++) {
+
+		for (i =3D 0; i < ARRAY_SIZE(fh_tbl); i++)
 			pos +=3D scnprintf(*buf + pos, bufsz - pos,
 				"  %34s: 0X%08x\n",
 				get_fh_string(fh_tbl[i]),
 				iwl_read_direct32(trans, fh_tbl[i]));
-		}
+
 		return pos;
 	}
 #endif
+
 	IWL_ERR(trans, "FH register values:\n");
-	for (i =3D 0; i <  ARRAY_SIZE(fh_tbl); i++) {
+	for (i =3D 0; i <  ARRAY_SIZE(fh_tbl); i++)
 		IWL_ERR(trans, "  %34s: 0X%08x\n",
 			get_fh_string(fh_tbl[i]),
 			iwl_read_direct32(trans, fh_tbl[i]));
-	}
+
 	return 0;
 }
=20
@@ -1982,11 +1984,11 @@ static ssize_t iwl_dbgfs_fh_reg_read(struct file *f=
ile,
 				     size_t count, loff_t *ppos)
 {
 	struct iwl_trans *trans =3D file->private_data;
-	char *buf;
+	char *buf =3D NULL;
 	int pos =3D 0;
 	ssize_t ret =3D -EFAULT;
=20
-	ret =3D pos =3D iwl_dump_fh(trans, &buf, true);
+	ret =3D pos =3D iwl_dump_fh(trans, &buf);
 	if (buf) {
 		ret =3D simple_read_from_buffer(user_buf,
 					      count, ppos, buf, pos);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index acf712f..c5e8c9c 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1811,37 +1811,31 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_bu=
ff *skb,
 			meshhdrlen =3D ieee80211_new_mesh_header(&mesh_hdr,
 					sdata, NULL, NULL);
 		} else {
-			int is_mesh_mcast =3D 1;
-			const u8 *mesh_da;
+			/* DS -> MBSS (802.11-2012 13.11.3.3).
+			 * For unicast with unknown forwarding information,
+			 * destination might be in the MBSS or if that fails
+			 * forwarded to another mesh gate. In either case
+			 * resolution will be handled in ieee80211_xmit(), so
+			 * leave the original DA. This also works for mcast */
+			const u8 *mesh_da =3D skb->data;
+
+			if (mppath)
+				mesh_da =3D mppath->mpp;
+			else if (mpath)
+				mesh_da =3D mpath->dst;
+			rcu_read_unlock();
=20
-			if (is_multicast_ether_addr(skb->data))
-				/* DA TA mSA AE:SA */
-				mesh_da =3D skb->data;
-			else {
-				static const u8 bcast[ETH_ALEN] =3D
-					{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
-				if (mppath) {
-					/* RA TA mDA mSA AE:DA SA */
-					mesh_da =3D mppath->mpp;
-					is_mesh_mcast =3D 0;
-				} else if (mpath) {
-					mesh_da =3D mpath->dst;
-					is_mesh_mcast =3D 0;
-				} else {
-					/* DA TA mSA AE:SA */
-					mesh_da =3D bcast;
-				}
-			}
 			hdrlen =3D ieee80211_fill_mesh_addresses(&hdr, &fc,
 					mesh_da, sdata->vif.addr);
-			rcu_read_unlock();
-			if (is_mesh_mcast)
+			if (is_multicast_ether_addr(mesh_da))
+				/* DA TA mSA AE:SA */
 				meshhdrlen =3D
 					ieee80211_new_mesh_header(&mesh_hdr,
 							sdata,
 							skb->data + ETH_ALEN,
 							NULL);
 			else
+				/* RA TA mDA mSA AE:DA SA */
 				meshhdrlen =3D
 					ieee80211_new_mesh_header(&mesh_hdr,
 							sdata,
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--SLDf9lqlvOQaIe6s
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQN6gqAAoJEJctW/TcYTgG1yAP/R4l7uhqs9qJyDP0SzdnqL6N
2lDTy3PVgdH5GnZ89IBuBn+kV+Yc6eCLLTwo/Axj5TFZVmw7u5gBJHswr26SGN6O
HllVTH7jUaBBkVkeJkjBF6RWFcvMmJHoJW0P+UXU/DMT7LVaDcI+d3xzGd26Uvhs
+rRzBTjU8R0MSKWx/l0L78BWlMxK0RDLXrH009L1QZr75vAxPANGbFKiBQEBeZdy
OcO/qaEgEAnMECHmDRxFWS/9eD4NDvMMMwhSvugXBalNs+thXGRMg1UhG74mYMiV
WukqFNtFfXeaeav09XXIYha/4pIsjC5LNNh82pHvgm9QRuYl0duyjrBQwhUsvlAm
Sw2OcznOsrxBC6CbqvaiQ9svKGY0LRAykDBYRuvzXAkZ7aXQxVGtjSB4k6HDaKY8
0ey3LtSqbMpEss0beYHTmgYf0132LY7FthKb3b1dZkkjc8RmJ1nQdYotc9UO0G+M
S+ZtM660WrxWFMdKo/znitD2LWZutU1CBSWzuXVl1RUhTf78m5RjOL9G+02P5v02
KSCIfLi3oyV0aCZnAWFmuj3SjTo8PuLZmfiWJZbsmoHhdWqtA9VHUEt0mLo9fZuF
SIedlL02uILDsnw/ncXlmUlybyZbFz60SetbRqbTlqvtRmaCqKNdpM/GErHTL19g
mL9/k01pyjGkAnlWgyi/
=NOpN
-----END PGP SIGNATURE-----

--SLDf9lqlvOQaIe6s--
