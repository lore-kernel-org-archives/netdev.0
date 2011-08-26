From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2011-08-26
Date: Fri, 26 Aug 2011 11:17:58 -0400
Message-ID: <20110826151758.GH2579@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is a round of fixes intended for 3.1...

The biggest portion are Bluetooth fixes.  Gustavo describes them
thusly:

	Some fixes for 3.1! It looks a lot of fixes but some of them
	are the same fix applied to different files. Here we have a
	fix for a wrong timer value from Chen Ganir, a lock balance
	fix from Dan Carpenter, regression fix with the HCI Reset
	command from Szymon Janc, a fix to not show error messages on
	btusb device disconnect from Paul Bolle. Support for Toshiba
	AR30XX from Ricardo Mendoza. And finally a bunch of fixes
	from Peter Hurley, there are some lost wake up, deadlocks and
	memort leaks fixes. Most of them fixes regressions introduced
	by the move to the kthread API.

In addition, we have a locking fix for carl9170, a bcma fix to enable
driver loading via udev, a wl12xx fix to properly advertise the
maximum number of SSIDs for scanning, another wl12xx fix to properly
check a return code in order to avoid a possible oops, and a third
wl12xx fix to remove a broken testmode function with locking problems
(among others).  Also included is a suspend/resume fix for ath9k,
a fix for reading improper MAC addresses on ath9k, a suspend/resume
fix for mac80211, and a suspend/resume fix for rt2x00 as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit bc909d9ddbf7778371e36a651d6e4194b1cc7d4c:

  sendmmsg/sendmsg: fix unsafe user pointer access (2011-08-24 19:45:03 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

Alexey Khoroshilov (1):
      carl9170: Fix mismatch in carl9170_op_set_key mutex lock-unlock

Chen Ganir (1):
      Bluetooth: Fixed wrong L2CAP Sock timer value

Dan Carpenter (1):
      Bluetooth: unlock if allocation fails in hci_blacklist_add()

David Woodhouse (1):
      bcma: add uevent to the bus, to autoload drivers

Ido Yariv (2):
      wl12xx: Remove obsolete testmode NVS push command
      wl12xx: Fix validation of pm_runtime_get_sync return value

John W. Linville (2):
      Merge branch 'master' of master.kernel.org:/.../padovan/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Luciano Coelho (1):
      wl12xx: add max_sched_scan_ssids value to the hw description

Mohammed Shafi Shajakhan (1):
      ath9k: Fix PS wrappers in ath9k_set_coverage_class

Paul Bolle (1):
      Bluetooth: btusb: be quiet on device disconnect

Peter Hurley (15):
      Bluetooth: rfcomm: Remove unnecessary krfcommd event
      Bluetooth: rfcomm: Fix lost wakeups waiting to accept socket
      Bluetooth: Fix lost wakeups waiting for sock state change
      Bluetooth: l2cap: Fix lost wakeups waiting to accept socket
      Bluetooth: sco: Fix lost wakeups waiting to accept socket
      Bluetooth: bnep: Fix lost wakeup of session thread
      Bluetooth: cmtp: Fix lost wakeup of session thread
      Bluetooth: l2cap: Fix lost wakeup waiting for ERTM acks
      Bluetooth: bnep: Fix deadlock in session deletion
      Bluetooth: cmtp: Fix deadlock in session deletion
      Bluetooth: hidp: Fix session cleanup on failed conn add
      Bluetooth: hidp: Fix memory leak of cached report descriptor
      Bluetooth: hidp: Only free input device if failed register
      Bluetooth: hidp: Don't release device ref if never held
      Bluetooth: cmtp: Fix session cleanup on failed conn add

Ricardo Mendoza (1):
      Bluetooth: Add Toshiba laptops AR30XX device ID

Senthil Balasubramanian (1):
      ath9k_hw: Fix STA (AR9485) bringup issue due to incorrect MAC address

Stanislaw Gruszka (2):
      mac80211: fix suspend/resume races with unregister hw
      rt2x00: do not drop usb dev reference counter on suspend

Szymon Janc (1):
      Bluetooth: Don't use cmd_timer to timeout HCI reset command

 drivers/bcma/main.c                            |   12 ++++++
 drivers/bluetooth/ath3k.c                      |    1 +
 drivers/bluetooth/btusb.c                      |   13 +++++--
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |    2 +-
 drivers/net/wireless/ath/ath9k/main.c          |    4 ++
 drivers/net/wireless/ath/carl9170/main.c       |    4 ++-
 drivers/net/wireless/rt2x00/rt2x00usb.c        |   14 +-------
 drivers/net/wireless/wl12xx/main.c             |    1 +
 drivers/net/wireless/wl12xx/sdio.c             |    2 +-
 drivers/net/wireless/wl12xx/testmode.c         |   45 ------------------------
 include/net/cfg80211.h                         |    3 ++
 net/bluetooth/af_bluetooth.c                   |    6 ++--
 net/bluetooth/bnep/bnep.h                      |    1 +
 net/bluetooth/bnep/core.c                      |   13 ++++---
 net/bluetooth/cmtp/capi.c                      |    3 +-
 net/bluetooth/cmtp/cmtp.h                      |    1 +
 net/bluetooth/cmtp/core.c                      |   20 ++++++----
 net/bluetooth/hci_core.c                       |    8 +++--
 net/bluetooth/hidp/core.c                      |   19 +++++-----
 net/bluetooth/l2cap_core.c                     |    6 ++--
 net/bluetooth/l2cap_sock.c                     |   30 ++++++++--------
 net/bluetooth/rfcomm/core.c                    |   17 ++++-----
 net/bluetooth/rfcomm/sock.c                    |   28 +++++++-------
 net/bluetooth/sco.c                            |   28 +++++++-------
 net/mac80211/main.c                            |    2 +-
 net/wireless/core.c                            |    7 ++++
 net/wireless/sysfs.c                           |    6 ++-
 27 files changed, 143 insertions(+), 153 deletions(-)

diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index 873e2e4..73b7b1a 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -15,6 +15,7 @@ MODULE_LICENSE("GPL");
 static int bcma_bus_match(struct device *dev, struct device_driver *drv);
 static int bcma_device_probe(struct device *dev);
 static int bcma_device_remove(struct device *dev);
+static int bcma_device_uevent(struct device *dev, struct kobj_uevent_env *env);
 
 static ssize_t manuf_show(struct device *dev, struct device_attribute *attr, char *buf)
 {
@@ -49,6 +50,7 @@ static struct bus_type bcma_bus_type = {
 	.match		= bcma_bus_match,
 	.probe		= bcma_device_probe,
 	.remove		= bcma_device_remove,
+	.uevent		= bcma_device_uevent,
 	.dev_attrs	= bcma_device_attrs,
 };
 
@@ -227,6 +229,16 @@ static int bcma_device_remove(struct device *dev)
 	return 0;
 }
 
+static int bcma_device_uevent(struct device *dev, struct kobj_uevent_env *env)
+{
+	struct bcma_device *core = container_of(dev, struct bcma_device, dev);
+
+	return add_uevent_var(env,
+			      "MODALIAS=bcma:m%04Xid%04Xrev%02Xcl%02X",
+			      core->id.manuf, core->id.id,
+			      core->id.rev, core->id.class);
+}
+
 static int __init bcma_modinit(void)
 {
 	int err;
diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index a585473..db7cb81 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -63,6 +63,7 @@ static struct usb_device_id ath3k_table[] = {
 	/* Atheros AR3011 with sflash firmware*/
 	{ USB_DEVICE(0x0CF3, 0x3002) },
 	{ USB_DEVICE(0x13d3, 0x3304) },
+	{ USB_DEVICE(0x0930, 0x0215) },
 
 	/* Atheros AR9285 Malbec with sflash firmware */
 	{ USB_DEVICE(0x03F0, 0x311D) },
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 91d13a9..3ef4760 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -106,6 +106,7 @@ static struct usb_device_id blacklist_table[] = {
 	/* Atheros 3011 with sflash firmware */
 	{ USB_DEVICE(0x0cf3, 0x3002), .driver_info = BTUSB_IGNORE },
 	{ USB_DEVICE(0x13d3, 0x3304), .driver_info = BTUSB_IGNORE },
+	{ USB_DEVICE(0x0930, 0x0215), .driver_info = BTUSB_IGNORE },
 
 	/* Atheros AR9285 Malbec with sflash firmware */
 	{ USB_DEVICE(0x03f0, 0x311d), .driver_info = BTUSB_IGNORE },
@@ -256,7 +257,9 @@ static void btusb_intr_complete(struct urb *urb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
-		if (err != -EPERM)
+		/* -EPERM: urb is being killed;
+		 * -ENODEV: device got disconnected */
+		if (err != -EPERM && err != -ENODEV)
 			BT_ERR("%s urb %p failed to resubmit (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
@@ -341,7 +344,9 @@ static void btusb_bulk_complete(struct urb *urb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
-		if (err != -EPERM)
+		/* -EPERM: urb is being killed;
+		 * -ENODEV: device got disconnected */
+		if (err != -EPERM && err != -ENODEV)
 			BT_ERR("%s urb %p failed to resubmit (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
@@ -431,7 +436,9 @@ static void btusb_isoc_complete(struct urb *urb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
-		if (err != -EPERM)
+		/* -EPERM: urb is being killed;
+		 * -ENODEV: device got disconnected */
+		if (err != -EPERM && err != -ENODEV)
 			BT_ERR("%s urb %p failed to resubmit (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index c34bef1..1b94003 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -69,7 +69,7 @@ static int ar9003_hw_power_interpolate(int32_t x,
 static const struct ar9300_eeprom ar9300_default = {
 	.eepromVersion = 2,
 	.templateVersion = 2,
-	.macAddr = {1, 2, 3, 4, 5, 6},
+	.macAddr = {0, 2, 3, 4, 5, 6},
 	.custData = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 		     0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
 	.baseEepHeader = {
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 9098aaa..6530694 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -2283,7 +2283,11 @@ static void ath9k_set_coverage_class(struct ieee80211_hw *hw, u8 coverage_class)
 
 	mutex_lock(&sc->mutex);
 	ah->coverage_class = coverage_class;
+
+	ath9k_ps_wakeup(sc);
 	ath9k_hw_init_global_settings(ah);
+	ath9k_ps_restore(sc);
+
 	mutex_unlock(&sc->mutex);
 }
 
diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
index 0122930..0474e663 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -1066,8 +1066,10 @@ static int carl9170_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 	 * the high througput speed in 802.11n networks.
 	 */
 
-	if (!is_main_vif(ar, vif))
+	if (!is_main_vif(ar, vif)) {
+		mutex_lock(&ar->mutex);
 		goto err_softw;
+	}
 
 	/*
 	 * While the hardware supports *catch-all* key, for offloading
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index 7fbb55c..1e31050 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -871,18 +871,8 @@ int rt2x00usb_suspend(struct usb_interface *usb_intf, pm_message_t state)
 {
 	struct ieee80211_hw *hw = usb_get_intfdata(usb_intf);
 	struct rt2x00_dev *rt2x00dev = hw->priv;
-	int retval;
-
-	retval = rt2x00lib_suspend(rt2x00dev, state);
-	if (retval)
-		return retval;
 
-	/*
-	 * Decrease usbdev refcount.
-	 */
-	usb_put_dev(interface_to_usbdev(usb_intf));
-
-	return 0;
+	return rt2x00lib_suspend(rt2x00dev, state);
 }
 EXPORT_SYMBOL_GPL(rt2x00usb_suspend);
 
@@ -891,8 +881,6 @@ int rt2x00usb_resume(struct usb_interface *usb_intf)
 	struct ieee80211_hw *hw = usb_get_intfdata(usb_intf);
 	struct rt2x00_dev *rt2x00dev = hw->priv;
 
-	usb_get_dev(interface_to_usbdev(usb_intf));
-
 	return rt2x00lib_resume(rt2x00dev);
 }
 EXPORT_SYMBOL_GPL(rt2x00usb_resume);
diff --git a/drivers/net/wireless/wl12xx/main.c b/drivers/net/wireless/wl12xx/main.c
index e58c22d..b70ae40 100644
--- a/drivers/net/wireless/wl12xx/main.c
+++ b/drivers/net/wireless/wl12xx/main.c
@@ -4283,6 +4283,7 @@ int wl1271_init_ieee80211(struct wl1271 *wl)
 	wl->hw->wiphy->interface_modes = BIT(NL80211_IFTYPE_STATION) |
 		BIT(NL80211_IFTYPE_ADHOC) | BIT(NL80211_IFTYPE_AP);
 	wl->hw->wiphy->max_scan_ssids = 1;
+	wl->hw->wiphy->max_sched_scan_ssids = 1;
 	/*
 	 * Maximum length of elements in scanning probe request templates
 	 * should be the maximum length possible for a template, without
diff --git a/drivers/net/wireless/wl12xx/sdio.c b/drivers/net/wireless/wl12xx/sdio.c
index 5cf18c2..fb1fd5a 100644
--- a/drivers/net/wireless/wl12xx/sdio.c
+++ b/drivers/net/wireless/wl12xx/sdio.c
@@ -164,7 +164,7 @@ static int wl1271_sdio_power_on(struct wl1271 *wl)
 	/* If enabled, tell runtime PM not to power off the card */
 	if (pm_runtime_enabled(&func->dev)) {
 		ret = pm_runtime_get_sync(&func->dev);
-		if (ret)
+		if (ret < 0)
 			goto out;
 	} else {
 		/* Runtime PM is disabled: power up the card manually */
diff --git a/drivers/net/wireless/wl12xx/testmode.c b/drivers/net/wireless/wl12xx/testmode.c
index 88add68..4ae8eff 100644
--- a/drivers/net/wireless/wl12xx/testmode.c
+++ b/drivers/net/wireless/wl12xx/testmode.c
@@ -36,7 +36,6 @@ enum wl1271_tm_commands {
 	WL1271_TM_CMD_TEST,
 	WL1271_TM_CMD_INTERROGATE,
 	WL1271_TM_CMD_CONFIGURE,
-	WL1271_TM_CMD_NVS_PUSH,
 	WL1271_TM_CMD_SET_PLT_MODE,
 	WL1271_TM_CMD_RECOVER,
 
@@ -190,48 +189,6 @@ static int wl1271_tm_cmd_configure(struct wl1271 *wl, struct nlattr *tb[])
 	return 0;
 }
 
-static int wl1271_tm_cmd_nvs_push(struct wl1271 *wl, struct nlattr *tb[])
-{
-	int ret = 0;
-	size_t len;
-	void *buf;
-
-	wl1271_debug(DEBUG_TESTMODE, "testmode cmd nvs push");
-
-	if (!tb[WL1271_TM_ATTR_DATA])
-		return -EINVAL;
-
-	buf = nla_data(tb[WL1271_TM_ATTR_DATA]);
-	len = nla_len(tb[WL1271_TM_ATTR_DATA]);
-
-	mutex_lock(&wl->mutex);
-
-	kfree(wl->nvs);
-
-	if ((wl->chip.id == CHIP_ID_1283_PG20) &&
-	    (len != sizeof(struct wl128x_nvs_file)))
-		return -EINVAL;
-	else if (len != sizeof(struct wl1271_nvs_file))
-		return -EINVAL;
-
-	wl->nvs = kzalloc(len, GFP_KERNEL);
-	if (!wl->nvs) {
-		wl1271_error("could not allocate memory for the nvs file");
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	memcpy(wl->nvs, buf, len);
-	wl->nvs_len = len;
-
-	wl1271_debug(DEBUG_TESTMODE, "testmode pushed nvs");
-
-out:
-	mutex_unlock(&wl->mutex);
-
-	return ret;
-}
-
 static int wl1271_tm_cmd_set_plt_mode(struct wl1271 *wl, struct nlattr *tb[])
 {
 	u32 val;
@@ -288,8 +245,6 @@ int wl1271_tm_cmd(struct ieee80211_hw *hw, void *data, int len)
 		return wl1271_tm_cmd_interrogate(wl, tb);
 	case WL1271_TM_CMD_CONFIGURE:
 		return wl1271_tm_cmd_configure(wl, tb);
-	case WL1271_TM_CMD_NVS_PUSH:
-		return wl1271_tm_cmd_nvs_push(wl, tb);
 	case WL1271_TM_CMD_SET_PLT_MODE:
 		return wl1271_tm_cmd_set_plt_mode(wl, tb);
 	case WL1271_TM_CMD_RECOVER:
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index d17f47f..408ae48 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -1865,6 +1865,9 @@ struct wiphy {
 	 * you need use set_wiphy_dev() (see below) */
 	struct device dev;
 
+	/* protects ->resume, ->suspend sysfs callbacks against unregister hw */
+	bool registered;
+
 	/* dir in debugfs: ieee80211/<wiphyname> */
 	struct dentry *debugfsdir;
 
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 8add9b4..117e0d1 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -494,9 +494,8 @@ int bt_sock_wait_state(struct sock *sk, int state, unsigned long timeo)
 	BT_DBG("sk %p", sk);
 
 	add_wait_queue(sk_sleep(sk), &wait);
+	set_current_state(TASK_INTERRUPTIBLE);
 	while (sk->sk_state != state) {
-		set_current_state(TASK_INTERRUPTIBLE);
-
 		if (!timeo) {
 			err = -EINPROGRESS;
 			break;
@@ -510,12 +509,13 @@ int bt_sock_wait_state(struct sock *sk, int state, unsigned long timeo)
 		release_sock(sk);
 		timeo = schedule_timeout(timeo);
 		lock_sock(sk);
+		set_current_state(TASK_INTERRUPTIBLE);
 
 		err = sock_error(sk);
 		if (err)
 			break;
 	}
-	set_current_state(TASK_RUNNING);
+	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(sk_sleep(sk), &wait);
 	return err;
 }
diff --git a/net/bluetooth/bnep/bnep.h b/net/bluetooth/bnep/bnep.h
index 8e6c061..e7ee531 100644
--- a/net/bluetooth/bnep/bnep.h
+++ b/net/bluetooth/bnep/bnep.h
@@ -155,6 +155,7 @@ struct bnep_session {
 	unsigned int  role;
 	unsigned long state;
 	unsigned long flags;
+	atomic_t      terminate;
 	struct task_struct *task;
 
 	struct ethhdr eh;
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index ca39fcf..d9edfe8 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -484,9 +484,11 @@ static int bnep_session(void *arg)
 
 	init_waitqueue_entry(&wait, current);
 	add_wait_queue(sk_sleep(sk), &wait);
-	while (!kthread_should_stop()) {
+	while (1) {
 		set_current_state(TASK_INTERRUPTIBLE);
 
+		if (atomic_read(&s->terminate))
+			break;
 		/* RX */
 		while ((skb = skb_dequeue(&sk->sk_receive_queue))) {
 			skb_orphan(skb);
@@ -504,7 +506,7 @@ static int bnep_session(void *arg)
 
 		schedule();
 	}
-	set_current_state(TASK_RUNNING);
+	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(sk_sleep(sk), &wait);
 
 	/* Cleanup session */
@@ -640,9 +642,10 @@ int bnep_del_connection(struct bnep_conndel_req *req)
 	down_read(&bnep_session_sem);
 
 	s = __bnep_get_session(req->dst);
-	if (s)
-		kthread_stop(s->task);
-	else
+	if (s) {
+		atomic_inc(&s->terminate);
+		wake_up_process(s->task);
+	} else
 		err = -ENOENT;
 
 	up_read(&bnep_session_sem);
diff --git a/net/bluetooth/cmtp/capi.c b/net/bluetooth/cmtp/capi.c
index 040f67b..50f0d13 100644
--- a/net/bluetooth/cmtp/capi.c
+++ b/net/bluetooth/cmtp/capi.c
@@ -386,7 +386,8 @@ static void cmtp_reset_ctr(struct capi_ctr *ctrl)
 
 	capi_ctr_down(ctrl);
 
-	kthread_stop(session->task);
+	atomic_inc(&session->terminate);
+	wake_up_process(session->task);
 }
 
 static void cmtp_register_appl(struct capi_ctr *ctrl, __u16 appl, capi_register_params *rp)
diff --git a/net/bluetooth/cmtp/cmtp.h b/net/bluetooth/cmtp/cmtp.h
index db43b54..c32638d 100644
--- a/net/bluetooth/cmtp/cmtp.h
+++ b/net/bluetooth/cmtp/cmtp.h
@@ -81,6 +81,7 @@ struct cmtp_session {
 
 	char name[BTNAMSIZ];
 
+	atomic_t terminate;
 	struct task_struct *task;
 
 	wait_queue_head_t wait;
diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
index c5b11af..521baa4 100644
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -292,9 +292,11 @@ static int cmtp_session(void *arg)
 
 	init_waitqueue_entry(&wait, current);
 	add_wait_queue(sk_sleep(sk), &wait);
-	while (!kthread_should_stop()) {
+	while (1) {
 		set_current_state(TASK_INTERRUPTIBLE);
 
+		if (atomic_read(&session->terminate))
+			break;
 		if (sk->sk_state != BT_CONNECTED)
 			break;
 
@@ -307,7 +309,7 @@ static int cmtp_session(void *arg)
 
 		schedule();
 	}
-	set_current_state(TASK_RUNNING);
+	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(sk_sleep(sk), &wait);
 
 	down_write(&cmtp_session_sem);
@@ -380,16 +382,17 @@ int cmtp_add_connection(struct cmtp_connadd_req *req, struct socket *sock)
 
 	if (!(session->flags & (1 << CMTP_LOOPBACK))) {
 		err = cmtp_attach_device(session);
-		if (err < 0)
-			goto detach;
+		if (err < 0) {
+			atomic_inc(&session->terminate);
+			wake_up_process(session->task);
+			up_write(&cmtp_session_sem);
+			return err;
+		}
 	}
 
 	up_write(&cmtp_session_sem);
 	return 0;
 
-detach:
-	cmtp_detach_device(session);
-
 unlink:
 	__cmtp_unlink_session(session);
 
@@ -414,7 +417,8 @@ int cmtp_del_connection(struct cmtp_conndel_req *req)
 		skb_queue_purge(&session->transmit);
 
 		/* Stop session thread */
-		kthread_stop(session->task);
+		atomic_inc(&session->terminate);
+		wake_up_process(session->task);
 	} else
 		err = -ENOENT;
 
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index ec0bc3f..56943ad 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1209,7 +1209,6 @@ static void hci_cmd_timer(unsigned long arg)
 
 	BT_ERR("%s command tx timeout", hdev->name);
 	atomic_set(&hdev->cmd_cnt, 1);
-	clear_bit(HCI_RESET, &hdev->flags);
 	tasklet_schedule(&hdev->cmd_task);
 }
 
@@ -1327,7 +1326,7 @@ int hci_blacklist_add(struct hci_dev *hdev, bdaddr_t *bdaddr)
 
 	entry = kzalloc(sizeof(struct bdaddr_list), GFP_KERNEL);
 	if (!entry) {
-		return -ENOMEM;
+		err = -ENOMEM;
 		goto err;
 	}
 
@@ -2408,7 +2407,10 @@ static void hci_cmd_task(unsigned long arg)
 		if (hdev->sent_cmd) {
 			atomic_dec(&hdev->cmd_cnt);
 			hci_send_frame(skb);
-			mod_timer(&hdev->cmd_timer,
+			if (test_bit(HCI_RESET, &hdev->flags))
+				del_timer(&hdev->cmd_timer);
+			else
+				mod_timer(&hdev->cmd_timer,
 				  jiffies + msecs_to_jiffies(HCI_CMD_TIMEOUT));
 		} else {
 			skb_queue_head(&hdev->cmd_q, skb);
diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 43b4c2d..fb68f34 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -764,6 +764,7 @@ static int hidp_session(void *arg)
 
 	up_write(&hidp_session_sem);
 
+	kfree(session->rd_data);
 	kfree(session);
 	return 0;
 }
@@ -841,7 +842,8 @@ static int hidp_setup_input(struct hidp_session *session,
 
 	err = input_register_device(input);
 	if (err < 0) {
-		hci_conn_put_device(session->conn);
+		input_free_device(input);
+		session->input = NULL;
 		return err;
 	}
 
@@ -1044,8 +1046,12 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	}
 
 	err = hid_add_device(session->hid);
-	if (err < 0)
-		goto err_add_device;
+	if (err < 0) {
+		atomic_inc(&session->terminate);
+		wake_up_process(session->task);
+		up_write(&hidp_session_sem);
+		return err;
+	}
 
 	if (session->input) {
 		hidp_send_ctrl_message(session,
@@ -1059,12 +1065,6 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	up_write(&hidp_session_sem);
 	return 0;
 
-err_add_device:
-	hid_destroy_device(session->hid);
-	session->hid = NULL;
-	atomic_inc(&session->terminate);
-	wake_up_process(session->task);
-
 unlink:
 	hidp_del_timer(session);
 
@@ -1090,7 +1090,6 @@ purge:
 failed:
 	up_write(&hidp_session_sem);
 
-	input_free_device(session->input);
 	kfree(session);
 	return err;
 }
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 3204ba8..b3bdb48 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1159,9 +1159,8 @@ int __l2cap_wait_ack(struct sock *sk)
 	int timeo = HZ/5;
 
 	add_wait_queue(sk_sleep(sk), &wait);
-	while ((chan->unacked_frames > 0 && chan->conn)) {
-		set_current_state(TASK_INTERRUPTIBLE);
-
+	set_current_state(TASK_INTERRUPTIBLE);
+	while (chan->unacked_frames > 0 && chan->conn) {
 		if (!timeo)
 			timeo = HZ/5;
 
@@ -1173,6 +1172,7 @@ int __l2cap_wait_ack(struct sock *sk)
 		release_sock(sk);
 		timeo = schedule_timeout(timeo);
 		lock_sock(sk);
+		set_current_state(TASK_INTERRUPTIBLE);
 
 		err = sock_error(sk);
 		if (err)
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 5c36b3e..61f1f62 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -235,30 +235,26 @@ static int l2cap_sock_accept(struct socket *sock, struct socket *newsock, int fl
 
 	lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
 
-	if (sk->sk_state != BT_LISTEN) {
-		err = -EBADFD;
-		goto done;
-	}
-
 	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
 
 	BT_DBG("sk %p timeo %ld", sk, timeo);
 
 	/* Wait for an incoming connection. (wake-one). */
 	add_wait_queue_exclusive(sk_sleep(sk), &wait);
-	while (!(nsk = bt_accept_dequeue(sk, newsock))) {
+	while (1) {
 		set_current_state(TASK_INTERRUPTIBLE);
-		if (!timeo) {
-			err = -EAGAIN;
+
+		if (sk->sk_state != BT_LISTEN) {
+			err = -EBADFD;
 			break;
 		}
 
-		release_sock(sk);
-		timeo = schedule_timeout(timeo);
-		lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
+		nsk = bt_accept_dequeue(sk, newsock);
+		if (nsk)
+			break;
 
-		if (sk->sk_state != BT_LISTEN) {
-			err = -EBADFD;
+		if (!timeo) {
+			err = -EAGAIN;
 			break;
 		}
 
@@ -266,8 +262,12 @@ static int l2cap_sock_accept(struct socket *sock, struct socket *newsock, int fl
 			err = sock_intr_errno(timeo);
 			break;
 		}
+
+		release_sock(sk);
+		timeo = schedule_timeout(timeo);
+		lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
 	}
-	set_current_state(TASK_RUNNING);
+	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(sk_sleep(sk), &wait);
 
 	if (err)
@@ -993,7 +993,7 @@ static struct sock *l2cap_sock_alloc(struct net *net, struct socket *sock, int p
 	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
 	sk->sk_destruct = l2cap_sock_destruct;
-	sk->sk_sndtimeo = msecs_to_jiffies(L2CAP_CONN_TIMEOUT);
+	sk->sk_sndtimeo = L2CAP_CONN_TIMEOUT;
 
 	sock_reset_flag(sk, SOCK_ZAPPED);
 
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 5759bb7..5ba3f6d 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -62,7 +62,6 @@ static DEFINE_MUTEX(rfcomm_mutex);
 #define rfcomm_lock()	mutex_lock(&rfcomm_mutex)
 #define rfcomm_unlock()	mutex_unlock(&rfcomm_mutex)
 
-static unsigned long rfcomm_event;
 
 static LIST_HEAD(session_list);
 
@@ -120,7 +119,6 @@ static inline void rfcomm_schedule(void)
 {
 	if (!rfcomm_thread)
 		return;
-	set_bit(RFCOMM_SCHED_WAKEUP, &rfcomm_event);
 	wake_up_process(rfcomm_thread);
 }
 
@@ -2038,19 +2036,18 @@ static int rfcomm_run(void *unused)
 
 	rfcomm_add_listener(BDADDR_ANY);
 
-	while (!kthread_should_stop()) {
+	while (1) {
 		set_current_state(TASK_INTERRUPTIBLE);
-		if (!test_bit(RFCOMM_SCHED_WAKEUP, &rfcomm_event)) {
-			/* No pending events. Let's sleep.
-			 * Incoming connections and data will wake us up. */
-			schedule();
-		}
-		set_current_state(TASK_RUNNING);
+
+		if (kthread_should_stop())
+			break;
 
 		/* Process stuff */
-		clear_bit(RFCOMM_SCHED_WAKEUP, &rfcomm_event);
 		rfcomm_process_sessions();
+
+		schedule();
 	}
+	__set_current_state(TASK_RUNNING);
 
 	rfcomm_kill_listener();
 
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 8f01e6b..482722b 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -485,11 +485,6 @@ static int rfcomm_sock_accept(struct socket *sock, struct socket *newsock, int f
 
 	lock_sock(sk);
 
-	if (sk->sk_state != BT_LISTEN) {
-		err = -EBADFD;
-		goto done;
-	}
-
 	if (sk->sk_type != SOCK_STREAM) {
 		err = -EINVAL;
 		goto done;
@@ -501,19 +496,20 @@ static int rfcomm_sock_accept(struct socket *sock, struct socket *newsock, int f
 
 	/* Wait for an incoming connection. (wake-one). */
 	add_wait_queue_exclusive(sk_sleep(sk), &wait);
-	while (!(nsk = bt_accept_dequeue(sk, newsock))) {
+	while (1) {
 		set_current_state(TASK_INTERRUPTIBLE);
-		if (!timeo) {
-			err = -EAGAIN;
+
+		if (sk->sk_state != BT_LISTEN) {
+			err = -EBADFD;
 			break;
 		}
 
-		release_sock(sk);
-		timeo = schedule_timeout(timeo);
-		lock_sock(sk);
+		nsk = bt_accept_dequeue(sk, newsock);
+		if (nsk)
+			break;
 
-		if (sk->sk_state != BT_LISTEN) {
-			err = -EBADFD;
+		if (!timeo) {
+			err = -EAGAIN;
 			break;
 		}
 
@@ -521,8 +517,12 @@ static int rfcomm_sock_accept(struct socket *sock, struct socket *newsock, int f
 			err = sock_intr_errno(timeo);
 			break;
 		}
+
+		release_sock(sk);
+		timeo = schedule_timeout(timeo);
+		lock_sock(sk);
 	}
-	set_current_state(TASK_RUNNING);
+	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(sk_sleep(sk), &wait);
 
 	if (err)
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 4c3621b..8270f05 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -564,30 +564,26 @@ static int sco_sock_accept(struct socket *sock, struct socket *newsock, int flag
 
 	lock_sock(sk);
 
-	if (sk->sk_state != BT_LISTEN) {
-		err = -EBADFD;
-		goto done;
-	}
-
 	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
 
 	BT_DBG("sk %p timeo %ld", sk, timeo);
 
 	/* Wait for an incoming connection. (wake-one). */
 	add_wait_queue_exclusive(sk_sleep(sk), &wait);
-	while (!(ch = bt_accept_dequeue(sk, newsock))) {
+	while (1) {
 		set_current_state(TASK_INTERRUPTIBLE);
-		if (!timeo) {
-			err = -EAGAIN;
+
+		if (sk->sk_state != BT_LISTEN) {
+			err = -EBADFD;
 			break;
 		}
 
-		release_sock(sk);
-		timeo = schedule_timeout(timeo);
-		lock_sock(sk);
+		ch = bt_accept_dequeue(sk, newsock);
+		if (ch)
+			break;
 
-		if (sk->sk_state != BT_LISTEN) {
-			err = -EBADFD;
+		if (!timeo) {
+			err = -EAGAIN;
 			break;
 		}
 
@@ -595,8 +591,12 @@ static int sco_sock_accept(struct socket *sock, struct socket *newsock, int flag
 			err = sock_intr_errno(timeo);
 			break;
 		}
+
+		release_sock(sk);
+		timeo = schedule_timeout(timeo);
+		lock_sock(sk);
 	}
-	set_current_state(TASK_RUNNING);
+	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(sk_sleep(sk), &wait);
 
 	if (err)
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 866f269..acb4423 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1012,7 +1012,6 @@ void ieee80211_unregister_hw(struct ieee80211_hw *hw)
 	cancel_work_sync(&local->reconfig_filter);
 
 	ieee80211_clear_tx_pending(local);
-	sta_info_stop(local);
 	rate_control_deinitialize(local);
 
 	if (skb_queue_len(&local->skb_queue) ||
@@ -1024,6 +1023,7 @@ void ieee80211_unregister_hw(struct ieee80211_hw *hw)
 
 	destroy_workqueue(local->workqueue);
 	wiphy_unregister(local->hw.wiphy);
+	sta_info_stop(local);
 	ieee80211_wep_free(local);
 	ieee80211_led_exit(local);
 	kfree(local->int_scan_req);
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 645437c..c148651 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -616,6 +616,9 @@ int wiphy_register(struct wiphy *wiphy)
 	if (res)
 		goto out_rm_dev;
 
+	rtnl_lock();
+	rdev->wiphy.registered = true;
+	rtnl_unlock();
 	return 0;
 
 out_rm_dev:
@@ -647,6 +650,10 @@ void wiphy_unregister(struct wiphy *wiphy)
 {
 	struct cfg80211_registered_device *rdev = wiphy_to_dev(wiphy);
 
+	rtnl_lock();
+	rdev->wiphy.registered = false;
+	rtnl_unlock();
+
 	rfkill_unregister(rdev->rfkill);
 
 	/* protect the device list */
diff --git a/net/wireless/sysfs.c b/net/wireless/sysfs.c
index c6e4ca6..ff57459 100644
--- a/net/wireless/sysfs.c
+++ b/net/wireless/sysfs.c
@@ -93,7 +93,8 @@ static int wiphy_suspend(struct device *dev, pm_message_t state)
 
 	if (rdev->ops->suspend) {
 		rtnl_lock();
-		ret = rdev->ops->suspend(&rdev->wiphy, rdev->wowlan);
+		if (rdev->wiphy.registered)
+			ret = rdev->ops->suspend(&rdev->wiphy, rdev->wowlan);
 		rtnl_unlock();
 	}
 
@@ -112,7 +113,8 @@ static int wiphy_resume(struct device *dev)
 
 	if (rdev->ops->resume) {
 		rtnl_lock();
-		ret = rdev->ops->resume(&rdev->wiphy);
+		if (rdev->wiphy.registered)
+			ret = rdev->ops->resume(&rdev->wiphy);
 		rtnl_unlock();
 	}
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
