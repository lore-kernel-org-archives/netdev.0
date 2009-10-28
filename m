From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2009-10-28
Date: Wed, 28 Oct 2009 16:53:46 -0400
Message-ID: <20091028205346.GE2856@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is a collection of fixes (mostly (almost-)one-liners) intended
for 2.6.32.  There are a couple of fixes relating to behavior when an
association failes, as well as spelling fixes, simply endian fixes,
a MAINTAINERS change...I don't think there is anything controversial
here...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 66ed1e5ec1d979e572554643063734a76642=
61bb:
  Eric Dumazet (1):
        pktgen: Dont leak kernel memory

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it master

Andrey Yurovsky (1):
      mac80211: trivial: fix spelling in mesh_hwmp

Bartlomiej Zolnierkiewicz (1):
      MAINTAINERS: rt2x00 list is moderated

Benoit PAPILLAULT (1):
      rt2x00: Fix crypto in TX frame for rt2800usb

Bj=F6rn Smedman (1):
      mac80211: fix for incorrect sequence number on hostapd injected f=
rames

Holger Schurig (1):
      libertas spi: fix sparse errors

Johannes Berg (2):
      mac80211: keep auth state when assoc fails
      cfg80211: sme: deauthenticate on assoc failure

Larry Finger (1):
      b43: Fix Bugzilla #14181 and the bug from the previous 'fix'

Miguel Boton (1):
      b43: add 'struct b43_wl' missing declaration

Reinette Chatre (1):
      mac80211: fix ibss joining

Roel Kluin (1):
      airo: Reorder tests, check bounds before element

 MAINTAINERS                             |    2 +-
 drivers/net/wireless/airo.c             |    5 ++---
 drivers/net/wireless/b43/leds.h         |    1 +
 drivers/net/wireless/b43/main.c         |    1 -
 drivers/net/wireless/b43/rfkill.c       |    3 ++-
 drivers/net/wireless/libertas/if_spi.c  |   10 +++++-----
 drivers/net/wireless/rt2x00/rt2800usb.c |    2 +-
 net/mac80211/ibss.c                     |    6 ++----
 net/mac80211/mesh_hwmp.c                |    2 +-
 net/mac80211/mlme.c                     |    3 +--
 net/mac80211/tx.c                       |    2 +-
 net/wireless/core.h                     |    1 +
 net/wireless/mlme.c                     |    9 +++++++++
 net/wireless/sme.c                      |   21 +++++++++++++++++++--
 14 files changed, 46 insertions(+), 22 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 70bc7de..cdbbaf5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4280,7 +4280,7 @@ F:	drivers/video/aty/aty128fb.c
 RALINK RT2X00 WIRELESS LAN DRIVER
 P:	rt2x00 project
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
-L:	users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
+L:	users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org (moderated for non-subscribers)
 W:	http://rt2x00.serialmonkey.com/
 S:	Maintained
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/ivd/rt2x00.git
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 7116a1a..abf896a 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -4790,9 +4790,8 @@ static int proc_stats_rid_open( struct inode *ino=
de,
 static int get_dec_u16( char *buffer, int *start, int limit ) {
 	u16 value;
 	int valid =3D 0;
-	for( value =3D 0; buffer[*start] >=3D '0' &&
-		     buffer[*start] <=3D '9' &&
-		     *start < limit; (*start)++ ) {
+	for (value =3D 0; *start < limit && buffer[*start] >=3D '0' &&
+			buffer[*start] <=3D '9'; (*start)++) {
 		valid =3D 1;
 		value *=3D 10;
 		value +=3D buffer[*start] - '0';
diff --git a/drivers/net/wireless/b43/leds.h b/drivers/net/wireless/b43=
/leds.h
index 4c56187..32b66d5 100644
--- a/drivers/net/wireless/b43/leds.h
+++ b/drivers/net/wireless/b43/leds.h
@@ -1,6 +1,7 @@
 #ifndef B43_LEDS_H_
 #define B43_LEDS_H_
=20
+struct b43_wl;
 struct b43_wldev;
=20
 #ifdef CONFIG_B43_LEDS
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43=
/main.c
index df6b26a..86f3582 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -4501,7 +4501,6 @@ static void b43_op_stop(struct ieee80211_hw *hw)
=20
 	cancel_work_sync(&(wl->beacon_update_trigger));
=20
-	wiphy_rfkill_stop_polling(hw->wiphy);
 	mutex_lock(&wl->mutex);
 	if (b43_status(dev) >=3D B43_STAT_STARTED) {
 		dev =3D b43_wireless_core_stop(dev);
diff --git a/drivers/net/wireless/b43/rfkill.c b/drivers/net/wireless/b=
43/rfkill.c
index 7a3218c..ffdce6f 100644
--- a/drivers/net/wireless/b43/rfkill.c
+++ b/drivers/net/wireless/b43/rfkill.c
@@ -33,7 +33,8 @@ bool b43_is_hw_radio_enabled(struct b43_wldev *dev)
 		      & B43_MMIO_RADIO_HWENABLED_HI_MASK))
 			return 1;
 	} else {
-		if (b43_read16(dev, B43_MMIO_RADIO_HWENABLED_LO)
+		if (b43_status(dev) >=3D B43_STAT_STARTED &&
+		    b43_read16(dev, B43_MMIO_RADIO_HWENABLED_LO)
 		    & B43_MMIO_RADIO_HWENABLED_LO_MASK)
 			return 1;
 	}
diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wirel=
ess/libertas/if_spi.c
index cb8be8d..5b3672c 100644
--- a/drivers/net/wireless/libertas/if_spi.c
+++ b/drivers/net/wireless/libertas/if_spi.c
@@ -134,7 +134,7 @@ static void spu_transaction_finish(struct if_spi_ca=
rd *card)
 static int spu_write(struct if_spi_card *card, u16 reg, const u8 *buf,=
 int len)
 {
 	int err =3D 0;
-	u16 reg_out =3D cpu_to_le16(reg | IF_SPI_WRITE_OPERATION_MASK);
+	__le16 reg_out =3D cpu_to_le16(reg | IF_SPI_WRITE_OPERATION_MASK);
 	struct spi_message m;
 	struct spi_transfer reg_trans;
 	struct spi_transfer data_trans;
@@ -166,7 +166,7 @@ static int spu_write(struct if_spi_card *card, u16 =
reg, const u8 *buf, int len)
=20
 static inline int spu_write_u16(struct if_spi_card *card, u16 reg, u16=
 val)
 {
-	u16 buff;
+	__le16 buff;
=20
 	buff =3D cpu_to_le16(val);
 	return spu_write(card, reg, (u8 *)&buff, sizeof(u16));
@@ -188,7 +188,7 @@ static int spu_read(struct if_spi_card *card, u16 r=
eg, u8 *buf, int len)
 {
 	unsigned int delay;
 	int err =3D 0;
-	u16 reg_out =3D cpu_to_le16(reg | IF_SPI_READ_OPERATION_MASK);
+	__le16 reg_out =3D cpu_to_le16(reg | IF_SPI_READ_OPERATION_MASK);
 	struct spi_message m;
 	struct spi_transfer reg_trans;
 	struct spi_transfer dummy_trans;
@@ -235,7 +235,7 @@ static int spu_read(struct if_spi_card *card, u16 r=
eg, u8 *buf, int len)
 /* Read 16 bits from an SPI register */
 static inline int spu_read_u16(struct if_spi_card *card, u16 reg, u16 =
*val)
 {
-	u16 buf;
+	__le16 buf;
 	int ret;
=20
 	ret =3D spu_read(card, reg, (u8 *)&buf, sizeof(buf));
@@ -248,7 +248,7 @@ static inline int spu_read_u16(struct if_spi_card *=
card, u16 reg, u16 *val)
  * The low 16 bits are read first. */
 static int spu_read_u32(struct if_spi_card *card, u16 reg, u32 *val)
 {
-	u32 buf;
+	__le32 buf;
 	int err;
=20
 	err =3D spu_read(card, reg, (u8 *)&buf, sizeof(buf));
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wire=
less/rt2x00/rt2800usb.c
index a084077..9fe770f 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -1994,7 +1994,7 @@ static void rt2800usb_write_tx_desc(struct rt2x00=
_dev *rt2x00dev,
 	rt2x00_set_field32(&word, TXWI_W1_BW_WIN_SIZE, txdesc->ba_size);
 	rt2x00_set_field32(&word, TXWI_W1_WIRELESS_CLI_ID,
 			   test_bit(ENTRY_TXD_ENCRYPT, &txdesc->flags) ?
-			       (skbdesc->entry->entry_idx + 1) : 0xff);
+			   txdesc->key_idx : 0xff);
 	rt2x00_set_field32(&word, TXWI_W1_MPDU_TOTAL_BYTE_COUNT,
 			   skb->len - txdesc->l2pad);
 	rt2x00_set_field32(&word, TXWI_W1_PACKETID,
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 6eaf698..ca8ecce 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -538,13 +538,12 @@ static void ieee80211_sta_find_ibss(struct ieee80=
211_sub_if_data *sdata)
 				       WLAN_CAPABILITY_PRIVACY,
 				       capability);
=20
+	if (bss) {
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-	if (bss)
 		printk(KERN_DEBUG "   sta_find_ibss: selected %pM current "
 		       "%pM\n", bss->cbss.bssid, ifibss->bssid);
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
=20
-	if (bss && !memcmp(ifibss->bssid, bss->cbss.bssid, ETH_ALEN)) {
 		printk(KERN_DEBUG "%s: Selected IBSS BSSID %pM"
 		       " based on configured SSID\n",
 		       sdata->dev->name, bss->cbss.bssid);
@@ -552,8 +551,7 @@ static void ieee80211_sta_find_ibss(struct ieee8021=
1_sub_if_data *sdata)
 		ieee80211_sta_join_ibss(sdata, bss);
 		ieee80211_rx_bss_put(local, bss);
 		return;
-	} else if (bss)
-		ieee80211_rx_bss_put(local, bss);
+	}
=20
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
 	printk(KERN_DEBUG "   did not try to join ibss\n");
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index e12a786..29b82e9 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -259,7 +259,7 @@ static u32 airtime_link_metric_get(struct ieee80211=
_local *local,
  * @hwmp_ie: hwmp information element (PREP or PREQ)
  *
  * This function updates the path routing information to the originato=
r and the
- * transmitter of a HWMP PREQ or PREP fram.
+ * transmitter of a HWMP PREQ or PREP frame.
  *
  * Returns: metric to frame originator or 0 if the frame should not be=
 further
  * processed
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 8d26e9b..dc5049d 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1457,8 +1457,7 @@ ieee80211_rx_mgmt_assoc_resp(struct ieee80211_sub=
_if_data *sdata,
 	if (status_code !=3D WLAN_STATUS_SUCCESS) {
 		printk(KERN_DEBUG "%s: AP denied association (code=3D%d)\n",
 		       sdata->dev->name, status_code);
-		list_del(&wk->list);
-		kfree(wk);
+		wk->state =3D IEEE80211_MGD_STATE_IDLE;
 		return RX_MGMT_CFG80211_ASSOC;
 	}
=20
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index db4bda6..eaa4118 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1445,7 +1445,7 @@ static void ieee80211_xmit(struct ieee80211_sub_i=
f_data *sdata,
 				if (tmp_sdata->vif.type !=3D NL80211_IFTYPE_AP)
 					continue;
 				if (compare_ether_addr(tmp_sdata->dev->dev_addr,
-						       hdr->addr2)) {
+						       hdr->addr2) =3D=3D 0) {
 					dev_hold(tmp_sdata->dev);
 					dev_put(sdata->dev);
 					sdata =3D tmp_sdata;
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 2a33d8b..68b3219 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -358,6 +358,7 @@ int cfg80211_mgd_wext_connect(struct cfg80211_regis=
tered_device *rdev,
 			      struct wireless_dev *wdev);
=20
 void cfg80211_conn_work(struct work_struct *work);
+void cfg80211_sme_failed_assoc(struct wireless_dev *wdev);
 bool cfg80211_sme_failed_reassoc(struct wireless_dev *wdev);
=20
 /* internal helpers */
diff --git a/net/wireless/mlme.c b/net/wireless/mlme.c
index 79d2eec..0a6b7a0 100644
--- a/net/wireless/mlme.c
+++ b/net/wireless/mlme.c
@@ -62,6 +62,7 @@ void cfg80211_send_rx_assoc(struct net_device *dev, c=
onst u8 *buf, size_t len)
 	u8 *ie =3D mgmt->u.assoc_resp.variable;
 	int i, ieoffs =3D offsetof(struct ieee80211_mgmt, u.assoc_resp.variab=
le);
 	struct cfg80211_internal_bss *bss =3D NULL;
+	bool need_connect_result =3D true;
=20
 	wdev_lock(wdev);
=20
@@ -94,6 +95,14 @@ void cfg80211_send_rx_assoc(struct net_device *dev, =
const u8 *buf, size_t len)
 		}
=20
 		WARN_ON(!bss);
+	} else if (wdev->conn) {
+		cfg80211_sme_failed_assoc(wdev);
+		need_connect_result =3D false;
+		/*
+		 * do not call connect_result() now because the
+		 * sme will schedule work that does it later.
+		 */
+		goto out;
 	}
=20
 	if (!wdev->conn && wdev->sme_state =3D=3D CFG80211_SME_IDLE) {
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index 93c3ed3..ece378d 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -26,6 +26,7 @@ struct cfg80211_conn {
 		CFG80211_CONN_AUTHENTICATING,
 		CFG80211_CONN_ASSOCIATE_NEXT,
 		CFG80211_CONN_ASSOCIATING,
+		CFG80211_CONN_DEAUTH_ASSOC_FAIL,
 	} state;
 	u8 bssid[ETH_ALEN], prev_bssid[ETH_ALEN];
 	u8 *ie;
@@ -148,6 +149,12 @@ static int cfg80211_conn_do_work(struct wireless_d=
ev *wdev)
 					       NULL, 0,
 					       WLAN_REASON_DEAUTH_LEAVING);
 		return err;
+	case CFG80211_CONN_DEAUTH_ASSOC_FAIL:
+		__cfg80211_mlme_deauth(rdev, wdev->netdev, params->bssid,
+				       NULL, 0,
+				       WLAN_REASON_DEAUTH_LEAVING);
+		/* return an error so that we call __cfg80211_connect_result() */
+		return -EINVAL;
 	default:
 		return 0;
 	}
@@ -158,6 +165,7 @@ void cfg80211_conn_work(struct work_struct *work)
 	struct cfg80211_registered_device *rdev =3D
 		container_of(work, struct cfg80211_registered_device, conn_work);
 	struct wireless_dev *wdev;
+	u8 bssid[ETH_ALEN];
=20
 	rtnl_lock();
 	cfg80211_lock_rdev(rdev);
@@ -173,10 +181,10 @@ void cfg80211_conn_work(struct work_struct *work)
 			wdev_unlock(wdev);
 			continue;
 		}
+		memcpy(bssid, wdev->conn->params.bssid, ETH_ALEN);
 		if (cfg80211_conn_do_work(wdev))
 			__cfg80211_connect_result(
-					wdev->netdev,
-					wdev->conn->params.bssid,
+					wdev->netdev, bssid,
 					NULL, 0, NULL, 0,
 					WLAN_STATUS_UNSPECIFIED_FAILURE,
 					false, NULL);
@@ -337,6 +345,15 @@ bool cfg80211_sme_failed_reassoc(struct wireless_d=
ev *wdev)
 	return true;
 }
=20
+void cfg80211_sme_failed_assoc(struct wireless_dev *wdev)
+{
+	struct wiphy *wiphy =3D wdev->wiphy;
+	struct cfg80211_registered_device *rdev =3D wiphy_to_dev(wiphy);
+
+	wdev->conn->state =3D CFG80211_CONN_DEAUTH_ASSOC_FAIL;
+	schedule_work(&rdev->conn_work);
+}
+
 void __cfg80211_connect_result(struct net_device *dev, const u8 *bssid=
,
 			       const u8 *req_ie, size_t req_ie_len,
 			       const u8 *resp_ie, size_t resp_ie_len,
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
