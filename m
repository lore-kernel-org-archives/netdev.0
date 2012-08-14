From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2012-08-14
Date: Tue, 14 Aug 2012 15:02:46 -0400
Message-ID: <20120814190245.GA22136@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

commit 1e55217e174f4e6920fd441dcd3aaf8e37645460

Dave,

This batch of fixes is intended for 3.6.

Alexey Khoroshilov provides a potential memory leak in rndis_wlan.

Bob Copeland gives us an ath5k fix for a lockdep problem.

Dan Carpenter fixes a signedness mismatch in at76c50x.

Felix Fietkau corrects a regression caused by an earlier commit that can
lead to an IRQ storm.

Lorenzo Bianconi offers a fix for a bad variable initialization in ath9k
that can cause it to improperly mark decrypted frames.

Rajkumar Manoharan fixes ath9k to prevent the btcoex time from running
when the hardware is asleep.

The remainder are Bluetooth fixes, about which Gustavo says:

	"Here goes some fixes for 3.6-rc1, there are a few fix to
	thte inquiry code by Ram Malovany, support for 2 new devices,
	and few others fixes for NULL dereference, possible deadlock
	and a memory leak."

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3bf671af14d591ede9251acb0085e8017f3705e7:

  Merge branch 'fixes-for-3.6' of git://git.kernel.org/pub/scm/linux/kernel/git/cooloney/linux-leds (2012-08-13 09:59:04 +0300)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

for you to fetch changes up to 1e55217e174f4e6920fd441dcd3aaf8e37645460:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless into for-davem (2012-08-14 14:42:54 -0400)

----------------------------------------------------------------

Alexey Khoroshilov (1):
      rndis_wlan: Fix potential memory leak in update_pmkid()

Andrei Emeltchenko (1):
      Bluetooth: smp: Fix possible NULL dereference

Bob Copeland (1):
      ath5k: fix spin_lock_irqsave/spin_lock_bh nesting in mesh

Dan Carpenter (1):
      wireless: at76c50x: signedness bug in at76_dfu_get_state()

Felix Fietkau (1):
      ath9k: fix interrupt storms on queued hardware reset

Gustavo Padovan (1):
      Bluetooth: Fix possible deadlock in SCO code

Jaganath Kanakkassery (1):
      Bluetooth: Fix socket not getting freed if l2cap channel create fails

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Lorenzo Bianconi (1):
      ath9k: fix decrypt_error initialization in ath_rx_tasklet()

Manoj Iyer (1):
      Bluetooth: btusb: Add vendor specific ID (0a5c:21f4) BCM20702A0

Peng Chen (1):
      Bluetooth: add support for atheros 0489:e057

Rajkumar Manoharan (1):
      ath9k: stop btcoex on device suspend

Ram Malovany (3):
      Bluetooth: Fix using NULL inquiry entry
      Bluetooth: Fix using a NULL inquiry cache entry
      Bluetooth: Set name_state to unknown when entry name is empty

Szymon Janc (1):
      Bluetooth: Fix legacy pairing with some devices

 drivers/bluetooth/ath3k.c                     |  2 ++
 drivers/bluetooth/btusb.c                     |  2 ++
 drivers/net/wireless/at76c50x-usb.c           |  2 +-
 drivers/net/wireless/ath/ath5k/base.c         |  6 ++----
 drivers/net/wireless/ath/ath5k/mac80211-ops.c |  5 ++---
 drivers/net/wireless/ath/ath9k/mac.c          | 18 +++++++++++------
 drivers/net/wireless/ath/ath9k/mac.h          |  1 +
 drivers/net/wireless/ath/ath9k/main.c         |  4 +++-
 drivers/net/wireless/ath/ath9k/pci.c          |  1 +
 drivers/net/wireless/ath/ath9k/recv.c         |  2 +-
 drivers/net/wireless/rndis_wlan.c             |  6 ++++--
 net/bluetooth/hci_event.c                     | 28 +++++++++++++++++++++------
 net/bluetooth/l2cap_core.c                    |  1 +
 net/bluetooth/l2cap_sock.c                    |  2 +-
 net/bluetooth/sco.c                           | 19 +++++++++---------
 net/bluetooth/smp.c                           |  5 ++++-
 16 files changed, 68 insertions(+), 36 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index 10308cd..11f36e5 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -79,6 +79,7 @@ static struct usb_device_id ath3k_table[] = {
 	{ USB_DEVICE(0x13d3, 0x3362) },
 	{ USB_DEVICE(0x0CF3, 0xE004) },
 	{ USB_DEVICE(0x0930, 0x0219) },
+	{ USB_DEVICE(0x0489, 0xe057) },
 
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xE02C) },
@@ -104,6 +105,7 @@ static struct usb_device_id ath3k_blist_tbl[] = {
 	{ USB_DEVICE(0x13d3, 0x3362), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0xe004), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0219), .driver_info = BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0489, 0xe057), .driver_info = BTUSB_ATH3012 },
 
 	/* Atheros AR5BBU22 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xE03C), .driver_info = BTUSB_ATH3012 },
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index e272214..cef3bac 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -98,6 +98,7 @@ static struct usb_device_id btusb_table[] = {
 	{ USB_DEVICE(0x0a5c, 0x21e6) },
 	{ USB_DEVICE(0x0a5c, 0x21e8) },
 	{ USB_DEVICE(0x0a5c, 0x21f3) },
+	{ USB_DEVICE(0x0a5c, 0x21f4) },
 	{ USB_DEVICE(0x413c, 0x8197) },
 
 	/* Foxconn - Hon Hai */
@@ -133,6 +134,7 @@ static struct usb_device_id blacklist_table[] = {
 	{ USB_DEVICE(0x13d3, 0x3362), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0xe004), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0219), .driver_info = BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0489, 0xe057), .driver_info = BTUSB_ATH3012 },
 
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xe02c), .driver_info = BTUSB_IGNORE },
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index efc162e..88b8d64 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -342,7 +342,7 @@ static int at76_dfu_get_status(struct usb_device *udev,
 	return ret;
 }
 
-static u8 at76_dfu_get_state(struct usb_device *udev, u8 *state)
+static int at76_dfu_get_state(struct usb_device *udev, u8 *state)
 {
 	int ret;
 
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 8c4c040..2aab20e 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -2056,9 +2056,7 @@ ath5k_beacon_update_timers(struct ath5k_hw *ah, u64 bc_tsf)
 void
 ath5k_beacon_config(struct ath5k_hw *ah)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&ah->block, flags);
+	spin_lock_bh(&ah->block);
 	ah->bmisscount = 0;
 	ah->imask &= ~(AR5K_INT_BMISS | AR5K_INT_SWBA);
 
@@ -2085,7 +2083,7 @@ ath5k_beacon_config(struct ath5k_hw *ah)
 
 	ath5k_hw_set_imr(ah, ah->imask);
 	mmiowb();
-	spin_unlock_irqrestore(&ah->block, flags);
+	spin_unlock_bh(&ah->block);
 }
 
 static void ath5k_tasklet_beacon(unsigned long data)
diff --git a/drivers/net/wireless/ath/ath5k/mac80211-ops.c b/drivers/net/wireless/ath/ath5k/mac80211-ops.c
index 260e7dc..d56453e 100644
--- a/drivers/net/wireless/ath/ath5k/mac80211-ops.c
+++ b/drivers/net/wireless/ath/ath5k/mac80211-ops.c
@@ -254,7 +254,6 @@ ath5k_bss_info_changed(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 	struct ath5k_vif *avf = (void *)vif->drv_priv;
 	struct ath5k_hw *ah = hw->priv;
 	struct ath_common *common = ath5k_hw_common(ah);
-	unsigned long flags;
 
 	mutex_lock(&ah->lock);
 
@@ -300,9 +299,9 @@ ath5k_bss_info_changed(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 	}
 
 	if (changes & BSS_CHANGED_BEACON) {
-		spin_lock_irqsave(&ah->block, flags);
+		spin_lock_bh(&ah->block);
 		ath5k_beacon_update(hw, vif);
-		spin_unlock_irqrestore(&ah->block, flags);
+		spin_unlock_bh(&ah->block);
 	}
 
 	if (changes & BSS_CHANGED_BEACON_ENABLED)
diff --git a/drivers/net/wireless/ath/ath9k/mac.c b/drivers/net/wireless/ath/ath9k/mac.c
index 7990cd5..b42be91 100644
--- a/drivers/net/wireless/ath/ath9k/mac.c
+++ b/drivers/net/wireless/ath/ath9k/mac.c
@@ -773,15 +773,10 @@ bool ath9k_hw_intrpend(struct ath_hw *ah)
 }
 EXPORT_SYMBOL(ath9k_hw_intrpend);
 
-void ath9k_hw_disable_interrupts(struct ath_hw *ah)
+void ath9k_hw_kill_interrupts(struct ath_hw *ah)
 {
 	struct ath_common *common = ath9k_hw_common(ah);
 
-	if (!(ah->imask & ATH9K_INT_GLOBAL))
-		atomic_set(&ah->intr_ref_cnt, -1);
-	else
-		atomic_dec(&ah->intr_ref_cnt);
-
 	ath_dbg(common, INTERRUPT, "disable IER\n");
 	REG_WRITE(ah, AR_IER, AR_IER_DISABLE);
 	(void) REG_READ(ah, AR_IER);
@@ -793,6 +788,17 @@ void ath9k_hw_disable_interrupts(struct ath_hw *ah)
 		(void) REG_READ(ah, AR_INTR_SYNC_ENABLE);
 	}
 }
+EXPORT_SYMBOL(ath9k_hw_kill_interrupts);
+
+void ath9k_hw_disable_interrupts(struct ath_hw *ah)
+{
+	if (!(ah->imask & ATH9K_INT_GLOBAL))
+		atomic_set(&ah->intr_ref_cnt, -1);
+	else
+		atomic_dec(&ah->intr_ref_cnt);
+
+	ath9k_hw_kill_interrupts(ah);
+}
 EXPORT_SYMBOL(ath9k_hw_disable_interrupts);
 
 void ath9k_hw_enable_interrupts(struct ath_hw *ah)
diff --git a/drivers/net/wireless/ath/ath9k/mac.h b/drivers/net/wireless/ath/ath9k/mac.h
index 0eba36d..4a745e6 100644
--- a/drivers/net/wireless/ath/ath9k/mac.h
+++ b/drivers/net/wireless/ath/ath9k/mac.h
@@ -738,6 +738,7 @@ bool ath9k_hw_intrpend(struct ath_hw *ah);
 void ath9k_hw_set_interrupts(struct ath_hw *ah);
 void ath9k_hw_enable_interrupts(struct ath_hw *ah);
 void ath9k_hw_disable_interrupts(struct ath_hw *ah);
+void ath9k_hw_kill_interrupts(struct ath_hw *ah);
 
 void ar9002_hw_attach_mac_ops(struct ath_hw *ah);
 
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 6049d8b..a22df74 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -462,8 +462,10 @@ irqreturn_t ath_isr(int irq, void *dev)
 	if (!ath9k_hw_intrpend(ah))
 		return IRQ_NONE;
 
-	if(test_bit(SC_OP_HW_RESET, &sc->sc_flags))
+	if (test_bit(SC_OP_HW_RESET, &sc->sc_flags)) {
+		ath9k_hw_kill_interrupts(ah);
 		return IRQ_HANDLED;
+	}
 
 	/*
 	 * Figure out the reason(s) for the interrupt.  Note
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index d455de9..a978984 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -321,6 +321,7 @@ static int ath_pci_suspend(struct device *device)
 	 * Otherwise the chip never moved to full sleep,
 	 * when no interface is up.
 	 */
+	ath9k_stop_btcoex(sc);
 	ath9k_hw_disable(sc->sc_ah);
 	ath9k_hw_setpower(sc->sc_ah, ATH9K_PM_FULL_SLEEP);
 
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 12aca02..4480c0c 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -1044,7 +1044,6 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 	struct ieee80211_hw *hw = sc->hw;
 	struct ieee80211_hdr *hdr;
 	int retval;
-	bool decrypt_error = false;
 	struct ath_rx_status rs;
 	enum ath9k_rx_qtype qtype;
 	bool edma = !!(ah->caps.hw_caps & ATH9K_HW_CAP_EDMA);
@@ -1066,6 +1065,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 	tsf_lower = tsf & 0xffffffff;
 
 	do {
+		bool decrypt_error = false;
 		/* If handling rx interrupt and flush is in progress => exit */
 		if (test_bit(SC_OP_RXFLUSH, &sc->sc_flags) && (flush == 0))
 			break;
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 241162e..7a4ae9e 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1803,6 +1803,7 @@ static struct ndis_80211_pmkid *update_pmkid(struct usbnet *usbdev,
 						struct cfg80211_pmksa *pmksa,
 						int max_pmkids)
 {
+	struct ndis_80211_pmkid *new_pmkids;
 	int i, err, newlen;
 	unsigned int count;
 
@@ -1833,11 +1834,12 @@ static struct ndis_80211_pmkid *update_pmkid(struct usbnet *usbdev,
 	/* add new pmkid */
 	newlen = sizeof(*pmkids) + (count + 1) * sizeof(pmkids->bssid_info[0]);
 
-	pmkids = krealloc(pmkids, newlen, GFP_KERNEL);
-	if (!pmkids) {
+	new_pmkids = krealloc(pmkids, newlen, GFP_KERNEL);
+	if (!new_pmkids) {
 		err = -ENOMEM;
 		goto error;
 	}
+	pmkids = new_pmkids;
 
 	pmkids->length = cpu_to_le32(newlen);
 	pmkids->bssid_info_count = cpu_to_le32(count + 1);
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 41ff978..715d7e3 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -1365,6 +1365,9 @@ static bool hci_resolve_next_name(struct hci_dev *hdev)
 		return false;
 
 	e = hci_inquiry_cache_lookup_resolve(hdev, BDADDR_ANY, NAME_NEEDED);
+	if (!e)
+		return false;
+
 	if (hci_resolve_name(hdev, e) == 0) {
 		e->name_state = NAME_PENDING;
 		return true;
@@ -1393,12 +1396,20 @@ static void hci_check_pending_name(struct hci_dev *hdev, struct hci_conn *conn,
 		return;
 
 	e = hci_inquiry_cache_lookup_resolve(hdev, bdaddr, NAME_PENDING);
-	if (e) {
+	/* If the device was not found in a list of found devices names of which
+	 * are pending. there is no need to continue resolving a next name as it
+	 * will be done upon receiving another Remote Name Request Complete
+	 * Event */
+	if (!e)
+		return;
+
+	list_del(&e->list);
+	if (name) {
 		e->name_state = NAME_KNOWN;
-		list_del(&e->list);
-		if (name)
-			mgmt_remote_name(hdev, bdaddr, ACL_LINK, 0x00,
-					 e->data.rssi, name, name_len);
+		mgmt_remote_name(hdev, bdaddr, ACL_LINK, 0x00,
+				 e->data.rssi, name, name_len);
+	} else {
+		e->name_state = NAME_NOT_KNOWN;
 	}
 
 	if (hci_resolve_next_name(hdev))
@@ -1762,7 +1773,12 @@ static void hci_conn_complete_evt(struct hci_dev *hdev, struct sk_buff *skb)
 		if (conn->type == ACL_LINK) {
 			conn->state = BT_CONFIG;
 			hci_conn_hold(conn);
-			conn->disc_timeout = HCI_DISCONN_TIMEOUT;
+
+			if (!conn->out && !hci_conn_ssp_enabled(conn) &&
+			    !hci_find_link_key(hdev, &ev->bdaddr))
+				conn->disc_timeout = HCI_PAIRING_TIMEOUT;
+			else
+				conn->disc_timeout = HCI_DISCONN_TIMEOUT;
 		} else
 			conn->state = BT_CONNECTED;
 
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index a8964db..daa149b 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1181,6 +1181,7 @@ static void l2cap_le_conn_ready(struct l2cap_conn *conn)
 	sk = chan->sk;
 
 	hci_conn_hold(conn->hcon);
+	conn->hcon->disc_timeout = HCI_DISCONN_TIMEOUT;
 
 	bacpy(&bt_sk(sk)->src, conn->src);
 	bacpy(&bt_sk(sk)->dst, conn->dst);
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index a4bb27e..b94abd3 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -1174,7 +1174,7 @@ static struct sock *l2cap_sock_alloc(struct net *net, struct socket *sock, int p
 
 	chan = l2cap_chan_create();
 	if (!chan) {
-		l2cap_sock_kill(sk);
+		sk_free(sk);
 		return NULL;
 	}
 
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 40bbe25..3589e21 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -131,6 +131,15 @@ static int sco_conn_del(struct hci_conn *hcon, int err)
 		sco_sock_clear_timer(sk);
 		sco_chan_del(sk, err);
 		bh_unlock_sock(sk);
+
+		sco_conn_lock(conn);
+		conn->sk = NULL;
+		sco_pi(sk)->conn = NULL;
+		sco_conn_unlock(conn);
+
+		if (conn->hcon)
+			hci_conn_put(conn->hcon);
+
 		sco_sock_kill(sk);
 	}
 
@@ -821,16 +830,6 @@ static void sco_chan_del(struct sock *sk, int err)
 
 	BT_DBG("sk %p, conn %p, err %d", sk, conn, err);
 
-	if (conn) {
-		sco_conn_lock(conn);
-		conn->sk = NULL;
-		sco_pi(sk)->conn = NULL;
-		sco_conn_unlock(conn);
-
-		if (conn->hcon)
-			hci_conn_put(conn->hcon);
-	}
