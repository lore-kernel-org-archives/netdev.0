From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-05-01
Date: Tue, 1 May 2012 14:31:58 -0400
Message-ID: <20120501183157.GA2987@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 076e7779c07c56c7fa593a28c71ea7432d0c7c95

Dave,

This is a batch of fixes intended for 3.4...

Part of these are Bluetooth -- Gustavo says:

"A few more fixes to 3.4, there is three new device id supported, a missing
break and a fix to retain key during the connection."

Along with those, we have some 802.11 fixes.  Felix gives us a fix
for sending EAP frames for AP VLAN interfaces.  Franky gives us
two brcmfmac fixes, one for missed event completions and another
for an improperly initialized function pointer.  Grazvydas Ignotas
gives us a couple of wl1251 fixes for some improperly freed memory.
Jonathan Bither gives us an ath5k fix for an AHB resource leak.
Seth Forshee gives us a b43 fix to avoid a crash when b43 fails to
properly initialize.  Finally, Wey-yi gives us a fixup for a previously
merged fix to use the correct firmware for certain iwlwifi devices.

The brcmfmac fixes are bigger than I would like to see.  But since
they are isolated to that driver and fix real problems, I felt they
were still acceptable.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 116a0fc31c6c9b8fc821be5a96e5bf0b43260131:

  netem: fix possible skb leak (2012-05-01 13:40:48 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

AceLan Kao (2):
      Bluetooth: Add support for Atheros [13d3:3362]
      Bluetooth: Add support for AR3012 [0cf3:e004]

Felix Fietkau (1):
      mac80211: fix AP mode EAP tx for VLAN stations

Franky Lin (2):
      brcm80211: fmac: fix SDIO function 0 register r/w issue
      brcm80211: fmac: fix missing completion events issue

Grazvydas Ignotas (2):
      wl1251: fix crash on remove due to premature kfree
      wl1251: fix crash on remove due to leftover work item

John W. Linville (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jonathan Bither (1):
      ath5k: add missing iounmap to AHB probe removal

Manoj Iyer (1):
      Bluetooth: btusb: Add vendor specific ID (0489 e042) for BCM20702A0

Seth Forshee (1):
      b43: only reload config after successful initialization

Steven Harms (1):
      Add Foxconn / Hon Hai IDs for btusb module

Szymon Janc (1):
      Bluetooth: Fix missing break in hci_cmd_complete_evt

Vishal Agarwal (2):
      Bluetooth: hci_persistent_key should return bool
      Bluetooth: Temporary keys should be retained during connection

Wey-Yi Guy (1):
      iwlwifi: use 6000G2B for 6030 device series

 drivers/bluetooth/ath3k.c                          |    4 +
 drivers/bluetooth/btusb.c                          |    6 ++
 drivers/net/wireless/ath/ath5k/ahb.c               |    1 +
 drivers/net/wireless/b43/main.c                    |   10 +++-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |    8 ++-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   63 ++++++++++++++++=
----
 drivers/net/wireless/iwlwifi/iwl-6000.c            |    4 +-
 drivers/net/wireless/wl1251/main.c                 |    1 +
 drivers/net/wireless/wl1251/sdio.c                 |    2 +-
 include/net/bluetooth/hci_core.h                   |    3 +-
 net/bluetooth/hci_core.c                           |   27 ++++----
 net/bluetooth/hci_event.c                          |    3 +
 net/bluetooth/mgmt.c                               |    2 +-
 net/mac80211/tx.c                                  |    3 +-
 14 files changed, 102 insertions(+), 35 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index ae9edca..57fd867 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -75,6 +75,8 @@ static struct usb_device_id ath3k_table[] =3D {
 	{ USB_DEVICE(0x0CF3, 0x311D) },
 	{ USB_DEVICE(0x13d3, 0x3375) },
 	{ USB_DEVICE(0x04CA, 0x3005) },
+	{ USB_DEVICE(0x13d3, 0x3362) },
+	{ USB_DEVICE(0x0CF3, 0xE004) },
=20
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xE02C) },
@@ -94,6 +96,8 @@ static struct usb_device_id ath3k_blist_tbl[] =3D {
 	{ USB_DEVICE(0x0cf3, 0x311D), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3375), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3005), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x13d3, 0x3362), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0xe004), .driver_info =3D BTUSB_ATH3012 },
=20
 	{ }	/* Terminating entry */
 };
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 3311b81..9217121 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -101,12 +101,16 @@ static struct usb_device_id btusb_table[] =3D {
 	{ USB_DEVICE(0x0c10, 0x0000) },
=20
 	/* Broadcom BCM20702A0 */
+	{ USB_DEVICE(0x0489, 0xe042) },
 	{ USB_DEVICE(0x0a5c, 0x21e3) },
 	{ USB_DEVICE(0x0a5c, 0x21e6) },
 	{ USB_DEVICE(0x0a5c, 0x21e8) },
 	{ USB_DEVICE(0x0a5c, 0x21f3) },
 	{ USB_DEVICE(0x413c, 0x8197) },
=20
+	/* Foxconn - Hon Hai */
+	{ USB_DEVICE(0x0489, 0xe033) },
+
 	{ }	/* Terminating entry */
 };
=20
@@ -133,6 +137,8 @@ static struct usb_device_id blacklist_table[] =3D {
 	{ USB_DEVICE(0x0cf3, 0x311d), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3375), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3005), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x13d3, 0x3362), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0xe004), .driver_info =3D BTUSB_ATH3012 },
=20
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xe02c), .driver_info =3D BTUSB_IGNORE },
diff --git a/drivers/net/wireless/ath/ath5k/ahb.c b/drivers/net/wireless/at=
h/ath5k/ahb.c
index 8c50d9d..aec33cc 100644
--- a/drivers/net/wireless/ath/ath5k/ahb.c
+++ b/drivers/net/wireless/ath/ath5k/ahb.c
@@ -220,6 +220,7 @@ static int ath_ahb_remove(struct platform_device *pdev)
 	}
=20
 	ath5k_deinit_ah(ah);
+	iounmap(ah->iobase);
 	platform_set_drvdata(pdev, NULL);
 	ieee80211_free_hw(hw);
=20
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/mai=
n.c
index c79e663..e4d6dc2 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -4827,8 +4827,14 @@ static int b43_op_start(struct ieee80211_hw *hw)
  out_mutex_unlock:
 	mutex_unlock(&wl->mutex);
=20
-	/* reload configuration */
-	b43_op_config(hw, ~0);
+	/*
+	 * Configuration may have been overwritten during initialization.
+	 * Reload the configuration, but only if initialization was
+	 * successful. Reloading the configuration after a failed init
+	 * may hang the system.
+	 */
+	if (!err)
+		b43_op_config(hw, ~0);
=20
 	return err;
 }
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c b/drive=
rs/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
index 4688904..758c115 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
@@ -108,9 +108,15 @@ static inline int brcmf_sdioh_f0_write_byte(struct brc=
mf_sdio_dev *sdiodev,
 			sdio_release_host(sdfunc);
 		}
 	} else if (regaddr =3D=3D SDIO_CCCR_ABORT) {
+		sdfunc =3D kmemdup(sdiodev->func[0], sizeof(struct sdio_func),
+				 GFP_KERNEL);
+		if (!sdfunc)
+			return -ENOMEM;
+		sdfunc->num =3D 0;
 		sdio_claim_host(sdfunc);
 		sdio_writeb(sdfunc, *byte, regaddr, &err_ret);
 		sdio_release_host(sdfunc);
+		kfree(sdfunc);
 	} else if (regaddr < 0xF0) {
 		brcmf_dbg(ERROR, "F0 Wr:0x%02x: write disallowed\n", regaddr);
 		err_ret =3D -EPERM;
@@ -486,7 +492,7 @@ static int brcmf_ops_sdio_probe(struct sdio_func *func,
 			kfree(bus_if);
 			return -ENOMEM;
 		}
-		sdiodev->func[0] =3D func->card->sdio_func[0];
+		sdiodev->func[0] =3D func;
 		sdiodev->func[1] =3D func;
 		sdiodev->bus_if =3D bus_if;
 		bus_if->bus_priv.sdio =3D sdiodev;
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/n=
et/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 2bf5dda..eb3829b 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -574,6 +574,8 @@ struct brcmf_sdio {
=20
 	struct task_struct *dpc_tsk;
 	struct completion dpc_wait;
+	struct list_head dpc_tsklst;
+	spinlock_t dpc_tl_lock;
=20
 	struct semaphore sdsem;
=20
@@ -2594,29 +2596,58 @@ clkwait:
 	return resched;
 }
=20
+static inline void brcmf_sdbrcm_adddpctsk(struct brcmf_sdio *bus)
+{
+	struct list_head *new_hd;
+	unsigned long flags;
+
+	if (in_interrupt())
+		new_hd =3D kzalloc(sizeof(struct list_head), GFP_ATOMIC);
+	else
+		new_hd =3D kzalloc(sizeof(struct list_head), GFP_KERNEL);
+	if (new_hd =3D=3D NULL)
+		return;
+
+	spin_lock_irqsave(&bus->dpc_tl_lock, flags);
+	list_add_tail(new_hd, &bus->dpc_tsklst);
+	spin_unlock_irqrestore(&bus->dpc_tl_lock, flags);
+}
+
 static int brcmf_sdbrcm_dpc_thread(void *data)
 {
 	struct brcmf_sdio *bus =3D (struct brcmf_sdio *) data;
+	struct list_head *cur_hd, *tmp_hd;
+	unsigned long flags;
=20
 	allow_signal(SIGTERM);
 	/* Run until signal received */
 	while (1) {
 		if (kthread_should_stop())
 			break;
-		if (!wait_for_completion_interruptible(&bus->dpc_wait)) {
-			/* Call bus dpc unless it indicated down
-			(then clean stop) */
-			if (bus->sdiodev->bus_if->state !=3D BRCMF_BUS_DOWN) {
-				if (brcmf_sdbrcm_dpc(bus))
-					complete(&bus->dpc_wait);
-			} else {
+
+		if (list_empty(&bus->dpc_tsklst))
+			if (wait_for_completion_interruptible(&bus->dpc_wait))
+				break;
+
+		spin_lock_irqsave(&bus->dpc_tl_lock, flags);
+		list_for_each_safe(cur_hd, tmp_hd, &bus->dpc_tsklst) {
+			spin_unlock_irqrestore(&bus->dpc_tl_lock, flags);
+
+			if (bus->sdiodev->bus_if->state =3D=3D BRCMF_BUS_DOWN) {
 				/* after stopping the bus, exit thread */
 				brcmf_sdbrcm_bus_stop(bus->sdiodev->dev);
 				bus->dpc_tsk =3D NULL;
 				break;
 			}
-		} else
-			break;
+
+			if (brcmf_sdbrcm_dpc(bus))
+				brcmf_sdbrcm_adddpctsk(bus);
+
+			spin_lock_irqsave(&bus->dpc_tl_lock, flags);
+			list_del(cur_hd);
+			kfree(cur_hd);
+		}
+		spin_unlock_irqrestore(&bus->dpc_tl_lock, flags);
 	}
 	return 0;
 }
@@ -2669,8 +2700,10 @@ static int brcmf_sdbrcm_bus_txdata(struct device *de=
v, struct sk_buff *pkt)
 	/* Schedule DPC if needed to send queued packet(s) */
 	if (!bus->dpc_sched) {
 		bus->dpc_sched =3D true;
-		if (bus->dpc_tsk)
+		if (bus->dpc_tsk) {
+			brcmf_sdbrcm_adddpctsk(bus);
 			complete(&bus->dpc_wait);
+		}
 	}
=20
 	return ret;
@@ -3514,8 +3547,10 @@ void brcmf_sdbrcm_isr(void *arg)
 		brcmf_dbg(ERROR, "isr w/o interrupt configured!\n");
=20
 	bus->dpc_sched =3D true;
-	if (bus->dpc_tsk)
+	if (bus->dpc_tsk) {
+		brcmf_sdbrcm_adddpctsk(bus);
 		complete(&bus->dpc_wait);
+	}
 }
=20
 static bool brcmf_sdbrcm_bus_watchdog(struct brcmf_sdio *bus)
@@ -3559,8 +3594,10 @@ static bool brcmf_sdbrcm_bus_watchdog(struct brcmf_s=
dio *bus)
 				bus->ipend =3D true;
=20
 				bus->dpc_sched =3D true;
-				if (bus->dpc_tsk)
+				if (bus->dpc_tsk) {
+					brcmf_sdbrcm_adddpctsk(bus);
 					complete(&bus->dpc_wait);
+				}
 			}
 		}
=20
@@ -3897,6 +3934,8 @@ void *brcmf_sdbrcm_probe(u32 regsva, struct brcmf_sdi=
o_dev *sdiodev)
 	}
 	/* Initialize DPC thread */
 	init_completion(&bus->dpc_wait);
+	INIT_LIST_HEAD(&bus->dpc_tsklst);
+	spin_lock_init(&bus->dpc_tl_lock);
 	bus->dpc_tsk =3D kthread_run(brcmf_sdbrcm_dpc_thread,
 				   bus, "brcmf_dpc");
 	if (IS_ERR(bus->dpc_tsk)) {
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless=
/iwlwifi/iwl-6000.c
index b1b6951..f0c9150 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -336,7 +336,7 @@ static const struct iwl_bt_params iwl6000_bt_params =3D=
 {
 #define IWL_DEVICE_6005						\
 	.fw_name_pre =3D IWL6005_FW_PRE,				\
 	.ucode_api_max =3D IWL6000G2_UCODE_API_MAX,		\
-	.ucode_api_ok =3D IWL6000G2B_UCODE_API_OK,		\
+	.ucode_api_ok =3D IWL6000G2_UCODE_API_OK,			\
 	.ucode_api_min =3D IWL6000G2_UCODE_API_MIN,		\
 	.max_inst_size =3D IWL60_RTC_INST_SIZE,			\
 	.max_data_size =3D IWL60_RTC_DATA_SIZE,			\
@@ -390,7 +390,7 @@ const struct iwl_cfg iwl6005_2agn_mow2_cfg =3D {
 #define IWL_DEVICE_6030						\
 	.fw_name_pre =3D IWL6030_FW_PRE,				\
 	.ucode_api_max =3D IWL6000G2_UCODE_API_MAX,		\
-	.ucode_api_ok =3D IWL6000G2_UCODE_API_OK,			\
+	.ucode_api_ok =3D IWL6000G2B_UCODE_API_OK,		\
 	.ucode_api_min =3D IWL6000G2_UCODE_API_MIN,		\
 	.max_inst_size =3D IWL60_RTC_INST_SIZE,			\
 	.max_data_size =3D IWL60_RTC_DATA_SIZE,			\
diff --git a/drivers/net/wireless/wl1251/main.c b/drivers/net/wireless/wl12=
51/main.c
index 41302c7..d1afb8e 100644
--- a/drivers/net/wireless/wl1251/main.c
+++ b/drivers/net/wireless/wl1251/main.c
@@ -479,6 +479,7 @@ static void wl1251_op_stop(struct ieee80211_hw *hw)
 	cancel_work_sync(&wl->irq_work);
 	cancel_work_sync(&wl->tx_work);
 	cancel_work_sync(&wl->filter_work);
+	cancel_delayed_work_sync(&wl->elp_work);
=20
 	mutex_lock(&wl->mutex);
=20
diff --git a/drivers/net/wireless/wl1251/sdio.c b/drivers/net/wireless/wl12=
51/sdio.c
index f786942..1b851f6 100644
--- a/drivers/net/wireless/wl1251/sdio.c
+++ b/drivers/net/wireless/wl1251/sdio.c
@@ -315,8 +315,8 @@ static void __devexit wl1251_sdio_remove(struct sdio_fu=
nc *func)
=20
 	if (wl->irq)
 		free_irq(wl->irq, wl);
-	kfree(wl_sdio);
 	wl1251_free_hw(wl);
+	kfree(wl_sdio);
=20
 	sdio_claim_host(func);
 	sdio_release_irq(func);
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_c=
ore.h
index 6822d25..db1c5df 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -314,6 +314,7 @@ struct hci_conn {
=20
 	__u8		remote_cap;
 	__u8		remote_auth;
+	bool		flush_key;
=20
 	unsigned int	sent;
=20
@@ -980,7 +981,7 @@ int mgmt_discoverable(struct hci_dev *hdev, u8 discover=
able);
 int mgmt_connectable(struct hci_dev *hdev, u8 connectable);
 int mgmt_write_scan_failed(struct hci_dev *hdev, u8 scan, u8 status);
 int mgmt_new_link_key(struct hci_dev *hdev, struct link_key *key,
-		      u8 persistent);
+		      bool persistent);
 int mgmt_device_connected(struct hci_dev *hdev, bdaddr_t *bdaddr, u8 link_=
type,
 			  u8 addr_type, u32 flags, u8 *name, u8 name_len,
 			  u8 *dev_class);
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 92a857e..edfd61a 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1215,40 +1215,40 @@ struct link_key *hci_find_link_key(struct hci_dev *=
hdev, bdaddr_t *bdaddr)
 	return NULL;
 }
=20
-static int hci_persistent_key(struct hci_dev *hdev, struct hci_conn *conn,
+static bool hci_persistent_key(struct hci_dev *hdev, struct hci_conn *conn,
 						u8 key_type, u8 old_key_type)
 {
 	/* Legacy key */
 	if (key_type < 0x03)
-		return 1;
+		return true;
=20
 	/* Debug keys are insecure so don't store them persistently */
 	if (key_type =3D=3D HCI_LK_DEBUG_COMBINATION)
-		return 0;
+		return false;
=20
 	/* Changed combination key and there's no previous one */
 	if (key_type =3D=3D HCI_LK_CHANGED_COMBINATION && old_key_type =3D=3D 0xf=
f)
-		return 0;
+		return false;
=20
 	/* Security mode 3 case */
 	if (!conn)
-		return 1;
+		return true;
=20
 	/* Neither local nor remote side had no-bonding as requirement */
 	if (conn->auth_type > 0x01 && conn->remote_auth > 0x01)
-		return 1;
+		return true;
=20
 	/* Local side had dedicated bonding as requirement */
 	if (conn->auth_type =3D=3D 0x02 || conn->auth_type =3D=3D 0x03)
-		return 1;
+		return true;
=20
 	/* Remote side had dedicated bonding as requirement */
 	if (conn->remote_auth =3D=3D 0x02 || conn->remote_auth =3D=3D 0x03)
-		return 1;
+		return true;
=20
 	/* If none of the above criteria match, then don't store the key
 	 * persistently */
-	return 0;
+	return false;
 }
=20
 struct smp_ltk *hci_find_ltk(struct hci_dev *hdev, __le16 ediv, u8 rand[8])
@@ -1285,7 +1285,8 @@ int hci_add_link_key(struct hci_dev *hdev, struct hci=
_conn *conn, int new_key,
 		     bdaddr_t *bdaddr, u8 *val, u8 type, u8 pin_len)
 {
 	struct link_key *key, *old_key;
-	u8 old_key_type, persistent;
+	u8 old_key_type;
+	bool persistent;
=20
 	old_key =3D hci_find_link_key(hdev, bdaddr);
 	if (old_key) {
@@ -1328,10 +1329,8 @@ int hci_add_link_key(struct hci_dev *hdev, struct hc=
i_conn *conn, int new_key,
=20
 	mgmt_new_link_key(hdev, key, persistent);
=20
-	if (!persistent) {
-		list_del(&key->list);
-		kfree(key);
-	}
+	if (conn)
+		conn->flush_key =3D !persistent;
=20
 	return 0;
 }
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index b375310..6c06525 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -1901,6 +1901,8 @@ static inline void hci_disconn_complete_evt(struct hc=
i_dev *hdev, struct sk_buff
 	}
=20
 	if (ev->status =3D=3D 0) {
+		if (conn->type =3D=3D ACL_LINK && conn->flush_key)
+			hci_remove_link_key(hdev, &conn->dst);
 		hci_proto_disconn_cfm(conn, ev->reason);
 		hci_conn_del(conn);
 	}
@@ -2311,6 +2313,7 @@ static inline void hci_cmd_complete_evt(struct hci_de=
v *hdev, struct sk_buff *sk
=20
 	case HCI_OP_USER_PASSKEY_NEG_REPLY:
 		hci_cc_user_passkey_neg_reply(hdev, skb);
+		break;
=20
 	case HCI_OP_LE_SET_SCAN_PARAM:
 		hci_cc_le_set_scan_param(hdev, skb);
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 4ef275c..4bb03b1 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -2884,7 +2884,7 @@ int mgmt_write_scan_failed(struct hci_dev *hdev, u8 s=
can, u8 status)
 	return 0;
 }
=20
-int mgmt_new_link_key(struct hci_dev *hdev, struct link_key *key, u8 persi=
stent)
+int mgmt_new_link_key(struct hci_dev *hdev, struct link_key *key, bool per=
sistent)
 {
 	struct mgmt_ev_new_link_key ev;
=20
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 782a601..e76facc 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1158,7 +1158,8 @@ ieee80211_tx_prepare(struct ieee80211_sub_if_data *sd=
ata,
 		tx->sta =3D rcu_dereference(sdata->u.vlan.sta);
 		if (!tx->sta && sdata->dev->ieee80211_ptr->use_4addr)
 			return TX_DROP;
-	} else if (info->flags & IEEE80211_TX_CTL_INJECTED) {
+	} else if (info->flags & IEEE80211_TX_CTL_INJECTED ||
+		   tx->sdata->control_port_protocol =3D=3D tx->skb->protocol) {
 		tx->sta =3D sta_info_get_bss(sdata, hdr->addr1);
 	}
 	if (!tx->sta)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPoCwdAAoJEJctW/TcYTgGDCYP/2cC8KifDfYOawqcRNNq/m0l
D47jq63ME0wYX60RylRn3F4kVQYfNL21hAqYrOrectvY+/w4GCC/hV9gxby/Qzr2
hipQmsNfaurfBHccue+TV22ojlc53LXkh9gHa9Bj/d/7+EMc6D96DD2Cvo3f7+Lc
E34IF99giJMVyWKP2dNiABnuZm4cM8A+La8hwldTGkKSVS0t3m4CUR8NzIl4hBO9
ybBJaOg/MPF5Ns5LkAup5fv1mejDUeeqocoWZNfrX7Vq9K88kLBOR0ZQNjA4UFtY
PTOAYCx6v+O9KEs+ky3czuBPLpY4vPySf9lV2JwhfPU04qri0uAE3xvnFpjEHiVs
AQ/F95FsMZgq+kp/rdONTpVanHPGr9s6Kaj2gAsDx1KqFVP+TtFWo8Mhak8JTDJL
UoviF2oWYndbJjO9n/q27ua1bRyK7I7Igv+DPGJKpE+VEDK+FRuZoh50YOgFFO1n
8sMGxQM5iKcIoUWQMdyTAduXAjZJkfgifyKp+iI1QOkvIVj+epu2U3uBZUGwcyCC
k+ewcBAbap1ek/+CpJGLM/5RsTcuk4+sv2wjgDheoDZaC5qntAlHXtDp1ioa/sm3
4sOwxPBTIBikL6uj5hd4Fuc6IQw6dI5OP6XsepXUFNv4aeZKX203zpRoTokoM8Vk
PyVUIgB+Z9O1V9XA5Ieu
=pZ9P
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--
