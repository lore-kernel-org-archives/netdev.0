From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-11-16
Date: Fri, 16 Nov 2012 13:30:11 -0500
Message-ID: <20121116183011.GA29426@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cNdxnHkX5QqsyA0e"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 26c6e80892d8c160dffaba85889bd4e65b1dacf6

Dave,

This batch of fixes is intended for the 3.7 stream...

This includes a pull of the Bluetooth tree.  Gustavo says:

"A few important fixes to go into 3.7. There is a new hw support by Marcos
Chaparro. Johan added a memory leak fix and hci device index list fix.
Also Marcel fixed a race condition in the device set up that was prevent the
bt monitor to work properly. Last, Paulo S=E9rgio added a fix to the error
status when pairing for LE fails. This was prevent userspace to work to han=
dle
the failure properly."

Regarding the mac80211 pull, Johannes says:

"I have a locking fix for some SKB queues, a variable initialization to
avoid crashes in a certain failure case, another free_txskb fix from
Felix and another fix from him to avoid calling a stopped driver, a fix
for a (very unlikely) memory leak and a fix to not send null data
packets when resuming while not associated."

Regarding the iwlwifi pull, Johannes says:

"Two more fixes for iwlwifi ... one to use ieee80211_free_txskb(), and
one to check DMA mapping errors, please pull."

On top of that, Johannes also included a wireless regulatory fix
to allow 40 MHz on channels 12 and 13 in world roaming mode.  Also,
Hauke Mehrtens fixes a #ifdef typo in brcmfmac.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 6fc4adca6ce3e1d57a42707019dddcb883578a91:

  tilegx: request_irq with a non-null device name (2012-11-16 01:40:41 -050=
0)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 26c6e80892d8c160dffaba85889bd4e65b1dacf6:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2012-11-16 12:59:13 -0500)

----------------------------------------------------------------

Arik Nemtsov (1):
      mac80211: sync acccess to tx_filtered/ps_tx_buf queues

David Spinadel (1):
      mac80211: init sched_scan_ies

Felix Fietkau (2):
      mac80211: do not call ieee80211_configure_filter if no interfaces are=
 up
      mac80211: call skb_dequeue/ieee80211_free_txskb instead of __skb_queu=
e_purge

Hauke Mehrtens (1):
      brcmfmac: fix typo in CONFIG_BRCMISCAN

Johan Hedberg (2):
      Bluetooth: Fix having bogus entries in mgmt_read_index_list reply
      Bluetooth: Fix memory leak when removing a UUID

Johannes Berg (5):
      iwlwifi: handle DMA mapping failures
      iwlwifi: use ieee80211_free_txskb
      mac80211: fix memory leak in device registration error path
      mac80211: don't send null data packet when not associated
      wireless: allow 40 MHz on world roaming channels 12/13

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Marcel Holtmann (1):
      Bluetooth: Notify about device registration before power on

Marcos Chaparro (1):
      Bluetooth: ath3k: Add support for VAIO VPCEH [0489:e027]

Paulo S=E9rgio (1):
      Bluetooth: Fix error status when pairing fails

 drivers/bluetooth/ath3k.c                          |  1 +
 drivers/bluetooth/btusb.c                          |  1 +
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |  2 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |  2 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             | 23 ++++++++++++++++++=
++--
 net/bluetooth/hci_core.c                           |  4 ++--
 net/bluetooth/mgmt.c                               | 12 ++++++-----
 net/bluetooth/smp.c                                |  2 +-
 net/mac80211/cfg.c                                 |  3 +++
 net/mac80211/ieee80211_i.h                         |  2 ++
 net/mac80211/main.c                                |  6 ++++--
 net/mac80211/scan.c                                |  2 +-
 net/mac80211/sta_info.c                            | 11 ++++++++---
 net/mac80211/status.c                              |  9 +++++++++
 net/mac80211/tx.c                                  |  9 ++++++---
 net/mac80211/util.c                                |  2 ++
 net/wireless/reg.c                                 |  5 ++---
 18 files changed, 73 insertions(+), 25 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index fc2de55..b00000e 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -67,6 +67,7 @@ static struct usb_device_id ath3k_table[] =3D {
 	{ USB_DEVICE(0x13d3, 0x3304) },
 	{ USB_DEVICE(0x0930, 0x0215) },
 	{ USB_DEVICE(0x0489, 0xE03D) },
+	{ USB_DEVICE(0x0489, 0xE027) },
=20
 	/* Atheros AR9285 Malbec with sflash firmware */
 	{ USB_DEVICE(0x03F0, 0x311D) },
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index debda27..ee82f2f 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -124,6 +124,7 @@ static struct usb_device_id blacklist_table[] =3D {
 	{ USB_DEVICE(0x13d3, 0x3304), .driver_info =3D BTUSB_IGNORE },
 	{ USB_DEVICE(0x0930, 0x0215), .driver_info =3D BTUSB_IGNORE },
 	{ USB_DEVICE(0x0489, 0xe03d), .driver_info =3D BTUSB_IGNORE },
+	{ USB_DEVICE(0x0489, 0xe027), .driver_info =3D BTUSB_IGNORE },
=20
 	/* Atheros AR9285 Malbec with sflash firmware */
 	{ USB_DEVICE(0x03f0, 0x311d), .driver_info =3D BTUSB_IGNORE },
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index a6f1e81..481345c 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -4401,7 +4401,7 @@ static s32 brcmf_mode_to_nl80211_iftype(s32 mode)
=20
 static void brcmf_wiphy_pno_params(struct wiphy *wiphy)
 {
-#ifndef CONFIG_BRCMFISCAN
+#ifndef CONFIG_BRCMISCAN
 	/* scheduled scan settings */
 	wiphy->max_sched_scan_ssids =3D BRCMF_PNO_MAX_PFN_COUNT;
 	wiphy->max_match_sets =3D BRCMF_PNO_MAX_PFN_COUNT;
diff --git a/drivers/net/wireless/iwlwifi/dvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/dvm/mac80211.c
index ff8162d..fa4d1b8 100644
--- a/drivers/net/wireless/iwlwifi/dvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/dvm/mac80211.c
@@ -521,7 +521,7 @@ static void iwlagn_mac_tx(struct ieee80211_hw *hw,
 		     ieee80211_get_tx_rate(hw, IEEE80211_SKB_CB(skb))->bitrate);
=20
 	if (iwlagn_tx_skb(priv, control->sta, skb))
-		dev_kfree_skb_any(skb);
+		ieee80211_free_txskb(hw, skb);
 }
=20
 static void iwlagn_mac_update_tkip_key(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/iwlwifi/dvm/main.c b/drivers/net/wireless=
/iwlwifi/dvm/main.c
index 7ff3f14..408132c 100644
--- a/drivers/net/wireless/iwlwifi/dvm/main.c
+++ b/drivers/net/wireless/iwlwifi/dvm/main.c
@@ -2114,7 +2114,7 @@ static void iwl_free_skb(struct iwl_op_mode *op_mode,=
 struct sk_buff *skb)
=20
 	info =3D IEEE80211_SKB_CB(skb);
 	iwl_trans_free_tx_cmd(priv->trans, info->driver_data[1]);
-	dev_kfree_skb_any(skb);
+	ieee80211_free_txskb(priv->hw, skb);
 }
=20
 static void iwl_set_hw_rfkill_state(struct iwl_op_mode *op_mode, bool stat=
e)
diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c b/drivers/net/wireless/=
iwlwifi/pcie/rx.c
index 17c8e5d..bb69f8f 100644
--- a/drivers/net/wireless/iwlwifi/pcie/rx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/rx.c
@@ -321,6 +321,14 @@ static void iwl_rx_allocate(struct iwl_trans *trans, g=
fp_t priority)
 			dma_map_page(trans->dev, page, 0,
 				     PAGE_SIZE << trans_pcie->rx_page_order,
 				     DMA_FROM_DEVICE);
+		if (dma_mapping_error(trans->dev, rxb->page_dma)) {
+			rxb->page =3D NULL;
+			spin_lock_irqsave(&rxq->lock, flags);
+			list_add(&rxb->list, &rxq->rx_used);
+			spin_unlock_irqrestore(&rxq->lock, flags);
+			__free_pages(page, trans_pcie->rx_page_order);
+			return;
+		}
 		/* dma address must be no more than 36 bits */
 		BUG_ON(rxb->page_dma & ~DMA_BIT_MASK(36));
 		/* and also 256 byte aligned! */
@@ -488,8 +496,19 @@ static void iwl_rx_handle_rxbuf(struct iwl_trans *tran=
s,
 			dma_map_page(trans->dev, rxb->page, 0,
 				     PAGE_SIZE << trans_pcie->rx_page_order,
 				     DMA_FROM_DEVICE);
-		list_add_tail(&rxb->list, &rxq->rx_free);
-		rxq->free_count++;
+		if (dma_mapping_error(trans->dev, rxb->page_dma)) {
+			/*
+			 * free the page(s) as well to not break
+			 * the invariant that the items on the used
+			 * list have no page(s)
+			 */
+			__free_pages(rxb->page, trans_pcie->rx_page_order);
+			rxb->page =3D NULL;
+			list_add_tail(&rxb->list, &rxq->rx_used);
+		} else {
+			list_add_tail(&rxb->list, &rxq->rx_free);
+			rxq->free_count++;
+		}
 	} else
 		list_add_tail(&rxb->list, &rxq->rx_used);
 	spin_unlock_irqrestore(&rxq->lock, flags);
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 8a0ce70..a0a2f97 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1754,11 +1754,11 @@ int hci_register_dev(struct hci_dev *hdev)
 	if (hdev->dev_type !=3D HCI_AMP)
 		set_bit(HCI_AUTO_OFF, &hdev->dev_flags);
=20
-	schedule_work(&hdev->power_on);
-
 	hci_notify(hdev, HCI_DEV_REG);
 	hci_dev_hold(hdev);
=20
+	schedule_work(&hdev->power_on);
+
 	return id;
=20
 err_wqueue:
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index aa2ea0a..91de423 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -326,7 +326,7 @@ static int read_index_list(struct sock *sk, struct hci_=
dev *hdev, void *data,
 	struct hci_dev *d;
 	size_t rp_len;
 	u16 count;
-	int i, err;
+	int err;
=20
 	BT_DBG("sock %p", sk);
=20
@@ -347,9 +347,7 @@ static int read_index_list(struct sock *sk, struct hci_=
dev *hdev, void *data,
 		return -ENOMEM;
 	}
=20
-	rp->num_controllers =3D cpu_to_le16(count);
-
-	i =3D 0;
+	count =3D 0;
 	list_for_each_entry(d, &hci_dev_list, list) {
 		if (test_bit(HCI_SETUP, &d->dev_flags))
 			continue;
@@ -357,10 +355,13 @@ static int read_index_list(struct sock *sk, struct hc=
i_dev *hdev, void *data,
 		if (!mgmt_valid_hdev(d))
 			continue;
=20
-		rp->index[i++] =3D cpu_to_le16(d->id);
+		rp->index[count++] =3D cpu_to_le16(d->id);
 		BT_DBG("Added hci%u", d->id);
 	}
=20
+	rp->num_controllers =3D cpu_to_le16(count);
+	rp_len =3D sizeof(*rp) + (2 * count);
+
 	read_unlock(&hci_dev_list_lock);
=20
 	err =3D cmd_complete(sk, MGMT_INDEX_NONE, MGMT_OP_READ_INDEX_LIST, 0, rp,
@@ -1366,6 +1367,7 @@ static int remove_uuid(struct sock *sk, struct hci_de=
v *hdev, void *data,
 			continue;
=20
 		list_del(&match->list);
+		kfree(match);
 		found++;
 	}
=20
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 2ac8d50..a592337 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -267,7 +267,7 @@ static void smp_failure(struct l2cap_conn *conn, u8 rea=
son, u8 send)
=20
 	clear_bit(HCI_CONN_ENCRYPT_PEND, &conn->hcon->flags);
 	mgmt_auth_failed(conn->hcon->hdev, conn->dst, hcon->type,
-			 hcon->dst_type, reason);
+			 hcon->dst_type, HCI_ERROR_AUTH_FAILURE);
=20
 	cancel_delayed_work_sync(&conn->security_timer);
=20
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 05f3a31..7371f67 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -2594,6 +2594,9 @@ static void ieee80211_mgmt_frame_register(struct wiph=
y *wiphy,
 		else
 			local->probe_req_reg--;
=20
+		if (!local->open_count)
+			break;
+
 		ieee80211_queue_work(&local->hw, &local->reconfig_filter);
 		break;
 	default:
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 8c80455..156e583 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1314,6 +1314,8 @@ netdev_tx_t ieee80211_monitor_start_xmit(struct sk_bu=
ff *skb,
 					 struct net_device *dev);
 netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 				       struct net_device *dev);
+void ieee80211_purge_tx_queue(struct ieee80211_hw *hw,
+			      struct sk_buff_head *skbs);
=20
 /* HT */
 void ieee80211_apply_htcap_overrides(struct ieee80211_sub_if_data *sdata,
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index c80c449..f57f597 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -871,8 +871,10 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 				local->hw.wiphy->cipher_suites,
 				sizeof(u32) * local->hw.wiphy->n_cipher_suites,
 				GFP_KERNEL);
-			if (!suites)
-				return -ENOMEM;
+			if (!suites) {
+				result =3D -ENOMEM;
+				goto fail_wiphy_register;
+			}
 			for (r =3D 0; r < local->hw.wiphy->n_cipher_suites; r++) {
 				u32 suite =3D local->hw.wiphy->cipher_suites[r];
 				if (suite =3D=3D WLAN_CIPHER_SUITE_WEP40 ||
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index c4cdbde..43e60b5 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -917,7 +917,7 @@ int ieee80211_request_sched_scan_start(struct ieee80211=
_sub_if_data *sdata,
 				       struct cfg80211_sched_scan_request *req)
 {
 	struct ieee80211_local *local =3D sdata->local;
-	struct ieee80211_sched_scan_ies sched_scan_ies;
+	struct ieee80211_sched_scan_ies sched_scan_ies =3D {};
 	int ret, i;
=20
 	mutex_lock(&local->mtx);
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 0a4e4c0..d2eb64e 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -117,8 +117,8 @@ static void free_sta_work(struct work_struct *wk)
=20
 	for (ac =3D 0; ac < IEEE80211_NUM_ACS; ac++) {
 		local->total_ps_buffered -=3D skb_queue_len(&sta->ps_tx_buf[ac]);
-		__skb_queue_purge(&sta->ps_tx_buf[ac]);
-		__skb_queue_purge(&sta->tx_filtered[ac]);
+		ieee80211_purge_tx_queue(&local->hw, &sta->ps_tx_buf[ac]);
+		ieee80211_purge_tx_queue(&local->hw, &sta->tx_filtered[ac]);
 	}
=20
 #ifdef CONFIG_MAC80211_MESH
@@ -141,7 +141,7 @@ static void free_sta_work(struct work_struct *wk)
 		tid_tx =3D rcu_dereference_raw(sta->ampdu_mlme.tid_tx[i]);
 		if (!tid_tx)
 			continue;
-		__skb_queue_purge(&tid_tx->pending);
+		ieee80211_purge_tx_queue(&local->hw, &tid_tx->pending);
 		kfree(tid_tx);
 	}
=20
@@ -961,6 +961,7 @@ void ieee80211_sta_ps_deliver_wakeup(struct sta_info *s=
ta)
 	struct ieee80211_local *local =3D sdata->local;
 	struct sk_buff_head pending;
 	int filtered =3D 0, buffered =3D 0, ac;
+	unsigned long flags;
=20
 	clear_sta_flag(sta, WLAN_STA_SP);
=20
@@ -976,12 +977,16 @@ void ieee80211_sta_ps_deliver_wakeup(struct sta_info =
*sta)
 	for (ac =3D 0; ac < IEEE80211_NUM_ACS; ac++) {
 		int count =3D skb_queue_len(&pending), tmp;
=20
+		spin_lock_irqsave(&sta->tx_filtered[ac].lock, flags);
 		skb_queue_splice_tail_init(&sta->tx_filtered[ac], &pending);
+		spin_unlock_irqrestore(&sta->tx_filtered[ac].lock, flags);
 		tmp =3D skb_queue_len(&pending);
 		filtered +=3D tmp - count;
 		count =3D tmp;
=20
+		spin_lock_irqsave(&sta->ps_tx_buf[ac].lock, flags);
 		skb_queue_splice_tail_init(&sta->ps_tx_buf[ac], &pending);
+		spin_unlock_irqrestore(&sta->ps_tx_buf[ac].lock, flags);
 		tmp =3D skb_queue_len(&pending);
 		buffered +=3D tmp - count;
 	}
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 3af0cc4..101eb88 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -668,3 +668,12 @@ void ieee80211_free_txskb(struct ieee80211_hw *hw, str=
uct sk_buff *skb)
 	dev_kfree_skb_any(skb);
 }
 EXPORT_SYMBOL(ieee80211_free_txskb);
+
+void ieee80211_purge_tx_queue(struct ieee80211_hw *hw,
+			      struct sk_buff_head *skbs)
+{
+	struct sk_buff *skb;
+
+	while ((skb =3D __skb_dequeue(skbs)))
+		ieee80211_free_txskb(hw, skb);
+}
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index c9bf83f..b858ebe 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1358,7 +1358,7 @@ static int invoke_tx_handlers(struct ieee80211_tx_dat=
a *tx)
 		if (tx->skb)
 			ieee80211_free_txskb(&tx->local->hw, tx->skb);
 		else
-			__skb_queue_purge(&tx->skbs);
+			ieee80211_purge_tx_queue(&tx->local->hw, &tx->skbs);
 		return -1;
 	} else if (unlikely(res =3D=3D TX_QUEUED)) {
 		I802_DEBUG_INC(tx->local->tx_handlers_queued);
@@ -2120,10 +2120,13 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_bu=
ff *skb,
  */
 void ieee80211_clear_tx_pending(struct ieee80211_local *local)
 {
+	struct sk_buff *skb;
 	int i;
=20
-	for (i =3D 0; i < local->hw.queues; i++)
-		skb_queue_purge(&local->pending[i]);
+	for (i =3D 0; i < local->hw.queues; i++) {
+		while ((skb =3D skb_dequeue(&local->pending[i])) !=3D NULL)
+			ieee80211_free_txskb(&local->hw, skb);
+	}
 }
=20
 /*
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 2393918..0151ae3 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1491,6 +1491,8 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 		list_for_each_entry(sdata, &local->interfaces, list) {
 			if (sdata->vif.type !=3D NL80211_IFTYPE_STATION)
 				continue;
+			if (!sdata->u.mgd.associated)
+				continue;
=20
 			ieee80211_send_nullfunc(local, sdata, 0);
 		}
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index bcc7d7e..b75756b 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -141,9 +141,8 @@ static const struct ieee80211_regdomain world_regdom =
=3D {
 	.reg_rules =3D {
 		/* IEEE 802.11b/g, channels 1..11 */
 		REG_RULE(2412-10, 2462+10, 40, 6, 20, 0),
-		/* IEEE 802.11b/g, channels 12..13. No HT40
-		 * channel fits here. */
-		REG_RULE(2467-10, 2472+10, 20, 6, 20,
+		/* IEEE 802.11b/g, channels 12..13. */
+		REG_RULE(2467-10, 2472+10, 40, 6, 20,
 			NL80211_RRF_PASSIVE_SCAN |
 			NL80211_RRF_NO_IBSS),
 		/* IEEE 802.11 channel 14 - Only JP enables
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--cNdxnHkX5QqsyA0e
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQpoYyAAoJEJctW/TcYTgGlo0QAI2izFdscy2nnmyinvzZaYkY
hAllWvIU9hASg+jGoBdbBBRBiVSMK5vTQCTx3JiP30+du0/1fenIxHJXHw9uVCyF
eQH5cwg3TREf1VFcN4CEAPapd9uR4RvYbTk35cxydRCZEfseLAep8wbcfmk2M/hx
EzvMegTI6wDu85gIJRY1AP2YvZHgn11j83l5yOfui4ExYIFgk1oaKtvLtQnArotN
VSMQVoZmAjPGlv7TP9+kKq2oXVmWXwxG18ni5Qdy5iud0LgL8Z1q18kJOHw4AOeF
U0e+KqwBEvy4nidOGahlgPHpBANLSGv4Gws5pRD82sj4wQU1HnCXw2GofzbIf8w4
oh2+SE7suvRNhff6R/TcSAr9QufPrIMSdX6JGlN3OtdQL12GhzJYc7mPPwPtjsUc
fbqhH5dDaKha8OBmAcTHr/9cLazMBCwiFmZr+a9Oi3+KLyaWbxCzm8YP941aD4MG
2cXQwFAeC7i0GuqWETnxskJpyGXDIr2NnbG30iLo2nFQfshLToQATUhleV4+Hl/h
Eu/iwWgMZHAFWRDys3pYHuIUADywREUm38T7a5W7ncqNk9UYTnSIgCo11gODx1eE
3sSl2FrxfPjqyvaEGI/oFanz1V1UlmBvP/1D+PNXJwiNYylPB+z3A7YH2ecitVdZ
mEWhoJInH1U4cIPD2tfI
=ipNw
-----END PGP SIGNATURE-----

--cNdxnHkX5QqsyA0e--
