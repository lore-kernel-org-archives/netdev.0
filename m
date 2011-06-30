From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] bluetooth: Add bt_printk, convert logging macros to lower case
Date: Wed, 29 Jun 2011 18:18:30 -0700
Message-ID: <dde77465697e4a8fed630a9528cd8c1fcb092ce4.1309396408.git.joe@perches.com>
References: <1309370457.2208.48.camel@aeonflux> <cover.1309396408.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3341 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758121Ab1F3BTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2011 21:19:19 -0400
In-Reply-To: <cover.1309396408.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the more common logging styles.

bt_print uses vsprintf extension %pV.
This saves 2 to 3 % of code/text space.

$ find net/bluetooth -name "built-in.o.*" | xargs size
   text	   data	    bss	    dec	    hex	filename
  14778	   1012	   3408	  19198	   4afe	net/bluetooth/bnep/built-in.o.new
  15067	   1012	   3408	  19487	   4c1f	net/bluetooth/bnep/built-in.o.old
  18483	   1172	   4264	  23919	   5d6f	net/bluetooth/cmtp/built-in.o.new
  18927	   1172	   4264	  24363	   5f2b	net/bluetooth/cmtp/built-in.o.old
  59461	   3884	  14464	  77809	  12ff1	net/bluetooth/rfcomm/built-in.o.new
  61206	   3884	  14464	  79554	  136c2	net/bluetooth/rfcomm/built-in.o.old
  19237	   1172	   5152	  25561	   63d9	net/bluetooth/hidp/built-in.o.new
  19581	   1172	   5152	  25905	   6531	net/bluetooth/hidp/built-in.o.old
 346600	  19163	  86080	 451843	  6e503	net/bluetooth/built-in.o.new
 353751	  19163	  86064	 458978	  700e2	net/bluetooth/built-in.o.old

$ find drivers/bluetooth/ -name "built-in.o.*" | xargs size
   text	   data	    bss	    dec	    hex	filename
 129956	   8632	  36096	 174684	  2aa5c	drivers/bluetooth/built-in.o.new
 134402	   8632	  36064	 179098	  2bb9a	drivers/bluetooth/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/bluetooth/ath3k.c          |   48 ++++----
 drivers/bluetooth/bcm203x.c        |   38 +++---
 drivers/bluetooth/bfusb.c          |   94 +++++++-------
 drivers/bluetooth/bluecard_cs.c    |   18 ++--
 drivers/bluetooth/bpa10x.c         |   38 +++---
 drivers/bluetooth/bt3c_cs.c        |   34 +++---
 drivers/bluetooth/btmrvl_debugfs.c |    2 +-
 drivers/bluetooth/btmrvl_main.c    |   74 ++++++------
 drivers/bluetooth/btmrvl_sdio.c    |  112 +++++++++---------
 drivers/bluetooth/btsdio.c         |   26 ++--
 drivers/bluetooth/btuart_cs.c      |   24 ++--
 drivers/bluetooth/btusb.c          |   64 +++++-----
 drivers/bluetooth/btwilink.c       |   34 +++---
 drivers/bluetooth/dtl1_cs.c        |   20 ++--
 drivers/bluetooth/hci_ath.c        |   14 +-
 drivers/bluetooth/hci_bcsp.c       |   58 +++++-----
 drivers/bluetooth/hci_h4.c         |   18 ++--
 drivers/bluetooth/hci_ldisc.c      |   36 +++---
 drivers/bluetooth/hci_ll.c         |   76 ++++++------
 drivers/bluetooth/hci_vhci.c       |    8 +-
 include/net/bluetooth/bluetooth.h  |    9 +-
 net/bluetooth/af_bluetooth.c       |   20 ++--
 net/bluetooth/bnep/core.c          |   26 ++--
 net/bluetooth/bnep/netdev.c        |   14 +-
 net/bluetooth/bnep/sock.c          |   10 +-
 net/bluetooth/cmtp/capi.c          |   46 ++++----
 net/bluetooth/cmtp/core.c          |   30 +++---
 net/bluetooth/cmtp/sock.c          |   10 +-
 net/bluetooth/hci_conn.c           |   52 ++++----
 net/bluetooth/hci_core.c           |  140 +++++++++++-----------
 net/bluetooth/hci_event.c          |  234 ++++++++++++++++++------------------
 net/bluetooth/hci_sock.c           |   26 ++--
 net/bluetooth/hci_sysfs.c          |   12 +-
 net/bluetooth/hidp/core.c          |   50 ++++----
 net/bluetooth/hidp/sock.c          |   10 +-
 net/bluetooth/l2cap_core.c         |  168 +++++++++++++-------------
 net/bluetooth/l2cap_sock.c         |   40 +++---
 net/bluetooth/lib.c                |   19 +++
 net/bluetooth/mgmt.c               |   80 ++++++------
 net/bluetooth/rfcomm/core.c        |  152 ++++++++++++------------
 net/bluetooth/rfcomm/sock.c        |   56 +++++-----
 net/bluetooth/rfcomm/tty.c         |  100 ++++++++--------
 net/bluetooth/sco.c                |   80 ++++++------
 net/bluetooth/smp.c                |   30 +++---
 44 files changed, 1136 insertions(+), 1114 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index 6bacef3..f0d8228 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -100,13 +100,13 @@ static int ath3k_load_firmware(struct usb_device *udev,
 	int err, pipe, len, size, sent = 0;
 	int count = firmware->size;
 
-	BT_DBG("udev %p", udev);
+	bt_dbg("udev %p", udev);
 
 	pipe = usb_sndctrlpipe(udev, 0);
 
 	send_buf = kmalloc(BULK_SIZE, GFP_ATOMIC);
 	if (!send_buf) {
-		BT_ERR("Can't allocate memory chunk for firmware");
+		bt_err("Can't allocate memory chunk for firmware");
 		return -ENOMEM;
 	}
 
@@ -115,7 +115,7 @@ static int ath3k_load_firmware(struct usb_device *udev,
 				USB_REQ_DFU_DNLOAD,
 				USB_TYPE_VENDOR, 0, 0,
 				send_buf, 20, USB_CTRL_SET_TIMEOUT)) < 0) {
-		BT_ERR("Can't change to loading configuration err");
+		bt_err("Can't change to loading configuration err");
 		goto error;
 	}
 	sent += 20;
@@ -130,7 +130,7 @@ static int ath3k_load_firmware(struct usb_device *udev,
 					&len, 3000);
 
 		if (err || (len != size)) {
-			BT_ERR("Error in firmware loading err = %d,"
+			bt_err("Error in firmware loading err = %d,"
 				"len = %d, size = %d", err, len, size);
 			goto error;
 		}
@@ -177,7 +177,7 @@ static int ath3k_load_fwfile(struct usb_device *udev,
 
 	send_buf = kmalloc(BULK_SIZE, GFP_ATOMIC);
 	if (!send_buf) {
-		BT_ERR("Can't allocate memory chunk for firmware");
+		bt_err("Can't allocate memory chunk for firmware");
 		return -ENOMEM;
 	}
 
@@ -189,7 +189,7 @@ static int ath3k_load_fwfile(struct usb_device *udev,
 			USB_TYPE_VENDOR, 0, 0, send_buf,
 			size, USB_CTRL_SET_TIMEOUT);
 	if (ret < 0) {
-		BT_ERR("Can't change to loading configuration err");
+		bt_err("Can't change to loading configuration err");
 		kfree(send_buf);
 		return ret;
 	}
@@ -206,7 +206,7 @@ static int ath3k_load_fwfile(struct usb_device *udev,
 		err = usb_bulk_msg(udev, pipe, send_buf, size,
 					&len, 3000);
 		if (err || (len != size)) {
-			BT_ERR("Error in firmware loading err = %d,"
+			bt_err("Error in firmware loading err = %d,"
 				"len = %d, size = %d", err, len, size);
 			kfree(send_buf);
 			return err;
@@ -236,12 +236,12 @@ static int ath3k_set_normal_mode(struct usb_device *udev)
 
 	ret = ath3k_get_state(udev, &fw_state);
 	if (ret < 0) {
-		BT_ERR("Can't get state to change to normal mode err");
+		bt_err("Can't get state to change to normal mode err");
 		return ret;
 	}
 
 	if ((fw_state & ATH3K_MODE_MASK) == ATH3K_NORMAL_MODE) {
-		BT_DBG("firmware was already in normal mode");
+		bt_dbg("firmware was already in normal mode");
 		return 0;
 	}
 
@@ -261,18 +261,18 @@ static int ath3k_load_patch(struct usb_device *udev)
 
 	ret = ath3k_get_state(udev, &fw_state);
 	if (ret < 0) {
-		BT_ERR("Can't get state to change to load ram patch err");
+		bt_err("Can't get state to change to load ram patch err");
 		return ret;
 	}
 
 	if (fw_state & ATH3K_PATCH_UPDATE) {
-		BT_DBG("Patch was already downloaded");
+		bt_dbg("Patch was already downloaded");
 		return 0;
 	}
 
 	ret = ath3k_get_version(udev, &fw_version);
 	if (ret < 0) {
-		BT_ERR("Can't get version to change to load ram patch err");
+		bt_err("Can't get version to change to load ram patch err");
 		return ret;
 	}
 
@@ -281,7 +281,7 @@ static int ath3k_load_patch(struct usb_device *udev)
 
 	ret = request_firmware(&firmware, filename, &udev->dev);
 	if (ret < 0) {
-		BT_ERR("Patch file not found %s", filename);
+		bt_err("Patch file not found %s", filename);
 		return ret;
 	}
 
@@ -291,7 +291,7 @@ static int ath3k_load_patch(struct usb_device *udev)
 
 	if ((pt_version.rom_version != fw_version.rom_version) ||
 		(pt_version.build_version <= fw_version.build_version)) {
-		BT_ERR("Patch file version did not match with firmware");
+		bt_err("Patch file version did not match with firmware");
 		release_firmware(firmware);
 		return -EINVAL;
 	}
@@ -312,13 +312,13 @@ static int ath3k_load_syscfg(struct usb_device *udev)
 
 	ret = ath3k_get_state(udev, &fw_state);
 	if (ret < 0) {
-		BT_ERR("Can't get state to change to load configration err");
+		bt_err("Can't get state to change to load configration err");
 		return -EBUSY;
 	}
 
 	ret = ath3k_get_version(udev, &fw_version);
 	if (ret < 0) {
-		BT_ERR("Can't get version to change to load ram patch err");
+		bt_err("Can't get version to change to load ram patch err");
 		return ret;
 	}
 
@@ -343,7 +343,7 @@ static int ath3k_load_syscfg(struct usb_device *udev)
 
 	ret = request_firmware(&firmware, filename, &udev->dev);
 	if (ret < 0) {
-		BT_ERR("Configuration file not found %s", filename);
+		bt_err("Configuration file not found %s", filename);
 		return ret;
 	}
 
@@ -360,7 +360,7 @@ static int ath3k_probe(struct usb_interface *intf,
 	struct usb_device *udev = interface_to_usbdev(intf);
 	int ret;
 
-	BT_DBG("intf %p id %p", intf, id);
+	bt_dbg("intf %p id %p", intf, id);
 
 	if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
 		return -ENODEV;
@@ -377,17 +377,17 @@ static int ath3k_probe(struct usb_interface *intf,
 	if (id->driver_info & BTUSB_ATH3012) {
 		ret = ath3k_load_patch(udev);
 		if (ret < 0) {
-			BT_ERR("Loading patch file failed");
+			bt_err("Loading patch file failed");
 			return ret;
 		}
 		ret = ath3k_load_syscfg(udev);
 		if (ret < 0) {
-			BT_ERR("Loading sysconfig file failed");
+			bt_err("Loading sysconfig file failed");
 			return ret;
 		}
 		ret = ath3k_set_normal_mode(udev);
 		if (ret < 0) {
-			BT_ERR("Set normal mode failed");
+			bt_err("Set normal mode failed");
 			return ret;
 		}
 		ath3k_switch_pid(udev);
@@ -395,7 +395,7 @@ static int ath3k_probe(struct usb_interface *intf,
 	}
 
 	if (request_firmware(&firmware, "ath3k-1.fw", &udev->dev) < 0) {
-		BT_ERR("Error loading firmware");
+		bt_err("Error loading firmware");
 		return -EIO;
 	}
 
@@ -407,7 +407,7 @@ static int ath3k_probe(struct usb_interface *intf,
 
 static void ath3k_disconnect(struct usb_interface *intf)
 {
-	BT_DBG("ath3k_disconnect intf %p", intf);
+	bt_dbg("ath3k_disconnect intf %p", intf);
 }
 
 static struct usb_driver ath3k_driver = {
@@ -419,7 +419,7 @@ static struct usb_driver ath3k_driver = {
 
 static int __init ath3k_init(void)
 {
-	BT_INFO("Atheros AR30xx firmware driver ver %s", VERSION);
+	bt_info("Atheros AR30xx firmware driver ver %s", VERSION);
 	return usb_register(&ath3k_driver);
 }
 
diff --git a/drivers/bluetooth/bcm203x.c b/drivers/bluetooth/bcm203x.c
index 8b1b643..109dd8c 100644
--- a/drivers/bluetooth/bcm203x.c
+++ b/drivers/bluetooth/bcm203x.c
@@ -80,10 +80,10 @@ static void bcm203x_complete(struct urb *urb)
 	struct usb_device *udev = urb->dev;
 	int len;
 
-	BT_DBG("udev %p urb %p", udev, urb);
+	bt_dbg("udev %p urb %p", udev, urb);
 
 	if (urb->status) {
-		BT_ERR("URB failed with status %d", urb->status);
+		bt_err("URB failed with status %d", urb->status);
 		data->state = BCM203X_ERROR;
 		return;
 	}
@@ -107,12 +107,12 @@ static void bcm203x_complete(struct urb *urb)
 		data->state = BCM203X_CHECK_MEMORY;
 
 		if (usb_submit_urb(data->urb, GFP_ATOMIC) < 0)
-			BT_ERR("Can't submit URB");
+			bt_err("Can't submit URB");
 		break;
 
 	case BCM203X_CHECK_MEMORY:
 		if (data->buffer[0] != '#') {
-			BT_ERR("Memory select failed");
+			bt_err("Memory select failed");
 			data->state = BCM203X_ERROR;
 			break;
 		}
@@ -135,12 +135,12 @@ static void bcm203x_complete(struct urb *urb)
 		}
 
 		if (usb_submit_urb(data->urb, GFP_ATOMIC) < 0)
-			BT_ERR("Can't submit URB");
+			bt_err("Can't submit URB");
 		break;
 
 	case BCM203X_CHECK_FIRMWARE:
 		if (data->buffer[0] != '.') {
-			BT_ERR("Firmware loading failed");
+			bt_err("Firmware loading failed");
 			data->state = BCM203X_ERROR;
 			break;
 		}
@@ -156,7 +156,7 @@ static void bcm203x_work(struct work_struct *work)
 		container_of(work, struct bcm203x_data, work);
 
 	if (usb_submit_urb(data->urb, GFP_ATOMIC) < 0)
-		BT_ERR("Can't submit URB");
+		bt_err("Can't submit URB");
 }
 
 static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id *id)
@@ -166,14 +166,14 @@ static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id
 	struct bcm203x_data *data;
 	int size;
 
-	BT_DBG("intf %p id %p", intf, id);
+	bt_dbg("intf %p id %p", intf, id);
 
 	if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
 		return -ENODEV;
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (!data) {
-		BT_ERR("Can't allocate memory for data structure");
+		bt_err("Can't allocate memory for data structure");
 		return -ENOMEM;
 	}
 
@@ -182,25 +182,25 @@ static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id
 
 	data->urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!data->urb) {
-		BT_ERR("Can't allocate URB");
+		bt_err("Can't allocate URB");
 		kfree(data);
 		return -ENOMEM;
 	}
 
 	if (request_firmware(&firmware, "BCM2033-MD.hex", &udev->dev) < 0) {
-		BT_ERR("Mini driver request failed");
+		bt_err("Mini driver request failed");
 		usb_free_urb(data->urb);
 		kfree(data);
 		return -EIO;
 	}
 
-	BT_DBG("minidrv data %p size %zu", firmware->data, firmware->size);
+	bt_dbg("minidrv data %p size %zu", firmware->data, firmware->size);
 
 	size = max_t(uint, firmware->size, 4096);
 
 	data->buffer = kmalloc(size, GFP_KERNEL);
 	if (!data->buffer) {
-		BT_ERR("Can't allocate memory for mini driver");
+		bt_err("Can't allocate memory for mini driver");
 		release_firmware(firmware);
 		usb_free_urb(data->urb);
 		kfree(data);
@@ -215,18 +215,18 @@ static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id
 	release_firmware(firmware);
 
 	if (request_firmware(&firmware, "BCM2033-FW.bin", &udev->dev) < 0) {
-		BT_ERR("Firmware request failed");
+		bt_err("Firmware request failed");
 		usb_free_urb(data->urb);
 		kfree(data->buffer);
 		kfree(data);
 		return -EIO;
 	}
 
-	BT_DBG("firmware data %p size %zu", firmware->data, firmware->size);
+	bt_dbg("firmware data %p size %zu", firmware->data, firmware->size);
 
 	data->fw_data = kmemdup(firmware->data, firmware->size, GFP_KERNEL);
 	if (!data->fw_data) {
-		BT_ERR("Can't allocate memory for firmware image");
+		bt_err("Can't allocate memory for firmware image");
 		release_firmware(firmware);
 		usb_free_urb(data->urb);
 		kfree(data->buffer);
@@ -252,7 +252,7 @@ static void bcm203x_disconnect(struct usb_interface *intf)
 {
 	struct bcm203x_data *data = usb_get_intfdata(intf);
 
-	BT_DBG("intf %p", intf);
+	bt_dbg("intf %p", intf);
 
 	usb_kill_urb(data->urb);
 
@@ -275,11 +275,11 @@ static int __init bcm203x_init(void)
 {
 	int err;
 
-	BT_INFO("Broadcom Blutonium firmware driver ver %s", VERSION);
+	bt_info("Broadcom Blutonium firmware driver ver %s", VERSION);
 
 	err = usb_register(&bcm203x_driver);
 	if (err < 0)
-		BT_ERR("Failed to register USB driver");
+		bt_err("Failed to register USB driver");
 
 	return err;
 }
diff --git a/drivers/bluetooth/bfusb.c b/drivers/bluetooth/bfusb.c
index 005919a..b574c90 100644
--- a/drivers/bluetooth/bfusb.c
+++ b/drivers/bluetooth/bfusb.c
@@ -95,7 +95,7 @@ static struct urb *bfusb_get_completed(struct bfusb_data *data)
 	struct sk_buff *skb;
 	struct urb *urb = NULL;
 
-	BT_DBG("bfusb %p", data);
+	bt_dbg("bfusb %p", data);
 
 	skb = skb_dequeue(&data->completed_q);
 	if (skb) {
@@ -111,7 +111,7 @@ static void bfusb_unlink_urbs(struct bfusb_data *data)
 	struct sk_buff *skb;
 	struct urb *urb;
 
-	BT_DBG("bfusb %p", data);
+	bt_dbg("bfusb %p", data);
 
 	while ((skb = skb_dequeue(&data->pending_q))) {
 		urb = ((struct bfusb_data_scb *) skb->cb)->urb;
@@ -129,7 +129,7 @@ static int bfusb_send_bulk(struct bfusb_data *data, struct sk_buff *skb)
 	struct urb *urb = bfusb_get_completed(data);
 	int err, pipe;
 
-	BT_DBG("bfusb %p skb %p len %d", data, skb, skb->len);
+	bt_dbg("bfusb %p skb %p len %d", data, skb, skb->len);
 
 	if (!urb && !(urb = usb_alloc_urb(0, GFP_ATOMIC)))
 		return -ENOMEM;
@@ -145,7 +145,7 @@ static int bfusb_send_bulk(struct bfusb_data *data, struct sk_buff *skb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err) {
-		BT_ERR("%s bulk tx submit failed urb %p err %d", 
+		bt_err("%s bulk tx submit failed urb %p err %d", 
 					data->hdev->name, urb, err);
 		skb_unlink(skb, &data->pending_q);
 		usb_free_urb(urb);
@@ -159,7 +159,7 @@ static void bfusb_tx_wakeup(struct bfusb_data *data)
 {
 	struct sk_buff *skb;
 
-	BT_DBG("bfusb %p", data);
+	bt_dbg("bfusb %p", data);
 
 	if (test_and_set_bit(BFUSB_TX_PROCESS, &data->state)) {
 		set_bit(BFUSB_TX_WAKEUP, &data->state);
@@ -187,7 +187,7 @@ static void bfusb_tx_complete(struct urb *urb)
 	struct sk_buff *skb = (struct sk_buff *) urb->context;
 	struct bfusb_data *data = (struct bfusb_data *) skb->dev;
 
-	BT_DBG("bfusb %p urb %p skb %p len %d", data, urb, skb, skb->len);
+	bt_dbg("bfusb %p urb %p skb %p len %d", data, urb, skb, skb->len);
 
 	atomic_dec(&data->pending_tx);
 
@@ -216,7 +216,7 @@ static int bfusb_rx_submit(struct bfusb_data *data, struct urb *urb)
 	struct sk_buff *skb;
 	int err, pipe, size = HCI_MAX_FRAME_SIZE + 32;
 
-	BT_DBG("bfusb %p urb %p", data, urb);
+	bt_dbg("bfusb %p urb %p", data, urb);
 
 	if (!urb && !(urb = usb_alloc_urb(0, GFP_ATOMIC)))
 		return -ENOMEM;
@@ -241,7 +241,7 @@ static int bfusb_rx_submit(struct bfusb_data *data, struct urb *urb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err) {
-		BT_ERR("%s bulk rx submit failed urb %p err %d",
+		bt_err("%s bulk rx submit failed urb %p err %d",
 					data->hdev->name, urb, err);
 		skb_unlink(skb, &data->pending_q);
 		kfree_skb(skb);
@@ -253,10 +253,10 @@ static int bfusb_rx_submit(struct bfusb_data *data, struct urb *urb)
 
 static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned char *buf, int len)
 {
-	BT_DBG("bfusb %p hdr 0x%02x data %p len %d", data, hdr, buf, len);
+	bt_dbg("bfusb %p hdr 0x%02x data %p len %d", data, hdr, buf, len);
 
 	if (hdr & 0x10) {
-		BT_ERR("%s error in block", data->hdev->name);
+		bt_err("%s error in block", data->hdev->name);
 		kfree_skb(data->reassembly);
 		data->reassembly = NULL;
 		return -EIO;
@@ -268,13 +268,13 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 		int pkt_len = 0;
 
 		if (data->reassembly) {
-			BT_ERR("%s unexpected start block", data->hdev->name);
+			bt_err("%s unexpected start block", data->hdev->name);
 			kfree_skb(data->reassembly);
 			data->reassembly = NULL;
 		}
 
 		if (len < 1) {
-			BT_ERR("%s no packet type found", data->hdev->name);
+			bt_err("%s no packet type found", data->hdev->name);
 			return -EPROTO;
 		}
 
@@ -286,7 +286,7 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 				struct hci_event_hdr *hdr = (struct hci_event_hdr *) buf;
 				pkt_len = HCI_EVENT_HDR_SIZE + hdr->plen;
 			} else {
-				BT_ERR("%s event block is too short", data->hdev->name);
+				bt_err("%s event block is too short", data->hdev->name);
 				return -EILSEQ;
 			}
 			break;
@@ -296,7 +296,7 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 				struct hci_acl_hdr *hdr = (struct hci_acl_hdr *) buf;
 				pkt_len = HCI_ACL_HDR_SIZE + __le16_to_cpu(hdr->dlen);
 			} else {
-				BT_ERR("%s data block is too short", data->hdev->name);
+				bt_err("%s data block is too short", data->hdev->name);
 				return -EILSEQ;
 			}
 			break;
@@ -306,7 +306,7 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 				struct hci_sco_hdr *hdr = (struct hci_sco_hdr *) buf;
 				pkt_len = HCI_SCO_HDR_SIZE + hdr->dlen;
 			} else {
-				BT_ERR("%s audio block is too short", data->hdev->name);
+				bt_err("%s audio block is too short", data->hdev->name);
 				return -EILSEQ;
 			}
 			break;
@@ -314,7 +314,7 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 
 		skb = bt_skb_alloc(pkt_len, GFP_ATOMIC);
 		if (!skb) {
-			BT_ERR("%s no memory for the packet", data->hdev->name);
+			bt_err("%s no memory for the packet", data->hdev->name);
 			return -ENOMEM;
 		}
 
@@ -324,7 +324,7 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 		data->reassembly = skb;
 	} else {
 		if (!data->reassembly) {
-			BT_ERR("%s unexpected continuation block", data->hdev->name);
+			bt_err("%s unexpected continuation block", data->hdev->name);
 			return -EIO;
 		}
 	}
@@ -348,7 +348,7 @@ static void bfusb_rx_complete(struct urb *urb)
 	int count = urb->actual_length;
 	int err, hdr, len;
 
-	BT_DBG("bfusb %p urb %p skb %p len %d", data, urb, skb, skb->len);
+	bt_dbg("bfusb %p urb %p skb %p len %d", data, urb, skb, skb->len);
 
 	read_lock(&data->lock);
 
@@ -376,7 +376,7 @@ static void bfusb_rx_complete(struct urb *urb)
 		}
 
 		if (count < len) {
-			BT_ERR("%s block extends over URB buffer ranges",
+			bt_err("%s block extends over URB buffer ranges",
 					data->hdev->name);
 		}
 
@@ -401,7 +401,7 @@ resubmit:
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err) {
-		BT_ERR("%s bulk resubmit failed urb %p err %d",
+		bt_err("%s bulk resubmit failed urb %p err %d",
 					data->hdev->name, urb, err);
 	}
 
@@ -415,7 +415,7 @@ static int bfusb_open(struct hci_dev *hdev)
 	unsigned long flags;
 	int i, err;
 
-	BT_DBG("hdev %p bfusb %p", hdev, data);
+	bt_dbg("hdev %p bfusb %p", hdev, data);
 
 	if (test_and_set_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -439,7 +439,7 @@ static int bfusb_flush(struct hci_dev *hdev)
 {
 	struct bfusb_data *data = hdev->driver_data;
 
-	BT_DBG("hdev %p bfusb %p", hdev, data);
+	bt_dbg("hdev %p bfusb %p", hdev, data);
 
 	skb_queue_purge(&data->transmit_q);
 
@@ -451,7 +451,7 @@ static int bfusb_close(struct hci_dev *hdev)
 	struct bfusb_data *data = hdev->driver_data;
 	unsigned long flags;
 
-	BT_DBG("hdev %p bfusb %p", hdev, data);
+	bt_dbg("hdev %p bfusb %p", hdev, data);
 
 	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -473,10 +473,10 @@ static int bfusb_send_frame(struct sk_buff *skb)
 	unsigned char buf[3];
 	int sent = 0, size, count;
 
-	BT_DBG("hdev %p skb %p type %d len %d", hdev, skb, bt_cb(skb)->pkt_type, skb->len);
+	bt_dbg("hdev %p skb %p type %d len %d", hdev, skb, bt_cb(skb)->pkt_type, skb->len);
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown HCI device (hdev=NULL)");
+		bt_err("Frame for unknown HCI device (hdev=NULL)");
 		return -ENODEV;
 	}
 
@@ -505,7 +505,7 @@ static int bfusb_send_frame(struct sk_buff *skb)
 	/* Max HCI frame size seems to be 1511 + 1 */
 	nskb = bt_skb_alloc(count + 32, GFP_ATOMIC);
 	if (!nskb) {
-		BT_ERR("Can't allocate memory for new packet");
+		bt_err("Can't allocate memory for new packet");
 		return -ENOMEM;
 	}
 
@@ -548,7 +548,7 @@ static void bfusb_destruct(struct hci_dev *hdev)
 {
 	struct bfusb_data *data = hdev->driver_data;
 
-	BT_DBG("hdev %p bfusb %p", hdev, data);
+	bt_dbg("hdev %p bfusb %p", hdev, data);
 
 	kfree(data);
 }
@@ -564,15 +564,15 @@ static int bfusb_load_firmware(struct bfusb_data *data,
 	unsigned char *buf;
 	int err, pipe, len, size, sent = 0;
 
-	BT_DBG("bfusb %p udev %p", data, data->udev);
+	bt_dbg("bfusb %p udev %p", data, data->udev);
 
-	BT_INFO("BlueFRITZ! USB loading firmware");
+	bt_info("BlueFRITZ! USB loading firmware");
 
 	pipe = usb_sndctrlpipe(data->udev, 0);
 
 	if (usb_control_msg(data->udev, pipe, USB_REQ_SET_CONFIGURATION,
 				0, 1, 0, NULL, 0, USB_CTRL_SET_TIMEOUT) < 0) {
-		BT_ERR("Can't change to loading configuration");
+		bt_err("Can't change to loading configuration");
 		return -EBUSY;
 	}
 
@@ -580,7 +580,7 @@ static int bfusb_load_firmware(struct bfusb_data *data,
 
 	buf = kmalloc(BFUSB_MAX_BLOCK_SIZE + 3, GFP_ATOMIC);
 	if (!buf) {
-		BT_ERR("Can't allocate memory chunk for firmware");
+		bt_err("Can't allocate memory chunk for firmware");
 		return -ENOMEM;
 	}
 
@@ -595,7 +595,7 @@ static int bfusb_load_firmware(struct bfusb_data *data,
 					&len, BFUSB_BLOCK_TIMEOUT);
 
 		if (err || (len != size)) {
-			BT_ERR("Error in firmware loading");
+			bt_err("Error in firmware loading");
 			goto error;
 		}
 
@@ -606,7 +606,7 @@ static int bfusb_load_firmware(struct bfusb_data *data,
 	err = usb_bulk_msg(data->udev, pipe, NULL, 0,
 					&len, BFUSB_BLOCK_TIMEOUT);
 	if (err < 0) {
-		BT_ERR("Error in null packet request");
+		bt_err("Error in null packet request");
 		goto error;
 	}
 
@@ -615,13 +615,13 @@ static int bfusb_load_firmware(struct bfusb_data *data,
 	err = usb_control_msg(data->udev, pipe, USB_REQ_SET_CONFIGURATION,
 				0, 2, 0, NULL, 0, USB_CTRL_SET_TIMEOUT);
 	if (err < 0) {
-		BT_ERR("Can't change to running configuration");
+		bt_err("Can't change to running configuration");
 		goto error;
 	}
 
 	data->udev->toggle[0] = data->udev->toggle[1] = 0;
 
-	BT_INFO("BlueFRITZ! USB device ready");
+	bt_info("BlueFRITZ! USB device ready");
 
 	kfree(buf);
 	return 0;
@@ -646,7 +646,7 @@ static int bfusb_probe(struct usb_interface *intf, const struct usb_device_id *i
 	struct hci_dev *hdev;
 	struct bfusb_data *data;
 
-	BT_DBG("intf %p id %p", intf, id);
+	bt_dbg("intf %p id %p", intf, id);
 
 	/* Check number of endpoints */
 	if (intf->cur_altsetting->desc.bNumEndpoints < 2)
@@ -656,14 +656,14 @@ static int bfusb_probe(struct usb_interface *intf, const struct usb_device_id *i
 	bulk_in_ep  = &intf->cur_altsetting->endpoint[1];
 
 	if (!bulk_out_ep || !bulk_in_ep) {
-		BT_ERR("Bulk endpoints not found");
+		bt_err("Bulk endpoints not found");
 		goto done;
 	}
 
 	/* Initialize control structure and load firmware */
 	data = kzalloc(sizeof(struct bfusb_data), GFP_KERNEL);
 	if (!data) {
-		BT_ERR("Can't allocate memory for control structure");
+		bt_err("Can't allocate memory for control structure");
 		goto done;
 	}
 
@@ -681,14 +681,14 @@ static int bfusb_probe(struct usb_interface *intf, const struct usb_device_id *i
 	skb_queue_head_init(&data->completed_q);
 
 	if (request_firmware(&firmware, "bfubase.frm", &udev->dev) < 0) {
-		BT_ERR("Firmware request failed");
+		bt_err("Firmware request failed");
 		goto error;
 	}
 
-	BT_DBG("firmware data %p size %zu", firmware->data, firmware->size);
+	bt_dbg("firmware data %p size %zu", firmware->data, firmware->size);
 
 	if (bfusb_load_firmware(data, firmware->data, firmware->size) < 0) {
-		BT_ERR("Firmware loading failed");
+		bt_err("Firmware loading failed");
 		goto release;
 	}
 
@@ -697,7 +697,7 @@ static int bfusb_probe(struct usb_interface *intf, const struct usb_device_id *i
 	/* Initialize and register HCI device */
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can't allocate HCI device");
+		bt_err("Can't allocate HCI device");
 		goto error;
 	}
 
@@ -717,7 +717,7 @@ static int bfusb_probe(struct usb_interface *intf, const struct usb_device_id *i
 	hdev->owner = THIS_MODULE;
 
 	if (hci_register_dev(hdev) < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device");
 		hci_free_dev(hdev);
 		goto error;
 	}
@@ -741,7 +741,7 @@ static void bfusb_disconnect(struct usb_interface *intf)
 	struct bfusb_data *data = usb_get_intfdata(intf);
 	struct hci_dev *hdev = data->hdev;
 
-	BT_DBG("intf %p", intf);
+	bt_dbg("intf %p", intf);
 
 	if (!hdev)
 		return;
@@ -751,7 +751,7 @@ static void bfusb_disconnect(struct usb_interface *intf)
 	bfusb_close(hdev);
 
 	if (hci_unregister_dev(hdev) < 0)
-		BT_ERR("Can't unregister HCI device %s", hdev->name);
+		bt_err("Can't unregister HCI device %s", hdev->name);
 
 	hci_free_dev(hdev);
 }
@@ -767,11 +767,11 @@ static int __init bfusb_init(void)
 {
 	int err;
 
-	BT_INFO("BlueFRITZ! USB driver ver %s", VERSION);
+	bt_info("BlueFRITZ! USB driver ver %s", VERSION);
 
 	err = usb_register(&bfusb_driver);
 	if (err < 0)
-		BT_ERR("Failed to register BlueFRITZ! USB driver");
+		bt_err("Failed to register BlueFRITZ! USB driver");
 
 	return err;
 }
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index aed1904..aaf9b03 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -218,7 +218,7 @@ static int bluecard_write(unsigned int iobase, unsigned int offset, __u8 *buf, i
 static void bluecard_write_wakeup(bluecard_info_t *info)
 {
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device");
 		return;
 	}
 
@@ -374,7 +374,7 @@ static void bluecard_receive(bluecard_info_t *info, unsigned int offset)
 	int i, len;
 
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device");
 		return;
 	}
 
@@ -392,7 +392,7 @@ static void bluecard_receive(bluecard_info_t *info, unsigned int offset)
 			info->rx_state = RECV_WAIT_PACKET_TYPE;
 			info->rx_count = 0;
 			if (!(info->rx_skb = bt_skb_alloc(HCI_MAX_FRAME_SIZE, GFP_ATOMIC))) {
-				BT_ERR("Can't allocate mem for new packet");
+				bt_err("Can't allocate mem for new packet");
 				return;
 			}
 		}
@@ -434,7 +434,7 @@ static void bluecard_receive(bluecard_info_t *info, unsigned int offset)
 
 			default:
 				/* unknown packet */
-				BT_ERR("Unknown HCI packet with type 0x%02x received", bt_cb(info->rx_skb)->pkt_type);
+				bt_err("Unknown HCI packet with type 0x%02x received", bt_cb(info->rx_skb)->pkt_type);
 				info->hdev->stat.err_rx++;
 
 				kfree_skb(info->rx_skb);
@@ -568,7 +568,7 @@ static int bluecard_hci_set_baud_rate(struct hci_dev *hdev, int baud)
 	unsigned char cmd[] = { HCI_COMMAND_PKT, 0x09, 0xfc, 0x01, 0x03 };
 
 	if (!(skb = bt_skb_alloc(HCI_MAX_FRAME_SIZE, GFP_ATOMIC))) {
-		BT_ERR("Can't allocate mem for new packet");
+		bt_err("Can't allocate mem for new packet");
 		return -1;
 	}
 
@@ -663,7 +663,7 @@ static int bluecard_hci_send_frame(struct sk_buff *skb)
 	struct hci_dev *hdev = (struct hci_dev *)(skb->dev);
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown HCI device (hdev=NULL)");
+		bt_err("Frame for unknown HCI device (hdev=NULL)");
 		return -ENODEV;
 	}
 
@@ -727,7 +727,7 @@ static int bluecard_open(bluecard_info_t *info)
 	/* Initialize HCI device */
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can't allocate HCI device");
+		bt_err("Can't allocate HCI device");
 		return -ENOMEM;
 	}
 
@@ -815,7 +815,7 @@ static int bluecard_open(bluecard_info_t *info)
 
 	/* Register HCI device */
 	if (hci_register_dev(hdev) < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device");
 		info->hdev = NULL;
 		hci_free_dev(hdev);
 		return -ENODEV;
@@ -845,7 +845,7 @@ static int bluecard_close(bluecard_info_t *info)
 	outb(0x80, iobase + 0x30);
 
 	if (hci_unregister_dev(hdev) < 0)
-		BT_ERR("Can't unregister HCI device %s", hdev->name);
+		bt_err("Can't unregister HCI device %s", hdev->name);
 
 	hci_free_dev(hdev);
 
diff --git a/drivers/bluetooth/bpa10x.c b/drivers/bluetooth/bpa10x.c
index 751b338..59e8ab3 100644
--- a/drivers/bluetooth/bpa10x.c
+++ b/drivers/bluetooth/bpa10x.c
@@ -68,7 +68,7 @@ static int bpa10x_recv(struct hci_dev *hdev, int queue, void *buf, int count)
 {
 	struct bpa10x_data *data = hdev->driver_data;
 
-	BT_DBG("%s queue %d buffer %p count %d", hdev->name,
+	bt_dbg("%s queue %d buffer %p count %d", hdev->name,
 							queue, buf, count);
 
 	if (queue < 0 || queue > 1)
@@ -125,7 +125,7 @@ static int bpa10x_recv(struct hci_dev *hdev, int queue, void *buf, int count)
 
 			skb = bt_skb_alloc(len, GFP_ATOMIC);
 			if (!skb) {
-				BT_ERR("%s no memory for packet", hdev->name);
+				bt_err("%s no memory for packet", hdev->name);
 				return -ENOMEM;
 			}
 
@@ -169,7 +169,7 @@ static void bpa10x_tx_complete(struct urb *urb)
 	struct sk_buff *skb = urb->context;
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
+	bt_dbg("%s urb %p status %d count %d", hdev->name,
 					urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
@@ -192,7 +192,7 @@ static void bpa10x_rx_complete(struct urb *urb)
 	struct bpa10x_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
+	bt_dbg("%s urb %p status %d count %d", hdev->name,
 					urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
@@ -202,7 +202,7 @@ static void bpa10x_rx_complete(struct urb *urb)
 		if (bpa10x_recv(hdev, usb_pipebulk(urb->pipe),
 						urb->transfer_buffer,
 						urb->actual_length) < 0) {
-			BT_ERR("%s corrupted event packet", hdev->name);
+			bt_err("%s corrupted event packet", hdev->name);
 			hdev->stat.err_rx++;
 		}
 	}
@@ -211,7 +211,7 @@ static void bpa10x_rx_complete(struct urb *urb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
-		BT_ERR("%s urb %p failed to resubmit (%d)",
+		bt_err("%s urb %p failed to resubmit (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
@@ -225,7 +225,7 @@ static inline int bpa10x_submit_intr_urb(struct hci_dev *hdev)
 	unsigned int pipe;
 	int err, size = 16;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!urb)
@@ -248,7 +248,7 @@ static inline int bpa10x_submit_intr_urb(struct hci_dev *hdev)
 
 	err = usb_submit_urb(urb, GFP_KERNEL);
 	if (err < 0) {
-		BT_ERR("%s urb %p submission failed (%d)",
+		bt_err("%s urb %p submission failed (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
@@ -266,7 +266,7 @@ static inline int bpa10x_submit_bulk_urb(struct hci_dev *hdev)
 	unsigned int pipe;
 	int err, size = 64;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!urb)
@@ -289,7 +289,7 @@ static inline int bpa10x_submit_bulk_urb(struct hci_dev *hdev)
 
 	err = usb_submit_urb(urb, GFP_KERNEL);
 	if (err < 0) {
-		BT_ERR("%s urb %p submission failed (%d)",
+		bt_err("%s urb %p submission failed (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
@@ -304,7 +304,7 @@ static int bpa10x_open(struct hci_dev *hdev)
 	struct bpa10x_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (test_and_set_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -331,7 +331,7 @@ static int bpa10x_close(struct hci_dev *hdev)
 {
 	struct bpa10x_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -345,7 +345,7 @@ static int bpa10x_flush(struct hci_dev *hdev)
 {
 	struct bpa10x_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	usb_kill_anchored_urbs(&data->tx_anchor);
 
@@ -361,7 +361,7 @@ static int bpa10x_send_frame(struct sk_buff *skb)
 	unsigned int pipe;
 	int err;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		return -EBUSY;
@@ -422,7 +422,7 @@ static int bpa10x_send_frame(struct sk_buff *skb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
-		BT_ERR("%s urb %p submission failed", hdev->name, urb);
+		bt_err("%s urb %p submission failed", hdev->name, urb);
 		kfree(urb->setup_packet);
 		usb_unanchor_urb(urb);
 	}
@@ -436,7 +436,7 @@ static void bpa10x_destruct(struct hci_dev *hdev)
 {
 	struct bpa10x_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	kfree_skb(data->rx_skb[0]);
 	kfree_skb(data->rx_skb[1]);
@@ -449,7 +449,7 @@ static int bpa10x_probe(struct usb_interface *intf, const struct usb_device_id *
 	struct hci_dev *hdev;
 	int err;
 
-	BT_DBG("intf %p id %p", intf, id);
+	bt_dbg("intf %p id %p", intf, id);
 
 	if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
 		return -ENODEV;
@@ -502,7 +502,7 @@ static void bpa10x_disconnect(struct usb_interface *intf)
 {
 	struct bpa10x_data *data = usb_get_intfdata(intf);
 
-	BT_DBG("intf %p", intf);
+	bt_dbg("intf %p", intf);
 
 	if (!data)
 		return;
@@ -523,7 +523,7 @@ static struct usb_driver bpa10x_driver = {
 
 static int __init bpa10x_init(void)
 {
-	BT_INFO("Digianswer Bluetooth USB driver ver %s", VERSION);
+	bt_info("Digianswer Bluetooth USB driver ver %s", VERSION);
 
 	return usb_register(&bpa10x_driver);
 }
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 4fc0194..cc83eeb 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -179,7 +179,7 @@ static int bt3c_write(unsigned int iobase, int fifo_size, __u8 *buf, int len)
 static void bt3c_write_wakeup(bt3c_info_t *info)
 {
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device");
 		return;
 	}
 
@@ -204,7 +204,7 @@ static void bt3c_write_wakeup(bt3c_info_t *info)
 		len = bt3c_write(iobase, 256, skb->data, skb->len);
 
 		if (len != skb->len) {
-			BT_ERR("Very strange");
+			bt_err("Very strange");
 		}
 
 		kfree_skb(skb);
@@ -221,7 +221,7 @@ static void bt3c_receive(bt3c_info_t *info)
 	int size = 0, avail;
 
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device");
 		return;
 	}
 
@@ -240,7 +240,7 @@ static void bt3c_receive(bt3c_info_t *info)
 			info->rx_state = RECV_WAIT_PACKET_TYPE;
 			info->rx_count = 0;
 			if (!(info->rx_skb = bt_skb_alloc(HCI_MAX_FRAME_SIZE, GFP_ATOMIC))) {
-				BT_ERR("Can't allocate mem for new packet");
+				bt_err("Can't allocate mem for new packet");
 				return;
 			}
 		}
@@ -272,7 +272,7 @@ static void bt3c_receive(bt3c_info_t *info)
 
 			default:
 				/* Unknown packet */
-				BT_ERR("Unknown HCI packet with type 0x%02x received", bt_cb(info->rx_skb)->pkt_type);
+				bt_err("Unknown HCI packet with type 0x%02x received", bt_cb(info->rx_skb)->pkt_type);
 				info->hdev->stat.err_rx++;
 				clear_bit(HCI_RUNNING, &(info->hdev->flags));
 
@@ -355,17 +355,17 @@ static irqreturn_t bt3c_interrupt(int irq, void *dev_inst)
 		int stat = bt3c_read(iobase, 0x7001);
 
 		if ((stat & 0xff) == 0x7f) {
-			BT_ERR("Very strange (stat=0x%04x)", stat);
+			bt_err("Very strange (stat=0x%04x)", stat);
 		} else if ((stat & 0xff) != 0xff) {
 			if (stat & 0x0020) {
 				int status = bt3c_read(iobase, 0x7002) & 0x10;
-				BT_INFO("%s: Antenna %s", info->hdev->name,
+				bt_info("%s: Antenna %s", info->hdev->name,
 							status ? "out" : "in");
 			}
 			if (stat & 0x0001)
 				bt3c_receive(info);
 			if (stat & 0x0002) {
-				//BT_ERR("Ack (stat=0x%04x)", stat);
+				//bt_err("Ack (stat=0x%04x)", stat);
 				clear_bit(XMIT_SENDING, &(info->tx_state));
 				bt3c_write_wakeup(info);
 			}
@@ -424,7 +424,7 @@ static int bt3c_hci_send_frame(struct sk_buff *skb)
 	unsigned long flags;
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown HCI device (hdev=NULL)");
+		bt_err("Frame for unknown HCI device (hdev=NULL)");
 		return -ENODEV;
 	}
 
@@ -494,7 +494,7 @@ static int bt3c_load_firmware(bt3c_info_t *info, const unsigned char *firmware,
 	/* Load */
 	while (count) {
 		if (ptr[0] != 'S') {
-			BT_ERR("Bad address in firmware");
+			bt_err("Bad address in firmware");
 			err = -EFAULT;
 			goto error;
 		}
@@ -518,7 +518,7 @@ static int bt3c_load_firmware(bt3c_info_t *info, const unsigned char *firmware,
 		}
 
 		if (((tmp + fcs) & 0xff) != 0xff) {
-			BT_ERR("Checksum error in firmware");
+			bt_err("Checksum error in firmware");
 			err = -EILSEQ;
 			goto error;
 		}
@@ -573,7 +573,7 @@ static int bt3c_open(bt3c_info_t *info)
 	/* Initialize HCI device */
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can't allocate HCI device");
+		bt_err("Can't allocate HCI device");
 		return -ENOMEM;
 	}
 
@@ -595,7 +595,7 @@ static int bt3c_open(bt3c_info_t *info)
 	/* Load firmware */
 	err = request_firmware(&firmware, "BT3CPCC.bin", &info->p_dev->dev);
 	if (err < 0) {
-		BT_ERR("Firmware request failed");
+		bt_err("Firmware request failed");
 		goto error;
 	}
 
@@ -604,7 +604,7 @@ static int bt3c_open(bt3c_info_t *info)
 	release_firmware(firmware);
 
 	if (err < 0) {
-		BT_ERR("Firmware loading failed");
+		bt_err("Firmware loading failed");
 		goto error;
 	}
 
@@ -614,7 +614,7 @@ static int bt3c_open(bt3c_info_t *info)
 	/* Register HCI device */
 	err = hci_register_dev(hdev);
 	if (err < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device");
 		goto error;
 	}
 
@@ -637,7 +637,7 @@ static int bt3c_close(bt3c_info_t *info)
 	bt3c_hci_close(hdev);
 
 	if (hci_unregister_dev(hdev) < 0)
-		BT_ERR("Can't unregister HCI device %s", hdev->name);
+		bt_err("Can't unregister HCI device %s", hdev->name);
 
 	hci_free_dev(hdev);
 
@@ -728,7 +728,7 @@ static int bt3c_config(struct pcmcia_device *link)
 	if (!pcmcia_loop_config(link, bt3c_check_config_notpicky, NULL))
 		goto found_port;
 
-	BT_ERR("No usable port range found");
+	bt_err("No usable port range found");
 	goto failed;
 
 found_port:
diff --git a/drivers/bluetooth/btmrvl_debugfs.c b/drivers/bluetooth/btmrvl_debugfs.c
index 8ecf4c6..5a96a21 100644
--- a/drivers/bluetooth/btmrvl_debugfs.c
+++ b/drivers/bluetooth/btmrvl_debugfs.c
@@ -394,7 +394,7 @@ void btmrvl_debugfs_init(struct hci_dev *hdev)
 	priv->debugfs_data = dbg;
 
 	if (!dbg) {
-		BT_ERR("Can not allocate memory for btmrvl_debugfs_data.");
+		bt_err("Can not allocate memory for btmrvl_debugfs_data.");
 		return;
 	}
 
diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index 548d1d9..f5352a1 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -70,7 +70,7 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 
 	event = (struct btmrvl_event *) skb->data;
 	if (event->ec != 0xff) {
-		BT_DBG("Not Marvell Event=%x", event->ec);
+		bt_dbg("Not Marvell Event=%x", event->ec);
 		ret = -EINVAL;
 		goto exit;
 	}
@@ -82,19 +82,19 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 				adapter->psmode = 1;
 			else
 				adapter->psmode = 0;
-			BT_DBG("PS Mode:%s",
+			bt_dbg("PS Mode:%s",
 				(adapter->psmode) ? "Enable" : "Disable");
 		} else {
-			BT_DBG("PS Mode command failed");
+			bt_dbg("PS Mode command failed");
 		}
 		break;
 
 	case BT_CMD_HOST_SLEEP_CONFIG:
 		if (!event->data[3])
-			BT_DBG("gpio=%x, gap=%x", event->data[1],
+			bt_dbg("gpio=%x, gap=%x", event->data[1],
 							event->data[2]);
 		else
-			BT_DBG("HSCFG command failed");
+			bt_dbg("HSCFG command failed");
 		break;
 
 	case BT_CMD_HOST_SLEEP_ENABLE:
@@ -103,16 +103,16 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 			if (adapter->psmode)
 				adapter->ps_state = PS_SLEEP;
 			wake_up_interruptible(&adapter->cmd_wait_q);
-			BT_DBG("HS ACTIVATED!");
+			bt_dbg("HS ACTIVATED!");
 		} else {
-			BT_DBG("HS Enable failed");
+			bt_dbg("HS Enable failed");
 		}
 		break;
 
 	case BT_CMD_MODULE_CFG_REQ:
 		if (priv->btmrvl_dev.sendcmdflag &&
 				event->data[1] == MODULE_BRINGUP_REQ) {
-			BT_DBG("EVENT:%s",
+			bt_dbg("EVENT:%s",
 				((event->data[2] == MODULE_BROUGHT_UP) ||
 				(event->data[2] == MODULE_ALREADY_UP)) ?
 				"Bring-up succeed" : "Bring-up failed");
@@ -122,13 +122,13 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 			else
 				priv->btmrvl_dev.dev_type = HCI_BREDR;
 
-			BT_DBG("dev_type: %d", priv->btmrvl_dev.dev_type);
+			bt_dbg("dev_type: %d", priv->btmrvl_dev.dev_type);
 		} else if (priv->btmrvl_dev.sendcmdflag &&
 				event->data[1] == MODULE_SHUTDOWN_REQ) {
-			BT_DBG("EVENT:%s", (event->data[2]) ?
+			bt_dbg("EVENT:%s", (event->data[2]) ?
 				"Shutdown failed" : "Shutdown succeed");
 		} else {
-			BT_DBG("BT_CMD_MODULE_CFG_REQ resp for APP");
+			bt_dbg("BT_CMD_MODULE_CFG_REQ resp for APP");
 			ret = -EINVAL;
 		}
 		break;
@@ -136,12 +136,12 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 	case BT_EVENT_POWER_STATE:
 		if (event->data[1] == BT_PS_SLEEP)
 			adapter->ps_state = PS_SLEEP;
-		BT_DBG("EVENT:%s",
+		bt_dbg("EVENT:%s",
 			(adapter->ps_state) ? "PS_SLEEP" : "PS_AWAKE");
 		break;
 
 	default:
-		BT_DBG("Unknown Event=%d", event->data[0]);
+		bt_dbg("Unknown Event=%d", event->data[0]);
 		ret = -EINVAL;
 		break;
 	}
@@ -162,7 +162,7 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 
 	skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
 	if (skb == NULL) {
-		BT_ERR("No free skb");
+		bt_err("No free skb");
 		return -ENOMEM;
 	}
 
@@ -180,7 +180,7 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 
 	priv->adapter->cmd_complete = false;
 
-	BT_DBG("Queue module cfg Command");
+	bt_dbg("Queue module cfg Command");
 
 	wake_up_interruptible(&priv->main_thread.wait_q);
 
@@ -188,11 +188,11 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 				priv->adapter->cmd_complete,
 				msecs_to_jiffies(WAIT_UNTIL_CMD_RESP))) {
 		ret = -ETIMEDOUT;
-		BT_ERR("module_cfg_cmd(%x): timeout: %d",
+		bt_err("module_cfg_cmd(%x): timeout: %d",
 					subcmd, priv->btmrvl_dev.sendcmdflag);
 	}
 
-	BT_DBG("module cfg Command done");
+	bt_dbg("module cfg Command done");
 
 	return ret;
 }
@@ -205,7 +205,7 @@ int btmrvl_enable_ps(struct btmrvl_private *priv)
 
 	skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
 	if (skb == NULL) {
-		BT_ERR("No free skb");
+		bt_err("No free skb");
 		return -ENOMEM;
 	}
 
@@ -224,7 +224,7 @@ int btmrvl_enable_ps(struct btmrvl_private *priv)
 	skb->dev = (void *) priv->btmrvl_dev.hcidev;
 	skb_queue_head(&priv->adapter->tx_queue, skb);
 
-	BT_DBG("Queue PSMODE Command:%d", cmd->data[0]);
+	bt_dbg("Queue PSMODE Command:%d", cmd->data[0]);
 
 	return 0;
 }
@@ -238,7 +238,7 @@ static int btmrvl_enable_hs(struct btmrvl_private *priv)
 
 	skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
 	if (skb == NULL) {
-		BT_ERR("No free skb");
+		bt_err("No free skb");
 		return -ENOMEM;
 	}
 
@@ -251,7 +251,7 @@ static int btmrvl_enable_hs(struct btmrvl_private *priv)
 	skb->dev = (void *) priv->btmrvl_dev.hcidev;
 	skb_queue_head(&priv->adapter->tx_queue, skb);
 
-	BT_DBG("Queue hs enable Command");
+	bt_dbg("Queue hs enable Command");
 
 	wake_up_interruptible(&priv->main_thread.wait_q);
 
@@ -259,7 +259,7 @@ static int btmrvl_enable_hs(struct btmrvl_private *priv)
 			priv->adapter->hs_state,
 			msecs_to_jiffies(WAIT_UNTIL_HS_STATE_CHANGED))) {
 		ret = -ETIMEDOUT;
-		BT_ERR("timeout: %d, %d,%d", priv->adapter->hs_state,
+		bt_err("timeout: %d, %d,%d", priv->adapter->hs_state,
 						priv->adapter->ps_state,
 						priv->adapter->wakeup_tries);
 	}
@@ -278,7 +278,7 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 
 		skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
 		if (skb == NULL) {
-			BT_ERR("No free skb");
+			bt_err("No free skb");
 			return -ENOMEM;
 		}
 
@@ -293,7 +293,7 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 		skb->dev = (void *) priv->btmrvl_dev.hcidev;
 		skb_queue_head(&priv->adapter->tx_queue, skb);
 
-		BT_DBG("Queue HSCFG Command, gpio=0x%x, gap=0x%x",
+		bt_dbg("Queue HSCFG Command, gpio=0x%x, gap=0x%x",
 						cmd->data[0], cmd->data[1]);
 	}
 
@@ -324,7 +324,7 @@ static int btmrvl_tx_pkt(struct btmrvl_private *priv, struct sk_buff *skb)
 		return -EINVAL;
 
 	if (!skb->len || ((skb->len + BTM_HEADER_LEN) > BTM_UPLD_SIZE)) {
-		BT_ERR("Tx Error: Bad skb length %d : %d",
+		bt_err("Tx Error: Bad skb length %d : %d",
 						skb->len, BTM_UPLD_SIZE);
 		return -EINVAL;
 	}
@@ -334,7 +334,7 @@ static int btmrvl_tx_pkt(struct btmrvl_private *priv, struct sk_buff *skb)
 
 		skb = skb_realloc_headroom(skb, BTM_HEADER_LEN);
 		if (!skb) {
-			BT_ERR("Tx Error: realloc_headroom failed %d",
+			bt_err("Tx Error: realloc_headroom failed %d",
 				BTM_HEADER_LEN);
 			skb = tmp;
 			return -EINVAL;
@@ -394,16 +394,16 @@ static int btmrvl_send_frame(struct sk_buff *skb)
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 	struct btmrvl_private *priv = NULL;
 
-	BT_DBG("type=%d, len=%d", skb->pkt_type, skb->len);
+	bt_dbg("type=%d, len=%d", skb->pkt_type, skb->len);
 
 	if (!hdev || !hdev->driver_data) {
-		BT_ERR("Frame for unknown HCI device");
+		bt_err("Frame for unknown HCI device");
 		return -ENODEV;
 	}
 
 	priv = (struct btmrvl_private *) hdev->driver_data;
 	if (!test_bit(HCI_RUNNING, &hdev->flags)) {
-		BT_ERR("Failed testing HCI_RUNING, flags=%lx", hdev->flags);
+		bt_err("Failed testing HCI_RUNING, flags=%lx", hdev->flags);
 		print_hex_dump_bytes("data: ", DUMP_PREFIX_OFFSET,
 							skb->data, skb->len);
 		return -EBUSY;
@@ -484,7 +484,7 @@ static int btmrvl_service_main_thread(void *data)
 				((!adapter->int_count) &&
 				(!priv->btmrvl_dev.tx_dnld_rdy ||
 				skb_queue_empty(&adapter->tx_queue)))) {
-			BT_DBG("main_thread is sleeping...");
+			bt_dbg("main_thread is sleeping...");
 			schedule();
 		}
 
@@ -492,10 +492,10 @@ static int btmrvl_service_main_thread(void *data)
 
 		remove_wait_queue(&thread->wait_q, &wait);
 
-		BT_DBG("main_thread woke up");
+		bt_dbg("main_thread woke up");
 
 		if (kthread_should_stop()) {
-			BT_DBG("main_thread: break from main thread");
+			bt_dbg("main_thread: break from main thread");
 			break;
 		}
 
@@ -541,7 +541,7 @@ int btmrvl_register_hdev(struct btmrvl_private *priv)
 
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can not allocate HCI device");
+		bt_err("Can not allocate HCI device");
 		goto err_hdev;
 	}
 
@@ -563,7 +563,7 @@ int btmrvl_register_hdev(struct btmrvl_private *priv)
 
 	ret = hci_register_dev(hdev);
 	if (ret < 0) {
-		BT_ERR("Can not register HCI device");
+		bt_err("Can not register HCI device");
 		goto err_hci_register_dev;
 	}
 
@@ -593,19 +593,19 @@ struct btmrvl_private *btmrvl_add_card(void *card)
 
 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
 	if (!priv) {
-		BT_ERR("Can not allocate priv");
+		bt_err("Can not allocate priv");
 		goto err_priv;
 	}
 
 	priv->adapter = kzalloc(sizeof(*priv->adapter), GFP_KERNEL);
 	if (!priv->adapter) {
-		BT_ERR("Allocate buffer for btmrvl_adapter failed!");
+		bt_err("Allocate buffer for btmrvl_adapter failed!");
 		goto err_adapter;
 	}
 
 	btmrvl_init_adapter(priv);
 
-	BT_DBG("Starting kthread...");
+	bt_dbg("Starting kthread...");
 	priv->main_thread.priv = priv;
 	spin_lock_init(&priv->driver_lock);
 
diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
index 7f521d4..bc51814 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -159,7 +159,7 @@ static int btmrvl_sdio_enable_host_int_mask(struct btmrvl_sdio_card *card,
 
 	sdio_writeb(card->func, mask, card->reg->host_int_mask, &ret);
 	if (ret) {
-		BT_ERR("Unable to enable the host interrupt!");
+		bt_err("Unable to enable the host interrupt!");
 		ret = -EIO;
 	}
 
@@ -180,7 +180,7 @@ static int btmrvl_sdio_disable_host_int_mask(struct btmrvl_sdio_card *card,
 
 	sdio_writeb(card->func, host_int_mask, card->reg->host_int_mask, &ret);
 	if (ret < 0) {
-		BT_ERR("Unable to disable the host interrupt!");
+		bt_err("Unable to disable the host interrupt!");
 		return -EIO;
 	}
 
@@ -206,7 +206,7 @@ static int btmrvl_sdio_poll_card_status(struct btmrvl_sdio_card *card, u8 bits)
 	ret = -ETIMEDOUT;
 
 failed:
-	BT_ERR("FAILED! ret=%d", ret);
+	bt_err("FAILED! ret=%d", ret);
 
 	return ret;
 }
@@ -247,7 +247,7 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 	ret = request_firmware(&fw_helper, card->helper,
 						&card->func->dev);
 	if ((ret < 0) || !fw_helper) {
-		BT_ERR("request_firmware(helper) failed, error code = %d",
+		bt_err("request_firmware(helper) failed, error code = %d",
 									ret);
 		ret = -ENOENT;
 		goto done;
@@ -256,14 +256,14 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 	helper = fw_helper->data;
 	helperlen = fw_helper->size;
 
-	BT_DBG("Downloading helper image (%d bytes), block size %d bytes",
+	bt_dbg("Downloading helper image (%d bytes), block size %d bytes",
 						helperlen, SDIO_BLOCK_SIZE);
 
 	tmphlprbufsz = ALIGN_SZ(BTM_UPLD_SIZE, BTSDIO_DMA_ALIGN);
 
 	tmphlprbuf = kzalloc(tmphlprbufsz, GFP_KERNEL);
 	if (!tmphlprbuf) {
-		BT_ERR("Unable to allocate buffer for helper."
+		bt_err("Unable to allocate buffer for helper."
 			" Terminating download");
 		ret = -ENOMEM;
 		goto done;
@@ -280,7 +280,7 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 		ret = btmrvl_sdio_poll_card_status(card,
 					    CARD_IO_READY | DN_LD_CARD_RDY);
 		if (ret < 0) {
-			BT_ERR("Helper download poll status timeout @ %d",
+			bt_err("Helper download poll status timeout @ %d",
 				hlprblknow);
 			goto done;
 		}
@@ -305,7 +305,7 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 		ret = sdio_writesb(card->func, card->ioport, helperbuf,
 				FIRMWARE_TRANSFER_NBLOCK * SDIO_BLOCK_SIZE);
 		if (ret < 0) {
-			BT_ERR("IO error during helper download @ %d",
+			bt_err("IO error during helper download @ %d",
 				hlprblknow);
 			goto done;
 		}
@@ -313,14 +313,14 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 		hlprblknow += tx_len;
 	} while (true);
 
-	BT_DBG("Transferring helper image EOF block");
+	bt_dbg("Transferring helper image EOF block");
 
 	memset(helperbuf, 0x0, SDIO_BLOCK_SIZE);
 
 	ret = sdio_writesb(card->func, card->ioport, helperbuf,
 							SDIO_BLOCK_SIZE);
 	if (ret < 0) {
-		BT_ERR("IO error in writing helper image EOF block");
+		bt_err("IO error in writing helper image EOF block");
 		goto done;
 	}
 
@@ -349,7 +349,7 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 	ret = request_firmware(&fw_firmware, card->firmware,
 							&card->func->dev);
 	if ((ret < 0) || !fw_firmware) {
-		BT_ERR("request_firmware(firmware) failed, error code = %d",
+		bt_err("request_firmware(firmware) failed, error code = %d",
 									ret);
 		ret = -ENOENT;
 		goto done;
@@ -358,12 +358,12 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 	firmware = fw_firmware->data;
 	firmwarelen = fw_firmware->size;
 
-	BT_DBG("Downloading FW image (%d bytes)", firmwarelen);
+	bt_dbg("Downloading FW image (%d bytes)", firmwarelen);
 
 	tmpfwbufsz = ALIGN_SZ(BTM_UPLD_SIZE, BTSDIO_DMA_ALIGN);
 	tmpfwbuf = kzalloc(tmpfwbufsz, GFP_KERNEL);
 	if (!tmpfwbuf) {
-		BT_ERR("Unable to allocate buffer for firmware."
+		bt_err("Unable to allocate buffer for firmware."
 		       " Terminating download");
 		ret = -ENOMEM;
 		goto done;
@@ -378,7 +378,7 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 		ret = btmrvl_sdio_poll_card_status(card,
 					CARD_IO_READY | DN_LD_CARD_RDY);
 		if (ret < 0) {
-			BT_ERR("FW download with helper poll status"
+			bt_err("FW download with helper poll status"
 						" timeout @ %d", offset);
 			goto done;
 		}
@@ -391,7 +391,7 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 			base0 = sdio_readb(card->func,
 					card->reg->sq_read_base_addr_a0, &ret);
 			if (ret) {
-				BT_ERR("BASE0 register read failed:"
+				bt_err("BASE0 register read failed:"
 					" base0 = 0x%04X(%d)."
 					" Terminating download",
 					base0, base0);
@@ -401,7 +401,7 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 			base1 = sdio_readb(card->func,
 					card->reg->sq_read_base_addr_a1, &ret);
 			if (ret) {
-				BT_ERR("BASE1 register read failed:"
+				bt_err("BASE1 register read failed:"
 					" base1 = 0x%04X(%d)."
 					" Terminating download",
 					base1, base1);
@@ -419,7 +419,7 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 		if (!len)
 			break;
 		else if (len > BTM_UPLD_SIZE) {
-			BT_ERR("FW download failure @%d, invalid length %d",
+			bt_err("FW download failure @%d, invalid length %d",
 								offset, len);
 			ret = -EINVAL;
 			goto done;
@@ -430,12 +430,12 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 		if (len & BIT(0)) {
 			count++;
 			if (count > MAX_WRITE_IOMEM_RETRY) {
-				BT_ERR("FW download failure @%d, "
+				bt_err("FW download failure @%d, "
 					"over max retry count", offset);
 				ret = -EIO;
 				goto done;
 			}
-			BT_ERR("FW CRC error indicated by the helper: "
+			bt_err("FW CRC error indicated by the helper: "
 				"len = 0x%04X, txlen = %d", len, txlen);
 			len &= ~BIT(0);
 			/* Set txlen to 0 so as to resend from same offset */
@@ -456,18 +456,18 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 						tx_blocks * blksz_dl);
 
 		if (ret < 0) {
-			BT_ERR("FW download, writesb(%d) failed @%d",
+			bt_err("FW download, writesb(%d) failed @%d",
 							count, offset);
 			sdio_writeb(card->func, HOST_CMD53_FIN,
 						card->reg->cfg, &ret);
 			if (ret)
-				BT_ERR("writeb failed (CFG)");
+				bt_err("writeb failed (CFG)");
 		}
 
 		offset += txlen;
 	} while (true);
 
-	BT_DBG("FW download over, size %d bytes", offset);
+	bt_dbg("FW download over, size %d bytes", offset);
 
 	ret = 0;
 
@@ -491,7 +491,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 	struct btmrvl_sdio_card *card = priv->btmrvl_dev.card;
 
 	if (!card || !card->func) {
-		BT_ERR("card or function is NULL!");
+		bt_err("card or function is NULL!");
 		ret = -EINVAL;
 		goto exit;
 	}
@@ -499,7 +499,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 	/* Read the length of data to be transferred */
 	ret = btmrvl_sdio_read_rx_len(card, &buf_len);
 	if (ret < 0) {
-		BT_ERR("read rx_len failed");
+		bt_err("read rx_len failed");
 		ret = -EIO;
 		goto exit;
 	}
@@ -509,7 +509,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 
 	if (buf_len <= SDIO_HEADER_LEN
 			|| (buf_block_len * blksz) > ALLOC_BUF_SIZE) {
-		BT_ERR("invalid packet length: %d", buf_len);
+		bt_err("invalid packet length: %d", buf_len);
 		ret = -EINVAL;
 		goto exit;
 	}
@@ -518,7 +518,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 	skb = bt_skb_alloc(buf_block_len * blksz + BTSDIO_DMA_ALIGN,
 								GFP_ATOMIC);
 	if (skb == NULL) {
-		BT_ERR("No free skb");
+		bt_err("No free skb");
 		goto exit;
 	}
 
@@ -534,7 +534,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 	ret = sdio_readsb(card->func, payload, card->ioport,
 			  buf_block_len * blksz);
 	if (ret < 0) {
-		BT_ERR("readsb failed: %d", ret);
+		bt_err("readsb failed: %d", ret);
 		ret = -EIO;
 		goto exit;
 	}
@@ -576,7 +576,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 		break;
 
 	default:
-		BT_ERR("Unknown packet type:%d", type);
+		bt_err("Unknown packet type:%d", type);
 		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, payload,
 						blksz * buf_block_len);
 
@@ -609,7 +609,7 @@ static int btmrvl_sdio_process_int_status(struct btmrvl_private *priv)
 	sdio_claim_host(card->func);
 	if (ireg & DN_LD_HOST_INT_STATUS) {
 		if (priv->btmrvl_dev.tx_dnld_rdy)
-			BT_DBG("tx_done already received: "
+			bt_dbg("tx_done already received: "
 				" int_status=0x%x", ireg);
 		else
 			priv->btmrvl_dev.tx_dnld_rdy = true;
@@ -633,7 +633,7 @@ static void btmrvl_sdio_interrupt(struct sdio_func *func)
 
 	card = sdio_get_drvdata(func);
 	if (!card || !card->priv) {
-		BT_ERR("sbi_interrupt(%p) card or priv is "
+		bt_err("sbi_interrupt(%p) card or priv is "
 				"NULL, card=%p\n", func, card);
 		return;
 	}
@@ -642,7 +642,7 @@ static void btmrvl_sdio_interrupt(struct sdio_func *func)
 
 	ireg = sdio_readb(card->func, card->reg->host_intstatus, &ret);
 	if (ret) {
-		BT_ERR("sdio_readb: read int status register failed");
+		bt_err("sdio_readb: read int status register failed");
 		return;
 	}
 
@@ -652,13 +652,13 @@ static void btmrvl_sdio_interrupt(struct sdio_func *func)
 		 * Clear the interrupt status register and re-enable the
 		 * interrupt.
 		 */
-		BT_DBG("ireg = 0x%x", ireg);
+		bt_dbg("ireg = 0x%x", ireg);
 
 		sdio_writeb(card->func, ~(ireg) & (DN_LD_HOST_INT_STATUS |
 					UP_LD_HOST_INT_STATUS),
 				card->reg->host_intstatus, &ret);
 		if (ret) {
-			BT_ERR("sdio_writeb: clear int status register failed");
+			bt_err("sdio_writeb: clear int status register failed");
 			return;
 		}
 	}
@@ -677,7 +677,7 @@ static int btmrvl_sdio_register_dev(struct btmrvl_sdio_card *card)
 	int ret = 0;
 
 	if (!card || !card->func) {
-		BT_ERR("Error: card or function is NULL!");
+		bt_err("Error: card or function is NULL!");
 		ret = -EINVAL;
 		goto failed;
 	}
@@ -688,21 +688,21 @@ static int btmrvl_sdio_register_dev(struct btmrvl_sdio_card *card)
 
 	ret = sdio_enable_func(func);
 	if (ret) {
-		BT_ERR("sdio_enable_func() failed: ret=%d", ret);
+		bt_err("sdio_enable_func() failed: ret=%d", ret);
 		ret = -EIO;
 		goto release_host;
 	}
 
 	ret = sdio_claim_irq(func, btmrvl_sdio_interrupt);
 	if (ret) {
-		BT_ERR("sdio_claim_irq failed: ret=%d", ret);
+		bt_err("sdio_claim_irq failed: ret=%d", ret);
 		ret = -EIO;
 		goto disable_func;
 	}
 
 	ret = sdio_set_block_size(card->func, SDIO_BLOCK_SIZE);
 	if (ret) {
-		BT_ERR("cannot set SDIO block size");
+		bt_err("cannot set SDIO block size");
 		ret = -EIO;
 		goto release_irq;
 	}
@@ -731,7 +731,7 @@ static int btmrvl_sdio_register_dev(struct btmrvl_sdio_card *card)
 
 	card->ioport |= (reg << 16);
 
-	BT_DBG("SDIO FUNC%d IO port: 0x%x", func->num, card->ioport);
+	bt_dbg("SDIO FUNC%d IO port: 0x%x", func->num, card->ioport);
 
 	sdio_set_drvdata(func, card);
 
@@ -812,7 +812,7 @@ static int btmrvl_sdio_host_to_card(struct btmrvl_private *priv,
 	int tmpbufsz;
 
 	if (!card || !card->func) {
-		BT_ERR("card or function is NULL!");
+		bt_err("card or function is NULL!");
 		return -EINVAL;
 	}
 
@@ -837,7 +837,7 @@ static int btmrvl_sdio_host_to_card(struct btmrvl_private *priv,
 				   buf_block_len * blksz);
 		if (ret < 0) {
 			i++;
-			BT_ERR("i=%d writesb failed: %d", i, ret);
+			bt_err("i=%d writesb failed: %d", i, ret);
 			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
 						payload, nb);
 			ret = -EIO;
@@ -862,25 +862,25 @@ static int btmrvl_sdio_download_fw(struct btmrvl_sdio_card *card)
 	int pollnum = MAX_POLL_TRIES;
 
 	if (!card || !card->func) {
-		BT_ERR("card or function is NULL!");
+		bt_err("card or function is NULL!");
 		return -EINVAL;
 	}
 	sdio_claim_host(card->func);
 
 	if (!btmrvl_sdio_verify_fw_download(card, 1)) {
-		BT_DBG("Firmware already downloaded!");
+		bt_dbg("Firmware already downloaded!");
 		goto done;
 	}
 
 	/* Check if other function driver is downloading the firmware */
 	fws0 = sdio_readb(card->func, card->reg->card_fw_status0, &ret);
 	if (ret) {
-		BT_ERR("Failed to read FW downloading status!");
+		bt_err("Failed to read FW downloading status!");
 		ret = -EIO;
 		goto done;
 	}
 	if (fws0) {
-		BT_DBG("BT not the winner (%#x). Skip FW downloading", fws0);
+		bt_dbg("BT not the winner (%#x). Skip FW downloading", fws0);
 
 		/* Give other function more time to download the firmware */
 		pollnum *= 10;
@@ -888,21 +888,21 @@ static int btmrvl_sdio_download_fw(struct btmrvl_sdio_card *card)
 		if (card->helper) {
 			ret = btmrvl_sdio_download_helper(card);
 			if (ret) {
-				BT_ERR("Failed to download helper!");
+				bt_err("Failed to download helper!");
 				ret = -EIO;
 				goto done;
 			}
 		}
 
 		if (btmrvl_sdio_download_fw_w_helper(card)) {
-			BT_ERR("Failed to download firmware!");
+			bt_err("Failed to download firmware!");
 			ret = -EIO;
 			goto done;
 		}
 	}
 
 	if (btmrvl_sdio_verify_fw_download(card, pollnum)) {
-		BT_ERR("FW failed to be active in time!");
+		bt_err("FW failed to be active in time!");
 		ret = -ETIMEDOUT;
 		goto done;
 	}
@@ -919,7 +919,7 @@ static int btmrvl_sdio_wakeup_fw(struct btmrvl_private *priv)
 	int ret = 0;
 
 	if (!card || !card->func) {
-		BT_ERR("card or function is NULL!");
+		bt_err("card or function is NULL!");
 		return -EINVAL;
 	}
 
@@ -929,7 +929,7 @@ static int btmrvl_sdio_wakeup_fw(struct btmrvl_private *priv)
 
 	sdio_release_host(card->func);
 
-	BT_DBG("wake up firmware");
+	bt_dbg("wake up firmware");
 
 	return ret;
 }
@@ -941,7 +941,7 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 	struct btmrvl_private *priv = NULL;
 	struct btmrvl_sdio_card *card = NULL;
 
-	BT_INFO("vendor=0x%x, device=0x%x, class=%d, fn=%d",
+	bt_info("vendor=0x%x, device=0x%x, class=%d, fn=%d",
 			id->vendor, id->device, id->class, func->num);
 
 	card = kzalloc(sizeof(*card), GFP_KERNEL);
@@ -961,7 +961,7 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 	}
 
 	if (btmrvl_sdio_register_dev(card) < 0) {
-		BT_ERR("Failed to register BT device!");
+		bt_err("Failed to register BT device!");
 		ret = -ENODEV;
 		goto free_card;
 	}
@@ -970,7 +970,7 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 	btmrvl_sdio_disable_host_int(card);
 
 	if (btmrvl_sdio_download_fw(card)) {
-		BT_ERR("Downloading firmware failed!");
+		bt_err("Downloading firmware failed!");
 		ret = -ENODEV;
 		goto unreg_dev;
 	}
@@ -981,7 +981,7 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 
 	priv = btmrvl_add_card(card);
 	if (!priv) {
-		BT_ERR("Initializing card failed!");
+		bt_err("Initializing card failed!");
 		ret = -ENODEV;
 		goto disable_host_int;
 	}
@@ -994,7 +994,7 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 	priv->hw_process_int_status = btmrvl_sdio_process_int_status;
 
 	if (btmrvl_register_hdev(priv)) {
-		BT_ERR("Register hdev failed!");
+		bt_err("Register hdev failed!");
 		ret = -ENODEV;
 		goto disable_host_int;
 	}
@@ -1029,7 +1029,7 @@ static void btmrvl_sdio_remove(struct sdio_func *func)
 							MODULE_SHUTDOWN_REQ);
 				btmrvl_sdio_disable_host_int(card);
 			}
-			BT_DBG("unregester dev");
+			bt_dbg("unregester dev");
 			btmrvl_sdio_unregister_dev(card);
 			btmrvl_remove_card(card->priv);
 			kfree(card);
@@ -1047,7 +1047,7 @@ static struct sdio_driver bt_mrvl_sdio = {
 static int __init btmrvl_sdio_init_module(void)
 {
 	if (sdio_register_driver(&bt_mrvl_sdio) != 0) {
-		BT_ERR("SDIO Driver Registration Failed");
+		bt_err("SDIO Driver Registration Failed");
 		return -ENODEV;
 	}
 
diff --git a/drivers/bluetooth/btsdio.c b/drivers/bluetooth/btsdio.c
index 792e32d..47555fe 100644
--- a/drivers/bluetooth/btsdio.c
+++ b/drivers/bluetooth/btsdio.c
@@ -78,7 +78,7 @@ static int btsdio_tx_packet(struct btsdio_data *data, struct sk_buff *skb)
 {
 	int err;
 
-	BT_DBG("%s", data->hdev->name);
+	bt_dbg("%s", data->hdev->name);
 
 	/* Prepend Type-A header */
 	skb_push(skb, 4);
@@ -107,7 +107,7 @@ static void btsdio_work(struct work_struct *work)
 	struct sk_buff *skb;
 	int err;
 
-	BT_DBG("%s", data->hdev->name);
+	bt_dbg("%s", data->hdev->name);
 
 	sdio_claim_host(data->func);
 
@@ -129,7 +129,7 @@ static int btsdio_rx_packet(struct btsdio_data *data)
 	struct sk_buff *skb;
 	int err, len;
 
-	BT_DBG("%s", data->hdev->name);
+	bt_dbg("%s", data->hdev->name);
 
 	err = sdio_readsb(data->func, hdr, REG_RDAT, 4);
 	if (err < 0)
@@ -174,7 +174,7 @@ static void btsdio_interrupt(struct sdio_func *func)
 	struct btsdio_data *data = sdio_get_drvdata(func);
 	int intrd;
 
-	BT_DBG("%s", data->hdev->name);
+	bt_dbg("%s", data->hdev->name);
 
 	intrd = sdio_readb(func, REG_INTRD, NULL);
 	if (intrd & 0x01) {
@@ -192,7 +192,7 @@ static int btsdio_open(struct hci_dev *hdev)
 	struct btsdio_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (test_and_set_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -227,7 +227,7 @@ static int btsdio_close(struct hci_dev *hdev)
 {
 	struct btsdio_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -248,7 +248,7 @@ static int btsdio_flush(struct hci_dev *hdev)
 {
 	struct btsdio_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	skb_queue_purge(&data->txq);
 
@@ -260,7 +260,7 @@ static int btsdio_send_frame(struct sk_buff *skb)
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 	struct btsdio_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		return -EBUSY;
@@ -293,7 +293,7 @@ static void btsdio_destruct(struct hci_dev *hdev)
 {
 	struct btsdio_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	kfree(data);
 }
@@ -306,10 +306,10 @@ static int btsdio_probe(struct sdio_func *func,
 	struct sdio_func_tuple *tuple = func->tuples;
 	int err;
 
-	BT_DBG("func %p id %p class 0x%04x", func, id, func->class);
+	bt_dbg("func %p id %p class 0x%04x", func, id, func->class);
 
 	while (tuple) {
-		BT_DBG("code 0x%x size %d", tuple->code, tuple->size);
+		bt_dbg("code 0x%x size %d", tuple->code, tuple->size);
 		tuple = tuple->next;
 	}
 
@@ -366,7 +366,7 @@ static void btsdio_remove(struct sdio_func *func)
 	struct btsdio_data *data = sdio_get_drvdata(func);
 	struct hci_dev *hdev;
 
-	BT_DBG("func %p", func);
+	bt_dbg("func %p", func);
 
 	if (!data)
 		return;
@@ -389,7 +389,7 @@ static struct sdio_driver btsdio_driver = {
 
 static int __init btsdio_init(void)
 {
-	BT_INFO("Generic Bluetooth SDIO driver ver %s", VERSION);
+	bt_info("Generic Bluetooth SDIO driver ver %s", VERSION);
 
 	return sdio_register_driver(&btsdio_driver);
 }
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 526b618..460ec83 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -131,7 +131,7 @@ static int btuart_write(unsigned int iobase, int fifo_size, __u8 *buf, int len)
 static void btuart_write_wakeup(btuart_info_t *info)
 {
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device");
 		return;
 	}
 
@@ -178,7 +178,7 @@ static void btuart_receive(btuart_info_t *info)
 	int boguscount = 0;
 
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device");
 		return;
 	}
 
@@ -192,7 +192,7 @@ static void btuart_receive(btuart_info_t *info)
 			info->rx_state = RECV_WAIT_PACKET_TYPE;
 			info->rx_count = 0;
 			if (!(info->rx_skb = bt_skb_alloc(HCI_MAX_FRAME_SIZE, GFP_ATOMIC))) {
-				BT_ERR("Can't allocate mem for new packet");
+				bt_err("Can't allocate mem for new packet");
 				return;
 			}
 		}
@@ -221,7 +221,7 @@ static void btuart_receive(btuart_info_t *info)
 
 			default:
 				/* Unknown packet */
-				BT_ERR("Unknown HCI packet with type 0x%02x received", bt_cb(info->rx_skb)->pkt_type);
+				bt_err("Unknown HCI packet with type 0x%02x received", bt_cb(info->rx_skb)->pkt_type);
 				info->hdev->stat.err_rx++;
 				clear_bit(HCI_RUNNING, &(info->hdev->flags));
 
@@ -309,7 +309,7 @@ static irqreturn_t btuart_interrupt(int irq, void *dev_inst)
 
 		switch (iir) {
 		case UART_IIR_RLSI:
-			BT_ERR("RLSI");
+			bt_err("RLSI");
 			break;
 		case UART_IIR_RDI:
 			/* Receive interrupt */
@@ -322,7 +322,7 @@ static irqreturn_t btuart_interrupt(int irq, void *dev_inst)
 			}
 			break;
 		default:
-			BT_ERR("Unhandled IIR=%#x", iir);
+			bt_err("Unhandled IIR=%#x", iir);
 			break;
 		}
 
@@ -349,7 +349,7 @@ static void btuart_change_speed(btuart_info_t *info, unsigned int speed)
 	int divisor;
 
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device");
 		return;
 	}
 
@@ -431,7 +431,7 @@ static int btuart_hci_send_frame(struct sk_buff *skb)
 	struct hci_dev *hdev = (struct hci_dev *)(skb->dev);
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown HCI device (hdev=NULL)");
+		bt_err("Frame for unknown HCI device (hdev=NULL)");
 		return -ENODEV;
 	}
 
@@ -491,7 +491,7 @@ static int btuart_open(btuart_info_t *info)
 	/* Initialize HCI device */
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can't allocate HCI device");
+		bt_err("Can't allocate HCI device");
 		return -ENOMEM;
 	}
 
@@ -534,7 +534,7 @@ static int btuart_open(btuart_info_t *info)
 
 	/* Register HCI device */
 	if (hci_register_dev(hdev) < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device");
 		info->hdev = NULL;
 		hci_free_dev(hdev);
 		return -ENODEV;
@@ -566,7 +566,7 @@ static int btuart_close(btuart_info_t *info)
 	spin_unlock_irqrestore(&(info->lock), flags);
 
 	if (hci_unregister_dev(hdev) < 0)
-		BT_ERR("Can't unregister HCI device %s", hdev->name);
+		bt_err("Can't unregister HCI device %s", hdev->name);
 
 	hci_free_dev(hdev);
 
@@ -657,7 +657,7 @@ static int btuart_config(struct pcmcia_device *link)
 	if (!pcmcia_loop_config(link, btuart_check_config_notpicky, NULL))
 		goto found_port;
 
-	BT_ERR("No usable port range found");
+	bt_err("No usable port range found");
 	goto failed;
 
 found_port:
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index c2de895..8e2fdf5 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -230,7 +230,7 @@ static void btusb_intr_complete(struct urb *urb)
 	struct btusb_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
+	bt_dbg("%s urb %p status %d count %d", hdev->name,
 					urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
@@ -242,7 +242,7 @@ static void btusb_intr_complete(struct urb *urb)
 		if (hci_recv_fragment(hdev, HCI_EVENT_PKT,
 						urb->transfer_buffer,
 						urb->actual_length) < 0) {
-			BT_ERR("%s corrupted event packet", hdev->name);
+			bt_err("%s corrupted event packet", hdev->name);
 			hdev->stat.err_rx++;
 		}
 	}
@@ -256,7 +256,7 @@ static void btusb_intr_complete(struct urb *urb)
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
 		if (err != -EPERM)
-			BT_ERR("%s urb %p failed to resubmit (%d)",
+			bt_err("%s urb %p failed to resubmit (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
@@ -270,7 +270,7 @@ static int btusb_submit_intr_urb(struct hci_dev *hdev, gfp_t mem_flags)
 	unsigned int pipe;
 	int err, size;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (!data->intr_ep)
 		return -ENODEV;
@@ -299,7 +299,7 @@ static int btusb_submit_intr_urb(struct hci_dev *hdev, gfp_t mem_flags)
 
 	err = usb_submit_urb(urb, mem_flags);
 	if (err < 0) {
-		BT_ERR("%s urb %p submission failed (%d)",
+		bt_err("%s urb %p submission failed (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
@@ -315,7 +315,7 @@ static void btusb_bulk_complete(struct urb *urb)
 	struct btusb_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
+	bt_dbg("%s urb %p status %d count %d", hdev->name,
 					urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
@@ -327,7 +327,7 @@ static void btusb_bulk_complete(struct urb *urb)
 		if (hci_recv_fragment(hdev, HCI_ACLDATA_PKT,
 						urb->transfer_buffer,
 						urb->actual_length) < 0) {
-			BT_ERR("%s corrupted ACL packet", hdev->name);
+			bt_err("%s corrupted ACL packet", hdev->name);
 			hdev->stat.err_rx++;
 		}
 	}
@@ -341,7 +341,7 @@ static void btusb_bulk_complete(struct urb *urb)
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
 		if (err != -EPERM)
-			BT_ERR("%s urb %p failed to resubmit (%d)",
+			bt_err("%s urb %p failed to resubmit (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
@@ -355,7 +355,7 @@ static int btusb_submit_bulk_urb(struct hci_dev *hdev, gfp_t mem_flags)
 	unsigned int pipe;
 	int err, size = HCI_MAX_FRAME_SIZE;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (!data->bulk_rx_ep)
 		return -ENODEV;
@@ -382,7 +382,7 @@ static int btusb_submit_bulk_urb(struct hci_dev *hdev, gfp_t mem_flags)
 
 	err = usb_submit_urb(urb, mem_flags);
 	if (err < 0) {
-		BT_ERR("%s urb %p submission failed (%d)",
+		bt_err("%s urb %p submission failed (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
@@ -398,7 +398,7 @@ static void btusb_isoc_complete(struct urb *urb)
 	struct btusb_data *data = hdev->driver_data;
 	int i, err;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
+	bt_dbg("%s urb %p status %d count %d", hdev->name,
 					urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
@@ -417,7 +417,7 @@ static void btusb_isoc_complete(struct urb *urb)
 			if (hci_recv_fragment(hdev, HCI_SCODATA_PKT,
 						urb->transfer_buffer + offset,
 								length) < 0) {
-				BT_ERR("%s corrupted SCO packet", hdev->name);
+				bt_err("%s corrupted SCO packet", hdev->name);
 				hdev->stat.err_rx++;
 			}
 		}
@@ -431,7 +431,7 @@ static void btusb_isoc_complete(struct urb *urb)
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
 		if (err != -EPERM)
-			BT_ERR("%s urb %p failed to resubmit (%d)",
+			bt_err("%s urb %p failed to resubmit (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
@@ -441,7 +441,7 @@ static inline void __fill_isoc_descriptor(struct urb *urb, int len, int mtu)
 {
 	int i, offset = 0;
 
-	BT_DBG("len %d mtu %d", len, mtu);
+	bt_dbg("len %d mtu %d", len, mtu);
 
 	for (i = 0; i < BTUSB_MAX_ISOC_FRAMES && len >= mtu;
 					i++, offset += mtu, len -= mtu) {
@@ -466,7 +466,7 @@ static int btusb_submit_isoc_urb(struct hci_dev *hdev, gfp_t mem_flags)
 	unsigned int pipe;
 	int err, size;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (!data->isoc_rx_ep)
 		return -ENODEV;
@@ -503,7 +503,7 @@ static int btusb_submit_isoc_urb(struct hci_dev *hdev, gfp_t mem_flags)
 
 	err = usb_submit_urb(urb, mem_flags);
 	if (err < 0) {
-		BT_ERR("%s urb %p submission failed (%d)",
+		bt_err("%s urb %p submission failed (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
@@ -519,7 +519,7 @@ static void btusb_tx_complete(struct urb *urb)
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 	struct btusb_data *data = hdev->driver_data;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
+	bt_dbg("%s urb %p status %d count %d", hdev->name,
 					urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
@@ -545,7 +545,7 @@ static void btusb_isoc_tx_complete(struct urb *urb)
 	struct sk_buff *skb = urb->context;
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
+	bt_dbg("%s urb %p status %d count %d", hdev->name,
 					urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
@@ -567,7 +567,7 @@ static int btusb_open(struct hci_dev *hdev)
 	struct btusb_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	err = usb_autopm_get_interface(data->intf);
 	if (err < 0)
@@ -617,7 +617,7 @@ static int btusb_close(struct hci_dev *hdev)
 	struct btusb_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -646,7 +646,7 @@ static int btusb_flush(struct hci_dev *hdev)
 {
 	struct btusb_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	usb_kill_anchored_urbs(&data->tx_anchor);
 
@@ -662,7 +662,7 @@ static int btusb_send_frame(struct sk_buff *skb)
 	unsigned int pipe;
 	int err;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		return -EBUSY;
@@ -751,7 +751,7 @@ skip_waking:
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
-		BT_ERR("%s urb %p submission failed", hdev->name, urb);
+		bt_err("%s urb %p submission failed", hdev->name, urb);
 		kfree(urb->setup_packet);
 		usb_unanchor_urb(urb);
 	} else {
@@ -768,7 +768,7 @@ static void btusb_destruct(struct hci_dev *hdev)
 {
 	struct btusb_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	kfree(data);
 }
@@ -777,7 +777,7 @@ static void btusb_notify(struct hci_dev *hdev, unsigned int evt)
 {
 	struct btusb_data *data = hdev->driver_data;
 
-	BT_DBG("%s evt %d", hdev->name, evt);
+	bt_dbg("%s evt %d", hdev->name, evt);
 
 	if (hdev->conn_hash.sco_num != data->sco_num) {
 		data->sco_num = hdev->conn_hash.sco_num;
@@ -797,7 +797,7 @@ static inline int __set_isoc_interface(struct hci_dev *hdev, int altsetting)
 
 	err = usb_set_interface(data->udev, 1, altsetting);
 	if (err < 0) {
-		BT_ERR("%s setting interface failed (%d)", hdev->name, -err);
+		bt_err("%s setting interface failed (%d)", hdev->name, -err);
 		return err;
 	}
 
@@ -821,7 +821,7 @@ static inline int __set_isoc_interface(struct hci_dev *hdev, int altsetting)
 	}
 
 	if (!data->isoc_tx_ep || !data->isoc_rx_ep) {
-		BT_ERR("%s invalid SCO descriptors", hdev->name);
+		bt_err("%s invalid SCO descriptors", hdev->name);
 		return -ENODEV;
 	}
 
@@ -889,7 +889,7 @@ static int btusb_probe(struct usb_interface *intf,
 	struct hci_dev *hdev;
 	int i, err;
 
-	BT_DBG("intf %p id %p", intf, id);
+	bt_dbg("intf %p id %p", intf, id);
 
 	/* interface numbers are hardcoded in the spec */
 	if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
@@ -1056,7 +1056,7 @@ static void btusb_disconnect(struct usb_interface *intf)
 	struct btusb_data *data = usb_get_intfdata(intf);
 	struct hci_dev *hdev;
 
-	BT_DBG("intf %p", intf);
+	bt_dbg("intf %p", intf);
 
 	if (!data)
 		return;
@@ -1087,7 +1087,7 @@ static int btusb_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct btusb_data *data = usb_get_intfdata(intf);
 
-	BT_DBG("intf %p", intf);
+	bt_dbg("intf %p", intf);
 
 	if (data->suspend_count++)
 		return 0;
@@ -1131,7 +1131,7 @@ static int btusb_resume(struct usb_interface *intf)
 	struct hci_dev *hdev = data->hdev;
 	int err = 0;
 
-	BT_DBG("intf %p", intf);
+	bt_dbg("intf %p", intf);
 
 	if (--data->suspend_count)
 		return 0;
@@ -1197,7 +1197,7 @@ static struct usb_driver btusb_driver = {
 
 static int __init btusb_init(void)
 {
-	BT_INFO("Generic Bluetooth USB driver ver %s", VERSION);
+	bt_info("Generic Bluetooth USB driver ver %s", VERSION);
 
 	return usb_register(&btusb_driver);
 }
diff --git a/drivers/bluetooth/btwilink.c b/drivers/bluetooth/btwilink.c
index 65d27af..874daa9 100644
--- a/drivers/bluetooth/btwilink.c
+++ b/drivers/bluetooth/btwilink.c
@@ -112,7 +112,7 @@ static long st_receive(void *priv_data, struct sk_buff *skb)
 	/* Forward skb to HCI core layer */
 	err = hci_recv_frame(skb);
 	if (err < 0) {
-		BT_ERR("Unable to push skb to HCI core(%d)", err);
+		bt_err("Unable to push skb to HCI core(%d)", err);
 		return err;
 	}
 
@@ -154,7 +154,7 @@ static int ti_st_open(struct hci_dev *hdev)
 	struct ti_st *hst;
 	int err, i;
 
-	BT_DBG("%s %p", hdev->name, hdev);
+	bt_dbg("%s %p", hdev->name, hdev);
 
 	if (test_and_set_bit(HCI_RUNNING, &hdev->flags))
 		return -EBUSY;
@@ -183,21 +183,21 @@ static int ti_st_open(struct hci_dev *hdev)
 
 		if (err != -EINPROGRESS) {
 			clear_bit(HCI_RUNNING, &hdev->flags);
-			BT_ERR("st_register failed %d", err);
+			bt_err("st_register failed %d", err);
 			return err;
 		}
 
 		/* ST is busy with either protocol
 		 * registration or firmware download.
 		 */
-		BT_DBG("waiting for registration "
+		bt_dbg("waiting for registration "
 				"completion signal from ST");
 		timeleft = wait_for_completion_timeout
 			(&hst->wait_reg_completion,
 			 msecs_to_jiffies(BT_REGISTER_TIMEOUT));
 		if (!timeleft) {
 			clear_bit(HCI_RUNNING, &hdev->flags);
-			BT_ERR("Timeout(%d sec),didn't get reg "
+			bt_err("Timeout(%d sec),didn't get reg "
 					"completion signal from ST",
 					BT_REGISTER_TIMEOUT / 1000);
 			return -ETIMEDOUT;
@@ -207,7 +207,7 @@ static int ti_st_open(struct hci_dev *hdev)
 		 * called with ERROR status? */
 		if (hst->reg_status != 0) {
 			clear_bit(HCI_RUNNING, &hdev->flags);
-			BT_ERR("ST registration completed with invalid "
+			bt_err("ST registration completed with invalid "
 					"status %d", hst->reg_status);
 			return -EAGAIN;
 		}
@@ -215,13 +215,13 @@ static int ti_st_open(struct hci_dev *hdev)
 done:
 		hst->st_write = ti_st_proto[i].write;
 		if (!hst->st_write) {
-			BT_ERR("undefined ST write function");
+			bt_err("undefined ST write function");
 			clear_bit(HCI_RUNNING, &hdev->flags);
 			for (i = 0; i < MAX_BT_CHNL_IDS; i++) {
 				/* Undo registration with ST */
 				err = st_unregister(&ti_st_proto[i]);
 				if (err)
-					BT_ERR("st_unregister() failed with "
+					bt_err("st_unregister() failed with "
 							"error %d", err);
 				hst->st_write = NULL;
 			}
@@ -243,7 +243,7 @@ static int ti_st_close(struct hci_dev *hdev)
 	for (i = 0; i < MAX_BT_CHNL_IDS; i++) {
 		err = st_unregister(&ti_st_proto[i]);
 		if (err)
-			BT_ERR("st_unregister(%d) failed with error %d",
+			bt_err("st_unregister(%d) failed with error %d",
 					ti_st_proto[i].chnl_id, err);
 	}
 
@@ -268,7 +268,7 @@ static int ti_st_send_frame(struct sk_buff *skb)
 	/* Prepend skb with frame type */
 	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
 
-	BT_DBG("%s: type %d len %d", hdev->name, bt_cb(skb)->pkt_type,
+	bt_dbg("%s: type %d len %d", hdev->name, bt_cb(skb)->pkt_type,
 			skb->len);
 
 	/* Insert skb to shared transport layer's transmit queue.
@@ -278,7 +278,7 @@ static int ti_st_send_frame(struct sk_buff *skb)
 	len = hst->st_write(skb);
 	if (len < 0) {
 		kfree_skb(skb);
-		BT_ERR("ST write failed (%ld)", len);
+		bt_err("ST write failed (%ld)", len);
 		/* Try Again, would only fail if UART has gone bad */
 		return -EAGAIN;
 	}
@@ -292,7 +292,7 @@ static int ti_st_send_frame(struct sk_buff *skb)
 
 static void ti_st_destruct(struct hci_dev *hdev)
 {
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 	/* do nothing here, since platform remove
 	 * would free the hdev->driver_data
 	 */
@@ -315,7 +315,7 @@ static int bt_ti_probe(struct platform_device *pdev)
 		return -ENOMEM;
 	}
 
-	BT_DBG("hdev %p", hdev);
+	bt_dbg("hdev %p", hdev);
 
 	hst->hdev = hdev;
 	hdev->bus = HCI_UART;
@@ -329,13 +329,13 @@ static int bt_ti_probe(struct platform_device *pdev)
 
 	err = hci_register_dev(hdev);
 	if (err < 0) {
-		BT_ERR("Can't register HCI device error %d", err);
+		bt_err("Can't register HCI device error %d", err);
 		kfree(hst);
 		hci_free_dev(hdev);
 		return err;
 	}
 
-	BT_DBG("HCI device registered (hdev %p)", hdev);
+	bt_dbg("HCI device registered (hdev %p)", hdev);
 
 	dev_set_drvdata(&pdev->dev, hst);
 	return err;
@@ -349,7 +349,7 @@ static int bt_ti_remove(struct platform_device *pdev)
 	if (!hst)
 		return -EFAULT;
 
-	BT_DBG("%s", hst->hdev->name);
+	bt_dbg("%s", hst->hdev->name);
 
 	hdev = hst->hdev;
 	ti_st_close(hdev);
@@ -374,7 +374,7 @@ static struct platform_driver btwilink_driver = {
 /* ------- Module Init/Exit interfaces ------ */
 static int __init btwilink_init(void)
 {
-	BT_INFO("Bluetooth Driver for TI WiLink - Version %s", VERSION);
+	bt_info("Bluetooth Driver for TI WiLink - Version %s", VERSION);
 
 	return platform_driver_register(&btwilink_driver);
 }
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 5e4c2de..887660f 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -133,7 +133,7 @@ static int dtl1_write(unsigned int iobase, int fifo_size, __u8 *buf, int len)
 static void dtl1_write_wakeup(dtl1_info_t *info)
 {
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device");
 		return;
 	}
 
@@ -209,7 +209,7 @@ static void dtl1_receive(dtl1_info_t *info)
 	int boguscount = 0;
 
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device");
 		return;
 	}
 
@@ -221,7 +221,7 @@ static void dtl1_receive(dtl1_info_t *info)
 		/* Allocate packet */
 		if (info->rx_skb == NULL)
 			if (!(info->rx_skb = bt_skb_alloc(HCI_MAX_FRAME_SIZE, GFP_ATOMIC))) {
-				BT_ERR("Can't allocate mem for new packet");
+				bt_err("Can't allocate mem for new packet");
 				info->rx_state = RECV_WAIT_NSH;
 				info->rx_count = NSHL;
 				return;
@@ -266,7 +266,7 @@ static void dtl1_receive(dtl1_info_t *info)
 					break;
 				default:
 					/* unknown packet */
-					BT_ERR("Unknown HCI packet with type 0x%02x received", bt_cb(info->rx_skb)->pkt_type);
+					bt_err("Unknown HCI packet with type 0x%02x received", bt_cb(info->rx_skb)->pkt_type);
 					kfree_skb(info->rx_skb);
 					break;
 				}
@@ -313,7 +313,7 @@ static irqreturn_t dtl1_interrupt(int irq, void *dev_inst)
 
 		switch (iir) {
 		case UART_IIR_RLSI:
-			BT_ERR("RLSI");
+			bt_err("RLSI");
 			break;
 		case UART_IIR_RDI:
 			/* Receive interrupt */
@@ -326,7 +326,7 @@ static irqreturn_t dtl1_interrupt(int irq, void *dev_inst)
 			}
 			break;
 		default:
-			BT_ERR("Unhandled IIR=%#x", iir);
+			bt_err("Unhandled IIR=%#x", iir);
 			break;
 		}
 
@@ -395,7 +395,7 @@ static int dtl1_hci_send_frame(struct sk_buff *skb)
 	nsh_t nsh;
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown HCI device (hdev=NULL)");
+		bt_err("Frame for unknown HCI device (hdev=NULL)");
 		return -ENODEV;
 	}
 
@@ -476,7 +476,7 @@ static int dtl1_open(dtl1_info_t *info)
 	/* Initialize HCI device */
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can't allocate HCI device");
+		bt_err("Can't allocate HCI device");
 		return -ENOMEM;
 	}
 
@@ -520,7 +520,7 @@ static int dtl1_open(dtl1_info_t *info)
 
 	/* Register HCI device */
 	if (hci_register_dev(hdev) < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device");
 		info->hdev = NULL;
 		hci_free_dev(hdev);
 		return -ENODEV;
@@ -552,7 +552,7 @@ static int dtl1_close(dtl1_info_t *info)
 	spin_unlock_irqrestore(&(info->lock), flags);
 
 	if (hci_unregister_dev(hdev) < 0)
-		BT_ERR("Can't unregister HCI device %s", hdev->name);
+		bt_err("Can't unregister HCI device %s", hdev->name);
 
 	hci_free_dev(hdev);
 
diff --git a/drivers/bluetooth/hci_ath.c b/drivers/bluetooth/hci_ath.c
index 4093935..c65b1e6 100644
--- a/drivers/bluetooth/hci_ath.c
+++ b/drivers/bluetooth/hci_ath.c
@@ -110,7 +110,7 @@ static int ath_open(struct hci_uart *hu)
 {
 	struct ath_struct *ath;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	ath = kzalloc(sizeof(*ath), GFP_ATOMIC);
 	if (!ath)
@@ -131,7 +131,7 @@ static int ath_flush(struct hci_uart *hu)
 {
 	struct ath_struct *ath = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	skb_queue_purge(&ath->txq);
 
@@ -143,7 +143,7 @@ static int ath_close(struct hci_uart *hu)
 {
 	struct ath_struct *ath = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	skb_queue_purge(&ath->txq);
 
@@ -178,7 +178,7 @@ static int ath_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 			ath->cur_sleep = skb->data[HCI_COMMAND_HDR_SIZE];
 	}
 
-	BT_DBG("hu %p skb %p", hu, skb);
+	bt_dbg("hu %p skb %p", hu, skb);
 
 	/* Prepend skb with frame type */
 	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
@@ -205,7 +205,7 @@ static int ath_recv(struct hci_uart *hu, void *data, int count)
 
 	ret = hci_recv_stream_fragment(hu->hdev, data, count);
 	if (ret < 0) {
-		BT_ERR("Frame Reassembly Failed");
+		bt_err("Frame Reassembly Failed");
 		return ret;
 	}
 
@@ -227,9 +227,9 @@ int __init ath_init(void)
 	int err = hci_uart_register_proto(&athp);
 
 	if (!err)
-		BT_INFO("HCIATH3K protocol initialized");
+		bt_info("HCIATH3K protocol initialized");
 	else
-		BT_ERR("HCIATH3K protocol registration failed");
+		bt_err("HCIATH3K protocol registration failed");
 
 	return err;
 }
diff --git a/drivers/bluetooth/hci_bcsp.c b/drivers/bluetooth/hci_bcsp.c
index 9c5b2dc..2bd1db8 100644
--- a/drivers/bluetooth/hci_bcsp.c
+++ b/drivers/bluetooth/hci_bcsp.c
@@ -152,7 +152,7 @@ static int bcsp_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 	struct bcsp_struct *bcsp = hu->priv;
 
 	if (skb->len > 0xFFF) {
-		BT_ERR("Packet too long");
+		bt_err("Packet too long");
 		kfree_skb(skb);
 		return 0;
 	}
@@ -168,7 +168,7 @@ static int bcsp_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 		break;
 
 	default:
-		BT_ERR("Unknown packet type");
+		bt_err("Unknown packet type");
 		kfree_skb(skb);
 		break;
 	}
@@ -206,7 +206,7 @@ static struct sk_buff *bcsp_prepare_pkt(struct bcsp_struct *bcsp, u8 *data,
 		rel = 0;	/* unreliable channel */
 		break;
 	default:
-		BT_ERR("Unknown packet type");
+		bt_err("Unknown packet type");
 		return NULL;
 	}
 
@@ -239,11 +239,11 @@ static struct sk_buff *bcsp_prepare_pkt(struct bcsp_struct *bcsp, u8 *data,
 
 	hdr[0] = bcsp->rxseq_txack << 3;
 	bcsp->txack_req = 0;
-	BT_DBG("We request packet no %u to card", bcsp->rxseq_txack);
+	bt_dbg("We request packet no %u to card", bcsp->rxseq_txack);
 
 	if (rel) {
 		hdr[0] |= 0x80 + bcsp->msgq_txseq;
-		BT_DBG("Sending packet with seqno %u", bcsp->msgq_txseq);
+		bt_dbg("Sending packet with seqno %u", bcsp->msgq_txseq);
 		bcsp->msgq_txseq = (bcsp->msgq_txseq + 1) & 0x07;
 	}
 
@@ -298,7 +298,7 @@ static struct sk_buff *bcsp_dequeue(struct hci_uart *hu)
 			return nskb;
 		} else {
 			skb_queue_head(&bcsp->unrel, skb);
-			BT_ERR("Could not dequeue pkt because alloc_skb failed");
+			bt_err("Could not dequeue pkt because alloc_skb failed");
 		}
 	}
 
@@ -317,7 +317,7 @@ static struct sk_buff *bcsp_dequeue(struct hci_uart *hu)
 			return nskb;
 		} else {
 			skb_queue_head(&bcsp->rel, skb);
-			BT_ERR("Could not dequeue pkt because alloc_skb failed");
+			bt_err("Could not dequeue pkt because alloc_skb failed");
 		}
 	}
 
@@ -340,7 +340,7 @@ static struct sk_buff *bcsp_dequeue(struct hci_uart *hu)
 
 static int bcsp_flush(struct hci_uart *hu)
 {
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 	return 0;
 }
 
@@ -365,9 +365,9 @@ static void bcsp_pkt_cull(struct bcsp_struct *bcsp)
 	}
 
 	if (bcsp->rxack != seqno)
-		BT_ERR("Peer acked invalid packet");
+		bt_err("Peer acked invalid packet");
 
-	BT_DBG("Removing %u pkts out of %u, up to seqno %u",
+	bt_dbg("Removing %u pkts out of %u, up to seqno %u",
 	       pkts_to_be_removed, skb_queue_len(&bcsp->unack),
 	       (seqno - 1) & 0x07);
 
@@ -387,7 +387,7 @@ static void bcsp_pkt_cull(struct bcsp_struct *bcsp)
 	spin_unlock_irqrestore(&bcsp->unack.lock, flags);
 
 	if (i != pkts_to_be_removed)
-		BT_ERR("Removed only %u out of %u pkts", i, pkts_to_be_removed);
+		bt_err("Removed only %u out of %u pkts", i, pkts_to_be_removed);
 }
 
 /* Handle BCSP link-establishment packets. When we
@@ -405,7 +405,7 @@ static void bcsp_handle_le_pkt(struct hci_uart *hu)
 			!memcmp(&bcsp->rx_skb->data[4], conf_pkt, 4)) {
 		struct sk_buff *nskb = alloc_skb(4, GFP_ATOMIC);
 
-		BT_DBG("Found a LE conf pkt");
+		bt_dbg("Found a LE conf pkt");
 		if (!nskb)
 			return;
 		memcpy(skb_put(nskb, 4), conf_rsp_pkt, 4);
@@ -417,7 +417,7 @@ static void bcsp_handle_le_pkt(struct hci_uart *hu)
 	/* Spot "sync" pkts. If we find one...disaster! */
 	else if (bcsp->rx_skb->data[1] >> 4 == 4 && bcsp->rx_skb->data[2] == 0 &&
 			!memcmp(&bcsp->rx_skb->data[4], sync_pkt, 4)) {
-		BT_ERR("Found a LE sync pkt, card has reset");
+		bt_err("Found a LE sync pkt, card has reset");
 	}
 }
 
@@ -461,7 +461,7 @@ static inline void bcsp_unslip_one_byte(struct bcsp_struct *bcsp, unsigned char
 			break;
 
 		default:
-			BT_ERR ("Invalid byte %02x after esc byte", byte);
+			bt_err ("Invalid byte %02x after esc byte", byte);
 			kfree_skb(bcsp->rx_skb);
 			bcsp->rx_skb = NULL;
 			bcsp->rx_state = BCSP_W4_PKT_DELIMITER;
@@ -476,7 +476,7 @@ static void bcsp_complete_rx_pkt(struct hci_uart *hu)
 	int pass_up;
 
 	if (bcsp->rx_skb->data[0] & 0x80) {	/* reliable pkt */
-		BT_DBG("Received seqno %u from card", bcsp->rxseq_txack);
+		bt_dbg("Received seqno %u from card", bcsp->rxseq_txack);
 		bcsp->rxseq_txack++;
 		bcsp->rxseq_txack %= 0x8;
 		bcsp->txack_req    = 1;
@@ -486,7 +486,7 @@ static void bcsp_complete_rx_pkt(struct hci_uart *hu)
 	}
 
 	bcsp->rxack = (bcsp->rx_skb->data[0] >> 3) & 0x07;
-	BT_DBG("Request for pkt %u from card", bcsp->rxack);
+	bt_dbg("Request for pkt %u from card", bcsp->rxack);
 
 	bcsp_pkt_cull(bcsp);
 	if ((bcsp->rx_skb->data[1] & 0x0f) == 6 &&
@@ -524,7 +524,7 @@ static void bcsp_complete_rx_pkt(struct hci_uart *hu)
 
 				hci_recv_frame(bcsp->rx_skb);
 			} else {
-				BT_ERR ("Packet for unknown channel (%u %s)",
+				bt_err ("Packet for unknown channel (%u %s)",
 					bcsp->rx_skb->data[1] & 0x0f,
 					bcsp->rx_skb->data[0] & 0x80 ? 
 					"reliable" : "unreliable");
@@ -554,14 +554,14 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 	struct bcsp_struct *bcsp = hu->priv;
 	register unsigned char *ptr;
 
-	BT_DBG("hu %p count %d rx_state %d rx_count %ld", 
+	bt_dbg("hu %p count %d rx_state %d rx_count %ld", 
 		hu, count, bcsp->rx_state, bcsp->rx_count);
 
 	ptr = data;
 	while (count) {
 		if (bcsp->rx_count) {
 			if (*ptr == 0xc0) {
-				BT_ERR("Short BCSP packet");
+				bt_err("Short BCSP packet");
 				kfree_skb(bcsp->rx_skb);
 				bcsp->rx_state = BCSP_W4_PKT_START;
 				bcsp->rx_count = 0;
@@ -576,7 +576,7 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 		case BCSP_W4_BCSP_HDR:
 			if ((0xff & (u8) ~ (bcsp->rx_skb->data[0] + bcsp->rx_skb->data[1] +
 					bcsp->rx_skb->data[2])) != bcsp->rx_skb->data[3]) {
-				BT_ERR("Error in BCSP hdr checksum");
+				bt_err("Error in BCSP hdr checksum");
 				kfree_skb(bcsp->rx_skb);
 				bcsp->rx_state = BCSP_W4_PKT_DELIMITER;
 				bcsp->rx_count = 0;
@@ -584,7 +584,7 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 			}
 			if (bcsp->rx_skb->data[0] & 0x80	/* reliable pkt */
 			    		&& (bcsp->rx_skb->data[0] & 0x07) != bcsp->rxseq_txack) {
-				BT_ERR ("Out-of-order packet arrived, got %u expected %u",
+				bt_err ("Out-of-order packet arrived, got %u expected %u",
 					bcsp->rx_skb->data[0] & 0x07, bcsp->rxseq_txack);
 
 				kfree_skb(bcsp->rx_skb);
@@ -607,7 +607,7 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 
 		case BCSP_W4_CRC:
 			if (bitrev16(bcsp->message_crc) != bscp_get_crc(bcsp)) {
-				BT_ERR ("Checksum failed: computed %04x received %04x",
+				bt_err ("Checksum failed: computed %04x received %04x",
 					bitrev16(bcsp->message_crc),
 					bscp_get_crc(bcsp));
 
@@ -626,7 +626,7 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 				bcsp->rx_state = BCSP_W4_PKT_START;
 				break;
 			default:
-				/*BT_ERR("Ignoring byte %02x", *ptr);*/
+				/*bt_err("Ignoring byte %02x", *ptr);*/
 				break;
 			}
 			ptr++; count--;
@@ -650,7 +650,7 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 
 				bcsp->rx_skb = bt_skb_alloc(0x1005, GFP_ATOMIC);
 				if (!bcsp->rx_skb) {
-					BT_ERR("Can't allocate mem for new packet");
+					bt_err("Can't allocate mem for new packet");
 					bcsp->rx_state = BCSP_W4_PKT_DELIMITER;
 					bcsp->rx_count = 0;
 					return 0;
@@ -672,7 +672,7 @@ static void bcsp_timed_event(unsigned long arg)
 	struct sk_buff *skb;
 	unsigned long flags;
 
-	BT_DBG("hu %p retransmitting %u pkts", hu, bcsp->unack.qlen);
+	bt_dbg("hu %p retransmitting %u pkts", hu, bcsp->unack.qlen);
 
 	spin_lock_irqsave_nested(&bcsp->unack.lock, flags, SINGLE_DEPTH_NESTING);
 
@@ -690,7 +690,7 @@ static int bcsp_open(struct hci_uart *hu)
 {
 	struct bcsp_struct *bcsp;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	bcsp = kzalloc(sizeof(*bcsp), GFP_ATOMIC);
 	if (!bcsp)
@@ -718,7 +718,7 @@ static int bcsp_close(struct hci_uart *hu)
 	struct bcsp_struct *bcsp = hu->priv;
 	hu->priv = NULL;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	skb_queue_purge(&bcsp->unack);
 	skb_queue_purge(&bcsp->rel);
@@ -744,9 +744,9 @@ int __init bcsp_init(void)
 	int err = hci_uart_register_proto(&bcsp);
 
 	if (!err)
-		BT_INFO("HCI BCSP protocol initialized");
+		bt_info("HCI BCSP protocol initialized");
 	else
-		BT_ERR("HCI BCSP protocol registration failed");
+		bt_err("HCI BCSP protocol registration failed");
 
 	return err;
 }
diff --git a/drivers/bluetooth/hci_h4.c b/drivers/bluetooth/hci_h4.c
index 2fcd8b3..a962c9f 100644
--- a/drivers/bluetooth/hci_h4.c
+++ b/drivers/bluetooth/hci_h4.c
@@ -67,7 +67,7 @@ static int h4_open(struct hci_uart *hu)
 {
 	struct h4_struct *h4;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	h4 = kzalloc(sizeof(*h4), GFP_ATOMIC);
 	if (!h4)
@@ -84,7 +84,7 @@ static int h4_flush(struct hci_uart *hu)
 {
 	struct h4_struct *h4 = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	skb_queue_purge(&h4->txq);
 
@@ -98,7 +98,7 @@ static int h4_close(struct hci_uart *hu)
 
 	hu->priv = NULL;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	skb_queue_purge(&h4->txq);
 
@@ -115,7 +115,7 @@ static int h4_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 {
 	struct h4_struct *h4 = hu->priv;
 
-	BT_DBG("hu %p skb %p", hu, skb);
+	bt_dbg("hu %p skb %p", hu, skb);
 
 	/* Prepend skb with frame type */
 	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
@@ -128,12 +128,12 @@ static inline int h4_check_data_len(struct h4_struct *h4, int len)
 {
 	register int room = skb_tailroom(h4->rx_skb);
 
-	BT_DBG("len %d room %d", len, room);
+	bt_dbg("len %d room %d", len, room);
 
 	if (!len) {
 		hci_recv_frame(h4->rx_skb);
 	} else if (len > room) {
-		BT_ERR("Data length is too large");
+		bt_err("Data length is too large");
 		kfree_skb(h4->rx_skb);
 	} else {
 		h4->rx_state = H4_W4_DATA;
@@ -155,7 +155,7 @@ static int h4_recv(struct hci_uart *hu, void *data, int count)
 
 	ret = hci_recv_stream_fragment(hu->hdev, data, count);
 	if (ret < 0) {
-		BT_ERR("Frame Reassembly Failed");
+		bt_err("Frame Reassembly Failed");
 		return ret;
 	}
 
@@ -183,9 +183,9 @@ int __init h4_init(void)
 	int err = hci_uart_register_proto(&h4p);
 
 	if (!err)
-		BT_INFO("HCI H4 protocol initialized");
+		bt_info("HCI H4 protocol initialized");
 	else
-		BT_ERR("HCI H4 protocol registration failed");
+		bt_err("HCI H4 protocol registration failed");
 
 	return err;
 }
diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_ldisc.c
index 48ad2a7..a009920 100644
--- a/drivers/bluetooth/hci_ldisc.c
+++ b/drivers/bluetooth/hci_ldisc.c
@@ -129,7 +129,7 @@ int hci_uart_tx_wakeup(struct hci_uart *hu)
 		return 0;
 	}
 
-	BT_DBG("");
+	bt_dbg("");
 
 restart:
 	clear_bit(HCI_UART_TX_WAKEUP, &hu->tx_state);
@@ -162,7 +162,7 @@ restart:
 /* Initialize device */
 static int hci_uart_open(struct hci_dev *hdev)
 {
-	BT_DBG("%s %p", hdev->name, hdev);
+	bt_dbg("%s %p", hdev->name, hdev);
 
 	/* Nothing to do for UART driver */
 
@@ -177,7 +177,7 @@ static int hci_uart_flush(struct hci_dev *hdev)
 	struct hci_uart *hu  = (struct hci_uart *) hdev->driver_data;
 	struct tty_struct *tty = hu->tty;
 
-	BT_DBG("hdev %p tty %p", hdev, tty);
+	bt_dbg("hdev %p tty %p", hdev, tty);
 
 	if (hu->tx_skb) {
 		kfree_skb(hu->tx_skb); hu->tx_skb = NULL;
@@ -196,7 +196,7 @@ static int hci_uart_flush(struct hci_dev *hdev)
 /* Close device */
 static int hci_uart_close(struct hci_dev *hdev)
 {
-	BT_DBG("hdev %p", hdev);
+	bt_dbg("hdev %p", hdev);
 
 	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -213,7 +213,7 @@ static int hci_uart_send_frame(struct sk_buff *skb)
 	struct hci_uart *hu;
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown device (hdev=NULL)");
+		bt_err("Frame for unknown device (hdev=NULL)");
 		return -ENODEV;
 	}
 
@@ -222,7 +222,7 @@ static int hci_uart_send_frame(struct sk_buff *skb)
 
 	hu = (struct hci_uart *) hdev->driver_data;
 
-	BT_DBG("%s: type %d len %d", hdev->name, bt_cb(skb)->pkt_type, skb->len);
+	bt_dbg("%s: type %d len %d", hdev->name, bt_cb(skb)->pkt_type, skb->len);
 
 	hu->proto->enqueue(hu, skb);
 
@@ -236,7 +236,7 @@ static void hci_uart_destruct(struct hci_dev *hdev)
 	if (!hdev)
 		return;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 	kfree(hdev->driver_data);
 }
 
@@ -254,7 +254,7 @@ static int hci_uart_tty_open(struct tty_struct *tty)
 {
 	struct hci_uart *hu = (void *) tty->disc_data;
 
-	BT_DBG("tty %p", tty);
+	bt_dbg("tty %p", tty);
 
 	/* FIXME: This btw is bogus, nothing requires the old ldisc to clear
 	   the pointer */
@@ -267,7 +267,7 @@ static int hci_uart_tty_open(struct tty_struct *tty)
 		return -EOPNOTSUPP;
 
 	if (!(hu = kzalloc(sizeof(struct hci_uart), GFP_KERNEL))) {
-		BT_ERR("Can't allocate control structure");
+		bt_err("Can't allocate control structure");
 		return -ENFILE;
 	}
 
@@ -298,7 +298,7 @@ static void hci_uart_tty_close(struct tty_struct *tty)
 {
 	struct hci_uart *hu = (void *)tty->disc_data;
 
-	BT_DBG("tty %p", tty);
+	bt_dbg("tty %p", tty);
 
 	/* Detach from the tty */
 	tty->disc_data = NULL;
@@ -331,7 +331,7 @@ static void hci_uart_tty_wakeup(struct tty_struct *tty)
 {
 	struct hci_uart *hu = (void *)tty->disc_data;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	if (!hu)
 		return;
@@ -379,12 +379,12 @@ static int hci_uart_register_dev(struct hci_uart *hu)
 {
 	struct hci_dev *hdev;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	/* Initialize and register HCI device */
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can't allocate HCI device");
+		bt_err("Can't allocate HCI device");
 		return -ENOMEM;
 	}
 
@@ -409,7 +409,7 @@ static int hci_uart_register_dev(struct hci_uart *hu)
 		set_bit(HCI_QUIRK_RAW_DEVICE, &hdev->quirks);
 
 	if (hci_register_dev(hdev) < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device");
 		hci_free_dev(hdev);
 		return -ENODEV;
 	}
@@ -460,7 +460,7 @@ static int hci_uart_tty_ioctl(struct tty_struct *tty, struct file * file,
 	struct hci_uart *hu = (void *)tty->disc_data;
 	int err = 0;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	/* Verify the status of the device */
 	if (!hu)
@@ -531,7 +531,7 @@ static int __init hci_uart_init(void)
 	static struct tty_ldisc_ops hci_uart_ldisc;
 	int err;
 
-	BT_INFO("HCI UART driver ver %s", VERSION);
+	bt_info("HCI UART driver ver %s", VERSION);
 
 	/* Register the tty discipline */
 
@@ -549,7 +549,7 @@ static int __init hci_uart_init(void)
 	hci_uart_ldisc.owner		= THIS_MODULE;
 
 	if ((err = tty_register_ldisc(N_HCI, &hci_uart_ldisc))) {
-		BT_ERR("HCI line discipline registration failed. (%d)", err);
+		bt_err("HCI line discipline registration failed. (%d)", err);
 		return err;
 	}
 
@@ -588,7 +588,7 @@ static void __exit hci_uart_exit(void)
 
 	/* Release tty registration of line discipline */
 	if ((err = tty_unregister_ldisc(N_HCI)))
-		BT_ERR("Can't unregister HCI line discipline (%d)", err);
+		bt_err("Can't unregister HCI line discipline (%d)", err);
 }
 
 module_init(hci_uart_init);
diff --git a/drivers/bluetooth/hci_ll.c b/drivers/bluetooth/hci_ll.c
index 7e4b435..008fd4e 100644
--- a/drivers/bluetooth/hci_ll.c
+++ b/drivers/bluetooth/hci_ll.c
@@ -97,12 +97,12 @@ static int send_hcill_cmd(u8 cmd, struct hci_uart *hu)
 	struct ll_struct *ll = hu->priv;
 	struct hcill_cmd *hcill_packet;
 
-	BT_DBG("hu %p cmd 0x%x", hu, cmd);
+	bt_dbg("hu %p cmd 0x%x", hu, cmd);
 
 	/* allocate packet */
 	skb = bt_skb_alloc(1, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("cannot allocate memory for HCILL packet");
+		bt_err("cannot allocate memory for HCILL packet");
 		err = -ENOMEM;
 		goto out;
 	}
@@ -123,7 +123,7 @@ static int ll_open(struct hci_uart *hu)
 {
 	struct ll_struct *ll;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	ll = kzalloc(sizeof(*ll), GFP_ATOMIC);
 	if (!ll)
@@ -145,7 +145,7 @@ static int ll_flush(struct hci_uart *hu)
 {
 	struct ll_struct *ll = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	skb_queue_purge(&ll->tx_wait_q);
 	skb_queue_purge(&ll->txq);
@@ -158,7 +158,7 @@ static int ll_close(struct hci_uart *hu)
 {
 	struct ll_struct *ll = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	skb_queue_purge(&ll->tx_wait_q);
 	skb_queue_purge(&ll->txq);
@@ -197,7 +197,7 @@ static void ll_device_want_to_wakeup(struct hci_uart *hu)
 	unsigned long flags;
 	struct ll_struct *ll = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	/* lock hcill state */
 	spin_lock_irqsave(&ll->hcill_lock, flags);
@@ -214,18 +214,18 @@ static void ll_device_want_to_wakeup(struct hci_uart *hu)
 		 * require an explicit ack here, do accept it, thus it is
 		 * perfectly safe to always send one.
 		 */
-		BT_DBG("dual wake-up-indication");
+		bt_dbg("dual wake-up-indication");
 		/* deliberate fall-through - do not add break */
 	case HCILL_ASLEEP:
 		/* acknowledge device wake up */
 		if (send_hcill_cmd(HCILL_WAKE_UP_ACK, hu) < 0) {
-			BT_ERR("cannot acknowledge device wake up");
+			bt_err("cannot acknowledge device wake up");
 			goto out;
 		}
 		break;
 	default:
 		/* any other state is illegal */
-		BT_ERR("received HCILL_WAKE_UP_IND in state %ld", ll->hcill_state);
+		bt_err("received HCILL_WAKE_UP_IND in state %ld", ll->hcill_state);
 		break;
 	}
 
@@ -247,18 +247,18 @@ static void ll_device_want_to_sleep(struct hci_uart *hu)
 	unsigned long flags;
 	struct ll_struct *ll = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	/* lock hcill state */
 	spin_lock_irqsave(&ll->hcill_lock, flags);
 
 	/* sanity check */
 	if (ll->hcill_state != HCILL_AWAKE)
-		BT_ERR("ERR: HCILL_GO_TO_SLEEP_IND in state %ld", ll->hcill_state);
+		bt_err("ERR: HCILL_GO_TO_SLEEP_IND in state %ld", ll->hcill_state);
 
 	/* acknowledge device sleep */
 	if (send_hcill_cmd(HCILL_GO_TO_SLEEP_ACK, hu) < 0) {
-		BT_ERR("cannot acknowledge device sleep");
+		bt_err("cannot acknowledge device sleep");
 		goto out;
 	}
 
@@ -280,14 +280,14 @@ static void ll_device_woke_up(struct hci_uart *hu)
 	unsigned long flags;
 	struct ll_struct *ll = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	bt_dbg("hu %p", hu);
 
 	/* lock hcill state */
 	spin_lock_irqsave(&ll->hcill_lock, flags);
 
 	/* sanity check */
 	if (ll->hcill_state != HCILL_ASLEEP_TO_AWAKE)
-		BT_ERR("received HCILL_WAKE_UP_ACK in state %ld", ll->hcill_state);
+		bt_err("received HCILL_WAKE_UP_ACK in state %ld", ll->hcill_state);
 
 	/* send pending packets and change state to HCILL_AWAKE */
 	__ll_do_awake(ll);
@@ -305,7 +305,7 @@ static int ll_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 	unsigned long flags = 0;
 	struct ll_struct *ll = hu->priv;
 
-	BT_DBG("hu %p skb %p", hu, skb);
+	bt_dbg("hu %p skb %p", hu, skb);
 
 	/* Prepend skb with frame type */
 	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
@@ -316,27 +316,27 @@ static int ll_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 	/* act according to current state */
 	switch (ll->hcill_state) {
 	case HCILL_AWAKE:
-		BT_DBG("device awake, sending normally");
+		bt_dbg("device awake, sending normally");
 		skb_queue_tail(&ll->txq, skb);
 		break;
 	case HCILL_ASLEEP:
-		BT_DBG("device asleep, waking up and queueing packet");
+		bt_dbg("device asleep, waking up and queueing packet");
 		/* save packet for later */
 		skb_queue_tail(&ll->tx_wait_q, skb);
 		/* awake device */
 		if (send_hcill_cmd(HCILL_WAKE_UP_IND, hu) < 0) {
-			BT_ERR("cannot wake up device");
+			bt_err("cannot wake up device");
 			break;
 		}
 		ll->hcill_state = HCILL_ASLEEP_TO_AWAKE;
 		break;
 	case HCILL_ASLEEP_TO_AWAKE:
-		BT_DBG("device waking up, queueing packet");
+		bt_dbg("device waking up, queueing packet");
 		/* transient state; just keep packet for later */
 		skb_queue_tail(&ll->tx_wait_q, skb);
 		break;
 	default:
-		BT_ERR("illegal hcill state: %ld (losing packet)", ll->hcill_state);
+		bt_err("illegal hcill state: %ld (losing packet)", ll->hcill_state);
 		kfree_skb(skb);
 		break;
 	}
@@ -350,12 +350,12 @@ static inline int ll_check_data_len(struct ll_struct *ll, int len)
 {
 	register int room = skb_tailroom(ll->rx_skb);
 
-	BT_DBG("len %d room %d", len, room);
+	bt_dbg("len %d room %d", len, room);
 
 	if (!len) {
 		hci_recv_frame(ll->rx_skb);
 	} else if (len > room) {
-		BT_ERR("Data length is too large");
+		bt_err("Data length is too large");
 		kfree_skb(ll->rx_skb);
 	} else {
 		ll->rx_state = HCILL_W4_DATA;
@@ -380,7 +380,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 	struct hci_sco_hdr   *sh;
 	register int len, type, dlen;
 
-	BT_DBG("hu %p count %d rx_state %ld rx_count %ld", hu, count, ll->rx_state, ll->rx_count);
+	bt_dbg("hu %p count %d rx_state %ld rx_count %ld", hu, count, ll->rx_state, ll->rx_count);
 
 	ptr = data;
 	while (count) {
@@ -394,7 +394,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 
 			switch (ll->rx_state) {
 			case HCILL_W4_DATA:
-				BT_DBG("Complete data");
+				bt_dbg("Complete data");
 				hci_recv_frame(ll->rx_skb);
 
 				ll->rx_state = HCILL_W4_PACKET_TYPE;
@@ -404,7 +404,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 			case HCILL_W4_EVENT_HDR:
 				eh = hci_event_hdr(ll->rx_skb);
 
-				BT_DBG("Event header: evt 0x%2.2x plen %d", eh->evt, eh->plen);
+				bt_dbg("Event header: evt 0x%2.2x plen %d", eh->evt, eh->plen);
 
 				ll_check_data_len(ll, eh->plen);
 				continue;
@@ -413,7 +413,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 				ah = hci_acl_hdr(ll->rx_skb);
 				dlen = __le16_to_cpu(ah->dlen);
 
-				BT_DBG("ACL header: dlen %d", dlen);
+				bt_dbg("ACL header: dlen %d", dlen);
 
 				ll_check_data_len(ll, dlen);
 				continue;
@@ -421,7 +421,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 			case HCILL_W4_SCO_HDR:
 				sh = hci_sco_hdr(ll->rx_skb);
 
-				BT_DBG("SCO header: dlen %d", sh->dlen);
+				bt_dbg("SCO header: dlen %d", sh->dlen);
 
 				ll_check_data_len(ll, sh->dlen);
 				continue;
@@ -431,21 +431,21 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 		/* HCILL_W4_PACKET_TYPE */
 		switch (*ptr) {
 		case HCI_EVENT_PKT:
-			BT_DBG("Event packet");
+			bt_dbg("Event packet");
 			ll->rx_state = HCILL_W4_EVENT_HDR;
 			ll->rx_count = HCI_EVENT_HDR_SIZE;
 			type = HCI_EVENT_PKT;
 			break;
 
 		case HCI_ACLDATA_PKT:
-			BT_DBG("ACL packet");
+			bt_dbg("ACL packet");
 			ll->rx_state = HCILL_W4_ACL_HDR;
 			ll->rx_count = HCI_ACL_HDR_SIZE;
 			type = HCI_ACLDATA_PKT;
 			break;
 
 		case HCI_SCODATA_PKT:
-			BT_DBG("SCO packet");
+			bt_dbg("SCO packet");
 			ll->rx_state = HCILL_W4_SCO_HDR;
 			ll->rx_count = HCI_SCO_HDR_SIZE;
 			type = HCI_SCODATA_PKT;
@@ -453,31 +453,31 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 
 		/* HCILL signals */
 		case HCILL_GO_TO_SLEEP_IND:
-			BT_DBG("HCILL_GO_TO_SLEEP_IND packet");
+			bt_dbg("HCILL_GO_TO_SLEEP_IND packet");
 			ll_device_want_to_sleep(hu);
 			ptr++; count--;
 			continue;
 
 		case HCILL_GO_TO_SLEEP_ACK:
 			/* shouldn't happen */
-			BT_ERR("received HCILL_GO_TO_SLEEP_ACK (in state %ld)", ll->hcill_state);
+			bt_err("received HCILL_GO_TO_SLEEP_ACK (in state %ld)", ll->hcill_state);
 			ptr++; count--;
 			continue;
 
 		case HCILL_WAKE_UP_IND:
-			BT_DBG("HCILL_WAKE_UP_IND packet");
+			bt_dbg("HCILL_WAKE_UP_IND packet");
 			ll_device_want_to_wakeup(hu);
 			ptr++; count--;
 			continue;
 
 		case HCILL_WAKE_UP_ACK:
-			BT_DBG("HCILL_WAKE_UP_ACK packet");
+			bt_dbg("HCILL_WAKE_UP_ACK packet");
 			ll_device_woke_up(hu);
 			ptr++; count--;
 			continue;
 
 		default:
-			BT_ERR("Unknown HCI packet type %2.2x", (__u8)*ptr);
+			bt_err("Unknown HCI packet type %2.2x", (__u8)*ptr);
 			hu->hdev->stat.err_rx++;
 			ptr++; count--;
 			continue;
@@ -488,7 +488,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 		/* Allocate packet */
 		ll->rx_skb = bt_skb_alloc(HCI_MAX_FRAME_SIZE, GFP_ATOMIC);
 		if (!ll->rx_skb) {
-			BT_ERR("Can't allocate mem for new packet");
+			bt_err("Can't allocate mem for new packet");
 			ll->rx_state = HCILL_W4_PACKET_TYPE;
 			ll->rx_count = 0;
 			return -ENOMEM;
@@ -522,9 +522,9 @@ int __init ll_init(void)
 	int err = hci_uart_register_proto(&llp);
 
 	if (!err)
-		BT_INFO("HCILL protocol initialized");
+		bt_info("HCILL protocol initialized");
 	else
-		BT_ERR("HCILL protocol registration failed");
+		bt_err("HCILL protocol registration failed");
 
 	return err;
 }
diff --git a/drivers/bluetooth/hci_vhci.c b/drivers/bluetooth/hci_vhci.c
index 67c180c..cb43f9e 100644
--- a/drivers/bluetooth/hci_vhci.c
+++ b/drivers/bluetooth/hci_vhci.c
@@ -84,7 +84,7 @@ static int vhci_send_frame(struct sk_buff *skb)
 	struct vhci_data *data;
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown HCI device (hdev=NULL)");
+		bt_err("Frame for unknown HCI device (hdev=NULL)");
 		return -ENODEV;
 	}
 
@@ -248,7 +248,7 @@ static int vhci_open(struct inode *inode, struct file *file)
 	hdev->owner = THIS_MODULE;
 
 	if (hci_register_dev(hdev) < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device");
 		kfree(data);
 		hci_free_dev(hdev);
 		return -EBUSY;
@@ -265,7 +265,7 @@ static int vhci_release(struct inode *inode, struct file *file)
 	struct hci_dev *hdev = data->hdev;
 
 	if (hci_unregister_dev(hdev) < 0) {
-		BT_ERR("Can't unregister HCI device %s", hdev->name);
+		bt_err("Can't unregister HCI device %s", hdev->name);
 	}
 
 	hci_free_dev(hdev);
@@ -293,7 +293,7 @@ static struct miscdevice vhci_miscdev= {
 
 static int __init vhci_init(void)
 {
-	BT_INFO("Virtual HCI driver ver %s", VERSION);
+	bt_info("Virtual HCI driver ver %s", VERSION);
 
 	return misc_register(&vhci_miscdev);
 }
diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 7d77545f..b83d977 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -76,9 +76,12 @@ struct bt_power {
 #define BT_POWER_FORCE_ACTIVE_OFF 0
 #define BT_POWER_FORCE_ACTIVE_ON  1
 
-#define BT_INFO(fmt, arg...) printk(KERN_INFO "Bluetooth: " fmt "\n" , ## arg)
-#define BT_ERR(fmt, arg...)  printk(KERN_ERR "%s: " fmt "\n" , __func__ , ## arg)
-#define BT_DBG(fmt, arg...)  pr_debug("%s: " fmt "\n" , __func__ , ## arg)
+__attribute__((format (printf, 2, 3)))
+int bt_printk(const char *level, const char *fmt, ...);
+
+#define bt_info(fmt, arg...)	bt_printk(KERN_INFO, pr_fmt(fmt), ##arg)
+#define bt_err(fmt, arg...)	bt_printk(KERN_ERR, pr_fmt(fmt), ##arg)
+#define bt_dbg(fmt, arg...)	pr_debug(fmt "\n", ##arg)
 
 /* Connection and socket states */
 enum {
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 8add9b4..4748ad8 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -172,7 +172,7 @@ EXPORT_SYMBOL(bt_sock_unlink);
 
 void bt_accept_enqueue(struct sock *parent, struct sock *sk)
 {
-	BT_DBG("parent %p, sk %p", parent, sk);
+	bt_dbg("parent %p, sk %p", parent, sk);
 
 	sock_hold(sk);
 	list_add_tail(&bt_sk(sk)->accept_q, &bt_sk(parent)->accept_q);
@@ -183,7 +183,7 @@ EXPORT_SYMBOL(bt_accept_enqueue);
 
 void bt_accept_unlink(struct sock *sk)
 {
-	BT_DBG("sk %p state %d", sk, sk->sk_state);
+	bt_dbg("sk %p state %d", sk, sk->sk_state);
 
 	list_del_init(&bt_sk(sk)->accept_q);
 	bt_sk(sk)->parent->sk_ack_backlog--;
@@ -197,7 +197,7 @@ struct sock *bt_accept_dequeue(struct sock *parent, struct socket *newsock)
 	struct list_head *p, *n;
 	struct sock *sk;
 
-	BT_DBG("parent %p", parent);
+	bt_dbg("parent %p", parent);
 
 	local_bh_disable();
 	list_for_each_safe(p, n, &bt_sk(parent)->accept_q) {
@@ -240,7 +240,7 @@ int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	size_t copied;
 	int err;
 
-	BT_DBG("sock %p sk %p len %zu", sock, sk, len);
+	bt_dbg("sock %p sk %p len %zu", sock, sk, len);
 
 	if (flags & (MSG_OOB))
 		return -EOPNOTSUPP;
@@ -313,7 +313,7 @@ int bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	msg->msg_namelen = 0;
 
-	BT_DBG("sk %p size %zu", sk, size);
+	bt_dbg("sk %p size %zu", sk, size);
 
 	lock_sock(sk);
 
@@ -402,7 +402,7 @@ unsigned int bt_sock_poll(struct file *file, struct socket *sock, poll_table *wa
 	struct sock *sk = sock->sk;
 	unsigned int mask = 0;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	poll_wait(file, sk_sleep(sk), wait);
 
@@ -445,7 +445,7 @@ int bt_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	long amount;
 	int err;
 
-	BT_DBG("sk %p cmd %x arg %lx", sk, cmd, arg);
+	bt_dbg("sk %p cmd %x arg %lx", sk, cmd, arg);
 
 	switch (cmd) {
 	case TIOCOUTQ:
@@ -491,7 +491,7 @@ int bt_sock_wait_state(struct sock *sk, int state, unsigned long timeo)
 	DECLARE_WAITQUEUE(wait, current);
 	int err = 0;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	add_wait_queue(sk_sleep(sk), &wait);
 	while (sk->sk_state != state) {
@@ -531,7 +531,7 @@ static int __init bt_init(void)
 {
 	int err;
 
-	BT_INFO("Core ver %s", VERSION);
+	bt_info("Core ver %s", VERSION);
 
 	err = bt_sysfs_init();
 	if (err < 0)
@@ -543,7 +543,7 @@ static int __init bt_init(void)
 		return err;
 	}
 
-	BT_INFO("HCI device and connection manager initialized");
+	bt_info("HCI device and connection manager initialized");
 
 	err = hci_sock_init();
 	if (err < 0)
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index ca39fcf..29399d2 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -67,7 +67,7 @@ static struct bnep_session *__bnep_get_session(u8 *dst)
 	struct bnep_session *s;
 	struct list_head *p;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	list_for_each(p, &bnep_session_list) {
 		s = list_entry(p, struct bnep_session, list);
@@ -138,7 +138,7 @@ static int bnep_ctrl_set_netfilter(struct bnep_session *s, __be16 *data, int len
 	if (len < n)
 		return -EILSEQ;
 
-	BT_DBG("filter len %d", n);
+	bt_dbg("filter len %d", n);
 
 #ifdef CONFIG_BT_BNEP_PROTO_FILTER
 	n /= 4;
@@ -150,7 +150,7 @@ static int bnep_ctrl_set_netfilter(struct bnep_session *s, __be16 *data, int len
 			f[i].start = get_unaligned_be16(data++);
 			f[i].end   = get_unaligned_be16(data++);
 
-			BT_DBG("proto filter start %d end %d",
+			bt_dbg("proto filter start %d end %d",
 				f[i].start, f[i].end);
 		}
 
@@ -184,7 +184,7 @@ static int bnep_ctrl_set_mcfilter(struct bnep_session *s, u8 *data, int len)
 	if (len < n)
 		return -EILSEQ;
 
-	BT_DBG("filter len %d", n);
+	bt_dbg("filter len %d", n);
 
 #ifdef CONFIG_BT_BNEP_MC_FILTER
 	n /= (ETH_ALEN * 2);
@@ -206,7 +206,7 @@ static int bnep_ctrl_set_mcfilter(struct bnep_session *s, u8 *data, int len)
 			a2 = data;
 			data += ETH_ALEN;
 
-			BT_DBG("mc filter %s -> %s",
+			bt_dbg("mc filter %s -> %s",
 				batostr((void *) a1), batostr((void *) a2));
 
 			/* Iterate from a1 to a2 */
@@ -222,7 +222,7 @@ static int bnep_ctrl_set_mcfilter(struct bnep_session *s, u8 *data, int len)
 		}
 	}
 
-	BT_DBG("mc filter hash 0x%llx", s->mc_filter);
+	bt_dbg("mc filter hash 0x%llx", s->mc_filter);
 
 	bnep_send_rsp(s, BNEP_FILTER_MULTI_ADDR_RSP, BNEP_SUCCESS);
 #else
@@ -284,7 +284,7 @@ static int bnep_rx_extension(struct bnep_session *s, struct sk_buff *skb)
 			break;
 		}
 
-		BT_DBG("type 0x%x len %d", h->type, h->len);
+		bt_dbg("type 0x%x len %d", h->type, h->len);
 
 		switch (h->type & BNEP_TYPE_MASK) {
 		case BNEP_EXT_CONTROL:
@@ -419,7 +419,7 @@ static inline int bnep_tx_frame(struct bnep_session *s, struct sk_buff *skb)
 	int len = 0, il = 0;
 	u8 type = 0;
 
-	BT_DBG("skb %p dev %p type %d", skb, skb->dev, skb->pkt_type);
+	bt_dbg("skb %p dev %p type %d", skb, skb->dev, skb->pkt_type);
 
 	if (!skb->dev) {
 		/* Control frame sent by us */
@@ -478,7 +478,7 @@ static int bnep_session(void *arg)
 	struct sk_buff *skb;
 	wait_queue_t wait;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	set_user_nice(current, -15);
 
@@ -557,7 +557,7 @@ int bnep_add_connection(struct bnep_connadd_req *req, struct socket *sock)
 	u8 dst[ETH_ALEN], src[ETH_ALEN];
 	int err;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	baswap((void *) dst, &bt_sk(sock->sk)->dst);
 	baswap((void *) src, &bt_sk(sock->sk)->src);
@@ -635,7 +635,7 @@ int bnep_del_connection(struct bnep_conndel_req *req)
 	struct bnep_session *s;
 	int  err = 0;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	down_read(&bnep_session_sem);
 
@@ -719,9 +719,9 @@ static int __init bnep_init(void)
 	strcat(flt, "multicast");
 #endif
 
-	BT_INFO("BNEP (Ethernet Emulation) ver %s", VERSION);
+	bt_info("BNEP (Ethernet Emulation) ver %s", VERSION);
 	if (flt[0])
-		BT_INFO("BNEP filters: %s", flt);
+		bt_info("BNEP filters: %s", flt);
 
 	bnep_sock_init();
 	return 0;
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index 8c100c9..b43ab23 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -65,12 +65,12 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 	struct sk_buff *skb;
 	int size;
 
-	BT_DBG("%s mc_count %d", dev->name, netdev_mc_count(dev));
+	bt_dbg("%s mc_count %d", dev->name, netdev_mc_count(dev));
 
 	size = sizeof(*r) + (BNEP_MAX_MULTICAST_FILTERS + 1) * ETH_ALEN * 2;
 	skb  = alloc_skb(size, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("%s Multicast list allocation failed", dev->name);
+		bt_err("%s Multicast list allocation failed", dev->name);
 		return;
 	}
 
@@ -117,13 +117,13 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 
 static int bnep_net_set_mac_addr(struct net_device *dev, void *arg)
 {
-	BT_DBG("%s", dev->name);
+	bt_dbg("%s", dev->name);
 	return 0;
 }
 
 static void bnep_net_timeout(struct net_device *dev)
 {
-	BT_DBG("net_timeout");
+	bt_dbg("net_timeout");
 	netif_wake_queue(dev);
 }
 
@@ -165,7 +165,7 @@ static inline int bnep_net_proto_filter(struct sk_buff *skb, struct bnep_session
 			return 0;
 	}
 
-	BT_DBG("BNEP: filtered skb %p, proto 0x%.4x", skb, proto);
+	bt_dbg("BNEP: filtered skb %p, proto 0x%.4x", skb, proto);
 	return 1;
 }
 #endif
@@ -176,7 +176,7 @@ static netdev_tx_t bnep_net_xmit(struct sk_buff *skb,
 	struct bnep_session *s = netdev_priv(dev);
 	struct sock *sk = s->sock->sk;
 
-	BT_DBG("skb %p, dev %p", skb, dev);
+	bt_dbg("skb %p, dev %p", skb, dev);
 
 #ifdef CONFIG_BT_BNEP_MC_FILTER
 	if (bnep_net_mc_filter(skb, s)) {
@@ -202,7 +202,7 @@ static netdev_tx_t bnep_net_xmit(struct sk_buff *skb,
 	wake_up_interruptible(sk_sleep(sk));
 
 	if (skb_queue_len(&sk->sk_write_queue) >= BNEP_TX_QUEUE_LEN) {
-		BT_DBG("tx queue is full");
+		bt_dbg("tx queue is full");
 
 		/* Stop queuing.
 		 * Session thread will do netif_wake_queue() */
diff --git a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
index 17800b1..e5bbaa6 100644
--- a/net/bluetooth/bnep/sock.c
+++ b/net/bluetooth/bnep/sock.c
@@ -50,7 +50,7 @@ static int bnep_sock_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	bt_dbg("sock %p sk %p", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -70,7 +70,7 @@ static int bnep_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long
 	void __user *argp = (void __user *)arg;
 	int err;
 
-	BT_DBG("cmd %x arg %lx", cmd, arg);
+	bt_dbg("cmd %x arg %lx", cmd, arg);
 
 	switch (cmd) {
 	case BNEPCONNADD:
@@ -201,7 +201,7 @@ static int bnep_sock_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	bt_dbg("sock %p", sock);
 
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
@@ -245,7 +245,7 @@ int __init bnep_sock_init(void)
 	return 0;
 
 error:
-	BT_ERR("Can't register BNEP socket");
+	bt_err("Can't register BNEP socket");
 	proto_unregister(&bnep_proto);
 	return err;
 }
@@ -253,7 +253,7 @@ error:
 void __exit bnep_sock_cleanup(void)
 {
 	if (bt_sock_unregister(BTPROTO_BNEP) < 0)
-		BT_ERR("Can't unregister BNEP socket");
+		bt_err("Can't unregister BNEP socket");
 
 	proto_unregister(&bnep_proto);
 }
diff --git a/net/bluetooth/cmtp/capi.c b/net/bluetooth/cmtp/capi.c
index 040f67b..2deed02 100644
--- a/net/bluetooth/cmtp/capi.c
+++ b/net/bluetooth/cmtp/capi.c
@@ -74,7 +74,7 @@ static struct cmtp_application *cmtp_application_add(struct cmtp_session *sessio
 {
 	struct cmtp_application *app = kzalloc(sizeof(*app), GFP_KERNEL);
 
-	BT_DBG("session %p application %p appl %d", session, app, appl);
+	bt_dbg("session %p application %p appl %d", session, app, appl);
 
 	if (!app)
 		return NULL;
@@ -89,7 +89,7 @@ static struct cmtp_application *cmtp_application_add(struct cmtp_session *sessio
 
 static void cmtp_application_del(struct cmtp_session *session, struct cmtp_application *app)
 {
-	BT_DBG("session %p application %p", session, app);
+	bt_dbg("session %p application %p", session, app);
 
 	if (app) {
 		list_del(&app->list);
@@ -137,7 +137,7 @@ static void cmtp_send_capimsg(struct cmtp_session *session, struct sk_buff *skb)
 {
 	struct cmtp_scb *scb = (void *) skb->cb;
 
-	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
+	bt_dbg("session %p skb %p len %d", session, skb, skb->len);
 
 	scb->id = -1;
 	scb->data = (CAPIMSG_COMMAND(skb->data) == CAPI_DATA_B3);
@@ -154,11 +154,11 @@ static void cmtp_send_interopmsg(struct cmtp_session *session,
 	struct sk_buff *skb;
 	unsigned char *s;
 
-	BT_DBG("session %p subcmd 0x%02x appl %d msgnum %d", session, subcmd, appl, msgnum);
+	bt_dbg("session %p subcmd 0x%02x appl %d msgnum %d", session, subcmd, appl, msgnum);
 
 	skb = alloc_skb(CAPI_MSG_BASELEN + 6 + len, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("Can't allocate memory for interoperability packet");
+		bt_err("Can't allocate memory for interoperability packet");
 		return;
 	}
 
@@ -190,7 +190,7 @@ static void cmtp_recv_interopmsg(struct cmtp_session *session, struct sk_buff *s
 	__u16 appl, msgnum, func, info;
 	__u32 controller;
 
-	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
+	bt_dbg("session %p skb %p len %d", session, skb, skb->len);
 
 	switch (CAPIMSG_SUBCOMMAND(skb->data)) {
 	case CAPI_CONF:
@@ -329,7 +329,7 @@ void cmtp_recv_capimsg(struct cmtp_session *session, struct sk_buff *skb)
 	__u16 appl;
 	__u32 contr;
 
-	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
+	bt_dbg("session %p skb %p len %d", session, skb, skb->len);
 
 	if (skb->len < CAPI_MSG_BASELEN)
 		return;
@@ -352,7 +352,7 @@ void cmtp_recv_capimsg(struct cmtp_session *session, struct sk_buff *skb)
 		appl = application->appl;
 		CAPIMSG_SETAPPID(skb->data, appl);
 	} else {
-		BT_ERR("Can't find application with id %d", appl);
+		bt_err("Can't find application with id %d", appl);
 		kfree_skb(skb);
 		return;
 	}
@@ -363,7 +363,7 @@ void cmtp_recv_capimsg(struct cmtp_session *session, struct sk_buff *skb)
 	}
 
 	if (!ctrl) {
-		BT_ERR("Can't find controller %d for message", session->num);
+		bt_err("Can't find controller %d for message", session->num);
 		kfree_skb(skb);
 		return;
 	}
@@ -373,7 +373,7 @@ void cmtp_recv_capimsg(struct cmtp_session *session, struct sk_buff *skb)
 
 static int cmtp_load_firmware(struct capi_ctr *ctrl, capiloaddata *data)
 {
-	BT_DBG("ctrl %p data %p", ctrl, data);
+	bt_dbg("ctrl %p data %p", ctrl, data);
 
 	return 0;
 }
@@ -382,7 +382,7 @@ static void cmtp_reset_ctr(struct capi_ctr *ctrl)
 {
 	struct cmtp_session *session = ctrl->driverdata;
 
-	BT_DBG("ctrl %p", ctrl);
+	bt_dbg("ctrl %p", ctrl);
 
 	capi_ctr_down(ctrl);
 
@@ -398,12 +398,12 @@ static void cmtp_register_appl(struct capi_ctr *ctrl, __u16 appl, capi_register_
 	unsigned char buf[8];
 	int err = 0, nconn, want = rp->level3cnt;
 
-	BT_DBG("ctrl %p appl %d level3cnt %d datablkcnt %d datablklen %d",
+	bt_dbg("ctrl %p appl %d level3cnt %d datablkcnt %d datablklen %d",
 		ctrl, appl, rp->level3cnt, rp->datablkcnt, rp->datablklen);
 
 	application = cmtp_application_add(session, appl);
 	if (!application) {
-		BT_ERR("Can't allocate memory for new application");
+		bt_err("Can't allocate memory for new application");
 		return;
 	}
 
@@ -463,11 +463,11 @@ static void cmtp_release_appl(struct capi_ctr *ctrl, __u16 appl)
 	struct cmtp_session *session = ctrl->driverdata;
 	struct cmtp_application *application;
 
-	BT_DBG("ctrl %p appl %d", ctrl, appl);
+	bt_dbg("ctrl %p appl %d", ctrl, appl);
 
 	application = cmtp_application_get(session, CMTP_APPLID, appl);
 	if (!application) {
-		BT_ERR("Can't find application");
+		bt_err("Can't find application");
 		return;
 	}
 
@@ -489,14 +489,14 @@ static u16 cmtp_send_message(struct capi_ctr *ctrl, struct sk_buff *skb)
 	__u16 appl;
 	__u32 contr;
 
-	BT_DBG("ctrl %p skb %p", ctrl, skb);
+	bt_dbg("ctrl %p skb %p", ctrl, skb);
 
 	appl = CAPIMSG_APPID(skb->data);
 	contr = CAPIMSG_CONTROL(skb->data);
 
 	application = cmtp_application_get(session, CMTP_APPLID, appl);
 	if ((!application) || (application->state != BT_CONNECTED)) {
-		BT_ERR("Can't find application with id %d", appl);
+		bt_err("Can't find application with id %d", appl);
 		return CAPI_ILLAPPNR;
 	}
 
@@ -554,7 +554,7 @@ int cmtp_attach_device(struct cmtp_session *session)
 	unsigned char buf[4];
 	long ret;
 
-	BT_DBG("session %p", session);
+	bt_dbg("session %p", session);
 
 	capimsg_setu32(buf, 0, 0);
 
@@ -564,7 +564,7 @@ int cmtp_attach_device(struct cmtp_session *session)
 	ret = wait_event_interruptible_timeout(session->wait,
 			session->ncontroller, CMTP_INTEROP_TIMEOUT);
 
-	BT_INFO("Found %d CAPI controller(s) on device %s", session->ncontroller, session->name);
+	bt_info("Found %d CAPI controller(s) on device %s", session->ncontroller, session->name);
 
 	if (!ret)
 		return -ETIMEDOUT;
@@ -573,7 +573,7 @@ int cmtp_attach_device(struct cmtp_session *session)
 		return -ENODEV;
 
 	if (session->ncontroller > 1)
-		BT_INFO("Setting up only CAPI controller 1");
+		bt_info("Setting up only CAPI controller 1");
 
 	session->ctrl.owner      = THIS_MODULE;
 	session->ctrl.driverdata = session;
@@ -590,13 +590,13 @@ int cmtp_attach_device(struct cmtp_session *session)
 	session->ctrl.proc_fops = &cmtp_proc_fops;
 
 	if (attach_capi_ctr(&session->ctrl) < 0) {
-		BT_ERR("Can't attach new controller");
+		bt_err("Can't attach new controller");
 		return -EBUSY;
 	}
 
 	session->num = session->ctrl.cnr;
 
-	BT_DBG("session %p num %d", session, session->num);
+	bt_dbg("session %p num %d", session, session->num);
 
 	capimsg_setu32(buf, 0, 1);
 
@@ -617,7 +617,7 @@ int cmtp_attach_device(struct cmtp_session *session)
 
 void cmtp_detach_device(struct cmtp_session *session)
 {
-	BT_DBG("session %p", session);
+	bt_dbg("session %p", session);
 
 	detach_capi_ctr(&session->ctrl);
 }
diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
index c5b11af..12062af 100644
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -55,7 +55,7 @@ static struct cmtp_session *__cmtp_get_session(bdaddr_t *bdaddr)
 	struct cmtp_session *session;
 	struct list_head *p;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	list_for_each(p, &cmtp_session_list) {
 		session = list_entry(p, struct cmtp_session, list);
@@ -112,13 +112,13 @@ static inline void cmtp_add_msgpart(struct cmtp_session *session, int id, const
 	struct sk_buff *skb = session->reassembly[id], *nskb;
 	int size;
 
-	BT_DBG("session %p buf %p count %d", session, buf, count);
+	bt_dbg("session %p buf %p count %d", session, buf, count);
 
 	size = (skb) ? skb->len + count : count;
 
 	nskb = alloc_skb(size, GFP_ATOMIC);
 	if (!nskb) {
-		BT_ERR("Can't allocate memory for CAPI message");
+		bt_err("Can't allocate memory for CAPI message");
 		return;
 	}
 
@@ -137,7 +137,7 @@ static inline int cmtp_recv_frame(struct cmtp_session *session, struct sk_buff *
 	__u8 hdr, hdrlen, id;
 	__u16 len;
 
-	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
+	bt_dbg("session %p skb %p len %d", session, skb, skb->len);
 
 	while (skb->len > 0) {
 		hdr = skb->data[0];
@@ -159,10 +159,10 @@ static inline int cmtp_recv_frame(struct cmtp_session *session, struct sk_buff *
 
 		id = (hdr & 0x3c) >> 2;
 
-		BT_DBG("hdr 0x%02x hdrlen %d len %d id %d", hdr, hdrlen, len, id);
+		bt_dbg("hdr 0x%02x hdrlen %d len %d id %d", hdr, hdrlen, len, id);
 
 		if (hdrlen + len > skb->len) {
-			BT_ERR("Wrong size or header information in CMTP frame");
+			bt_err("Wrong size or header information in CMTP frame");
 			break;
 		}
 
@@ -200,7 +200,7 @@ static int cmtp_send_frame(struct cmtp_session *session, unsigned char *data, in
 	struct kvec iv = { data, len };
 	struct msghdr msg;
 
-	BT_DBG("session %p data %p len %d", session, data, len);
+	bt_dbg("session %p data %p len %d", session, data, len);
 
 	if (!len)
 		return 0;
@@ -216,11 +216,11 @@ static void cmtp_process_transmit(struct cmtp_session *session)
 	unsigned char *hdr;
 	unsigned int size, tail;
 
-	BT_DBG("session %p", session);
+	bt_dbg("session %p", session);
 
 	nskb = alloc_skb(session->mtu, GFP_ATOMIC);
 	if (!nskb) {
-		BT_ERR("Can't allocate memory for new frame");
+		bt_err("Can't allocate memory for new frame");
 		return;
 	}
 
@@ -286,7 +286,7 @@ static int cmtp_session(void *arg)
 	struct sk_buff *skb;
 	wait_queue_t wait;
 
-	BT_DBG("session %p", session);
+	bt_dbg("session %p", session);
 
 	set_user_nice(current, -15);
 
@@ -330,7 +330,7 @@ int cmtp_add_connection(struct cmtp_connadd_req *req, struct socket *sock)
 	struct cmtp_session *session, *s;
 	int i, err;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	session = kzalloc(sizeof(struct cmtp_session), GFP_KERNEL);
 	if (!session)
@@ -349,7 +349,7 @@ int cmtp_add_connection(struct cmtp_connadd_req *req, struct socket *sock)
 	session->mtu = min_t(uint, l2cap_pi(sock->sk)->chan->omtu,
 					l2cap_pi(sock->sk)->chan->imtu);
 
-	BT_DBG("mtu %d", session->mtu);
+	bt_dbg("mtu %d", session->mtu);
 
 	sprintf(session->name, "%s", batostr(&bt_sk(sock->sk)->dst));
 
@@ -404,7 +404,7 @@ int cmtp_del_connection(struct cmtp_conndel_req *req)
 	struct cmtp_session *session;
 	int err = 0;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	down_read(&cmtp_session_sem);
 
@@ -427,7 +427,7 @@ int cmtp_get_connlist(struct cmtp_connlist_req *req)
 	struct list_head *p;
 	int err = 0, n = 0;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	down_read(&cmtp_session_sem);
 
@@ -475,7 +475,7 @@ int cmtp_get_conninfo(struct cmtp_conninfo *ci)
 
 static int __init cmtp_init(void)
 {
-	BT_INFO("CMTP (CAPI Emulation) ver %s", VERSION);
+	bt_info("CMTP (CAPI Emulation) ver %s", VERSION);
 
 	cmtp_init_sockets();
 
diff --git a/net/bluetooth/cmtp/sock.c b/net/bluetooth/cmtp/sock.c
index 3f2dd5c..e5b9356 100644
--- a/net/bluetooth/cmtp/sock.c
+++ b/net/bluetooth/cmtp/sock.c
@@ -47,7 +47,7 @@ static int cmtp_sock_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	bt_dbg("sock %p sk %p", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -68,7 +68,7 @@ static int cmtp_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long
 	void __user *argp = (void __user *)arg;
 	int err;
 
-	BT_DBG("cmd %x arg %lx", cmd, arg);
+	bt_dbg("cmd %x arg %lx", cmd, arg);
 
 	switch (cmd) {
 	case CMTPCONNADD:
@@ -195,7 +195,7 @@ static int cmtp_sock_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	bt_dbg("sock %p", sock);
 
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
@@ -239,7 +239,7 @@ int cmtp_init_sockets(void)
 	return 0;
 
 error:
-	BT_ERR("Can't register CMTP socket");
+	bt_err("Can't register CMTP socket");
 	proto_unregister(&cmtp_proto);
 	return err;
 }
@@ -247,7 +247,7 @@ error:
 void cmtp_cleanup_sockets(void)
 {
 	if (bt_sock_unregister(BTPROTO_CMTP) < 0)
-		BT_ERR("Can't unregister CMTP socket");
+		bt_err("Can't unregister CMTP socket");
 
 	proto_unregister(&cmtp_proto);
 }
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index fa48c0b..942d647 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -80,7 +80,7 @@ void hci_acl_connect(struct hci_conn *conn)
 	struct inquiry_entry *ie;
 	struct hci_cp_create_conn cp;
 
-	BT_DBG("%p", conn);
+	bt_dbg("%p", conn);
 
 	conn->state = BT_CONNECT;
 	conn->out = 1;
@@ -121,7 +121,7 @@ static void hci_acl_connect_cancel(struct hci_conn *conn)
 {
 	struct hci_cp_create_conn_cancel cp;
 
-	BT_DBG("%p", conn);
+	bt_dbg("%p", conn);
 
 	if (conn->hdev->hci_ver < 2)
 		return;
@@ -134,7 +134,7 @@ void hci_acl_disconn(struct hci_conn *conn, __u8 reason)
 {
 	struct hci_cp_disconnect cp;
 
-	BT_DBG("%p", conn);
+	bt_dbg("%p", conn);
 
 	conn->state = BT_DISCONN;
 
@@ -148,7 +148,7 @@ void hci_add_sco(struct hci_conn *conn, __u16 handle)
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_cp_add_sco cp;
 
-	BT_DBG("%p", conn);
+	bt_dbg("%p", conn);
 
 	conn->state = BT_CONNECT;
 	conn->out = 1;
@@ -166,7 +166,7 @@ void hci_setup_sync(struct hci_conn *conn, __u16 handle)
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_cp_setup_sync_conn cp;
 
-	BT_DBG("%p", conn);
+	bt_dbg("%p", conn);
 
 	conn->state = BT_CONNECT;
 	conn->out = 1;
@@ -211,7 +211,7 @@ void hci_le_start_enc(struct hci_conn *conn, __le16 ediv, __u8 rand[8],
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_cp_le_start_enc cp;
 
-	BT_DBG("%p", conn);
+	bt_dbg("%p", conn);
 
 	memset(&cp, 0, sizeof(cp));
 
@@ -229,7 +229,7 @@ void hci_le_ltk_reply(struct hci_conn *conn, u8 ltk[16])
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_cp_le_ltk_reply cp;
 
-	BT_DBG("%p", conn);
+	bt_dbg("%p", conn);
 
 	memset(&cp, 0, sizeof(cp));
 
@@ -245,7 +245,7 @@ void hci_le_ltk_neg_reply(struct hci_conn *conn)
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_cp_le_ltk_neg_reply cp;
 
-	BT_DBG("%p", conn);
+	bt_dbg("%p", conn);
 
 	memset(&cp, 0, sizeof(cp));
 
@@ -259,7 +259,7 @@ void hci_sco_setup(struct hci_conn *conn, __u8 status)
 {
 	struct hci_conn *sco = conn->link;
 
-	BT_DBG("%p", conn);
+	bt_dbg("%p", conn);
 
 	if (!sco)
 		return;
@@ -281,7 +281,7 @@ static void hci_conn_timeout(unsigned long arg)
 	struct hci_dev *hdev = conn->hdev;
 	__u8 reason;
 
-	BT_DBG("conn %p state %d", conn, conn->state);
+	bt_dbg("conn %p state %d", conn, conn->state);
 
 	if (atomic_read(&conn->refcnt))
 		return;
@@ -315,7 +315,7 @@ static void hci_conn_idle(unsigned long arg)
 {
 	struct hci_conn *conn = (void *) arg;
 
-	BT_DBG("conn %p mode %d", conn, conn->mode);
+	bt_dbg("conn %p mode %d", conn, conn->mode);
 
 	hci_conn_enter_sniff_mode(conn);
 }
@@ -337,7 +337,7 @@ struct hci_conn *hci_conn_add(struct hci_dev *hdev, int type, bdaddr_t *dst)
 {
 	struct hci_conn *conn;
 
-	BT_DBG("%s dst %s", hdev->name, batostr(dst));
+	bt_dbg("%s dst %s", hdev->name, batostr(dst));
 
 	conn = kzalloc(sizeof(struct hci_conn), GFP_ATOMIC);
 	if (!conn)
@@ -402,7 +402,7 @@ int hci_conn_del(struct hci_conn *conn)
 {
 	struct hci_dev *hdev = conn->hdev;
 
-	BT_DBG("%s conn %p handle %d", hdev->name, conn, conn->handle);
+	bt_dbg("%s conn %p handle %d", hdev->name, conn, conn->handle);
 
 	del_timer(&conn->idle_timer);
 
@@ -453,7 +453,7 @@ struct hci_dev *hci_get_route(bdaddr_t *dst, bdaddr_t *src)
 	struct hci_dev *hdev = NULL;
 	struct list_head *p;
 
-	BT_DBG("%s -> %s", batostr(src), batostr(dst));
+	bt_dbg("%s -> %s", batostr(src), batostr(dst));
 
 	read_lock_bh(&hci_dev_list_lock);
 
@@ -495,7 +495,7 @@ struct hci_conn *hci_connect(struct hci_dev *hdev, int type, bdaddr_t *dst, __u8
 	struct hci_conn *sco;
 	struct hci_conn *le;
 
-	BT_DBG("%s dst %s", hdev->name, batostr(dst));
+	bt_dbg("%s dst %s", hdev->name, batostr(dst));
 
 	if (type == LE_LINK) {
 		struct adv_entry *entry;
@@ -575,7 +575,7 @@ EXPORT_SYMBOL(hci_connect);
 /* Check link security requirement */
 int hci_conn_check_link_mode(struct hci_conn *conn)
 {
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	if (conn->ssp_mode > 0 && conn->hdev->ssp_mode > 0 &&
 					!(conn->link_mode & HCI_LM_ENCRYPT))
@@ -588,7 +588,7 @@ EXPORT_SYMBOL(hci_conn_check_link_mode);
 /* Authenticate remote device */
 static int hci_conn_auth(struct hci_conn *conn, __u8 sec_level, __u8 auth_type)
 {
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	if (conn->pending_sec_level > sec_level)
 		sec_level = conn->pending_sec_level;
@@ -618,7 +618,7 @@ static int hci_conn_auth(struct hci_conn *conn, __u8 sec_level, __u8 auth_type)
 /* Encrypt the the link */
 static void hci_conn_encrypt(struct hci_conn *conn)
 {
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	if (!test_and_set_bit(HCI_CONN_ENCRYPT_PEND, &conn->pend)) {
 		struct hci_cp_set_conn_encrypt cp;
@@ -632,7 +632,7 @@ static void hci_conn_encrypt(struct hci_conn *conn)
 /* Enable security */
 int hci_conn_security(struct hci_conn *conn, __u8 sec_level, __u8 auth_type)
 {
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	/* For sdp we don't need the link key. */
 	if (sec_level == BT_SECURITY_SDP)
@@ -688,7 +688,7 @@ EXPORT_SYMBOL(hci_conn_security);
 /* Check secure link requirement */
 int hci_conn_check_secure(struct hci_conn *conn, __u8 sec_level)
 {
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	if (sec_level != BT_SECURITY_HIGH)
 		return 1; /* Accept if non-secure is required */
@@ -703,7 +703,7 @@ EXPORT_SYMBOL(hci_conn_check_secure);
 /* Change link key */
 int hci_conn_change_link_key(struct hci_conn *conn)
 {
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	if (!test_and_set_bit(HCI_CONN_AUTH_PEND, &conn->pend)) {
 		struct hci_cp_change_conn_link_key cp;
@@ -719,7 +719,7 @@ EXPORT_SYMBOL(hci_conn_change_link_key);
 /* Switch role */
 int hci_conn_switch_role(struct hci_conn *conn, __u8 role)
 {
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	if (!role && conn->link_mode & HCI_LM_MASTER)
 		return 1;
@@ -740,7 +740,7 @@ void hci_conn_enter_active_mode(struct hci_conn *conn, __u8 force_active)
 {
 	struct hci_dev *hdev = conn->hdev;
 
-	BT_DBG("conn %p mode %d", conn, conn->mode);
+	bt_dbg("conn %p mode %d", conn, conn->mode);
 
 	if (test_bit(HCI_RAW, &hdev->flags))
 		return;
@@ -768,7 +768,7 @@ void hci_conn_enter_sniff_mode(struct hci_conn *conn)
 {
 	struct hci_dev *hdev = conn->hdev;
 
-	BT_DBG("conn %p mode %d", conn, conn->mode);
+	bt_dbg("conn %p mode %d", conn, conn->mode);
 
 	if (test_bit(HCI_RAW, &hdev->flags))
 		return;
@@ -805,7 +805,7 @@ void hci_conn_hash_flush(struct hci_dev *hdev)
 	struct hci_conn_hash *h = &hdev->conn_hash;
 	struct list_head *p;
 
-	BT_DBG("hdev %s", hdev->name);
+	bt_dbg("hdev %s", hdev->name);
 
 	p = h->list.next;
 	while (p != &h->list) {
@@ -826,7 +826,7 @@ void hci_conn_check_pending(struct hci_dev *hdev)
 {
 	struct hci_conn *conn;
 
-	BT_DBG("hdev %s", hdev->name);
+	bt_dbg("hdev %s", hdev->name);
 
 	hci_dev_lock(hdev);
 
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index ec34c5a..41254be 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -98,7 +98,7 @@ static void hci_notify(struct hci_dev *hdev, int event)
 
 void hci_req_complete(struct hci_dev *hdev, __u16 cmd, int result)
 {
-	BT_DBG("%s command 0x%04x result 0x%2.2x", hdev->name, cmd, result);
+	bt_dbg("%s command 0x%04x result 0x%2.2x", hdev->name, cmd, result);
 
 	/* If this is the init phase check if the completed command matches
 	 * the last init command, and if not just return.
@@ -115,7 +115,7 @@ void hci_req_complete(struct hci_dev *hdev, __u16 cmd, int result)
 
 static void hci_req_cancel(struct hci_dev *hdev, int err)
 {
-	BT_DBG("%s err 0x%2.2x", hdev->name, err);
+	bt_dbg("%s err 0x%2.2x", hdev->name, err);
 
 	if (hdev->req_status == HCI_REQ_PEND) {
 		hdev->req_result = err;
@@ -131,7 +131,7 @@ static int __hci_request(struct hci_dev *hdev, void (*req)(struct hci_dev *hdev,
 	DECLARE_WAITQUEUE(wait, current);
 	int err = 0;
 
-	BT_DBG("%s start", hdev->name);
+	bt_dbg("%s start", hdev->name);
 
 	hdev->req_status = HCI_REQ_PEND;
 
@@ -162,7 +162,7 @@ static int __hci_request(struct hci_dev *hdev, void (*req)(struct hci_dev *hdev,
 
 	hdev->req_status = hdev->req_result = 0;
 
-	BT_DBG("%s end: err %d", hdev->name, err);
+	bt_dbg("%s end: err %d", hdev->name, err);
 
 	return err;
 }
@@ -185,7 +185,7 @@ static inline int hci_request(struct hci_dev *hdev, void (*req)(struct hci_dev *
 
 static void hci_reset_req(struct hci_dev *hdev, unsigned long opt)
 {
-	BT_DBG("%s %ld", hdev->name, opt);
+	bt_dbg("%s %ld", hdev->name, opt);
 
 	/* Reset device */
 	set_bit(HCI_RESET, &hdev->flags);
@@ -199,7 +199,7 @@ static void hci_init_req(struct hci_dev *hdev, unsigned long opt)
 	__le16 param;
 	__u8 flt_type;
 
-	BT_DBG("%s %ld", hdev->name, opt);
+	bt_dbg("%s %ld", hdev->name, opt);
 
 	/* Driver initialization */
 
@@ -271,7 +271,7 @@ static void hci_init_req(struct hci_dev *hdev, unsigned long opt)
 
 static void hci_le_init_req(struct hci_dev *hdev, unsigned long opt)
 {
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	/* Read LE buffer size */
 	hci_send_cmd(hdev, HCI_OP_LE_READ_BUFFER_SIZE, 0, NULL);
@@ -281,7 +281,7 @@ static void hci_scan_req(struct hci_dev *hdev, unsigned long opt)
 {
 	__u8 scan = opt;
 
-	BT_DBG("%s %x", hdev->name, scan);
+	bt_dbg("%s %x", hdev->name, scan);
 
 	/* Inquiry and Page scans */
 	hci_send_cmd(hdev, HCI_OP_WRITE_SCAN_ENABLE, 1, &scan);
@@ -291,7 +291,7 @@ static void hci_auth_req(struct hci_dev *hdev, unsigned long opt)
 {
 	__u8 auth = opt;
 
-	BT_DBG("%s %x", hdev->name, auth);
+	bt_dbg("%s %x", hdev->name, auth);
 
 	/* Authentication */
 	hci_send_cmd(hdev, HCI_OP_WRITE_AUTH_ENABLE, 1, &auth);
@@ -301,7 +301,7 @@ static void hci_encrypt_req(struct hci_dev *hdev, unsigned long opt)
 {
 	__u8 encrypt = opt;
 
-	BT_DBG("%s %x", hdev->name, encrypt);
+	bt_dbg("%s %x", hdev->name, encrypt);
 
 	/* Encryption */
 	hci_send_cmd(hdev, HCI_OP_WRITE_ENCRYPT_MODE, 1, &encrypt);
@@ -311,7 +311,7 @@ static void hci_linkpol_req(struct hci_dev *hdev, unsigned long opt)
 {
 	__le16 policy = cpu_to_le16(opt);
 
-	BT_DBG("%s %x", hdev->name, policy);
+	bt_dbg("%s %x", hdev->name, policy);
 
 	/* Default link policy */
 	hci_send_cmd(hdev, HCI_OP_WRITE_DEF_LINK_POLICY, 2, &policy);
@@ -324,7 +324,7 @@ struct hci_dev *hci_dev_get(int index)
 	struct hci_dev *hdev = NULL;
 	struct list_head *p;
 
-	BT_DBG("%d", index);
+	bt_dbg("%d", index);
 
 	if (index < 0)
 		return NULL;
@@ -347,7 +347,7 @@ static void inquiry_cache_flush(struct hci_dev *hdev)
 	struct inquiry_cache *cache = &hdev->inq_cache;
 	struct inquiry_entry *next  = cache->list, *e;
 
-	BT_DBG("cache %p", cache);
+	bt_dbg("cache %p", cache);
 
 	cache->list = NULL;
 	while ((e = next)) {
@@ -361,7 +361,7 @@ struct inquiry_entry *hci_inquiry_cache_lookup(struct hci_dev *hdev, bdaddr_t *b
 	struct inquiry_cache *cache = &hdev->inq_cache;
 	struct inquiry_entry *e;
 
-	BT_DBG("cache %p, %s", cache, batostr(bdaddr));
+	bt_dbg("cache %p, %s", cache, batostr(bdaddr));
 
 	for (e = cache->list; e; e = e->next)
 		if (!bacmp(&e->data.bdaddr, bdaddr))
@@ -374,7 +374,7 @@ void hci_inquiry_cache_update(struct hci_dev *hdev, struct inquiry_data *data)
 	struct inquiry_cache *cache = &hdev->inq_cache;
 	struct inquiry_entry *ie;
 
-	BT_DBG("cache %p, %s", cache, batostr(&data->bdaddr));
+	bt_dbg("cache %p, %s", cache, batostr(&data->bdaddr));
 
 	ie = hci_inquiry_cache_lookup(hdev, &data->bdaddr);
 	if (!ie) {
@@ -410,7 +410,7 @@ static int inquiry_cache_dump(struct hci_dev *hdev, int num, __u8 *buf)
 		info++;
 	}
 
-	BT_DBG("cache %p, copied %d", cache, copied);
+	bt_dbg("cache %p, copied %d", cache, copied);
 	return copied;
 }
 
@@ -419,7 +419,7 @@ static void hci_inq_req(struct hci_dev *hdev, unsigned long opt)
 	struct hci_inquiry_req *ir = (struct hci_inquiry_req *) opt;
 	struct hci_cp_inquiry cp;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (test_bit(HCI_INQUIRY, &hdev->flags))
 		return;
@@ -480,7 +480,7 @@ int hci_inquiry(void __user *arg)
 	ir.num_rsp = inquiry_cache_dump(hdev, max_rsp, buf);
 	hci_dev_unlock_bh(hdev);
 
-	BT_DBG("num_rsp %d", ir.num_rsp);
+	bt_dbg("num_rsp %d", ir.num_rsp);
 
 	if (!copy_to_user(ptr, &ir, sizeof(ir))) {
 		ptr += sizeof(ir);
@@ -508,7 +508,7 @@ int hci_dev_open(__u16 dev)
 	if (!hdev)
 		return -ENODEV;
 
-	BT_DBG("%s %p", hdev->name, hdev);
+	bt_dbg("%s %p", hdev->name, hdev);
 
 	hci_req_lock(hdev);
 
@@ -584,7 +584,7 @@ done:
 
 static int hci_dev_do_close(struct hci_dev *hdev)
 {
-	BT_DBG("%s %p", hdev->name, hdev);
+	bt_dbg("%s %p", hdev->name, hdev);
 
 	hci_req_cancel(hdev, ENODEV);
 	hci_req_lock(hdev);
@@ -891,7 +891,7 @@ static int hci_rfkill_set_block(void *data, bool blocked)
 {
 	struct hci_dev *hdev = data;
 
-	BT_DBG("%p name %s blocked %d", hdev, hdev->name, blocked);
+	bt_dbg("%p name %s blocked %d", hdev, hdev->name, blocked);
 
 	if (!blocked)
 		return 0;
@@ -934,7 +934,7 @@ static void hci_power_on(struct work_struct *work)
 {
 	struct hci_dev *hdev = container_of(work, struct hci_dev, power_on);
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (hci_dev_open(hdev->id) < 0)
 		return;
@@ -951,7 +951,7 @@ static void hci_power_off(struct work_struct *work)
 {
 	struct hci_dev *hdev = container_of(work, struct hci_dev, power_off);
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_dev_close(hdev->id);
 }
@@ -960,7 +960,7 @@ static void hci_auto_off(unsigned long data)
 {
 	struct hci_dev *hdev = (struct hci_dev *) data;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	clear_bit(HCI_AUTO_OFF, &hdev->flags);
 
@@ -969,7 +969,7 @@ static void hci_auto_off(unsigned long data)
 
 void hci_del_off_timer(struct hci_dev *hdev)
 {
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	clear_bit(HCI_AUTO_OFF, &hdev->flags);
 	del_timer(&hdev->off_timer);
@@ -1077,7 +1077,7 @@ int hci_add_link_key(struct hci_dev *hdev, struct hci_conn *conn, int new_key,
 		list_add(&key->list, &hdev->link_keys);
 	}
 
-	BT_DBG("%s key for %s type %u", hdev->name, batostr(bdaddr), type);
+	bt_dbg("%s key for %s type %u", hdev->name, batostr(bdaddr), type);
 
 	/* Some buggy controller combinations generate a changed
 	 * combination key for legacy pairing even when there's no
@@ -1122,7 +1122,7 @@ int hci_remove_link_key(struct hci_dev *hdev, bdaddr_t *bdaddr)
 	if (!key)
 		return -ENOENT;
 
-	BT_DBG("%s removing %s", hdev->name, batostr(bdaddr));
+	bt_dbg("%s removing %s", hdev->name, batostr(bdaddr));
 
 	list_del(&key->list);
 	kfree(key);
@@ -1135,7 +1135,7 @@ static void hci_cmd_timer(unsigned long arg)
 {
 	struct hci_dev *hdev = (void *) arg;
 
-	BT_ERR("%s command tx timeout", hdev->name);
+	bt_err("%s command tx timeout", hdev->name);
 	atomic_set(&hdev->cmd_cnt, 1);
 	clear_bit(HCI_RESET, &hdev->flags);
 	tasklet_schedule(&hdev->cmd_task);
@@ -1161,7 +1161,7 @@ int hci_remove_remote_oob_data(struct hci_dev *hdev, bdaddr_t *bdaddr)
 	if (!data)
 		return -ENOENT;
 
-	BT_DBG("%s removing %s", hdev->name, batostr(bdaddr));
+	bt_dbg("%s removing %s", hdev->name, batostr(bdaddr));
 
 	list_del(&data->list);
 	kfree(data);
@@ -1200,7 +1200,7 @@ int hci_add_remote_oob_data(struct hci_dev *hdev, bdaddr_t *bdaddr, u8 *hash,
 	memcpy(data->hash, hash, sizeof(data->hash));
 	memcpy(data->randomizer, randomizer, sizeof(data->randomizer));
 
-	BT_DBG("%s for %s", hdev->name, batostr(bdaddr));
+	bt_dbg("%s for %s", hdev->name, batostr(bdaddr));
 
 	return 0;
 }
@@ -1316,7 +1316,7 @@ int hci_adv_entries_clear(struct hci_dev *hdev)
 		kfree(entry);
 	}
 
-	BT_DBG("%s adv cache cleared", hdev->name);
+	bt_dbg("%s adv cache cleared", hdev->name);
 
 	return 0;
 }
@@ -1362,7 +1362,7 @@ int hci_add_adv_entry(struct hci_dev *hdev,
 
 	list_add(&entry->list, &hdev->adv_entries);
 
-	BT_DBG("%s adv entry added: address %s type %u", hdev->name,
+	bt_dbg("%s adv entry added: address %s type %u", hdev->name,
 				batostr(&entry->bdaddr), entry->bdaddr_type);
 
 	return 0;
@@ -1382,7 +1382,7 @@ int hci_register_dev(struct hci_dev *hdev)
 	struct list_head *head = &hci_dev_list, *p;
 	int i, id = 0;
 
-	BT_DBG("%p name %s bus %d owner %p", hdev, hdev->name,
+	bt_dbg("%p name %s bus %d owner %p", hdev, hdev->name,
 						hdev->bus, hdev->owner);
 
 	if (!hdev->open || !hdev->close || !hdev->destruct)
@@ -1462,7 +1462,7 @@ int hci_register_dev(struct hci_dev *hdev)
 
 	hdev->tfm = alloc_cypher();
 	if (IS_ERR(hdev->tfm))
-		BT_INFO("Failed to load transform for ecb(aes): %ld",
+		bt_info("Failed to load transform for ecb(aes): %ld",
 							PTR_ERR(hdev->tfm));
 
 	hci_register_sysfs(hdev);
@@ -1498,7 +1498,7 @@ int hci_unregister_dev(struct hci_dev *hdev)
 {
 	int i;
 
-	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
+	bt_dbg("%p name %s bus %d", hdev, hdev->name, hdev->bus);
 
 	write_lock_bh(&hci_dev_list_lock);
 	list_del(&hdev->list);
@@ -1756,7 +1756,7 @@ int hci_register_proto(struct hci_proto *hp)
 {
 	int err = 0;
 
-	BT_DBG("%p name %s id %d", hp, hp->name, hp->id);
+	bt_dbg("%p name %s id %d", hp, hp->name, hp->id);
 
 	if (hp->id >= HCI_MAX_PROTO)
 		return -EINVAL;
@@ -1778,7 +1778,7 @@ int hci_unregister_proto(struct hci_proto *hp)
 {
 	int err = 0;
 
-	BT_DBG("%p name %s id %d", hp, hp->name, hp->id);
+	bt_dbg("%p name %s id %d", hp, hp->name, hp->id);
 
 	if (hp->id >= HCI_MAX_PROTO)
 		return -EINVAL;
@@ -1798,7 +1798,7 @@ EXPORT_SYMBOL(hci_unregister_proto);
 
 int hci_register_cb(struct hci_cb *cb)
 {
-	BT_DBG("%p name %s", cb, cb->name);
+	bt_dbg("%p name %s", cb, cb->name);
 
 	write_lock_bh(&hci_cb_list_lock);
 	list_add(&cb->list, &hci_cb_list);
@@ -1810,7 +1810,7 @@ EXPORT_SYMBOL(hci_register_cb);
 
 int hci_unregister_cb(struct hci_cb *cb)
 {
-	BT_DBG("%p name %s", cb, cb->name);
+	bt_dbg("%p name %s", cb, cb->name);
 
 	write_lock_bh(&hci_cb_list_lock);
 	list_del(&cb->list);
@@ -1829,7 +1829,7 @@ static int hci_send_frame(struct sk_buff *skb)
 		return -ENODEV;
 	}
 
-	BT_DBG("%s type %d len %d", hdev->name, bt_cb(skb)->pkt_type, skb->len);
+	bt_dbg("%s type %d len %d", hdev->name, bt_cb(skb)->pkt_type, skb->len);
 
 	if (atomic_read(&hdev->promisc)) {
 		/* Time stamp */
@@ -1851,11 +1851,11 @@ int hci_send_cmd(struct hci_dev *hdev, __u16 opcode, __u32 plen, void *param)
 	struct hci_command_hdr *hdr;
 	struct sk_buff *skb;
 
-	BT_DBG("%s opcode 0x%x plen %d", hdev->name, opcode, plen);
+	bt_dbg("%s opcode 0x%x plen %d", hdev->name, opcode, plen);
 
 	skb = bt_skb_alloc(len, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("%s no memory for command", hdev->name);
+		bt_err("%s no memory for command", hdev->name);
 		return -ENOMEM;
 	}
 
@@ -1866,7 +1866,7 @@ int hci_send_cmd(struct hci_dev *hdev, __u16 opcode, __u32 plen, void *param)
 	if (plen)
 		memcpy(skb_put(skb, plen), param, plen);
 
-	BT_DBG("skb len %d", skb->len);
+	bt_dbg("skb len %d", skb->len);
 
 	bt_cb(skb)->pkt_type = HCI_COMMAND_PKT;
 	skb->dev = (void *) hdev;
@@ -1893,7 +1893,7 @@ void *hci_sent_cmd_data(struct hci_dev *hdev, __u16 opcode)
 	if (hdr->opcode != cpu_to_le16(opcode))
 		return NULL;
 
-	BT_DBG("%s opcode 0x%x", hdev->name, opcode);
+	bt_dbg("%s opcode 0x%x", hdev->name, opcode);
 
 	return hdev->sent_cmd->data + HCI_COMMAND_HDR_SIZE;
 }
@@ -1916,7 +1916,7 @@ void hci_send_acl(struct hci_conn *conn, struct sk_buff *skb, __u16 flags)
 	struct hci_dev *hdev = conn->hdev;
 	struct sk_buff *list;
 
-	BT_DBG("%s conn %p flags 0x%x", hdev->name, conn, flags);
+	bt_dbg("%s conn %p flags 0x%x", hdev->name, conn, flags);
 
 	skb->dev = (void *) hdev;
 	bt_cb(skb)->pkt_type = HCI_ACLDATA_PKT;
@@ -1925,12 +1925,12 @@ void hci_send_acl(struct hci_conn *conn, struct sk_buff *skb, __u16 flags)
 	list = skb_shinfo(skb)->frag_list;
 	if (!list) {
 		/* Non fragmented */
-		BT_DBG("%s nonfrag skb %p len %d", hdev->name, skb, skb->len);
+		bt_dbg("%s nonfrag skb %p len %d", hdev->name, skb, skb->len);
 
 		skb_queue_tail(&conn->data_q, skb);
 	} else {
 		/* Fragmented */
-		BT_DBG("%s frag %p len %d", hdev->name, skb, skb->len);
+		bt_dbg("%s frag %p len %d", hdev->name, skb, skb->len);
 
 		skb_shinfo(skb)->frag_list = NULL;
 
@@ -1948,7 +1948,7 @@ void hci_send_acl(struct hci_conn *conn, struct sk_buff *skb, __u16 flags)
 			bt_cb(skb)->pkt_type = HCI_ACLDATA_PKT;
 			hci_add_acl_hdr(skb, conn->handle, flags);
 
-			BT_DBG("%s frag %p len %d", hdev->name, skb, skb->len);
+			bt_dbg("%s frag %p len %d", hdev->name, skb, skb->len);
 
 			__skb_queue_tail(&conn->data_q, skb);
 		} while (list);
@@ -1966,7 +1966,7 @@ void hci_send_sco(struct hci_conn *conn, struct sk_buff *skb)
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_sco_hdr hdr;
 
-	BT_DBG("%s len %d", hdev->name, skb->len);
+	bt_dbg("%s len %d", hdev->name, skb->len);
 
 	hdr.handle = cpu_to_le16(conn->handle);
 	hdr.dlen   = skb->len;
@@ -2029,7 +2029,7 @@ static inline struct hci_conn *hci_low_sent(struct hci_dev *hdev, __u8 type, int
 			break;
 		default:
 			cnt = 0;
-			BT_ERR("Unknown link type");
+			bt_err("Unknown link type");
 		}
 
 		q = cnt / num;
@@ -2037,7 +2037,7 @@ static inline struct hci_conn *hci_low_sent(struct hci_dev *hdev, __u8 type, int
 	} else
 		*quote = 0;
 
-	BT_DBG("conn %p quote %d", conn, *quote);
+	bt_dbg("conn %p quote %d", conn, *quote);
 	return conn;
 }
 
@@ -2047,13 +2047,13 @@ static inline void hci_link_tx_to(struct hci_dev *hdev, __u8 type)
 	struct list_head *p;
 	struct hci_conn  *c;
 
-	BT_ERR("%s link tx timeout", hdev->name);
+	bt_err("%s link tx timeout", hdev->name);
 
 	/* Kill stalled connections */
 	list_for_each(p, &h->list) {
 		c = list_entry(p, struct hci_conn, list);
 		if (c->type == type && c->sent) {
-			BT_ERR("%s killing stalled connection %s",
+			bt_err("%s killing stalled connection %s",
 				hdev->name, batostr(&c->dst));
 			hci_acl_disconn(c, 0x13);
 		}
@@ -2066,7 +2066,7 @@ static inline void hci_sched_acl(struct hci_dev *hdev)
 	struct sk_buff *skb;
 	int quote;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (!test_bit(HCI_RAW, &hdev->flags)) {
 		/* ACL tx timeout must be longer than maximum
@@ -2077,7 +2077,7 @@ static inline void hci_sched_acl(struct hci_dev *hdev)
 
 	while (hdev->acl_cnt && (conn = hci_low_sent(hdev, ACL_LINK, &quote))) {
 		while (quote-- && (skb = skb_dequeue(&conn->data_q))) {
-			BT_DBG("skb %p len %d", skb, skb->len);
+			bt_dbg("skb %p len %d", skb, skb->len);
 
 			hci_conn_enter_active_mode(conn, bt_cb(skb)->force_active);
 
@@ -2097,11 +2097,11 @@ static inline void hci_sched_sco(struct hci_dev *hdev)
 	struct sk_buff *skb;
 	int quote;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	while (hdev->sco_cnt && (conn = hci_low_sent(hdev, SCO_LINK, &quote))) {
 		while (quote-- && (skb = skb_dequeue(&conn->data_q))) {
-			BT_DBG("skb %p len %d", skb, skb->len);
+			bt_dbg("skb %p len %d", skb, skb->len);
 			hci_send_frame(skb);
 
 			conn->sent++;
@@ -2117,11 +2117,11 @@ static inline void hci_sched_esco(struct hci_dev *hdev)
 	struct sk_buff *skb;
 	int quote;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	while (hdev->sco_cnt && (conn = hci_low_sent(hdev, ESCO_LINK, &quote))) {
 		while (quote-- && (skb = skb_dequeue(&conn->data_q))) {
-			BT_DBG("skb %p len %d", skb, skb->len);
+			bt_dbg("skb %p len %d", skb, skb->len);
 			hci_send_frame(skb);
 
 			conn->sent++;
@@ -2137,7 +2137,7 @@ static inline void hci_sched_le(struct hci_dev *hdev)
 	struct sk_buff *skb;
 	int quote, cnt;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (!test_bit(HCI_RAW, &hdev->flags)) {
 		/* LE tx timeout must be longer than maximum
@@ -2150,7 +2150,7 @@ static inline void hci_sched_le(struct hci_dev *hdev)
 	cnt = hdev->le_pkts ? hdev->le_cnt : hdev->acl_cnt;
 	while (cnt && (conn = hci_low_sent(hdev, LE_LINK, &quote))) {
 		while (quote-- && (skb = skb_dequeue(&conn->data_q))) {
-			BT_DBG("skb %p len %d", skb, skb->len);
+			bt_dbg("skb %p len %d", skb, skb->len);
 
 			hci_send_frame(skb);
 			hdev->le_last_tx = jiffies;
@@ -2172,7 +2172,7 @@ static void hci_tx_task(unsigned long arg)
 
 	read_lock(&hci_task_lock);
 
-	BT_DBG("%s acl %d sco %d le %d", hdev->name, hdev->acl_cnt,
+	bt_dbg("%s acl %d sco %d le %d", hdev->name, hdev->acl_cnt,
 		hdev->sco_cnt, hdev->le_cnt);
 
 	/* Schedule queues and send stuff to HCI driver */
@@ -2207,7 +2207,7 @@ static inline void hci_acldata_packet(struct hci_dev *hdev, struct sk_buff *skb)
 	flags  = hci_flags(handle);
 	handle = hci_handle(handle);
 
-	BT_DBG("%s len %d handle 0x%x flags 0x%x", hdev->name, skb->len, handle, flags);
+	bt_dbg("%s len %d handle 0x%x flags 0x%x", hdev->name, skb->len, handle, flags);
 
 	hdev->stat.acl_rx++;
 
@@ -2227,7 +2227,7 @@ static inline void hci_acldata_packet(struct hci_dev *hdev, struct sk_buff *skb)
 			return;
 		}
 	} else {
-		BT_ERR("%s ACL packet for unknown connection handle %d",
+		bt_err("%s ACL packet for unknown connection handle %d",
 			hdev->name, handle);
 	}
 
@@ -2245,7 +2245,7 @@ static inline void hci_scodata_packet(struct hci_dev *hdev, struct sk_buff *skb)
 
 	handle = __le16_to_cpu(hdr->handle);
 
-	BT_DBG("%s len %d handle 0x%x", hdev->name, skb->len, handle);
+	bt_dbg("%s len %d handle 0x%x", hdev->name, skb->len, handle);
 
 	hdev->stat.sco_rx++;
 
@@ -2263,7 +2263,7 @@ static inline void hci_scodata_packet(struct hci_dev *hdev, struct sk_buff *skb)
 			return;
 		}
 	} else {
-		BT_ERR("%s SCO packet for unknown connection handle %d",
+		bt_err("%s SCO packet for unknown connection handle %d",
 			hdev->name, handle);
 	}
 
@@ -2275,7 +2275,7 @@ static void hci_rx_task(unsigned long arg)
 	struct hci_dev *hdev = (struct hci_dev *) arg;
 	struct sk_buff *skb;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	read_lock(&hci_task_lock);
 
@@ -2307,12 +2307,12 @@ static void hci_rx_task(unsigned long arg)
 			break;
 
 		case HCI_ACLDATA_PKT:
-			BT_DBG("%s ACL data packet", hdev->name);
+			bt_dbg("%s ACL data packet", hdev->name);
 			hci_acldata_packet(hdev, skb);
 			break;
 
 		case HCI_SCODATA_PKT:
-			BT_DBG("%s SCO data packet", hdev->name);
+			bt_dbg("%s SCO data packet", hdev->name);
 			hci_scodata_packet(hdev, skb);
 			break;
 
@@ -2330,7 +2330,7 @@ static void hci_cmd_task(unsigned long arg)
 	struct hci_dev *hdev = (struct hci_dev *) arg;
 	struct sk_buff *skb;
 
-	BT_DBG("%s cmd %d", hdev->name, atomic_read(&hdev->cmd_cnt));
+	bt_dbg("%s cmd %d", hdev->name, atomic_read(&hdev->cmd_cnt));
 
 	/* Send queued commands */
 	if (atomic_read(&hdev->cmd_cnt)) {
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index ac2c5e8..1df9dd3 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -51,7 +51,7 @@ static void hci_cc_inquiry_cancel(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (status)
 		return;
@@ -69,7 +69,7 @@ static void hci_cc_exit_periodic_inq(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (status)
 		return;
@@ -83,7 +83,7 @@ static void hci_cc_exit_periodic_inq(struct hci_dev *hdev, struct sk_buff *skb)
 
 static void hci_cc_remote_name_req_cancel(struct hci_dev *hdev, struct sk_buff *skb)
 {
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 }
 
 static void hci_cc_role_discovery(struct hci_dev *hdev, struct sk_buff *skb)
@@ -91,7 +91,7 @@ static void hci_cc_role_discovery(struct hci_dev *hdev, struct sk_buff *skb)
 	struct hci_rp_role_discovery *rp = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -114,7 +114,7 @@ static void hci_cc_read_link_policy(struct hci_dev *hdev, struct sk_buff *skb)
 	struct hci_rp_read_link_policy *rp = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -134,7 +134,7 @@ static void hci_cc_write_link_policy(struct hci_dev *hdev, struct sk_buff *skb)
 	struct hci_conn *conn;
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -156,7 +156,7 @@ static void hci_cc_read_def_link_policy(struct hci_dev *hdev, struct sk_buff *sk
 {
 	struct hci_rp_read_def_link_policy *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -169,7 +169,7 @@ static void hci_cc_write_def_link_policy(struct hci_dev *hdev, struct sk_buff *s
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	sent = hci_sent_cmd_data(hdev, HCI_OP_WRITE_DEF_LINK_POLICY);
 	if (!sent)
@@ -185,7 +185,7 @@ static void hci_cc_reset(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	clear_bit(HCI_RESET, &hdev->flags);
 
@@ -197,7 +197,7 @@ static void hci_cc_write_local_name(struct hci_dev *hdev, struct sk_buff *skb)
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	sent = hci_sent_cmd_data(hdev, HCI_OP_WRITE_LOCAL_NAME);
 	if (!sent)
@@ -216,7 +216,7 @@ static void hci_cc_read_local_name(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_read_local_name *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -229,7 +229,7 @@ static void hci_cc_write_auth_enable(struct hci_dev *hdev, struct sk_buff *skb)
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	sent = hci_sent_cmd_data(hdev, HCI_OP_WRITE_AUTH_ENABLE);
 	if (!sent)
@@ -252,7 +252,7 @@ static void hci_cc_write_encrypt_mode(struct hci_dev *hdev, struct sk_buff *skb)
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	sent = hci_sent_cmd_data(hdev, HCI_OP_WRITE_ENCRYPT_MODE);
 	if (!sent)
@@ -275,7 +275,7 @@ static void hci_cc_write_scan_enable(struct hci_dev *hdev, struct sk_buff *skb)
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	sent = hci_sent_cmd_data(hdev, HCI_OP_WRITE_SCAN_ENABLE);
 	if (!sent)
@@ -310,14 +310,14 @@ static void hci_cc_read_class_of_dev(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_read_class_of_dev *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
 
 	memcpy(hdev->dev_class, rp->dev_class, 3);
 
-	BT_DBG("%s class 0x%.2x%.2x%.2x", hdev->name,
+	bt_dbg("%s class 0x%.2x%.2x%.2x", hdev->name,
 		hdev->dev_class[2], hdev->dev_class[1], hdev->dev_class[0]);
 }
 
@@ -326,7 +326,7 @@ static void hci_cc_write_class_of_dev(struct hci_dev *hdev, struct sk_buff *skb)
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (status)
 		return;
@@ -343,7 +343,7 @@ static void hci_cc_read_voice_setting(struct hci_dev *hdev, struct sk_buff *skb)
 	struct hci_rp_read_voice_setting *rp = (void *) skb->data;
 	__u16 setting;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -355,7 +355,7 @@ static void hci_cc_read_voice_setting(struct hci_dev *hdev, struct sk_buff *skb)
 
 	hdev->voice_setting = setting;
 
-	BT_DBG("%s voice setting 0x%04x", hdev->name, setting);
+	bt_dbg("%s voice setting 0x%04x", hdev->name, setting);
 
 	if (hdev->notify) {
 		tasklet_disable(&hdev->tx_task);
@@ -370,7 +370,7 @@ static void hci_cc_write_voice_setting(struct hci_dev *hdev, struct sk_buff *skb
 	__u16 setting;
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (status)
 		return;
@@ -386,7 +386,7 @@ static void hci_cc_write_voice_setting(struct hci_dev *hdev, struct sk_buff *skb
 
 	hdev->voice_setting = setting;
 
-	BT_DBG("%s voice setting 0x%04x", hdev->name, setting);
+	bt_dbg("%s voice setting 0x%04x", hdev->name, setting);
 
 	if (hdev->notify) {
 		tasklet_disable(&hdev->tx_task);
@@ -399,7 +399,7 @@ static void hci_cc_host_buffer_size(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_HOST_BUFFER_SIZE, status);
 }
@@ -408,7 +408,7 @@ static void hci_cc_read_ssp_mode(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_read_ssp_mode *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -421,7 +421,7 @@ static void hci_cc_write_ssp_mode(struct hci_dev *hdev, struct sk_buff *skb)
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (status)
 		return;
@@ -548,7 +548,7 @@ static void hci_cc_read_local_version(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_read_local_version *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -559,7 +559,7 @@ static void hci_cc_read_local_version(struct hci_dev *hdev, struct sk_buff *skb)
 	hdev->manufacturer = __le16_to_cpu(rp->manufacturer);
 	hdev->lmp_subver = __le16_to_cpu(rp->lmp_subver);
 
-	BT_DBG("%s manufacturer %d hci ver %d:%d", hdev->name,
+	bt_dbg("%s manufacturer %d hci ver %d:%d", hdev->name,
 					hdev->manufacturer,
 					hdev->hci_ver, hdev->hci_rev);
 
@@ -589,7 +589,7 @@ static void hci_cc_read_local_commands(struct hci_dev *hdev, struct sk_buff *skb
 {
 	struct hci_rp_read_local_commands *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		goto done;
@@ -607,7 +607,7 @@ static void hci_cc_read_local_features(struct hci_dev *hdev, struct sk_buff *skb
 {
 	struct hci_rp_read_local_features *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -651,7 +651,7 @@ static void hci_cc_read_local_features(struct hci_dev *hdev, struct sk_buff *skb
 	if (hdev->features[5] & LMP_EDR_3S_ESCO)
 		hdev->esco_type |= (ESCO_2EV5 | ESCO_3EV5);
 
-	BT_DBG("%s features 0x%.2x%.2x%.2x%.2x%.2x%.2x%.2x%.2x", hdev->name,
+	bt_dbg("%s features 0x%.2x%.2x%.2x%.2x%.2x%.2x%.2x%.2x", hdev->name,
 					hdev->features[0], hdev->features[1],
 					hdev->features[2], hdev->features[3],
 					hdev->features[4], hdev->features[5],
@@ -662,7 +662,7 @@ static void hci_cc_read_buffer_size(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_read_buffer_size *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -680,7 +680,7 @@ static void hci_cc_read_buffer_size(struct hci_dev *hdev, struct sk_buff *skb)
 	hdev->acl_cnt = hdev->acl_pkts;
 	hdev->sco_cnt = hdev->sco_pkts;
 
-	BT_DBG("%s acl mtu %d:%d sco mtu %d:%d", hdev->name,
+	bt_dbg("%s acl mtu %d:%d sco mtu %d:%d", hdev->name,
 					hdev->acl_mtu, hdev->acl_pkts,
 					hdev->sco_mtu, hdev->sco_pkts);
 }
@@ -689,7 +689,7 @@ static void hci_cc_read_bd_addr(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_read_bd_addr *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (!rp->status)
 		bacpy(&hdev->bdaddr, &rp->bdaddr);
@@ -701,7 +701,7 @@ static void hci_cc_write_ca_timeout(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_WRITE_CA_TIMEOUT, status);
 }
@@ -711,7 +711,7 @@ static void hci_cc_delete_stored_link_key(struct hci_dev *hdev,
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_DELETE_STORED_LINK_KEY, status);
 }
@@ -720,7 +720,7 @@ static void hci_cc_set_event_mask(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_SET_EVENT_MASK, status);
 }
@@ -730,7 +730,7 @@ static void hci_cc_write_inquiry_mode(struct hci_dev *hdev,
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_WRITE_INQUIRY_MODE, status);
 }
@@ -740,7 +740,7 @@ static void hci_cc_read_inq_rsp_tx_power(struct hci_dev *hdev,
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_READ_INQ_RSP_TX_POWER, status);
 }
@@ -749,7 +749,7 @@ static void hci_cc_set_event_flt(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_SET_EVENT_FLT, status);
 }
@@ -760,7 +760,7 @@ static void hci_cc_pin_code_reply(struct hci_dev *hdev, struct sk_buff *skb)
 	struct hci_cp_pin_code_reply *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (test_bit(HCI_MGMT, &hdev->flags))
 		mgmt_pin_code_reply_complete(hdev->id, &rp->bdaddr, rp->status);
@@ -781,7 +781,7 @@ static void hci_cc_pin_code_neg_reply(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_pin_code_neg_reply *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (test_bit(HCI_MGMT, &hdev->flags))
 		mgmt_pin_code_neg_reply_complete(hdev->id, &rp->bdaddr,
@@ -792,7 +792,7 @@ static void hci_cc_le_read_buffer_size(struct hci_dev *hdev,
 {
 	struct hci_rp_le_read_buffer_size *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -802,7 +802,7 @@ static void hci_cc_le_read_buffer_size(struct hci_dev *hdev,
 
 	hdev->le_cnt = hdev->le_pkts;
 
-	BT_DBG("%s le mtu %d:%d", hdev->name, hdev->le_mtu, hdev->le_pkts);
+	bt_dbg("%s le mtu %d:%d", hdev->name, hdev->le_mtu, hdev->le_pkts);
 
 	hci_req_complete(hdev, HCI_OP_LE_READ_BUFFER_SIZE, rp->status);
 }
@@ -811,7 +811,7 @@ static void hci_cc_user_confirm_reply(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_user_confirm_reply *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (test_bit(HCI_MGMT, &hdev->flags))
 		mgmt_user_confirm_reply_complete(hdev->id, &rp->bdaddr,
@@ -823,7 +823,7 @@ static void hci_cc_user_confirm_neg_reply(struct hci_dev *hdev,
 {
 	struct hci_rp_user_confirm_reply *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (test_bit(HCI_MGMT, &hdev->flags))
 		mgmt_user_confirm_neg_reply_complete(hdev->id, &rp->bdaddr,
@@ -835,7 +835,7 @@ static void hci_cc_read_local_oob_data_reply(struct hci_dev *hdev,
 {
 	struct hci_rp_read_local_oob_data *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	mgmt_read_local_oob_data_reply_complete(hdev->id, rp->hash,
 						rp->randomizer, rp->status);
@@ -847,7 +847,7 @@ static void hci_cc_le_set_scan_enable(struct hci_dev *hdev,
 	struct hci_cp_le_set_scan_enable *cp;
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (status)
 		return;
@@ -872,7 +872,7 @@ static void hci_cc_le_ltk_reply(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_le_ltk_reply *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -884,7 +884,7 @@ static void hci_cc_le_ltk_neg_reply(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_le_ltk_neg_reply *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	bt_dbg("%s status 0x%x", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -894,7 +894,7 @@ static void hci_cc_le_ltk_neg_reply(struct hci_dev *hdev, struct sk_buff *skb)
 
 static inline void hci_cs_inquiry(struct hci_dev *hdev, __u8 status)
 {
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (status) {
 		hci_req_complete(hdev, HCI_OP_INQUIRY, status);
@@ -913,7 +913,7 @@ static inline void hci_cs_create_conn(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_create_conn *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	cp = hci_sent_cmd_data(hdev, HCI_OP_CREATE_CONN);
 	if (!cp)
@@ -923,7 +923,7 @@ static inline void hci_cs_create_conn(struct hci_dev *hdev, __u8 status)
 
 	conn = hci_conn_hash_lookup_ba(hdev, ACL_LINK, &cp->bdaddr);
 
-	BT_DBG("%s bdaddr %s conn %p", hdev->name, batostr(&cp->bdaddr), conn);
+	bt_dbg("%s bdaddr %s conn %p", hdev->name, batostr(&cp->bdaddr), conn);
 
 	if (status) {
 		if (conn && conn->state == BT_CONNECT) {
@@ -941,7 +941,7 @@ static inline void hci_cs_create_conn(struct hci_dev *hdev, __u8 status)
 				conn->out = 1;
 				conn->link_mode |= HCI_LM_MASTER;
 			} else
-				BT_ERR("No memory for new connection");
+				bt_err("No memory for new connection");
 		}
 	}
 
@@ -954,7 +954,7 @@ static void hci_cs_add_sco(struct hci_dev *hdev, __u8 status)
 	struct hci_conn *acl, *sco;
 	__u16 handle;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (!status)
 		return;
@@ -965,7 +965,7 @@ static void hci_cs_add_sco(struct hci_dev *hdev, __u8 status)
 
 	handle = __le16_to_cpu(cp->handle);
 
-	BT_DBG("%s handle %d", hdev->name, handle);
+	bt_dbg("%s handle %d", hdev->name, handle);
 
 	hci_dev_lock(hdev);
 
@@ -988,7 +988,7 @@ static void hci_cs_auth_requested(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_auth_requested *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1015,7 +1015,7 @@ static void hci_cs_set_conn_encrypt(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_set_conn_encrypt *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1060,7 +1060,7 @@ static void hci_cs_remote_name_req(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_remote_name_req *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	/* If successful wait for the name req complete event before
 	 * checking for the need to do authentication */
@@ -1095,7 +1095,7 @@ static void hci_cs_read_remote_features(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_read_remote_features *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1122,7 +1122,7 @@ static void hci_cs_read_remote_ext_features(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_read_remote_ext_features *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1150,7 +1150,7 @@ static void hci_cs_setup_sync_conn(struct hci_dev *hdev, __u8 status)
 	struct hci_conn *acl, *sco;
 	__u16 handle;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1161,7 +1161,7 @@ static void hci_cs_setup_sync_conn(struct hci_dev *hdev, __u8 status)
 
 	handle = __le16_to_cpu(cp->handle);
 
-	BT_DBG("%s handle %d", hdev->name, handle);
+	bt_dbg("%s handle %d", hdev->name, handle);
 
 	hci_dev_lock(hdev);
 
@@ -1184,7 +1184,7 @@ static void hci_cs_sniff_mode(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_sniff_mode *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1211,7 +1211,7 @@ static void hci_cs_exit_sniff_mode(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_exit_sniff_mode *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1238,7 +1238,7 @@ static void hci_cs_le_create_conn(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_le_create_conn *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 
 	cp = hci_sent_cmd_data(hdev, HCI_OP_LE_CREATE_CONN);
 	if (!cp)
@@ -1248,7 +1248,7 @@ static void hci_cs_le_create_conn(struct hci_dev *hdev, __u8 status)
 
 	conn = hci_conn_hash_lookup_ba(hdev, LE_LINK, &cp->peer_addr);
 
-	BT_DBG("%s bdaddr %s conn %p", hdev->name, batostr(&cp->peer_addr),
+	bt_dbg("%s bdaddr %s conn %p", hdev->name, batostr(&cp->peer_addr),
 		conn);
 
 	if (status) {
@@ -1264,7 +1264,7 @@ static void hci_cs_le_create_conn(struct hci_dev *hdev, __u8 status)
 				conn->dst_type = cp->peer_addr_type;
 				conn->out = 1;
 			} else {
-				BT_ERR("No memory for new connection");
+				bt_err("No memory for new connection");
 			}
 		}
 	}
@@ -1274,14 +1274,14 @@ static void hci_cs_le_create_conn(struct hci_dev *hdev, __u8 status)
 
 static void hci_cs_le_start_enc(struct hci_dev *hdev, u8 status)
 {
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	bt_dbg("%s status 0x%x", hdev->name, status);
 }
 
 static inline void hci_inquiry_complete_evt(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status %d", hdev->name, status);
+	bt_dbg("%s status %d", hdev->name, status);
 
 	if (test_bit(HCI_MGMT, &hdev->flags) &&
 				test_and_clear_bit(HCI_INQUIRY, &hdev->flags))
@@ -1298,7 +1298,7 @@ static inline void hci_inquiry_result_evt(struct hci_dev *hdev, struct sk_buff *
 	struct inquiry_info *info = (void *) (skb->data + 1);
 	int num_rsp = *((__u8 *) skb->data);
 
-	BT_DBG("%s num_rsp %d", hdev->name, num_rsp);
+	bt_dbg("%s num_rsp %d", hdev->name, num_rsp);
 
 	if (!num_rsp)
 		return;
@@ -1333,7 +1333,7 @@ static inline void hci_conn_complete_evt(struct hci_dev *hdev, struct sk_buff *s
 	struct hci_ev_conn_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -1411,7 +1411,7 @@ static inline void hci_conn_request_evt(struct hci_dev *hdev, struct sk_buff *sk
 	struct hci_ev_conn_request *ev = (void *) skb->data;
 	int mask = hdev->link_mode;
 
-	BT_DBG("%s bdaddr %s type 0x%x", hdev->name,
+	bt_dbg("%s bdaddr %s type 0x%x", hdev->name,
 					batostr(&ev->bdaddr), ev->link_type);
 
 	mask |= hci_proto_connect_ind(hdev, &ev->bdaddr, ev->link_type);
@@ -1432,7 +1432,7 @@ static inline void hci_conn_request_evt(struct hci_dev *hdev, struct sk_buff *sk
 		if (!conn) {
 			conn = hci_conn_add(hdev, ev->link_type, &ev->bdaddr);
 			if (!conn) {
-				BT_ERR("No memory for new connection");
+				bt_err("No memory for new connection");
 				hci_dev_unlock(hdev);
 				return;
 			}
@@ -1485,7 +1485,7 @@ static inline void hci_disconn_complete_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_ev_disconn_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	bt_dbg("%s status %d", hdev->name, ev->status);
 
 	if (ev->status) {
 		mgmt_disconnect_failed(hdev->id);
@@ -1515,7 +1515,7 @@ static inline void hci_auth_complete_evt(struct hci_dev *hdev, struct sk_buff *s
 	struct hci_ev_auth_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	bt_dbg("%s status %d", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -1526,7 +1526,7 @@ static inline void hci_auth_complete_evt(struct hci_dev *hdev, struct sk_buff *s
 	if (!ev->status) {
 		if (!(conn->ssp_mode > 0 && hdev->ssp_mode > 0) &&
 				test_bit(HCI_CONN_REAUTH_PEND,	&conn->pend)) {
-			BT_INFO("re-auth of legacy device is not possible.");
+			bt_info("re-auth of legacy device is not possible.");
 		} else {
 			conn->link_mode |= HCI_LM_AUTH;
 			conn->sec_level = conn->pending_sec_level;
@@ -1580,7 +1580,7 @@ static inline void hci_remote_name_evt(struct hci_dev *hdev, struct sk_buff *skb
 	struct hci_ev_remote_name *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_conn_check_pending(hdev);
 
@@ -1611,7 +1611,7 @@ static inline void hci_encrypt_change_evt(struct hci_dev *hdev, struct sk_buff *
 	struct hci_ev_encrypt_change *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	bt_dbg("%s status %d", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -1647,7 +1647,7 @@ static inline void hci_change_link_key_complete_evt(struct hci_dev *hdev, struct
 	struct hci_ev_change_link_key_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	bt_dbg("%s status %d", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -1669,7 +1669,7 @@ static inline void hci_remote_features_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_ev_remote_features *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	bt_dbg("%s status %d", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -1712,12 +1712,12 @@ unlock:
 
 static inline void hci_remote_version_evt(struct hci_dev *hdev, struct sk_buff *skb)
 {
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 }
 
 static inline void hci_qos_setup_complete_evt(struct hci_dev *hdev, struct sk_buff *skb)
 {
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 }
 
 static inline void hci_cmd_complete_evt(struct hci_dev *hdev, struct sk_buff *skb)
@@ -1895,7 +1895,7 @@ static inline void hci_cmd_complete_evt(struct hci_dev *hdev, struct sk_buff *sk
 		break;
 
 	default:
-		BT_DBG("%s opcode 0x%x", hdev->name, opcode);
+		bt_dbg("%s opcode 0x%x", hdev->name, opcode);
 		break;
 	}
 
@@ -1977,7 +1977,7 @@ static inline void hci_cmd_status_evt(struct hci_dev *hdev, struct sk_buff *skb)
 		break;
 
 	default:
-		BT_DBG("%s opcode 0x%x", hdev->name, opcode);
+		bt_dbg("%s opcode 0x%x", hdev->name, opcode);
 		break;
 	}
 
@@ -1996,7 +1996,7 @@ static inline void hci_role_change_evt(struct hci_dev *hdev, struct sk_buff *skb
 	struct hci_ev_role_change *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	bt_dbg("%s status %d", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -2025,10 +2025,10 @@ static inline void hci_num_comp_pkts_evt(struct hci_dev *hdev, struct sk_buff *s
 
 	skb_pull(skb, sizeof(*ev));
 
-	BT_DBG("%s num_hndl %d", hdev->name, ev->num_hndl);
+	bt_dbg("%s num_hndl %d", hdev->name, ev->num_hndl);
 
 	if (skb->len < ev->num_hndl * 4) {
-		BT_DBG("%s bad parameters", hdev->name);
+		bt_dbg("%s bad parameters", hdev->name);
 		return;
 	}
 
@@ -2077,7 +2077,7 @@ static inline void hci_mode_change_evt(struct hci_dev *hdev, struct sk_buff *skb
 	struct hci_ev_mode_change *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	bt_dbg("%s status %d", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -2105,7 +2105,7 @@ static inline void hci_pin_code_request_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_ev_pin_code_req *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2140,7 +2140,7 @@ static inline void hci_link_key_request_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_conn *conn;
 	struct link_key *key;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (!test_bit(HCI_LINK_KEYS, &hdev->flags))
 		return;
@@ -2149,17 +2149,17 @@ static inline void hci_link_key_request_evt(struct hci_dev *hdev, struct sk_buff
 
 	key = hci_find_link_key(hdev, &ev->bdaddr);
 	if (!key) {
-		BT_DBG("%s link key not found for %s", hdev->name,
+		bt_dbg("%s link key not found for %s", hdev->name,
 							batostr(&ev->bdaddr));
 		goto not_found;
 	}
 
-	BT_DBG("%s found key type %u for %s", hdev->name, key->type,
+	bt_dbg("%s found key type %u for %s", hdev->name, key->type,
 							batostr(&ev->bdaddr));
 
 	if (!test_bit(HCI_DEBUG_KEYS, &hdev->flags) &&
 				key->type == HCI_LK_DEBUG_COMBINATION) {
-		BT_DBG("%s ignoring debug key", hdev->name);
+		bt_dbg("%s ignoring debug key", hdev->name);
 		goto not_found;
 	}
 
@@ -2168,13 +2168,13 @@ static inline void hci_link_key_request_evt(struct hci_dev *hdev, struct sk_buff
 		if (key->type == HCI_LK_UNAUTH_COMBINATION &&
 				conn->auth_type != 0xff &&
 				(conn->auth_type & 0x01)) {
-			BT_DBG("%s ignoring unauthenticated key", hdev->name);
+			bt_dbg("%s ignoring unauthenticated key", hdev->name);
 			goto not_found;
 		}
 
 		if (key->type == HCI_LK_COMBINATION && key->pin_len < 16 &&
 				conn->pending_sec_level == BT_SECURITY_HIGH) {
-			BT_DBG("%s ignoring key unauthenticated for high \
+			bt_dbg("%s ignoring key unauthenticated for high \
 							security", hdev->name);
 			goto not_found;
 		}
@@ -2203,7 +2203,7 @@ static inline void hci_link_key_notify_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_conn *conn;
 	u8 pin_len = 0;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2231,7 +2231,7 @@ static inline void hci_clock_offset_evt(struct hci_dev *hdev, struct sk_buff *sk
 	struct hci_ev_clock_offset *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	bt_dbg("%s status %d", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -2254,7 +2254,7 @@ static inline void hci_pkt_type_change_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_ev_pkt_type_change *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	bt_dbg("%s status %d", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -2270,7 +2270,7 @@ static inline void hci_pscan_rep_mode_evt(struct hci_dev *hdev, struct sk_buff *
 	struct hci_ev_pscan_rep_mode *ev = (void *) skb->data;
 	struct inquiry_entry *ie;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2288,7 +2288,7 @@ static inline void hci_inquiry_result_with_rssi_evt(struct hci_dev *hdev, struct
 	struct inquiry_data data;
 	int num_rsp = *((__u8 *) skb->data);
 
-	BT_DBG("%s num_rsp %d", hdev->name, num_rsp);
+	bt_dbg("%s num_rsp %d", hdev->name, num_rsp);
 
 	if (!num_rsp)
 		return;
@@ -2346,7 +2346,7 @@ static inline void hci_remote_ext_features_evt(struct hci_dev *hdev, struct sk_b
 	struct hci_ev_remote_ext_features *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2390,7 +2390,7 @@ static inline void hci_sync_conn_complete_evt(struct hci_dev *hdev, struct sk_bu
 	struct hci_ev_sync_conn_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	bt_dbg("%s status %d", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -2442,14 +2442,14 @@ unlock:
 
 static inline void hci_sync_conn_changed_evt(struct hci_dev *hdev, struct sk_buff *skb)
 {
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 }
 
 static inline void hci_sniff_subrate_evt(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_ev_sniff_subrate *ev = (void *) skb->data;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	bt_dbg("%s status %d", hdev->name, ev->status);
 }
 
 static inline void hci_extended_inquiry_result_evt(struct hci_dev *hdev, struct sk_buff *skb)
@@ -2458,7 +2458,7 @@ static inline void hci_extended_inquiry_result_evt(struct hci_dev *hdev, struct
 	struct extended_inquiry_info *info = (void *) (skb->data + 1);
 	int num_rsp = *((__u8 *) skb->data);
 
-	BT_DBG("%s num_rsp %d", hdev->name, num_rsp);
+	bt_dbg("%s num_rsp %d", hdev->name, num_rsp);
 
 	if (!num_rsp)
 		return;
@@ -2512,7 +2512,7 @@ static inline void hci_io_capa_request_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_ev_io_capa_request *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2561,7 +2561,7 @@ static inline void hci_io_capa_reply_evt(struct hci_dev *hdev, struct sk_buff *s
 	struct hci_ev_io_capa_reply *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2584,7 +2584,7 @@ static inline void hci_user_confirm_request_evt(struct hci_dev *hdev,
 	int loc_mitm, rem_mitm, confirm_hint = 0;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2604,7 +2604,7 @@ static inline void hci_user_confirm_request_evt(struct hci_dev *hdev,
 	 * initiators (connect_cfm_cb set) since then we always have the MITM
 	 * bit set. */
 	if (!conn->connect_cfm_cb && loc_mitm && conn->remote_cap == 0x03) {
-		BT_DBG("Rejecting request: remote device can't provide MITM");
+		bt_dbg("Rejecting request: remote device can't provide MITM");
 		hci_send_cmd(hdev, HCI_OP_USER_CONFIRM_NEG_REPLY,
 					sizeof(ev->bdaddr), &ev->bdaddr);
 		goto unlock;
@@ -2618,12 +2618,12 @@ static inline void hci_user_confirm_request_evt(struct hci_dev *hdev,
 		 * proceed from user space (mgmt_user_confirm with
 		 * confirm_hint set to 1). */
 		if (!test_bit(HCI_CONN_AUTH_PEND, &conn->pend)) {
-			BT_DBG("Confirming auto-accept as acceptor");
+			bt_dbg("Confirming auto-accept as acceptor");
 			confirm_hint = 1;
 			goto confirm;
 		}
 
-		BT_DBG("Auto-accept of user confirmation with %ums delay",
+		bt_dbg("Auto-accept of user confirmation with %ums delay",
 						hdev->auto_accept_delay);
 
 		if (hdev->auto_accept_delay > 0) {
@@ -2650,7 +2650,7 @@ static inline void hci_simple_pair_complete_evt(struct hci_dev *hdev, struct sk_
 	struct hci_ev_simple_pair_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2677,7 +2677,7 @@ static inline void hci_remote_host_features_evt(struct hci_dev *hdev, struct sk_
 	struct hci_ev_remote_host_features *ev = (void *) skb->data;
 	struct inquiry_entry *ie;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2694,7 +2694,7 @@ static inline void hci_remote_oob_data_request_evt(struct hci_dev *hdev,
 	struct hci_ev_remote_oob_data_request *ev = (void *) skb->data;
 	struct oob_data *data;
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2728,7 +2728,7 @@ static inline void hci_le_conn_complete_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_ev_le_conn_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	bt_dbg("%s status %d", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -2736,7 +2736,7 @@ static inline void hci_le_conn_complete_evt(struct hci_dev *hdev, struct sk_buff
 	if (!conn) {
 		conn = hci_conn_add(hdev, LE_LINK, &ev->bdaddr);
 		if (!conn) {
-			BT_ERR("No memory for new connection");
+			bt_err("No memory for new connection");
 			hci_dev_unlock(hdev);
 			return;
 		}
@@ -2795,7 +2795,7 @@ static inline void hci_le_ltk_request_evt(struct hci_dev *hdev,
 	struct hci_cp_le_ltk_reply cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s handle %d", hdev->name, cpu_to_le16(ev->handle));
+	bt_dbg("%s handle %d", hdev->name, cpu_to_le16(ev->handle));
 
 	hci_dev_lock(hdev);
 
@@ -2987,7 +2987,7 @@ void hci_event_packet(struct hci_dev *hdev, struct sk_buff *skb)
 		break;
 
 	default:
-		BT_DBG("%s event 0x%x", hdev->name, event);
+		bt_dbg("%s event 0x%x", hdev->name, event);
 		break;
 	}
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index ff02cf5..496f6b3 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -91,7 +91,7 @@ void hci_send_to_sock(struct hci_dev *hdev, struct sk_buff *skb,
 	struct sock *sk;
 	struct hlist_node *node;
 
-	BT_DBG("hdev %p len %d", hdev, skb->len);
+	bt_dbg("hdev %p len %d", hdev, skb->len);
 
 	read_lock(&hci_sk_list.lock);
 	sk_for_each(sk, node, &hci_sk_list.head) {
@@ -157,7 +157,7 @@ static int hci_sock_release(struct socket *sock)
 	struct sock *sk = sock->sk;
 	struct hci_dev *hdev;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	bt_dbg("sock %p sk %p", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -252,7 +252,7 @@ static int hci_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long a
 	void __user *argp = (void __user *) arg;
 	int err;
 
-	BT_DBG("cmd %x arg %lx", cmd, arg);
+	bt_dbg("cmd %x arg %lx", cmd, arg);
 
 	switch (cmd) {
 	case HCIGETDEVLIST:
@@ -314,7 +314,7 @@ static int hci_sock_bind(struct socket *sock, struct sockaddr *addr, int addr_le
 	struct hci_dev *hdev = NULL;
 	int len, err = 0;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	bt_dbg("sock %p sk %p", sock, sk);
 
 	if (!addr)
 		return -EINVAL;
@@ -364,7 +364,7 @@ static int hci_sock_getname(struct socket *sock, struct sockaddr *addr, int *add
 	struct sock *sk = sock->sk;
 	struct hci_dev *hdev = hci_pi(sk)->hdev;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	bt_dbg("sock %p sk %p", sock, sk);
 
 	if (!hdev)
 		return -EBADFD;
@@ -421,7 +421,7 @@ static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int copied, err;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	if (flags & (MSG_OOB))
 		return -EOPNOTSUPP;
@@ -459,7 +459,7 @@ static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int err;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	bt_dbg("sock %p sk %p", sock, sk);
 
 	if (msg->msg_flags & MSG_OOB)
 		return -EOPNOTSUPP;
@@ -553,7 +553,7 @@ static int hci_sock_setsockopt(struct socket *sock, int level, int optname, char
 	struct sock *sk = sock->sk;
 	int err = 0, opt = 0;
 
-	BT_DBG("sk %p, opt %d", sk, optname);
+	bt_dbg("sk %p, opt %d", sk, optname);
 
 	lock_sock(sk);
 
@@ -707,7 +707,7 @@ static int hci_sock_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	bt_dbg("sock %p", sock);
 
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
@@ -736,7 +736,7 @@ static int hci_sock_dev_event(struct notifier_block *this, unsigned long event,
 	struct hci_dev *hdev = (struct hci_dev *) ptr;
 	struct hci_ev_si_device ev;
 
-	BT_DBG("hdev %s event %ld", hdev->name, event);
+	bt_dbg("hdev %s event %ld", hdev->name, event);
 
 	/* Send event to sockets */
 	ev.event  = event;
@@ -793,12 +793,12 @@ int __init hci_sock_init(void)
 
 	hci_register_notifier(&hci_sock_nblock);
 
-	BT_INFO("HCI socket layer initialized");
+	bt_info("HCI socket layer initialized");
 
 	return 0;
 
 error:
-	BT_ERR("HCI socket registration failed");
+	bt_err("HCI socket registration failed");
 	proto_unregister(&hci_sk_proto);
 	return err;
 }
@@ -806,7 +806,7 @@ error:
 void hci_sock_cleanup(void)
 {
 	if (bt_sock_unregister(BTPROTO_HCI) < 0)
-		BT_ERR("HCI socket unregistration failed");
+		bt_err("HCI socket unregistration failed");
 
 	hci_unregister_notifier(&hci_sock_nblock);
 
diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index a6c3aa8..ae91be0 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -96,7 +96,7 @@ static void add_conn(struct work_struct *work)
 	dev_set_drvdata(&conn->dev, conn);
 
 	if (device_add(&conn->dev) < 0) {
-		BT_ERR("Failed to register connection device");
+		bt_err("Failed to register connection device");
 		return;
 	}
 
@@ -141,7 +141,7 @@ void hci_conn_init_sysfs(struct hci_conn *conn)
 {
 	struct hci_dev *hdev = conn->hdev;
 
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	conn->dev.type = &bt_link;
 	conn->dev.class = bt_class;
@@ -155,14 +155,14 @@ void hci_conn_init_sysfs(struct hci_conn *conn)
 
 void hci_conn_add_sysfs(struct hci_conn *conn)
 {
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	queue_work(conn->hdev->workqueue, &conn->work_add);
 }
 
 void hci_conn_del_sysfs(struct hci_conn *conn)
 {
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	queue_work(conn->hdev->workqueue, &conn->work_del);
 }
@@ -545,7 +545,7 @@ int hci_register_sysfs(struct hci_dev *hdev)
 	struct device *dev = &hdev->dev;
 	int err;
 
-	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
+	bt_dbg("%p name %s bus %d", hdev, hdev->name, hdev->bus);
 
 	dev->type = &bt_host;
 	dev->class = bt_class;
@@ -581,7 +581,7 @@ int hci_register_sysfs(struct hci_dev *hdev)
 
 void hci_unregister_sysfs(struct hci_dev *hdev)
 {
-	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
+	bt_dbg("%p name %s bus %d", hdev, hdev->name, hdev->bus);
 
 	debugfs_remove_recursive(hdev->debugfs);
 
diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index c405a95..01ae736 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -83,7 +83,7 @@ static struct hidp_session *__hidp_get_session(bdaddr_t *bdaddr)
 	struct hidp_session *session;
 	struct list_head *p;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	list_for_each(p, &hidp_session_list) {
 		session = list_entry(p, struct hidp_session, list);
@@ -145,7 +145,7 @@ static int hidp_queue_event(struct hidp_session *session, struct input_dev *dev,
 	unsigned char newleds;
 	struct sk_buff *skb;
 
-	BT_DBG("session %p type %d code %d value %d", session, type, code, value);
+	bt_dbg("session %p type %d code %d value %d", session, type, code, value);
 
 	if (type != EV_LED)
 		return -1;
@@ -163,7 +163,7 @@ static int hidp_queue_event(struct hidp_session *session, struct input_dev *dev,
 
 	skb = alloc_skb(3, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("Can't allocate memory for new frame");
+		bt_err("Can't allocate memory for new frame");
 		return -ENOMEM;
 	}
 
@@ -216,14 +216,14 @@ static void hidp_input_report(struct hidp_session *session, struct sk_buff *skb)
 				if (hidp_keycode[keys[i]])
 					input_report_key(dev, hidp_keycode[keys[i]], 0);
 				else
-					BT_ERR("Unknown key (scancode %#x) released.", keys[i]);
+					bt_err("Unknown key (scancode %#x) released.", keys[i]);
 			}
 
 			if (udata[i] > 3 && memscan(keys + 2, udata[i], 6) == keys + 8) {
 				if (hidp_keycode[udata[i]])
 					input_report_key(dev, hidp_keycode[udata[i]], 1);
 				else
-					BT_ERR("Unknown key (scancode %#x) pressed.", udata[i]);
+					bt_err("Unknown key (scancode %#x) pressed.", udata[i]);
 			}
 		}
 
@@ -253,11 +253,11 @@ static int __hidp_send_ctrl_message(struct hidp_session *session,
 {
 	struct sk_buff *skb;
 
-	BT_DBG("session %p data %p size %d", session, data, size);
+	bt_dbg("session %p data %p size %d", session, data, size);
 
 	skb = alloc_skb(size + 1, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("Can't allocate memory for new frame");
+		bt_err("Can't allocate memory for new frame");
 		return -ENOMEM;
 	}
 
@@ -287,11 +287,11 @@ static int hidp_queue_report(struct hidp_session *session,
 {
 	struct sk_buff *skb;
 
-	BT_DBG("session %p hid %p data %p size %d", session, session->hid, data, size);
+	bt_dbg("session %p hid %p data %p size %d", session, session->hid, data, size);
 
 	skb = alloc_skb(size + 1, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("Can't allocate memory for new frame");
+		bt_err("Can't allocate memory for new frame");
 		return -ENOMEM;
 	}
 
@@ -482,7 +482,7 @@ static inline void hidp_del_timer(struct hidp_session *session)
 static void hidp_process_handshake(struct hidp_session *session,
 					unsigned char param)
 {
-	BT_DBG("session %p param 0x%02x", session, param);
+	bt_dbg("session %p param 0x%02x", session, param);
 	session->output_report_success = 0; /* default condition */
 
 	switch (param) {
@@ -528,7 +528,7 @@ static void hidp_process_handshake(struct hidp_session *session,
 static void hidp_process_hid_control(struct hidp_session *session,
 					unsigned char param)
 {
-	BT_DBG("session %p param 0x%02x", session, param);
+	bt_dbg("session %p param 0x%02x", session, param);
 
 	if (param == HIDP_CTRL_VIRTUAL_CABLE_UNPLUG) {
 		/* Flush the transmit queues */
@@ -544,7 +544,7 @@ static int hidp_process_data(struct hidp_session *session, struct sk_buff *skb,
 				unsigned char param)
 {
 	int done_with_skb = 1;
-	BT_DBG("session %p skb %p len %d param 0x%02x", session, skb, skb->len, param);
+	bt_dbg("session %p skb %p len %d param 0x%02x", session, skb, skb->len, param);
 
 	switch (param) {
 	case HIDP_DATA_RTYPE_INPUT:
@@ -588,7 +588,7 @@ static void hidp_recv_ctrl_frame(struct hidp_session *session,
 	unsigned char hdr, type, param;
 	int free_skb = 1;
 
-	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
+	bt_dbg("session %p skb %p len %d", session, skb, skb->len);
 
 	hdr = skb->data[0];
 	skb_pull(skb, 1);
@@ -624,7 +624,7 @@ static void hidp_recv_intr_frame(struct hidp_session *session,
 {
 	unsigned char hdr;
 
-	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
+	bt_dbg("session %p skb %p len %d", session, skb, skb->len);
 
 	hdr = skb->data[0];
 	skb_pull(skb, 1);
@@ -637,10 +637,10 @@ static void hidp_recv_intr_frame(struct hidp_session *session,
 
 		if (session->hid) {
 			hid_input_report(session->hid, HID_INPUT_REPORT, skb->data, skb->len, 1);
-			BT_DBG("report len %d", skb->len);
+			bt_dbg("report len %d", skb->len);
 		}
 	} else {
-		BT_DBG("Unsupported protocol header 0x%02x", hdr);
+		bt_dbg("Unsupported protocol header 0x%02x", hdr);
 	}
 
 	kfree_skb(skb);
@@ -651,7 +651,7 @@ static int hidp_send_frame(struct socket *sock, unsigned char *data, int len)
 	struct kvec iv = { data, len };
 	struct msghdr msg;
 
-	BT_DBG("sock %p data %p len %d", sock, data, len);
+	bt_dbg("sock %p data %p len %d", sock, data, len);
 
 	if (!len)
 		return 0;
@@ -665,7 +665,7 @@ static void hidp_process_transmit(struct hidp_session *session)
 {
 	struct sk_buff *skb;
 
-	BT_DBG("session %p", session);
+	bt_dbg("session %p", session);
 
 	while ((skb = skb_dequeue(&session->ctrl_transmit))) {
 		if (hidp_send_frame(session->ctrl_sock, skb->data, skb->len) < 0) {
@@ -696,7 +696,7 @@ static int hidp_session(void *arg)
 	struct sk_buff *skb;
 	wait_queue_t ctrl_wait, intr_wait;
 
-	BT_DBG("session %p", session);
+	bt_dbg("session %p", session);
 
 	set_user_nice(current, -15);
 
@@ -957,7 +957,7 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	int vendor, product;
 	int err;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	if (bacmp(&bt_sk(ctrl_sock->sk)->src, &bt_sk(intr_sock->sk)->src) ||
 			bacmp(&bt_sk(ctrl_sock->sk)->dst, &bt_sk(intr_sock->sk)->dst))
@@ -967,7 +967,7 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	if (!session)
 		return -ENOMEM;
 
-	BT_DBG("rd_data %p rd_size %d", req->rd_data, req->rd_size);
+	bt_dbg("rd_data %p rd_size %d", req->rd_data, req->rd_size);
 
 	down_write(&hidp_session_sem);
 
@@ -984,7 +984,7 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	session->intr_mtu = min_t(uint, l2cap_pi(intr_sock->sk)->chan->omtu,
 					l2cap_pi(intr_sock->sk)->chan->imtu);
 
-	BT_DBG("ctrl mtu %d intr mtu %d", session->ctrl_mtu, session->intr_mtu);
+	bt_dbg("ctrl mtu %d intr mtu %d", session->ctrl_mtu, session->intr_mtu);
 
 	session->ctrl_sock = ctrl_sock;
 	session->intr_sock = intr_sock;
@@ -1097,7 +1097,7 @@ int hidp_del_connection(struct hidp_conndel_req *req)
 	struct hidp_session *session;
 	int err = 0;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	down_read(&hidp_session_sem);
 
@@ -1125,7 +1125,7 @@ int hidp_get_connlist(struct hidp_connlist_req *req)
 	struct list_head *p;
 	int err = 0, n = 0;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	down_read(&hidp_session_sem);
 
@@ -1184,7 +1184,7 @@ static int __init hidp_init(void)
 {
 	int ret;
 
-	BT_INFO("HIDP (Human Interface Emulation) ver %s", VERSION);
+	bt_info("HIDP (Human Interface Emulation) ver %s", VERSION);
 
 	ret = hid_register_driver(&hidp_driver);
 	if (ret)
diff --git a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
index 178ac7f..72fd7e5 100644
--- a/net/bluetooth/hidp/sock.c
+++ b/net/bluetooth/hidp/sock.c
@@ -43,7 +43,7 @@ static int hidp_sock_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	bt_dbg("sock %p sk %p", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -65,7 +65,7 @@ static int hidp_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long
 	struct socket *isock;
 	int err;
 
-	BT_DBG("cmd %x arg %lx", cmd, arg);
+	bt_dbg("cmd %x arg %lx", cmd, arg);
 
 	switch (cmd) {
 	case HIDPCONNADD:
@@ -247,7 +247,7 @@ static int hidp_sock_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	bt_dbg("sock %p", sock);
 
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
@@ -291,7 +291,7 @@ int __init hidp_init_sockets(void)
 	return 0;
 
 error:
-	BT_ERR("Can't register HIDP socket");
+	bt_err("Can't register HIDP socket");
 	proto_unregister(&hidp_proto);
 	return err;
 }
@@ -299,7 +299,7 @@ error:
 void __exit hidp_cleanup_sockets(void)
 {
 	if (bt_sock_unregister(BTPROTO_HIDP) < 0)
-		BT_ERR("Can't unregister HIDP socket");
+		bt_err("Can't unregister HIDP socket");
 
 	proto_unregister(&hidp_proto);
 }
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 2a27428..da9f254 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -223,7 +223,7 @@ static u16 l2cap_alloc_cid(struct l2cap_conn *conn)
 
 static void l2cap_set_timer(struct l2cap_chan *chan, struct timer_list *timer, long timeout)
 {
-       BT_DBG("chan %p state %d timeout %ld", chan->sk, chan->state, timeout);
+       bt_dbg("chan %p state %d timeout %ld", chan->sk, chan->state, timeout);
 
        if (!mod_timer(timer, jiffies + timeout))
 	       chan_hold(chan);
@@ -231,7 +231,7 @@ static void l2cap_set_timer(struct l2cap_chan *chan, struct timer_list *timer, l
 
 static void l2cap_clear_timer(struct l2cap_chan *chan, struct timer_list *timer)
 {
-       BT_DBG("chan %p state %d", chan, chan->state);
+       bt_dbg("chan %p state %d", chan, chan->state);
 
        if (timer_pending(timer) && del_timer(timer))
 	       chan_put(chan);
@@ -249,7 +249,7 @@ static void l2cap_chan_timeout(unsigned long arg)
 	struct sock *sk = chan->sk;
 	int reason;
 
-	BT_DBG("chan %p state %d", chan, chan->state);
+	bt_dbg("chan %p state %d", chan, chan->state);
 
 	bh_lock_sock(sk);
 
@@ -311,7 +311,7 @@ void l2cap_chan_destroy(struct l2cap_chan *chan)
 
 static void __l2cap_chan_add(struct l2cap_conn *conn, struct l2cap_chan *chan)
 {
-	BT_DBG("conn %p, psm 0x%2.2x, dcid 0x%4.4x", conn,
+	bt_dbg("conn %p, psm 0x%2.2x, dcid 0x%4.4x", conn,
 			chan->psm, chan->dcid);
 
 	conn->disc_reason = 0x13;
@@ -356,7 +356,7 @@ static void l2cap_chan_del(struct l2cap_chan *chan, int err)
 
 	__clear_chan_timer(chan);
 
-	BT_DBG("chan %p, conn %p, err %d", chan, conn, err);
+	bt_dbg("chan %p, conn %p, err %d", chan, conn, err);
 
 	if (conn) {
 		/* Delete from channel list */
@@ -408,7 +408,7 @@ static void l2cap_chan_cleanup_listen(struct sock *parent)
 {
 	struct sock *sk;
 
-	BT_DBG("parent %p", parent);
+	bt_dbg("parent %p", parent);
 
 	/* Close not yet accepted channels */
 	while ((sk = bt_accept_dequeue(parent, NULL))) {
@@ -426,7 +426,7 @@ void l2cap_chan_close(struct l2cap_chan *chan, int reason)
 	struct l2cap_conn *conn = chan->conn;
 	struct sock *sk = chan->sk;
 
-	BT_DBG("chan %p state %d socket %p", chan, chan->state, sk->sk_socket);
+	bt_dbg("chan %p state %d socket %p", chan, chan->state, sk->sk_socket);
 
 	switch (chan->state) {
 	case BT_LISTEN:
@@ -550,7 +550,7 @@ static void l2cap_send_cmd(struct l2cap_conn *conn, u8 ident, u8 code, u16 len,
 	struct sk_buff *skb = l2cap_build_cmd(conn, code, ident, len, data);
 	u8 flags;
 
-	BT_DBG("code 0x%2.2x", code);
+	bt_dbg("code 0x%2.2x", code);
 
 	if (!skb)
 		return;
@@ -579,7 +579,7 @@ static inline void l2cap_send_sframe(struct l2cap_chan *chan, u16 control)
 	if (chan->fcs == L2CAP_FCS_CRC16)
 		hlen += 2;
 
-	BT_DBG("chan %p, control 0x%2.2x", chan, control);
+	bt_dbg("chan %p, control 0x%2.2x", chan, control);
 
 	count = min_t(unsigned int, conn->mtu, hlen);
 	control |= L2CAP_CTRL_FRAME_TYPE;
@@ -713,7 +713,7 @@ static void l2cap_conn_start(struct l2cap_conn *conn)
 {
 	struct l2cap_chan *chan, *tmp;
 
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	read_lock(&conn->chan_lock);
 
@@ -839,7 +839,7 @@ static void l2cap_le_conn_ready(struct l2cap_conn *conn)
 	struct sock *parent, *sk;
 	struct l2cap_chan *chan, *pchan;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	/* Check if we have socket listening on cid */
 	pchan = l2cap_global_chan_by_scid(BT_LISTEN, L2CAP_CID_LE_DATA,
@@ -853,7 +853,7 @@ static void l2cap_le_conn_ready(struct l2cap_conn *conn)
 
 	/* Check for backlog size */
 	if (sk_acceptq_is_full(parent)) {
-		BT_DBG("backlog full %d", parent->sk_ack_backlog);
+		bt_dbg("backlog full %d", parent->sk_ack_backlog);
 		goto clean;
 	}
 
@@ -890,7 +890,7 @@ static void l2cap_chan_ready(struct sock *sk)
 	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
 	struct sock *parent = bt_sk(sk)->parent;
 
-	BT_DBG("sk %p, parent %p", sk, parent);
+	bt_dbg("sk %p, parent %p", sk, parent);
 
 	chan->conf_state = 0;
 	__clear_chan_timer(chan);
@@ -906,7 +906,7 @@ static void l2cap_conn_ready(struct l2cap_conn *conn)
 {
 	struct l2cap_chan *chan;
 
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	if (!conn->hcon->out && conn->hcon->type == LE_LINK)
 		l2cap_le_conn_ready(conn);
@@ -941,7 +941,7 @@ static void l2cap_conn_unreliable(struct l2cap_conn *conn, int err)
 {
 	struct l2cap_chan *chan;
 
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	read_lock(&conn->chan_lock);
 
@@ -974,7 +974,7 @@ static void l2cap_conn_del(struct hci_conn *hcon, int err)
 	if (!conn)
 		return;
 
-	BT_DBG("hcon %p conn %p, err %d", hcon, conn, err);
+	bt_dbg("hcon %p conn %p, err %d", hcon, conn, err);
 
 	kfree_skb(conn->rx_skb);
 
@@ -1018,7 +1018,7 @@ static struct l2cap_conn *l2cap_conn_add(struct hci_conn *hcon, u8 status)
 	hcon->l2cap_data = conn;
 	conn->hcon = hcon;
 
-	BT_DBG("hcon %p conn %p", hcon, conn);
+	bt_dbg("hcon %p conn %p", hcon, conn);
 
 	if (hcon->hdev->le_mtu && hcon->type == LE_LINK)
 		conn->mtu = hcon->hdev->le_mtu;
@@ -1100,7 +1100,7 @@ int l2cap_chan_connect(struct l2cap_chan *chan)
 	__u8 auth_type;
 	int err;
 
-	BT_DBG("%s -> %s psm 0x%2.2x", batostr(src), batostr(dst),
+	bt_dbg("%s -> %s psm 0x%2.2x", batostr(src), batostr(dst),
 							chan->psm);
 
 	hdev = hci_get_route(dst, src);
@@ -1192,7 +1192,7 @@ static void l2cap_monitor_timeout(unsigned long arg)
 	struct l2cap_chan *chan = (void *) arg;
 	struct sock *sk = chan->sk;
 
-	BT_DBG("chan %p", chan);
+	bt_dbg("chan %p", chan);
 
 	bh_lock_sock(sk);
 	if (chan->retry_count >= chan->remote_max_tx) {
@@ -1213,7 +1213,7 @@ static void l2cap_retrans_timeout(unsigned long arg)
 	struct l2cap_chan *chan = (void *) arg;
 	struct sock *sk = chan->sk;
 
-	BT_DBG("chan %p", chan);
+	bt_dbg("chan %p", chan);
 
 	bh_lock_sock(sk);
 	chan->retry_count = 1;
@@ -1249,7 +1249,7 @@ void l2cap_do_send(struct l2cap_chan *chan, struct sk_buff *skb)
 	struct hci_conn *hcon = chan->conn->hcon;
 	u16 flags;
 
-	BT_DBG("chan %p, skb %p len %d", chan, skb, skb->len);
+	bt_dbg("chan %p, skb %p len %d", chan, skb, skb->len);
 
 	if (!chan->flushable && lmp_no_flush_capable(hcon->hdev))
 		flags = ACL_START_NO_FLUSH;
@@ -1472,7 +1472,7 @@ struct sk_buff *l2cap_create_connless_pdu(struct l2cap_chan *chan, struct msghdr
 	int err, count, hlen = L2CAP_HDR_SIZE + 2;
 	struct l2cap_hdr *lh;
 
-	BT_DBG("sk %p len %d", sk, (int)len);
+	bt_dbg("sk %p len %d", sk, (int)len);
 
 	count = min_t(unsigned int, (conn->mtu - hlen), len);
 	skb = bt_skb_send_alloc(sk, count + hlen,
@@ -1502,7 +1502,7 @@ struct sk_buff *l2cap_create_basic_pdu(struct l2cap_chan *chan, struct msghdr *m
 	int err, count, hlen = L2CAP_HDR_SIZE;
 	struct l2cap_hdr *lh;
 
-	BT_DBG("sk %p len %d", sk, (int)len);
+	bt_dbg("sk %p len %d", sk, (int)len);
 
 	count = min_t(unsigned int, (conn->mtu - hlen), len);
 	skb = bt_skb_send_alloc(sk, count + hlen,
@@ -1531,7 +1531,7 @@ struct sk_buff *l2cap_create_iframe_pdu(struct l2cap_chan *chan, struct msghdr *
 	int err, count, hlen = L2CAP_HDR_SIZE + 2;
 	struct l2cap_hdr *lh;
 
-	BT_DBG("sk %p len %d", sk, (int)len);
+	bt_dbg("sk %p len %d", sk, (int)len);
 
 	if (!conn)
 		return ERR_PTR(-ENOTCONN);
@@ -1686,7 +1686,7 @@ int l2cap_chan_send(struct l2cap_chan *chan, struct msghdr *msg, size_t len)
 		break;
 
 	default:
-		BT_DBG("bad state %1.1x", chan->mode);
+		bt_dbg("bad state %1.1x", chan->mode);
 		err = -EBADFD;
 	}
 
@@ -1699,7 +1699,7 @@ static void l2cap_raw_recv(struct l2cap_conn *conn, struct sk_buff *skb)
 	struct sk_buff *nskb;
 	struct l2cap_chan *chan;
 
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	read_lock(&conn->chan_lock);
 	list_for_each_entry(chan, &conn->chan_l, list) {
@@ -1729,7 +1729,7 @@ static struct sk_buff *l2cap_build_cmd(struct l2cap_conn *conn,
 	struct l2cap_hdr *lh;
 	int len, count;
 
-	BT_DBG("conn %p, code 0x%2.2x, ident 0x%2.2x, len %d",
+	bt_dbg("conn %p, code 0x%2.2x, ident 0x%2.2x, len %d",
 			conn, code, ident, dlen);
 
 	len = L2CAP_HDR_SIZE + L2CAP_CMD_HDR_SIZE + dlen;
@@ -1813,7 +1813,7 @@ static inline int l2cap_get_conf_opt(void **ptr, int *type, int *olen, unsigned
 		break;
 	}
 
-	BT_DBG("type 0x%2.2x len %d val 0x%lx", *type, opt->len, *val);
+	bt_dbg("type 0x%2.2x len %d val 0x%lx", *type, opt->len, *val);
 	return len;
 }
 
@@ -1821,7 +1821,7 @@ static void l2cap_add_conf_opt(void **ptr, u8 type, u8 len, unsigned long val)
 {
 	struct l2cap_conf_opt *opt = *ptr;
 
-	BT_DBG("type 0x%2.2x len %d val 0x%lx", type, len, val);
+	bt_dbg("type 0x%2.2x len %d val 0x%lx", type, len, val);
 
 	opt->type = type;
 	opt->len  = len;
@@ -1901,7 +1901,7 @@ static int l2cap_build_conf_req(struct l2cap_chan *chan, void *data)
 	struct l2cap_conf_rfc rfc = { .mode = chan->mode };
 	void *ptr = req->data;
 
-	BT_DBG("chan %p", chan);
+	bt_dbg("chan %p", chan);
 
 	if (chan->num_conf_req || chan->num_conf_rsp)
 		goto done;
@@ -2004,7 +2004,7 @@ static int l2cap_parse_conf_req(struct l2cap_chan *chan, void *data)
 	u16 mtu = L2CAP_DEFAULT_MTU;
 	u16 result = L2CAP_CONF_SUCCESS;
 
-	BT_DBG("chan %p", chan);
+	bt_dbg("chan %p", chan);
 
 	while (len >= L2CAP_CONF_OPT_SIZE) {
 		len -= l2cap_get_conf_opt(&req, &type, &olen, &val);
@@ -2153,7 +2153,7 @@ static int l2cap_parse_conf_rsp(struct l2cap_chan *chan, void *rsp, int len, voi
 	unsigned long val;
 	struct l2cap_conf_rfc rfc;
 
-	BT_DBG("chan %p, rsp %p, len %d, req %p", chan, rsp, len, data);
+	bt_dbg("chan %p, rsp %p, len %d, req %p", chan, rsp, len, data);
 
 	while (len >= L2CAP_CONF_OPT_SIZE) {
 		len -= l2cap_get_conf_opt(&rsp, &type, &olen, &val);
@@ -2218,7 +2218,7 @@ static int l2cap_build_conf_rsp(struct l2cap_chan *chan, void *data, u16 result,
 	struct l2cap_conf_rsp *rsp = data;
 	void *ptr = rsp->data;
 
-	BT_DBG("chan %p", chan);
+	bt_dbg("chan %p", chan);
 
 	rsp->scid   = cpu_to_le16(chan->dcid);
 	rsp->result = cpu_to_le16(result);
@@ -2254,7 +2254,7 @@ static void l2cap_conf_rfc_get(struct l2cap_chan *chan, void *rsp, int len)
 	unsigned long val;
 	struct l2cap_conf_rfc rfc;
 
-	BT_DBG("chan %p, rsp %p, len %d", chan, rsp, len);
+	bt_dbg("chan %p, rsp %p, len %d", chan, rsp, len);
 
 	if ((chan->mode != L2CAP_MODE_ERTM) && (chan->mode != L2CAP_MODE_STREAMING))
 		return;
@@ -2313,7 +2313,7 @@ static inline int l2cap_connect_req(struct l2cap_conn *conn, struct l2cap_cmd_hd
 	u16 dcid = 0, scid = __le16_to_cpu(req->scid);
 	__le16 psm = req->psm;
 
-	BT_DBG("psm 0x%2.2x scid 0x%4.4x", psm, scid);
+	bt_dbg("psm 0x%2.2x scid 0x%4.4x", psm, scid);
 
 	/* Check if we have socket listening on psm */
 	pchan = l2cap_global_chan_by_psm(BT_LISTEN, psm, conn->src);
@@ -2338,7 +2338,7 @@ static inline int l2cap_connect_req(struct l2cap_conn *conn, struct l2cap_cmd_hd
 
 	/* Check for backlog size */
 	if (sk_acceptq_is_full(parent)) {
-		BT_DBG("backlog full %d", parent->sk_ack_backlog);
+		bt_dbg("backlog full %d", parent->sk_ack_backlog);
 		goto response;
 	}
 
@@ -2449,7 +2449,7 @@ static inline int l2cap_connect_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hd
 	result = __le16_to_cpu(rsp->result);
 	status = __le16_to_cpu(rsp->status);
 
-	BT_DBG("dcid 0x%4.4x scid 0x%4.4x result 0x%2.2x status 0x%2.2x", dcid, scid, result, status);
+	bt_dbg("dcid 0x%4.4x scid 0x%4.4x result 0x%2.2x status 0x%2.2x", dcid, scid, result, status);
 
 	if (scid) {
 		chan = l2cap_get_chan_by_scid(conn, scid);
@@ -2522,7 +2522,7 @@ static inline int l2cap_config_req(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 	dcid  = __le16_to_cpu(req->dcid);
 	flags = __le16_to_cpu(req->flags);
 
-	BT_DBG("dcid 0x%4.4x flags 0x%2.2x", dcid, flags);
+	bt_dbg("dcid 0x%4.4x flags 0x%2.2x", dcid, flags);
 
 	chan = l2cap_get_chan_by_scid(conn, dcid);
 	if (!chan)
@@ -2615,7 +2615,7 @@ static inline int l2cap_config_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 	flags  = __le16_to_cpu(rsp->flags);
 	result = __le16_to_cpu(rsp->result);
 
-	BT_DBG("scid 0x%4.4x flags 0x%2.2x result 0x%2.2x",
+	bt_dbg("scid 0x%4.4x flags 0x%2.2x result 0x%2.2x",
 			scid, flags, result);
 
 	chan = l2cap_get_chan_by_scid(conn, scid);
@@ -2696,7 +2696,7 @@ static inline int l2cap_disconnect_req(struct l2cap_conn *conn, struct l2cap_cmd
 	scid = __le16_to_cpu(req->scid);
 	dcid = __le16_to_cpu(req->dcid);
 
-	BT_DBG("scid 0x%4.4x dcid 0x%4.4x", scid, dcid);
+	bt_dbg("scid 0x%4.4x dcid 0x%4.4x", scid, dcid);
 
 	chan = l2cap_get_chan_by_scid(conn, dcid);
 	if (!chan)
@@ -2736,7 +2736,7 @@ static inline int l2cap_disconnect_rsp(struct l2cap_conn *conn, struct l2cap_cmd
 	scid = __le16_to_cpu(rsp->scid);
 	dcid = __le16_to_cpu(rsp->dcid);
 
-	BT_DBG("dcid 0x%4.4x scid 0x%4.4x", dcid, scid);
+	bt_dbg("dcid 0x%4.4x scid 0x%4.4x", dcid, scid);
 
 	chan = l2cap_get_chan_by_scid(conn, scid);
 	if (!chan)
@@ -2767,7 +2767,7 @@ static inline int l2cap_information_req(struct l2cap_conn *conn, struct l2cap_cm
 
 	type = __le16_to_cpu(req->type);
 
-	BT_DBG("type 0x%4.4x", type);
+	bt_dbg("type 0x%4.4x", type);
 
 	if (type == L2CAP_IT_FEAT_MASK) {
 		u8 buf[8];
@@ -2808,7 +2808,7 @@ static inline int l2cap_information_rsp(struct l2cap_conn *conn, struct l2cap_cm
 	type   = __le16_to_cpu(rsp->type);
 	result = __le16_to_cpu(rsp->result);
 
-	BT_DBG("type 0x%4.4x result 0x%2.2x", type, result);
+	bt_dbg("type 0x%4.4x result 0x%2.2x", type, result);
 
 	/* L2CAP Info req/rsp are unbound to channels, add extra checks */
 	if (cmd->ident != conn->info_ident ||
@@ -2896,7 +2896,7 @@ static inline int l2cap_conn_param_update_req(struct l2cap_conn *conn,
 	latency		= __le16_to_cpu(req->latency);
 	to_multiplier	= __le16_to_cpu(req->to_multiplier);
 
-	BT_DBG("min 0x%4.4x max 0x%4.4x latency: 0x%4.4x Timeout: 0x%4.4x",
+	bt_dbg("min 0x%4.4x max 0x%4.4x latency: 0x%4.4x Timeout: 0x%4.4x",
 						min, max, latency, to_multiplier);
 
 	memset(&rsp, 0, sizeof(rsp));
@@ -2966,7 +2966,7 @@ static inline int l2cap_bredr_sig_cmd(struct l2cap_conn *conn,
 		break;
 
 	default:
-		BT_ERR("Unknown BR/EDR signaling command 0x%2.2x", cmd->code);
+		bt_err("Unknown BR/EDR signaling command 0x%2.2x", cmd->code);
 		err = -EINVAL;
 		break;
 	}
@@ -2988,7 +2988,7 @@ static inline int l2cap_le_sig_cmd(struct l2cap_conn *conn,
 		return 0;
 
 	default:
-		BT_ERR("Unknown LE signaling command 0x%2.2x", cmd->code);
+		bt_err("Unknown LE signaling command 0x%2.2x", cmd->code);
 		return -EINVAL;
 	}
 }
@@ -3011,10 +3011,10 @@ static inline void l2cap_sig_channel(struct l2cap_conn *conn,
 
 		cmd_len = le16_to_cpu(cmd.len);
 
-		BT_DBG("code 0x%2.2x len %d id 0x%2.2x", cmd.code, cmd_len, cmd.ident);
+		bt_dbg("code 0x%2.2x len %d id 0x%2.2x", cmd.code, cmd_len, cmd.ident);
 
 		if (cmd_len > len || !cmd.ident) {
-			BT_DBG("corrupted command");
+			bt_dbg("corrupted command");
 			break;
 		}
 
@@ -3026,7 +3026,7 @@ static inline void l2cap_sig_channel(struct l2cap_conn *conn,
 		if (err) {
 			struct l2cap_cmd_rej rej;
 
-			BT_ERR("Wrong link type (%d)", err);
+			bt_err("Wrong link type (%d)", err);
 
 			/* FIXME: Map err to a valid reason */
 			rej.reason = cpu_to_le16(0);
@@ -3261,7 +3261,7 @@ done:
 	clear_bit(CONN_LOCAL_BUSY, &chan->conn_state);
 	clear_bit(CONN_RNR_SENT, &chan->conn_state);
 
-	BT_DBG("chan %p, Exit local busy", chan);
+	bt_dbg("chan %p, Exit local busy", chan);
 
 	return 0;
 }
@@ -3332,7 +3332,7 @@ static int l2cap_push_rx_skb(struct l2cap_chan *chan, struct sk_buff *skb, u16 c
 	}
 
 	/* Busy Condition */
-	BT_DBG("chan %p, Enter local busy", chan);
+	bt_dbg("chan %p, Enter local busy", chan);
 
 	set_bit(CONN_LOCAL_BUSY, &chan->conn_state);
 	bt_cb(skb)->sar = control >> L2CAP_CTRL_SAR_SHIFT;
@@ -3508,7 +3508,7 @@ static inline int l2cap_data_channel_iframe(struct l2cap_chan *chan, u16 rx_cont
 	int num_to_ack = (chan->tx_win/6) + 1;
 	int err = 0;
 
-	BT_DBG("chan %p len %d tx_seq %d rx_control 0x%4.4x", chan, skb->len,
+	bt_dbg("chan %p len %d tx_seq %d rx_control 0x%4.4x", chan, skb->len,
 							tx_seq, rx_control);
 
 	if (L2CAP_CTRL_FINAL & rx_control &&
@@ -3554,7 +3554,7 @@ static inline int l2cap_data_channel_iframe(struct l2cap_chan *chan, u16 rx_cont
 				chan->buffer_seq = chan->buffer_seq_srej;
 				clear_bit(CONN_SREJ_SENT, &chan->conn_state);
 				l2cap_send_ack(chan);
-				BT_DBG("chan %p, Exit SREJ_SENT", chan);
+				bt_dbg("chan %p, Exit SREJ_SENT", chan);
 			}
 		} else {
 			struct srej_list *l;
@@ -3583,7 +3583,7 @@ static inline int l2cap_data_channel_iframe(struct l2cap_chan *chan, u16 rx_cont
 
 		set_bit(CONN_SREJ_SENT, &chan->conn_state);
 
-		BT_DBG("chan %p, Enter SREJ", chan);
+		bt_dbg("chan %p, Enter SREJ", chan);
 
 		INIT_LIST_HEAD(&chan->srej_l);
 		chan->buffer_seq_srej = chan->buffer_seq;
@@ -3634,7 +3634,7 @@ drop:
 
 static inline void l2cap_data_channel_rrframe(struct l2cap_chan *chan, u16 rx_control)
 {
-	BT_DBG("chan %p, req_seq %d ctrl 0x%4.4x", chan, __get_reqseq(rx_control),
+	bt_dbg("chan %p, req_seq %d ctrl 0x%4.4x", chan, __get_reqseq(rx_control),
 						rx_control);
 
 	chan->expected_ack_seq = __get_reqseq(rx_control);
@@ -3676,7 +3676,7 @@ static inline void l2cap_data_channel_rejframe(struct l2cap_chan *chan, u16 rx_c
 {
 	u8 tx_seq = __get_reqseq(rx_control);
 
-	BT_DBG("chan %p, req_seq %d ctrl 0x%4.4x", chan, tx_seq, rx_control);
+	bt_dbg("chan %p, req_seq %d ctrl 0x%4.4x", chan, tx_seq, rx_control);
 
 	clear_bit(CONN_REMOTE_BUSY, &chan->conn_state);
 
@@ -3697,7 +3697,7 @@ static inline void l2cap_data_channel_srejframe(struct l2cap_chan *chan, u16 rx_
 {
 	u8 tx_seq = __get_reqseq(rx_control);
 
-	BT_DBG("chan %p, req_seq %d ctrl 0x%4.4x", chan, tx_seq, rx_control);
+	bt_dbg("chan %p, req_seq %d ctrl 0x%4.4x", chan, tx_seq, rx_control);
 
 	clear_bit(CONN_REMOTE_BUSY, &chan->conn_state);
 
@@ -3733,7 +3733,7 @@ static inline void l2cap_data_channel_rnrframe(struct l2cap_chan *chan, u16 rx_c
 {
 	u8 tx_seq = __get_reqseq(rx_control);
 
-	BT_DBG("chan %p, req_seq %d ctrl 0x%4.4x", chan, tx_seq, rx_control);
+	bt_dbg("chan %p, req_seq %d ctrl 0x%4.4x", chan, tx_seq, rx_control);
 
 	set_bit(CONN_REMOTE_BUSY, &chan->conn_state);
 	chan->expected_ack_seq = tx_seq;
@@ -3757,7 +3757,7 @@ static inline void l2cap_data_channel_rnrframe(struct l2cap_chan *chan, u16 rx_c
 
 static inline int l2cap_data_channel_sframe(struct l2cap_chan *chan, u16 rx_control, struct sk_buff *skb)
 {
-	BT_DBG("chan %p rx_control 0x%4.4x len %d", chan, rx_control, skb->len);
+	bt_dbg("chan %p rx_control 0x%4.4x len %d", chan, rx_control, skb->len);
 
 	if (L2CAP_CTRL_FINAL & rx_control &&
 			test_bit(CONN_WAIT_F, &chan->conn_state)) {
@@ -3844,7 +3844,7 @@ static int l2cap_ertm_data_rcv(struct sock *sk, struct sk_buff *skb)
 		l2cap_data_channel_iframe(chan, control, skb);
 	} else {
 		if (len != 0) {
-			BT_ERR("%d", len);
+			bt_err("%d", len);
 			l2cap_send_disconn_req(chan->conn, chan, ECONNRESET);
 			goto drop;
 		}
@@ -3869,13 +3869,13 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 
 	chan = l2cap_get_chan_by_scid(conn, cid);
 	if (!chan) {
-		BT_DBG("unknown cid 0x%4.4x", cid);
+		bt_dbg("unknown cid 0x%4.4x", cid);
 		goto drop;
 	}
 
 	sk = chan->sk;
 
-	BT_DBG("chan %p, len %d", chan, skb->len);
+	bt_dbg("chan %p, len %d", chan, skb->len);
 
 	if (chan->state != BT_CONNECTED)
 		goto drop;
@@ -3933,7 +3933,7 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 		goto done;
 
 	default:
-		BT_DBG("chan %p: bad mode 0x%2.2x", chan, chan->mode);
+		bt_dbg("chan %p: bad mode 0x%2.2x", chan, chan->mode);
 		break;
 	}
 
@@ -3960,7 +3960,7 @@ static inline int l2cap_conless_channel(struct l2cap_conn *conn, __le16 psm, str
 
 	bh_lock_sock(sk);
 
-	BT_DBG("sk %p, len %d", sk, skb->len);
+	bt_dbg("sk %p, len %d", sk, skb->len);
 
 	if (chan->state != BT_BOUND && chan->state != BT_CONNECTED)
 		goto drop;
@@ -3993,7 +3993,7 @@ static inline int l2cap_att_channel(struct l2cap_conn *conn, __le16 cid, struct
 
 	bh_lock_sock(sk);
 
-	BT_DBG("sk %p, len %d", sk, skb->len);
+	bt_dbg("sk %p, len %d", sk, skb->len);
 
 	if (chan->state != BT_BOUND && chan->state != BT_CONNECTED)
 		goto drop;
@@ -4028,7 +4028,7 @@ static void l2cap_recv_frame(struct l2cap_conn *conn, struct sk_buff *skb)
 		return;
 	}
 
-	BT_DBG("len %d, cid 0x%4.4x", len, cid);
+	bt_dbg("len %d, cid 0x%4.4x", len, cid);
 
 	switch (cid) {
 	case L2CAP_CID_LE_SIGNALING:
@@ -4067,7 +4067,7 @@ static int l2cap_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr, u8 type)
 	if (type != ACL_LINK)
 		return -EINVAL;
 
-	BT_DBG("hdev %s, bdaddr %s", hdev->name, batostr(bdaddr));
+	bt_dbg("hdev %s, bdaddr %s", hdev->name, batostr(bdaddr));
 
 	/* Find listening sockets and check their link_mode */
 	read_lock(&chan_list_lock);
@@ -4097,7 +4097,7 @@ static int l2cap_connect_cfm(struct hci_conn *hcon, u8 status)
 {
 	struct l2cap_conn *conn;
 
-	BT_DBG("hcon %p bdaddr %s status %d", hcon, batostr(&hcon->dst), status);
+	bt_dbg("hcon %p bdaddr %s status %d", hcon, batostr(&hcon->dst), status);
 
 	if (!(hcon->type == ACL_LINK || hcon->type == LE_LINK))
 		return -EINVAL;
@@ -4116,7 +4116,7 @@ static int l2cap_disconn_ind(struct hci_conn *hcon)
 {
 	struct l2cap_conn *conn = hcon->l2cap_data;
 
-	BT_DBG("hcon %p", hcon);
+	bt_dbg("hcon %p", hcon);
 
 	if ((hcon->type != ACL_LINK && hcon->type != LE_LINK) || !conn)
 		return 0x13;
@@ -4126,7 +4126,7 @@ static int l2cap_disconn_ind(struct hci_conn *hcon)
 
 static int l2cap_disconn_cfm(struct hci_conn *hcon, u8 reason)
 {
-	BT_DBG("hcon %p reason %d", hcon, reason);
+	bt_dbg("hcon %p reason %d", hcon, reason);
 
 	if (!(hcon->type == ACL_LINK || hcon->type == LE_LINK))
 		return -EINVAL;
@@ -4161,7 +4161,7 @@ static int l2cap_security_cfm(struct hci_conn *hcon, u8 status, u8 encrypt)
 	if (!conn)
 		return 0;
 
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	read_lock(&conn->chan_lock);
 
@@ -4170,7 +4170,7 @@ static int l2cap_security_cfm(struct hci_conn *hcon, u8 status, u8 encrypt)
 
 		bh_lock_sock(sk);
 
-		BT_DBG("chan->scid %d", chan->scid);
+		bt_dbg("chan->scid %d", chan->scid);
 
 		if (chan->scid == L2CAP_CID_LE_DATA) {
 			if (!status && encrypt) {
@@ -4258,7 +4258,7 @@ static int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 fl
 	if (!conn)
 		goto drop;
 
-	BT_DBG("conn %p len %d flags 0x%x", conn, skb->len, flags);
+	bt_dbg("conn %p len %d flags 0x%x", conn, skb->len, flags);
 
 	if (!(flags & ACL_CONT)) {
 		struct l2cap_hdr *hdr;
@@ -4267,7 +4267,7 @@ static int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 fl
 		int len;
 
 		if (conn->rx_len) {
-			BT_ERR("Unexpected start frame (len %d)", skb->len);
+			bt_err("Unexpected start frame (len %d)", skb->len);
 			kfree_skb(conn->rx_skb);
 			conn->rx_skb = NULL;
 			conn->rx_len = 0;
@@ -4276,7 +4276,7 @@ static int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 fl
 
 		/* Start fragment always begin with Basic L2CAP header */
 		if (skb->len < L2CAP_HDR_SIZE) {
-			BT_ERR("Frame is too short (len %d)", skb->len);
+			bt_err("Frame is too short (len %d)", skb->len);
 			l2cap_conn_unreliable(conn, ECOMM);
 			goto drop;
 		}
@@ -4291,10 +4291,10 @@ static int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 fl
 			return 0;
 		}
 
-		BT_DBG("Start: total len %d, frag len %d", len, skb->len);
+		bt_dbg("Start: total len %d, frag len %d", len, skb->len);
 
 		if (skb->len > len) {
-			BT_ERR("Frame is too long (len %d, expected len %d)",
+			bt_err("Frame is too long (len %d, expected len %d)",
 				skb->len, len);
 			l2cap_conn_unreliable(conn, ECOMM);
 			goto drop;
@@ -4306,7 +4306,7 @@ static int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 fl
 			struct sock *sk = chan->sk;
 
 			if (chan->imtu < len - L2CAP_HDR_SIZE) {
-				BT_ERR("Frame exceeding recv MTU (len %d, "
+				bt_err("Frame exceeding recv MTU (len %d, "
 							"MTU %d)", len,
 							chan->imtu);
 				bh_unlock_sock(sk);
@@ -4325,16 +4325,16 @@ static int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 fl
 								skb->len);
 		conn->rx_len = len - skb->len;
 	} else {
-		BT_DBG("Cont: frag len %d (expecting %d)", skb->len, conn->rx_len);
+		bt_dbg("Cont: frag len %d (expecting %d)", skb->len, conn->rx_len);
 
 		if (!conn->rx_len) {
-			BT_ERR("Unexpected continuation frame (len %d)", skb->len);
+			bt_err("Unexpected continuation frame (len %d)", skb->len);
 			l2cap_conn_unreliable(conn, ECOMM);
 			goto drop;
 		}
 
 		if (skb->len > conn->rx_len) {
-			BT_ERR("Fragment is too long (len %d, expected %d)",
+			bt_err("Fragment is too long (len %d, expected %d)",
 					skb->len, conn->rx_len);
 			kfree_skb(conn->rx_skb);
 			conn->rx_skb = NULL;
@@ -4422,7 +4422,7 @@ int __init l2cap_init(void)
 
 	err = hci_register_proto(&l2cap_hci_proto);
 	if (err < 0) {
-		BT_ERR("L2CAP protocol registration failed");
+		bt_err("L2CAP protocol registration failed");
 		bt_sock_unregister(BTPROTO_L2CAP);
 		goto error;
 	}
@@ -4431,7 +4431,7 @@ int __init l2cap_init(void)
 		l2cap_debugfs = debugfs_create_file("l2cap", 0444,
 					bt_debugfs, NULL, &l2cap_debugfs_fops);
 		if (!l2cap_debugfs)
-			BT_ERR("Failed to create L2CAP debug file");
+			bt_err("Failed to create L2CAP debug file");
 	}
 
 	return 0;
@@ -4450,7 +4450,7 @@ void l2cap_exit(void)
 	destroy_workqueue(_busy_wq);
 
 	if (hci_unregister_proto(&l2cap_hci_proto) < 0)
-		BT_ERR("L2CAP protocol unregistration failed");
+		bt_err("L2CAP protocol unregistration failed");
 
 	l2cap_cleanup_sockets();
 }
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 39082d4..bc31d62 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -42,7 +42,7 @@ static int l2cap_sock_bind(struct socket *sock, struct sockaddr *addr, int alen)
 	struct sockaddr_l2 la;
 	int len, err = 0;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (!addr || addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
@@ -106,7 +106,7 @@ static int l2cap_sock_connect(struct socket *sock, struct sockaddr *addr, int al
 	struct sockaddr_l2 la;
 	int len, err = 0;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (!addr || alen < sizeof(addr->sa_family) ||
 	    addr->sa_family != AF_BLUETOOTH)
@@ -192,7 +192,7 @@ static int l2cap_sock_listen(struct socket *sock, int backlog)
 	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
 	int err = 0;
 
-	BT_DBG("sk %p backlog %d", sk, backlog);
+	bt_dbg("sk %p backlog %d", sk, backlog);
 
 	lock_sock(sk);
 
@@ -242,7 +242,7 @@ static int l2cap_sock_accept(struct socket *sock, struct socket *newsock, int fl
 
 	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
 
-	BT_DBG("sk %p timeo %ld", sk, timeo);
+	bt_dbg("sk %p timeo %ld", sk, timeo);
 
 	/* Wait for an incoming connection. (wake-one). */
 	add_wait_queue_exclusive(sk_sleep(sk), &wait);
@@ -275,7 +275,7 @@ static int l2cap_sock_accept(struct socket *sock, struct socket *newsock, int fl
 
 	newsock->state = SS_CONNECTED;
 
-	BT_DBG("new socket %p", nsk);
+	bt_dbg("new socket %p", nsk);
 
 done:
 	release_sock(sk);
@@ -288,7 +288,7 @@ static int l2cap_sock_getname(struct socket *sock, struct sockaddr *addr, int *l
 	struct sock *sk = sock->sk;
 	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	addr->sa_family = AF_BLUETOOTH;
 	*len = sizeof(struct sockaddr_l2);
@@ -315,7 +315,7 @@ static int l2cap_sock_getsockopt_old(struct socket *sock, int optname, char __us
 	int len, err = 0;
 	u32 opt;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (get_user(len, optlen))
 		return -EFAULT;
@@ -401,7 +401,7 @@ static int l2cap_sock_getsockopt(struct socket *sock, int level, int optname, ch
 	struct bt_power pwr;
 	int len, err = 0;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (level == SOL_L2CAP)
 		return l2cap_sock_getsockopt_old(sock, optname, optval, optlen);
@@ -479,7 +479,7 @@ static int l2cap_sock_setsockopt_old(struct socket *sock, int optname, char __us
 	int len, err = 0;
 	u32 opt;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	lock_sock(sk);
 
@@ -567,7 +567,7 @@ static int l2cap_sock_setsockopt(struct socket *sock, int level, int optname, ch
 	int len, err = 0;
 	u32 opt;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (level == SOL_L2CAP)
 		return l2cap_sock_setsockopt_old(sock, optname, optval, optlen);
@@ -686,7 +686,7 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct ms
 	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
 	int err;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	err = sock_error(sk);
 	if (err)
@@ -738,7 +738,7 @@ static void l2cap_sock_kill(struct sock *sk)
 	if (!sock_flag(sk, SOCK_ZAPPED) || sk->sk_socket)
 		return;
 
-	BT_DBG("sk %p state %d", sk, sk->sk_state);
+	bt_dbg("sk %p state %d", sk, sk->sk_state);
 
 	/* Kill poor orphan */
 
@@ -753,7 +753,7 @@ static int l2cap_sock_shutdown(struct socket *sock, int how)
 	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
 	int err = 0;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -783,7 +783,7 @@ static int l2cap_sock_release(struct socket *sock)
 	struct sock *sk = sock->sk;
 	int err;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -840,7 +840,7 @@ static struct l2cap_ops l2cap_chan_ops = {
 
 static void l2cap_sock_destruct(struct sock *sk)
 {
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	skb_queue_purge(&sk->sk_receive_queue);
 	skb_queue_purge(&sk->sk_write_queue);
@@ -851,7 +851,7 @@ static void l2cap_sock_init(struct sock *sk, struct sock *parent)
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
 	struct l2cap_chan *chan = pi->chan;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (parent) {
 		struct l2cap_chan *pchan = l2cap_pi(parent)->chan;
@@ -955,7 +955,7 @@ static int l2cap_sock_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	bt_dbg("sock %p", sock);
 
 	sock->state = SS_UNCONNECTED;
 
@@ -1014,12 +1014,12 @@ int __init l2cap_init_sockets(void)
 	if (err < 0)
 		goto error;
 
-	BT_INFO("L2CAP socket layer initialized");
+	bt_info("L2CAP socket layer initialized");
 
 	return 0;
 
 error:
-	BT_ERR("L2CAP socket registration failed");
+	bt_err("L2CAP socket registration failed");
 	proto_unregister(&l2cap_proto);
 	return err;
 }
@@ -1027,7 +1027,7 @@ error:
 void l2cap_cleanup_sockets(void)
 {
 	if (bt_sock_unregister(BTPROTO_L2CAP) < 0)
-		BT_ERR("L2CAP socket unregistration failed");
+		bt_err("L2CAP socket unregistration failed");
 
 	proto_unregister(&l2cap_proto);
 }
diff --git a/net/bluetooth/lib.c b/net/bluetooth/lib.c
index 4e7cf8b..6545286 100644
--- a/net/bluetooth/lib.c
+++ b/net/bluetooth/lib.c
@@ -150,3 +150,22 @@ int bt_to_errno(__u16 code)
 	}
 }
 EXPORT_SYMBOL(bt_to_errno);
+
+int bt_printk(const char *level, const char *format, ...)
+{
+	struct va_format vaf;
+	va_list args;
+	int r;
+
+	va_start(args, format);
+
+	vaf.fmt = format;
+	vaf.va = &args;
+
+	r = printk("%sbluetooth: %pV\n", level, &vaf);
+
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(bt_printk);
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 64c0418..d8550f9 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -49,7 +49,7 @@ static int cmd_status(struct sock *sk, u16 index, u16 cmd, u8 status)
 	struct mgmt_hdr *hdr;
 	struct mgmt_ev_cmd_status *ev;
 
-	BT_DBG("sock %p, index %u, cmd %u, status %u", sk, index, cmd, status);
+	bt_dbg("sock %p, index %u, cmd %u, status %u", sk, index, cmd, status);
 
 	skb = alloc_skb(sizeof(*hdr) + sizeof(*ev), GFP_ATOMIC);
 	if (!skb)
@@ -78,7 +78,7 @@ static int cmd_complete(struct sock *sk, u16 index, u16 cmd, void *rp,
 	struct mgmt_hdr *hdr;
 	struct mgmt_ev_cmd_complete *ev;
 
-	BT_DBG("sock %p", sk);
+	bt_dbg("sock %p", sk);
 
 	skb = alloc_skb(sizeof(*hdr) + sizeof(*ev) + rp_len, GFP_ATOMIC);
 	if (!skb)
@@ -106,7 +106,7 @@ static int read_version(struct sock *sk)
 {
 	struct mgmt_rp_read_version rp;
 
-	BT_DBG("sock %p", sk);
+	bt_dbg("sock %p", sk);
 
 	rp.version = MGMT_VERSION;
 	put_unaligned_le16(MGMT_REVISION, &rp.revision);
@@ -123,7 +123,7 @@ static int read_index_list(struct sock *sk)
 	u16 count;
 	int i, err;
 
-	BT_DBG("sock %p", sk);
+	bt_dbg("sock %p", sk);
 
 	read_lock(&hci_dev_list_lock);
 
@@ -153,7 +153,7 @@ static int read_index_list(struct sock *sk)
 			continue;
 
 		put_unaligned_le16(d->id, &rp->index[i++]);
-		BT_DBG("Added hci%u", d->id);
+		bt_dbg("Added hci%u", d->id);
 	}
 
 	read_unlock(&hci_dev_list_lock);
@@ -171,7 +171,7 @@ static int read_controller_info(struct sock *sk, u16 index)
 	struct mgmt_rp_read_info rp;
 	struct hci_dev *hdev;
 
-	BT_DBG("sock %p hci%u", sk, index);
+	bt_dbg("sock %p hci%u", sk, index);
 
 	hdev = hci_dev_get(index);
 	if (!hdev)
@@ -307,7 +307,7 @@ static int set_powered(struct sock *sk, u16 index, unsigned char *data, u16 len)
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	bt_dbg("request for hci%u", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_SET_POWERED, EINVAL);
@@ -359,7 +359,7 @@ static int set_discoverable(struct sock *sk, u16 index, unsigned char *data,
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	bt_dbg("request for hci%u", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_SET_DISCOVERABLE, EINVAL);
@@ -420,7 +420,7 @@ static int set_connectable(struct sock *sk, u16 index, unsigned char *data,
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	bt_dbg("request for hci%u", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_SET_CONNECTABLE, EINVAL);
@@ -513,7 +513,7 @@ static int set_pairable(struct sock *sk, u16 index, unsigned char *data,
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	bt_dbg("request for hci%u", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_SET_PAIRABLE, EINVAL);
@@ -706,7 +706,7 @@ static int update_class(struct hci_dev *hdev)
 {
 	u8 cod[3];
 
-	BT_DBG("%s", hdev->name);
+	bt_dbg("%s", hdev->name);
 
 	if (test_bit(HCI_SERVICE_CACHE, &hdev->flags))
 		return 0;
@@ -730,7 +730,7 @@ static int add_uuid(struct sock *sk, u16 index, unsigned char *data, u16 len)
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	bt_dbg("request for hci%u", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_ADD_UUID, EINVAL);
@@ -779,7 +779,7 @@ static int remove_uuid(struct sock *sk, u16 index, unsigned char *data, u16 len)
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	bt_dbg("request for hci%u", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_REMOVE_UUID, EINVAL);
@@ -838,7 +838,7 @@ static int set_dev_class(struct sock *sk, u16 index, unsigned char *data,
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	bt_dbg("request for hci%u", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_SET_DEV_CLASS, EINVAL);
@@ -881,7 +881,7 @@ static int set_service_cache(struct sock *sk, u16 index,  unsigned char *data,
 
 	hci_dev_lock(hdev);
 
-	BT_DBG("hci%u enable %d", index, cp->enable);
+	bt_dbg("hci%u enable %d", index, cp->enable);
 
 	if (cp->enable) {
 		set_bit(HCI_SERVICE_CACHE, &hdev->flags);
@@ -919,7 +919,7 @@ static int load_keys(struct sock *sk, u16 index, unsigned char *data, u16 len)
 
 	expected_len = sizeof(*cp) + key_count * sizeof(struct mgmt_key_info);
 	if (expected_len != len) {
-		BT_ERR("load_keys: expected %u bytes, got %u bytes",
+		bt_err("load_keys: expected %u bytes, got %u bytes",
 							len, expected_len);
 		return -EINVAL;
 	}
@@ -928,7 +928,7 @@ static int load_keys(struct sock *sk, u16 index, unsigned char *data, u16 len)
 	if (!hdev)
 		return cmd_status(sk, index, MGMT_OP_LOAD_KEYS, ENODEV);
 
-	BT_DBG("hci%u debug_keys %u key_count %u", index, cp->debug_keys,
+	bt_dbg("hci%u debug_keys %u key_count %u", index, cp->debug_keys,
 								key_count);
 
 	hci_dev_lock(hdev);
@@ -1009,7 +1009,7 @@ static int disconnect(struct sock *sk, u16 index, unsigned char *data, u16 len)
 	struct hci_conn *conn;
 	int err;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	cp = (void *) data;
 
@@ -1070,7 +1070,7 @@ static int get_connections(struct sock *sk, u16 index)
 	u16 count;
 	int i, err;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	hdev = hci_dev_get(index);
 	if (!hdev)
@@ -1138,7 +1138,7 @@ static int pin_code_reply(struct sock *sk, u16 index, unsigned char *data,
 	struct pending_cmd *cmd;
 	int err;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	cp = (void *) data;
 
@@ -1165,7 +1165,7 @@ static int pin_code_reply(struct sock *sk, u16 index, unsigned char *data,
 	if (conn->pending_sec_level == BT_SECURITY_HIGH && cp->pin_len != 16) {
 		bacpy(&ncp.bdaddr, &cp->bdaddr);
 
-		BT_ERR("PIN code is not 16 bytes long");
+		bt_err("PIN code is not 16 bytes long");
 
 		err = send_pin_code_neg_reply(sk, index, hdev, &ncp);
 		if (err >= 0)
@@ -1203,7 +1203,7 @@ static int pin_code_neg_reply(struct sock *sk, u16 index, unsigned char *data,
 	struct mgmt_cp_pin_code_neg_reply *cp;
 	int err;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	cp = (void *) data;
 
@@ -1239,7 +1239,7 @@ static int set_io_capability(struct sock *sk, u16 index, unsigned char *data,
 	struct hci_dev *hdev;
 	struct mgmt_cp_set_io_capability *cp;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	cp = (void *) data;
 
@@ -1254,7 +1254,7 @@ static int set_io_capability(struct sock *sk, u16 index, unsigned char *data,
 
 	hdev->io_capability = cp->io_capability;
 
-	BT_DBG("%s IO capability set to 0x%02x", hdev->name,
+	bt_dbg("%s IO capability set to 0x%02x", hdev->name,
 							hdev->io_capability);
 
 	hci_dev_unlock(hdev);
@@ -1312,11 +1312,11 @@ static void pairing_complete_cb(struct hci_conn *conn, u8 status)
 {
 	struct pending_cmd *cmd;
 
-	BT_DBG("status %u", status);
+	bt_dbg("status %u", status);
 
 	cmd = find_pairing(conn);
 	if (!cmd) {
-		BT_DBG("Unable to find a pending command");
+		bt_dbg("Unable to find a pending command");
 		return;
 	}
 
@@ -1332,7 +1332,7 @@ static int pair_device(struct sock *sk, u16 index, unsigned char *data, u16 len)
 	struct hci_conn *conn;
 	int err;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	cp = (void *) data;
 
@@ -1400,7 +1400,7 @@ static int user_confirm_reply(struct sock *sk, u16 index, unsigned char *data,
 	struct hci_dev *hdev;
 	int err;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	if (success) {
 		mgmt_op = MGMT_OP_USER_CONFIRM_REPLY;
@@ -1450,7 +1450,7 @@ static int set_local_name(struct sock *sk, u16 index, unsigned char *data,
 	struct pending_cmd *cmd;
 	int err;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	if (len != sizeof(*mgmt_cp))
 		return cmd_status(sk, index, MGMT_OP_SET_LOCAL_NAME, EINVAL);
@@ -1486,7 +1486,7 @@ static int read_local_oob_data(struct sock *sk, u16 index)
 	struct pending_cmd *cmd;
 	int err;
 
-	BT_DBG("hci%u", index);
+	bt_dbg("hci%u", index);
 
 	hdev = hci_dev_get(index);
 	if (!hdev)
@@ -1536,7 +1536,7 @@ static int add_remote_oob_data(struct sock *sk, u16 index, unsigned char *data,
 	struct mgmt_cp_add_remote_oob_data *cp = (void *) data;
 	int err;
 
-	BT_DBG("hci%u ", index);
+	bt_dbg("hci%u ", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_ADD_REMOTE_OOB_DATA,
@@ -1570,7 +1570,7 @@ static int remove_remote_oob_data(struct sock *sk, u16 index,
 	struct mgmt_cp_remove_remote_oob_data *cp = (void *) data;
 	int err;
 
-	BT_DBG("hci%u ", index);
+	bt_dbg("hci%u ", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_REMOVE_REMOTE_OOB_DATA,
@@ -1605,7 +1605,7 @@ static int start_discovery(struct sock *sk, u16 index)
 	struct hci_dev *hdev;
 	int err;
 
-	BT_DBG("hci%u", index);
+	bt_dbg("hci%u", index);
 
 	hdev = hci_dev_get(index);
 	if (!hdev)
@@ -1641,7 +1641,7 @@ static int stop_discovery(struct sock *sk, u16 index)
 	struct pending_cmd *cmd;
 	int err;
 
-	BT_DBG("hci%u", index);
+	bt_dbg("hci%u", index);
 
 	hdev = hci_dev_get(index);
 	if (!hdev)
@@ -1673,7 +1673,7 @@ static int block_device(struct sock *sk, u16 index, unsigned char *data,
 	struct mgmt_cp_block_device *cp;
 	int err;
 
-	BT_DBG("hci%u", index);
+	bt_dbg("hci%u", index);
 
 	cp = (void *) data;
 
@@ -1705,7 +1705,7 @@ static int unblock_device(struct sock *sk, u16 index, unsigned char *data,
 	struct mgmt_cp_unblock_device *cp;
 	int err;
 
-	BT_DBG("hci%u", index);
+	bt_dbg("hci%u", index);
 
 	cp = (void *) data;
 
@@ -1737,7 +1737,7 @@ int mgmt_control(struct sock *sk, struct msghdr *msg, size_t msglen)
 	u16 opcode, index, len;
 	int err;
 
-	BT_DBG("got %zu bytes", msglen);
+	bt_dbg("got %zu bytes", msglen);
 
 	if (msglen < sizeof(*hdr))
 		return -EINVAL;
@@ -1851,7 +1851,7 @@ int mgmt_control(struct sock *sk, struct msghdr *msg, size_t msglen)
 		err = unblock_device(sk, index, buf + sizeof(*hdr), len);
 		break;
 	default:
-		BT_DBG("Unknown op %u", opcode);
+		bt_dbg("Unknown op %u", opcode);
 		err = cmd_status(sk, index, opcode, 0x01);
 		break;
 	}
@@ -2098,7 +2098,7 @@ int mgmt_user_confirm_request(u16 index, bdaddr_t *bdaddr, __le32 value,
 {
 	struct mgmt_ev_user_confirm_request ev;
 
-	BT_DBG("hci%u", index);
+	bt_dbg("hci%u", index);
 
 	bacpy(&ev.bdaddr, bdaddr);
 	ev.confirm_hint = confirm_hint;
@@ -2198,7 +2198,7 @@ int mgmt_read_local_oob_data_reply_complete(u16 index, u8 *hash, u8 *randomizer,
 	struct pending_cmd *cmd;
 	int err;
 
-	BT_DBG("hci%u status %u", index, status);
+	bt_dbg("hci%u status %u", index, status);
 
 	cmd = mgmt_pending_find(MGMT_OP_READ_LOCAL_OOB_DATA, index);
 	if (!cmd)
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 5759bb7..1849956 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -204,13 +204,13 @@ static inline int __check_fcs(u8 *data, int type, u8 fcs)
 /* ---- L2CAP callbacks ---- */
 static void rfcomm_l2state_change(struct sock *sk)
 {
-	BT_DBG("%p state %d", sk, sk->sk_state);
+	bt_dbg("%p state %d", sk, sk->sk_state);
 	rfcomm_schedule();
 }
 
 static void rfcomm_l2data_ready(struct sock *sk, int bytes)
 {
-	BT_DBG("%p bytes %d", sk, bytes);
+	bt_dbg("%p bytes %d", sk, bytes);
 	rfcomm_schedule();
 }
 
@@ -218,7 +218,7 @@ static int rfcomm_l2sock_create(struct socket **sock)
 {
 	int err;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	err = sock_create_kern(PF_BLUETOOTH, SOCK_SEQPACKET, BTPROTO_L2CAP, sock);
 	if (!err) {
@@ -255,7 +255,7 @@ static void rfcomm_session_timeout(unsigned long arg)
 {
 	struct rfcomm_session *s = (void *) arg;
 
-	BT_DBG("session %p state %ld", s, s->state);
+	bt_dbg("session %p state %ld", s, s->state);
 
 	set_bit(RFCOMM_TIMED_OUT, &s->flags);
 	rfcomm_schedule();
@@ -263,7 +263,7 @@ static void rfcomm_session_timeout(unsigned long arg)
 
 static void rfcomm_session_set_timer(struct rfcomm_session *s, long timeout)
 {
-	BT_DBG("session %p state %ld timeout %ld", s, s->state, timeout);
+	bt_dbg("session %p state %ld timeout %ld", s, s->state, timeout);
 
 	if (!mod_timer(&s->timer, jiffies + timeout))
 		rfcomm_session_hold(s);
@@ -271,7 +271,7 @@ static void rfcomm_session_set_timer(struct rfcomm_session *s, long timeout)
 
 static void rfcomm_session_clear_timer(struct rfcomm_session *s)
 {
-	BT_DBG("session %p state %ld", s, s->state);
+	bt_dbg("session %p state %ld", s, s->state);
 
 	if (timer_pending(&s->timer) && del_timer(&s->timer))
 		rfcomm_session_put(s);
@@ -282,7 +282,7 @@ static void rfcomm_dlc_timeout(unsigned long arg)
 {
 	struct rfcomm_dlc *d = (void *) arg;
 
-	BT_DBG("dlc %p state %ld", d, d->state);
+	bt_dbg("dlc %p state %ld", d, d->state);
 
 	set_bit(RFCOMM_TIMED_OUT, &d->flags);
 	rfcomm_dlc_put(d);
@@ -291,7 +291,7 @@ static void rfcomm_dlc_timeout(unsigned long arg)
 
 static void rfcomm_dlc_set_timer(struct rfcomm_dlc *d, long timeout)
 {
-	BT_DBG("dlc %p state %ld timeout %ld", d, d->state, timeout);
+	bt_dbg("dlc %p state %ld timeout %ld", d, d->state, timeout);
 
 	if (!mod_timer(&d->timer, jiffies + timeout))
 		rfcomm_dlc_hold(d);
@@ -299,7 +299,7 @@ static void rfcomm_dlc_set_timer(struct rfcomm_dlc *d, long timeout)
 
 static void rfcomm_dlc_clear_timer(struct rfcomm_dlc *d)
 {
-	BT_DBG("dlc %p state %ld", d, d->state);
+	bt_dbg("dlc %p state %ld", d, d->state);
 
 	if (timer_pending(&d->timer) && del_timer(&d->timer))
 		rfcomm_dlc_put(d);
@@ -307,7 +307,7 @@ static void rfcomm_dlc_clear_timer(struct rfcomm_dlc *d)
 
 static void rfcomm_dlc_clear_state(struct rfcomm_dlc *d)
 {
-	BT_DBG("%p", d);
+	bt_dbg("%p", d);
 
 	d->state      = BT_OPEN;
 	d->flags      = 0;
@@ -335,14 +335,14 @@ struct rfcomm_dlc *rfcomm_dlc_alloc(gfp_t prio)
 
 	rfcomm_dlc_clear_state(d);
 
-	BT_DBG("%p", d);
+	bt_dbg("%p", d);
 
 	return d;
 }
 
 void rfcomm_dlc_free(struct rfcomm_dlc *d)
 {
-	BT_DBG("%p", d);
+	bt_dbg("%p", d);
 
 	skb_queue_purge(&d->tx_queue);
 	kfree(d);
@@ -350,7 +350,7 @@ void rfcomm_dlc_free(struct rfcomm_dlc *d)
 
 static void rfcomm_dlc_link(struct rfcomm_session *s, struct rfcomm_dlc *d)
 {
-	BT_DBG("dlc %p session %p", d, s);
+	bt_dbg("dlc %p session %p", d, s);
 
 	rfcomm_session_hold(s);
 
@@ -364,7 +364,7 @@ static void rfcomm_dlc_unlink(struct rfcomm_dlc *d)
 {
 	struct rfcomm_session *s = d->session;
 
-	BT_DBG("dlc %p refcnt %d session %p", d, atomic_read(&d->refcnt), s);
+	bt_dbg("dlc %p refcnt %d session %p", d, atomic_read(&d->refcnt), s);
 
 	list_del(&d->list);
 	d->session = NULL;
@@ -395,7 +395,7 @@ static int __rfcomm_dlc_open(struct rfcomm_dlc *d, bdaddr_t *src, bdaddr_t *dst,
 	int err = 0;
 	u8 dlci;
 
-	BT_DBG("dlc %p state %ld %s %s channel %d",
+	bt_dbg("dlc %p state %ld %s %s channel %d",
 			d, d->state, batostr(src), batostr(dst), channel);
 
 	if (channel < 1 || channel > 30)
@@ -461,7 +461,7 @@ static int __rfcomm_dlc_close(struct rfcomm_dlc *d, int err)
 	if (!s)
 		return 0;
 
-	BT_DBG("dlc %p state %ld dlci %d err %d session %p",
+	bt_dbg("dlc %p state %ld dlci %d err %d session %p",
 			d, d->state, d->dlci, err, s);
 
 	switch (d->state) {
@@ -528,7 +528,7 @@ int rfcomm_dlc_send(struct rfcomm_dlc *d, struct sk_buff *skb)
 	if (d->state != BT_CONNECTED)
 		return -ENOTCONN;
 
-	BT_DBG("dlc %p mtu %d len %d", d, d->mtu, len);
+	bt_dbg("dlc %p mtu %d len %d", d, d->mtu, len);
 
 	if (len > d->mtu)
 		return -EINVAL;
@@ -543,7 +543,7 @@ int rfcomm_dlc_send(struct rfcomm_dlc *d, struct sk_buff *skb)
 
 void __rfcomm_dlc_throttle(struct rfcomm_dlc *d)
 {
-	BT_DBG("dlc %p state %ld", d, d->state);
+	bt_dbg("dlc %p state %ld", d, d->state);
 
 	if (!d->cfc) {
 		d->v24_sig |= RFCOMM_V24_FC;
@@ -554,7 +554,7 @@ void __rfcomm_dlc_throttle(struct rfcomm_dlc *d)
 
 void __rfcomm_dlc_unthrottle(struct rfcomm_dlc *d)
 {
-	BT_DBG("dlc %p state %ld", d, d->state);
+	bt_dbg("dlc %p state %ld", d, d->state);
 
 	if (!d->cfc) {
 		d->v24_sig &= ~RFCOMM_V24_FC;
@@ -570,7 +570,7 @@ void __rfcomm_dlc_unthrottle(struct rfcomm_dlc *d)
  */
 int rfcomm_dlc_set_modem_status(struct rfcomm_dlc *d, u8 v24_sig)
 {
-	BT_DBG("dlc %p state %ld v24_sig 0x%x",
+	bt_dbg("dlc %p state %ld v24_sig 0x%x",
 			d, d->state, v24_sig);
 
 	if (test_bit(RFCOMM_RX_THROTTLED, &d->flags))
@@ -588,7 +588,7 @@ int rfcomm_dlc_set_modem_status(struct rfcomm_dlc *d, u8 v24_sig)
 
 int rfcomm_dlc_get_modem_status(struct rfcomm_dlc *d, u8 *v24_sig)
 {
-	BT_DBG("dlc %p state %ld v24_sig 0x%x",
+	bt_dbg("dlc %p state %ld v24_sig 0x%x",
 			d, d->state, d->v24_sig);
 
 	*v24_sig = d->v24_sig;
@@ -603,7 +603,7 @@ static struct rfcomm_session *rfcomm_session_add(struct socket *sock, int state)
 	if (!s)
 		return NULL;
 
-	BT_DBG("session %p sock %p", s, sock);
+	bt_dbg("session %p sock %p", s, sock);
 
 	setup_timer(&s->timer, rfcomm_session_timeout, (unsigned long) s);
 
@@ -631,7 +631,7 @@ static void rfcomm_session_del(struct rfcomm_session *s)
 {
 	int state = s->state;
 
-	BT_DBG("session %p state %ld", s, s->state);
+	bt_dbg("session %p state %ld", s, s->state);
 
 	list_del(&s->list);
 
@@ -667,7 +667,7 @@ static void rfcomm_session_close(struct rfcomm_session *s, int err)
 	struct rfcomm_dlc *d;
 	struct list_head *p, *n;
 
-	BT_DBG("session %p state %ld err %d", s, s->state, err);
+	bt_dbg("session %p state %ld err %d", s, s->state, err);
 
 	rfcomm_session_hold(s);
 
@@ -694,7 +694,7 @@ static struct rfcomm_session *rfcomm_session_create(bdaddr_t *src,
 	struct socket *sock;
 	struct sock *sk;
 
-	BT_DBG("%s %s", batostr(src), batostr(dst));
+	bt_dbg("%s %s", batostr(src), batostr(dst));
 
 	*err = rfcomm_l2sock_create(&sock);
 	if (*err < 0)
@@ -757,7 +757,7 @@ static int rfcomm_send_frame(struct rfcomm_session *s, u8 *data, int len)
 	struct kvec iv = { data, len };
 	struct msghdr msg;
 
-	BT_DBG("session %p len %d", s, len);
+	bt_dbg("session %p len %d", s, len);
 
 	memset(&msg, 0, sizeof(msg));
 
@@ -768,7 +768,7 @@ static int rfcomm_send_sabm(struct rfcomm_session *s, u8 dlci)
 {
 	struct rfcomm_cmd cmd;
 
-	BT_DBG("%p dlci %d", s, dlci);
+	bt_dbg("%p dlci %d", s, dlci);
 
 	cmd.addr = __addr(s->initiator, dlci);
 	cmd.ctrl = __ctrl(RFCOMM_SABM, 1);
@@ -782,7 +782,7 @@ static int rfcomm_send_ua(struct rfcomm_session *s, u8 dlci)
 {
 	struct rfcomm_cmd cmd;
 
-	BT_DBG("%p dlci %d", s, dlci);
+	bt_dbg("%p dlci %d", s, dlci);
 
 	cmd.addr = __addr(!s->initiator, dlci);
 	cmd.ctrl = __ctrl(RFCOMM_UA, 1);
@@ -796,7 +796,7 @@ static int rfcomm_send_disc(struct rfcomm_session *s, u8 dlci)
 {
 	struct rfcomm_cmd cmd;
 
-	BT_DBG("%p dlci %d", s, dlci);
+	bt_dbg("%p dlci %d", s, dlci);
 
 	cmd.addr = __addr(s->initiator, dlci);
 	cmd.ctrl = __ctrl(RFCOMM_DISC, 1);
@@ -811,7 +811,7 @@ static int rfcomm_queue_disc(struct rfcomm_dlc *d)
 	struct rfcomm_cmd *cmd;
 	struct sk_buff *skb;
 
-	BT_DBG("dlc %p dlci %d", d, d->dlci);
+	bt_dbg("dlc %p dlci %d", d, d->dlci);
 
 	skb = alloc_skb(sizeof(*cmd), GFP_KERNEL);
 	if (!skb)
@@ -832,7 +832,7 @@ static int rfcomm_send_dm(struct rfcomm_session *s, u8 dlci)
 {
 	struct rfcomm_cmd cmd;
 
-	BT_DBG("%p dlci %d", s, dlci);
+	bt_dbg("%p dlci %d", s, dlci);
 
 	cmd.addr = __addr(!s->initiator, dlci);
 	cmd.ctrl = __ctrl(RFCOMM_DM, 1);
@@ -848,7 +848,7 @@ static int rfcomm_send_nsc(struct rfcomm_session *s, int cr, u8 type)
 	struct rfcomm_mcc *mcc;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d type %d", s, cr, type);
+	bt_dbg("%p cr %d type %d", s, cr, type);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -874,7 +874,7 @@ static int rfcomm_send_pn(struct rfcomm_session *s, int cr, struct rfcomm_dlc *d
 	struct rfcomm_pn  *pn;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d dlci %d mtu %d", s, cr, d->dlci, d->mtu);
+	bt_dbg("%p cr %d dlci %d mtu %d", s, cr, d->dlci, d->mtu);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -919,7 +919,7 @@ int rfcomm_send_rpn(struct rfcomm_session *s, int cr, u8 dlci,
 	struct rfcomm_rpn *rpn;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d dlci %d bit_r 0x%x data_b 0x%x stop_b 0x%x parity 0x%x"
+	bt_dbg("%p cr %d dlci %d bit_r 0x%x data_b 0x%x stop_b 0x%x parity 0x%x"
 			" flwc_s 0x%x xon_c 0x%x xoff_c 0x%x p_mask 0x%x",
 		s, cr, dlci, bit_rate, data_bits, stop_bits, parity,
 		flow_ctrl_settings, xon_char, xoff_char, param_mask);
@@ -954,7 +954,7 @@ static int rfcomm_send_rls(struct rfcomm_session *s, int cr, u8 dlci, u8 status)
 	struct rfcomm_rls *rls;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d status 0x%x", s, cr, status);
+	bt_dbg("%p cr %d status 0x%x", s, cr, status);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -981,7 +981,7 @@ static int rfcomm_send_msc(struct rfcomm_session *s, int cr, u8 dlci, u8 v24_sig
 	struct rfcomm_msc *msc;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d v24 0x%x", s, cr, v24_sig);
+	bt_dbg("%p cr %d v24 0x%x", s, cr, v24_sig);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -1007,7 +1007,7 @@ static int rfcomm_send_fcoff(struct rfcomm_session *s, int cr)
 	struct rfcomm_mcc *mcc;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d", s, cr);
+	bt_dbg("%p cr %d", s, cr);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -1029,7 +1029,7 @@ static int rfcomm_send_fcon(struct rfcomm_session *s, int cr)
 	struct rfcomm_mcc *mcc;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d", s, cr);
+	bt_dbg("%p cr %d", s, cr);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -1055,7 +1055,7 @@ static int rfcomm_send_test(struct rfcomm_session *s, int cr, u8 *pattern, int l
 	if (len > 125)
 		return -EINVAL;
 
-	BT_DBG("%p cr %d", s, cr);
+	bt_dbg("%p cr %d", s, cr);
 
 	hdr[0] = __addr(s->initiator, 0);
 	hdr[1] = __ctrl(RFCOMM_UIH, 0);
@@ -1082,7 +1082,7 @@ static int rfcomm_send_credits(struct rfcomm_session *s, u8 addr, u8 credits)
 	struct rfcomm_hdr *hdr;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p addr %d credits %d", s, addr, credits);
+	bt_dbg("%p addr %d credits %d", s, addr, credits);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = addr;
@@ -1119,7 +1119,7 @@ static void rfcomm_make_uih(struct sk_buff *skb, u8 addr)
 /* ---- RFCOMM frame reception ---- */
 static int rfcomm_recv_ua(struct rfcomm_session *s, u8 dlci)
 {
-	BT_DBG("session %p state %ld dlci %d", s, s->state, dlci);
+	bt_dbg("session %p state %ld dlci %d", s, s->state, dlci);
 
 	if (dlci) {
 		/* Data channel */
@@ -1177,7 +1177,7 @@ static int rfcomm_recv_dm(struct rfcomm_session *s, u8 dlci)
 {
 	int err = 0;
 
-	BT_DBG("session %p state %ld dlci %d", s, s->state, dlci);
+	bt_dbg("session %p state %ld dlci %d", s, s->state, dlci);
 
 	if (dlci) {
 		/* Data DLC */
@@ -1207,7 +1207,7 @@ static int rfcomm_recv_disc(struct rfcomm_session *s, u8 dlci)
 {
 	int err = 0;
 
-	BT_DBG("session %p state %ld dlci %d", s, s->state, dlci);
+	bt_dbg("session %p state %ld dlci %d", s, s->state, dlci);
 
 	if (dlci) {
 		struct rfcomm_dlc *d = rfcomm_dlc_get(s, dlci);
@@ -1244,7 +1244,7 @@ void rfcomm_dlc_accept(struct rfcomm_dlc *d)
 	struct sock *sk = d->session->sock->sk;
 	struct l2cap_conn *conn = l2cap_pi(sk)->chan->conn;
 
-	BT_DBG("dlc %p", d);
+	bt_dbg("dlc %p", d);
 
 	rfcomm_send_ua(d->session, d->dlci);
 
@@ -1285,7 +1285,7 @@ static int rfcomm_recv_sabm(struct rfcomm_session *s, u8 dlci)
 	struct rfcomm_dlc *d;
 	u8 channel;
 
-	BT_DBG("session %p state %ld dlci %d", s, s->state, dlci);
+	bt_dbg("session %p state %ld dlci %d", s, s->state, dlci);
 
 	if (!dlci) {
 		rfcomm_send_ua(s, 0);
@@ -1326,7 +1326,7 @@ static int rfcomm_apply_pn(struct rfcomm_dlc *d, int cr, struct rfcomm_pn *pn)
 {
 	struct rfcomm_session *s = d->session;
 
-	BT_DBG("dlc %p state %ld dlci %d mtu %d fc 0x%x credits %d",
+	bt_dbg("dlc %p state %ld dlci %d mtu %d fc 0x%x credits %d",
 			d, d->state, d->dlci, pn->mtu, pn->flow_ctrl, pn->credits);
 
 	if ((pn->flow_ctrl == 0xf0 && s->cfc != RFCOMM_CFC_DISABLED) ||
@@ -1357,7 +1357,7 @@ static int rfcomm_recv_pn(struct rfcomm_session *s, int cr, struct sk_buff *skb)
 	struct rfcomm_dlc *d;
 	u8 dlci = pn->dlci;
 
-	BT_DBG("session %p state %ld dlci %d", s, s->state, dlci);
+	bt_dbg("session %p state %ld dlci %d", s, s->state, dlci);
 
 	if (!dlci)
 		return 0;
@@ -1417,7 +1417,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	u8 xoff_char = 0;
 	u16 rpn_mask = RFCOMM_RPN_PM_ALL;
 
-	BT_DBG("dlci %d cr %d len 0x%x bitr 0x%x line 0x%x flow 0x%x xonc 0x%x xoffc 0x%x pm 0x%x",
+	bt_dbg("dlci %d cr %d len 0x%x bitr 0x%x line 0x%x flow 0x%x xonc 0x%x xoffc 0x%x pm 0x%x",
 		dlci, cr, len, rpn->bit_rate, rpn->line_settings, rpn->flow_ctrl,
 		rpn->xon_char, rpn->xoff_char, rpn->param_mask);
 
@@ -1442,7 +1442,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_BITRATE)) {
 		bit_rate = rpn->bit_rate;
 		if (bit_rate > RFCOMM_RPN_BR_230400) {
-			BT_DBG("RPN bit rate mismatch 0x%x", bit_rate);
+			bt_dbg("RPN bit rate mismatch 0x%x", bit_rate);
 			bit_rate = RFCOMM_RPN_BR_9600;
 			rpn_mask ^= RFCOMM_RPN_PM_BITRATE;
 		}
@@ -1451,7 +1451,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_DATA)) {
 		data_bits = __get_rpn_data_bits(rpn->line_settings);
 		if (data_bits != RFCOMM_RPN_DATA_8) {
-			BT_DBG("RPN data bits mismatch 0x%x", data_bits);
+			bt_dbg("RPN data bits mismatch 0x%x", data_bits);
 			data_bits = RFCOMM_RPN_DATA_8;
 			rpn_mask ^= RFCOMM_RPN_PM_DATA;
 		}
@@ -1460,7 +1460,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_STOP)) {
 		stop_bits = __get_rpn_stop_bits(rpn->line_settings);
 		if (stop_bits != RFCOMM_RPN_STOP_1) {
-			BT_DBG("RPN stop bits mismatch 0x%x", stop_bits);
+			bt_dbg("RPN stop bits mismatch 0x%x", stop_bits);
 			stop_bits = RFCOMM_RPN_STOP_1;
 			rpn_mask ^= RFCOMM_RPN_PM_STOP;
 		}
@@ -1469,7 +1469,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_PARITY)) {
 		parity = __get_rpn_parity(rpn->line_settings);
 		if (parity != RFCOMM_RPN_PARITY_NONE) {
-			BT_DBG("RPN parity mismatch 0x%x", parity);
+			bt_dbg("RPN parity mismatch 0x%x", parity);
 			parity = RFCOMM_RPN_PARITY_NONE;
 			rpn_mask ^= RFCOMM_RPN_PM_PARITY;
 		}
@@ -1478,7 +1478,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_FLOW)) {
 		flow_ctrl = rpn->flow_ctrl;
 		if (flow_ctrl != RFCOMM_RPN_FLOW_NONE) {
-			BT_DBG("RPN flow ctrl mismatch 0x%x", flow_ctrl);
+			bt_dbg("RPN flow ctrl mismatch 0x%x", flow_ctrl);
 			flow_ctrl = RFCOMM_RPN_FLOW_NONE;
 			rpn_mask ^= RFCOMM_RPN_PM_FLOW;
 		}
@@ -1487,7 +1487,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_XON)) {
 		xon_char = rpn->xon_char;
 		if (xon_char != RFCOMM_RPN_XON_CHAR) {
-			BT_DBG("RPN XON char mismatch 0x%x", xon_char);
+			bt_dbg("RPN XON char mismatch 0x%x", xon_char);
 			xon_char = RFCOMM_RPN_XON_CHAR;
 			rpn_mask ^= RFCOMM_RPN_PM_XON;
 		}
@@ -1496,7 +1496,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_XOFF)) {
 		xoff_char = rpn->xoff_char;
 		if (xoff_char != RFCOMM_RPN_XOFF_CHAR) {
-			BT_DBG("RPN XOFF char mismatch 0x%x", xoff_char);
+			bt_dbg("RPN XOFF char mismatch 0x%x", xoff_char);
 			xoff_char = RFCOMM_RPN_XOFF_CHAR;
 			rpn_mask ^= RFCOMM_RPN_PM_XOFF;
 		}
@@ -1514,7 +1514,7 @@ static int rfcomm_recv_rls(struct rfcomm_session *s, int cr, struct sk_buff *skb
 	struct rfcomm_rls *rls = (void *) skb->data;
 	u8 dlci = __get_dlci(rls->dlci);
 
-	BT_DBG("dlci %d cr %d status 0x%x", dlci, cr, rls->status);
+	bt_dbg("dlci %d cr %d status 0x%x", dlci, cr, rls->status);
 
 	if (!cr)
 		return 0;
@@ -1534,7 +1534,7 @@ static int rfcomm_recv_msc(struct rfcomm_session *s, int cr, struct sk_buff *skb
 	struct rfcomm_dlc *d;
 	u8 dlci = __get_dlci(msc->dlci);
 
-	BT_DBG("dlci %d cr %d v24 0x%x", dlci, cr, msc->v24_sig);
+	bt_dbg("dlci %d cr %d v24 0x%x", dlci, cr, msc->v24_sig);
 
 	d = rfcomm_dlc_get(s, dlci);
 	if (!d)
@@ -1573,7 +1573,7 @@ static int rfcomm_recv_mcc(struct rfcomm_session *s, struct sk_buff *skb)
 	type = __get_mcc_type(mcc->type);
 	len  = __get_mcc_len(mcc->len);
 
-	BT_DBG("%p type 0x%x cr %d", s, type, cr);
+	bt_dbg("%p type 0x%x cr %d", s, type, cr);
 
 	skb_pull(skb, 2);
 
@@ -1617,7 +1617,7 @@ static int rfcomm_recv_mcc(struct rfcomm_session *s, struct sk_buff *skb)
 		break;
 
 	default:
-		BT_ERR("Unknown control type 0x%02x", type);
+		bt_err("Unknown control type 0x%02x", type);
 		rfcomm_send_nsc(s, cr, type);
 		break;
 	}
@@ -1628,7 +1628,7 @@ static int rfcomm_recv_data(struct rfcomm_session *s, u8 dlci, int pf, struct sk
 {
 	struct rfcomm_dlc *d;
 
-	BT_DBG("session %p state %ld dlci %d pf %d", s, s->state, dlci, pf);
+	bt_dbg("session %p state %ld dlci %d pf %d", s, s->state, dlci, pf);
 
 	d = rfcomm_dlc_get(s, dlci);
 	if (!d) {
@@ -1670,7 +1670,7 @@ static int rfcomm_recv_frame(struct rfcomm_session *s, struct sk_buff *skb)
 	fcs = *(u8 *)skb_tail_pointer(skb);
 
 	if (__check_fcs(skb->data, type, fcs)) {
-		BT_ERR("bad checksum in packet");
+		bt_err("bad checksum in packet");
 		kfree_skb(skb);
 		return -EILSEQ;
 	}
@@ -1708,7 +1708,7 @@ static int rfcomm_recv_frame(struct rfcomm_session *s, struct sk_buff *skb)
 		break;
 
 	default:
-		BT_ERR("Unknown packet type 0x%02x", type);
+		bt_err("Unknown packet type 0x%02x", type);
 		break;
 	}
 	kfree_skb(skb);
@@ -1722,7 +1722,7 @@ static void rfcomm_process_connect(struct rfcomm_session *s)
 	struct rfcomm_dlc *d;
 	struct list_head *p, *n;
 
-	BT_DBG("session %p state %ld", s, s->state);
+	bt_dbg("session %p state %ld", s, s->state);
 
 	list_for_each_safe(p, n, &s->dlcs) {
 		d = list_entry(p, struct rfcomm_dlc, list);
@@ -1746,7 +1746,7 @@ static inline int rfcomm_process_tx(struct rfcomm_dlc *d)
 	struct sk_buff *skb;
 	int err;
 
-	BT_DBG("dlc %p state %ld cfc %d rx_credits %d tx_credits %d",
+	bt_dbg("dlc %p state %ld cfc %d rx_credits %d tx_credits %d",
 			d, d->state, d->cfc, d->rx_credits, d->tx_credits);
 
 	/* Send pending MSC */
@@ -1794,7 +1794,7 @@ static inline void rfcomm_process_dlcs(struct rfcomm_session *s)
 	struct rfcomm_dlc *d;
 	struct list_head *p, *n;
 
-	BT_DBG("session %p state %ld", s, s->state);
+	bt_dbg("session %p state %ld", s, s->state);
 
 	list_for_each_safe(p, n, &s->dlcs) {
 		d = list_entry(p, struct rfcomm_dlc, list);
@@ -1850,7 +1850,7 @@ static inline void rfcomm_process_rx(struct rfcomm_session *s)
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
 
-	BT_DBG("session %p state %ld qlen %d", s, s->state, skb_queue_len(&sk->sk_receive_queue));
+	bt_dbg("session %p state %ld qlen %d", s, s->state, skb_queue_len(&sk->sk_receive_queue));
 
 	/* Get data directly from socket receive queue without copying it. */
 	while ((skb = skb_dequeue(&sk->sk_receive_queue))) {
@@ -1876,7 +1876,7 @@ static inline void rfcomm_accept_connection(struct rfcomm_session *s)
 	if (list_empty(&bt_sk(sock->sk)->accept_q))
 		return;
 
-	BT_DBG("session %p", s);
+	bt_dbg("session %p", s);
 
 	err = kernel_accept(sock, &nsock, O_NONBLOCK);
 	if (err < 0)
@@ -1904,7 +1904,7 @@ static inline void rfcomm_check_connection(struct rfcomm_session *s)
 {
 	struct sock *sk = s->sock->sk;
 
-	BT_DBG("%p state %ld", s, s->state);
+	bt_dbg("%p state %ld", s, s->state);
 
 	switch (sk->sk_state) {
 	case BT_CONNECTED:
@@ -1977,7 +1977,7 @@ static int rfcomm_add_listener(bdaddr_t *ba)
 	/* Create socket */
 	err = rfcomm_l2sock_create(&sock);
 	if (err < 0) {
-		BT_ERR("Create socket failed %d", err);
+		bt_err("Create socket failed %d", err);
 		return err;
 	}
 
@@ -1988,7 +1988,7 @@ static int rfcomm_add_listener(bdaddr_t *ba)
 	addr.l2_cid    = 0;
 	err = kernel_bind(sock, (struct sockaddr *) &addr, sizeof(addr));
 	if (err < 0) {
-		BT_ERR("Bind failed %d", err);
+		bt_err("Bind failed %d", err);
 		goto failed;
 	}
 
@@ -2001,7 +2001,7 @@ static int rfcomm_add_listener(bdaddr_t *ba)
 	/* Start listening on the socket */
 	err = kernel_listen(sock, 10);
 	if (err) {
-		BT_ERR("Listen failed %d", err);
+		bt_err("Listen failed %d", err);
 		goto failed;
 	}
 
@@ -2022,7 +2022,7 @@ static void rfcomm_kill_listener(void)
 	struct rfcomm_session *s;
 	struct list_head *p, *n;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	list_for_each_safe(p, n, &session_list) {
 		s = list_entry(p, struct rfcomm_session, list);
@@ -2032,7 +2032,7 @@ static void rfcomm_kill_listener(void)
 
 static int rfcomm_run(void *unused)
 {
-	BT_DBG("");
+	bt_dbg("");
 
 	set_user_nice(current, -10);
 
@@ -2063,7 +2063,7 @@ static void rfcomm_security_cfm(struct hci_conn *conn, u8 status, u8 encrypt)
 	struct rfcomm_dlc *d;
 	struct list_head *p, *n;
 
-	BT_DBG("conn %p status 0x%02x encrypt 0x%02x", conn, status, encrypt);
+	bt_dbg("conn %p status 0x%02x encrypt 0x%02x", conn, status, encrypt);
 
 	s = rfcomm_session_get(&conn->hdev->bdaddr, &conn->dst);
 	if (!s)
@@ -2169,7 +2169,7 @@ static int __init rfcomm_init(void)
 		rfcomm_dlc_debugfs = debugfs_create_file("rfcomm_dlc", 0444,
 				bt_debugfs, NULL, &rfcomm_dlc_debugfs_fops);
 		if (!rfcomm_dlc_debugfs)
-			BT_ERR("Failed to create RFCOMM debug file");
+			bt_err("Failed to create RFCOMM debug file");
 	}
 
 	err = rfcomm_init_ttys();
@@ -2180,7 +2180,7 @@ static int __init rfcomm_init(void)
 	if (err < 0)
 		goto cleanup;
 
-	BT_INFO("RFCOMM ver %s", VERSION);
+	bt_info("RFCOMM ver %s", VERSION);
 
 	return 0;
 
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 8f01e6b..776d286 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -87,7 +87,7 @@ static void rfcomm_sk_state_change(struct rfcomm_dlc *d, int err)
 	if (!sk)
 		return;
 
-	BT_DBG("dlc %p state %ld err %d", d, d->state, err);
+	bt_dbg("dlc %p state %ld err %d", d, d->state, err);
 
 	local_irq_save(flags);
 	bh_lock_sock(sk);
@@ -171,7 +171,7 @@ static void rfcomm_sock_destruct(struct sock *sk)
 {
 	struct rfcomm_dlc *d = rfcomm_pi(sk)->dlc;
 
-	BT_DBG("sk %p dlc %p", sk, d);
+	bt_dbg("sk %p dlc %p", sk, d);
 
 	skb_queue_purge(&sk->sk_receive_queue);
 	skb_queue_purge(&sk->sk_write_queue);
@@ -191,7 +191,7 @@ static void rfcomm_sock_cleanup_listen(struct sock *parent)
 {
 	struct sock *sk;
 
-	BT_DBG("parent %p", parent);
+	bt_dbg("parent %p", parent);
 
 	/* Close not yet accepted dlcs */
 	while ((sk = bt_accept_dequeue(parent, NULL))) {
@@ -211,7 +211,7 @@ static void rfcomm_sock_kill(struct sock *sk)
 	if (!sock_flag(sk, SOCK_ZAPPED) || sk->sk_socket)
 		return;
 
-	BT_DBG("sk %p state %d refcnt %d", sk, sk->sk_state, atomic_read(&sk->sk_refcnt));
+	bt_dbg("sk %p state %d refcnt %d", sk, sk->sk_state, atomic_read(&sk->sk_refcnt));
 
 	/* Kill poor orphan */
 	bt_sock_unlink(&rfcomm_sk_list, sk);
@@ -223,7 +223,7 @@ static void __rfcomm_sock_close(struct sock *sk)
 {
 	struct rfcomm_dlc *d = rfcomm_pi(sk)->dlc;
 
-	BT_DBG("sk %p state %d socket %p", sk, sk->sk_state, sk->sk_socket);
+	bt_dbg("sk %p state %d socket %p", sk, sk->sk_state, sk->sk_socket);
 
 	switch (sk->sk_state) {
 	case BT_LISTEN:
@@ -256,7 +256,7 @@ static void rfcomm_sock_init(struct sock *sk, struct sock *parent)
 {
 	struct rfcomm_pinfo *pi = rfcomm_pi(sk);
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (parent) {
 		sk->sk_type = parent->sk_type;
@@ -318,7 +318,7 @@ static struct sock *rfcomm_sock_alloc(struct net *net, struct socket *sock, int
 
 	bt_sock_link(&rfcomm_sk_list, sk);
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 	return sk;
 }
 
@@ -327,7 +327,7 @@ static int rfcomm_sock_create(struct net *net, struct socket *sock,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	bt_dbg("sock %p", sock);
 
 	sock->state = SS_UNCONNECTED;
 
@@ -350,7 +350,7 @@ static int rfcomm_sock_bind(struct socket *sock, struct sockaddr *addr, int addr
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sk %p %s", sk, batostr(&sa->rc_bdaddr));
+	bt_dbg("sk %p %s", sk, batostr(&sa->rc_bdaddr));
 
 	if (!addr || addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
@@ -392,7 +392,7 @@ static int rfcomm_sock_connect(struct socket *sock, struct sockaddr *addr, int a
 	struct rfcomm_dlc *d = rfcomm_pi(sk)->dlc;
 	int err = 0;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (alen < sizeof(struct sockaddr_rc) ||
 	    addr->sa_family != AF_BLUETOOTH)
@@ -432,7 +432,7 @@ static int rfcomm_sock_listen(struct socket *sock, int backlog)
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sk %p backlog %d", sk, backlog);
+	bt_dbg("sk %p backlog %d", sk, backlog);
 
 	lock_sock(sk);
 
@@ -497,7 +497,7 @@ static int rfcomm_sock_accept(struct socket *sock, struct socket *newsock, int f
 
 	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
 
-	BT_DBG("sk %p timeo %ld", sk, timeo);
+	bt_dbg("sk %p timeo %ld", sk, timeo);
 
 	/* Wait for an incoming connection. (wake-one). */
 	add_wait_queue_exclusive(sk_sleep(sk), &wait);
@@ -530,7 +530,7 @@ static int rfcomm_sock_accept(struct socket *sock, struct socket *newsock, int f
 
 	newsock->state = SS_CONNECTED;
 
-	BT_DBG("new socket %p", nsk);
+	bt_dbg("new socket %p", nsk);
 
 done:
 	release_sock(sk);
@@ -542,7 +542,7 @@ static int rfcomm_sock_getname(struct socket *sock, struct sockaddr *addr, int *
 	struct sockaddr_rc *sa = (struct sockaddr_rc *) addr;
 	struct sock *sk = sock->sk;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	sa->rc_family  = AF_BLUETOOTH;
 	sa->rc_channel = rfcomm_pi(sk)->channel;
@@ -572,7 +572,7 @@ static int rfcomm_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (sk->sk_shutdown & SEND_SHUTDOWN)
 		return -EPIPE;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	lock_sock(sk);
 
@@ -645,7 +645,7 @@ static int rfcomm_sock_setsockopt_old(struct socket *sock, int optname, char __u
 	int err = 0;
 	u32 opt;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	lock_sock(sk);
 
@@ -683,7 +683,7 @@ static int rfcomm_sock_setsockopt(struct socket *sock, int level, int optname, c
 	size_t len;
 	u32 opt;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (level == SOL_RFCOMM)
 		return rfcomm_sock_setsockopt_old(sock, optname, optval, optlen);
@@ -747,7 +747,7 @@ static int rfcomm_sock_getsockopt_old(struct socket *sock, int optname, char __u
 	int len, err = 0;
 	u32 opt;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (get_user(len, optlen))
 		return -EFAULT;
@@ -811,7 +811,7 @@ static int rfcomm_sock_getsockopt(struct socket *sock, int level, int optname, c
 	struct bt_security sec;
 	int len, err = 0;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (level == SOL_RFCOMM)
 		return rfcomm_sock_getsockopt_old(sock, optname, optval, optlen);
@@ -864,7 +864,7 @@ static int rfcomm_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned lon
 	struct sock *sk __maybe_unused = sock->sk;
 	int err;
 
-	BT_DBG("sk %p cmd %x arg %lx", sk, cmd, arg);
+	bt_dbg("sk %p cmd %x arg %lx", sk, cmd, arg);
 
 	err = bt_sock_ioctl(sock, cmd, arg);
 
@@ -886,7 +886,7 @@ static int rfcomm_sock_shutdown(struct socket *sock, int how)
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -908,7 +908,7 @@ static int rfcomm_sock_release(struct socket *sock)
 	struct sock *sk = sock->sk;
 	int err;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -930,7 +930,7 @@ int rfcomm_connect_ind(struct rfcomm_session *s, u8 channel, struct rfcomm_dlc *
 	bdaddr_t src, dst;
 	int result = 0;
 
-	BT_DBG("session %p channel %d", s, channel);
+	bt_dbg("session %p channel %d", s, channel);
 
 	rfcomm_session_getaddr(s, &src, &dst);
 
@@ -943,7 +943,7 @@ int rfcomm_connect_ind(struct rfcomm_session *s, u8 channel, struct rfcomm_dlc *
 
 	/* Check for backlog size */
 	if (sk_acceptq_is_full(parent)) {
-		BT_DBG("backlog full %d", parent->sk_ack_backlog);
+		bt_dbg("backlog full %d", parent->sk_ack_backlog);
 		goto done;
 	}
 
@@ -1047,15 +1047,15 @@ int __init rfcomm_init_sockets(void)
 		rfcomm_sock_debugfs = debugfs_create_file("rfcomm", 0444,
 				bt_debugfs, NULL, &rfcomm_sock_debugfs_fops);
 		if (!rfcomm_sock_debugfs)
-			BT_ERR("Failed to create RFCOMM debug file");
+			bt_err("Failed to create RFCOMM debug file");
 	}
 
-	BT_INFO("RFCOMM socket layer initialized");
+	bt_info("RFCOMM socket layer initialized");
 
 	return 0;
 
 error:
-	BT_ERR("RFCOMM socket layer registration failed");
+	bt_err("RFCOMM socket layer registration failed");
 	proto_unregister(&rfcomm_proto);
 	return err;
 }
@@ -1065,7 +1065,7 @@ void __exit rfcomm_cleanup_sockets(void)
 	debugfs_remove(rfcomm_sock_debugfs);
 
 	if (bt_sock_unregister(BTPROTO_RFCOMM) < 0)
-		BT_ERR("RFCOMM socket layer unregistration failed");
+		bt_err("RFCOMM socket layer unregistration failed");
 
 	proto_unregister(&rfcomm_proto);
 }
diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index c258796..313441d 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -88,7 +88,7 @@ static void rfcomm_dev_destruct(struct rfcomm_dev *dev)
 {
 	struct rfcomm_dlc *dlc = dev->dlc;
 
-	BT_DBG("dev %p dlc %p", dev, dlc);
+	bt_dbg("dev %p dlc %p", dev, dlc);
 
 	/* Refcount should only hit zero when called from rfcomm_dev_del()
 	   which will have taken us off the list. Everything else are
@@ -201,7 +201,7 @@ static int rfcomm_dev_add(struct rfcomm_dev_req *req, struct rfcomm_dlc *dlc)
 	struct list_head *head = &rfcomm_dev_list, *p;
 	int err = 0;
 
-	BT_DBG("id %d channel %d", req->dev_id, req->channel);
+	bt_dbg("id %d channel %d", req->dev_id, req->channel);
 
 	dev = kzalloc(sizeof(struct rfcomm_dev), GFP_KERNEL);
 	if (!dev)
@@ -310,10 +310,10 @@ out:
 	dev_set_drvdata(dev->tty_dev, dev);
 
 	if (device_create_file(dev->tty_dev, &dev_attr_address) < 0)
-		BT_ERR("Failed to create address attribute");
+		bt_err("Failed to create address attribute");
 
 	if (device_create_file(dev->tty_dev, &dev_attr_channel) < 0)
-		BT_ERR("Failed to create channel attribute");
+		bt_err("Failed to create channel attribute");
 
 	return dev->id;
 
@@ -324,7 +324,7 @@ free:
 
 static void rfcomm_dev_del(struct rfcomm_dev *dev)
 {
-	BT_DBG("dev %p", dev);
+	bt_dbg("dev %p", dev);
 
 	BUG_ON(test_and_set_bit(RFCOMM_TTY_RELEASED, &dev->flags));
 
@@ -388,7 +388,7 @@ static int rfcomm_create_dev(struct sock *sk, void __user *arg)
 	if (copy_from_user(&req, arg, sizeof(req)))
 		return -EFAULT;
 
-	BT_DBG("sk %p dev_id %d flags 0x%x", sk, req.dev_id, req.flags);
+	bt_dbg("sk %p dev_id %d flags 0x%x", sk, req.dev_id, req.flags);
 
 	if (req.flags != NOCAP_FLAGS && !capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -429,7 +429,7 @@ static int rfcomm_release_dev(void __user *arg)
 	if (copy_from_user(&req, arg, sizeof(req)))
 		return -EFAULT;
 
-	BT_DBG("dev_id %d flags 0x%x", req.dev_id, req.flags);
+	bt_dbg("dev_id %d flags 0x%x", req.dev_id, req.flags);
 
 	dev = rfcomm_dev_get(req.dev_id);
 	if (!dev)
@@ -461,7 +461,7 @@ static int rfcomm_get_dev_list(void __user *arg)
 	int n = 0, size, err;
 	u16 dev_num;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	if (get_user(dev_num, (u16 __user *) arg))
 		return -EFAULT;
@@ -510,7 +510,7 @@ static int rfcomm_get_dev_info(void __user *arg)
 	struct rfcomm_dev_info di;
 	int err = 0;
 
-	BT_DBG("");
+	bt_dbg("");
 
 	if (copy_from_user(&di, arg, sizeof(di)))
 		return -EFAULT;
@@ -534,7 +534,7 @@ static int rfcomm_get_dev_info(void __user *arg)
 
 int rfcomm_dev_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 {
-	BT_DBG("cmd %d arg %p", cmd, arg);
+	bt_dbg("cmd %d arg %p", cmd, arg);
 
 	switch (cmd) {
 	case RFCOMMCREATEDEV:
@@ -570,7 +570,7 @@ static void rfcomm_dev_data_ready(struct rfcomm_dlc *dlc, struct sk_buff *skb)
 		return;
 	}
 
-	BT_DBG("dlc %p tty %p len %d", dlc, tty, skb->len);
+	bt_dbg("dlc %p tty %p len %d", dlc, tty, skb->len);
 
 	tty_insert_flip_string(tty, skb->data, skb->len);
 	tty_flip_buffer_push(tty);
@@ -584,7 +584,7 @@ static void rfcomm_dev_state_change(struct rfcomm_dlc *dlc, int err)
 	if (!dev)
 		return;
 
-	BT_DBG("dlc %p dev %p err %d", dlc, dev, err);
+	bt_dbg("dlc %p dev %p err %d", dlc, dev, err);
 
 	dev->err = err;
 	wake_up_interruptible(&dev->wait);
@@ -620,7 +620,7 @@ static void rfcomm_dev_modem_status(struct rfcomm_dlc *dlc, u8 v24_sig)
 	if (!dev)
 		return;
 
-	BT_DBG("dlc %p dev %p v24_sig 0x%02x", dlc, dev, v24_sig);
+	bt_dbg("dlc %p dev %p v24_sig 0x%02x", dlc, dev, v24_sig);
 
 	if ((dev->modem_status & TIOCM_CD) && !(v24_sig & RFCOMM_V24_DV)) {
 		if (dev->tty && !C_CLOCAL(dev->tty))
@@ -642,7 +642,7 @@ static void rfcomm_tty_wakeup(unsigned long arg)
 	if (!tty)
 		return;
 
-	BT_DBG("dev %p tty %p", dev, tty);
+	bt_dbg("dev %p tty %p", dev, tty);
 	tty_wakeup(tty);
 }
 
@@ -655,7 +655,7 @@ static void rfcomm_tty_copy_pending(struct rfcomm_dev *dev)
 	if (!tty)
 		return;
 
-	BT_DBG("dev %p tty %p", dev, tty);
+	bt_dbg("dev %p tty %p", dev, tty);
 
 	rfcomm_dlc_lock(dev->dlc);
 
@@ -679,7 +679,7 @@ static int rfcomm_tty_open(struct tty_struct *tty, struct file *filp)
 
 	id = tty->index;
 
-	BT_DBG("tty %p id %d", tty, id);
+	bt_dbg("tty %p id %d", tty, id);
 
 	/* We don't leak this refcount. For reasons which are not entirely
 	   clear, the TTY layer will call our ->close() method even if the
@@ -689,7 +689,7 @@ static int rfcomm_tty_open(struct tty_struct *tty, struct file *filp)
 	if (!dev)
 		return -ENODEV;
 
-	BT_DBG("dev %p dst %s channel %d opened %d", dev, batostr(&dev->dst),
+	bt_dbg("dev %p dst %s channel %d opened %d", dev, batostr(&dev->dst),
 				dev->channel, atomic_read(&dev->opened));
 
 	if (atomic_inc_return(&dev->opened) > 1)
@@ -751,7 +751,7 @@ static void rfcomm_tty_close(struct tty_struct *tty, struct file *filp)
 	if (!dev)
 		return;
 
-	BT_DBG("tty %p dev %p dlc %p opened %d", tty, dev, dev->dlc,
+	bt_dbg("tty %p dev %p dlc %p opened %d", tty, dev, dev->dlc,
 						atomic_read(&dev->opened));
 
 	if (atomic_dec_and_test(&dev->opened)) {
@@ -788,7 +788,7 @@ static int rfcomm_tty_write(struct tty_struct *tty, const unsigned char *buf, in
 	struct sk_buff *skb;
 	int err = 0, sent = 0, size;
 
-	BT_DBG("tty %p count %d", tty, count);
+	bt_dbg("tty %p count %d", tty, count);
 
 	while (count) {
 		size = min_t(uint, count, dlc->mtu);
@@ -820,7 +820,7 @@ static int rfcomm_tty_write_room(struct tty_struct *tty)
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 	int room;
 
-	BT_DBG("tty %p", tty);
+	bt_dbg("tty %p", tty);
 
 	if (!dev || !dev->dlc)
 		return 0;
@@ -834,39 +834,39 @@ static int rfcomm_tty_write_room(struct tty_struct *tty)
 
 static int rfcomm_tty_ioctl(struct tty_struct *tty, unsigned int cmd, unsigned long arg)
 {
-	BT_DBG("tty %p cmd 0x%02x", tty, cmd);
+	bt_dbg("tty %p cmd 0x%02x", tty, cmd);
 
 	switch (cmd) {
 	case TCGETS:
-		BT_DBG("TCGETS is not supported");
+		bt_dbg("TCGETS is not supported");
 		return -ENOIOCTLCMD;
 
 	case TCSETS:
-		BT_DBG("TCSETS is not supported");
+		bt_dbg("TCSETS is not supported");
 		return -ENOIOCTLCMD;
 
 	case TIOCMIWAIT:
-		BT_DBG("TIOCMIWAIT");
+		bt_dbg("TIOCMIWAIT");
 		break;
 
 	case TIOCGSERIAL:
-		BT_ERR("TIOCGSERIAL is not supported");
+		bt_err("TIOCGSERIAL is not supported");
 		return -ENOIOCTLCMD;
 
 	case TIOCSSERIAL:
-		BT_ERR("TIOCSSERIAL is not supported");
+		bt_err("TIOCSSERIAL is not supported");
 		return -ENOIOCTLCMD;
 
 	case TIOCSERGSTRUCT:
-		BT_ERR("TIOCSERGSTRUCT is not supported");
+		bt_err("TIOCSERGSTRUCT is not supported");
 		return -ENOIOCTLCMD;
 
 	case TIOCSERGETLSR:
-		BT_ERR("TIOCSERGETLSR is not supported");
+		bt_err("TIOCSERGETLSR is not supported");
 		return -ENOIOCTLCMD;
 
 	case TIOCSERCONFIG:
-		BT_ERR("TIOCSERCONFIG is not supported");
+		bt_err("TIOCSERCONFIG is not supported");
 		return -ENOIOCTLCMD;
 
 	default:
@@ -888,52 +888,52 @@ static void rfcomm_tty_set_termios(struct tty_struct *tty, struct ktermios *old)
 
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p termios %p", tty, old);
+	bt_dbg("tty %p termios %p", tty, old);
 
 	if (!dev || !dev->dlc || !dev->dlc->session)
 		return;
 
 	/* Handle turning off CRTSCTS */
 	if ((old->c_cflag & CRTSCTS) && !(new->c_cflag & CRTSCTS))
-		BT_DBG("Turning off CRTSCTS unsupported");
+		bt_dbg("Turning off CRTSCTS unsupported");
 
 	/* Parity on/off and when on, odd/even */
 	if (((old->c_cflag & PARENB) != (new->c_cflag & PARENB)) ||
 			((old->c_cflag & PARODD) != (new->c_cflag & PARODD))) {
 		changes |= RFCOMM_RPN_PM_PARITY;
-		BT_DBG("Parity change detected.");
+		bt_dbg("Parity change detected.");
 	}
 
 	/* Mark and space parity are not supported! */
 	if (new->c_cflag & PARENB) {
 		if (new->c_cflag & PARODD) {
-			BT_DBG("Parity is ODD");
+			bt_dbg("Parity is ODD");
 			parity = RFCOMM_RPN_PARITY_ODD;
 		} else {
-			BT_DBG("Parity is EVEN");
+			bt_dbg("Parity is EVEN");
 			parity = RFCOMM_RPN_PARITY_EVEN;
 		}
 	} else {
-		BT_DBG("Parity is OFF");
+		bt_dbg("Parity is OFF");
 		parity = RFCOMM_RPN_PARITY_NONE;
 	}
 
 	/* Setting the x_on / x_off characters */
 	if (old->c_cc[VSTOP] != new->c_cc[VSTOP]) {
-		BT_DBG("XOFF custom");
+		bt_dbg("XOFF custom");
 		x_on = new->c_cc[VSTOP];
 		changes |= RFCOMM_RPN_PM_XON;
 	} else {
-		BT_DBG("XOFF default");
+		bt_dbg("XOFF default");
 		x_on = RFCOMM_RPN_XON_CHAR;
 	}
 
 	if (old->c_cc[VSTART] != new->c_cc[VSTART]) {
-		BT_DBG("XON custom");
+		bt_dbg("XON custom");
 		x_off = new->c_cc[VSTART];
 		changes |= RFCOMM_RPN_PM_XOFF;
 	} else {
-		BT_DBG("XON default");
+		bt_dbg("XON default");
 		x_off = RFCOMM_RPN_XOFF_CHAR;
 	}
 
@@ -1020,7 +1020,7 @@ static void rfcomm_tty_throttle(struct tty_struct *tty)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p dev %p", tty, dev);
+	bt_dbg("tty %p dev %p", tty, dev);
 
 	rfcomm_dlc_throttle(dev->dlc);
 }
@@ -1029,7 +1029,7 @@ static void rfcomm_tty_unthrottle(struct tty_struct *tty)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p dev %p", tty, dev);
+	bt_dbg("tty %p dev %p", tty, dev);
 
 	rfcomm_dlc_unthrottle(dev->dlc);
 }
@@ -1038,7 +1038,7 @@ static int rfcomm_tty_chars_in_buffer(struct tty_struct *tty)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p dev %p", tty, dev);
+	bt_dbg("tty %p dev %p", tty, dev);
 
 	if (!dev || !dev->dlc)
 		return 0;
@@ -1053,7 +1053,7 @@ static void rfcomm_tty_flush_buffer(struct tty_struct *tty)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p dev %p", tty, dev);
+	bt_dbg("tty %p dev %p", tty, dev);
 
 	if (!dev || !dev->dlc)
 		return;
@@ -1064,19 +1064,19 @@ static void rfcomm_tty_flush_buffer(struct tty_struct *tty)
 
 static void rfcomm_tty_send_xchar(struct tty_struct *tty, char ch)
 {
-	BT_DBG("tty %p ch %c", tty, ch);
+	bt_dbg("tty %p ch %c", tty, ch);
 }
 
 static void rfcomm_tty_wait_until_sent(struct tty_struct *tty, int timeout)
 {
-	BT_DBG("tty %p timeout %d", tty, timeout);
+	bt_dbg("tty %p timeout %d", tty, timeout);
 }
 
 static void rfcomm_tty_hangup(struct tty_struct *tty)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p dev %p", tty, dev);
+	bt_dbg("tty %p dev %p", tty, dev);
 
 	if (!dev)
 		return;
@@ -1095,7 +1095,7 @@ static int rfcomm_tty_tiocmget(struct tty_struct *tty)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p dev %p", tty, dev);
+	bt_dbg("tty %p dev %p", tty, dev);
 
 	return dev->modem_status;
 }
@@ -1106,7 +1106,7 @@ static int rfcomm_tty_tiocmset(struct tty_struct *tty, unsigned int set, unsigne
 	struct rfcomm_dlc *dlc = dev->dlc;
 	u8 v24_sig;
 
-	BT_DBG("tty %p dev %p set 0x%02x clear 0x%02x", tty, dev, set, clear);
+	bt_dbg("tty %p dev %p set 0x%02x clear 0x%02x", tty, dev, set, clear);
 
 	rfcomm_dlc_get_modem_status(dlc, &v24_sig);
 
@@ -1173,12 +1173,12 @@ int __init rfcomm_init_ttys(void)
 	tty_set_operations(rfcomm_tty_driver, &rfcomm_ops);
 
 	if (tty_register_driver(rfcomm_tty_driver)) {
-		BT_ERR("Can't register RFCOMM TTY driver");
+		bt_err("Can't register RFCOMM TTY driver");
 		put_tty_driver(rfcomm_tty_driver);
 		return -1;
 	}
 
-	BT_INFO("RFCOMM TTY layer initialized");
+	bt_info("RFCOMM TTY layer initialized");
 
 	return 0;
 }
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 4c3621b..db0bc64 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -71,7 +71,7 @@ static void sco_sock_timeout(unsigned long arg)
 {
 	struct sock *sk = (struct sock *) arg;
 
-	BT_DBG("sock %p state %d", sk, sk->sk_state);
+	bt_dbg("sock %p state %d", sk, sk->sk_state);
 
 	bh_lock_sock(sk);
 	sk->sk_err = ETIMEDOUT;
@@ -84,13 +84,13 @@ static void sco_sock_timeout(unsigned long arg)
 
 static void sco_sock_set_timer(struct sock *sk, long timeout)
 {
-	BT_DBG("sock %p state %d timeout %ld", sk, sk->sk_state, timeout);
+	bt_dbg("sock %p state %d timeout %ld", sk, sk->sk_state, timeout);
 	sk_reset_timer(sk, &sk->sk_timer, jiffies + timeout);
 }
 
 static void sco_sock_clear_timer(struct sock *sk)
 {
-	BT_DBG("sock %p state %d", sk, sk->sk_state);
+	bt_dbg("sock %p state %d", sk, sk->sk_state);
 	sk_stop_timer(sk, &sk->sk_timer);
 }
 
@@ -120,7 +120,7 @@ static struct sco_conn *sco_conn_add(struct hci_conn *hcon, __u8 status)
 	else
 		conn->mtu = 60;
 
-	BT_DBG("hcon %p conn %p", hcon, conn);
+	bt_dbg("hcon %p conn %p", hcon, conn);
 
 	return conn;
 }
@@ -142,7 +142,7 @@ static int sco_conn_del(struct hci_conn *hcon, int err)
 	if (!conn)
 		return 0;
 
-	BT_DBG("hcon %p conn %p, err %d", hcon, conn, err);
+	bt_dbg("hcon %p conn %p, err %d", hcon, conn, err);
 
 	/* Kill socket */
 	sk = sco_chan_get(conn);
@@ -182,7 +182,7 @@ static int sco_connect(struct sock *sk)
 	struct hci_dev  *hdev;
 	int err, type;
 
-	BT_DBG("%s -> %s", batostr(src), batostr(dst));
+	bt_dbg("%s -> %s", batostr(src), batostr(dst));
 
 	hdev = hci_get_route(dst, src);
 	if (!hdev)
@@ -239,7 +239,7 @@ static inline int sco_send_frame(struct sock *sk, struct msghdr *msg, int len)
 	if (len > conn->mtu)
 		return -EINVAL;
 
-	BT_DBG("sk %p len %d", sk, len);
+	bt_dbg("sk %p len %d", sk, len);
 
 	count = min_t(unsigned int, conn->mtu, len);
 	skb = bt_skb_send_alloc(sk, count,
@@ -264,7 +264,7 @@ static inline void sco_recv_frame(struct sco_conn *conn, struct sk_buff *skb)
 	if (!sk)
 		goto drop;
 
-	BT_DBG("sk %p len %d", sk, skb->len);
+	bt_dbg("sk %p len %d", sk, skb->len);
 
 	if (sk->sk_state != BT_CONNECTED)
 		goto drop;
@@ -320,7 +320,7 @@ static struct sock *sco_get_sock_listen(bdaddr_t *src)
 
 static void sco_sock_destruct(struct sock *sk)
 {
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	skb_queue_purge(&sk->sk_receive_queue);
 	skb_queue_purge(&sk->sk_write_queue);
@@ -330,7 +330,7 @@ static void sco_sock_cleanup_listen(struct sock *parent)
 {
 	struct sock *sk;
 
-	BT_DBG("parent %p", parent);
+	bt_dbg("parent %p", parent);
 
 	/* Close not yet accepted channels */
 	while ((sk = bt_accept_dequeue(parent, NULL))) {
@@ -350,7 +350,7 @@ static void sco_sock_kill(struct sock *sk)
 	if (!sock_flag(sk, SOCK_ZAPPED) || sk->sk_socket)
 		return;
 
-	BT_DBG("sk %p state %d", sk, sk->sk_state);
+	bt_dbg("sk %p state %d", sk, sk->sk_state);
 
 	/* Kill poor orphan */
 	bt_sock_unlink(&sco_sk_list, sk);
@@ -360,7 +360,7 @@ static void sco_sock_kill(struct sock *sk)
 
 static void __sco_sock_close(struct sock *sk)
 {
-	BT_DBG("sk %p state %d socket %p", sk, sk->sk_state, sk->sk_socket);
+	bt_dbg("sk %p state %d socket %p", sk, sk->sk_state, sk->sk_socket);
 
 	switch (sk->sk_state) {
 	case BT_LISTEN:
@@ -401,7 +401,7 @@ static void sco_sock_close(struct sock *sk)
 
 static void sco_sock_init(struct sock *sk, struct sock *parent)
 {
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (parent)
 		sk->sk_type = parent->sk_type;
@@ -443,7 +443,7 @@ static int sco_sock_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	bt_dbg("sock %p", sock);
 
 	sock->state = SS_UNCONNECTED;
 
@@ -467,7 +467,7 @@ static int sco_sock_bind(struct socket *sock, struct sockaddr *addr, int addr_le
 	bdaddr_t *src = &sa->sco_bdaddr;
 	int err = 0;
 
-	BT_DBG("sk %p %s", sk, batostr(&sa->sco_bdaddr));
+	bt_dbg("sk %p %s", sk, batostr(&sa->sco_bdaddr));
 
 	if (!addr || addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
@@ -503,7 +503,7 @@ static int sco_sock_connect(struct socket *sock, struct sockaddr *addr, int alen
 	int err = 0;
 
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (alen < sizeof(struct sockaddr_sco) ||
 	    addr->sa_family != AF_BLUETOOTH)
@@ -537,7 +537,7 @@ static int sco_sock_listen(struct socket *sock, int backlog)
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sk %p backlog %d", sk, backlog);
+	bt_dbg("sk %p backlog %d", sk, backlog);
 
 	lock_sock(sk);
 
@@ -571,7 +571,7 @@ static int sco_sock_accept(struct socket *sock, struct socket *newsock, int flag
 
 	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
 
-	BT_DBG("sk %p timeo %ld", sk, timeo);
+	bt_dbg("sk %p timeo %ld", sk, timeo);
 
 	/* Wait for an incoming connection. (wake-one). */
 	add_wait_queue_exclusive(sk_sleep(sk), &wait);
@@ -604,7 +604,7 @@ static int sco_sock_accept(struct socket *sock, struct socket *newsock, int flag
 
 	newsock->state = SS_CONNECTED;
 
-	BT_DBG("new socket %p", ch);
+	bt_dbg("new socket %p", ch);
 
 done:
 	release_sock(sk);
@@ -616,7 +616,7 @@ static int sco_sock_getname(struct socket *sock, struct sockaddr *addr, int *len
 	struct sockaddr_sco *sa = (struct sockaddr_sco *) addr;
 	struct sock *sk = sock->sk;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	addr->sa_family = AF_BLUETOOTH;
 	*len = sizeof(struct sockaddr_sco);
@@ -635,7 +635,7 @@ static int sco_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	int err;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	err = sock_error(sk);
 	if (err)
@@ -660,7 +660,7 @@ static int sco_sock_setsockopt(struct socket *sock, int level, int optname, char
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	lock_sock(sk);
 
@@ -681,7 +681,7 @@ static int sco_sock_getsockopt_old(struct socket *sock, int optname, char __user
 	struct sco_conninfo cinfo;
 	int len, err = 0;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (get_user(len, optlen))
 		return -EFAULT;
@@ -697,7 +697,7 @@ static int sco_sock_getsockopt_old(struct socket *sock, int optname, char __user
 
 		opts.mtu = sco_pi(sk)->conn->mtu;
 
-		BT_DBG("mtu %d", opts.mtu);
+		bt_dbg("mtu %d", opts.mtu);
 
 		len = min_t(unsigned int, len, sizeof(opts));
 		if (copy_to_user(optval, (char *)&opts, len))
@@ -735,7 +735,7 @@ static int sco_sock_getsockopt(struct socket *sock, int level, int optname, char
 	struct sock *sk = sock->sk;
 	int len, err = 0;
 
-	BT_DBG("sk %p", sk);
+	bt_dbg("sk %p", sk);
 
 	if (level == SOL_SCO)
 		return sco_sock_getsockopt_old(sock, optname, optval, optlen);
@@ -760,7 +760,7 @@ static int sco_sock_shutdown(struct socket *sock, int how)
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -784,7 +784,7 @@ static int sco_sock_release(struct socket *sock)
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	bt_dbg("sock %p, sk %p", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -804,7 +804,7 @@ static int sco_sock_release(struct socket *sock)
 
 static void __sco_chan_add(struct sco_conn *conn, struct sock *sk, struct sock *parent)
 {
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	sco_pi(sk)->conn = conn;
 	conn->sk = sk;
@@ -821,7 +821,7 @@ static void sco_chan_del(struct sock *sk, int err)
 
 	conn = sco_pi(sk)->conn;
 
-	BT_DBG("sk %p, conn %p, err %d", sk, conn, err);
+	bt_dbg("sk %p, conn %p, err %d", sk, conn, err);
 
 	if (conn) {
 		sco_conn_lock(conn);
@@ -845,7 +845,7 @@ static void sco_conn_ready(struct sco_conn *conn)
 	struct sock *parent;
 	struct sock *sk = conn->sk;
 
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	sco_conn_lock(conn);
 
@@ -899,7 +899,7 @@ static int sco_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr, __u8 type)
 	if (type != SCO_LINK && type != ESCO_LINK)
 		return -EINVAL;
 
-	BT_DBG("hdev %s, bdaddr %s", hdev->name, batostr(bdaddr));
+	bt_dbg("hdev %s, bdaddr %s", hdev->name, batostr(bdaddr));
 
 	/* Find listening sockets */
 	read_lock(&sco_sk_list.lock);
@@ -920,7 +920,7 @@ static int sco_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr, __u8 type)
 
 static int sco_connect_cfm(struct hci_conn *hcon, __u8 status)
 {
-	BT_DBG("hcon %p bdaddr %s status %d", hcon, batostr(&hcon->dst), status);
+	bt_dbg("hcon %p bdaddr %s status %d", hcon, batostr(&hcon->dst), status);
 
 	if (hcon->type != SCO_LINK && hcon->type != ESCO_LINK)
 		return -EINVAL;
@@ -939,7 +939,7 @@ static int sco_connect_cfm(struct hci_conn *hcon, __u8 status)
 
 static int sco_disconn_cfm(struct hci_conn *hcon, __u8 reason)
 {
-	BT_DBG("hcon %p reason %d", hcon, reason);
+	bt_dbg("hcon %p reason %d", hcon, reason);
 
 	if (hcon->type != SCO_LINK && hcon->type != ESCO_LINK)
 		return -EINVAL;
@@ -956,7 +956,7 @@ static int sco_recv_scodata(struct hci_conn *hcon, struct sk_buff *skb)
 	if (!conn)
 		goto drop;
 
-	BT_DBG("conn %p len %d", conn, skb->len);
+	bt_dbg("conn %p len %d", conn, skb->len);
 
 	if (skb->len) {
 		sco_recv_frame(conn, skb);
@@ -1044,13 +1044,13 @@ int __init sco_init(void)
 
 	err = bt_sock_register(BTPROTO_SCO, &sco_sock_family_ops);
 	if (err < 0) {
-		BT_ERR("SCO socket registration failed");
+		bt_err("SCO socket registration failed");
 		goto error;
 	}
 
 	err = hci_register_proto(&sco_hci_proto);
 	if (err < 0) {
-		BT_ERR("SCO protocol registration failed");
+		bt_err("SCO protocol registration failed");
 		bt_sock_unregister(BTPROTO_SCO);
 		goto error;
 	}
@@ -1059,10 +1059,10 @@ int __init sco_init(void)
 		sco_debugfs = debugfs_create_file("sco", 0444,
 					bt_debugfs, NULL, &sco_debugfs_fops);
 		if (!sco_debugfs)
-			BT_ERR("Failed to create SCO debug file");
+			bt_err("Failed to create SCO debug file");
 	}
 
-	BT_INFO("SCO socket layer initialized");
+	bt_info("SCO socket layer initialized");
 
 	return 0;
 
@@ -1076,10 +1076,10 @@ void __exit sco_exit(void)
 	debugfs_remove(sco_debugfs);
 
 	if (bt_sock_unregister(BTPROTO_SCO) < 0)
-		BT_ERR("SCO socket unregistration failed");
+		bt_err("SCO socket unregistration failed");
 
 	if (hci_unregister_proto(&sco_hci_proto) < 0)
-		BT_ERR("SCO protocol unregistration failed");
+		bt_err("SCO protocol unregistration failed");
 
 	proto_unregister(&sco_proto);
 }
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index a36f870..6e14fab 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -52,7 +52,7 @@ static int smp_e(struct crypto_blkcipher *tfm, const u8 *k, u8 *r)
 	unsigned char iv[128];
 
 	if (tfm == NULL) {
-		BT_ERR("tfm %p", tfm);
+		bt_err("tfm %p", tfm);
 		return -EINVAL;
 	}
 
@@ -61,7 +61,7 @@ static int smp_e(struct crypto_blkcipher *tfm, const u8 *k, u8 *r)
 
 	err = crypto_blkcipher_setkey(tfm, k, 16);
 	if (err) {
-		BT_ERR("cipher setkey failed: %d", err);
+		bt_err("cipher setkey failed: %d", err);
 		return err;
 	}
 
@@ -75,7 +75,7 @@ static int smp_e(struct crypto_blkcipher *tfm, const u8 *k, u8 *r)
 
 	err = crypto_blkcipher_encrypt(&desc, &sg, &sg, 16);
 	if (err)
-		BT_ERR("Encrypt data error %d", err);
+		bt_err("Encrypt data error %d", err);
 
 	return err;
 }
@@ -107,7 +107,7 @@ static int smp_c1(struct crypto_blkcipher *tfm, u8 k[16], u8 r[16],
 	/* res = e(k, res) */
 	err = smp_e(tfm, k, res);
 	if (err) {
-		BT_ERR("Encrypt data error");
+		bt_err("Encrypt data error");
 		return err;
 	}
 
@@ -117,7 +117,7 @@ static int smp_c1(struct crypto_blkcipher *tfm, u8 k[16], u8 r[16],
 	/* res = e(k, res) */
 	err = smp_e(tfm, k, res);
 	if (err)
-		BT_ERR("Encrypt data error");
+		bt_err("Encrypt data error");
 
 	return err;
 }
@@ -133,7 +133,7 @@ static int smp_s1(struct crypto_blkcipher *tfm, u8 k[16],
 
 	err = smp_e(tfm, k, _r);
 	if (err)
-		BT_ERR("Encrypt data error");
+		bt_err("Encrypt data error");
 
 	return err;
 }
@@ -176,7 +176,7 @@ static void smp_send_cmd(struct l2cap_conn *conn, u8 code, u16 len, void *data)
 {
 	struct sk_buff *skb = smp_build_cmd(conn, code, len, data);
 
-	BT_DBG("code 0x%2.2x", code);
+	bt_dbg("code 0x%2.2x", code);
 
 	if (!skb)
 		return;
@@ -223,7 +223,7 @@ static u8 smp_cmd_pairing_req(struct l2cap_conn *conn, struct sk_buff *skb)
 	struct smp_cmd_pairing rsp, *req = (void *) skb->data;
 	u8 key_size;
 
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	conn->preq[0] = SMP_CMD_PAIRING_REQ;
 	memcpy(&conn->preq[1], req, sizeof(*req));
@@ -261,7 +261,7 @@ static u8 smp_cmd_pairing_rsp(struct l2cap_conn *conn, struct sk_buff *skb)
 	int ret;
 	u8 res[16], key_size;
 
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	skb_pull(skb, sizeof(*rsp));
 
@@ -300,7 +300,7 @@ static u8 smp_cmd_pairing_confirm(struct l2cap_conn *conn, struct sk_buff *skb)
 {
 	struct crypto_blkcipher *tfm = conn->hcon->hdev->tfm;
 
-	BT_DBG("conn %p %s", conn, conn->hcon->out ? "master" : "slave");
+	bt_dbg("conn %p %s", conn, conn->hcon->out ? "master" : "slave");
 
 	memcpy(conn->pcnf, skb->data, sizeof(conn->pcnf));
 	skb_pull(skb, sizeof(conn->pcnf));
@@ -360,12 +360,12 @@ static u8 smp_cmd_pairing_random(struct l2cap_conn *conn, struct sk_buff *skb)
 	if (ret)
 		return SMP_UNSPECIFIED;
 
-	BT_DBG("conn %p %s", conn, conn->hcon->out ? "master" : "slave");
+	bt_dbg("conn %p %s", conn, conn->hcon->out ? "master" : "slave");
 
 	swap128(res, confirm);
 
 	if (memcmp(conn->pcnf, confirm, sizeof(conn->pcnf)) != 0) {
-		BT_ERR("Pairing failed (confirmation values mismatch)");
+		bt_err("Pairing failed (confirmation values mismatch)");
 		return SMP_CONFIRM_FAILED;
 	}
 
@@ -404,7 +404,7 @@ static u8 smp_cmd_security_req(struct l2cap_conn *conn, struct sk_buff *skb)
 	struct smp_cmd_pairing cp;
 	struct hci_conn *hcon = conn->hcon;
 
-	BT_DBG("conn %p", conn);
+	bt_dbg("conn %p", conn);
 
 	if (test_bit(HCI_CONN_ENCRYPT_PEND, &hcon->pend))
 		return 0;
@@ -432,7 +432,7 @@ int smp_conn_security(struct l2cap_conn *conn, __u8 sec_level)
 	struct hci_conn *hcon = conn->hcon;
 	__u8 authreq;
 
-	BT_DBG("conn %p hcon %p level 0x%2.2x", conn, hcon, sec_level);
+	bt_dbg("conn %p hcon %p level 0x%2.2x", conn, hcon, sec_level);
 
 	if (IS_ERR(hcon->hdev->tfm))
 		return 1;
@@ -517,7 +517,7 @@ int smp_sig_channel(struct l2cap_conn *conn, struct sk_buff *skb)
 	case SMP_CMD_IDENT_ADDR_INFO:
 	case SMP_CMD_SIGN_INFO:
 	default:
-		BT_DBG("Unknown command code 0x%2.2x", code);
+		bt_dbg("Unknown command code 0x%2.2x", code);
 
 		reason = SMP_CMD_NOTSUPP;
 		err = -EOPNOTSUPP;
-- 
1.7.6.rc1

