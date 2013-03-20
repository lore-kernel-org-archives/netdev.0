From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-03-20
Date: Wed, 20 Mar 2013 15:11:08 -0400
Message-ID: <20130320191107.GA9978@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="G4iJoqBmSsgzjUCe"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

I present to you another batch of fixes intended for the 3.9 stream...

On the bluetooth bits, Gustavo says:

"I put together 3 fixes intended for 3.9, there are support for two
new devices and a NULL dereference fix in the SCO code."

Amitkumar Karwar fixes a command queueing race in mwifiex.

Bing Zhao provides a pair of mwifiex related to cleaning-up before
a shutdown.

Felix Fietkau provides an ath9k fix for a regression caused by an
earlier calibration fix, and another ath9k fix to avoid race conditions
that unnecessarily lead to chip resets.

Jussi Kivilinna prevents and skbuff leak in rtlwifi.

Stanislaw Gruszka corrects a length paramater for a DMA buffer mapping
operation in iwlegacy.

Please let me know if there are problems!

John

---

The following changes since commit da2191e31409d1058dcbed44e8f53e39a40e86b3:

  net: fec: Define indexes as 'unsigned int' (2013-03-20 12:28:59 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to b9d5319041999401d29e7efcd5d15664edfaad2e:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-03-20 14:26:37 -0400)

----------------------------------------------------------------

Amitkumar Karwar (1):
      mwifiex: fix race when queuing commands

Bing Zhao (2):
      mwifiex: skip pending commands after function shutdown
      mwifiex: cancel cmd timer and free curr_cmd in shutdown process

Felix Fietkau (2):
      ath9k_hw: revert chainmask to user configuration after calibration
      ath9k: limit tx path hang check to normal data queues

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jussi Kivilinna (1):
      rtlwifi: usb: add missing freeing of skbuff

Ming Lei (2):
      Bluetooth: Add support for Dell[QCA 0cf3:0036]
      Bluetooth: Add support for Dell[QCA 0cf3:817a]

Stanislaw Gruszka (1):
      iwl3945: fix length of dma buffers

Vinicius Costa Gomes (1):
      Bluetooth: Fix not closing SCO sockets in the BT_CONNECT2 state

 drivers/bluetooth/ath3k.c                     |  4 ++++
 drivers/bluetooth/btusb.c                     |  2 ++
 drivers/net/wireless/ath/ath9k/ar9003_calib.c |  4 ++++
 drivers/net/wireless/ath/ath9k/link.c         | 26 +++++++++++++----------=
---
 drivers/net/wireless/iwlegacy/3945-mac.c      | 22 ++++++++++++----------
 drivers/net/wireless/mwifiex/cmdevt.c         | 22 ++++++++++++++++------
 drivers/net/wireless/mwifiex/init.c           |  8 ++++++++
 drivers/net/wireless/mwifiex/main.h           |  4 ++--
 drivers/net/wireless/mwifiex/scan.c           |  8 ++++----
 drivers/net/wireless/mwifiex/sta_ioctl.c      | 10 ++--------
 drivers/net/wireless/rtlwifi/usb.c            |  1 +
 net/bluetooth/sco.c                           |  1 +
 12 files changed, 69 insertions(+), 43 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index b282af1..6aab00e 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -73,9 +73,11 @@ static struct usb_device_id ath3k_table[] =3D {
 	{ USB_DEVICE(0x03F0, 0x311D) },
=20
 	/* Atheros AR3012 with sflash firmware*/
+	{ USB_DEVICE(0x0CF3, 0x0036) },
 	{ USB_DEVICE(0x0CF3, 0x3004) },
 	{ USB_DEVICE(0x0CF3, 0x3008) },
 	{ USB_DEVICE(0x0CF3, 0x311D) },
+	{ USB_DEVICE(0x0CF3, 0x817a) },
 	{ USB_DEVICE(0x13d3, 0x3375) },
 	{ USB_DEVICE(0x04CA, 0x3004) },
 	{ USB_DEVICE(0x04CA, 0x3005) },
@@ -107,9 +109,11 @@ MODULE_DEVICE_TABLE(usb, ath3k_table);
 static struct usb_device_id ath3k_blist_tbl[] =3D {
=20
 	/* Atheros AR3012 with sflash firmware*/
+	{ USB_DEVICE(0x0CF3, 0x0036), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x3004), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x311D), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0CF3, 0x817a), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3375), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3004), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3005), .driver_info =3D BTUSB_ATH3012 },
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index e547851..2cc5f77 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -131,9 +131,11 @@ static struct usb_device_id blacklist_table[] =3D {
 	{ USB_DEVICE(0x03f0, 0x311d), .driver_info =3D BTUSB_IGNORE },
=20
 	/* Atheros 3012 with sflash firmware */
+	{ USB_DEVICE(0x0cf3, 0x0036), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x3004), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x311d), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0x817a), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3375), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3004), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3005), .driver_info =3D BTUSB_ATH3012 },
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_calib.c b/drivers/net/wi=
reless/ath/ath9k/ar9003_calib.c
index 4cc1394..f76c3ca 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
@@ -1023,6 +1023,7 @@ static bool ar9003_hw_init_cal(struct ath_hw *ah,
 					  AR_PHY_AGC_CONTROL_FLTR_CAL   |
 					  AR_PHY_AGC_CONTROL_PKDET_CAL;
=20
+	/* Use chip chainmask only for calibration */
 	ar9003_hw_set_chain_masks(ah, ah->caps.rx_chainmask, ah->caps.tx_chainmas=
k);
=20
 	if (rtt) {
@@ -1150,6 +1151,9 @@ skip_tx_iqcal:
 		ar9003_hw_rtt_disable(ah);
 	}
=20
+	/* Revert chainmask to runtime parameters */
+	ar9003_hw_set_chain_masks(ah, ah->rxchainmask, ah->txchainmask);
+
 	/* Initialize list pointers */
 	ah->cal_list =3D ah->cal_list_last =3D ah->cal_list_curr =3D NULL;
=20
diff --git a/drivers/net/wireless/ath/ath9k/link.c b/drivers/net/wireless/a=
th/ath9k/link.c
index ade3afb..39c84ec 100644
--- a/drivers/net/wireless/ath/ath9k/link.c
+++ b/drivers/net/wireless/ath/ath9k/link.c
@@ -28,21 +28,21 @@ void ath_tx_complete_poll_work(struct work_struct *work)
 	int i;
 	bool needreset =3D false;
=20
-	for (i =3D 0; i < ATH9K_NUM_TX_QUEUES; i++)
-		if (ATH_TXQ_SETUP(sc, i)) {
-			txq =3D &sc->tx.txq[i];
-			ath_txq_lock(sc, txq);
-			if (txq->axq_depth) {
-				if (txq->axq_tx_inprogress) {
-					needreset =3D true;
-					ath_txq_unlock(sc, txq);
-					break;
-				} else {
-					txq->axq_tx_inprogress =3D true;
-				}
+	for (i =3D 0; i < IEEE80211_NUM_ACS; i++) {
+		txq =3D sc->tx.txq_map[i];
+
+		ath_txq_lock(sc, txq);
+		if (txq->axq_depth) {
+			if (txq->axq_tx_inprogress) {
+				needreset =3D true;
+				ath_txq_unlock(sc, txq);
+				break;
+			} else {
+				txq->axq_tx_inprogress =3D true;
 			}
-			ath_txq_unlock_complete(sc, txq);
 		}
+		ath_txq_unlock_complete(sc, txq);
+	}
=20
 	if (needreset) {
 		ath_dbg(ath9k_hw_common(sc->sc_ah), RESET,
diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireles=
s/iwlegacy/3945-mac.c
index 3630a41..c353b5f 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -475,6 +475,7 @@ il3945_tx_skb(struct il_priv *il,
 	dma_addr_t txcmd_phys;
 	int txq_id =3D skb_get_queue_mapping(skb);
 	u16 len, idx, hdr_len;
+	u16 firstlen, secondlen;
 	u8 id;
 	u8 unicast;
 	u8 sta_id;
@@ -589,21 +590,22 @@ il3945_tx_skb(struct il_priv *il,
 	len =3D
 	    sizeof(struct il3945_tx_cmd) + sizeof(struct il_cmd_header) +
 	    hdr_len;
-	len =3D (len + 3) & ~3;
+	firstlen =3D (len + 3) & ~3;
=20
 	/* Physical address of this Tx command's header (not MAC header!),
 	 * within command buffer array. */
 	txcmd_phys =3D
-	    pci_map_single(il->pci_dev, &out_cmd->hdr, len, PCI_DMA_TODEVICE);
+	    pci_map_single(il->pci_dev, &out_cmd->hdr, firstlen,
+			   PCI_DMA_TODEVICE);
 	if (unlikely(pci_dma_mapping_error(il->pci_dev, txcmd_phys)))
 		goto drop_unlock;
=20
 	/* Set up TFD's 2nd entry to point directly to remainder of skb,
 	 * if any (802.11 null frames have no payload). */
-	len =3D skb->len - hdr_len;
-	if (len) {
+	secondlen =3D skb->len - hdr_len;
+	if (secondlen > 0) {
 		phys_addr =3D
-		    pci_map_single(il->pci_dev, skb->data + hdr_len, len,
+		    pci_map_single(il->pci_dev, skb->data + hdr_len, secondlen,
 				   PCI_DMA_TODEVICE);
 		if (unlikely(pci_dma_mapping_error(il->pci_dev, phys_addr)))
 			goto drop_unlock;
@@ -611,12 +613,12 @@ il3945_tx_skb(struct il_priv *il,
=20
 	/* Add buffer containing Tx command and MAC(!) header to TFD's
 	 * first entry */
-	il->ops->txq_attach_buf_to_tfd(il, txq, txcmd_phys, len, 1, 0);
+	il->ops->txq_attach_buf_to_tfd(il, txq, txcmd_phys, firstlen, 1, 0);
 	dma_unmap_addr_set(out_meta, mapping, txcmd_phys);
-	dma_unmap_len_set(out_meta, len, len);
-	if (len)
-		il->ops->txq_attach_buf_to_tfd(il, txq, phys_addr, len, 0,
-					       U32_PAD(len));
+	dma_unmap_len_set(out_meta, len, firstlen);
+	if (secondlen > 0)
+		il->ops->txq_attach_buf_to_tfd(il, txq, phys_addr, secondlen, 0,
+					       U32_PAD(secondlen));
=20
 	if (!ieee80211_has_morefrags(hdr->frame_control)) {
 		txq->need_update =3D 1;
diff --git a/drivers/net/wireless/mwifiex/cmdevt.c b/drivers/net/wireless/m=
wifiex/cmdevt.c
index 20a6c55..b5c8b96 100644
--- a/drivers/net/wireless/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/mwifiex/cmdevt.c
@@ -157,6 +157,20 @@ static int mwifiex_dnld_cmd_to_fw(struct mwifiex_priva=
te *priv,
 		return -1;
 	}
=20
+	cmd_code =3D le16_to_cpu(host_cmd->command);
+	cmd_size =3D le16_to_cpu(host_cmd->size);
+
+	if (adapter->hw_status =3D=3D MWIFIEX_HW_STATUS_RESET &&
+	    cmd_code !=3D HostCmd_CMD_FUNC_SHUTDOWN &&
+	    cmd_code !=3D HostCmd_CMD_FUNC_INIT) {
+		dev_err(adapter->dev,
+			"DNLD_CMD: FW in reset state, ignore cmd %#x\n",
+			cmd_code);
+		mwifiex_complete_cmd(adapter, cmd_node);
+		mwifiex_insert_cmd_to_free_q(adapter, cmd_node);
+		return -1;
+	}
+
 	/* Set command sequence number */
 	adapter->seq_num++;
 	host_cmd->seq_num =3D cpu_to_le16(HostCmd_SET_SEQ_NO_BSS_INFO
@@ -168,9 +182,6 @@ static int mwifiex_dnld_cmd_to_fw(struct mwifiex_privat=
e *priv,
 	adapter->curr_cmd =3D cmd_node;
 	spin_unlock_irqrestore(&adapter->mwifiex_cmd_lock, flags);
=20
-	cmd_code =3D le16_to_cpu(host_cmd->command);
-	cmd_size =3D le16_to_cpu(host_cmd->size);
-
 	/* Adjust skb length */
 	if (cmd_node->cmd_skb->len > cmd_size)
 		/*
@@ -484,8 +495,6 @@ int mwifiex_send_cmd_sync(struct mwifiex_private *priv,=
 uint16_t cmd_no,
=20
 	ret =3D mwifiex_send_cmd_async(priv, cmd_no, cmd_action, cmd_oid,
 				     data_buf);
-	if (!ret)
-		ret =3D mwifiex_wait_queue_complete(adapter);
=20
 	return ret;
 }
@@ -588,9 +597,10 @@ int mwifiex_send_cmd_async(struct mwifiex_private *pri=
v, uint16_t cmd_no,
 	if (cmd_no =3D=3D HostCmd_CMD_802_11_SCAN) {
 		mwifiex_queue_scan_cmd(priv, cmd_node);
 	} else {
-		adapter->cmd_queued =3D cmd_node;
 		mwifiex_insert_cmd_to_pending_q(adapter, cmd_node, true);
 		queue_work(adapter->workqueue, &adapter->main_work);
+		if (cmd_node->wait_q_enabled)
+			ret =3D mwifiex_wait_queue_complete(adapter, cmd_node);
 	}
=20
 	return ret;
diff --git a/drivers/net/wireless/mwifiex/init.c b/drivers/net/wireless/mwi=
fiex/init.c
index e38aa9b..0ff4c37 100644
--- a/drivers/net/wireless/mwifiex/init.c
+++ b/drivers/net/wireless/mwifiex/init.c
@@ -709,6 +709,14 @@ mwifiex_shutdown_drv(struct mwifiex_adapter *adapter)
 		return ret;
 	}
=20
+	/* cancel current command */
+	if (adapter->curr_cmd) {
+		dev_warn(adapter->dev, "curr_cmd is still in processing\n");
+		del_timer(&adapter->cmd_timer);
+		mwifiex_insert_cmd_to_free_q(adapter, adapter->curr_cmd);
+		adapter->curr_cmd =3D NULL;
+	}
+
 	/* shut down mwifiex */
 	dev_dbg(adapter->dev, "info: shutdown mwifiex...\n");
=20
diff --git a/drivers/net/wireless/mwifiex/main.h b/drivers/net/wireless/mwi=
fiex/main.h
index 553adfb..7035ade 100644
--- a/drivers/net/wireless/mwifiex/main.h
+++ b/drivers/net/wireless/mwifiex/main.h
@@ -723,7 +723,6 @@ struct mwifiex_adapter {
 	u16 cmd_wait_q_required;
 	struct mwifiex_wait_queue cmd_wait_q;
 	u8 scan_wait_q_woken;
-	struct cmd_ctrl_node *cmd_queued;
 	spinlock_t queue_lock;		/* lock for tx queues */
 	struct completion fw_load;
 	u8 country_code[IEEE80211_COUNTRY_STRING_LEN];
@@ -1018,7 +1017,8 @@ int mwifiex_request_set_multicast_list(struct mwifiex=
_private *priv,
 			struct mwifiex_multicast_list *mcast_list);
 int mwifiex_copy_mcast_addr(struct mwifiex_multicast_list *mlist,
 			    struct net_device *dev);
-int mwifiex_wait_queue_complete(struct mwifiex_adapter *adapter);
+int mwifiex_wait_queue_complete(struct mwifiex_adapter *adapter,
+				struct cmd_ctrl_node *cmd_queued);
 int mwifiex_bss_start(struct mwifiex_private *priv, struct cfg80211_bss *b=
ss,
 		      struct cfg80211_ssid *req_ssid);
 int mwifiex_cancel_hs(struct mwifiex_private *priv, int cmd_type);
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwi=
fiex/scan.c
index bb60c27..d215b4d 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -1388,10 +1388,13 @@ int mwifiex_scan_networks(struct mwifiex_private *p=
riv,
 			list_del(&cmd_node->list);
 			spin_unlock_irqrestore(&adapter->scan_pending_q_lock,
 					       flags);
-			adapter->cmd_queued =3D cmd_node;
 			mwifiex_insert_cmd_to_pending_q(adapter, cmd_node,
 							true);
 			queue_work(adapter->workqueue, &adapter->main_work);
+
+			/* Perform internal scan synchronously */
+			if (!priv->scan_request)
+				mwifiex_wait_queue_complete(adapter, cmd_node);
 		} else {
 			spin_unlock_irqrestore(&adapter->scan_pending_q_lock,
 					       flags);
@@ -1946,9 +1949,6 @@ int mwifiex_request_scan(struct mwifiex_private *priv,
 		/* Normal scan */
 		ret =3D mwifiex_scan_networks(priv, NULL);
=20
-	if (!ret)
-		ret =3D mwifiex_wait_queue_complete(priv->adapter);
-
 	up(&priv->async_sem);
=20
 	return ret;
diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireles=
s/mwifiex/sta_ioctl.c
index 9f33c92..13100f8 100644
--- a/drivers/net/wireless/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
@@ -54,16 +54,10 @@ int mwifiex_copy_mcast_addr(struct mwifiex_multicast_li=
st *mlist,
  * This function waits on a cmd wait queue. It also cancels the pending
  * request after waking up, in case of errors.
  */
-int mwifiex_wait_queue_complete(struct mwifiex_adapter *adapter)
+int mwifiex_wait_queue_complete(struct mwifiex_adapter *adapter,
+				struct cmd_ctrl_node *cmd_queued)
 {
 	int status;
-	struct cmd_ctrl_node *cmd_queued;
-
-	if (!adapter->cmd_queued)
-		return 0;
-
-	cmd_queued =3D adapter->cmd_queued;
-	adapter->cmd_queued =3D NULL;
=20
 	dev_dbg(adapter->dev, "cmd pending\n");
 	atomic_inc(&adapter->cmd_pending);
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlw=
ifi/usb.c
index 156b527..5847d6d 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -851,6 +851,7 @@ static void _rtl_usb_transmit(struct ieee80211_hw *hw, =
struct sk_buff *skb,
 	if (unlikely(!_urb)) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Can't allocate urb. Drop skb!\n");
+		kfree_skb(skb);
 		return;
 	}
 	_rtl_submit_tx_urb(hw, _urb);
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 79d87d8..fad0302 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -359,6 +359,7 @@ static void __sco_sock_close(struct sock *sk)
 			sco_chan_del(sk, ECONNRESET);
 		break;
=20
+	case BT_CONNECT2:
 	case BT_CONNECT:
 	case BT_DISCONN:
 		sco_chan_del(sk, ECONNRESET);
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--G4iJoqBmSsgzjUCe
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRSgnLAAoJEJctW/TcYTgGKG0P/1RAAH7juT607nZIlMiRR+UN
EwcgokGVUayRB63mTTQRXtEey+OBfQJwccNNrhDljHAWxUa8E50UNoXtwscGvG40
JMcl2WKUfLUflZ2EHYV2H1iFoCo9Y4D/gtSPeL+jlU6qITNKu6AxCviXobb89akI
6nZJZPz8D/Gem8+UPz+oC649zEMr02kpyicEq8PsGHoEM8tXTdsSMle6YOg5sooY
tpVaqZtTzDXWaVnqt+97IvCGP/YKBknxLHTYlEy8sfrVlnOWGN3ymi4S+jgaj2Yk
WkyqYf7yyMeLUKJzXaF8FvCVqtM2Wo8FqQK5vzs4Xqd4F5vosvq84W7HR58mayUG
uI0ilVK+AtTOAf9c8+cwohDbxYAKZPlnw6vOW5pE/9sP5G7PjdkrLs6wm4Rr8oVG
8f2zGpIV8AIk9z+nu/ZlRJTfEvRzdGHSiQ88Kbw7qg0/ufHK2KVKUYZvuHaRO3I0
tiww59yuz1Q05Efgp3ViwXkIteoQFQB9KNmxxkHwjW+wSuNTfX39VQxvrOiTiMbr
mcVuPAWQbAplDTkBdbYL282WTosQUd1P3d5ftw/SpNQeCIewI4DvYBApB2g/nDLz
Bymyd3baeSDeRWJuXkl6o0TTlxS9qhjUGDpTNziJ/NlUuJTpxlIjdWJJj1VVIpKP
Sv0sKHMtB5xRr7jcDPoU
=lteu
-----END PGP SIGNATURE-----

--G4iJoqBmSsgzjUCe--
