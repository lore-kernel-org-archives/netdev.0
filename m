From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-07-24
Date: Wed, 24 Jul 2013 14:04:01 -0400
Message-ID: <20130724180400.GF2385@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="r5Pyd7+fXNt84Ff3"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This is another batch of fixes intended for the 3.11 stream.  FWIW,
this is the first request with fixes from the mac80211 and iwlwifi
trees as well.

Regarding the mac80211 bits, Johannes says:

"Here I have a fix for RSSI thresholds in mesh, two minstrel fixes from
Felix, an nl80211 fix from Michal and four various fixes I did myself."

As for the iwlwifi bits, Johannes says:

"Here I have a fix for debugfs directory creation (causing a spurious
error message), two scanning fixes from David Spinadel, an LED fix and
two patches related to a BA session problem that eventually caused
firmware crashes from Emmanuel and a small BT fix for older devices as
well as a workaround for a firmware problem with APs with very small
beacon intervals from myself."

Along with those:

Arend van Spriel addresses a lock-up and a NULL pointer dereference
in brcmfmac.

Daniel Drake fixes an unhandled interrupt during device tear down
in mwifiex.

Larry Finger corrects a wil6210 build error.

Oleksij Rempel fixes two ath9k_htc problems related to keeping the
driver and firmware in sync.

Solomon Peachy gives us a cw1200 fix to avoid an oops in monitor mode.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit f8c0aca9fda7856a8a8d61d523ba3187affbd714:

  fec: Add MODULE_ALIAS (2013-07-23 17:23:16 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 18e1ccb6ca35f995006749d20d9bd6ef40d736fd:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-07-24 11:50:38 -0400)

----------------------------------------------------------------

Alexander Bondar (1):
      iwlwifi: mvm: Fix VIF specific debugfs directory creation

Arend van Spriel (2):
      brcmfmac: decrement pending 8021x count upon tx failure
      brcmfmac: bail out of brcmf_txflowblock_if() for non-netdev interface

Chun-Yeow Yeoh (1):
      nl80211: fix the setting of RSSI threshold value for mesh

Daniel Drake (1):
      mwifiex: fix IRQ enable/disable

David Spinadel (2):
      iwlwifi: mvm: fix bug in scan ssid
      iwlwifi: mvm: remove extra SSID from probe request

Emmanuel Grumbach (3):
      iwlwifi: mvm: unregister leds when registration failed
      iwlwifi: mvm: fix L2P BA ressources leak
      iwlwifi: mvm: track the number of Rx BA sessions

Felix Fietkau (2):
      mac80211/minstrel_ht: fix cck rate sampling
      mac80211/minstrel: fix NULL pointer dereference issue

Johannes Berg (6):
      cfg80211: fix bugs in new SME implementation
      regulatory: add missing rtnl locking
      mac80211: fix ethtool stats for non-station interfaces
      mac80211: fix duplicate retransmission detection
      iwlwifi: dvm: don't send BT_CONFIG on devices w/o Bluetooth
      iwlwifi: mvm: refuse connection to APs with BI < 16

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      ath: wil6210: Fix build error

Michal Kazior (1):
      nl80211: fix mgmt tx status and testmode reporting for netns

Oleksij Rempel (2):
      ath9k_htc: do some initial hardware configuration
      ath9k_htc: reboot firmware if it was loaded

Solomon Peachy (1):
      cw1200: Fix OOPS in monitor mode

 drivers/net/wireless/ath/ath9k/hif_usb.c           |  4 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |  1 +
 drivers/net/wireless/ath/wil6210/debugfs.c         |  4 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |  8 +-
 drivers/net/wireless/cw1200/txrx.c                 |  2 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |  2 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  6 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        | 23 +++++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  1 +
 drivers/net/wireless/iwlwifi/mvm/scan.c            | 10 ++-
 drivers/net/wireless/iwlwifi/mvm/sta.c             | 23 +++++-
 drivers/net/wireless/mwifiex/init.c                | 10 +--
 drivers/net/wireless/mwifiex/main.c                | 13 +++-
 drivers/net/wireless/mwifiex/main.h                |  1 +
 drivers/net/wireless/mwifiex/sdio.c                | 91 ++++++++++--------=
----
 drivers/net/wireless/mwifiex/sdio.h                |  3 -
 net/mac80211/cfg.c                                 |  2 +
 net/mac80211/rc80211_minstrel.c                    |  3 +-
 net/mac80211/rc80211_minstrel_ht.c                 | 10 ++-
 net/mac80211/rx.c                                  | 10 ++-
 net/wireless/nl80211.c                             | 11 ++-
 net/wireless/reg.c                                 |  2 +
 net/wireless/sme.c                                 | 29 ++++++-
 24 files changed, 184 insertions(+), 87 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireles=
s/ath/ath9k/hif_usb.c
index 2469db5..5205a36 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -1295,7 +1295,9 @@ static void ath9k_hif_usb_disconnect(struct usb_inter=
face *interface)
=20
 	usb_set_intfdata(interface, NULL);
=20
-	if (!unplugged && (hif_dev->flags & HIF_USB_START))
+	/* If firmware was loaded we should drop it
+	 * go back to first stage bootloader. */
+	if (!unplugged && (hif_dev->flags & HIF_USB_READY))
 		ath9k_hif_usb_reboot(udev);
=20
 	kfree(hif_dev);
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wi=
reless/ath/ath9k/htc_drv_init.c
index 71a183f..c3676bf 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -861,6 +861,7 @@ static int ath9k_init_device(struct ath9k_htc_priv *pri=
v,
 	if (error !=3D 0)
 		goto err_rx;
=20
+	ath9k_hw_disable(priv->ah);
 #ifdef CONFIG_MAC80211_LEDS
 	/* must be initialized before ieee80211_register_hw */
 	priv->led_cdev.default_trigger =3D ieee80211_create_tpt_led_trigger(priv-=
>hw,
diff --git a/drivers/net/wireless/ath/wil6210/debugfs.c b/drivers/net/wirel=
ess/ath/wil6210/debugfs.c
index e8308ec..ab63676 100644
--- a/drivers/net/wireless/ath/wil6210/debugfs.c
+++ b/drivers/net/wireless/ath/wil6210/debugfs.c
@@ -145,7 +145,7 @@ static void wil_print_ring(struct seq_file *s, const ch=
ar *prefix,
 				   le16_to_cpu(hdr.type), hdr.flags);
 			if (len <=3D MAX_MBOXITEM_SIZE) {
 				int n =3D 0;
-				unsigned char printbuf[16 * 3 + 2];
+				char printbuf[16 * 3 + 2];
 				unsigned char databuf[MAX_MBOXITEM_SIZE];
 				void __iomem *src =3D wmi_buffer(wil, d.addr) +
 					sizeof(struct wil6210_mbox_hdr);
@@ -416,7 +416,7 @@ static int wil_txdesc_debugfs_show(struct seq_file *s, =
void *data)
 		seq_printf(s, "  SKB =3D %p\n", skb);
=20
 		if (skb) {
-			unsigned char printbuf[16 * 3 + 2];
+			char printbuf[16 * 3 + 2];
 			int i =3D 0;
 			int len =3D le16_to_cpu(d->dma.length);
 			void *p =3D skb->data;
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/=
net/wireless/brcm80211/brcmfmac/dhd_linux.c
index 8e89755..8009901 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -242,7 +242,7 @@ void brcmf_txflowblock_if(struct brcmf_if *ifp,
 {
 	unsigned long flags;
=20
-	if (!ifp)
+	if (!ifp || !ifp->ndev)
 		return;
=20
 	brcmf_dbg(TRACE, "enter: idx=3D%d stop=3D0x%X reason=3D%d state=3D%d\n",
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c b/drivers/n=
et/wireless/brcm80211/brcmfmac/fwsignal.c
index f0d9f7f..29b1f24 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
@@ -1744,13 +1744,14 @@ int brcmf_fws_process_skb(struct brcmf_if *ifp, str=
uct sk_buff *skb)
 	ulong flags;
 	int fifo =3D BRCMF_FWS_FIFO_BCMC;
 	bool multicast =3D is_multicast_ether_addr(eh->h_dest);
+	bool pae =3D eh->h_proto =3D=3D htons(ETH_P_PAE);
=20
 	/* determine the priority */
 	if (!skb->priority)
 		skb->priority =3D cfg80211_classify8021d(skb);
=20
 	drvr->tx_multicast +=3D !!multicast;
-	if (ntohs(eh->h_proto) =3D=3D ETH_P_PAE)
+	if (pae)
 		atomic_inc(&ifp->pend_8021x_cnt);
=20
 	if (!brcmf_fws_fc_active(fws)) {
@@ -1781,6 +1782,11 @@ int brcmf_fws_process_skb(struct brcmf_if *ifp, stru=
ct sk_buff *skb)
 		brcmf_fws_schedule_deq(fws);
 	} else {
 		brcmf_err("drop skb: no hanger slot\n");
+		if (pae) {
+			atomic_dec(&ifp->pend_8021x_cnt);
+			if (waitqueue_active(&ifp->pend_8021x_wait))
+				wake_up(&ifp->pend_8021x_wait);
+		}
 		brcmu_pkt_buf_free_skb(skb);
 	}
 	brcmf_fws_unlock(drvr, flags);
diff --git a/drivers/net/wireless/cw1200/txrx.c b/drivers/net/wireless/cw12=
00/txrx.c
index 5862c37..e824d4d 100644
--- a/drivers/net/wireless/cw1200/txrx.c
+++ b/drivers/net/wireless/cw1200/txrx.c
@@ -1165,7 +1165,7 @@ void cw1200_rx_cb(struct cw1200_common *priv,
 		if (cw1200_handle_action_rx(priv, skb))
 			return;
 	} else if (ieee80211_is_beacon(frame->frame_control) &&
-		   !arg->status &&
+		   !arg->status && priv->vif &&
 		   !memcmp(ieee80211_get_SA(frame), priv->vif->bss_conf.bssid,
 			   ETH_ALEN)) {
 		const u8 *tim_ie;
diff --git a/drivers/net/wireless/iwlwifi/dvm/main.c b/drivers/net/wireless=
/iwlwifi/dvm/main.c
index 3952ddf..1531a4f 100644
--- a/drivers/net/wireless/iwlwifi/dvm/main.c
+++ b/drivers/net/wireless/iwlwifi/dvm/main.c
@@ -758,7 +758,7 @@ int iwl_alive_start(struct iwl_priv *priv)
 					 BT_COEX_PRIO_TBL_EVT_INIT_CALIB2);
 		if (ret)
 			return ret;
-	} else {
+	} else if (priv->lib->bt_params) {
 		/*
 		 * default is 2-wire BT coexexistence support
 		 */
diff --git a/drivers/net/wireless/iwlwifi/mvm/debugfs.c b/drivers/net/wirel=
ess/iwlwifi/mvm/debugfs.c
index e56ed2a..c24a744 100644
--- a/drivers/net/wireless/iwlwifi/mvm/debugfs.c
+++ b/drivers/net/wireless/iwlwifi/mvm/debugfs.c
@@ -988,7 +988,11 @@ void iwl_mvm_vif_dbgfs_register(struct iwl_mvm *mvm, s=
truct ieee80211_vif *vif)
 	struct iwl_mvm_vif *mvmvif =3D iwl_mvm_vif_from_mac80211(vif);
 	char buf[100];
=20
-	if (!dbgfs_dir)
+	/*
+	 * Check if debugfs directory already exist before creating it.
+	 * This may happen when, for example, resetting hw or suspend-resume
+	 */
+	if (!dbgfs_dir || mvmvif->dbgfs_dir)
 		return;
=20
 	mvmvif->dbgfs_dir =3D debugfs_create_dir("iwlmvm", dbgfs_dir);
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index e08683b..1eedc42 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -257,7 +257,11 @@ int iwl_mvm_mac_setup_register(struct iwl_mvm *mvm)
 	if (ret)
 		return ret;
=20
-	return ieee80211_register_hw(mvm->hw);
+	ret =3D ieee80211_register_hw(mvm->hw);
+	if (ret)
+		iwl_mvm_leds_exit(mvm);
+
+	return ret;
 }
=20
 static void iwl_mvm_mac_tx(struct ieee80211_hw *hw,
@@ -385,6 +389,7 @@ static void iwl_mvm_restart_cleanup(struct iwl_mvm *mvm)
 	ieee80211_wake_queues(mvm->hw);
=20
 	mvm->vif_count =3D 0;
+	mvm->rx_ba_sessions =3D 0;
 }
=20
 static int iwl_mvm_mac_start(struct ieee80211_hw *hw)
@@ -1006,6 +1011,21 @@ static int iwl_mvm_mac_sta_state(struct ieee80211_hw=
 *hw,
 	mutex_lock(&mvm->mutex);
 	if (old_state =3D=3D IEEE80211_STA_NOTEXIST &&
 	    new_state =3D=3D IEEE80211_STA_NONE) {
+		/*
+		 * Firmware bug - it'll crash if the beacon interval is less
+		 * than 16. We can't avoid connecting at all, so refuse the
+		 * station state change, this will cause mac80211 to abandon
+		 * attempts to connect to this AP, and eventually wpa_s will
+		 * blacklist the AP...
+		 */
+		if (vif->type =3D=3D NL80211_IFTYPE_STATION &&
+		    vif->bss_conf.beacon_int < 16) {
+			IWL_ERR(mvm,
+				"AP %pM beacon interval is %d, refusing due to firmware bug!\n",
+				sta->addr, vif->bss_conf.beacon_int);
+			ret =3D -EINVAL;
+			goto out_unlock;
+		}
 		ret =3D iwl_mvm_add_sta(mvm, vif, sta);
 	} else if (old_state =3D=3D IEEE80211_STA_NONE &&
 		   new_state =3D=3D IEEE80211_STA_AUTH) {
@@ -1038,6 +1058,7 @@ static int iwl_mvm_mac_sta_state(struct ieee80211_hw =
*hw,
 	} else {
 		ret =3D -EIO;
 	}
+ out_unlock:
 	mutex_unlock(&mvm->mutex);
=20
 	return ret;
diff --git a/drivers/net/wireless/iwlwifi/mvm/mvm.h b/drivers/net/wireless/=
iwlwifi/mvm/mvm.h
index d40d7db..420e82d 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mvm.h
+++ b/drivers/net/wireless/iwlwifi/mvm/mvm.h
@@ -419,6 +419,7 @@ struct iwl_mvm {
 	struct work_struct sta_drained_wk;
 	unsigned long sta_drained[BITS_TO_LONGS(IWL_MVM_STATION_COUNT)];
 	atomic_t pending_frames[IWL_MVM_STATION_COUNT];
+	u8 rx_ba_sessions;
=20
 	/* configured by mac80211 */
 	u32 rts_threshold;
diff --git a/drivers/net/wireless/iwlwifi/mvm/scan.c b/drivers/net/wireless=
/iwlwifi/mvm/scan.c
index 2157b0f..268f027 100644
--- a/drivers/net/wireless/iwlwifi/mvm/scan.c
+++ b/drivers/net/wireless/iwlwifi/mvm/scan.c
@@ -137,8 +137,8 @@ static void iwl_mvm_scan_fill_ssids(struct iwl_scan_cmd=
 *cmd,
 {
 	int fw_idx, req_idx;
=20
-	fw_idx =3D 0;
-	for (req_idx =3D req->n_ssids - 1; req_idx > 0; req_idx--) {
+	for (req_idx =3D req->n_ssids - 1, fw_idx =3D 0; req_idx > 0;
+	     req_idx--, fw_idx++) {
 		cmd->direct_scan[fw_idx].id =3D WLAN_EID_SSID;
 		cmd->direct_scan[fw_idx].len =3D req->ssids[req_idx].ssid_len;
 		memcpy(cmd->direct_scan[fw_idx].ssid,
@@ -153,7 +153,9 @@ static void iwl_mvm_scan_fill_ssids(struct iwl_scan_cmd=
 *cmd,
  * just to notify that this scan is active and not passive.
  * In order to notify the FW of the number of SSIDs we wish to scan (inclu=
ding
  * the zero-length one), we need to set the corresponding bits in chan->ty=
pe,
- * one for each SSID, and set the active bit (first).
+ * one for each SSID, and set the active bit (first). The first SSID is al=
ready
+ * included in the probe template, so we need to set only req->n_ssids - 1=
 bits
+ * in addition to the first bit.
  */
 static u16 iwl_mvm_get_active_dwell(enum ieee80211_band band, int n_ssids)
 {
@@ -179,7 +181,7 @@ static void iwl_mvm_scan_fill_channels(struct iwl_scan_=
cmd *cmd,
 	__le32 chan_type_value;
=20
 	if (req->n_ssids > 0)
-		chan_type_value =3D cpu_to_le32(BIT(req->n_ssids + 1) - 1);
+		chan_type_value =3D cpu_to_le32(BIT(req->n_ssids) - 1);
 	else
 		chan_type_value =3D SCAN_CHANNEL_TYPE_PASSIVE;
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/sta.c b/drivers/net/wireless/=
iwlwifi/mvm/sta.c
index 62fe520..85d4bbe 100644
--- a/drivers/net/wireless/iwlwifi/mvm/sta.c
+++ b/drivers/net/wireless/iwlwifi/mvm/sta.c
@@ -608,6 +608,8 @@ int iwl_mvm_rm_bcast_sta(struct iwl_mvm *mvm, struct iw=
l_mvm_int_sta *bsta)
 	return ret;
 }
=20
+#define IWL_MAX_RX_BA_SESSIONS 16
+
 int iwl_mvm_sta_rx_agg(struct iwl_mvm *mvm, struct ieee80211_sta *sta,
 		       int tid, u16 ssn, bool start)
 {
@@ -618,11 +620,20 @@ int iwl_mvm_sta_rx_agg(struct iwl_mvm *mvm, struct ie=
ee80211_sta *sta,
=20
 	lockdep_assert_held(&mvm->mutex);
=20
+	if (start && mvm->rx_ba_sessions >=3D IWL_MAX_RX_BA_SESSIONS) {
+		IWL_WARN(mvm, "Not enough RX BA SESSIONS\n");
+		return -ENOSPC;
+	}
+
 	cmd.mac_id_n_color =3D cpu_to_le32(mvm_sta->mac_id_n_color);
 	cmd.sta_id =3D mvm_sta->sta_id;
 	cmd.add_modify =3D STA_MODE_MODIFY;
-	cmd.add_immediate_ba_tid =3D (u8) tid;
-	cmd.add_immediate_ba_ssn =3D cpu_to_le16(ssn);
+	if (start) {
+		cmd.add_immediate_ba_tid =3D (u8) tid;
+		cmd.add_immediate_ba_ssn =3D cpu_to_le16(ssn);
+	} else {
+		cmd.remove_immediate_ba_tid =3D (u8) tid;
+	}
 	cmd.modify_mask =3D start ? STA_MODIFY_ADD_BA_TID :
 				  STA_MODIFY_REMOVE_BA_TID;
=20
@@ -648,6 +659,14 @@ int iwl_mvm_sta_rx_agg(struct iwl_mvm *mvm, struct iee=
e80211_sta *sta,
 		break;
 	}
=20
+	if (!ret) {
+		if (start)
+			mvm->rx_ba_sessions++;
+		else if (mvm->rx_ba_sessions > 0)
+			/* check that restart flow didn't zero the counter */
+			mvm->rx_ba_sessions--;
+	}
+
 	return ret;
 }
=20
diff --git a/drivers/net/wireless/mwifiex/init.c b/drivers/net/wireless/mwi=
fiex/init.c
index caaf4bd..2cf8b96 100644
--- a/drivers/net/wireless/mwifiex/init.c
+++ b/drivers/net/wireless/mwifiex/init.c
@@ -693,7 +693,7 @@ int mwifiex_dnld_fw(struct mwifiex_adapter *adapter,
 		if (!ret) {
 			dev_notice(adapter->dev,
 				   "WLAN FW already running! Skip FW dnld\n");
-			goto done;
+			return 0;
 		}
=20
 		poll_num =3D MAX_FIRMWARE_POLL_TRIES;
@@ -719,14 +719,8 @@ int mwifiex_dnld_fw(struct mwifiex_adapter *adapter,
 poll_fw:
 	/* Check if the firmware is downloaded successfully or not */
 	ret =3D adapter->if_ops.check_fw_status(adapter, poll_num);
-	if (ret) {
+	if (ret)
 		dev_err(adapter->dev, "FW failed to be active in time\n");
-		return -1;
-	}
-done:
-	/* re-enable host interrupt for mwifiex after fw dnld is successful */
-	if (adapter->if_ops.enable_int)
-		adapter->if_ops.enable_int(adapter);
=20
 	return ret;
 }
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwi=
fiex/main.c
index e15ab72..1753431 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -427,6 +427,10 @@ static void mwifiex_fw_dpc(const struct firmware *firm=
ware, void *context)
 				"Cal data request_firmware() failed\n");
 	}
=20
+	/* enable host interrupt after fw dnld is successful */
+	if (adapter->if_ops.enable_int)
+		adapter->if_ops.enable_int(adapter);
+
 	adapter->init_wait_q_woken =3D false;
 	ret =3D mwifiex_init_fw(adapter);
 	if (ret =3D=3D -1) {
@@ -478,6 +482,8 @@ err_add_intf:
 	mwifiex_del_virtual_intf(adapter->wiphy, priv->wdev);
 	rtnl_unlock();
 err_init_fw:
+	if (adapter->if_ops.disable_int)
+		adapter->if_ops.disable_int(adapter);
 	pr_debug("info: %s: unregister device\n", __func__);
 	adapter->if_ops.unregister_dev(adapter);
 done:
@@ -855,7 +861,7 @@ mwifiex_add_card(void *card, struct semaphore *sem,
 	INIT_WORK(&adapter->main_work, mwifiex_main_work_queue);
=20
 	/* Register the device. Fill up the private data structure with relevant
-	   information from the card and request for the required IRQ. */
+	   information from the card. */
 	if (adapter->if_ops.register_dev(adapter)) {
 		pr_err("%s: failed to register mwifiex device\n", __func__);
 		goto err_registerdev;
@@ -919,6 +925,11 @@ int mwifiex_remove_card(struct mwifiex_adapter *adapte=
r, struct semaphore *sem)
 	if (!adapter)
 		goto exit_remove;
=20
+	/* We can no longer handle interrupts once we start doing the teardown
+	 * below. */
+	if (adapter->if_ops.disable_int)
+		adapter->if_ops.disable_int(adapter);
+
 	adapter->surprise_removed =3D true;
=20
 	/* Stop data */
diff --git a/drivers/net/wireless/mwifiex/main.h b/drivers/net/wireless/mwi=
fiex/main.h
index 3da73d3..253e0bd 100644
--- a/drivers/net/wireless/mwifiex/main.h
+++ b/drivers/net/wireless/mwifiex/main.h
@@ -601,6 +601,7 @@ struct mwifiex_if_ops {
 	int (*register_dev) (struct mwifiex_adapter *);
 	void (*unregister_dev) (struct mwifiex_adapter *);
 	int (*enable_int) (struct mwifiex_adapter *);
+	void (*disable_int) (struct mwifiex_adapter *);
 	int (*process_int_status) (struct mwifiex_adapter *);
 	int (*host_to_card) (struct mwifiex_adapter *, u8, struct sk_buff *,
 			     struct mwifiex_tx_param *);
diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/mwi=
fiex/sdio.c
index 5ee5ed0..5ef49f2 100644
--- a/drivers/net/wireless/mwifiex/sdio.c
+++ b/drivers/net/wireless/mwifiex/sdio.c
@@ -51,6 +51,7 @@ static struct mwifiex_if_ops sdio_ops;
 static struct semaphore add_remove_card_sem;
=20
 static int mwifiex_sdio_resume(struct device *dev);
+static void mwifiex_sdio_interrupt(struct sdio_func *func);
=20
 /*
  * SDIO probe.
@@ -296,6 +297,15 @@ static struct sdio_driver mwifiex_sdio =3D {
 	}
 };
=20
+/* Write data into SDIO card register. Caller claims SDIO device. */
+static int
+mwifiex_write_reg_locked(struct sdio_func *func, u32 reg, u8 data)
+{
+	int ret =3D -1;
+	sdio_writeb(func, data, reg, &ret);
+	return ret;
+}
+
 /*
  * This function writes data into SDIO card register.
  */
@@ -303,10 +313,10 @@ static int
 mwifiex_write_reg(struct mwifiex_adapter *adapter, u32 reg, u8 data)
 {
 	struct sdio_mmc_card *card =3D adapter->card;
-	int ret =3D -1;
+	int ret;
=20
 	sdio_claim_host(card->func);
-	sdio_writeb(card->func, data, reg, &ret);
+	ret =3D mwifiex_write_reg_locked(card->func, reg, data);
 	sdio_release_host(card->func);
=20
 	return ret;
@@ -685,23 +695,15 @@ mwifiex_sdio_read_fw_status(struct mwifiex_adapter *a=
dapter, u16 *dat)
  * The host interrupt mask is read, the disable bit is reset and
  * written back to the card host interrupt mask register.
  */
-static int mwifiex_sdio_disable_host_int(struct mwifiex_adapter *adapter)
+static void mwifiex_sdio_disable_host_int(struct mwifiex_adapter *adapter)
 {
-	u8 host_int_mask, host_int_disable =3D HOST_INT_DISABLE;
-
-	/* Read back the host_int_mask register */
-	if (mwifiex_read_reg(adapter, HOST_INT_MASK_REG, &host_int_mask))
-		return -1;
-
-	/* Update with the mask and write back to the register */
-	host_int_mask &=3D ~host_int_disable;
-
-	if (mwifiex_write_reg(adapter, HOST_INT_MASK_REG, host_int_mask)) {
-		dev_err(adapter->dev, "disable host interrupt failed\n");
-		return -1;
-	}
+	struct sdio_mmc_card *card =3D adapter->card;
+	struct sdio_func *func =3D card->func;
=20
-	return 0;
+	sdio_claim_host(func);
+	mwifiex_write_reg_locked(func, HOST_INT_MASK_REG, 0);
+	sdio_release_irq(func);
+	sdio_release_host(func);
 }
=20
 /*
@@ -713,14 +715,29 @@ static int mwifiex_sdio_disable_host_int(struct mwifi=
ex_adapter *adapter)
 static int mwifiex_sdio_enable_host_int(struct mwifiex_adapter *adapter)
 {
 	struct sdio_mmc_card *card =3D adapter->card;
+	struct sdio_func *func =3D card->func;
+	int ret;
+
+	sdio_claim_host(func);
+
+	/* Request the SDIO IRQ */
+	ret =3D sdio_claim_irq(func, mwifiex_sdio_interrupt);
+	if (ret) {
+		dev_err(adapter->dev, "claim irq failed: ret=3D%d\n", ret);
+		goto out;
+	}
=20
 	/* Simply write the mask to the register */
-	if (mwifiex_write_reg(adapter, HOST_INT_MASK_REG,
-			      card->reg->host_int_enable)) {
+	ret =3D mwifiex_write_reg_locked(func, HOST_INT_MASK_REG,
+				       card->reg->host_int_enable);
+	if (ret) {
 		dev_err(adapter->dev, "enable host interrupt failed\n");
-		return -1;
+		sdio_release_irq(func);
 	}
-	return 0;
+
+out:
+	sdio_release_host(func);
+	return ret;
 }
=20
 /*
@@ -997,9 +1014,6 @@ mwifiex_sdio_interrupt(struct sdio_func *func)
 	}
 	adapter =3D card->adapter;
=20
-	if (adapter->surprise_removed)
-		return;
-
 	if (!adapter->pps_uapsd_mode && adapter->ps_state =3D=3D PS_STATE_SLEEP)
 		adapter->ps_state =3D PS_STATE_AWAKE;
=20
@@ -1728,9 +1742,7 @@ mwifiex_unregister_dev(struct mwifiex_adapter *adapte=
r)
 	struct sdio_mmc_card *card =3D adapter->card;
=20
 	if (adapter->card) {
-		/* Release the SDIO IRQ */
 		sdio_claim_host(card->func);
-		sdio_release_irq(card->func);
 		sdio_disable_func(card->func);
 		sdio_release_host(card->func);
 		sdio_set_drvdata(card->func, NULL);
@@ -1744,7 +1756,7 @@ mwifiex_unregister_dev(struct mwifiex_adapter *adapte=
r)
  */
 static int mwifiex_register_dev(struct mwifiex_adapter *adapter)
 {
-	int ret =3D 0;
+	int ret;
 	struct sdio_mmc_card *card =3D adapter->card;
 	struct sdio_func *func =3D card->func;
=20
@@ -1753,22 +1765,14 @@ static int mwifiex_register_dev(struct mwifiex_adap=
ter *adapter)
=20
 	sdio_claim_host(func);
=20
-	/* Request the SDIO IRQ */
-	ret =3D sdio_claim_irq(func, mwifiex_sdio_interrupt);
-	if (ret) {
-		pr_err("claim irq failed: ret=3D%d\n", ret);
-		goto disable_func;
-	}
-
 	/* Set block size */
 	ret =3D sdio_set_block_size(card->func, MWIFIEX_SDIO_BLOCK_SIZE);
+	sdio_release_host(func);
 	if (ret) {
 		pr_err("cannot set SDIO block size\n");
-		ret =3D -1;
-		goto release_irq;
+		return ret;
 	}
=20
-	sdio_release_host(func);
 	sdio_set_drvdata(func, card);
=20
 	adapter->dev =3D &func->dev;
@@ -1776,15 +1780,6 @@ static int mwifiex_register_dev(struct mwifiex_adapt=
er *adapter)
 	strcpy(adapter->fw_name, card->firmware);
=20
 	return 0;
-
-release_irq:
-	sdio_release_irq(func);
-disable_func:
-	sdio_disable_func(func);
-	sdio_release_host(func);
-	adapter->card =3D NULL;
-
-	return -1;
 }
=20
 /*
@@ -1813,9 +1808,6 @@ static int mwifiex_init_sdio(struct mwifiex_adapter *=
adapter)
 	 */
 	mwifiex_read_reg(adapter, HOST_INTSTATUS_REG, &sdio_ireg);
=20
-	/* Disable host interrupt mask register for SDIO */
-	mwifiex_sdio_disable_host_int(adapter);
-
 	/* Get SDIO ioport */
 	mwifiex_init_sdio_ioport(adapter);
=20
@@ -1957,6 +1949,7 @@ static struct mwifiex_if_ops sdio_ops =3D {
 	.register_dev =3D mwifiex_register_dev,
 	.unregister_dev =3D mwifiex_unregister_dev,
 	.enable_int =3D mwifiex_sdio_enable_host_int,
+	.disable_int =3D mwifiex_sdio_disable_host_int,
 	.process_int_status =3D mwifiex_process_int_status,
 	.host_to_card =3D mwifiex_sdio_host_to_card,
 	.wakeup =3D mwifiex_pm_wakeup_card,
diff --git a/drivers/net/wireless/mwifiex/sdio.h b/drivers/net/wireless/mwi=
fiex/sdio.h
index 6d51dfd..532ae0a 100644
--- a/drivers/net/wireless/mwifiex/sdio.h
+++ b/drivers/net/wireless/mwifiex/sdio.h
@@ -92,9 +92,6 @@
 /* Host Control Registers : Download host interrupt mask */
 #define DN_LD_HOST_INT_MASK		(0x2U)
=20
-/* Disable Host interrupt mask */
-#define	HOST_INT_DISABLE		0xff
-
 /* Host Control Registers : Host interrupt status */
 #define HOST_INTSTATUS_REG		0x03
 /* Host Control Registers : Upload host interrupt status */
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 8184d12..43dd752 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -666,6 +666,8 @@ static void ieee80211_get_et_stats(struct wiphy *wiphy,
 			if (sta->sdata->dev !=3D dev)
 				continue;
=20
+			sinfo.filled =3D 0;
+			sta_set_sinfo(sta, &sinfo);
 			i =3D 0;
 			ADD_STA_STATS(sta);
 		}
diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstre=
l.c
index ac7ef54..e6512e2 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -290,7 +290,7 @@ minstrel_get_rate(void *priv, struct ieee80211_sta *sta,
 	struct minstrel_rate *msr, *mr;
 	unsigned int ndx;
 	bool mrr_capable;
-	bool prev_sample =3D mi->prev_sample;
+	bool prev_sample;
 	int delta;
 	int sampling_ratio;
=20
@@ -314,6 +314,7 @@ minstrel_get_rate(void *priv, struct ieee80211_sta *sta,
 			(mi->sample_count + mi->sample_deferred / 2);
=20
 	/* delta < 0: no sampling required */
+	prev_sample =3D mi->prev_sample;
 	mi->prev_sample =3D false;
 	if (delta < 0 || (!mrr_capable && prev_sample))
 		return;
diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_mins=
trel_ht.c
index 5b2d301..f5aed96 100644
--- a/net/mac80211/rc80211_minstrel_ht.c
+++ b/net/mac80211/rc80211_minstrel_ht.c
@@ -804,10 +804,18 @@ minstrel_ht_get_rate(void *priv, struct ieee80211_sta=
 *sta, void *priv_sta,
=20
 	sample_group =3D &minstrel_mcs_groups[sample_idx / MCS_GROUP_RATES];
 	info->flags |=3D IEEE80211_TX_CTL_RATE_CTRL_PROBE;
+	rate->count =3D 1;
+
+	if (sample_idx / MCS_GROUP_RATES =3D=3D MINSTREL_CCK_GROUP) {
+		int idx =3D sample_idx % ARRAY_SIZE(mp->cck_rates);
+		rate->idx =3D mp->cck_rates[idx];
+		rate->flags =3D 0;
+		return;
+	}
+
 	rate->idx =3D sample_idx % MCS_GROUP_RATES +
 		    (sample_group->streams - 1) * MCS_GROUP_RATES;
 	rate->flags =3D IEEE80211_TX_RC_MCS | sample_group->flags;
-	rate->count =3D 1;
 }
=20
 static void
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 23dbcfc..2c5a79b 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -936,8 +936,14 @@ ieee80211_rx_h_check(struct ieee80211_rx_data *rx)
 	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *)rx->skb->data;
 	struct ieee80211_rx_status *status =3D IEEE80211_SKB_RXCB(rx->skb);
=20
-	/* Drop duplicate 802.11 retransmissions (IEEE 802.11 Chap. 9.2.9) */
-	if (rx->sta && !is_multicast_ether_addr(hdr->addr1)) {
+	/*
+	 * Drop duplicate 802.11 retransmissions
+	 * (IEEE 802.11-2012: 9.3.2.10 "Duplicate detection and recovery")
+	 */
+	if (rx->skb->len >=3D 24 && rx->sta &&
+	    !ieee80211_is_ctl(hdr->frame_control) &&
+	    !ieee80211_is_qos_nullfunc(hdr->frame_control) &&
+	    !is_multicast_ether_addr(hdr->addr1)) {
 		if (unlikely(ieee80211_has_retry(hdr->frame_control) &&
 			     rx->sta->last_seq_ctrl[rx->seqno_idx] =3D=3D
 			     hdr->seq_ctrl)) {
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 1cc47ac..25d217d 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -4770,9 +4770,9 @@ do {									    \
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshForwarding, 0, 1,
 				  mask, NL80211_MESHCONF_FORWARDING,
 				  nla_get_u8);
-	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, rssi_threshold, 1, 255,
+	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, rssi_threshold, -255, 0,
 				  mask, NL80211_MESHCONF_RSSI_THRESHOLD,
-				  nla_get_u32);
+				  nla_get_s32);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, ht_opmode, 0, 16,
 				  mask, NL80211_MESHCONF_HT_OPMODE,
 				  nla_get_u16);
@@ -6613,12 +6613,14 @@ EXPORT_SYMBOL(cfg80211_testmode_alloc_event_skb);
=20
 void cfg80211_testmode_event(struct sk_buff *skb, gfp_t gfp)
 {
+	struct cfg80211_registered_device *rdev =3D ((void **)skb->cb)[0];
 	void *hdr =3D ((void **)skb->cb)[1];
 	struct nlattr *data =3D ((void **)skb->cb)[2];
=20
 	nla_nest_end(skb, data);
 	genlmsg_end(skb, hdr);
-	genlmsg_multicast(skb, 0, nl80211_testmode_mcgrp.id, gfp);
+	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), skb, 0,
+				nl80211_testmode_mcgrp.id, gfp);
 }
 EXPORT_SYMBOL(cfg80211_testmode_event);
 #endif
@@ -10064,7 +10066,8 @@ void cfg80211_mgmt_tx_status(struct wireless_dev *w=
dev, u64 cookie,
=20
 	genlmsg_end(msg, hdr);
=20
-	genlmsg_multicast(msg, 0, nl80211_mlme_mcgrp.id, gfp);
+	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+				nl80211_mlme_mcgrp.id, gfp);
 	return;
=20
  nla_put_failure:
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 5a24c98..5a950f3 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -2279,7 +2279,9 @@ void wiphy_regulatory_deregister(struct wiphy *wiphy)
 static void reg_timeout_work(struct work_struct *work)
 {
 	REG_DBG_PRINT("Timeout while waiting for CRDA to reply, restoring regulat=
ory settings\n");
+	rtnl_lock();
 	restore_regulatory_settings(true);
+	rtnl_unlock();
 }
=20
 int __init regulatory_init(void)
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index 1d3cfb1..81c8a10 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -34,8 +34,10 @@ struct cfg80211_conn {
 		CFG80211_CONN_SCAN_AGAIN,
 		CFG80211_CONN_AUTHENTICATE_NEXT,
 		CFG80211_CONN_AUTHENTICATING,
+		CFG80211_CONN_AUTH_FAILED,
 		CFG80211_CONN_ASSOCIATE_NEXT,
 		CFG80211_CONN_ASSOCIATING,
+		CFG80211_CONN_ASSOC_FAILED,
 		CFG80211_CONN_DEAUTH,
 		CFG80211_CONN_CONNECTED,
 	} state;
@@ -164,6 +166,8 @@ static int cfg80211_conn_do_work(struct wireless_dev *w=
dev)
 					  NULL, 0,
 					  params->key, params->key_len,
 					  params->key_idx, NULL, 0);
+	case CFG80211_CONN_AUTH_FAILED:
+		return -ENOTCONN;
 	case CFG80211_CONN_ASSOCIATE_NEXT:
 		BUG_ON(!rdev->ops->assoc);
 		wdev->conn->state =3D CFG80211_CONN_ASSOCIATING;
@@ -188,10 +192,17 @@ static int cfg80211_conn_do_work(struct wireless_dev =
*wdev)
 					     WLAN_REASON_DEAUTH_LEAVING,
 					     false);
 		return err;
+	case CFG80211_CONN_ASSOC_FAILED:
+		cfg80211_mlme_deauth(rdev, wdev->netdev, params->bssid,
+				     NULL, 0,
+				     WLAN_REASON_DEAUTH_LEAVING, false);
+		return -ENOTCONN;
 	case CFG80211_CONN_DEAUTH:
 		cfg80211_mlme_deauth(rdev, wdev->netdev, params->bssid,
 				     NULL, 0,
 				     WLAN_REASON_DEAUTH_LEAVING, false);
+		/* free directly, disconnected event already sent */
+		cfg80211_sme_free(wdev);
 		return 0;
 	default:
 		return 0;
@@ -371,7 +382,7 @@ bool cfg80211_sme_rx_assoc_resp(struct wireless_dev *wd=
ev, u16 status)
 		return true;
 	}
=20
-	wdev->conn->state =3D CFG80211_CONN_DEAUTH;
+	wdev->conn->state =3D CFG80211_CONN_ASSOC_FAILED;
 	schedule_work(&rdev->conn_work);
 	return false;
 }
@@ -383,7 +394,13 @@ void cfg80211_sme_deauth(struct wireless_dev *wdev)
=20
 void cfg80211_sme_auth_timeout(struct wireless_dev *wdev)
 {
-	cfg80211_sme_free(wdev);
+	struct cfg80211_registered_device *rdev =3D wiphy_to_dev(wdev->wiphy);
+
+	if (!wdev->conn)
+		return;
+
+	wdev->conn->state =3D CFG80211_CONN_AUTH_FAILED;
+	schedule_work(&rdev->conn_work);
 }
=20
 void cfg80211_sme_disassoc(struct wireless_dev *wdev)
@@ -399,7 +416,13 @@ void cfg80211_sme_disassoc(struct wireless_dev *wdev)
=20
 void cfg80211_sme_assoc_timeout(struct wireless_dev *wdev)
 {
-	cfg80211_sme_disassoc(wdev);
+	struct cfg80211_registered_device *rdev =3D wiphy_to_dev(wdev->wiphy);
+
+	if (!wdev->conn)
+		return;
+
+	wdev->conn->state =3D CFG80211_CONN_ASSOC_FAILED;
+	schedule_work(&rdev->conn_work);
 }
=20
 static int cfg80211_sme_connect(struct wireless_dev *wdev,
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--r5Pyd7+fXNt84Ff3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJR8BcQAAoJEJctW/TcYTgG3lQP/2Da1DKSLz6VcIp5uVSMAkV+
2zyj+AH9BpafFR8Ba8mqlnO0h0uh/5Xrne1XtPN72ShGGpF3VtfKK1W5dAZU11+f
F6TmTln+BC5AxXjx6/kB7Byc0xl8kj+6EeMwK6onAN5+OzCJYxWGpOBb/DLGk8lS
sUp0kGV5D5hcvKJeFNV91kQfezwHbBvNukjatZapZwvUJhaxEAiePgII1oc3c2v2
IonfZEFkJHTzUPDYZRQTekXdO+ZIgZkkPJ6SNwh/oYpFBp2wMK4Gf/FVvHDVwmdg
pQWHhs7NDFMWZutfEJb/GqAH9kxhm5GMgjC+B83oHnez+VSijwzDzH7ZfgCHuThN
fDVAX14CppgO2iyYTke+rVcX/AIcXcqlBzBiQN+p+BdD/HZf9qcV/o0b1EdzU2ii
rm5UdMTuWGTFHcSmJKrWclHDwEK8zRqC1gCPJLogl79P8gGN2TTTFFb0/6yGKthH
I6+Pj+Rlqlcfbfy+b+CKHHHmoheczOP3gPib3tJKEsmSueVgjMXYErlppAGjbL4K
bl221zvh9MlpUW1vm48xv8vYDCef5B/h/ixcUSQ4ASg9OkYEmGX027Lm2F62XPEz
BGg9ZGXcmIB9Rs4i3TT/zRzGsQ0ll92AL0ufuDBt0dnbmQBlT8I7eWMPeXjcc2Ci
L+IJYWQFZ/mbFhzxoxNZ
=VBCU
-----END PGP SIGNATURE-----

--r5Pyd7+fXNt84Ff3--
