From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 3/3] bluetooth: Convert BT_DBG to pr_debug
Date: Thu, 16 Feb 2012 23:32:44 -0800
Message-ID: <6e53178ca0d6ca35c4953e653571d03379759af5.1329461203.git.joe@perches.com>
References: <cover.1329461202.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:40102 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751210Ab2BQHe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Feb 2012 02:34:27 -0500
In-Reply-To: <cover.1329461202.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to obfuscate, just use the normal debugging macro.

Add "\n" to uses, align arguments, coalesce formats.
Fix a typo and fix a bad format extended by a line continuation.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/bluetooth/ath3k.c       |   10 +-
 drivers/bluetooth/bcm203x.c     |   10 +-
 drivers/bluetooth/bfusb.c       |   35 +++---
 drivers/bluetooth/bpa10x.c      |   30 ++--
 drivers/bluetooth/btmrvl_main.c |   63 +++++-----
 drivers/bluetooth/btmrvl_sdio.c |   27 ++--
 drivers/bluetooth/btsdio.c      |   24 ++--
 drivers/bluetooth/btusb.c       |   48 ++++----
 drivers/bluetooth/btwilink.c    |   17 +--
 drivers/bluetooth/hci_ath.c     |    8 +-
 drivers/bluetooth/hci_bcsp.c    |   28 ++--
 drivers/bluetooth/hci_h4.c      |   10 +-
 drivers/bluetooth/hci_ldisc.c   |   23 ++--
 drivers/bluetooth/hci_ll.c      |   50 ++++----
 include/net/bluetooth/l2cap.h   |    2 +-
 net/bluetooth/af_bluetooth.c    |   16 +-
 net/bluetooth/bnep/core.c       |   26 ++--
 net/bluetooth/bnep/netdev.c     |   12 +-
 net/bluetooth/bnep/sock.c       |    6 +-
 net/bluetooth/cmtp/capi.c       |   31 +++--
 net/bluetooth/cmtp/core.c       |   23 ++--
 net/bluetooth/cmtp/sock.c       |    6 +-
 net/bluetooth/hci_conn.c        |   58 ++++----
 net/bluetooth/hci_core.c        |  151 +++++++++++----------
 net/bluetooth/hci_event.c       |  282 ++++++++++++++++++++-------------------
 net/bluetooth/hci_sock.c        |   20 ++--
 net/bluetooth/hci_sysfs.c       |    8 +-
 net/bluetooth/hidp/core.c       |   44 ++++---
 net/bluetooth/hidp/sock.c       |    6 +-
 net/bluetooth/l2cap_core.c      |  189 ++++++++++++++-------------
 net/bluetooth/l2cap_sock.c      |   34 +++---
 net/bluetooth/mgmt.c            |   89 ++++++------
 net/bluetooth/rfcomm/core.c     |  164 ++++++++++++-----------
 net/bluetooth/rfcomm/sock.c     |   49 ++++----
 net/bluetooth/rfcomm/tty.c      |   88 ++++++------
 net/bluetooth/sco.c             |   69 +++++-----
 net/bluetooth/smp.c             |   33 +++---
 37 files changed, 915 insertions(+), 874 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index f4511b2..dbca924 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -102,7 +102,7 @@ static int ath3k_load_firmware(struct usb_device *udev,
 	int err, pipe, len, size, sent = 0;
 	int count = firmware->size;
 
-	BT_DBG("udev %p", udev);
+	pr_debug("udev %p\n", udev);
 
 	pipe = usb_sndctrlpipe(udev, 0);
 
@@ -243,7 +243,7 @@ static int ath3k_set_normal_mode(struct usb_device *udev)
 	}
 
 	if ((fw_state & ATH3K_MODE_MASK) == ATH3K_NORMAL_MODE) {
-		BT_DBG("firmware was already in normal mode");
+		pr_debug("firmware was already in normal mode\n");
 		return 0;
 	}
 
@@ -268,7 +268,7 @@ static int ath3k_load_patch(struct usb_device *udev)
 	}
 
 	if (fw_state & ATH3K_PATCH_UPDATE) {
-		BT_DBG("Patch was already downloaded");
+		pr_debug("Patch was already downloaded\n");
 		return 0;
 	}
 
@@ -362,7 +362,7 @@ static int ath3k_probe(struct usb_interface *intf,
 	struct usb_device *udev = interface_to_usbdev(intf);
 	int ret;
 
-	BT_DBG("intf %p id %p", intf, id);
+	pr_debug("intf %p id %p\n", intf, id);
 
 	if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
 		return -ENODEV;
@@ -420,7 +420,7 @@ static int ath3k_probe(struct usb_interface *intf,
 
 static void ath3k_disconnect(struct usb_interface *intf)
 {
-	BT_DBG("ath3k_disconnect intf %p", intf);
+	pr_debug("ath3k_disconnect intf %p\n", intf);
 }
 
 static struct usb_driver ath3k_driver = {
diff --git a/drivers/bluetooth/bcm203x.c b/drivers/bluetooth/bcm203x.c
index d30c94c..f124c13 100644
--- a/drivers/bluetooth/bcm203x.c
+++ b/drivers/bluetooth/bcm203x.c
@@ -82,7 +82,7 @@ static void bcm203x_complete(struct urb *urb)
 	struct usb_device *udev = urb->dev;
 	int len;
 
-	BT_DBG("udev %p urb %p", udev, urb);
+	pr_debug("udev %p urb %p\n", udev, urb);
 
 	if (urb->status) {
 		bt_err("URB failed with status %d\n", urb->status);
@@ -172,7 +172,7 @@ static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id
 	struct bcm203x_data *data;
 	int size;
 
-	BT_DBG("intf %p id %p", intf, id);
+	pr_debug("intf %p id %p\n", intf, id);
 
 	if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
 		return -ENODEV;
@@ -200,7 +200,7 @@ static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id
 		return -EIO;
 	}
 
-	BT_DBG("minidrv data %p size %zu", firmware->data, firmware->size);
+	pr_debug("minidrv data %p size %zu\n", firmware->data, firmware->size);
 
 	size = max_t(uint, firmware->size, 4096);
 
@@ -228,7 +228,7 @@ static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id
 		return -EIO;
 	}
 
-	BT_DBG("firmware data %p size %zu", firmware->data, firmware->size);
+	pr_debug("firmware data %p size %zu\n", firmware->data, firmware->size);
 
 	data->fw_data = kmemdup(firmware->data, firmware->size, GFP_KERNEL);
 	if (!data->fw_data) {
@@ -259,7 +259,7 @@ static void bcm203x_disconnect(struct usb_interface *intf)
 {
 	struct bcm203x_data *data = usb_get_intfdata(intf);
 
-	BT_DBG("intf %p", intf);
+	pr_debug("intf %p\n", intf);
 
 	atomic_inc(&data->shutdown);
 	cancel_work_sync(&data->work);
diff --git a/drivers/bluetooth/bfusb.c b/drivers/bluetooth/bfusb.c
index 0623fb2..86ed0f9 100644
--- a/drivers/bluetooth/bfusb.c
+++ b/drivers/bluetooth/bfusb.c
@@ -95,7 +95,7 @@ static struct urb *bfusb_get_completed(struct bfusb_data *data)
 	struct sk_buff *skb;
 	struct urb *urb = NULL;
 
-	BT_DBG("bfusb %p", data);
+	pr_debug("bfusb %p\n", data);
 
 	skb = skb_dequeue(&data->completed_q);
 	if (skb) {
@@ -111,7 +111,7 @@ static void bfusb_unlink_urbs(struct bfusb_data *data)
 	struct sk_buff *skb;
 	struct urb *urb;
 
-	BT_DBG("bfusb %p", data);
+	pr_debug("bfusb %p\n", data);
 
 	while ((skb = skb_dequeue(&data->pending_q))) {
 		urb = ((struct bfusb_data_scb *) skb->cb)->urb;
@@ -129,7 +129,7 @@ static int bfusb_send_bulk(struct bfusb_data *data, struct sk_buff *skb)
 	struct urb *urb = bfusb_get_completed(data);
 	int err, pipe;
 
-	BT_DBG("bfusb %p skb %p len %d", data, skb, skb->len);
+	pr_debug("bfusb %p skb %p len %d\n", data, skb, skb->len);
 
 	if (!urb && !(urb = usb_alloc_urb(0, GFP_ATOMIC)))
 		return -ENOMEM;
@@ -159,7 +159,7 @@ static void bfusb_tx_wakeup(struct bfusb_data *data)
 {
 	struct sk_buff *skb;
 
-	BT_DBG("bfusb %p", data);
+	pr_debug("bfusb %p\n", data);
 
 	if (test_and_set_bit(BFUSB_TX_PROCESS, &data->state)) {
 		set_bit(BFUSB_TX_WAKEUP, &data->state);
@@ -187,7 +187,7 @@ static void bfusb_tx_complete(struct urb *urb)
 	struct sk_buff *skb = (struct sk_buff *) urb->context;
 	struct bfusb_data *data = (struct bfusb_data *) skb->dev;
 
-	BT_DBG("bfusb %p urb %p skb %p len %d", data, urb, skb, skb->len);
+	pr_debug("bfusb %p urb %p skb %p len %d\n", data, urb, skb, skb->len);
 
 	atomic_dec(&data->pending_tx);
 
@@ -216,7 +216,7 @@ static int bfusb_rx_submit(struct bfusb_data *data, struct urb *urb)
 	struct sk_buff *skb;
 	int err, pipe, size = HCI_MAX_FRAME_SIZE + 32;
 
-	BT_DBG("bfusb %p urb %p", data, urb);
+	pr_debug("bfusb %p urb %p\n", data, urb);
 
 	if (!urb && !(urb = usb_alloc_urb(0, GFP_ATOMIC)))
 		return -ENOMEM;
@@ -253,7 +253,7 @@ static int bfusb_rx_submit(struct bfusb_data *data, struct urb *urb)
 
 static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned char *buf, int len)
 {
-	BT_DBG("bfusb %p hdr 0x%02x data %p len %d", data, hdr, buf, len);
+	pr_debug("bfusb %p hdr 0x%02x data %p len %d\n", data, hdr, buf, len);
 
 	if (hdr & 0x10) {
 		bt_err("%s error in block\n", data->hdev->name);
@@ -353,7 +353,7 @@ static void bfusb_rx_complete(struct urb *urb)
 	int count = urb->actual_length;
 	int err, hdr, len;
 
-	BT_DBG("bfusb %p urb %p skb %p len %d", data, urb, skb, skb->len);
+	pr_debug("bfusb %p urb %p skb %p len %d\n", data, urb, skb, skb->len);
 
 	read_lock(&data->lock);
 
@@ -420,7 +420,7 @@ static int bfusb_open(struct hci_dev *hdev)
 	unsigned long flags;
 	int i, err;
 
-	BT_DBG("hdev %p bfusb %p", hdev, data);
+	pr_debug("hdev %p bfusb %p\n", hdev, data);
 
 	if (test_and_set_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -444,7 +444,7 @@ static int bfusb_flush(struct hci_dev *hdev)
 {
 	struct bfusb_data *data = hdev->driver_data;
 
-	BT_DBG("hdev %p bfusb %p", hdev, data);
+	pr_debug("hdev %p bfusb %p\n", hdev, data);
 
 	skb_queue_purge(&data->transmit_q);
 
@@ -456,7 +456,7 @@ static int bfusb_close(struct hci_dev *hdev)
 	struct bfusb_data *data = hdev->driver_data;
 	unsigned long flags;
 
-	BT_DBG("hdev %p bfusb %p", hdev, data);
+	pr_debug("hdev %p bfusb %p\n", hdev, data);
 
 	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -478,7 +478,8 @@ static int bfusb_send_frame(struct sk_buff *skb)
 	unsigned char buf[3];
 	int sent = 0, size, count;
 
-	BT_DBG("hdev %p skb %p type %d len %d", hdev, skb, bt_cb(skb)->pkt_type, skb->len);
+	pr_debug("hdev %p skb %p type %d len %d\n",
+		 hdev, skb, bt_cb(skb)->pkt_type, skb->len);
 
 	if (!hdev) {
 		bt_err("Frame for unknown HCI device (hdev=NULL)\n");
@@ -553,7 +554,7 @@ static void bfusb_destruct(struct hci_dev *hdev)
 {
 	struct bfusb_data *data = hdev->driver_data;
 
-	BT_DBG("hdev %p bfusb %p", hdev, data);
+	pr_debug("hdev %p bfusb %p\n", hdev, data);
 
 	kfree(data);
 }
@@ -569,7 +570,7 @@ static int bfusb_load_firmware(struct bfusb_data *data,
 	unsigned char *buf;
 	int err, pipe, len, size, sent = 0;
 
-	BT_DBG("bfusb %p udev %p", data, data->udev);
+	pr_debug("bfusb %p udev %p\n", data, data->udev);
 
 	bt_info("BlueFRITZ! USB loading firmware\n");
 
@@ -652,7 +653,7 @@ static int bfusb_probe(struct usb_interface *intf, const struct usb_device_id *i
 	struct hci_dev *hdev;
 	struct bfusb_data *data;
 
-	BT_DBG("intf %p id %p", intf, id);
+	pr_debug("intf %p id %p\n", intf, id);
 
 	/* Check number of endpoints */
 	if (intf->cur_altsetting->desc.bNumEndpoints < 2)
@@ -691,7 +692,7 @@ static int bfusb_probe(struct usb_interface *intf, const struct usb_device_id *i
 		goto error;
 	}
 
-	BT_DBG("firmware data %p size %zu", firmware->data, firmware->size);
+	pr_debug("firmware data %p size %zu\n", firmware->data, firmware->size);
 
 	if (bfusb_load_firmware(data, firmware->data, firmware->size) < 0) {
 		bt_err("Firmware loading failed\n");
@@ -747,7 +748,7 @@ static void bfusb_disconnect(struct usb_interface *intf)
 	struct bfusb_data *data = usb_get_intfdata(intf);
 	struct hci_dev *hdev = data->hdev;
 
-	BT_DBG("intf %p", intf);
+	pr_debug("intf %p\n", intf);
 
 	if (!hdev)
 		return;
diff --git a/drivers/bluetooth/bpa10x.c b/drivers/bluetooth/bpa10x.c
index e2f1458..c6e19e6 100644
--- a/drivers/bluetooth/bpa10x.c
+++ b/drivers/bluetooth/bpa10x.c
@@ -68,8 +68,8 @@ static int bpa10x_recv(struct hci_dev *hdev, int queue, void *buf, int count)
 {
 	struct bpa10x_data *data = hdev->driver_data;
 
-	BT_DBG("%s queue %d buffer %p count %d", hdev->name,
-							queue, buf, count);
+	pr_debug("%s queue %d buffer %p count %d\n",
+		 hdev->name, queue, buf, count);
 
 	if (queue < 0 || queue > 1)
 		return -EILSEQ;
@@ -169,8 +169,8 @@ static void bpa10x_tx_complete(struct urb *urb)
 	struct sk_buff *skb = urb->context;
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
-					urb, urb->status, urb->actual_length);
+	pr_debug("%s urb %p status %d count %d\n",
+		 hdev->name, urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		goto done;
@@ -192,8 +192,8 @@ static void bpa10x_rx_complete(struct urb *urb)
 	struct bpa10x_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
-					urb, urb->status, urb->actual_length);
+	pr_debug("%s urb %p status %d count %d\n",
+		 hdev->name, urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		return;
@@ -225,7 +225,7 @@ static inline int bpa10x_submit_intr_urb(struct hci_dev *hdev)
 	unsigned int pipe;
 	int err, size = 16;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!urb)
@@ -266,7 +266,7 @@ static inline int bpa10x_submit_bulk_urb(struct hci_dev *hdev)
 	unsigned int pipe;
 	int err, size = 64;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!urb)
@@ -304,7 +304,7 @@ static int bpa10x_open(struct hci_dev *hdev)
 	struct bpa10x_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (test_and_set_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -331,7 +331,7 @@ static int bpa10x_close(struct hci_dev *hdev)
 {
 	struct bpa10x_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -345,7 +345,7 @@ static int bpa10x_flush(struct hci_dev *hdev)
 {
 	struct bpa10x_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	usb_kill_anchored_urbs(&data->tx_anchor);
 
@@ -361,7 +361,7 @@ static int bpa10x_send_frame(struct sk_buff *skb)
 	unsigned int pipe;
 	int err;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		return -EBUSY;
@@ -436,7 +436,7 @@ static void bpa10x_destruct(struct hci_dev *hdev)
 {
 	struct bpa10x_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	kfree_skb(data->rx_skb[0]);
 	kfree_skb(data->rx_skb[1]);
@@ -449,7 +449,7 @@ static int bpa10x_probe(struct usb_interface *intf, const struct usb_device_id *
 	struct hci_dev *hdev;
 	int err;
 
-	BT_DBG("intf %p id %p", intf, id);
+	pr_debug("intf %p id %p\n", intf, id);
 
 	if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
 		return -ENODEV;
@@ -502,7 +502,7 @@ static void bpa10x_disconnect(struct usb_interface *intf)
 {
 	struct bpa10x_data *data = usb_get_intfdata(intf);
 
-	BT_DBG("intf %p", intf);
+	pr_debug("intf %p\n", intf);
 
 	if (!data)
 		return;
diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index 0ccf84d..67dae7d 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -72,7 +72,7 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 
 	event = (struct btmrvl_event *) skb->data;
 	if (event->ec != 0xff) {
-		BT_DBG("Not Marvell Event=%x", event->ec);
+		pr_debug("Not Marvell Event=%x\n", event->ec);
 		ret = -EINVAL;
 		goto exit;
 	}
@@ -84,19 +84,19 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 				adapter->psmode = 1;
 			else
 				adapter->psmode = 0;
-			BT_DBG("PS Mode:%s",
-				(adapter->psmode) ? "Enable" : "Disable");
+			pr_debug("PS Mode:%s\n",
+				 adapter->psmode ? "Enable" : "Disable");
 		} else {
-			BT_DBG("PS Mode command failed");
+			pr_debug("PS Mode command failed\n");
 		}
 		break;
 
 	case BT_CMD_HOST_SLEEP_CONFIG:
 		if (!event->data[3])
-			BT_DBG("gpio=%x, gap=%x", event->data[1],
-							event->data[2]);
+			pr_debug("gpio=%x, gap=%x\n",
+				 event->data[1], event->data[2]);
 		else
-			BT_DBG("HSCFG command failed");
+			pr_debug("HSCFG command failed\n");
 		break;
 
 	case BT_CMD_HOST_SLEEP_ENABLE:
@@ -105,32 +105,33 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 			if (adapter->psmode)
 				adapter->ps_state = PS_SLEEP;
 			wake_up_interruptible(&adapter->cmd_wait_q);
-			BT_DBG("HS ACTIVATED!");
+			pr_debug("HS ACTIVATED!\n");
 		} else {
-			BT_DBG("HS Enable failed");
+			pr_debug("HS Enable failed\n");
 		}
 		break;
 
 	case BT_CMD_MODULE_CFG_REQ:
 		if (priv->btmrvl_dev.sendcmdflag &&
 				event->data[1] == MODULE_BRINGUP_REQ) {
-			BT_DBG("EVENT:%s",
-				((event->data[2] == MODULE_BROUGHT_UP) ||
-				(event->data[2] == MODULE_ALREADY_UP)) ?
-				"Bring-up succeed" : "Bring-up failed");
+			pr_debug("EVENT:%s\n",
+				 ((event->data[2] == MODULE_BROUGHT_UP) ||
+				  (event->data[2] == MODULE_ALREADY_UP)) ?
+				 "Bring-up succeed" : "Bring-up failed");
 
 			if (event->length > 3 && event->data[3])
 				priv->btmrvl_dev.dev_type = HCI_AMP;
 			else
 				priv->btmrvl_dev.dev_type = HCI_BREDR;
 
-			BT_DBG("dev_type: %d", priv->btmrvl_dev.dev_type);
+			pr_debug("dev_type: %d\n", priv->btmrvl_dev.dev_type);
 		} else if (priv->btmrvl_dev.sendcmdflag &&
 				event->data[1] == MODULE_SHUTDOWN_REQ) {
-			BT_DBG("EVENT:%s", (event->data[2]) ?
-				"Shutdown failed" : "Shutdown succeed");
+			pr_debug("EVENT:%s\n",
+				 (event->data[2]) ?
+				 "Shutdown failed" : "Shutdown succeed");
 		} else {
-			BT_DBG("BT_CMD_MODULE_CFG_REQ resp for APP");
+			pr_debug("BT_CMD_MODULE_CFG_REQ resp for APP\n");
 			ret = -EINVAL;
 		}
 		break;
@@ -138,12 +139,12 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 	case BT_EVENT_POWER_STATE:
 		if (event->data[1] == BT_PS_SLEEP)
 			adapter->ps_state = PS_SLEEP;
-		BT_DBG("EVENT:%s",
-			(adapter->ps_state) ? "PS_SLEEP" : "PS_AWAKE");
+		pr_debug("EVENT:%s\n",
+			 (adapter->ps_state) ? "PS_SLEEP" : "PS_AWAKE");
 		break;
 
 	default:
-		BT_DBG("Unknown Event=%d", event->data[0]);
+		pr_debug("Unknown Event=%d\n", event->data[0]);
 		ret = -EINVAL;
 		break;
 	}
@@ -182,7 +183,7 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 
 	priv->adapter->cmd_complete = false;
 
-	BT_DBG("Queue module cfg Command");
+	pr_debug("Queue module cfg Command\n");
 
 	wake_up_interruptible(&priv->main_thread.wait_q);
 
@@ -194,7 +195,7 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 		       subcmd, priv->btmrvl_dev.sendcmdflag);
 	}
 
-	BT_DBG("module cfg Command done");
+	pr_debug("module cfg Command done\n");
 
 	return ret;
 }
@@ -226,7 +227,7 @@ int btmrvl_enable_ps(struct btmrvl_private *priv)
 	skb->dev = (void *) priv->btmrvl_dev.hcidev;
 	skb_queue_head(&priv->adapter->tx_queue, skb);
 
-	BT_DBG("Queue PSMODE Command:%d", cmd->data[0]);
+	pr_debug("Queue PSMODE Command:%d\n", cmd->data[0]);
 
 	return 0;
 }
@@ -253,7 +254,7 @@ static int btmrvl_enable_hs(struct btmrvl_private *priv)
 	skb->dev = (void *) priv->btmrvl_dev.hcidev;
 	skb_queue_head(&priv->adapter->tx_queue, skb);
 
-	BT_DBG("Queue hs enable Command");
+	pr_debug("Queue hs enable Command\n");
 
 	wake_up_interruptible(&priv->main_thread.wait_q);
 
@@ -296,8 +297,8 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 		skb->dev = (void *) priv->btmrvl_dev.hcidev;
 		skb_queue_head(&priv->adapter->tx_queue, skb);
 
-		BT_DBG("Queue HSCFG Command, gpio=0x%x, gap=0x%x",
-						cmd->data[0], cmd->data[1]);
+		pr_debug("Queue HSCFG Command, gpio=0x%x, gap=0x%x\n",
+			 cmd->data[0], cmd->data[1]);
 	}
 
 	if (priv->btmrvl_dev.pscmd) {
@@ -397,7 +398,7 @@ static int btmrvl_send_frame(struct sk_buff *skb)
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 	struct btmrvl_private *priv = NULL;
 
-	BT_DBG("type=%d, len=%d", skb->pkt_type, skb->len);
+	pr_debug("type=%d, len=%d\n", skb->pkt_type, skb->len);
 
 	if (!hdev || !hdev->driver_data) {
 		bt_err("Frame for unknown HCI device\n");
@@ -485,7 +486,7 @@ static int btmrvl_service_main_thread(void *data)
 				((!adapter->int_count) &&
 				(!priv->btmrvl_dev.tx_dnld_rdy ||
 				skb_queue_empty(&adapter->tx_queue)))) {
-			BT_DBG("main_thread is sleeping...");
+			pr_debug("main_thread is sleeping...\n");
 			schedule();
 		}
 
@@ -493,10 +494,10 @@ static int btmrvl_service_main_thread(void *data)
 
 		remove_wait_queue(&thread->wait_q, &wait);
 
-		BT_DBG("main_thread woke up");
+		pr_debug("main_thread woke up\n");
 
 		if (kthread_should_stop()) {
-			BT_DBG("main_thread: break from main thread");
+			pr_debug("main_thread: break from main thread\n");
 			break;
 		}
 
@@ -606,7 +607,7 @@ struct btmrvl_private *btmrvl_add_card(void *card)
 
 	btmrvl_init_adapter(priv);
 
-	BT_DBG("Starting kthread...");
+	pr_debug("Starting kthread...\n");
 	priv->main_thread.priv = priv;
 	spin_lock_init(&priv->driver_lock);
 
diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
index ba5629b..ae15580 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -267,8 +267,8 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 	helper = fw_helper->data;
 	helperlen = fw_helper->size;
 
-	BT_DBG("Downloading helper image (%d bytes), block size %d bytes",
-						helperlen, SDIO_BLOCK_SIZE);
+	pr_debug("Downloading helper image (%d bytes), block size %d bytes\n",
+		 helperlen, SDIO_BLOCK_SIZE);
 
 	tmphlprbufsz = ALIGN_SZ(BTM_UPLD_SIZE, BTSDIO_DMA_ALIGN);
 
@@ -323,7 +323,7 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 		hlprblknow += tx_len;
 	} while (true);
 
-	BT_DBG("Transferring helper image EOF block");
+	pr_debug("Transferring helper image EOF block\n");
 
 	memset(helperbuf, 0x0, SDIO_BLOCK_SIZE);
 
@@ -368,7 +368,7 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 	firmware = fw_firmware->data;
 	firmwarelen = fw_firmware->size;
 
-	BT_DBG("Downloading FW image (%d bytes)", firmwarelen);
+	pr_debug("Downloading FW image (%d bytes)\n", firmwarelen);
 
 	tmpfwbufsz = ALIGN_SZ(BTM_UPLD_SIZE, BTSDIO_DMA_ALIGN);
 	tmpfwbuf = kzalloc(tmpfwbufsz, GFP_KERNEL);
@@ -472,7 +472,7 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 		offset += txlen;
 	} while (true);
 
-	BT_DBG("FW download over, size %d bytes", offset);
+	pr_debug("FW download over, size %d bytes\n", offset);
 
 	ret = 0;
 
@@ -614,8 +614,8 @@ static int btmrvl_sdio_process_int_status(struct btmrvl_private *priv)
 	sdio_claim_host(card->func);
 	if (ireg & DN_LD_HOST_INT_STATUS) {
 		if (priv->btmrvl_dev.tx_dnld_rdy)
-			BT_DBG("tx_done already received: "
-				" int_status=0x%x", ireg);
+			pr_debug("tx_done already received: int_status=0x%x\n",
+				 ireg);
 		else
 			priv->btmrvl_dev.tx_dnld_rdy = true;
 	}
@@ -657,7 +657,7 @@ static void btmrvl_sdio_interrupt(struct sdio_func *func)
 		 * Clear the interrupt status register and re-enable the
 		 * interrupt.
 		 */
-		BT_DBG("ireg = 0x%x", ireg);
+		pr_debug("ireg = 0x%x\n", ireg);
 
 		sdio_writeb(card->func, ~(ireg) & (DN_LD_HOST_INT_STATUS |
 					UP_LD_HOST_INT_STATUS),
@@ -736,7 +736,7 @@ static int btmrvl_sdio_register_dev(struct btmrvl_sdio_card *card)
 
 	card->ioport |= (reg << 16);
 
-	BT_DBG("SDIO FUNC%d IO port: 0x%x", func->num, card->ioport);
+	pr_debug("SDIO FUNC%d IO port: 0x%x\n", func->num, card->ioport);
 
 	sdio_set_drvdata(func, card);
 
@@ -873,7 +873,7 @@ static int btmrvl_sdio_download_fw(struct btmrvl_sdio_card *card)
 	sdio_claim_host(card->func);
 
 	if (!btmrvl_sdio_verify_fw_download(card, 1)) {
-		BT_DBG("Firmware already downloaded!");
+		pr_debug("Firmware already downloaded!\n");
 		goto done;
 	}
 
@@ -885,7 +885,8 @@ static int btmrvl_sdio_download_fw(struct btmrvl_sdio_card *card)
 		goto done;
 	}
 	if (fws0) {
-		BT_DBG("BT not the winner (%#x). Skip FW downloading", fws0);
+		pr_debug("BT not the winner (%#x). Skip FW downloading\n",
+			 fws0);
 
 		/* Give other function more time to download the firmware */
 		pollnum *= 10;
@@ -934,7 +935,7 @@ static int btmrvl_sdio_wakeup_fw(struct btmrvl_private *priv)
 
 	sdio_release_host(card->func);
 
-	BT_DBG("wake up firmware");
+	pr_debug("wake up firmware\n");
 
 	return ret;
 }
@@ -1034,7 +1035,7 @@ static void btmrvl_sdio_remove(struct sdio_func *func)
 							MODULE_SHUTDOWN_REQ);
 				btmrvl_sdio_disable_host_int(card);
 			}
-			BT_DBG("unregester dev");
+			pr_debug("unregister dev\n");
 			btmrvl_sdio_unregister_dev(card);
 			btmrvl_remove_card(card->priv);
 			kfree(card);
diff --git a/drivers/bluetooth/btsdio.c b/drivers/bluetooth/btsdio.c
index a7368bc..339d1e9 100644
--- a/drivers/bluetooth/btsdio.c
+++ b/drivers/bluetooth/btsdio.c
@@ -78,7 +78,7 @@ static int btsdio_tx_packet(struct btsdio_data *data, struct sk_buff *skb)
 {
 	int err;
 
-	BT_DBG("%s", data->hdev->name);
+	pr_debug("%s\n", data->hdev->name);
 
 	/* Prepend Type-A header */
 	skb_push(skb, 4);
@@ -107,7 +107,7 @@ static void btsdio_work(struct work_struct *work)
 	struct sk_buff *skb;
 	int err;
 
-	BT_DBG("%s", data->hdev->name);
+	pr_debug("%s\n", data->hdev->name);
 
 	sdio_claim_host(data->func);
 
@@ -129,7 +129,7 @@ static int btsdio_rx_packet(struct btsdio_data *data)
 	struct sk_buff *skb;
 	int err, len;
 
-	BT_DBG("%s", data->hdev->name);
+	pr_debug("%s\n", data->hdev->name);
 
 	err = sdio_readsb(data->func, hdr, REG_RDAT, 4);
 	if (err < 0)
@@ -174,7 +174,7 @@ static void btsdio_interrupt(struct sdio_func *func)
 	struct btsdio_data *data = sdio_get_drvdata(func);
 	int intrd;
 
-	BT_DBG("%s", data->hdev->name);
+	pr_debug("%s\n", data->hdev->name);
 
 	intrd = sdio_readb(func, REG_INTRD, NULL);
 	if (intrd & 0x01) {
@@ -192,7 +192,7 @@ static int btsdio_open(struct hci_dev *hdev)
 	struct btsdio_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (test_and_set_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -227,7 +227,7 @@ static int btsdio_close(struct hci_dev *hdev)
 {
 	struct btsdio_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -248,7 +248,7 @@ static int btsdio_flush(struct hci_dev *hdev)
 {
 	struct btsdio_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	skb_queue_purge(&data->txq);
 
@@ -260,7 +260,7 @@ static int btsdio_send_frame(struct sk_buff *skb)
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 	struct btsdio_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		return -EBUSY;
@@ -293,7 +293,7 @@ static void btsdio_destruct(struct hci_dev *hdev)
 {
 	struct btsdio_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	kfree(data);
 }
@@ -306,10 +306,10 @@ static int btsdio_probe(struct sdio_func *func,
 	struct sdio_func_tuple *tuple = func->tuples;
 	int err;
 
-	BT_DBG("func %p id %p class 0x%04x", func, id, func->class);
+	pr_debug("func %p id %p class 0x%04x\n", func, id, func->class);
 
 	while (tuple) {
-		BT_DBG("code 0x%x size %d", tuple->code, tuple->size);
+		pr_debug("code 0x%x size %d\n", tuple->code, tuple->size);
 		tuple = tuple->next;
 	}
 
@@ -366,7 +366,7 @@ static void btsdio_remove(struct sdio_func *func)
 	struct btsdio_data *data = sdio_get_drvdata(func);
 	struct hci_dev *hdev;
 
-	BT_DBG("func %p", func);
+	pr_debug("func %p\n", func);
 
 	if (!data)
 		return;
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 5b29cd8..be18e44 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -247,8 +247,8 @@ static void btusb_intr_complete(struct urb *urb)
 	struct btusb_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
-					urb, urb->status, urb->actual_length);
+	pr_debug("%s urb %p status %d count %d\n",
+		 hdev->name, urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		return;
@@ -289,7 +289,7 @@ static int btusb_submit_intr_urb(struct hci_dev *hdev, gfp_t mem_flags)
 	unsigned int pipe;
 	int err, size;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!data->intr_ep)
 		return -ENODEV;
@@ -335,8 +335,8 @@ static void btusb_bulk_complete(struct urb *urb)
 	struct btusb_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
-					urb, urb->status, urb->actual_length);
+	pr_debug("%s urb %p status %d count %d\n",
+		 hdev->name, urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		return;
@@ -377,7 +377,7 @@ static int btusb_submit_bulk_urb(struct hci_dev *hdev, gfp_t mem_flags)
 	unsigned int pipe;
 	int err, size = HCI_MAX_FRAME_SIZE;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!data->bulk_rx_ep)
 		return -ENODEV;
@@ -421,8 +421,8 @@ static void btusb_isoc_complete(struct urb *urb)
 	struct btusb_data *data = hdev->driver_data;
 	int i, err;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
-					urb, urb->status, urb->actual_length);
+	pr_debug("%s urb %p status %d count %d\n",
+		 hdev->name, urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		return;
@@ -466,7 +466,7 @@ static inline void __fill_isoc_descriptor(struct urb *urb, int len, int mtu)
 {
 	int i, offset = 0;
 
-	BT_DBG("len %d mtu %d", len, mtu);
+	pr_debug("len %d mtu %d\n", len, mtu);
 
 	for (i = 0; i < BTUSB_MAX_ISOC_FRAMES && len >= mtu;
 					i++, offset += mtu, len -= mtu) {
@@ -491,7 +491,7 @@ static int btusb_submit_isoc_urb(struct hci_dev *hdev, gfp_t mem_flags)
 	unsigned int pipe;
 	int err, size;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!data->isoc_rx_ep)
 		return -ENODEV;
@@ -540,8 +540,8 @@ static void btusb_tx_complete(struct urb *urb)
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 	struct btusb_data *data = hdev->driver_data;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
-					urb, urb->status, urb->actual_length);
+	pr_debug("%s urb %p status %d count %d\n",
+		 hdev->name, urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		goto done;
@@ -566,8 +566,8 @@ static void btusb_isoc_tx_complete(struct urb *urb)
 	struct sk_buff *skb = urb->context;
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 
-	BT_DBG("%s urb %p status %d count %d", hdev->name,
-					urb, urb->status, urb->actual_length);
+	pr_debug("%s urb %p status %d count %d\n",
+		 hdev->name, urb, urb->status, urb->actual_length);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		goto done;
@@ -588,7 +588,7 @@ static int btusb_open(struct hci_dev *hdev)
 	struct btusb_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	err = usb_autopm_get_interface(data->intf);
 	if (err < 0)
@@ -638,7 +638,7 @@ static int btusb_close(struct hci_dev *hdev)
 	struct btusb_data *data = hdev->driver_data;
 	int err;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -667,7 +667,7 @@ static int btusb_flush(struct hci_dev *hdev)
 {
 	struct btusb_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	usb_kill_anchored_urbs(&data->tx_anchor);
 
@@ -683,7 +683,7 @@ static int btusb_send_frame(struct sk_buff *skb)
 	unsigned int pipe;
 	int err;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		return -EBUSY;
@@ -789,7 +789,7 @@ static void btusb_destruct(struct hci_dev *hdev)
 {
 	struct btusb_data *data = hdev->driver_data;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	kfree(data);
 }
@@ -798,7 +798,7 @@ static void btusb_notify(struct hci_dev *hdev, unsigned int evt)
 {
 	struct btusb_data *data = hdev->driver_data;
 
-	BT_DBG("%s evt %d", hdev->name, evt);
+	pr_debug("%s evt %d\n", hdev->name, evt);
 
 	if (hdev->conn_hash.sco_num != data->sco_num) {
 		data->sco_num = hdev->conn_hash.sco_num;
@@ -910,7 +910,7 @@ static int btusb_probe(struct usb_interface *intf,
 	struct hci_dev *hdev;
 	int i, err;
 
-	BT_DBG("intf %p id %p", intf, id);
+	pr_debug("intf %p id %p\n", intf, id);
 
 	/* interface numbers are hardcoded in the spec */
 	if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
@@ -1086,7 +1086,7 @@ static void btusb_disconnect(struct usb_interface *intf)
 	struct btusb_data *data = usb_get_intfdata(intf);
 	struct hci_dev *hdev;
 
-	BT_DBG("intf %p", intf);
+	pr_debug("intf %p\n", intf);
 
 	if (!data)
 		return;
@@ -1117,7 +1117,7 @@ static int btusb_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct btusb_data *data = usb_get_intfdata(intf);
 
-	BT_DBG("intf %p", intf);
+	pr_debug("intf %p\n", intf);
 
 	if (data->suspend_count++)
 		return 0;
@@ -1161,7 +1161,7 @@ static int btusb_resume(struct usb_interface *intf)
 	struct hci_dev *hdev = data->hdev;
 	int err = 0;
 
-	BT_DBG("intf %p", intf);
+	pr_debug("intf %p\n", intf);
 
 	if (--data->suspend_count)
 		return 0;
diff --git a/drivers/bluetooth/btwilink.c b/drivers/bluetooth/btwilink.c
index d69d796..55dcc17 100644
--- a/drivers/bluetooth/btwilink.c
+++ b/drivers/bluetooth/btwilink.c
@@ -155,7 +155,7 @@ static int ti_st_open(struct hci_dev *hdev)
 	struct ti_st *hst;
 	int err, i;
 
-	BT_DBG("%s %p", hdev->name, hdev);
+	pr_debug("%s %p\n", hdev->name, hdev);
 
 	if (test_and_set_bit(HCI_RUNNING, &hdev->flags))
 		return -EBUSY;
@@ -191,8 +191,7 @@ static int ti_st_open(struct hci_dev *hdev)
 		/* ST is busy with either protocol
 		 * registration or firmware download.
 		 */
-		BT_DBG("waiting for registration "
-				"completion signal from ST");
+		pr_debug("waiting for registration completion signal from ST\n");
 		timeleft = wait_for_completion_timeout
 			(&hst->wait_reg_completion,
 			 msecs_to_jiffies(BT_REGISTER_TIMEOUT));
@@ -268,8 +267,8 @@ static int ti_st_send_frame(struct sk_buff *skb)
 	/* Prepend skb with frame type */
 	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
 
-	BT_DBG("%s: type %d len %d", hdev->name, bt_cb(skb)->pkt_type,
-			skb->len);
+	pr_debug("%s: type %d len %d\n",
+		 hdev->name, bt_cb(skb)->pkt_type, skb->len);
 
 	/* Insert skb to shared transport layer's transmit queue.
 	 * Freeing skb memory is taken care in shared transport layer,
@@ -292,7 +291,7 @@ static int ti_st_send_frame(struct sk_buff *skb)
 
 static void ti_st_destruct(struct hci_dev *hdev)
 {
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 	/* do nothing here, since platform remove
 	 * would free the hdev->driver_data
 	 */
@@ -315,7 +314,7 @@ static int bt_ti_probe(struct platform_device *pdev)
 		return -ENOMEM;
 	}
 
-	BT_DBG("hdev %p", hdev);
+	pr_debug("hdev %p\n", hdev);
 
 	hst->hdev = hdev;
 	hdev->bus = HCI_UART;
@@ -335,7 +334,7 @@ static int bt_ti_probe(struct platform_device *pdev)
 		return err;
 	}
 
-	BT_DBG("HCI device registered (hdev %p)", hdev);
+	pr_debug("HCI device registered (hdev %p)\n", hdev);
 
 	dev_set_drvdata(&pdev->dev, hst);
 	return err;
@@ -349,7 +348,7 @@ static int bt_ti_remove(struct platform_device *pdev)
 	if (!hst)
 		return -EFAULT;
 
-	BT_DBG("%s", hst->hdev->name);
+	pr_debug("%s\n", hst->hdev->name);
 
 	hdev = hst->hdev;
 	ti_st_close(hdev);
diff --git a/drivers/bluetooth/hci_ath.c b/drivers/bluetooth/hci_ath.c
index 2d025fa..adeffba 100644
--- a/drivers/bluetooth/hci_ath.c
+++ b/drivers/bluetooth/hci_ath.c
@@ -110,7 +110,7 @@ static int ath_open(struct hci_uart *hu)
 {
 	struct ath_struct *ath;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	ath = kzalloc(sizeof(*ath), GFP_ATOMIC);
 	if (!ath)
@@ -131,7 +131,7 @@ static int ath_flush(struct hci_uart *hu)
 {
 	struct ath_struct *ath = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	skb_queue_purge(&ath->txq);
 
@@ -143,7 +143,7 @@ static int ath_close(struct hci_uart *hu)
 {
 	struct ath_struct *ath = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	skb_queue_purge(&ath->txq);
 
@@ -178,7 +178,7 @@ static int ath_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 			ath->cur_sleep = skb->data[HCI_COMMAND_HDR_SIZE];
 	}
 
-	BT_DBG("hu %p skb %p", hu, skb);
+	pr_debug("hu %p skb %p\n", hu, skb);
 
 	/* Prepend skb with frame type */
 	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
diff --git a/drivers/bluetooth/hci_bcsp.c b/drivers/bluetooth/hci_bcsp.c
index 5042daa..3ea7f2c 100644
--- a/drivers/bluetooth/hci_bcsp.c
+++ b/drivers/bluetooth/hci_bcsp.c
@@ -239,11 +239,11 @@ static struct sk_buff *bcsp_prepare_pkt(struct bcsp_struct *bcsp, u8 *data,
 
 	hdr[0] = bcsp->rxseq_txack << 3;
 	bcsp->txack_req = 0;
-	BT_DBG("We request packet no %u to card", bcsp->rxseq_txack);
+	pr_debug("We request packet no %u to card\n", bcsp->rxseq_txack);
 
 	if (rel) {
 		hdr[0] |= 0x80 + bcsp->msgq_txseq;
-		BT_DBG("Sending packet with seqno %u", bcsp->msgq_txseq);
+		pr_debug("Sending packet with seqno %u\n", bcsp->msgq_txseq);
 		bcsp->msgq_txseq = (bcsp->msgq_txseq + 1) & 0x07;
 	}
 
@@ -340,7 +340,7 @@ static struct sk_buff *bcsp_dequeue(struct hci_uart *hu)
 
 static int bcsp_flush(struct hci_uart *hu)
 {
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 	return 0;
 }
 
@@ -367,9 +367,9 @@ static void bcsp_pkt_cull(struct bcsp_struct *bcsp)
 	if (bcsp->rxack != seqno)
 		bt_err("Peer acked invalid packet\n");
 
-	BT_DBG("Removing %u pkts out of %u, up to seqno %u",
-	       pkts_to_be_removed, skb_queue_len(&bcsp->unack),
-	       (seqno - 1) & 0x07);
+	pr_debug("Removing %u pkts out of %u, up to seqno %u\n",
+		 pkts_to_be_removed, skb_queue_len(&bcsp->unack),
+		 (seqno - 1) & 0x07);
 
 	i = 0;
 	skb_queue_walk_safe(&bcsp->unack, skb, tmp) {
@@ -406,7 +406,7 @@ static void bcsp_handle_le_pkt(struct hci_uart *hu)
 			!memcmp(&bcsp->rx_skb->data[4], conf_pkt, 4)) {
 		struct sk_buff *nskb = alloc_skb(4, GFP_ATOMIC);
 
-		BT_DBG("Found a LE conf pkt");
+		pr_debug("Found a LE conf pkt\n");
 		if (!nskb)
 			return;
 		memcpy(skb_put(nskb, 4), conf_rsp_pkt, 4);
@@ -477,7 +477,7 @@ static void bcsp_complete_rx_pkt(struct hci_uart *hu)
 	int pass_up;
 
 	if (bcsp->rx_skb->data[0] & 0x80) {	/* reliable pkt */
-		BT_DBG("Received seqno %u from card", bcsp->rxseq_txack);
+		pr_debug("Received seqno %u from card\n", bcsp->rxseq_txack);
 		bcsp->rxseq_txack++;
 		bcsp->rxseq_txack %= 0x8;
 		bcsp->txack_req    = 1;
@@ -487,7 +487,7 @@ static void bcsp_complete_rx_pkt(struct hci_uart *hu)
 	}
 
 	bcsp->rxack = (bcsp->rx_skb->data[0] >> 3) & 0x07;
-	BT_DBG("Request for pkt %u from card", bcsp->rxack);
+	pr_debug("Request for pkt %u from card\n", bcsp->rxack);
 
 	bcsp_pkt_cull(bcsp);
 	if ((bcsp->rx_skb->data[1] & 0x0f) == 6 &&
@@ -555,8 +555,8 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 	struct bcsp_struct *bcsp = hu->priv;
 	register unsigned char *ptr;
 
-	BT_DBG("hu %p count %d rx_state %d rx_count %ld", 
-		hu, count, bcsp->rx_state, bcsp->rx_count);
+	pr_debug("hu %p count %d rx_state %d rx_count %ld\n",
+		 hu, count, bcsp->rx_state, bcsp->rx_count);
 
 	ptr = data;
 	while (count) {
@@ -674,7 +674,7 @@ static void bcsp_timed_event(unsigned long arg)
 	struct sk_buff *skb;
 	unsigned long flags;
 
-	BT_DBG("hu %p retransmitting %u pkts", hu, bcsp->unack.qlen);
+	pr_debug("hu %p retransmitting %u pkts\n", hu, bcsp->unack.qlen);
 
 	spin_lock_irqsave_nested(&bcsp->unack.lock, flags, SINGLE_DEPTH_NESTING);
 
@@ -692,7 +692,7 @@ static int bcsp_open(struct hci_uart *hu)
 {
 	struct bcsp_struct *bcsp;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	bcsp = kzalloc(sizeof(*bcsp), GFP_ATOMIC);
 	if (!bcsp)
@@ -720,7 +720,7 @@ static int bcsp_close(struct hci_uart *hu)
 	struct bcsp_struct *bcsp = hu->priv;
 	hu->priv = NULL;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	skb_queue_purge(&bcsp->unack);
 	skb_queue_purge(&bcsp->rel);
diff --git a/drivers/bluetooth/hci_h4.c b/drivers/bluetooth/hci_h4.c
index 0ffe638..4a015e5 100644
--- a/drivers/bluetooth/hci_h4.c
+++ b/drivers/bluetooth/hci_h4.c
@@ -67,7 +67,7 @@ static int h4_open(struct hci_uart *hu)
 {
 	struct h4_struct *h4;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	h4 = kzalloc(sizeof(*h4), GFP_ATOMIC);
 	if (!h4)
@@ -84,7 +84,7 @@ static int h4_flush(struct hci_uart *hu)
 {
 	struct h4_struct *h4 = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	skb_queue_purge(&h4->txq);
 
@@ -98,7 +98,7 @@ static int h4_close(struct hci_uart *hu)
 
 	hu->priv = NULL;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	skb_queue_purge(&h4->txq);
 
@@ -115,7 +115,7 @@ static int h4_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 {
 	struct h4_struct *h4 = hu->priv;
 
-	BT_DBG("hu %p skb %p", hu, skb);
+	pr_debug("hu %p skb %p\n", hu, skb);
 
 	/* Prepend skb with frame type */
 	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
@@ -128,7 +128,7 @@ static inline int h4_check_data_len(struct h4_struct *h4, int len)
 {
 	register int room = skb_tailroom(h4->rx_skb);
 
-	BT_DBG("len %d room %d", len, room);
+	pr_debug("len %d room %d\n", len, room);
 
 	if (!len) {
 		hci_recv_frame(h4->rx_skb);
diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_ldisc.c
index c4bd312..3d50994 100644
--- a/drivers/bluetooth/hci_ldisc.c
+++ b/drivers/bluetooth/hci_ldisc.c
@@ -129,7 +129,7 @@ int hci_uart_tx_wakeup(struct hci_uart *hu)
 		return 0;
 	}
 
-	BT_DBG("");
+	pr_debug("\n");
 
 restart:
 	clear_bit(HCI_UART_TX_WAKEUP, &hu->tx_state);
@@ -162,7 +162,7 @@ restart:
 /* Initialize device */
 static int hci_uart_open(struct hci_dev *hdev)
 {
-	BT_DBG("%s %p", hdev->name, hdev);
+	pr_debug("%s %p\n", hdev->name, hdev);
 
 	/* Nothing to do for UART driver */
 
@@ -177,7 +177,7 @@ static int hci_uart_flush(struct hci_dev *hdev)
 	struct hci_uart *hu  = (struct hci_uart *) hdev->driver_data;
 	struct tty_struct *tty = hu->tty;
 
-	BT_DBG("hdev %p tty %p", hdev, tty);
+	pr_debug("hdev %p tty %p\n", hdev, tty);
 
 	if (hu->tx_skb) {
 		kfree_skb(hu->tx_skb); hu->tx_skb = NULL;
@@ -196,7 +196,7 @@ static int hci_uart_flush(struct hci_dev *hdev)
 /* Close device */
 static int hci_uart_close(struct hci_dev *hdev)
 {
-	BT_DBG("hdev %p", hdev);
+	pr_debug("hdev %p\n", hdev);
 
 	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
@@ -222,7 +222,8 @@ static int hci_uart_send_frame(struct sk_buff *skb)
 
 	hu = (struct hci_uart *) hdev->driver_data;
 
-	BT_DBG("%s: type %d len %d", hdev->name, bt_cb(skb)->pkt_type, skb->len);
+	pr_debug("%s: type %d len %d\n",
+		 hdev->name, bt_cb(skb)->pkt_type, skb->len);
 
 	hu->proto->enqueue(hu, skb);
 
@@ -236,7 +237,7 @@ static void hci_uart_destruct(struct hci_dev *hdev)
 	if (!hdev)
 		return;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 	kfree(hdev->driver_data);
 }
 
@@ -254,7 +255,7 @@ static int hci_uart_tty_open(struct tty_struct *tty)
 {
 	struct hci_uart *hu = (void *) tty->disc_data;
 
-	BT_DBG("tty %p", tty);
+	pr_debug("tty %p\n", tty);
 
 	/* FIXME: This btw is bogus, nothing requires the old ldisc to clear
 	   the pointer */
@@ -298,7 +299,7 @@ static void hci_uart_tty_close(struct tty_struct *tty)
 {
 	struct hci_uart *hu = (void *)tty->disc_data;
 
-	BT_DBG("tty %p", tty);
+	pr_debug("tty %p\n", tty);
 
 	/* Detach from the tty */
 	tty->disc_data = NULL;
@@ -331,7 +332,7 @@ static void hci_uart_tty_wakeup(struct tty_struct *tty)
 {
 	struct hci_uart *hu = (void *)tty->disc_data;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	if (!hu)
 		return;
@@ -379,7 +380,7 @@ static int hci_uart_register_dev(struct hci_uart *hu)
 {
 	struct hci_dev *hdev;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	/* Initialize and register HCI device */
 	hdev = hci_alloc_dev();
@@ -460,7 +461,7 @@ static int hci_uart_tty_ioctl(struct tty_struct *tty, struct file * file,
 	struct hci_uart *hu = (void *)tty->disc_data;
 	int err = 0;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	/* Verify the status of the device */
 	if (!hu)
diff --git a/drivers/bluetooth/hci_ll.c b/drivers/bluetooth/hci_ll.c
index 7d21082..b94f888 100644
--- a/drivers/bluetooth/hci_ll.c
+++ b/drivers/bluetooth/hci_ll.c
@@ -97,7 +97,7 @@ static int send_hcill_cmd(u8 cmd, struct hci_uart *hu)
 	struct ll_struct *ll = hu->priv;
 	struct hcill_cmd *hcill_packet;
 
-	BT_DBG("hu %p cmd 0x%x", hu, cmd);
+	pr_debug("hu %p cmd 0x%x\n", hu, cmd);
 
 	/* allocate packet */
 	skb = bt_skb_alloc(1, GFP_ATOMIC);
@@ -123,7 +123,7 @@ static int ll_open(struct hci_uart *hu)
 {
 	struct ll_struct *ll;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	ll = kzalloc(sizeof(*ll), GFP_ATOMIC);
 	if (!ll)
@@ -145,7 +145,7 @@ static int ll_flush(struct hci_uart *hu)
 {
 	struct ll_struct *ll = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	skb_queue_purge(&ll->tx_wait_q);
 	skb_queue_purge(&ll->txq);
@@ -158,7 +158,7 @@ static int ll_close(struct hci_uart *hu)
 {
 	struct ll_struct *ll = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	skb_queue_purge(&ll->tx_wait_q);
 	skb_queue_purge(&ll->txq);
@@ -197,7 +197,7 @@ static void ll_device_want_to_wakeup(struct hci_uart *hu)
 	unsigned long flags;
 	struct ll_struct *ll = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	/* lock hcill state */
 	spin_lock_irqsave(&ll->hcill_lock, flags);
@@ -214,7 +214,7 @@ static void ll_device_want_to_wakeup(struct hci_uart *hu)
 		 * require an explicit ack here, do accept it, thus it is
 		 * perfectly safe to always send one.
 		 */
-		BT_DBG("dual wake-up-indication");
+		pr_debug("dual wake-up-indication\n");
 		/* deliberate fall-through - do not add break */
 	case HCILL_ASLEEP:
 		/* acknowledge device wake up */
@@ -248,7 +248,7 @@ static void ll_device_want_to_sleep(struct hci_uart *hu)
 	unsigned long flags;
 	struct ll_struct *ll = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	/* lock hcill state */
 	spin_lock_irqsave(&ll->hcill_lock, flags);
@@ -282,7 +282,7 @@ static void ll_device_woke_up(struct hci_uart *hu)
 	unsigned long flags;
 	struct ll_struct *ll = hu->priv;
 
-	BT_DBG("hu %p", hu);
+	pr_debug("hu %p\n", hu);
 
 	/* lock hcill state */
 	spin_lock_irqsave(&ll->hcill_lock, flags);
@@ -308,7 +308,7 @@ static int ll_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 	unsigned long flags = 0;
 	struct ll_struct *ll = hu->priv;
 
-	BT_DBG("hu %p skb %p", hu, skb);
+	pr_debug("hu %p skb %p\n", hu, skb);
 
 	/* Prepend skb with frame type */
 	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
@@ -319,11 +319,11 @@ static int ll_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 	/* act according to current state */
 	switch (ll->hcill_state) {
 	case HCILL_AWAKE:
-		BT_DBG("device awake, sending normally");
+		pr_debug("device awake, sending normally\n");
 		skb_queue_tail(&ll->txq, skb);
 		break;
 	case HCILL_ASLEEP:
-		BT_DBG("device asleep, waking up and queueing packet");
+		pr_debug("device asleep, waking up and queueing packet\n");
 		/* save packet for later */
 		skb_queue_tail(&ll->tx_wait_q, skb);
 		/* awake device */
@@ -334,7 +334,7 @@ static int ll_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 		ll->hcill_state = HCILL_ASLEEP_TO_AWAKE;
 		break;
 	case HCILL_ASLEEP_TO_AWAKE:
-		BT_DBG("device waking up, queueing packet");
+		pr_debug("device waking up, queueing packet\n");
 		/* transient state; just keep packet for later */
 		skb_queue_tail(&ll->tx_wait_q, skb);
 		break;
@@ -354,7 +354,7 @@ static inline int ll_check_data_len(struct ll_struct *ll, int len)
 {
 	register int room = skb_tailroom(ll->rx_skb);
 
-	BT_DBG("len %d room %d", len, room);
+	pr_debug("len %d room %d\n", len, room);
 
 	if (!len) {
 		hci_recv_frame(ll->rx_skb);
@@ -384,7 +384,8 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 	struct hci_sco_hdr   *sh;
 	register int len, type, dlen;
 
-	BT_DBG("hu %p count %d rx_state %ld rx_count %ld", hu, count, ll->rx_state, ll->rx_count);
+	pr_debug("hu %p count %d rx_state %ld rx_count %ld\n",
+		 hu, count, ll->rx_state, ll->rx_count);
 
 	ptr = data;
 	while (count) {
@@ -398,7 +399,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 
 			switch (ll->rx_state) {
 			case HCILL_W4_DATA:
-				BT_DBG("Complete data");
+				pr_debug("Complete data\n");
 				hci_recv_frame(ll->rx_skb);
 
 				ll->rx_state = HCILL_W4_PACKET_TYPE;
@@ -408,7 +409,8 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 			case HCILL_W4_EVENT_HDR:
 				eh = hci_event_hdr(ll->rx_skb);
 
-				BT_DBG("Event header: evt 0x%2.2x plen %d", eh->evt, eh->plen);
+				pr_debug("Event header: evt 0x%2.2x plen %d\n",
+					 eh->evt, eh->plen);
 
 				ll_check_data_len(ll, eh->plen);
 				continue;
@@ -417,7 +419,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 				ah = hci_acl_hdr(ll->rx_skb);
 				dlen = __le16_to_cpu(ah->dlen);
 
-				BT_DBG("ACL header: dlen %d", dlen);
+				pr_debug("ACL header: dlen %d\n", dlen);
 
 				ll_check_data_len(ll, dlen);
 				continue;
@@ -425,7 +427,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 			case HCILL_W4_SCO_HDR:
 				sh = hci_sco_hdr(ll->rx_skb);
 
-				BT_DBG("SCO header: dlen %d", sh->dlen);
+				pr_debug("SCO header: dlen %d\n", sh->dlen);
 
 				ll_check_data_len(ll, sh->dlen);
 				continue;
@@ -435,21 +437,21 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 		/* HCILL_W4_PACKET_TYPE */
 		switch (*ptr) {
 		case HCI_EVENT_PKT:
-			BT_DBG("Event packet");
+			pr_debug("Event packet\n");
 			ll->rx_state = HCILL_W4_EVENT_HDR;
 			ll->rx_count = HCI_EVENT_HDR_SIZE;
 			type = HCI_EVENT_PKT;
 			break;
 
 		case HCI_ACLDATA_PKT:
-			BT_DBG("ACL packet");
+			pr_debug("ACL packet\n");
 			ll->rx_state = HCILL_W4_ACL_HDR;
 			ll->rx_count = HCI_ACL_HDR_SIZE;
 			type = HCI_ACLDATA_PKT;
 			break;
 
 		case HCI_SCODATA_PKT:
-			BT_DBG("SCO packet");
+			pr_debug("SCO packet\n");
 			ll->rx_state = HCILL_W4_SCO_HDR;
 			ll->rx_count = HCI_SCO_HDR_SIZE;
 			type = HCI_SCODATA_PKT;
@@ -457,7 +459,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 
 		/* HCILL signals */
 		case HCILL_GO_TO_SLEEP_IND:
-			BT_DBG("HCILL_GO_TO_SLEEP_IND packet");
+			pr_debug("HCILL_GO_TO_SLEEP_IND packet\n");
 			ll_device_want_to_sleep(hu);
 			ptr++; count--;
 			continue;
@@ -470,13 +472,13 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 			continue;
 
 		case HCILL_WAKE_UP_IND:
-			BT_DBG("HCILL_WAKE_UP_IND packet");
+			pr_debug("HCILL_WAKE_UP_IND packet\n");
 			ll_device_want_to_wakeup(hu);
 			ptr++; count--;
 			continue;
 
 		case HCILL_WAKE_UP_ACK:
-			BT_DBG("HCILL_WAKE_UP_ACK packet");
+			pr_debug("HCILL_WAKE_UP_ACK packet\n");
 			ll_device_woke_up(hu);
 			ptr++; count--;
 			continue;
diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index b1664ed..d64c4a9 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -609,7 +609,7 @@ static inline void l2cap_chan_put(struct l2cap_chan *c)
 static inline void l2cap_set_timer(struct l2cap_chan *chan,
 					struct delayed_work *work, long timeout)
 {
-	BT_DBG("chan %p state %d timeout %ld", chan, chan->state, timeout);
+	pr_debug("chan %p state %d timeout %ld\n", chan, chan->state, timeout);
 
 	if (!cancel_delayed_work(work))
 		l2cap_chan_hold(chan);
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index d75fe7c..2b4df7c 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -170,7 +170,7 @@ EXPORT_SYMBOL(bt_sock_unlink);
 
 void bt_accept_enqueue(struct sock *parent, struct sock *sk)
 {
-	BT_DBG("parent %p, sk %p", parent, sk);
+	pr_debug("parent %p, sk %p\n", parent, sk);
 
 	sock_hold(sk);
 	list_add_tail(&bt_sk(sk)->accept_q, &bt_sk(parent)->accept_q);
@@ -181,7 +181,7 @@ EXPORT_SYMBOL(bt_accept_enqueue);
 
 void bt_accept_unlink(struct sock *sk)
 {
-	BT_DBG("sk %p state %d", sk, sk->sk_state);
+	pr_debug("sk %p state %d\n", sk, sk->sk_state);
 
 	list_del_init(&bt_sk(sk)->accept_q);
 	bt_sk(sk)->parent->sk_ack_backlog--;
@@ -195,7 +195,7 @@ struct sock *bt_accept_dequeue(struct sock *parent, struct socket *newsock)
 	struct list_head *p, *n;
 	struct sock *sk;
 
-	BT_DBG("parent %p", parent);
+	pr_debug("parent %p\n", parent);
 
 	list_for_each_safe(p, n, &bt_sk(parent)->accept_q) {
 		sk = (struct sock *) list_entry(p, struct bt_sock, accept_q);
@@ -235,7 +235,7 @@ int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	size_t copied;
 	int err;
 
-	BT_DBG("sock %p sk %p len %zu", sock, sk, len);
+	pr_debug("sock %p sk %p len %zu\n", sock, sk, len);
 
 	if (flags & (MSG_OOB))
 		return -EOPNOTSUPP;
@@ -308,7 +308,7 @@ int bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	msg->msg_namelen = 0;
 
-	BT_DBG("sk %p size %zu", sk, size);
+	pr_debug("sk %p size %zu\n", sk, size);
 
 	lock_sock(sk);
 
@@ -423,7 +423,7 @@ unsigned int bt_sock_poll(struct file *file, struct socket *sock, poll_table *wa
 	struct sock *sk = sock->sk;
 	unsigned int mask = 0;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	poll_wait(file, sk_sleep(sk), wait);
 
@@ -466,7 +466,7 @@ int bt_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	long amount;
 	int err;
 
-	BT_DBG("sk %p cmd %x arg %lx", sk, cmd, arg);
+	pr_debug("sk %p cmd %x arg %lx\n", sk, cmd, arg);
 
 	switch (cmd) {
 	case TIOCOUTQ:
@@ -512,7 +512,7 @@ int bt_sock_wait_state(struct sock *sk, int state, unsigned long timeo)
 	DECLARE_WAITQUEUE(wait, current);
 	int err = 0;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	add_wait_queue(sk_sleep(sk), &wait);
 	set_current_state(TASK_INTERRUPTIBLE);
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index a98306e..7c4d0e9 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -66,7 +66,7 @@ static struct bnep_session *__bnep_get_session(u8 *dst)
 {
 	struct bnep_session *s;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	list_for_each_entry(s, &bnep_session_list, list)
 		if (!compare_ether_addr(dst, s->eh.h_source))
@@ -131,7 +131,7 @@ static int bnep_ctrl_set_netfilter(struct bnep_session *s, __be16 *data, int len
 	if (len < n)
 		return -EILSEQ;
 
-	BT_DBG("filter len %d", n);
+	pr_debug("filter len %d\n", n);
 
 #ifdef CONFIG_BT_BNEP_PROTO_FILTER
 	n /= 4;
@@ -143,8 +143,8 @@ static int bnep_ctrl_set_netfilter(struct bnep_session *s, __be16 *data, int len
 			f[i].start = get_unaligned_be16(data++);
 			f[i].end   = get_unaligned_be16(data++);
 
-			BT_DBG("proto filter start %d end %d",
-				f[i].start, f[i].end);
+			pr_debug("proto filter start %d end %d\n",
+				 f[i].start, f[i].end);
 		}
 
 		if (i < BNEP_MAX_PROTO_FILTERS)
@@ -177,7 +177,7 @@ static int bnep_ctrl_set_mcfilter(struct bnep_session *s, u8 *data, int len)
 	if (len < n)
 		return -EILSEQ;
 
-	BT_DBG("filter len %d", n);
+	pr_debug("filter len %d\n", n);
 
 #ifdef CONFIG_BT_BNEP_MC_FILTER
 	n /= (ETH_ALEN * 2);
@@ -199,8 +199,8 @@ static int bnep_ctrl_set_mcfilter(struct bnep_session *s, u8 *data, int len)
 			a2 = data;
 			data += ETH_ALEN;
 
-			BT_DBG("mc filter %s -> %s",
-				batostr((void *) a1), batostr((void *) a2));
+			pr_debug("mc filter %s -> %s\n",
+				 batostr((void *) a1), batostr((void *) a2));
 
 			/* Iterate from a1 to a2 */
 			set_bit(bnep_mc_hash(a1), (ulong *) &s->mc_filter);
@@ -215,7 +215,7 @@ static int bnep_ctrl_set_mcfilter(struct bnep_session *s, u8 *data, int len)
 		}
 	}
 
-	BT_DBG("mc filter hash 0x%llx", s->mc_filter);
+	pr_debug("mc filter hash 0x%llx\n", s->mc_filter);
 
 	bnep_send_rsp(s, BNEP_FILTER_MULTI_ADDR_RSP, BNEP_SUCCESS);
 #else
@@ -277,7 +277,7 @@ static int bnep_rx_extension(struct bnep_session *s, struct sk_buff *skb)
 			break;
 		}
 
-		BT_DBG("type 0x%x len %d", h->type, h->len);
+		pr_debug("type 0x%x len %d\n", h->type, h->len);
 
 		switch (h->type & BNEP_TYPE_MASK) {
 		case BNEP_EXT_CONTROL:
@@ -412,7 +412,7 @@ static inline int bnep_tx_frame(struct bnep_session *s, struct sk_buff *skb)
 	int len = 0, il = 0;
 	u8 type = 0;
 
-	BT_DBG("skb %p dev %p type %d", skb, skb->dev, skb->pkt_type);
+	pr_debug("skb %p dev %p type %d\n", skb, skb->dev, skb->pkt_type);
 
 	if (!skb->dev) {
 		/* Control frame sent by us */
@@ -471,7 +471,7 @@ static int bnep_session(void *arg)
 	struct sk_buff *skb;
 	wait_queue_t wait;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	set_user_nice(current, -15);
 
@@ -556,7 +556,7 @@ int bnep_add_connection(struct bnep_connadd_req *req, struct socket *sock)
 	u8 dst[ETH_ALEN], src[ETH_ALEN];
 	int err;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	baswap((void *) dst, &bt_sk(sock->sk)->dst);
 	baswap((void *) src, &bt_sk(sock->sk)->src);
@@ -636,7 +636,7 @@ int bnep_del_connection(struct bnep_conndel_req *req)
 	struct bnep_session *s;
 	int  err = 0;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	down_read(&bnep_session_sem);
 
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index 32c8204..da65ba0 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -65,7 +65,7 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 	struct sk_buff *skb;
 	int size;
 
-	BT_DBG("%s mc_count %d", dev->name, netdev_mc_count(dev));
+	pr_debug("%s mc_count %d\n", dev->name, netdev_mc_count(dev));
 
 	size = sizeof(*r) + (BNEP_MAX_MULTICAST_FILTERS + 1) * ETH_ALEN * 2;
 	skb  = alloc_skb(size, GFP_ATOMIC);
@@ -117,13 +117,13 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 
 static int bnep_net_set_mac_addr(struct net_device *dev, void *arg)
 {
-	BT_DBG("%s", dev->name);
+	pr_debug("%s\n", dev->name);
 	return 0;
 }
 
 static void bnep_net_timeout(struct net_device *dev)
 {
-	BT_DBG("net_timeout");
+	pr_debug("net_timeout\n");
 	netif_wake_queue(dev);
 }
 
@@ -165,7 +165,7 @@ static inline int bnep_net_proto_filter(struct sk_buff *skb, struct bnep_session
 			return 0;
 	}
 
-	BT_DBG("BNEP: filtered skb %p, proto 0x%.4x", skb, proto);
+	pr_debug("BNEP: filtered skb %p, proto 0x%.4x\n", skb, proto);
 	return 1;
 }
 #endif
@@ -176,7 +176,7 @@ static netdev_tx_t bnep_net_xmit(struct sk_buff *skb,
 	struct bnep_session *s = netdev_priv(dev);
 	struct sock *sk = s->sock->sk;
 
-	BT_DBG("skb %p, dev %p", skb, dev);
+	pr_debug("skb %p, dev %p\n", skb, dev);
 
 #ifdef CONFIG_BT_BNEP_MC_FILTER
 	if (bnep_net_mc_filter(skb, s)) {
@@ -202,7 +202,7 @@ static netdev_tx_t bnep_net_xmit(struct sk_buff *skb,
 	wake_up_interruptible(sk_sleep(sk));
 
 	if (skb_queue_len(&sk->sk_write_queue) >= BNEP_TX_QUEUE_LEN) {
-		BT_DBG("tx queue is full");
+		pr_debug("tx queue is full\n");
 
 		/* Stop queuing.
 		 * Session thread will do netif_wake_queue() */
diff --git a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
index 916af88..99dbed7 100644
--- a/net/bluetooth/bnep/sock.c
+++ b/net/bluetooth/bnep/sock.c
@@ -50,7 +50,7 @@ static int bnep_sock_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	pr_debug("sock %p sk %p\n", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -70,7 +70,7 @@ static int bnep_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long
 	void __user *argp = (void __user *)arg;
 	int err;
 
-	BT_DBG("cmd %x arg %lx", cmd, arg);
+	pr_debug("cmd %x arg %lx\n", cmd, arg);
 
 	switch (cmd) {
 	case BNEPCONNADD:
@@ -201,7 +201,7 @@ static int bnep_sock_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	pr_debug("sock %p\n", sock);
 
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
diff --git a/net/bluetooth/cmtp/capi.c b/net/bluetooth/cmtp/capi.c
index b60e817..1f5d547 100644
--- a/net/bluetooth/cmtp/capi.c
+++ b/net/bluetooth/cmtp/capi.c
@@ -74,7 +74,7 @@ static struct cmtp_application *cmtp_application_add(struct cmtp_session *sessio
 {
 	struct cmtp_application *app = kzalloc(sizeof(*app), GFP_KERNEL);
 
-	BT_DBG("session %p application %p appl %d", session, app, appl);
+	pr_debug("session %p application %p appl %d\n", session, app, appl);
 
 	if (!app)
 		return NULL;
@@ -89,7 +89,7 @@ static struct cmtp_application *cmtp_application_add(struct cmtp_session *sessio
 
 static void cmtp_application_del(struct cmtp_session *session, struct cmtp_application *app)
 {
-	BT_DBG("session %p application %p", session, app);
+	pr_debug("session %p application %p\n", session, app);
 
 	if (app) {
 		list_del(&app->list);
@@ -137,7 +137,7 @@ static void cmtp_send_capimsg(struct cmtp_session *session, struct sk_buff *skb)
 {
 	struct cmtp_scb *scb = (void *) skb->cb;
 
-	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
+	pr_debug("session %p skb %p len %d\n", session, skb, skb->len);
 
 	scb->id = -1;
 	scb->data = (CAPIMSG_COMMAND(skb->data) == CAPI_DATA_B3);
@@ -154,7 +154,8 @@ static void cmtp_send_interopmsg(struct cmtp_session *session,
 	struct sk_buff *skb;
 	unsigned char *s;
 
-	BT_DBG("session %p subcmd 0x%02x appl %d msgnum %d", session, subcmd, appl, msgnum);
+	pr_debug("session %p subcmd 0x%02x appl %d msgnum %d\n",
+		 session, subcmd, appl, msgnum);
 
 	skb = alloc_skb(CAPI_MSG_BASELEN + 6 + len, GFP_ATOMIC);
 	if (!skb) {
@@ -190,7 +191,7 @@ static void cmtp_recv_interopmsg(struct cmtp_session *session, struct sk_buff *s
 	__u16 appl, msgnum, func, info;
 	__u32 controller;
 
-	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
+	pr_debug("session %p skb %p len %d\n", session, skb, skb->len);
 
 	switch (CAPIMSG_SUBCOMMAND(skb->data)) {
 	case CAPI_CONF:
@@ -329,7 +330,7 @@ void cmtp_recv_capimsg(struct cmtp_session *session, struct sk_buff *skb)
 	__u16 appl;
 	__u32 contr;
 
-	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
+	pr_debug("session %p skb %p len %d\n", session, skb, skb->len);
 
 	if (skb->len < CAPI_MSG_BASELEN)
 		return;
@@ -373,7 +374,7 @@ void cmtp_recv_capimsg(struct cmtp_session *session, struct sk_buff *skb)
 
 static int cmtp_load_firmware(struct capi_ctr *ctrl, capiloaddata *data)
 {
-	BT_DBG("ctrl %p data %p", ctrl, data);
+	pr_debug("ctrl %p data %p\n", ctrl, data);
 
 	return 0;
 }
@@ -382,7 +383,7 @@ static void cmtp_reset_ctr(struct capi_ctr *ctrl)
 {
 	struct cmtp_session *session = ctrl->driverdata;
 
-	BT_DBG("ctrl %p", ctrl);
+	pr_debug("ctrl %p\n", ctrl);
 
 	capi_ctr_down(ctrl);
 
@@ -399,8 +400,8 @@ static void cmtp_register_appl(struct capi_ctr *ctrl, __u16 appl, capi_register_
 	unsigned char buf[8];
 	int err = 0, nconn, want = rp->level3cnt;
 
-	BT_DBG("ctrl %p appl %d level3cnt %d datablkcnt %d datablklen %d",
-		ctrl, appl, rp->level3cnt, rp->datablkcnt, rp->datablklen);
+	pr_debug("ctrl %p appl %d level3cnt %d datablkcnt %d datablklen %d\n",
+		 ctrl, appl, rp->level3cnt, rp->datablkcnt, rp->datablklen);
 
 	application = cmtp_application_add(session, appl);
 	if (!application) {
@@ -464,7 +465,7 @@ static void cmtp_release_appl(struct capi_ctr *ctrl, __u16 appl)
 	struct cmtp_session *session = ctrl->driverdata;
 	struct cmtp_application *application;
 
-	BT_DBG("ctrl %p appl %d", ctrl, appl);
+	pr_debug("ctrl %p appl %d\n", ctrl, appl);
 
 	application = cmtp_application_get(session, CMTP_APPLID, appl);
 	if (!application) {
@@ -490,7 +491,7 @@ static u16 cmtp_send_message(struct capi_ctr *ctrl, struct sk_buff *skb)
 	__u16 appl;
 	__u32 contr;
 
-	BT_DBG("ctrl %p skb %p", ctrl, skb);
+	pr_debug("ctrl %p skb %p\n", ctrl, skb);
 
 	appl = CAPIMSG_APPID(skb->data);
 	contr = CAPIMSG_CONTROL(skb->data);
@@ -555,7 +556,7 @@ int cmtp_attach_device(struct cmtp_session *session)
 	unsigned char buf[4];
 	long ret;
 
-	BT_DBG("session %p", session);
+	pr_debug("session %p\n", session);
 
 	capimsg_setu32(buf, 0, 0);
 
@@ -598,7 +599,7 @@ int cmtp_attach_device(struct cmtp_session *session)
 
 	session->num = session->ctrl.cnr;
 
-	BT_DBG("session %p num %d", session, session->num);
+	pr_debug("session %p num %d\n", session, session->num);
 
 	capimsg_setu32(buf, 0, 1);
 
@@ -619,7 +620,7 @@ int cmtp_attach_device(struct cmtp_session *session)
 
 void cmtp_detach_device(struct cmtp_session *session)
 {
-	BT_DBG("session %p", session);
+	pr_debug("session %p\n", session);
 
 	detach_capi_ctr(&session->ctrl);
 }
diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
index b170dbe..a0b451f 100644
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -54,7 +54,7 @@ static struct cmtp_session *__cmtp_get_session(bdaddr_t *bdaddr)
 {
 	struct cmtp_session *session;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	list_for_each_entry(session, &cmtp_session_list, list)
 		if (!bacmp(bdaddr, &session->bdaddr))
@@ -108,7 +108,7 @@ static inline void cmtp_add_msgpart(struct cmtp_session *session, int id, const
 	struct sk_buff *skb = session->reassembly[id], *nskb;
 	int size;
 
-	BT_DBG("session %p buf %p count %d", session, buf, count);
+	pr_debug("session %p buf %p count %d\n", session, buf, count);
 
 	size = (skb) ? skb->len + count : count;
 
@@ -133,7 +133,7 @@ static inline int cmtp_recv_frame(struct cmtp_session *session, struct sk_buff *
 	__u8 hdr, hdrlen, id;
 	__u16 len;
 
-	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
+	pr_debug("session %p skb %p len %d\n", session, skb, skb->len);
 
 	while (skb->len > 0) {
 		hdr = skb->data[0];
@@ -155,7 +155,8 @@ static inline int cmtp_recv_frame(struct cmtp_session *session, struct sk_buff *
 
 		id = (hdr & 0x3c) >> 2;
 
-		BT_DBG("hdr 0x%02x hdrlen %d len %d id %d", hdr, hdrlen, len, id);
+		pr_debug("hdr 0x%02x hdrlen %d len %d id %d\n",
+			 hdr, hdrlen, len, id);
 
 		if (hdrlen + len > skb->len) {
 			bt_err("Wrong size or header information in CMTP frame\n");
@@ -196,7 +197,7 @@ static int cmtp_send_frame(struct cmtp_session *session, unsigned char *data, in
 	struct kvec iv = { data, len };
 	struct msghdr msg;
 
-	BT_DBG("session %p data %p len %d", session, data, len);
+	pr_debug("session %p data %p len %d\n", session, data, len);
 
 	if (!len)
 		return 0;
@@ -212,7 +213,7 @@ static void cmtp_process_transmit(struct cmtp_session *session)
 	unsigned char *hdr;
 	unsigned int size, tail;
 
-	BT_DBG("session %p", session);
+	pr_debug("session %p\n", session);
 
 	nskb = alloc_skb(session->mtu, GFP_ATOMIC);
 	if (!nskb) {
@@ -282,7 +283,7 @@ static int cmtp_session(void *arg)
 	struct sk_buff *skb;
 	wait_queue_t wait;
 
-	BT_DBG("session %p", session);
+	pr_debug("session %p\n", session);
 
 	set_user_nice(current, -15);
 
@@ -332,7 +333,7 @@ int cmtp_add_connection(struct cmtp_connadd_req *req, struct socket *sock)
 	struct cmtp_session *session, *s;
 	int i, err;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	session = kzalloc(sizeof(struct cmtp_session), GFP_KERNEL);
 	if (!session)
@@ -351,7 +352,7 @@ int cmtp_add_connection(struct cmtp_connadd_req *req, struct socket *sock)
 	session->mtu = min_t(uint, l2cap_pi(sock->sk)->chan->omtu,
 					l2cap_pi(sock->sk)->chan->imtu);
 
-	BT_DBG("mtu %d", session->mtu);
+	pr_debug("mtu %d\n", session->mtu);
 
 	sprintf(session->name, "%s", batostr(&bt_sk(sock->sk)->dst));
 
@@ -409,7 +410,7 @@ int cmtp_del_connection(struct cmtp_conndel_req *req)
 	struct cmtp_session *session;
 	int err = 0;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	down_read(&cmtp_session_sem);
 
@@ -433,7 +434,7 @@ int cmtp_get_connlist(struct cmtp_connlist_req *req)
 	struct cmtp_session *session;
 	int err = 0, n = 0;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	down_read(&cmtp_session_sem);
 
diff --git a/net/bluetooth/cmtp/sock.c b/net/bluetooth/cmtp/sock.c
index 921f045..310d1e5 100644
--- a/net/bluetooth/cmtp/sock.c
+++ b/net/bluetooth/cmtp/sock.c
@@ -47,7 +47,7 @@ static int cmtp_sock_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	pr_debug("sock %p sk %p\n", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -68,7 +68,7 @@ static int cmtp_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long
 	void __user *argp = (void __user *)arg;
 	int err;
 
-	BT_DBG("cmd %x arg %lx", cmd, arg);
+	pr_debug("cmd %x arg %lx\n", cmd, arg);
 
 	switch (cmd) {
 	case CMTPCONNADD:
@@ -195,7 +195,7 @@ static int cmtp_sock_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	pr_debug("sock %p\n", sock);
 
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index 07bc69e..034305e 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -80,7 +80,7 @@ void hci_acl_connect(struct hci_conn *conn)
 	struct inquiry_entry *ie;
 	struct hci_cp_create_conn cp;
 
-	BT_DBG("%p", conn);
+	pr_debug("%p\n", conn);
 
 	conn->state = BT_CONNECT;
 	conn->out = 1;
@@ -121,7 +121,7 @@ static void hci_acl_connect_cancel(struct hci_conn *conn)
 {
 	struct hci_cp_create_conn_cancel cp;
 
-	BT_DBG("%p", conn);
+	pr_debug("%p\n", conn);
 
 	if (conn->hdev->hci_ver < BLUETOOTH_VER_1_2)
 		return;
@@ -134,7 +134,7 @@ void hci_acl_disconn(struct hci_conn *conn, __u8 reason)
 {
 	struct hci_cp_disconnect cp;
 
-	BT_DBG("%p", conn);
+	pr_debug("%p\n", conn);
 
 	conn->state = BT_DISCONN;
 
@@ -148,7 +148,7 @@ void hci_add_sco(struct hci_conn *conn, __u16 handle)
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_cp_add_sco cp;
 
-	BT_DBG("%p", conn);
+	pr_debug("%p\n", conn);
 
 	conn->state = BT_CONNECT;
 	conn->out = 1;
@@ -166,7 +166,7 @@ void hci_setup_sync(struct hci_conn *conn, __u16 handle)
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_cp_setup_sync_conn cp;
 
-	BT_DBG("%p", conn);
+	pr_debug("%p\n", conn);
 
 	conn->state = BT_CONNECT;
 	conn->out = 1;
@@ -211,7 +211,7 @@ void hci_le_start_enc(struct hci_conn *conn, __le16 ediv, __u8 rand[8],
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_cp_le_start_enc cp;
 
-	BT_DBG("%p", conn);
+	pr_debug("%p\n", conn);
 
 	memset(&cp, 0, sizeof(cp));
 
@@ -229,7 +229,7 @@ void hci_le_ltk_reply(struct hci_conn *conn, u8 ltk[16])
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_cp_le_ltk_reply cp;
 
-	BT_DBG("%p", conn);
+	pr_debug("%p\n", conn);
 
 	memset(&cp, 0, sizeof(cp));
 
@@ -245,7 +245,7 @@ void hci_le_ltk_neg_reply(struct hci_conn *conn)
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_cp_le_ltk_neg_reply cp;
 
-	BT_DBG("%p", conn);
+	pr_debug("%p\n", conn);
 
 	memset(&cp, 0, sizeof(cp));
 
@@ -259,7 +259,7 @@ void hci_sco_setup(struct hci_conn *conn, __u8 status)
 {
 	struct hci_conn *sco = conn->link;
 
-	BT_DBG("%p", conn);
+	pr_debug("%p\n", conn);
 
 	if (!sco)
 		return;
@@ -282,7 +282,7 @@ static void hci_conn_timeout(struct work_struct *work)
 	struct hci_dev *hdev = conn->hdev;
 	__u8 reason;
 
-	BT_DBG("conn %p state %d", conn, conn->state);
+	pr_debug("conn %p state %d\n", conn, conn->state);
 
 	if (atomic_read(&conn->refcnt))
 		return;
@@ -317,7 +317,7 @@ static void hci_conn_enter_sniff_mode(struct hci_conn *conn)
 {
 	struct hci_dev *hdev = conn->hdev;
 
-	BT_DBG("conn %p mode %d", conn, conn->mode);
+	pr_debug("conn %p mode %d\n", conn, conn->mode);
 
 	if (test_bit(HCI_RAW, &hdev->flags))
 		return;
@@ -352,7 +352,7 @@ static void hci_conn_idle(unsigned long arg)
 {
 	struct hci_conn *conn = (void *) arg;
 
-	BT_DBG("conn %p mode %d", conn, conn->mode);
+	pr_debug("conn %p mode %d\n", conn, conn->mode);
 
 	hci_conn_enter_sniff_mode(conn);
 }
@@ -370,7 +370,7 @@ struct hci_conn *hci_conn_add(struct hci_dev *hdev, int type, bdaddr_t *dst)
 {
 	struct hci_conn *conn;
 
-	BT_DBG("%s dst %s", hdev->name, batostr(dst));
+	pr_debug("%s dst %s\n", hdev->name, batostr(dst));
 
 	conn = kzalloc(sizeof(struct hci_conn), GFP_ATOMIC);
 	if (!conn)
@@ -433,7 +433,7 @@ int hci_conn_del(struct hci_conn *conn)
 {
 	struct hci_dev *hdev = conn->hdev;
 
-	BT_DBG("%s conn %p handle %d", hdev->name, conn, conn->handle);
+	pr_debug("%s conn %p handle %d\n", hdev->name, conn, conn->handle);
 
 	del_timer(&conn->idle_timer);
 
@@ -485,7 +485,7 @@ struct hci_dev *hci_get_route(bdaddr_t *dst, bdaddr_t *src)
 	int use_src = bacmp(src, BDADDR_ANY);
 	struct hci_dev *hdev = NULL, *d;
 
-	BT_DBG("%s -> %s", batostr(src), batostr(dst));
+	pr_debug("%s -> %s\n", batostr(src), batostr(dst));
 
 	read_lock(&hci_dev_list_lock);
 
@@ -525,7 +525,7 @@ struct hci_conn *hci_connect(struct hci_dev *hdev, int type, bdaddr_t *dst, __u8
 	struct hci_conn *sco;
 	struct hci_conn *le;
 
-	BT_DBG("%s dst %s", hdev->name, batostr(dst));
+	pr_debug("%s dst %s\n", hdev->name, batostr(dst));
 
 	if (type == LE_LINK) {
 		struct adv_entry *entry;
@@ -605,7 +605,7 @@ EXPORT_SYMBOL(hci_connect);
 /* Check link security requirement */
 int hci_conn_check_link_mode(struct hci_conn *conn)
 {
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	if (conn->ssp_mode > 0 && conn->hdev->ssp_mode > 0 &&
 					!(conn->link_mode & HCI_LM_ENCRYPT))
@@ -618,7 +618,7 @@ EXPORT_SYMBOL(hci_conn_check_link_mode);
 /* Authenticate remote device */
 static int hci_conn_auth(struct hci_conn *conn, __u8 sec_level, __u8 auth_type)
 {
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	if (conn->pending_sec_level > sec_level)
 		sec_level = conn->pending_sec_level;
@@ -652,7 +652,7 @@ static int hci_conn_auth(struct hci_conn *conn, __u8 sec_level, __u8 auth_type)
 /* Encrypt the the link */
 static void hci_conn_encrypt(struct hci_conn *conn)
 {
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	if (!test_and_set_bit(HCI_CONN_ENCRYPT_PEND, &conn->pend)) {
 		struct hci_cp_set_conn_encrypt cp;
@@ -666,7 +666,7 @@ static void hci_conn_encrypt(struct hci_conn *conn)
 /* Enable security */
 int hci_conn_security(struct hci_conn *conn, __u8 sec_level, __u8 auth_type)
 {
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	/* For sdp we don't need the link key. */
 	if (sec_level == BT_SECURITY_SDP)
@@ -722,7 +722,7 @@ EXPORT_SYMBOL(hci_conn_security);
 /* Check secure link requirement */
 int hci_conn_check_secure(struct hci_conn *conn, __u8 sec_level)
 {
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	if (sec_level != BT_SECURITY_HIGH)
 		return 1; /* Accept if non-secure is required */
@@ -737,7 +737,7 @@ EXPORT_SYMBOL(hci_conn_check_secure);
 /* Change link key */
 int hci_conn_change_link_key(struct hci_conn *conn)
 {
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	if (!test_and_set_bit(HCI_CONN_AUTH_PEND, &conn->pend)) {
 		struct hci_cp_change_conn_link_key cp;
@@ -753,7 +753,7 @@ EXPORT_SYMBOL(hci_conn_change_link_key);
 /* Switch role */
 int hci_conn_switch_role(struct hci_conn *conn, __u8 role)
 {
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	if (!role && conn->link_mode & HCI_LM_MASTER)
 		return 1;
@@ -774,7 +774,7 @@ void hci_conn_enter_active_mode(struct hci_conn *conn, __u8 force_active)
 {
 	struct hci_dev *hdev = conn->hdev;
 
-	BT_DBG("conn %p mode %d", conn, conn->mode);
+	pr_debug("conn %p mode %d\n", conn, conn->mode);
 
 	if (test_bit(HCI_RAW, &hdev->flags))
 		return;
@@ -803,7 +803,7 @@ void hci_conn_hash_flush(struct hci_dev *hdev)
 	struct hci_conn_hash *h = &hdev->conn_hash;
 	struct hci_conn *c;
 
-	BT_DBG("hdev %s", hdev->name);
+	pr_debug("hdev %s\n", hdev->name);
 
 	list_for_each_entry_rcu(c, &h->list, list) {
 		c->state = BT_CLOSED;
@@ -818,7 +818,7 @@ void hci_conn_check_pending(struct hci_dev *hdev)
 {
 	struct hci_conn *conn;
 
-	BT_DBG("hdev %s", hdev->name);
+	pr_debug("hdev %s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -948,7 +948,7 @@ struct hci_chan *hci_chan_create(struct hci_conn *conn)
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_chan *chan;
 
-	BT_DBG("%s conn %p", hdev->name, conn);
+	pr_debug("%s conn %p\n", hdev->name, conn);
 
 	chan = kzalloc(sizeof(struct hci_chan), GFP_ATOMIC);
 	if (!chan)
@@ -967,7 +967,7 @@ int hci_chan_del(struct hci_chan *chan)
 	struct hci_conn *conn = chan->conn;
 	struct hci_dev *hdev = conn->hdev;
 
-	BT_DBG("%s conn %p chan %p", hdev->name, conn, chan);
+	pr_debug("%s conn %p chan %p\n", hdev->name, conn, chan);
 
 	list_del_rcu(&chan->list);
 
@@ -983,7 +983,7 @@ void hci_chan_list_flush(struct hci_conn *conn)
 {
 	struct hci_chan *chan;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	list_for_each_entry_rcu(chan, &conn->chan_list, list)
 		hci_chan_del(chan);
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 94dfc20..54bc464 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -93,7 +93,8 @@ static void hci_notify(struct hci_dev *hdev, int event)
 
 void hci_req_complete(struct hci_dev *hdev, __u16 cmd, int result)
 {
-	BT_DBG("%s command 0x%04x result 0x%2.2x", hdev->name, cmd, result);
+	pr_debug("%s command 0x%04x result 0x%2.2x\n",
+		 hdev->name, cmd, result);
 
 	/* If this is the init phase check if the completed command matches
 	 * the last init command, and if not just return.
@@ -110,7 +111,7 @@ void hci_req_complete(struct hci_dev *hdev, __u16 cmd, int result)
 
 static void hci_req_cancel(struct hci_dev *hdev, int err)
 {
-	BT_DBG("%s err 0x%2.2x", hdev->name, err);
+	pr_debug("%s err 0x%2.2x\n", hdev->name, err);
 
 	if (hdev->req_status == HCI_REQ_PEND) {
 		hdev->req_result = err;
@@ -126,7 +127,7 @@ static int __hci_request(struct hci_dev *hdev, void (*req)(struct hci_dev *hdev,
 	DECLARE_WAITQUEUE(wait, current);
 	int err = 0;
 
-	BT_DBG("%s start", hdev->name);
+	pr_debug("%s start\n", hdev->name);
 
 	hdev->req_status = HCI_REQ_PEND;
 
@@ -157,7 +158,7 @@ static int __hci_request(struct hci_dev *hdev, void (*req)(struct hci_dev *hdev,
 
 	hdev->req_status = hdev->req_result = 0;
 
-	BT_DBG("%s end: err %d", hdev->name, err);
+	pr_debug("%s end: err %d\n", hdev->name, err);
 
 	return err;
 }
@@ -180,7 +181,7 @@ static inline int hci_request(struct hci_dev *hdev, void (*req)(struct hci_dev *
 
 static void hci_reset_req(struct hci_dev *hdev, unsigned long opt)
 {
-	BT_DBG("%s %ld", hdev->name, opt);
+	pr_debug("%s %ld\n", hdev->name, opt);
 
 	/* Reset device */
 	set_bit(HCI_RESET, &hdev->flags);
@@ -254,7 +255,7 @@ static void hci_init_req(struct hci_dev *hdev, unsigned long opt)
 {
 	struct sk_buff *skb;
 
-	BT_DBG("%s %ld", hdev->name, opt);
+	pr_debug("%s %ld\n", hdev->name, opt);
 
 	/* Driver initialization */
 
@@ -286,7 +287,7 @@ static void hci_init_req(struct hci_dev *hdev, unsigned long opt)
 
 static void hci_le_init_req(struct hci_dev *hdev, unsigned long opt)
 {
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	/* Read LE buffer size */
 	hci_send_cmd(hdev, HCI_OP_LE_READ_BUFFER_SIZE, 0, NULL);
@@ -296,7 +297,7 @@ static void hci_scan_req(struct hci_dev *hdev, unsigned long opt)
 {
 	__u8 scan = opt;
 
-	BT_DBG("%s %x", hdev->name, scan);
+	pr_debug("%s %x\n", hdev->name, scan);
 
 	/* Inquiry and Page scans */
 	hci_send_cmd(hdev, HCI_OP_WRITE_SCAN_ENABLE, 1, &scan);
@@ -306,7 +307,7 @@ static void hci_auth_req(struct hci_dev *hdev, unsigned long opt)
 {
 	__u8 auth = opt;
 
-	BT_DBG("%s %x", hdev->name, auth);
+	pr_debug("%s %x\n", hdev->name, auth);
 
 	/* Authentication */
 	hci_send_cmd(hdev, HCI_OP_WRITE_AUTH_ENABLE, 1, &auth);
@@ -316,7 +317,7 @@ static void hci_encrypt_req(struct hci_dev *hdev, unsigned long opt)
 {
 	__u8 encrypt = opt;
 
-	BT_DBG("%s %x", hdev->name, encrypt);
+	pr_debug("%s %x\n", hdev->name, encrypt);
 
 	/* Encryption */
 	hci_send_cmd(hdev, HCI_OP_WRITE_ENCRYPT_MODE, 1, &encrypt);
@@ -326,7 +327,7 @@ static void hci_linkpol_req(struct hci_dev *hdev, unsigned long opt)
 {
 	__le16 policy = cpu_to_le16(opt);
 
-	BT_DBG("%s %x", hdev->name, policy);
+	pr_debug("%s %x\n", hdev->name, policy);
 
 	/* Default link policy */
 	hci_send_cmd(hdev, HCI_OP_WRITE_DEF_LINK_POLICY, 2, &policy);
@@ -338,7 +339,7 @@ struct hci_dev *hci_dev_get(int index)
 {
 	struct hci_dev *hdev = NULL, *d;
 
-	BT_DBG("%d", index);
+	pr_debug("%d\n", index);
 
 	if (index < 0)
 		return NULL;
@@ -360,7 +361,7 @@ static void inquiry_cache_flush(struct hci_dev *hdev)
 	struct inquiry_cache *cache = &hdev->inq_cache;
 	struct inquiry_entry *next  = cache->list, *e;
 
-	BT_DBG("cache %p", cache);
+	pr_debug("cache %p\n", cache);
 
 	cache->list = NULL;
 	while ((e = next)) {
@@ -374,7 +375,7 @@ struct inquiry_entry *hci_inquiry_cache_lookup(struct hci_dev *hdev, bdaddr_t *b
 	struct inquiry_cache *cache = &hdev->inq_cache;
 	struct inquiry_entry *e;
 
-	BT_DBG("cache %p, %s", cache, batostr(bdaddr));
+	pr_debug("cache %p, %s\n", cache, batostr(bdaddr));
 
 	for (e = cache->list; e; e = e->next)
 		if (!bacmp(&e->data.bdaddr, bdaddr))
@@ -387,7 +388,7 @@ void hci_inquiry_cache_update(struct hci_dev *hdev, struct inquiry_data *data)
 	struct inquiry_cache *cache = &hdev->inq_cache;
 	struct inquiry_entry *ie;
 
-	BT_DBG("cache %p, %s", cache, batostr(&data->bdaddr));
+	pr_debug("cache %p, %s\n", cache, batostr(&data->bdaddr));
 
 	ie = hci_inquiry_cache_lookup(hdev, &data->bdaddr);
 	if (!ie) {
@@ -423,7 +424,7 @@ static int inquiry_cache_dump(struct hci_dev *hdev, int num, __u8 *buf)
 		info++;
 	}
 
-	BT_DBG("cache %p, copied %d", cache, copied);
+	pr_debug("cache %p, copied %d\n", cache, copied);
 	return copied;
 }
 
@@ -432,7 +433,7 @@ static void hci_inq_req(struct hci_dev *hdev, unsigned long opt)
 	struct hci_inquiry_req *ir = (struct hci_inquiry_req *) opt;
 	struct hci_cp_inquiry cp;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (test_bit(HCI_INQUIRY, &hdev->flags))
 		return;
@@ -493,7 +494,7 @@ int hci_inquiry(void __user *arg)
 	ir.num_rsp = inquiry_cache_dump(hdev, max_rsp, buf);
 	hci_dev_unlock(hdev);
 
-	BT_DBG("num_rsp %d", ir.num_rsp);
+	pr_debug("num_rsp %d\n", ir.num_rsp);
 
 	if (!copy_to_user(ptr, &ir, sizeof(ir))) {
 		ptr += sizeof(ir);
@@ -521,7 +522,7 @@ int hci_dev_open(__u16 dev)
 	if (!hdev)
 		return -ENODEV;
 
-	BT_DBG("%s %p", hdev->name, hdev);
+	pr_debug("%s %p\n", hdev->name, hdev);
 
 	hci_req_lock(hdev);
 
@@ -601,7 +602,7 @@ done:
 
 static int hci_dev_do_close(struct hci_dev *hdev)
 {
-	BT_DBG("%s %p", hdev->name, hdev);
+	pr_debug("%s %p\n", hdev->name, hdev);
 
 	hci_req_cancel(hdev, ENODEV);
 	hci_req_lock(hdev);
@@ -918,7 +919,7 @@ static int hci_rfkill_set_block(void *data, bool blocked)
 {
 	struct hci_dev *hdev = data;
 
-	BT_DBG("%p name %s blocked %d", hdev, hdev->name, blocked);
+	pr_debug("%p name %s blocked %d\n", hdev, hdev->name, blocked);
 
 	if (!blocked)
 		return 0;
@@ -962,7 +963,7 @@ static void hci_power_on(struct work_struct *work)
 {
 	struct hci_dev *hdev = container_of(work, struct hci_dev, power_on);
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (hci_dev_open(hdev->id) < 0)
 		return;
@@ -980,7 +981,7 @@ static void hci_power_off(struct work_struct *work)
 	struct hci_dev *hdev = container_of(work, struct hci_dev,
 							power_off.work);
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	clear_bit(HCI_AUTO_OFF, &hdev->flags);
 
@@ -994,7 +995,7 @@ static void hci_discov_off(struct work_struct *work)
 
 	hdev = container_of(work, struct hci_dev, discov_off.work);
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -1138,7 +1139,7 @@ int hci_add_link_key(struct hci_dev *hdev, struct hci_conn *conn, int new_key,
 		list_add(&key->list, &hdev->link_keys);
 	}
 
-	BT_DBG("%s key for %s type %u", hdev->name, batostr(bdaddr), type);
+	pr_debug("%s key for %s type %u\n", hdev->name, batostr(bdaddr), type);
 
 	/* Some buggy controller combinations generate a changed
 	 * combination key for legacy pairing even when there's no
@@ -1182,7 +1183,7 @@ int hci_add_ltk(struct hci_dev *hdev, int new_key, bdaddr_t *bdaddr,
 	struct key_master_id *id;
 	u8 old_key_type;
 
-	BT_DBG("%s addr %s", hdev->name, batostr(bdaddr));
+	pr_debug("%s addr %s\n", hdev->name, batostr(bdaddr));
 
 	old_key = hci_find_link_key_type(hdev, bdaddr, HCI_LK_SMP_LTK);
 	if (old_key) {
@@ -1221,7 +1222,7 @@ int hci_remove_link_key(struct hci_dev *hdev, bdaddr_t *bdaddr)
 	if (!key)
 		return -ENOENT;
 
-	BT_DBG("%s removing %s", hdev->name, batostr(bdaddr));
+	pr_debug("%s removing %s\n", hdev->name, batostr(bdaddr));
 
 	list_del(&key->list);
 	kfree(key);
@@ -1259,7 +1260,7 @@ int hci_remove_remote_oob_data(struct hci_dev *hdev, bdaddr_t *bdaddr)
 	if (!data)
 		return -ENOENT;
 
-	BT_DBG("%s removing %s", hdev->name, batostr(bdaddr));
+	pr_debug("%s removing %s\n", hdev->name, batostr(bdaddr));
 
 	list_del(&data->list);
 	kfree(data);
@@ -1298,7 +1299,7 @@ int hci_add_remote_oob_data(struct hci_dev *hdev, bdaddr_t *bdaddr, u8 *hash,
 	memcpy(data->hash, hash, sizeof(data->hash));
 	memcpy(data->randomizer, randomizer, sizeof(data->randomizer));
 
-	BT_DBG("%s for %s", hdev->name, batostr(bdaddr));
+	pr_debug("%s for %s\n", hdev->name, batostr(bdaddr));
 
 	return 0;
 }
@@ -1390,7 +1391,7 @@ int hci_adv_entries_clear(struct hci_dev *hdev)
 		kfree(entry);
 	}
 
-	BT_DBG("%s adv cache cleared", hdev->name);
+	pr_debug("%s adv cache cleared\n", hdev->name);
 
 	return 0;
 }
@@ -1436,8 +1437,8 @@ int hci_add_adv_entry(struct hci_dev *hdev,
 
 	list_add(&entry->list, &hdev->adv_entries);
 
-	BT_DBG("%s adv entry added: address %s type %u", hdev->name,
-				batostr(&entry->bdaddr), entry->bdaddr_type);
+	pr_debug("%s adv entry added: address %s type %u\n",
+		 hdev->name, batostr(&entry->bdaddr), entry->bdaddr_type);
 
 	return 0;
 }
@@ -1448,8 +1449,8 @@ int hci_register_dev(struct hci_dev *hdev)
 	struct list_head *head = &hci_dev_list, *p;
 	int i, id, error;
 
-	BT_DBG("%p name %s bus %d owner %p", hdev, hdev->name,
-						hdev->bus, hdev->owner);
+	pr_debug("%p name %s bus %d owner %p\n",
+		 hdev, hdev->name, hdev->bus, hdev->owner);
 
 	if (!hdev->open || !hdev->close || !hdev->destruct)
 		return -EINVAL;
@@ -1575,7 +1576,7 @@ void hci_unregister_dev(struct hci_dev *hdev)
 {
 	int i;
 
-	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
+	pr_debug("%p name %s bus %d\n", hdev, hdev->name, hdev->bus);
 
 	write_lock(&hci_dev_list_lock);
 	list_del(&hdev->list);
@@ -1829,7 +1830,7 @@ EXPORT_SYMBOL(hci_recv_stream_fragment);
 
 int hci_register_cb(struct hci_cb *cb)
 {
-	BT_DBG("%p name %s", cb, cb->name);
+	pr_debug("%p name %s\n", cb, cb->name);
 
 	write_lock(&hci_cb_list_lock);
 	list_add(&cb->list, &hci_cb_list);
@@ -1841,7 +1842,7 @@ EXPORT_SYMBOL(hci_register_cb);
 
 int hci_unregister_cb(struct hci_cb *cb)
 {
-	BT_DBG("%p name %s", cb, cb->name);
+	pr_debug("%p name %s\n", cb, cb->name);
 
 	write_lock(&hci_cb_list_lock);
 	list_del(&cb->list);
@@ -1860,7 +1861,8 @@ static int hci_send_frame(struct sk_buff *skb)
 		return -ENODEV;
 	}
 
-	BT_DBG("%s type %d len %d", hdev->name, bt_cb(skb)->pkt_type, skb->len);
+	pr_debug("%s type %d len %d\n",
+		 hdev->name, bt_cb(skb)->pkt_type, skb->len);
 
 	if (atomic_read(&hdev->promisc)) {
 		/* Time stamp */
@@ -1882,7 +1884,7 @@ int hci_send_cmd(struct hci_dev *hdev, __u16 opcode, __u32 plen, void *param)
 	struct hci_command_hdr *hdr;
 	struct sk_buff *skb;
 
-	BT_DBG("%s opcode 0x%x plen %d", hdev->name, opcode, plen);
+	pr_debug("%s opcode 0x%x plen %d\n", hdev->name, opcode, plen);
 
 	skb = bt_skb_alloc(len, GFP_ATOMIC);
 	if (!skb) {
@@ -1897,7 +1899,7 @@ int hci_send_cmd(struct hci_dev *hdev, __u16 opcode, __u32 plen, void *param)
 	if (plen)
 		memcpy(skb_put(skb, plen), param, plen);
 
-	BT_DBG("skb len %d", skb->len);
+	pr_debug("skb len %d\n", skb->len);
 
 	bt_cb(skb)->pkt_type = HCI_COMMAND_PKT;
 	skb->dev = (void *) hdev;
@@ -1924,7 +1926,7 @@ void *hci_sent_cmd_data(struct hci_dev *hdev, __u16 opcode)
 	if (hdr->opcode != cpu_to_le16(opcode))
 		return NULL;
 
-	BT_DBG("%s opcode 0x%x", hdev->name, opcode);
+	pr_debug("%s opcode 0x%x\n", hdev->name, opcode);
 
 	return hdev->sent_cmd->data + HCI_COMMAND_HDR_SIZE;
 }
@@ -1951,12 +1953,13 @@ static void hci_queue_acl(struct hci_conn *conn, struct sk_buff_head *queue,
 	list = skb_shinfo(skb)->frag_list;
 	if (!list) {
 		/* Non fragmented */
-		BT_DBG("%s nonfrag skb %p len %d", hdev->name, skb, skb->len);
+		pr_debug("%s nonfrag skb %p len %d\n",
+			 hdev->name, skb, skb->len);
 
 		skb_queue_tail(queue, skb);
 	} else {
 		/* Fragmented */
-		BT_DBG("%s frag %p len %d", hdev->name, skb, skb->len);
+		pr_debug("%s frag %p len %d\n", hdev->name, skb, skb->len);
 
 		skb_shinfo(skb)->frag_list = NULL;
 
@@ -1974,7 +1977,8 @@ static void hci_queue_acl(struct hci_conn *conn, struct sk_buff_head *queue,
 			bt_cb(skb)->pkt_type = HCI_ACLDATA_PKT;
 			hci_add_acl_hdr(skb, conn->handle, flags);
 
-			BT_DBG("%s frag %p len %d", hdev->name, skb, skb->len);
+			pr_debug("%s frag %p len %d\n",
+				 hdev->name, skb, skb->len);
 
 			__skb_queue_tail(queue, skb);
 		} while (list);
@@ -1988,7 +1992,7 @@ void hci_send_acl(struct hci_chan *chan, struct sk_buff *skb, __u16 flags)
 	struct hci_conn *conn = chan->conn;
 	struct hci_dev *hdev = conn->hdev;
 
-	BT_DBG("%s chan %p flags 0x%x", hdev->name, chan, flags);
+	pr_debug("%s chan %p flags 0x%x\n", hdev->name, chan, flags);
 
 	skb->dev = (void *) hdev;
 	bt_cb(skb)->pkt_type = HCI_ACLDATA_PKT;
@@ -2006,7 +2010,7 @@ void hci_send_sco(struct hci_conn *conn, struct sk_buff *skb)
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_sco_hdr hdr;
 
-	BT_DBG("%s len %d", hdev->name, skb->len);
+	pr_debug("%s len %d\n", hdev->name, skb->len);
 
 	hdr.handle = cpu_to_le16(conn->handle);
 	hdr.dlen   = skb->len;
@@ -2081,7 +2085,7 @@ static inline struct hci_conn *hci_low_sent(struct hci_dev *hdev, __u8 type, int
 	} else
 		*quote = 0;
 
-	BT_DBG("conn %p quote %d", conn, *quote);
+	pr_debug("conn %p quote %d\n", conn, *quote);
 	return conn;
 }
 
@@ -2115,7 +2119,7 @@ static inline struct hci_chan *hci_chan_sent(struct hci_dev *hdev, __u8 type,
 	struct hci_conn *conn;
 	int cnt, q, conn_num = 0;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	rcu_read_lock();
 
@@ -2181,7 +2185,7 @@ static inline struct hci_chan *hci_chan_sent(struct hci_dev *hdev, __u8 type,
 
 	q = cnt / num;
 	*quote = q ? q : 1;
-	BT_DBG("chan %p quote %d", chan, *quote);
+	pr_debug("chan %p quote %d\n", chan, *quote);
 	return chan;
 }
 
@@ -2191,7 +2195,7 @@ static void hci_prio_recalculate(struct hci_dev *hdev, __u8 type)
 	struct hci_conn *conn;
 	int num = 0;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	rcu_read_lock();
 
@@ -2223,8 +2227,8 @@ static void hci_prio_recalculate(struct hci_dev *hdev, __u8 type)
 
 			skb->priority = HCI_PRIO_MAX - 1;
 
-			BT_DBG("chan %p skb %p promoted to %d", chan, skb,
-								skb->priority);
+			pr_debug("chan %p skb %p promoted to %d\n",
+				 chan, skb, skb->priority);
 		}
 
 		if (hci_conn_num(hdev, type) == num)
@@ -2242,7 +2246,7 @@ static inline void hci_sched_acl(struct hci_dev *hdev)
 	int quote;
 	unsigned int cnt;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!hci_conn_num(hdev, ACL_LINK))
 		return;
@@ -2260,8 +2264,8 @@ static inline void hci_sched_acl(struct hci_dev *hdev)
 			(chan = hci_chan_sent(hdev, ACL_LINK, &quote))) {
 		u32 priority = (skb_peek(&chan->data_q))->priority;
 		while (quote-- && (skb = skb_peek(&chan->data_q))) {
-			BT_DBG("chan %p skb %p len %d priority %u", chan, skb,
-					skb->len, skb->priority);
+			pr_debug("chan %p skb %p len %d priority %u\n",
+				 chan, skb, skb->len, skb->priority);
 
 			/* Stop if priority has changed */
 			if (skb->priority < priority)
@@ -2292,14 +2296,14 @@ static inline void hci_sched_sco(struct hci_dev *hdev)
 	struct sk_buff *skb;
 	int quote;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!hci_conn_num(hdev, SCO_LINK))
 		return;
 
 	while (hdev->sco_cnt && (conn = hci_low_sent(hdev, SCO_LINK, &quote))) {
 		while (quote-- && (skb = skb_dequeue(&conn->data_q))) {
-			BT_DBG("skb %p len %d", skb, skb->len);
+			pr_debug("skb %p len %d\n", skb, skb->len);
 			hci_send_frame(skb);
 
 			conn->sent++;
@@ -2315,14 +2319,14 @@ static inline void hci_sched_esco(struct hci_dev *hdev)
 	struct sk_buff *skb;
 	int quote;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!hci_conn_num(hdev, ESCO_LINK))
 		return;
 
 	while (hdev->sco_cnt && (conn = hci_low_sent(hdev, ESCO_LINK, &quote))) {
 		while (quote-- && (skb = skb_dequeue(&conn->data_q))) {
-			BT_DBG("skb %p len %d", skb, skb->len);
+			pr_debug("skb %p len %d\n", skb, skb->len);
 			hci_send_frame(skb);
 
 			conn->sent++;
@@ -2338,7 +2342,7 @@ static inline void hci_sched_le(struct hci_dev *hdev)
 	struct sk_buff *skb;
 	int quote, cnt, tmp;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!hci_conn_num(hdev, LE_LINK))
 		return;
@@ -2356,8 +2360,8 @@ static inline void hci_sched_le(struct hci_dev *hdev)
 	while (cnt && (chan = hci_chan_sent(hdev, LE_LINK, &quote))) {
 		u32 priority = (skb_peek(&chan->data_q))->priority;
 		while (quote-- && (skb = skb_peek(&chan->data_q))) {
-			BT_DBG("chan %p skb %p len %d priority %u", chan, skb,
-					skb->len, skb->priority);
+			pr_debug("chan %p skb %p len %d priority %u\n",
+				 chan, skb, skb->len, skb->priority);
 
 			/* Stop if priority has changed */
 			if (skb->priority < priority)
@@ -2388,8 +2392,8 @@ static void hci_tx_work(struct work_struct *work)
 	struct hci_dev *hdev = container_of(work, struct hci_dev, tx_work);
 	struct sk_buff *skb;
 
-	BT_DBG("%s acl %d sco %d le %d", hdev->name, hdev->acl_cnt,
-		hdev->sco_cnt, hdev->le_cnt);
+	pr_debug("%s acl %d sco %d le %d\n",
+		 hdev->name, hdev->acl_cnt, hdev->sco_cnt, hdev->le_cnt);
 
 	/* Schedule queues and send stuff to HCI driver */
 
@@ -2421,7 +2425,8 @@ static inline void hci_acldata_packet(struct hci_dev *hdev, struct sk_buff *skb)
 	flags  = hci_flags(handle);
 	handle = hci_handle(handle);
 
-	BT_DBG("%s len %d handle 0x%x flags 0x%x", hdev->name, skb->len, handle, flags);
+	pr_debug("%s len %d handle 0x%x flags 0x%x\n",
+		 hdev->name, skb->len, handle, flags);
 
 	hdev->stat.acl_rx++;
 
@@ -2454,7 +2459,7 @@ static inline void hci_scodata_packet(struct hci_dev *hdev, struct sk_buff *skb)
 
 	handle = __le16_to_cpu(hdr->handle);
 
-	BT_DBG("%s len %d handle 0x%x", hdev->name, skb->len, handle);
+	pr_debug("%s len %d handle 0x%x\n", hdev->name, skb->len, handle);
 
 	hdev->stat.sco_rx++;
 
@@ -2479,7 +2484,7 @@ static void hci_rx_work(struct work_struct *work)
 	struct hci_dev *hdev = container_of(work, struct hci_dev, rx_work);
 	struct sk_buff *skb;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	while ((skb = skb_dequeue(&hdev->rx_q))) {
 		if (atomic_read(&hdev->promisc)) {
@@ -2505,17 +2510,17 @@ static void hci_rx_work(struct work_struct *work)
 		/* Process frame */
 		switch (bt_cb(skb)->pkt_type) {
 		case HCI_EVENT_PKT:
-			BT_DBG("%s Event packet", hdev->name);
+			pr_debug("%s Event packet\n", hdev->name);
 			hci_event_packet(hdev, skb);
 			break;
 
 		case HCI_ACLDATA_PKT:
-			BT_DBG("%s ACL data packet", hdev->name);
+			pr_debug("%s ACL data packet\n", hdev->name);
 			hci_acldata_packet(hdev, skb);
 			break;
 
 		case HCI_SCODATA_PKT:
-			BT_DBG("%s SCO data packet", hdev->name);
+			pr_debug("%s SCO data packet\n", hdev->name);
 			hci_scodata_packet(hdev, skb);
 			break;
 
@@ -2531,7 +2536,7 @@ static void hci_cmd_work(struct work_struct *work)
 	struct hci_dev *hdev = container_of(work, struct hci_dev, cmd_work);
 	struct sk_buff *skb;
 
-	BT_DBG("%s cmd %d", hdev->name, atomic_read(&hdev->cmd_cnt));
+	pr_debug("%s cmd %d\n", hdev->name, atomic_read(&hdev->cmd_cnt));
 
 	/* Send queued commands */
 	if (atomic_read(&hdev->cmd_cnt)) {
@@ -2563,7 +2568,7 @@ int hci_do_inquiry(struct hci_dev *hdev, u8 length)
 	u8 lap[3] = { 0x33, 0x8b, 0x9e };
 	struct hci_cp_inquiry cp;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (test_bit(HCI_INQUIRY, &hdev->flags))
 		return -EINPROGRESS;
@@ -2577,7 +2582,7 @@ int hci_do_inquiry(struct hci_dev *hdev, u8 length)
 
 int hci_cancel_inquiry(struct hci_dev *hdev)
 {
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!test_bit(HCI_INQUIRY, &hdev->flags))
 		return -EPERM;
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index f78d608..6ceae3d 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -53,7 +53,7 @@ static void hci_cc_inquiry_cancel(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (status) {
 		hci_dev_lock(hdev);
@@ -77,7 +77,7 @@ static void hci_cc_exit_periodic_inq(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (status)
 		return;
@@ -87,7 +87,7 @@ static void hci_cc_exit_periodic_inq(struct hci_dev *hdev, struct sk_buff *skb)
 
 static void hci_cc_remote_name_req_cancel(struct hci_dev *hdev, struct sk_buff *skb)
 {
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 }
 
 static void hci_cc_role_discovery(struct hci_dev *hdev, struct sk_buff *skb)
@@ -95,7 +95,7 @@ static void hci_cc_role_discovery(struct hci_dev *hdev, struct sk_buff *skb)
 	struct hci_rp_role_discovery *rp = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -118,7 +118,7 @@ static void hci_cc_read_link_policy(struct hci_dev *hdev, struct sk_buff *skb)
 	struct hci_rp_read_link_policy *rp = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -138,7 +138,7 @@ static void hci_cc_write_link_policy(struct hci_dev *hdev, struct sk_buff *skb)
 	struct hci_conn *conn;
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -160,7 +160,7 @@ static void hci_cc_read_def_link_policy(struct hci_dev *hdev, struct sk_buff *sk
 {
 	struct hci_rp_read_def_link_policy *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -173,7 +173,7 @@ static void hci_cc_write_def_link_policy(struct hci_dev *hdev, struct sk_buff *s
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	sent = hci_sent_cmd_data(hdev, HCI_OP_WRITE_DEF_LINK_POLICY);
 	if (!sent)
@@ -189,7 +189,7 @@ static void hci_cc_reset(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	clear_bit(HCI_RESET, &hdev->flags);
 
@@ -203,7 +203,7 @@ static void hci_cc_write_local_name(struct hci_dev *hdev, struct sk_buff *skb)
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	sent = hci_sent_cmd_data(hdev, HCI_OP_WRITE_LOCAL_NAME);
 	if (!sent)
@@ -224,7 +224,7 @@ static void hci_cc_read_local_name(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_read_local_name *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -237,7 +237,7 @@ static void hci_cc_write_auth_enable(struct hci_dev *hdev, struct sk_buff *skb)
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	sent = hci_sent_cmd_data(hdev, HCI_OP_WRITE_AUTH_ENABLE);
 	if (!sent)
@@ -260,7 +260,7 @@ static void hci_cc_write_encrypt_mode(struct hci_dev *hdev, struct sk_buff *skb)
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	sent = hci_sent_cmd_data(hdev, HCI_OP_WRITE_ENCRYPT_MODE);
 	if (!sent)
@@ -284,7 +284,7 @@ static void hci_cc_write_scan_enable(struct hci_dev *hdev, struct sk_buff *skb)
 	int old_pscan, old_iscan;
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	sent = hci_sent_cmd_data(hdev, HCI_OP_WRITE_SCAN_ENABLE);
 	if (!sent)
@@ -331,15 +331,16 @@ static void hci_cc_read_class_of_dev(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_read_class_of_dev *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
 
 	memcpy(hdev->dev_class, rp->dev_class, 3);
 
-	BT_DBG("%s class 0x%.2x%.2x%.2x", hdev->name,
-		hdev->dev_class[2], hdev->dev_class[1], hdev->dev_class[0]);
+	pr_debug("%s class 0x%.2x%.2x%.2x\n",
+		 hdev->name,
+		 hdev->dev_class[2], hdev->dev_class[1], hdev->dev_class[0]);
 }
 
 static void hci_cc_write_class_of_dev(struct hci_dev *hdev, struct sk_buff *skb)
@@ -347,7 +348,7 @@ static void hci_cc_write_class_of_dev(struct hci_dev *hdev, struct sk_buff *skb)
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (status)
 		return;
@@ -364,7 +365,7 @@ static void hci_cc_read_voice_setting(struct hci_dev *hdev, struct sk_buff *skb)
 	struct hci_rp_read_voice_setting *rp = (void *) skb->data;
 	__u16 setting;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -376,7 +377,7 @@ static void hci_cc_read_voice_setting(struct hci_dev *hdev, struct sk_buff *skb)
 
 	hdev->voice_setting = setting;
 
-	BT_DBG("%s voice setting 0x%04x", hdev->name, setting);
+	pr_debug("%s voice setting 0x%04x\n", hdev->name, setting);
 
 	if (hdev->notify)
 		hdev->notify(hdev, HCI_NOTIFY_VOICE_SETTING);
@@ -388,7 +389,7 @@ static void hci_cc_write_voice_setting(struct hci_dev *hdev, struct sk_buff *skb
 	__u16 setting;
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (status)
 		return;
@@ -404,7 +405,7 @@ static void hci_cc_write_voice_setting(struct hci_dev *hdev, struct sk_buff *skb
 
 	hdev->voice_setting = setting;
 
-	BT_DBG("%s voice setting 0x%04x", hdev->name, setting);
+	pr_debug("%s voice setting 0x%04x\n", hdev->name, setting);
 
 	if (hdev->notify)
 		hdev->notify(hdev, HCI_NOTIFY_VOICE_SETTING);
@@ -414,7 +415,7 @@ static void hci_cc_host_buffer_size(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_HOST_BUFFER_SIZE, status);
 }
@@ -423,7 +424,7 @@ static void hci_cc_read_ssp_mode(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_read_ssp_mode *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -436,7 +437,7 @@ static void hci_cc_write_ssp_mode(struct hci_dev *hdev, struct sk_buff *skb)
 	__u8 status = *((__u8 *) skb->data);
 	void *sent;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (status)
 		return;
@@ -591,7 +592,7 @@ static void hci_cc_read_local_version(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_read_local_version *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -602,9 +603,9 @@ static void hci_cc_read_local_version(struct hci_dev *hdev, struct sk_buff *skb)
 	hdev->manufacturer = __le16_to_cpu(rp->manufacturer);
 	hdev->lmp_subver = __le16_to_cpu(rp->lmp_subver);
 
-	BT_DBG("%s manufacturer %d hci ver %d:%d", hdev->name,
-					hdev->manufacturer,
-					hdev->hci_ver, hdev->hci_rev);
+	pr_debug("%s manufacturer %d hci ver %d:%d\n",
+		 hdev->name, hdev->manufacturer,
+		 hdev->hci_ver, hdev->hci_rev);
 
 	if (test_bit(HCI_INIT, &hdev->flags))
 		hci_setup(hdev);
@@ -632,7 +633,7 @@ static void hci_cc_read_local_commands(struct hci_dev *hdev, struct sk_buff *skb
 {
 	struct hci_rp_read_local_commands *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		goto done;
@@ -650,7 +651,7 @@ static void hci_cc_read_local_features(struct hci_dev *hdev, struct sk_buff *skb
 {
 	struct hci_rp_read_local_features *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -694,11 +695,12 @@ static void hci_cc_read_local_features(struct hci_dev *hdev, struct sk_buff *skb
 	if (hdev->features[5] & LMP_EDR_3S_ESCO)
 		hdev->esco_type |= (ESCO_2EV5 | ESCO_3EV5);
 
-	BT_DBG("%s features 0x%.2x%.2x%.2x%.2x%.2x%.2x%.2x%.2x", hdev->name,
-					hdev->features[0], hdev->features[1],
-					hdev->features[2], hdev->features[3],
-					hdev->features[4], hdev->features[5],
-					hdev->features[6], hdev->features[7]);
+	pr_debug("%s features 0x%.2x%.2x%.2x%.2x%.2x%.2x%.2x%.2x\n",
+		 hdev->name,
+		 hdev->features[0], hdev->features[1],
+		 hdev->features[2], hdev->features[3],
+		 hdev->features[4], hdev->features[5],
+		 hdev->features[6], hdev->features[7]);
 }
 
 static void hci_cc_read_local_ext_features(struct hci_dev *hdev,
@@ -706,7 +708,7 @@ static void hci_cc_read_local_ext_features(struct hci_dev *hdev,
 {
 	struct hci_rp_read_local_ext_features *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -728,7 +730,7 @@ static void hci_cc_read_flow_control_mode(struct hci_dev *hdev,
 {
 	struct hci_rp_read_flow_control_mode *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -742,7 +744,7 @@ static void hci_cc_read_buffer_size(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_read_buffer_size *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -760,16 +762,17 @@ static void hci_cc_read_buffer_size(struct hci_dev *hdev, struct sk_buff *skb)
 	hdev->acl_cnt = hdev->acl_pkts;
 	hdev->sco_cnt = hdev->sco_pkts;
 
-	BT_DBG("%s acl mtu %d:%d sco mtu %d:%d", hdev->name,
-					hdev->acl_mtu, hdev->acl_pkts,
-					hdev->sco_mtu, hdev->sco_pkts);
+	pr_debug("%s acl mtu %d:%d sco mtu %d:%d\n",
+		 hdev->name,
+		 hdev->acl_mtu, hdev->acl_pkts,
+		 hdev->sco_mtu, hdev->sco_pkts);
 }
 
 static void hci_cc_read_bd_addr(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_read_bd_addr *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (!rp->status)
 		bacpy(&hdev->bdaddr, &rp->bdaddr);
@@ -782,7 +785,7 @@ static void hci_cc_read_data_block_size(struct hci_dev *hdev,
 {
 	struct hci_rp_read_data_block_size *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -793,8 +796,9 @@ static void hci_cc_read_data_block_size(struct hci_dev *hdev,
 
 	hdev->block_cnt = hdev->num_blocks;
 
-	BT_DBG("%s blk mtu %d cnt %d len %d", hdev->name, hdev->block_mtu,
-					hdev->block_cnt, hdev->block_len);
+	pr_debug("%s blk mtu %d cnt %d len %d\n",
+		 hdev->name, hdev->block_mtu,
+		 hdev->block_cnt, hdev->block_len);
 
 	hci_req_complete(hdev, HCI_OP_READ_DATA_BLOCK_SIZE, rp->status);
 }
@@ -803,7 +807,7 @@ static void hci_cc_write_ca_timeout(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_WRITE_CA_TIMEOUT, status);
 }
@@ -813,7 +817,7 @@ static void hci_cc_read_local_amp_info(struct hci_dev *hdev,
 {
 	struct hci_rp_read_local_amp_info *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -837,7 +841,7 @@ static void hci_cc_delete_stored_link_key(struct hci_dev *hdev,
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_DELETE_STORED_LINK_KEY, status);
 }
@@ -846,7 +850,7 @@ static void hci_cc_set_event_mask(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_SET_EVENT_MASK, status);
 }
@@ -856,7 +860,7 @@ static void hci_cc_write_inquiry_mode(struct hci_dev *hdev,
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_WRITE_INQUIRY_MODE, status);
 }
@@ -866,7 +870,7 @@ static void hci_cc_read_inq_rsp_tx_power(struct hci_dev *hdev,
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_READ_INQ_RSP_TX_POWER, status);
 }
@@ -875,7 +879,7 @@ static void hci_cc_set_event_flt(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_SET_EVENT_FLT, status);
 }
@@ -886,7 +890,7 @@ static void hci_cc_pin_code_reply(struct hci_dev *hdev, struct sk_buff *skb)
 	struct hci_cp_pin_code_reply *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	hci_dev_lock(hdev);
 
@@ -912,7 +916,7 @@ static void hci_cc_pin_code_neg_reply(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_pin_code_neg_reply *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	hci_dev_lock(hdev);
 
@@ -928,7 +932,7 @@ static void hci_cc_le_read_buffer_size(struct hci_dev *hdev,
 {
 	struct hci_rp_le_read_buffer_size *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -938,7 +942,7 @@ static void hci_cc_le_read_buffer_size(struct hci_dev *hdev,
 
 	hdev->le_cnt = hdev->le_pkts;
 
-	BT_DBG("%s le mtu %d:%d", hdev->name, hdev->le_mtu, hdev->le_pkts);
+	pr_debug("%s le mtu %d:%d\n", hdev->name, hdev->le_mtu, hdev->le_pkts);
 
 	hci_req_complete(hdev, HCI_OP_LE_READ_BUFFER_SIZE, rp->status);
 }
@@ -947,7 +951,7 @@ static void hci_cc_user_confirm_reply(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_user_confirm_reply *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	hci_dev_lock(hdev);
 
@@ -963,7 +967,7 @@ static void hci_cc_user_confirm_neg_reply(struct hci_dev *hdev,
 {
 	struct hci_rp_user_confirm_reply *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	hci_dev_lock(hdev);
 
@@ -978,7 +982,7 @@ static void hci_cc_user_passkey_reply(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_user_confirm_reply *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	hci_dev_lock(hdev);
 
@@ -994,7 +998,7 @@ static void hci_cc_user_passkey_neg_reply(struct hci_dev *hdev,
 {
 	struct hci_rp_user_confirm_reply *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	hci_dev_lock(hdev);
 
@@ -1010,7 +1014,7 @@ static void hci_cc_read_local_oob_data_reply(struct hci_dev *hdev,
 {
 	struct hci_rp_read_local_oob_data *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	hci_dev_lock(hdev);
 	mgmt_read_local_oob_data_reply_complete(hdev, rp->hash,
@@ -1022,7 +1026,7 @@ static void hci_cc_le_set_scan_param(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 }
 
 static void hci_cc_le_set_scan_enable(struct hci_dev *hdev,
@@ -1031,7 +1035,7 @@ static void hci_cc_le_set_scan_enable(struct hci_dev *hdev,
 	struct hci_cp_le_set_scan_enable *cp;
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (status)
 		return;
@@ -1067,7 +1071,7 @@ static void hci_cc_le_ltk_reply(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_le_ltk_reply *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -1079,7 +1083,7 @@ static void hci_cc_le_ltk_neg_reply(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_rp_le_ltk_neg_reply *rp = (void *) skb->data;
 
-	BT_DBG("%s status 0x%x", hdev->name, rp->status);
+	pr_debug("%s status 0x%x\n", hdev->name, rp->status);
 
 	if (rp->status)
 		return;
@@ -1093,7 +1097,7 @@ static inline void hci_cc_write_le_host_supported(struct hci_dev *hdev,
 	struct hci_cp_read_local_ext_features cp;
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (status)
 		return;
@@ -1104,7 +1108,7 @@ static inline void hci_cc_write_le_host_supported(struct hci_dev *hdev,
 
 static inline void hci_cs_inquiry(struct hci_dev *hdev, __u8 status)
 {
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (status) {
 		hci_req_complete(hdev, HCI_OP_INQUIRY, status);
@@ -1128,7 +1132,7 @@ static inline void hci_cs_create_conn(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_create_conn *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	cp = hci_sent_cmd_data(hdev, HCI_OP_CREATE_CONN);
 	if (!cp)
@@ -1138,7 +1142,8 @@ static inline void hci_cs_create_conn(struct hci_dev *hdev, __u8 status)
 
 	conn = hci_conn_hash_lookup_ba(hdev, ACL_LINK, &cp->bdaddr);
 
-	BT_DBG("%s bdaddr %s conn %p", hdev->name, batostr(&cp->bdaddr), conn);
+	pr_debug("%s bdaddr %s conn %p\n",
+		 hdev->name, batostr(&cp->bdaddr), conn);
 
 	if (status) {
 		if (conn && conn->state == BT_CONNECT) {
@@ -1169,7 +1174,7 @@ static void hci_cs_add_sco(struct hci_dev *hdev, __u8 status)
 	struct hci_conn *acl, *sco;
 	__u16 handle;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1180,7 +1185,7 @@ static void hci_cs_add_sco(struct hci_dev *hdev, __u8 status)
 
 	handle = __le16_to_cpu(cp->handle);
 
-	BT_DBG("%s handle %d", hdev->name, handle);
+	pr_debug("%s handle %d\n", hdev->name, handle);
 
 	hci_dev_lock(hdev);
 
@@ -1203,7 +1208,7 @@ static void hci_cs_auth_requested(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_auth_requested *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1230,7 +1235,7 @@ static void hci_cs_set_conn_encrypt(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_set_conn_encrypt *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1276,7 +1281,7 @@ static void hci_cs_remote_name_req(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_remote_name_req *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	/* If successful wait for the name req complete event before
 	 * checking for the need to do authentication */
@@ -1311,7 +1316,7 @@ static void hci_cs_read_remote_features(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_read_remote_features *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1338,7 +1343,7 @@ static void hci_cs_read_remote_ext_features(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_read_remote_ext_features *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1366,7 +1371,7 @@ static void hci_cs_setup_sync_conn(struct hci_dev *hdev, __u8 status)
 	struct hci_conn *acl, *sco;
 	__u16 handle;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1377,7 +1382,7 @@ static void hci_cs_setup_sync_conn(struct hci_dev *hdev, __u8 status)
 
 	handle = __le16_to_cpu(cp->handle);
 
-	BT_DBG("%s handle %d", hdev->name, handle);
+	pr_debug("%s handle %d\n", hdev->name, handle);
 
 	hci_dev_lock(hdev);
 
@@ -1400,7 +1405,7 @@ static void hci_cs_sniff_mode(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_sniff_mode *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1427,7 +1432,7 @@ static void hci_cs_exit_sniff_mode(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_exit_sniff_mode *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	if (!status)
 		return;
@@ -1454,7 +1459,7 @@ static void hci_cs_le_create_conn(struct hci_dev *hdev, __u8 status)
 	struct hci_cp_le_create_conn *cp;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 
 	cp = hci_sent_cmd_data(hdev, HCI_OP_LE_CREATE_CONN);
 	if (!cp)
@@ -1464,8 +1469,8 @@ static void hci_cs_le_create_conn(struct hci_dev *hdev, __u8 status)
 
 	conn = hci_conn_hash_lookup_ba(hdev, LE_LINK, &cp->peer_addr);
 
-	BT_DBG("%s bdaddr %s conn %p", hdev->name, batostr(&cp->peer_addr),
-		conn);
+	pr_debug("%s bdaddr %s conn %p\n",
+		 hdev->name, batostr(&cp->peer_addr), conn);
 
 	if (status) {
 		if (conn && conn->state == BT_CONNECT) {
@@ -1490,14 +1495,14 @@ static void hci_cs_le_create_conn(struct hci_dev *hdev, __u8 status)
 
 static void hci_cs_le_start_enc(struct hci_dev *hdev, u8 status)
 {
-	BT_DBG("%s status 0x%x", hdev->name, status);
+	pr_debug("%s status 0x%x\n", hdev->name, status);
 }
 
 static inline void hci_inquiry_complete_evt(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	__u8 status = *((__u8 *) skb->data);
 
-	BT_DBG("%s status %d", hdev->name, status);
+	pr_debug("%s status %d\n", hdev->name, status);
 
 	hci_req_complete(hdev, HCI_OP_INQUIRY, status);
 
@@ -1517,7 +1522,7 @@ static inline void hci_inquiry_result_evt(struct hci_dev *hdev, struct sk_buff *
 	struct inquiry_info *info = (void *) (skb->data + 1);
 	int num_rsp = *((__u8 *) skb->data);
 
-	BT_DBG("%s num_rsp %d", hdev->name, num_rsp);
+	pr_debug("%s num_rsp %d\n", hdev->name, num_rsp);
 
 	if (!num_rsp)
 		return;
@@ -1546,7 +1551,7 @@ static inline void hci_conn_complete_evt(struct hci_dev *hdev, struct sk_buff *s
 	struct hci_ev_conn_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -1626,8 +1631,8 @@ static inline void hci_conn_request_evt(struct hci_dev *hdev, struct sk_buff *sk
 	struct hci_ev_conn_request *ev = (void *) skb->data;
 	int mask = hdev->link_mode;
 
-	BT_DBG("%s bdaddr %s type 0x%x", hdev->name,
-					batostr(&ev->bdaddr), ev->link_type);
+	pr_debug("%s bdaddr %s type 0x%x\n",
+		 hdev->name, batostr(&ev->bdaddr), ev->link_type);
 
 	mask |= hci_proto_connect_ind(hdev, &ev->bdaddr, ev->link_type);
 
@@ -1700,7 +1705,7 @@ static inline void hci_disconn_complete_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_ev_disconn_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	pr_debug("%s status %d\n", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -1733,7 +1738,7 @@ static inline void hci_auth_complete_evt(struct hci_dev *hdev, struct sk_buff *s
 	struct hci_ev_auth_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	pr_debug("%s status %d\n", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -1798,7 +1803,7 @@ static inline void hci_remote_name_evt(struct hci_dev *hdev, struct sk_buff *skb
 	struct hci_ev_remote_name *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_conn_check_pending(hdev);
 
@@ -1829,7 +1834,7 @@ static inline void hci_encrypt_change_evt(struct hci_dev *hdev, struct sk_buff *
 	struct hci_ev_encrypt_change *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	pr_debug("%s status %d\n", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -1865,7 +1870,7 @@ static inline void hci_change_link_key_complete_evt(struct hci_dev *hdev, struct
 	struct hci_ev_change_link_key_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	pr_debug("%s status %d\n", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -1887,7 +1892,7 @@ static inline void hci_remote_features_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_ev_remote_features *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	pr_debug("%s status %d\n", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -1930,12 +1935,12 @@ unlock:
 
 static inline void hci_remote_version_evt(struct hci_dev *hdev, struct sk_buff *skb)
 {
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 }
 
 static inline void hci_qos_setup_complete_evt(struct hci_dev *hdev, struct sk_buff *skb)
 {
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 }
 
 static inline void hci_cmd_complete_evt(struct hci_dev *hdev, struct sk_buff *skb)
@@ -2144,7 +2149,7 @@ static inline void hci_cmd_complete_evt(struct hci_dev *hdev, struct sk_buff *sk
 		break;
 
 	default:
-		BT_DBG("%s opcode 0x%x", hdev->name, opcode);
+		pr_debug("%s opcode 0x%x\n", hdev->name, opcode);
 		break;
 	}
 
@@ -2226,7 +2231,7 @@ static inline void hci_cmd_status_evt(struct hci_dev *hdev, struct sk_buff *skb)
 		break;
 
 	default:
-		BT_DBG("%s opcode 0x%x", hdev->name, opcode);
+		pr_debug("%s opcode 0x%x\n", hdev->name, opcode);
 		break;
 	}
 
@@ -2245,7 +2250,7 @@ static inline void hci_role_change_evt(struct hci_dev *hdev, struct sk_buff *skb
 	struct hci_ev_role_change *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	pr_debug("%s status %d\n", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -2278,11 +2283,11 @@ static inline void hci_num_comp_pkts_evt(struct hci_dev *hdev, struct sk_buff *s
 
 	if (skb->len < sizeof(*ev) || skb->len < sizeof(*ev) +
 			ev->num_hndl * sizeof(struct hci_comp_pkts_info)) {
-		BT_DBG("%s bad parameters", hdev->name);
+		pr_debug("%s bad parameters\n", hdev->name);
 		return;
 	}
 
-	BT_DBG("%s num_hndl %d", hdev->name, ev->num_hndl);
+	pr_debug("%s num_hndl %d\n", hdev->name, ev->num_hndl);
 
 	for (i = 0; i < ev->num_hndl; i++) {
 		struct hci_comp_pkts_info *info = &ev->handles[i];
@@ -2337,7 +2342,7 @@ static inline void hci_mode_change_evt(struct hci_dev *hdev, struct sk_buff *skb
 	struct hci_ev_mode_change *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	pr_debug("%s status %d\n", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -2365,7 +2370,7 @@ static inline void hci_pin_code_request_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_ev_pin_code_req *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2404,7 +2409,7 @@ static inline void hci_link_key_request_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_conn *conn;
 	struct link_key *key;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (!test_bit(HCI_LINK_KEYS, &hdev->flags))
 		return;
@@ -2413,17 +2418,17 @@ static inline void hci_link_key_request_evt(struct hci_dev *hdev, struct sk_buff
 
 	key = hci_find_link_key(hdev, &ev->bdaddr);
 	if (!key) {
-		BT_DBG("%s link key not found for %s", hdev->name,
-							batostr(&ev->bdaddr));
+		pr_debug("%s link key not found for %s\n",
+			 hdev->name, batostr(&ev->bdaddr));
 		goto not_found;
 	}
 
-	BT_DBG("%s found key type %u for %s", hdev->name, key->type,
-							batostr(&ev->bdaddr));
+	pr_debug("%s found key type %u for %s\n",
+		 hdev->name, key->type, batostr(&ev->bdaddr));
 
 	if (!test_bit(HCI_DEBUG_KEYS, &hdev->flags) &&
 				key->type == HCI_LK_DEBUG_COMBINATION) {
-		BT_DBG("%s ignoring debug key", hdev->name);
+		pr_debug("%s ignoring debug key\n", hdev->name);
 		goto not_found;
 	}
 
@@ -2432,14 +2437,15 @@ static inline void hci_link_key_request_evt(struct hci_dev *hdev, struct sk_buff
 		if (key->type == HCI_LK_UNAUTH_COMBINATION &&
 				conn->auth_type != 0xff &&
 				(conn->auth_type & 0x01)) {
-			BT_DBG("%s ignoring unauthenticated key", hdev->name);
+			pr_debug("%s ignoring unauthenticated key\n",
+				 hdev->name);
 			goto not_found;
 		}
 
 		if (key->type == HCI_LK_COMBINATION && key->pin_len < 16 &&
 				conn->pending_sec_level == BT_SECURITY_HIGH) {
-			BT_DBG("%s ignoring key unauthenticated for high \
-							security", hdev->name);
+			pr_debug("%s ignoring key unauthenticated for high security\n",
+				 hdev->name);
 			goto not_found;
 		}
 
@@ -2467,7 +2473,7 @@ static inline void hci_link_key_notify_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_conn *conn;
 	u8 pin_len = 0;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2495,7 +2501,7 @@ static inline void hci_clock_offset_evt(struct hci_dev *hdev, struct sk_buff *sk
 	struct hci_ev_clock_offset *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	pr_debug("%s status %d\n", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -2518,7 +2524,7 @@ static inline void hci_pkt_type_change_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_ev_pkt_type_change *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	pr_debug("%s status %d\n", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -2534,7 +2540,7 @@ static inline void hci_pscan_rep_mode_evt(struct hci_dev *hdev, struct sk_buff *
 	struct hci_ev_pscan_rep_mode *ev = (void *) skb->data;
 	struct inquiry_entry *ie;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2552,7 +2558,7 @@ static inline void hci_inquiry_result_with_rssi_evt(struct hci_dev *hdev, struct
 	struct inquiry_data data;
 	int num_rsp = *((__u8 *) skb->data);
 
-	BT_DBG("%s num_rsp %d", hdev->name, num_rsp);
+	pr_debug("%s num_rsp %d\n", hdev->name, num_rsp);
 
 	if (!num_rsp)
 		return;
@@ -2604,7 +2610,7 @@ static inline void hci_remote_ext_features_evt(struct hci_dev *hdev, struct sk_b
 	struct hci_ev_remote_ext_features *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2648,7 +2654,7 @@ static inline void hci_sync_conn_complete_evt(struct hci_dev *hdev, struct sk_bu
 	struct hci_ev_sync_conn_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	pr_debug("%s status %d\n", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -2700,14 +2706,14 @@ unlock:
 
 static inline void hci_sync_conn_changed_evt(struct hci_dev *hdev, struct sk_buff *skb)
 {
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 }
 
 static inline void hci_sniff_subrate_evt(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_ev_sniff_subrate *ev = (void *) skb->data;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	pr_debug("%s status %d\n", hdev->name, ev->status);
 }
 
 static inline void hci_extended_inquiry_result_evt(struct hci_dev *hdev, struct sk_buff *skb)
@@ -2716,7 +2722,7 @@ static inline void hci_extended_inquiry_result_evt(struct hci_dev *hdev, struct
 	struct extended_inquiry_info *info = (void *) (skb->data + 1);
 	int num_rsp = *((__u8 *) skb->data);
 
-	BT_DBG("%s num_rsp %d", hdev->name, num_rsp);
+	pr_debug("%s num_rsp %d\n", hdev->name, num_rsp);
 
 	if (!num_rsp)
 		return;
@@ -2764,7 +2770,7 @@ static inline void hci_io_capa_request_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_ev_io_capa_request *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2813,7 +2819,7 @@ static inline void hci_io_capa_reply_evt(struct hci_dev *hdev, struct sk_buff *s
 	struct hci_ev_io_capa_reply *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2836,7 +2842,7 @@ static inline void hci_user_confirm_request_evt(struct hci_dev *hdev,
 	int loc_mitm, rem_mitm, confirm_hint = 0;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2856,7 +2862,7 @@ static inline void hci_user_confirm_request_evt(struct hci_dev *hdev,
 	 * initiators (connect_cfm_cb set) since then we always have the MITM
 	 * bit set. */
 	if (!conn->connect_cfm_cb && loc_mitm && conn->remote_cap == 0x03) {
-		BT_DBG("Rejecting request: remote device can't provide MITM");
+		pr_debug("Rejecting request: remote device can't provide MITM\n");
 		hci_send_cmd(hdev, HCI_OP_USER_CONFIRM_NEG_REPLY,
 					sizeof(ev->bdaddr), &ev->bdaddr);
 		goto unlock;
@@ -2870,13 +2876,13 @@ static inline void hci_user_confirm_request_evt(struct hci_dev *hdev,
 		 * proceed from user space (mgmt_user_confirm with
 		 * confirm_hint set to 1). */
 		if (!test_bit(HCI_CONN_AUTH_PEND, &conn->pend)) {
-			BT_DBG("Confirming auto-accept as acceptor");
+			pr_debug("Confirming auto-accept as acceptor\n");
 			confirm_hint = 1;
 			goto confirm;
 		}
 
-		BT_DBG("Auto-accept of user confirmation with %ums delay",
-						hdev->auto_accept_delay);
+		pr_debug("Auto-accept of user confirmation with %ums delay\n",
+			 hdev->auto_accept_delay);
 
 		if (hdev->auto_accept_delay > 0) {
 			int delay = msecs_to_jiffies(hdev->auto_accept_delay);
@@ -2902,7 +2908,7 @@ static inline void hci_user_passkey_request_evt(struct hci_dev *hdev,
 {
 	struct hci_ev_user_passkey_req *ev = (void *) skb->data;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2917,7 +2923,7 @@ static inline void hci_simple_pair_complete_evt(struct hci_dev *hdev, struct sk_
 	struct hci_ev_simple_pair_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2944,7 +2950,7 @@ static inline void hci_remote_host_features_evt(struct hci_dev *hdev, struct sk_
 	struct hci_ev_remote_host_features *ev = (void *) skb->data;
 	struct inquiry_entry *ie;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2961,7 +2967,7 @@ static inline void hci_remote_oob_data_request_evt(struct hci_dev *hdev,
 	struct hci_ev_remote_oob_data_request *ev = (void *) skb->data;
 	struct oob_data *data;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	hci_dev_lock(hdev);
 
@@ -2995,7 +3001,7 @@ static inline void hci_le_conn_complete_evt(struct hci_dev *hdev, struct sk_buff
 	struct hci_ev_le_conn_complete *ev = (void *) skb->data;
 	struct hci_conn *conn;
 
-	BT_DBG("%s status %d", hdev->name, ev->status);
+	pr_debug("%s status %d\n", hdev->name, ev->status);
 
 	hci_dev_lock(hdev);
 
@@ -3063,7 +3069,7 @@ static inline void hci_le_ltk_request_evt(struct hci_dev *hdev,
 	struct hci_conn *conn;
 	struct link_key *ltk;
 
-	BT_DBG("%s handle %d", hdev->name, cpu_to_le16(ev->handle));
+	pr_debug("%s handle %d\n", hdev->name, cpu_to_le16(ev->handle));
 
 	hci_dev_lock(hdev);
 
@@ -3272,7 +3278,7 @@ void hci_event_packet(struct hci_dev *hdev, struct sk_buff *skb)
 		break;
 
 	default:
-		BT_DBG("%s event 0x%x", hdev->name, event);
+		pr_debug("%s event 0x%x\n", hdev->name, event);
 		break;
 	}
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 15edd1f..dd38ec3 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -91,7 +91,7 @@ void hci_send_to_sock(struct hci_dev *hdev, struct sk_buff *skb,
 	struct sock *sk;
 	struct hlist_node *node;
 
-	BT_DBG("hdev %p len %d", hdev, skb->len);
+	pr_debug("hdev %p len %d\n", hdev, skb->len);
 
 	read_lock(&hci_sk_list.lock);
 	sk_for_each(sk, node, &hci_sk_list.head) {
@@ -157,7 +157,7 @@ static int hci_sock_release(struct socket *sock)
 	struct sock *sk = sock->sk;
 	struct hci_dev *hdev;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	pr_debug("sock %p sk %p\n", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -266,7 +266,7 @@ static int hci_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long a
 	void __user *argp = (void __user *) arg;
 	int err;
 
-	BT_DBG("cmd %x arg %lx", cmd, arg);
+	pr_debug("cmd %x arg %lx\n", cmd, arg);
 
 	switch (cmd) {
 	case HCIGETDEVLIST:
@@ -328,7 +328,7 @@ static int hci_sock_bind(struct socket *sock, struct sockaddr *addr, int addr_le
 	struct hci_dev *hdev = NULL;
 	int len, err = 0;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	pr_debug("sock %p sk %p\n", sock, sk);
 
 	if (!addr)
 		return -EINVAL;
@@ -381,7 +381,7 @@ static int hci_sock_getname(struct socket *sock, struct sockaddr *addr, int *add
 	struct sock *sk = sock->sk;
 	struct hci_dev *hdev = hci_pi(sk)->hdev;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	pr_debug("sock %p sk %p\n", sock, sk);
 
 	if (!hdev)
 		return -EBADFD;
@@ -438,7 +438,7 @@ static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int copied, err;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	if (flags & (MSG_OOB))
 		return -EOPNOTSUPP;
@@ -476,7 +476,7 @@ static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int err;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	pr_debug("sock %p sk %p\n", sock, sk);
 
 	if (msg->msg_flags & MSG_OOB)
 		return -EOPNOTSUPP;
@@ -570,7 +570,7 @@ static int hci_sock_setsockopt(struct socket *sock, int level, int optname, char
 	struct sock *sk = sock->sk;
 	int err = 0, opt = 0;
 
-	BT_DBG("sk %p, opt %d", sk, optname);
+	pr_debug("sk %p, opt %d\n", sk, optname);
 
 	lock_sock(sk);
 
@@ -724,7 +724,7 @@ static int hci_sock_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	pr_debug("sock %p\n", sock);
 
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
@@ -753,7 +753,7 @@ static int hci_sock_dev_event(struct notifier_block *this, unsigned long event,
 	struct hci_dev *hdev = (struct hci_dev *) ptr;
 	struct hci_ev_si_device ev;
 
-	BT_DBG("hdev %s event %ld", hdev->name, event);
+	pr_debug("hdev %s event %ld\n", hdev->name, event);
 
 	/* Send event to sockets */
 	ev.event  = event;
diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index 11e23eb..81e7a37 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -103,7 +103,7 @@ void hci_conn_init_sysfs(struct hci_conn *conn)
 {
 	struct hci_dev *hdev = conn->hdev;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	conn->dev.type = &bt_link;
 	conn->dev.class = bt_class;
@@ -116,7 +116,7 @@ void hci_conn_add_sysfs(struct hci_conn *conn)
 {
 	struct hci_dev *hdev = conn->hdev;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	dev_set_name(&conn->dev, "%s:%d", hdev->name, conn->handle);
 
@@ -532,7 +532,7 @@ int hci_add_sysfs(struct hci_dev *hdev)
 	struct device *dev = &hdev->dev;
 	int err;
 
-	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
+	pr_debug("%p name %s bus %d\n", hdev, hdev->name, hdev->bus);
 
 	dev->parent = hdev->parent;
 	dev_set_name(dev, "%s", hdev->name);
@@ -563,7 +563,7 @@ int hci_add_sysfs(struct hci_dev *hdev)
 
 void hci_del_sysfs(struct hci_dev *hdev)
 {
-	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
+	pr_debug("%p name %s bus %d\n", hdev, hdev->name, hdev->bus);
 
 	debugfs_remove_recursive(hdev->debugfs);
 
diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 098383a..f371d4a 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -82,7 +82,7 @@ static struct hidp_session *__hidp_get_session(bdaddr_t *bdaddr)
 {
 	struct hidp_session *session;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	list_for_each_entry(session, &hidp_session_list, list) {
 		if (!bacmp(bdaddr, &session->bdaddr))
@@ -140,7 +140,8 @@ static int hidp_queue_event(struct hidp_session *session, struct input_dev *dev,
 	unsigned char newleds;
 	struct sk_buff *skb;
 
-	BT_DBG("session %p type %d code %d value %d", session, type, code, value);
+	pr_debug("session %p type %d code %d value %d\n",
+		 session, type, code, value);
 
 	if (type != EV_LED)
 		return -1;
@@ -250,7 +251,7 @@ static int __hidp_send_ctrl_message(struct hidp_session *session,
 {
 	struct sk_buff *skb;
 
-	BT_DBG("session %p data %p size %d", session, data, size);
+	pr_debug("session %p data %p size %d\n", session, data, size);
 
 	if (atomic_read(&session->terminate))
 		return -EIO;
@@ -287,7 +288,8 @@ static int hidp_queue_report(struct hidp_session *session,
 {
 	struct sk_buff *skb;
 
-	BT_DBG("session %p hid %p data %p size %d", session, session->hid, data, size);
+	pr_debug("session %p hid %p data %p size %d\n",
+		 session, session->hid, data, size);
 
 	skb = alloc_skb(size + 1, GFP_ATOMIC);
 	if (!skb) {
@@ -482,7 +484,7 @@ static inline void hidp_del_timer(struct hidp_session *session)
 static void hidp_process_handshake(struct hidp_session *session,
 					unsigned char param)
 {
-	BT_DBG("session %p param 0x%02x", session, param);
+	pr_debug("session %p param 0x%02x\n", session, param);
 	session->output_report_success = 0; /* default condition */
 
 	switch (param) {
@@ -525,7 +527,7 @@ static void hidp_process_handshake(struct hidp_session *session,
 static void hidp_process_hid_control(struct hidp_session *session,
 					unsigned char param)
 {
-	BT_DBG("session %p param 0x%02x", session, param);
+	pr_debug("session %p param 0x%02x\n", session, param);
 
 	if (param == HIDP_CTRL_VIRTUAL_CABLE_UNPLUG) {
 		/* Flush the transmit queues */
@@ -542,7 +544,8 @@ static int hidp_process_data(struct hidp_session *session, struct sk_buff *skb,
 				unsigned char param)
 {
 	int done_with_skb = 1;
-	BT_DBG("session %p skb %p len %d param 0x%02x", session, skb, skb->len, param);
+	pr_debug("session %p skb %p len %d param 0x%02x\n",
+		 session, skb, skb->len, param);
 
 	switch (param) {
 	case HIDP_DATA_RTYPE_INPUT:
@@ -586,7 +589,7 @@ static void hidp_recv_ctrl_frame(struct hidp_session *session,
 	unsigned char hdr, type, param;
 	int free_skb = 1;
 
-	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
+	pr_debug("session %p skb %p len %d\n", session, skb, skb->len);
 
 	hdr = skb->data[0];
 	skb_pull(skb, 1);
@@ -622,7 +625,7 @@ static void hidp_recv_intr_frame(struct hidp_session *session,
 {
 	unsigned char hdr;
 
-	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
+	pr_debug("session %p skb %p len %d\n", session, skb, skb->len);
 
 	hdr = skb->data[0];
 	skb_pull(skb, 1);
@@ -635,10 +638,10 @@ static void hidp_recv_intr_frame(struct hidp_session *session,
 
 		if (session->hid) {
 			hid_input_report(session->hid, HID_INPUT_REPORT, skb->data, skb->len, 1);
-			BT_DBG("report len %d", skb->len);
+			pr_debug("report len %d\n", skb->len);
 		}
 	} else {
-		BT_DBG("Unsupported protocol header 0x%02x", hdr);
+		pr_debug("Unsupported protocol header 0x%02x\n", hdr);
 	}
 
 	kfree_skb(skb);
@@ -649,7 +652,7 @@ static int hidp_send_frame(struct socket *sock, unsigned char *data, int len)
 	struct kvec iv = { data, len };
 	struct msghdr msg;
 
-	BT_DBG("sock %p data %p len %d", sock, data, len);
+	pr_debug("sock %p data %p len %d\n", sock, data, len);
 
 	if (!len)
 		return 0;
@@ -663,7 +666,7 @@ static void hidp_process_intr_transmit(struct hidp_session *session)
 {
 	struct sk_buff *skb;
 
-	BT_DBG("session %p", session);
+	pr_debug("session %p\n", session);
 
 	while ((skb = skb_dequeue(&session->intr_transmit))) {
 		if (hidp_send_frame(session->intr_sock, skb->data, skb->len) < 0) {
@@ -680,7 +683,7 @@ static void hidp_process_ctrl_transmit(struct hidp_session *session)
 {
 	struct sk_buff *skb;
 
-	BT_DBG("session %p", session);
+	pr_debug("session %p\n", session);
 
 	while ((skb = skb_dequeue(&session->ctrl_transmit))) {
 		if (hidp_send_frame(session->ctrl_sock, skb->data, skb->len) < 0) {
@@ -701,7 +704,7 @@ static int hidp_session(void *arg)
 	struct sk_buff *skb;
 	wait_queue_t ctrl_wait, intr_wait;
 
-	BT_DBG("session %p", session);
+	pr_debug("session %p\n", session);
 
 	__module_get(THIS_MODULE);
 	set_user_nice(current, -15);
@@ -976,13 +979,13 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	int vendor, product;
 	int err;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	if (bacmp(&bt_sk(ctrl_sock->sk)->src, &bt_sk(intr_sock->sk)->src) ||
 			bacmp(&bt_sk(ctrl_sock->sk)->dst, &bt_sk(intr_sock->sk)->dst))
 		return -ENOTUNIQ;
 
-	BT_DBG("rd_data %p rd_size %d", req->rd_data, req->rd_size);
+	pr_debug("rd_data %p rd_size %d\n", req->rd_data, req->rd_size);
 
 	down_write(&hidp_session_sem);
 
@@ -1005,7 +1008,8 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	session->intr_mtu = min_t(uint, l2cap_pi(intr_sock->sk)->chan->omtu,
 					l2cap_pi(intr_sock->sk)->chan->imtu);
 
-	BT_DBG("ctrl mtu %d intr mtu %d", session->ctrl_mtu, session->intr_mtu);
+	pr_debug("ctrl mtu %d intr mtu %d\n",
+		 session->ctrl_mtu, session->intr_mtu);
 
 	session->ctrl_sock = ctrl_sock;
 	session->intr_sock = intr_sock;
@@ -1126,7 +1130,7 @@ int hidp_del_connection(struct hidp_conndel_req *req)
 	struct hidp_session *session;
 	int err = 0;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	down_read(&hidp_session_sem);
 
@@ -1155,7 +1159,7 @@ int hidp_get_connlist(struct hidp_connlist_req *req)
 	struct hidp_session *session;
 	int err = 0, n = 0;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	down_read(&hidp_session_sem);
 
diff --git a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
index fbaaf1f..4f05143 100644
--- a/net/bluetooth/hidp/sock.c
+++ b/net/bluetooth/hidp/sock.c
@@ -43,7 +43,7 @@ static int hidp_sock_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	BT_DBG("sock %p sk %p", sock, sk);
+	pr_debug("sock %p sk %p\n", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -65,7 +65,7 @@ static int hidp_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long
 	struct socket *isock;
 	int err;
 
-	BT_DBG("cmd %x arg %lx", cmd, arg);
+	pr_debug("cmd %x arg %lx\n", cmd, arg);
 
 	switch (cmd) {
 	case HIDPCONNADD:
@@ -247,7 +247,7 @@ static int hidp_sock_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	pr_debug("sock %p\n", sock);
 
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 9dbf868..fb9f89a 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -245,8 +245,8 @@ static char *state_to_string(int state)
 
 static void l2cap_state_change(struct l2cap_chan *chan, int state)
 {
-	BT_DBG("%p %s -> %s", chan, state_to_string(chan->state),
-						state_to_string(state));
+	pr_debug("%p %s -> %s\n",
+		 chan, state_to_string(chan->state), state_to_string(state));
 
 	chan->state = state;
 	chan->ops->state_change(chan->data, state);
@@ -259,7 +259,7 @@ static void l2cap_chan_timeout(struct work_struct *work)
 	struct sock *sk = chan->sk;
 	int reason;
 
-	BT_DBG("chan %p state %d", chan, chan->state);
+	pr_debug("chan %p state %d\n", chan, chan->state);
 
 	lock_sock(sk);
 
@@ -299,7 +299,7 @@ struct l2cap_chan *l2cap_chan_create(struct sock *sk)
 
 	atomic_set(&chan->refcnt, 1);
 
-	BT_DBG("sk %p chan %p", sk, chan);
+	pr_debug("sk %p chan %p\n", sk, chan);
 
 	return chan;
 }
@@ -315,8 +315,8 @@ void l2cap_chan_destroy(struct l2cap_chan *chan)
 
 static void l2cap_chan_add(struct l2cap_conn *conn, struct l2cap_chan *chan)
 {
-	BT_DBG("conn %p, psm 0x%2.2x, dcid 0x%4.4x", conn,
-			chan->psm, chan->dcid);
+	pr_debug("conn %p, psm 0x%2.2x, dcid 0x%4.4x\n",
+		 conn, chan->psm, chan->dcid);
 
 	conn->disc_reason = HCI_ERROR_REMOTE_USER_TERM;
 
@@ -367,7 +367,7 @@ static void l2cap_chan_del(struct l2cap_chan *chan, int err)
 
 	__clear_chan_timer(chan);
 
-	BT_DBG("chan %p, conn %p, err %d", chan, conn, err);
+	pr_debug("chan %p, conn %p, err %d\n", chan, conn, err);
 
 	if (conn) {
 		/* Delete from channel list */
@@ -418,7 +418,7 @@ static void l2cap_chan_cleanup_listen(struct sock *parent)
 {
 	struct sock *sk;
 
-	BT_DBG("parent %p", parent);
+	pr_debug("parent %p\n", parent);
 
 	/* Close not yet accepted channels */
 	while ((sk = bt_accept_dequeue(parent, NULL))) {
@@ -436,7 +436,8 @@ void l2cap_chan_close(struct l2cap_chan *chan, int reason)
 	struct l2cap_conn *conn = chan->conn;
 	struct sock *sk = chan->sk;
 
-	BT_DBG("chan %p state %d socket %p", chan, chan->state, sk->sk_socket);
+	pr_debug("chan %p state %d socket %p\n",
+		 chan, chan->state, sk->sk_socket);
 
 	switch (chan->state) {
 	case BT_LISTEN:
@@ -560,7 +561,7 @@ static void l2cap_send_cmd(struct l2cap_conn *conn, u8 ident, u8 code, u16 len,
 	struct sk_buff *skb = l2cap_build_cmd(conn, code, ident, len, data);
 	u8 flags;
 
-	BT_DBG("code 0x%2.2x", code);
+	pr_debug("code 0x%2.2x\n", code);
 
 	if (!skb)
 		return;
@@ -581,8 +582,8 @@ static void l2cap_do_send(struct l2cap_chan *chan, struct sk_buff *skb)
 	struct hci_conn *hcon = chan->conn->hcon;
 	u16 flags;
 
-	BT_DBG("chan %p, skb %p len %d priority %u", chan, skb, skb->len,
-							skb->priority);
+	pr_debug("chan %p, skb %p len %d priority %u\n",
+		 chan, skb, skb->len, skb->priority);
 
 	if (!test_bit(FLAG_FLUSHABLE, &chan->flags) &&
 					lmp_no_flush_capable(hcon->hdev))
@@ -612,7 +613,7 @@ static inline void l2cap_send_sframe(struct l2cap_chan *chan, u32 control)
 	if (chan->fcs == L2CAP_FCS_CRC16)
 		hlen += L2CAP_FCS_SIZE;
 
-	BT_DBG("chan %p, control 0x%8.8x", chan, control);
+	pr_debug("chan %p, control 0x%8.8x\n", chan, control);
 
 	count = min_t(unsigned int, conn->mtu, hlen);
 
@@ -742,7 +743,7 @@ static void l2cap_conn_start(struct l2cap_conn *conn)
 {
 	struct l2cap_chan *chan;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	rcu_read_lock();
 
@@ -867,7 +868,7 @@ static void l2cap_le_conn_ready(struct l2cap_conn *conn)
 	struct sock *parent, *sk;
 	struct l2cap_chan *chan, *pchan;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	/* Check if we have socket listening on cid */
 	pchan = l2cap_global_chan_by_scid(BT_LISTEN, L2CAP_CID_LE_DATA,
@@ -881,7 +882,7 @@ static void l2cap_le_conn_ready(struct l2cap_conn *conn)
 
 	/* Check for backlog size */
 	if (sk_acceptq_is_full(parent)) {
-		BT_DBG("backlog full %d", parent->sk_ack_backlog);
+		pr_debug("backlog full %d\n", parent->sk_ack_backlog);
 		goto clean;
 	}
 
@@ -914,7 +915,7 @@ static void l2cap_chan_ready(struct sock *sk)
 	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
 	struct sock *parent = bt_sk(sk)->parent;
 
-	BT_DBG("sk %p, parent %p", sk, parent);
+	pr_debug("sk %p, parent %p\n", sk, parent);
 
 	chan->conf_state = 0;
 	__clear_chan_timer(chan);
@@ -930,7 +931,7 @@ static void l2cap_conn_ready(struct l2cap_conn *conn)
 {
 	struct l2cap_chan *chan;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	if (!conn->hcon->out && conn->hcon->type == LE_LINK)
 		l2cap_le_conn_ready(conn);
@@ -968,7 +969,7 @@ static void l2cap_conn_unreliable(struct l2cap_conn *conn, int err)
 {
 	struct l2cap_chan *chan;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	rcu_read_lock();
 
@@ -1002,7 +1003,7 @@ static void l2cap_conn_del(struct hci_conn *hcon, int err)
 	if (!conn)
 		return;
 
-	BT_DBG("hcon %p conn %p, err %d", hcon, conn, err);
+	pr_debug("hcon %p conn %p, err %d\n", hcon, conn, err);
 
 	kfree_skb(conn->rx_skb);
 
@@ -1059,7 +1060,7 @@ static struct l2cap_conn *l2cap_conn_add(struct hci_conn *hcon, u8 status)
 	conn->hcon = hcon;
 	conn->hchan = hchan;
 
-	BT_DBG("hcon %p conn %p hchan %p", hcon, conn, hchan);
+	pr_debug("hcon %p conn %p hchan %p\n", hcon, conn, hchan);
 
 	if (hcon->hdev->le_mtu && hcon->type == LE_LINK)
 		conn->mtu = hcon->hdev->le_mtu;
@@ -1130,8 +1131,8 @@ int l2cap_chan_connect(struct l2cap_chan *chan, __le16 psm, u16 cid, bdaddr_t *d
 	__u8 auth_type;
 	int err;
 
-	BT_DBG("%s -> %s psm 0x%2.2x", batostr(src), batostr(dst),
-							chan->psm);
+	pr_debug("%s -> %s psm 0x%2.2x\n",
+		 batostr(src), batostr(dst), chan->psm);
 
 	hdev = hci_get_route(dst, src);
 	if (!hdev)
@@ -1278,7 +1279,7 @@ static void l2cap_monitor_timeout(struct work_struct *work)
 							monitor_timer.work);
 	struct sock *sk = chan->sk;
 
-	BT_DBG("chan %p", chan);
+	pr_debug("chan %p\n", chan);
 
 	lock_sock(sk);
 	if (chan->retry_count >= chan->remote_max_tx) {
@@ -1300,7 +1301,7 @@ static void l2cap_retrans_timeout(struct work_struct *work)
 							retrans_timer.work);
 	struct sock *sk = chan->sk;
 
-	BT_DBG("chan %p", chan);
+	pr_debug("chan %p\n", chan);
 
 	lock_sock(sk);
 	chan->retry_count = 1;
@@ -1556,7 +1557,7 @@ static struct sk_buff *l2cap_create_connless_pdu(struct l2cap_chan *chan,
 	int err, count, hlen = L2CAP_HDR_SIZE + L2CAP_PSMLEN_SIZE;
 	struct l2cap_hdr *lh;
 
-	BT_DBG("sk %p len %d priority %u", sk, (int)len, priority);
+	pr_debug("sk %p len %d priority %u\n", sk, (int)len, priority);
 
 	count = min_t(unsigned int, (conn->mtu - hlen), len);
 	skb = bt_skb_send_alloc(sk, count + hlen,
@@ -1590,7 +1591,7 @@ static struct sk_buff *l2cap_create_basic_pdu(struct l2cap_chan *chan,
 	int err, count, hlen = L2CAP_HDR_SIZE;
 	struct l2cap_hdr *lh;
 
-	BT_DBG("sk %p len %d", sk, (int)len);
+	pr_debug("sk %p len %d\n", sk, (int)len);
 
 	count = min_t(unsigned int, (conn->mtu - hlen), len);
 	skb = bt_skb_send_alloc(sk, count + hlen,
@@ -1623,7 +1624,7 @@ static struct sk_buff *l2cap_create_iframe_pdu(struct l2cap_chan *chan,
 	int err, count, hlen;
 	struct l2cap_hdr *lh;
 
-	BT_DBG("sk %p len %d", sk, (int)len);
+	pr_debug("sk %p len %d\n", sk, (int)len);
 
 	if (!conn)
 		return ERR_PTR(-ENOTCONN);
@@ -1786,7 +1787,7 @@ int l2cap_chan_send(struct l2cap_chan *chan, struct msghdr *msg, size_t len,
 		break;
 
 	default:
-		BT_DBG("bad state %1.1x", chan->mode);
+		pr_debug("bad state %1.1x\n", chan->mode);
 		err = -EBADFD;
 	}
 
@@ -1799,7 +1800,7 @@ static void l2cap_raw_recv(struct l2cap_conn *conn, struct sk_buff *skb)
 	struct sk_buff *nskb;
 	struct l2cap_chan *chan;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	rcu_read_lock();
 
@@ -1831,8 +1832,8 @@ static struct sk_buff *l2cap_build_cmd(struct l2cap_conn *conn,
 	struct l2cap_hdr *lh;
 	int len, count;
 
-	BT_DBG("conn %p, code 0x%2.2x, ident 0x%2.2x, len %d",
-			conn, code, ident, dlen);
+	pr_debug("conn %p, code 0x%2.2x, ident 0x%2.2x, len %d\n",
+		 conn, code, ident, dlen);
 
 	len = L2CAP_HDR_SIZE + L2CAP_CMD_HDR_SIZE + dlen;
 	count = min_t(unsigned int, conn->mtu, len);
@@ -1915,7 +1916,7 @@ static inline int l2cap_get_conf_opt(void **ptr, int *type, int *olen, unsigned
 		break;
 	}
 
-	BT_DBG("type 0x%2.2x len %d val 0x%lx", *type, opt->len, *val);
+	pr_debug("type 0x%2.2x len %d val 0x%lx\n", *type, opt->len, *val);
 	return len;
 }
 
@@ -1923,7 +1924,7 @@ static void l2cap_add_conf_opt(void **ptr, u8 type, u8 len, unsigned long val)
 {
 	struct l2cap_conf_opt *opt = *ptr;
 
-	BT_DBG("type 0x%2.2x len %d val 0x%lx", type, len, val);
+	pr_debug("type 0x%2.2x len %d val 0x%lx\n", type, len, val);
 
 	opt->type = type;
 	opt->len  = len;
@@ -1985,7 +1986,7 @@ static void l2cap_ack_timeout(struct work_struct *work)
 	struct l2cap_chan *chan = container_of(work, struct l2cap_chan,
 							ack_timer.work);
 
-	BT_DBG("chan %p", chan);
+	pr_debug("chan %p\n", chan);
 
 	lock_sock(chan->sk);
 	l2cap_send_ack(chan);
@@ -2053,7 +2054,7 @@ static int l2cap_build_conf_req(struct l2cap_chan *chan, void *data)
 	void *ptr = req->data;
 	u16 size;
 
-	BT_DBG("chan %p", chan);
+	pr_debug("chan %p\n", chan);
 
 	if (chan->num_conf_req || chan->num_conf_rsp)
 		goto done;
@@ -2182,7 +2183,7 @@ static int l2cap_parse_conf_req(struct l2cap_chan *chan, void *data)
 	u16 result = L2CAP_CONF_SUCCESS;
 	u16 size;
 
-	BT_DBG("chan %p", chan);
+	pr_debug("chan %p\n", chan);
 
 	while (len >= L2CAP_CONF_OPT_SIZE) {
 		len -= l2cap_get_conf_opt(&req, &type, &olen, &val);
@@ -2396,7 +2397,7 @@ static int l2cap_parse_conf_rsp(struct l2cap_chan *chan, void *rsp, int len, voi
 	struct l2cap_conf_rfc rfc = { .mode = L2CAP_MODE_BASIC };
 	struct l2cap_conf_efs efs;
 
-	BT_DBG("chan %p, rsp %p, len %d, req %p", chan, rsp, len, data);
+	pr_debug("chan %p, rsp %p, len %d, req %p\n", chan, rsp, len, data);
 
 	while (len >= L2CAP_CONF_OPT_SIZE) {
 		len -= l2cap_get_conf_opt(&rsp, &type, &olen, &val);
@@ -2491,7 +2492,7 @@ static int l2cap_build_conf_rsp(struct l2cap_chan *chan, void *data, u16 result,
 	struct l2cap_conf_rsp *rsp = data;
 	void *ptr = rsp->data;
 
-	BT_DBG("chan %p", chan);
+	pr_debug("chan %p\n", chan);
 
 	rsp->scid   = cpu_to_le16(chan->dcid);
 	rsp->result = cpu_to_le16(result);
@@ -2527,7 +2528,7 @@ static void l2cap_conf_rfc_get(struct l2cap_chan *chan, void *rsp, int len)
 	unsigned long val;
 	struct l2cap_conf_rfc rfc;
 
-	BT_DBG("chan %p, rsp %p, len %d", chan, rsp, len);
+	pr_debug("chan %p, rsp %p, len %d\n", chan, rsp, len);
 
 	if ((chan->mode != L2CAP_MODE_ERTM) && (chan->mode != L2CAP_MODE_STREAMING))
 		return;
@@ -2596,7 +2597,7 @@ static inline int l2cap_connect_req(struct l2cap_conn *conn, struct l2cap_cmd_hd
 	u16 dcid = 0, scid = __le16_to_cpu(req->scid);
 	__le16 psm = req->psm;
 
-	BT_DBG("psm 0x%2.2x scid 0x%4.4x", psm, scid);
+	pr_debug("psm 0x%2.2x scid 0x%4.4x\n", psm, scid);
 
 	/* Check if we have socket listening on psm */
 	pchan = l2cap_global_chan_by_psm(BT_LISTEN, psm, conn->src);
@@ -2621,7 +2622,7 @@ static inline int l2cap_connect_req(struct l2cap_conn *conn, struct l2cap_cmd_hd
 
 	/* Check for backlog size */
 	if (sk_acceptq_is_full(parent)) {
-		BT_DBG("backlog full %d", parent->sk_ack_backlog);
+		pr_debug("backlog full %d\n", parent->sk_ack_backlog);
 		goto response;
 	}
 
@@ -2727,7 +2728,8 @@ static inline int l2cap_connect_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hd
 	result = __le16_to_cpu(rsp->result);
 	status = __le16_to_cpu(rsp->status);
 
-	BT_DBG("dcid 0x%4.4x scid 0x%4.4x result 0x%2.2x status 0x%2.2x", dcid, scid, result, status);
+	pr_debug("dcid 0x%4.4x scid 0x%4.4x result 0x%2.2x status 0x%2.2x\n",
+		 dcid, scid, result, status);
 
 	if (scid) {
 		chan = l2cap_get_chan_by_scid(conn, scid);
@@ -2792,7 +2794,7 @@ static inline int l2cap_config_req(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 	dcid  = __le16_to_cpu(req->dcid);
 	flags = __le16_to_cpu(req->flags);
 
-	BT_DBG("dcid 0x%4.4x flags 0x%2.2x", dcid, flags);
+	pr_debug("dcid 0x%4.4x flags 0x%2.2x\n", dcid, flags);
 
 	chan = l2cap_get_chan_by_scid(conn, dcid);
 	if (!chan)
@@ -2903,8 +2905,8 @@ static inline int l2cap_config_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 	flags  = __le16_to_cpu(rsp->flags);
 	result = __le16_to_cpu(rsp->result);
 
-	BT_DBG("scid 0x%4.4x flags 0x%2.2x result 0x%2.2x",
-			scid, flags, result);
+	pr_debug("scid 0x%4.4x flags 0x%2.2x result 0x%2.2x\n",
+		 scid, flags, result);
 
 	chan = l2cap_get_chan_by_scid(conn, scid);
 	if (!chan)
@@ -3010,7 +3012,7 @@ static inline int l2cap_disconnect_req(struct l2cap_conn *conn, struct l2cap_cmd
 	scid = __le16_to_cpu(req->scid);
 	dcid = __le16_to_cpu(req->dcid);
 
-	BT_DBG("scid 0x%4.4x dcid 0x%4.4x", scid, dcid);
+	pr_debug("scid 0x%4.4x dcid 0x%4.4x\n", scid, dcid);
 
 	chan = l2cap_get_chan_by_scid(conn, dcid);
 	if (!chan)
@@ -3041,7 +3043,7 @@ static inline int l2cap_disconnect_rsp(struct l2cap_conn *conn, struct l2cap_cmd
 	scid = __le16_to_cpu(rsp->scid);
 	dcid = __le16_to_cpu(rsp->dcid);
 
-	BT_DBG("dcid 0x%4.4x scid 0x%4.4x", dcid, scid);
+	pr_debug("dcid 0x%4.4x scid 0x%4.4x\n", dcid, scid);
 
 	chan = l2cap_get_chan_by_scid(conn, scid);
 	if (!chan)
@@ -3063,7 +3065,7 @@ static inline int l2cap_information_req(struct l2cap_conn *conn, struct l2cap_cm
 
 	type = __le16_to_cpu(req->type);
 
-	BT_DBG("type 0x%4.4x", type);
+	pr_debug("type 0x%4.4x\n", type);
 
 	if (type == L2CAP_IT_FEAT_MASK) {
 		u8 buf[8];
@@ -3114,7 +3116,7 @@ static inline int l2cap_information_rsp(struct l2cap_conn *conn, struct l2cap_cm
 	type   = __le16_to_cpu(rsp->type);
 	result = __le16_to_cpu(rsp->result);
 
-	BT_DBG("type 0x%4.4x result 0x%2.2x", type, result);
+	pr_debug("type 0x%4.4x result 0x%2.2x\n", type, result);
 
 	/* L2CAP Info req/rsp are unbound to channels, add extra checks */
 	if (cmd->ident != conn->info_ident ||
@@ -3176,7 +3178,7 @@ static inline int l2cap_create_channel_req(struct l2cap_conn *conn,
 	psm = le16_to_cpu(req->psm);
 	scid = le16_to_cpu(req->scid);
 
-	BT_DBG("psm %d, scid %d, amp_id %d", psm, scid, req->amp_id);
+	pr_debug("psm %d, scid %d, amp_id %d\n", psm, scid, req->amp_id);
 
 	/* Placeholder: Always reject */
 	rsp.dcid = 0;
@@ -3193,7 +3195,7 @@ static inline int l2cap_create_channel_req(struct l2cap_conn *conn,
 static inline int l2cap_create_channel_rsp(struct l2cap_conn *conn,
 					struct l2cap_cmd_hdr *cmd, void *data)
 {
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	return l2cap_connect_rsp(conn, cmd, data);
 }
@@ -3203,7 +3205,7 @@ static void l2cap_send_move_chan_rsp(struct l2cap_conn *conn, u8 ident,
 {
 	struct l2cap_move_chan_rsp rsp;
 
-	BT_DBG("icid %d, result %d", icid, result);
+	pr_debug("icid %d, result %d\n", icid, result);
 
 	rsp.icid = cpu_to_le16(icid);
 	rsp.result = cpu_to_le16(result);
@@ -3217,7 +3219,7 @@ static void l2cap_send_move_chan_cfm(struct l2cap_conn *conn,
 	struct l2cap_move_chan_cfm cfm;
 	u8 ident;
 
-	BT_DBG("icid %d, result %d", icid, result);
+	pr_debug("icid %d, result %d\n", icid, result);
 
 	ident = l2cap_get_ident(conn);
 	if (chan)
@@ -3234,7 +3236,7 @@ static void l2cap_send_move_chan_cfm_rsp(struct l2cap_conn *conn, u8 ident,
 {
 	struct l2cap_move_chan_cfm_rsp rsp;
 
-	BT_DBG("icid %d", icid);
+	pr_debug("icid %d\n", icid);
 
 	rsp.icid = cpu_to_le16(icid);
 	l2cap_send_cmd(conn, ident, L2CAP_MOVE_CHAN_CFM_RSP, sizeof(rsp), &rsp);
@@ -3252,7 +3254,7 @@ static inline int l2cap_move_channel_req(struct l2cap_conn *conn,
 
 	icid = le16_to_cpu(req->icid);
 
-	BT_DBG("icid %d, dest_amp_id %d", icid, req->dest_amp_id);
+	pr_debug("icid %d, dest_amp_id %d\n", icid, req->dest_amp_id);
 
 	if (!enable_hs)
 		return -EINVAL;
@@ -3275,7 +3277,7 @@ static inline int l2cap_move_channel_rsp(struct l2cap_conn *conn,
 	icid = le16_to_cpu(rsp->icid);
 	result = le16_to_cpu(rsp->result);
 
-	BT_DBG("icid %d, result %d", icid, result);
+	pr_debug("icid %d, result %d\n", icid, result);
 
 	/* Placeholder: Always unconfirmed */
 	l2cap_send_move_chan_cfm(conn, NULL, icid, L2CAP_MC_UNCONFIRMED);
@@ -3295,7 +3297,7 @@ static inline int l2cap_move_channel_confirm(struct l2cap_conn *conn,
 	icid = le16_to_cpu(cfm->icid);
 	result = le16_to_cpu(cfm->result);
 
-	BT_DBG("icid %d, result %d", icid, result);
+	pr_debug("icid %d, result %d\n", icid, result);
 
 	l2cap_send_move_chan_cfm_rsp(conn, cmd->ident, icid);
 
@@ -3313,7 +3315,7 @@ static inline int l2cap_move_channel_confirm_rsp(struct l2cap_conn *conn,
 
 	icid = le16_to_cpu(rsp->icid);
 
-	BT_DBG("icid %d", icid);
+	pr_debug("icid %d\n", icid);
 
 	return 0;
 }
@@ -3361,8 +3363,8 @@ static inline int l2cap_conn_param_update_req(struct l2cap_conn *conn,
 	latency		= __le16_to_cpu(req->latency);
 	to_multiplier	= __le16_to_cpu(req->to_multiplier);
 
-	BT_DBG("min 0x%4.4x max 0x%4.4x latency: 0x%4.4x Timeout: 0x%4.4x",
-						min, max, latency, to_multiplier);
+	pr_debug("min 0x%4.4x max 0x%4.4x latency: 0x%4.4x Timeout: 0x%4.4x\n",
+		 min, max, latency, to_multiplier);
 
 	memset(&rsp, 0, sizeof(rsp));
 
@@ -3500,10 +3502,11 @@ static inline void l2cap_sig_channel(struct l2cap_conn *conn,
 
 		cmd_len = le16_to_cpu(cmd.len);
 
-		BT_DBG("code 0x%2.2x len %d id 0x%2.2x", cmd.code, cmd_len, cmd.ident);
+		pr_debug("code 0x%2.2x len %d id 0x%2.2x\n",
+			 cmd.code, cmd_len, cmd.ident);
 
 		if (cmd_len > len || !cmd.ident) {
-			BT_DBG("corrupted command");
+			pr_debug("corrupted command\n");
 			break;
 		}
 
@@ -3715,7 +3718,7 @@ static void l2cap_ertm_enter_local_busy(struct l2cap_chan *chan)
 {
 	u32 control;
 
-	BT_DBG("chan %p, Enter local busy", chan);
+	pr_debug("chan %p, Enter local busy\n", chan);
 
 	set_bit(CONN_LOCAL_BUSY, &chan->conn_state);
 
@@ -3750,7 +3753,7 @@ done:
 	clear_bit(CONN_LOCAL_BUSY, &chan->conn_state);
 	clear_bit(CONN_RNR_SENT, &chan->conn_state);
 
-	BT_DBG("chan %p, Exit local busy", chan);
+	pr_debug("chan %p, Exit local busy\n", chan);
 }
 
 void l2cap_chan_busy(struct l2cap_chan *chan, int busy)
@@ -3843,8 +3846,8 @@ static inline int l2cap_data_channel_iframe(struct l2cap_chan *chan, u32 rx_cont
 	int num_to_ack = (chan->tx_win/6) + 1;
 	int err = 0;
 
-	BT_DBG("chan %p len %d tx_seq %d rx_control 0x%8.8x", chan, skb->len,
-							tx_seq, rx_control);
+	pr_debug("chan %p len %d tx_seq %d rx_control 0x%8.8x\n",
+		 chan, skb->len, tx_seq, rx_control);
 
 	if (__is_ctrl_final(chan, rx_control) &&
 			test_bit(CONN_WAIT_F, &chan->conn_state)) {
@@ -3887,7 +3890,7 @@ static inline int l2cap_data_channel_iframe(struct l2cap_chan *chan, u32 rx_cont
 				chan->buffer_seq = chan->buffer_seq_srej;
 				clear_bit(CONN_SREJ_SENT, &chan->conn_state);
 				l2cap_send_ack(chan);
-				BT_DBG("chan %p, Exit SREJ_SENT", chan);
+				pr_debug("chan %p, Exit SREJ_SENT\n", chan);
 			}
 		} else {
 			struct srej_list *l;
@@ -3919,7 +3922,7 @@ static inline int l2cap_data_channel_iframe(struct l2cap_chan *chan, u32 rx_cont
 
 		set_bit(CONN_SREJ_SENT, &chan->conn_state);
 
-		BT_DBG("chan %p, Enter SREJ", chan);
+		pr_debug("chan %p, Enter SREJ\n", chan);
 
 		INIT_LIST_HEAD(&chan->srej_l);
 		chan->buffer_seq_srej = chan->buffer_seq;
@@ -3978,8 +3981,8 @@ drop:
 
 static inline void l2cap_data_channel_rrframe(struct l2cap_chan *chan, u32 rx_control)
 {
-	BT_DBG("chan %p, req_seq %d ctrl 0x%8.8x", chan,
-				__get_reqseq(chan, rx_control), rx_control);
+	pr_debug("chan %p, req_seq %d ctrl 0x%8.8x\n",
+		 chan, __get_reqseq(chan, rx_control), rx_control);
 
 	chan->expected_ack_seq = __get_reqseq(chan, rx_control);
 	l2cap_drop_acked_frames(chan);
@@ -4020,7 +4023,8 @@ static inline void l2cap_data_channel_rejframe(struct l2cap_chan *chan, u32 rx_c
 {
 	u16 tx_seq = __get_reqseq(chan, rx_control);
 
-	BT_DBG("chan %p, req_seq %d ctrl 0x%8.8x", chan, tx_seq, rx_control);
+	pr_debug("chan %p, req_seq %d ctrl 0x%8.8x\n",
+		 chan, tx_seq, rx_control);
 
 	clear_bit(CONN_REMOTE_BUSY, &chan->conn_state);
 
@@ -4041,7 +4045,8 @@ static inline void l2cap_data_channel_srejframe(struct l2cap_chan *chan, u32 rx_
 {
 	u16 tx_seq = __get_reqseq(chan, rx_control);
 
-	BT_DBG("chan %p, req_seq %d ctrl 0x%8.8x", chan, tx_seq, rx_control);
+	pr_debug("chan %p, req_seq %d ctrl 0x%8.8x\n",
+		 chan, tx_seq, rx_control);
 
 	clear_bit(CONN_REMOTE_BUSY, &chan->conn_state);
 
@@ -4077,7 +4082,8 @@ static inline void l2cap_data_channel_rnrframe(struct l2cap_chan *chan, u32 rx_c
 {
 	u16 tx_seq = __get_reqseq(chan, rx_control);
 
-	BT_DBG("chan %p, req_seq %d ctrl 0x%8.8x", chan, tx_seq, rx_control);
+	pr_debug("chan %p, req_seq %d ctrl 0x%8.8x\n",
+		 chan, tx_seq, rx_control);
 
 	set_bit(CONN_REMOTE_BUSY, &chan->conn_state);
 	chan->expected_ack_seq = tx_seq;
@@ -4103,7 +4109,8 @@ static inline void l2cap_data_channel_rnrframe(struct l2cap_chan *chan, u32 rx_c
 
 static inline int l2cap_data_channel_sframe(struct l2cap_chan *chan, u32 rx_control, struct sk_buff *skb)
 {
-	BT_DBG("chan %p rx_control 0x%8.8x len %d", chan, rx_control, skb->len);
+	pr_debug("chan %p rx_control 0x%8.8x len %d\n",
+		 chan, rx_control, skb->len);
 
 	if (__is_ctrl_final(chan, rx_control) &&
 			test_bit(CONN_WAIT_F, &chan->conn_state)) {
@@ -4212,13 +4219,13 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 
 	chan = l2cap_get_chan_by_scid(conn, cid);
 	if (!chan) {
-		BT_DBG("unknown cid 0x%4.4x", cid);
+		pr_debug("unknown cid 0x%4.4x\n", cid);
 		goto drop;
 	}
 
 	sk = chan->sk;
 
-	BT_DBG("chan %p, len %d", chan, skb->len);
+	pr_debug("chan %p, len %d\n", chan, skb->len);
 
 	if (chan->state != BT_CONNECTED)
 		goto drop;
@@ -4279,7 +4286,7 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 		goto done;
 
 	default:
-		BT_DBG("chan %p: bad mode 0x%2.2x", chan, chan->mode);
+		pr_debug("chan %p: bad mode 0x%2.2x\n", chan, chan->mode);
 		break;
 	}
 
@@ -4306,7 +4313,7 @@ static inline int l2cap_conless_channel(struct l2cap_conn *conn, __le16 psm, str
 
 	lock_sock(sk);
 
-	BT_DBG("sk %p, len %d", sk, skb->len);
+	pr_debug("sk %p, len %d\n", sk, skb->len);
 
 	if (chan->state != BT_BOUND && chan->state != BT_CONNECTED)
 		goto drop;
@@ -4339,7 +4346,7 @@ static inline int l2cap_att_channel(struct l2cap_conn *conn, __le16 cid, struct
 
 	lock_sock(sk);
 
-	BT_DBG("sk %p, len %d", sk, skb->len);
+	pr_debug("sk %p, len %d\n", sk, skb->len);
 
 	if (chan->state != BT_BOUND && chan->state != BT_CONNECTED)
 		goto drop;
@@ -4374,7 +4381,7 @@ static void l2cap_recv_frame(struct l2cap_conn *conn, struct sk_buff *skb)
 		return;
 	}
 
-	BT_DBG("len %d, cid 0x%4.4x", len, cid);
+	pr_debug("len %d, cid 0x%4.4x\n", len, cid);
 
 	switch (cid) {
 	case L2CAP_CID_LE_SIGNALING:
@@ -4410,7 +4417,7 @@ int l2cap_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr)
 	int exact = 0, lm1 = 0, lm2 = 0;
 	struct l2cap_chan *c;
 
-	BT_DBG("hdev %s, bdaddr %s", hdev->name, batostr(bdaddr));
+	pr_debug("hdev %s, bdaddr %s\n", hdev->name, batostr(bdaddr));
 
 	/* Find listening sockets and check their link_mode */
 	read_lock(&chan_list_lock);
@@ -4440,7 +4447,8 @@ int l2cap_connect_cfm(struct hci_conn *hcon, u8 status)
 {
 	struct l2cap_conn *conn;
 
-	BT_DBG("hcon %p bdaddr %s status %d", hcon, batostr(&hcon->dst), status);
+	pr_debug("hcon %p bdaddr %s status %d\n",
+		 hcon, batostr(&hcon->dst), status);
 
 	if (!status) {
 		conn = l2cap_conn_add(hcon, status);
@@ -4456,7 +4464,7 @@ int l2cap_disconn_ind(struct hci_conn *hcon)
 {
 	struct l2cap_conn *conn = hcon->l2cap_data;
 
-	BT_DBG("hcon %p", hcon);
+	pr_debug("hcon %p\n", hcon);
 
 	if (!conn)
 		return HCI_ERROR_REMOTE_USER_TERM;
@@ -4465,7 +4473,7 @@ int l2cap_disconn_ind(struct hci_conn *hcon)
 
 int l2cap_disconn_cfm(struct hci_conn *hcon, u8 reason)
 {
-	BT_DBG("hcon %p reason %d", hcon, reason);
+	pr_debug("hcon %p reason %d\n", hcon, reason);
 
 	l2cap_conn_del(hcon, bt_to_errno(reason));
 	return 0;
@@ -4497,7 +4505,7 @@ int l2cap_security_cfm(struct hci_conn *hcon, u8 status, u8 encrypt)
 	if (!conn)
 		return 0;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	if (hcon->type == LE_LINK) {
 		smp_distribute_keys(conn, 0);
@@ -4511,7 +4519,7 @@ int l2cap_security_cfm(struct hci_conn *hcon, u8 status, u8 encrypt)
 
 		bh_lock_sock(sk);
 
-		BT_DBG("chan->scid %d", chan->scid);
+		pr_debug("chan->scid %d\n", chan->scid);
 
 		if (chan->scid == L2CAP_CID_LE_DATA) {
 			if (!status && encrypt) {
@@ -4601,7 +4609,7 @@ int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 flags)
 	if (!conn)
 		goto drop;
 
-	BT_DBG("conn %p len %d flags 0x%x", conn, skb->len, flags);
+	pr_debug("conn %p len %d flags 0x%x\n", conn, skb->len, flags);
 
 	if (!(flags & ACL_CONT)) {
 		struct l2cap_hdr *hdr;
@@ -4634,7 +4642,7 @@ int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 flags)
 			return 0;
 		}
 
-		BT_DBG("Start: total len %d, frag len %d", len, skb->len);
+		pr_debug("Start: total len %d, frag len %d\n", len, skb->len);
 
 		if (skb->len > len) {
 			bt_err("Frame is too long (len %d, expected len %d)\n",
@@ -4667,7 +4675,8 @@ int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 flags)
 								skb->len);
 		conn->rx_len = len - skb->len;
 	} else {
-		BT_DBG("Cont: frag len %d (expecting %d)", skb->len, conn->rx_len);
+		pr_debug("Cont: frag len %d (expecting %d)\n",
+			 skb->len, conn->rx_len);
 
 		if (!conn->rx_len) {
 			bt_err("Unexpected continuation frame (len %d)\n",
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 53e382c..fb0dbe0 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -46,7 +46,7 @@ static int l2cap_sock_bind(struct socket *sock, struct sockaddr *addr, int alen)
 	struct sockaddr_l2 la;
 	int len, err = 0;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (!addr || addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
@@ -110,7 +110,7 @@ static int l2cap_sock_connect(struct socket *sock, struct sockaddr *addr, int al
 	struct sockaddr_l2 la;
 	int len, err = 0;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (!addr || alen < sizeof(addr->sa_family) ||
 	    addr->sa_family != AF_BLUETOOTH)
@@ -141,7 +141,7 @@ static int l2cap_sock_listen(struct socket *sock, int backlog)
 	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
 	int err = 0;
 
-	BT_DBG("sk %p backlog %d", sk, backlog);
+	pr_debug("sk %p backlog %d\n", sk, backlog);
 
 	lock_sock(sk);
 
@@ -186,7 +186,7 @@ static int l2cap_sock_accept(struct socket *sock, struct socket *newsock, int fl
 
 	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
 
-	BT_DBG("sk %p timeo %ld", sk, timeo);
+	pr_debug("sk %p timeo %ld\n", sk, timeo);
 
 	/* Wait for an incoming connection. (wake-one). */
 	add_wait_queue_exclusive(sk_sleep(sk), &wait);
@@ -224,7 +224,7 @@ static int l2cap_sock_accept(struct socket *sock, struct socket *newsock, int fl
 
 	newsock->state = SS_CONNECTED;
 
-	BT_DBG("new socket %p", nsk);
+	pr_debug("new socket %p\n", nsk);
 
 done:
 	release_sock(sk);
@@ -237,7 +237,7 @@ static int l2cap_sock_getname(struct socket *sock, struct sockaddr *addr, int *l
 	struct sock *sk = sock->sk;
 	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	addr->sa_family = AF_BLUETOOTH;
 	*len = sizeof(struct sockaddr_l2);
@@ -264,7 +264,7 @@ static int l2cap_sock_getsockopt_old(struct socket *sock, int optname, char __us
 	int len, err = 0;
 	u32 opt;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (get_user(len, optlen))
 		return -EFAULT;
@@ -350,7 +350,7 @@ static int l2cap_sock_getsockopt(struct socket *sock, int level, int optname, ch
 	struct bt_power pwr;
 	int len, err = 0;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (level == SOL_L2CAP)
 		return l2cap_sock_getsockopt_old(sock, optname, optval, optlen);
@@ -443,7 +443,7 @@ static int l2cap_sock_setsockopt_old(struct socket *sock, int optname, char __us
 	int len, err = 0;
 	u32 opt;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	lock_sock(sk);
 
@@ -538,7 +538,7 @@ static int l2cap_sock_setsockopt(struct socket *sock, int level, int optname, ch
 	int len, err = 0;
 	u32 opt;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (level == SOL_L2CAP)
 		return l2cap_sock_setsockopt_old(sock, optname, optval, optlen);
@@ -700,7 +700,7 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct ms
 	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
 	int err;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	err = sock_error(sk);
 	if (err)
@@ -783,7 +783,7 @@ static void l2cap_sock_kill(struct sock *sk)
 	if (!sock_flag(sk, SOCK_ZAPPED) || sk->sk_socket)
 		return;
 
-	BT_DBG("sk %p state %d", sk, sk->sk_state);
+	pr_debug("sk %p state %d\n", sk, sk->sk_state);
 
 	/* Kill poor orphan */
 
@@ -798,7 +798,7 @@ static int l2cap_sock_shutdown(struct socket *sock, int how)
 	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
 	int err = 0;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -828,7 +828,7 @@ static int l2cap_sock_release(struct socket *sock)
 	struct sock *sk = sock->sk;
 	int err;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -909,7 +909,7 @@ static struct l2cap_ops l2cap_chan_ops = {
 
 static void l2cap_sock_destruct(struct sock *sk)
 {
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (l2cap_pi(sk)->rx_busy_skb) {
 		kfree_skb(l2cap_pi(sk)->rx_busy_skb);
@@ -925,7 +925,7 @@ static void l2cap_sock_init(struct sock *sk, struct sock *parent)
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
 	struct l2cap_chan *chan = pi->chan;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (parent) {
 		struct l2cap_chan *pchan = l2cap_pi(parent)->chan;
@@ -1027,7 +1027,7 @@ static int l2cap_sock_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	pr_debug("sock %p\n", sock);
 
 	sock->state = SS_UNCONNECTED;
 
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 2ef9c26..9e2b567 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -128,7 +128,8 @@ static int cmd_status(struct sock *sk, u16 index, u16 cmd, u8 status)
 	struct mgmt_ev_cmd_status *ev;
 	int err;
 
-	BT_DBG("sock %p, index %u, cmd %u, status %u", sk, index, cmd, status);
+	pr_debug("sock %p, index %u, cmd %u, status %u\n",
+		 sk, index, cmd, status);
 
 	skb = alloc_skb(sizeof(*hdr) + sizeof(*ev), GFP_ATOMIC);
 	if (!skb)
@@ -159,7 +160,7 @@ static int cmd_complete(struct sock *sk, u16 index, u16 cmd, void *rp,
 	struct mgmt_ev_cmd_complete *ev;
 	int err;
 
-	BT_DBG("sock %p", sk);
+	pr_debug("sock %p\n", sk);
 
 	skb = alloc_skb(sizeof(*hdr) + sizeof(*ev) + rp_len, GFP_ATOMIC);
 	if (!skb)
@@ -188,7 +189,7 @@ static int read_version(struct sock *sk)
 {
 	struct mgmt_rp_read_version rp;
 
-	BT_DBG("sock %p", sk);
+	pr_debug("sock %p\n", sk);
 
 	rp.version = MGMT_VERSION;
 	put_unaligned_le16(MGMT_REVISION, &rp.revision);
@@ -206,7 +207,7 @@ static int read_index_list(struct sock *sk)
 	u16 count;
 	int i, err;
 
-	BT_DBG("sock %p", sk);
+	pr_debug("sock %p\n", sk);
 
 	read_lock(&hci_dev_list_lock);
 
@@ -233,7 +234,7 @@ static int read_index_list(struct sock *sk)
 			continue;
 
 		put_unaligned_le16(d->id, &rp->index[i++]);
-		BT_DBG("Added hci%u", d->id);
+		pr_debug("Added hci%u\n", d->id);
 	}
 
 	read_unlock(&hci_dev_list_lock);
@@ -461,7 +462,7 @@ static int update_class(struct hci_dev *hdev)
 {
 	u8 cod[3];
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	if (test_bit(HCI_SERVICE_CACHE, &hdev->flags))
 		return 0;
@@ -507,7 +508,7 @@ static int read_controller_info(struct sock *sk, u16 index)
 	struct mgmt_rp_read_info rp;
 	struct hci_dev *hdev;
 
-	BT_DBG("sock %p hci%u", sk, index);
+	pr_debug("sock %p hci%u\n", sk, index);
 
 	hdev = hci_dev_get(index);
 	if (!hdev)
@@ -632,7 +633,7 @@ static int set_powered(struct sock *sk, u16 index, unsigned char *data, u16 len)
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	pr_debug("request for hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_SET_POWERED,
@@ -687,7 +688,7 @@ static int set_discoverable(struct sock *sk, u16 index, unsigned char *data,
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	pr_debug("request for hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_SET_DISCOVERABLE,
@@ -757,7 +758,7 @@ static int set_connectable(struct sock *sk, u16 index, unsigned char *data,
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	pr_debug("request for hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_SET_CONNECTABLE,
@@ -849,7 +850,7 @@ static int set_pairable(struct sock *sk, u16 index, unsigned char *data,
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	pr_debug("request for hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_SET_PAIRABLE,
@@ -891,7 +892,7 @@ static int add_uuid(struct sock *sk, u16 index, unsigned char *data, u16 len)
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	pr_debug("request for hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_ADD_UUID,
@@ -942,7 +943,7 @@ static int remove_uuid(struct sock *sk, u16 index, unsigned char *data, u16 len)
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	pr_debug("request for hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_REMOVE_UUID,
@@ -1004,7 +1005,7 @@ static int set_dev_class(struct sock *sk, u16 index, unsigned char *data,
 
 	cp = (void *) data;
 
-	BT_DBG("request for hci%u", index);
+	pr_debug("request for hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_SET_DEV_CLASS,
@@ -1068,8 +1069,8 @@ static int load_link_keys(struct sock *sk, u16 index, unsigned char *data,
 		return cmd_status(sk, index, MGMT_OP_LOAD_LINK_KEYS,
 						MGMT_STATUS_INVALID_PARAMS);
 
-	BT_DBG("hci%u debug_keys %u key_count %u", index, cp->debug_keys,
-								key_count);
+	pr_debug("hci%u debug_keys %u key_count %u\n",
+		 index, cp->debug_keys, key_count);
 
 	hci_dev_lock(hdev);
 
@@ -1175,7 +1176,7 @@ static int disconnect(struct sock *sk, u16 index, unsigned char *data, u16 len)
 	struct hci_conn *conn;
 	int err;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	cp = (void *) data;
 
@@ -1261,7 +1262,7 @@ static int get_connections(struct sock *sk, u16 index)
 	u16 count;
 	int i, err;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	hdev = hci_dev_get(index);
 	if (!hdev)
@@ -1335,7 +1336,7 @@ static int pin_code_reply(struct sock *sk, u16 index, unsigned char *data,
 	struct pending_cmd *cmd;
 	int err;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	cp = (void *) data;
 
@@ -1404,7 +1405,7 @@ static int pin_code_neg_reply(struct sock *sk, u16 index, unsigned char *data,
 	struct mgmt_cp_pin_code_neg_reply *cp;
 	int err;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	cp = (void *) data;
 
@@ -1440,7 +1441,7 @@ static int set_io_capability(struct sock *sk, u16 index, unsigned char *data,
 	struct hci_dev *hdev;
 	struct mgmt_cp_set_io_capability *cp;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	cp = (void *) data;
 
@@ -1457,8 +1458,8 @@ static int set_io_capability(struct sock *sk, u16 index, unsigned char *data,
 
 	hdev->io_capability = cp->io_capability;
 
-	BT_DBG("%s IO capability set to 0x%02x", hdev->name,
-							hdev->io_capability);
+	pr_debug("%s IO capability set to 0x%02x\n",
+		 hdev->name, hdev->io_capability);
 
 	hci_dev_unlock(hdev);
 	hci_dev_put(hdev);
@@ -1509,11 +1510,11 @@ static void pairing_complete_cb(struct hci_conn *conn, u8 status)
 {
 	struct pending_cmd *cmd;
 
-	BT_DBG("status %u", status);
+	pr_debug("status %u\n", status);
 
 	cmd = find_pairing(conn);
 	if (!cmd)
-		BT_DBG("Unable to find a pending command");
+		pr_debug("Unable to find a pending command\n");
 	else
 		pairing_complete(cmd, status);
 }
@@ -1528,7 +1529,7 @@ static int pair_device(struct sock *sk, u16 index, unsigned char *data, u16 len)
 	struct hci_conn *conn;
 	int err;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	cp = (void *) data;
 
@@ -1685,7 +1686,7 @@ static int user_confirm_reply(struct sock *sk, u16 index, void *data, u16 len)
 {
 	struct mgmt_cp_user_confirm_reply *cp = (void *) data;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_USER_CONFIRM_REPLY,
@@ -1701,7 +1702,7 @@ static int user_confirm_neg_reply(struct sock *sk, u16 index, void *data,
 {
 	struct mgmt_cp_user_confirm_neg_reply *cp = data;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_USER_CONFIRM_NEG_REPLY,
@@ -1716,7 +1717,7 @@ static int user_passkey_reply(struct sock *sk, u16 index, void *data, u16 len)
 {
 	struct mgmt_cp_user_passkey_reply *cp = (void *) data;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_USER_PASSKEY_REPLY,
@@ -1732,7 +1733,7 @@ static int user_passkey_neg_reply(struct sock *sk, u16 index, void *data,
 {
 	struct mgmt_cp_user_passkey_neg_reply *cp = (void *) data;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_USER_PASSKEY_NEG_REPLY,
@@ -1752,7 +1753,7 @@ static int set_local_name(struct sock *sk, u16 index, unsigned char *data,
 	struct pending_cmd *cmd;
 	int err;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	if (len != sizeof(*mgmt_cp))
 		return cmd_status(sk, index, MGMT_OP_SET_LOCAL_NAME,
@@ -1790,7 +1791,7 @@ static int read_local_oob_data(struct sock *sk, u16 index)
 	struct pending_cmd *cmd;
 	int err;
 
-	BT_DBG("hci%u", index);
+	pr_debug("hci%u\n", index);
 
 	hdev = hci_dev_get(index);
 	if (!hdev)
@@ -1841,7 +1842,7 @@ static int add_remote_oob_data(struct sock *sk, u16 index, unsigned char *data,
 	struct mgmt_cp_add_remote_oob_data *cp = (void *) data;
 	int err;
 
-	BT_DBG("hci%u ", index);
+	pr_debug("hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_ADD_REMOTE_OOB_DATA,
@@ -1876,7 +1877,7 @@ static int remove_remote_oob_data(struct sock *sk, u16 index,
 	struct mgmt_cp_remove_remote_oob_data *cp = (void *) data;
 	int err;
 
-	BT_DBG("hci%u ", index);
+	pr_debug("hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_REMOVE_REMOTE_OOB_DATA,
@@ -1911,7 +1912,7 @@ static int start_discovery(struct sock *sk, u16 index,
 	struct hci_dev *hdev;
 	int err;
 
-	BT_DBG("hci%u", index);
+	pr_debug("hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_START_DISCOVERY,
@@ -1953,7 +1954,7 @@ static int stop_discovery(struct sock *sk, u16 index)
 	struct pending_cmd *cmd;
 	int err;
 
-	BT_DBG("hci%u", index);
+	pr_debug("hci%u\n", index);
 
 	hdev = hci_dev_get(index);
 	if (!hdev)
@@ -1986,7 +1987,7 @@ static int block_device(struct sock *sk, u16 index, unsigned char *data,
 	struct mgmt_cp_block_device *cp = (void *) data;
 	int err;
 
-	BT_DBG("hci%u", index);
+	pr_debug("hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_BLOCK_DEVICE,
@@ -2020,7 +2021,7 @@ static int unblock_device(struct sock *sk, u16 index, unsigned char *data,
 	struct mgmt_cp_unblock_device *cp = (void *) data;
 	int err;
 
-	BT_DBG("hci%u", index);
+	pr_debug("hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_UNBLOCK_DEVICE,
@@ -2057,7 +2058,7 @@ static int set_fast_connectable(struct sock *sk, u16 index,
 	u8 type;
 	int err;
 
-	BT_DBG("hci%u", index);
+	pr_debug("hci%u\n", index);
 
 	if (len != sizeof(*cp))
 		return cmd_status(sk, index, MGMT_OP_SET_FAST_CONNECTABLE,
@@ -2111,7 +2112,7 @@ int mgmt_control(struct sock *sk, struct msghdr *msg, size_t msglen)
 	u16 opcode, index, len;
 	int err;
 
-	BT_DBG("got %zu bytes", msglen);
+	pr_debug("got %zu bytes\n", msglen);
 
 	if (msglen < sizeof(*hdr))
 		return -EINVAL;
@@ -2234,7 +2235,7 @@ int mgmt_control(struct sock *sk, struct msghdr *msg, size_t msglen)
 		err = unblock_device(sk, index, buf + sizeof(*hdr), len);
 		break;
 	default:
-		BT_DBG("Unknown op %u", opcode);
+		pr_debug("Unknown op %u\n", opcode);
 		err = cmd_status(sk, index, opcode,
 						MGMT_STATUS_UNKNOWN_COMMAND);
 		break;
@@ -2552,7 +2553,7 @@ int mgmt_user_confirm_request(struct hci_dev *hdev, bdaddr_t *bdaddr,
 {
 	struct mgmt_ev_user_confirm_request ev;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	bacpy(&ev.bdaddr, bdaddr);
 	ev.confirm_hint = confirm_hint;
@@ -2566,7 +2567,7 @@ int mgmt_user_passkey_request(struct hci_dev *hdev, bdaddr_t *bdaddr)
 {
 	struct mgmt_ev_user_passkey_request ev;
 
-	BT_DBG("%s", hdev->name);
+	pr_debug("%s\n", hdev->name);
 
 	bacpy(&ev.bdaddr, bdaddr);
 
@@ -2674,7 +2675,7 @@ int mgmt_read_local_oob_data_reply_complete(struct hci_dev *hdev, u8 *hash,
 	struct pending_cmd *cmd;
 	int err;
 
-	BT_DBG("%s status %u", hdev->name, status);
+	pr_debug("%s status %u\n", hdev->name, status);
 
 	cmd = mgmt_pending_find(MGMT_OP_READ_LOCAL_OOB_DATA, hdev);
 	if (!cmd)
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 18c3fce..8deffbb 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -202,13 +202,13 @@ static inline int __check_fcs(u8 *data, int type, u8 fcs)
 /* ---- L2CAP callbacks ---- */
 static void rfcomm_l2state_change(struct sock *sk)
 {
-	BT_DBG("%p state %d", sk, sk->sk_state);
+	pr_debug("%p state %d\n", sk, sk->sk_state);
 	rfcomm_schedule();
 }
 
 static void rfcomm_l2data_ready(struct sock *sk, int bytes)
 {
-	BT_DBG("%p bytes %d", sk, bytes);
+	pr_debug("%p bytes %d\n", sk, bytes);
 	rfcomm_schedule();
 }
 
@@ -216,7 +216,7 @@ static int rfcomm_l2sock_create(struct socket **sock)
 {
 	int err;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	err = sock_create_kern(PF_BLUETOOTH, SOCK_SEQPACKET, BTPROTO_L2CAP, sock);
 	if (!err) {
@@ -253,7 +253,7 @@ static void rfcomm_session_timeout(unsigned long arg)
 {
 	struct rfcomm_session *s = (void *) arg;
 
-	BT_DBG("session %p state %ld", s, s->state);
+	pr_debug("session %p state %ld\n", s, s->state);
 
 	set_bit(RFCOMM_TIMED_OUT, &s->flags);
 	rfcomm_schedule();
@@ -261,7 +261,7 @@ static void rfcomm_session_timeout(unsigned long arg)
 
 static void rfcomm_session_set_timer(struct rfcomm_session *s, long timeout)
 {
-	BT_DBG("session %p state %ld timeout %ld", s, s->state, timeout);
+	pr_debug("session %p state %ld timeout %ld\n", s, s->state, timeout);
 
 	if (!mod_timer(&s->timer, jiffies + timeout))
 		rfcomm_session_hold(s);
@@ -269,7 +269,7 @@ static void rfcomm_session_set_timer(struct rfcomm_session *s, long timeout)
 
 static void rfcomm_session_clear_timer(struct rfcomm_session *s)
 {
-	BT_DBG("session %p state %ld", s, s->state);
+	pr_debug("session %p state %ld\n", s, s->state);
 
 	if (timer_pending(&s->timer) && del_timer(&s->timer))
 		rfcomm_session_put(s);
@@ -280,7 +280,7 @@ static void rfcomm_dlc_timeout(unsigned long arg)
 {
 	struct rfcomm_dlc *d = (void *) arg;
 
-	BT_DBG("dlc %p state %ld", d, d->state);
+	pr_debug("dlc %p state %ld\n", d, d->state);
 
 	set_bit(RFCOMM_TIMED_OUT, &d->flags);
 	rfcomm_dlc_put(d);
@@ -289,7 +289,7 @@ static void rfcomm_dlc_timeout(unsigned long arg)
 
 static void rfcomm_dlc_set_timer(struct rfcomm_dlc *d, long timeout)
 {
-	BT_DBG("dlc %p state %ld timeout %ld", d, d->state, timeout);
+	pr_debug("dlc %p state %ld timeout %ld\n", d, d->state, timeout);
 
 	if (!mod_timer(&d->timer, jiffies + timeout))
 		rfcomm_dlc_hold(d);
@@ -297,7 +297,7 @@ static void rfcomm_dlc_set_timer(struct rfcomm_dlc *d, long timeout)
 
 static void rfcomm_dlc_clear_timer(struct rfcomm_dlc *d)
 {
-	BT_DBG("dlc %p state %ld", d, d->state);
+	pr_debug("dlc %p state %ld\n", d, d->state);
 
 	if (timer_pending(&d->timer) && del_timer(&d->timer))
 		rfcomm_dlc_put(d);
@@ -305,7 +305,7 @@ static void rfcomm_dlc_clear_timer(struct rfcomm_dlc *d)
 
 static void rfcomm_dlc_clear_state(struct rfcomm_dlc *d)
 {
-	BT_DBG("%p", d);
+	pr_debug("%p\n", d);
 
 	d->state      = BT_OPEN;
 	d->flags      = 0;
@@ -333,14 +333,14 @@ struct rfcomm_dlc *rfcomm_dlc_alloc(gfp_t prio)
 
 	rfcomm_dlc_clear_state(d);
 
-	BT_DBG("%p", d);
+	pr_debug("%p\n", d);
 
 	return d;
 }
 
 void rfcomm_dlc_free(struct rfcomm_dlc *d)
 {
-	BT_DBG("%p", d);
+	pr_debug("%p\n", d);
 
 	skb_queue_purge(&d->tx_queue);
 	kfree(d);
@@ -348,7 +348,7 @@ void rfcomm_dlc_free(struct rfcomm_dlc *d)
 
 static void rfcomm_dlc_link(struct rfcomm_session *s, struct rfcomm_dlc *d)
 {
-	BT_DBG("dlc %p session %p", d, s);
+	pr_debug("dlc %p session %p\n", d, s);
 
 	rfcomm_session_hold(s);
 
@@ -362,7 +362,8 @@ static void rfcomm_dlc_unlink(struct rfcomm_dlc *d)
 {
 	struct rfcomm_session *s = d->session;
 
-	BT_DBG("dlc %p refcnt %d session %p", d, atomic_read(&d->refcnt), s);
+	pr_debug("dlc %p refcnt %d session %p\n",
+		 d, atomic_read(&d->refcnt), s);
 
 	list_del(&d->list);
 	d->session = NULL;
@@ -391,8 +392,8 @@ static int __rfcomm_dlc_open(struct rfcomm_dlc *d, bdaddr_t *src, bdaddr_t *dst,
 	int err = 0;
 	u8 dlci;
 
-	BT_DBG("dlc %p state %ld %s %s channel %d",
-			d, d->state, batostr(src), batostr(dst), channel);
+	pr_debug("dlc %p state %ld %s %s channel %d\n",
+		 d, d->state, batostr(src), batostr(dst), channel);
 
 	if (channel < 1 || channel > 30)
 		return -EINVAL;
@@ -457,8 +458,8 @@ static int __rfcomm_dlc_close(struct rfcomm_dlc *d, int err)
 	if (!s)
 		return 0;
 
-	BT_DBG("dlc %p state %ld dlci %d err %d session %p",
-			d, d->state, d->dlci, err, s);
+	pr_debug("dlc %p state %ld dlci %d err %d session %p\n",
+		 d, d->state, d->dlci, err, s);
 
 	switch (d->state) {
 	case BT_CONNECT:
@@ -524,7 +525,7 @@ int rfcomm_dlc_send(struct rfcomm_dlc *d, struct sk_buff *skb)
 	if (d->state != BT_CONNECTED)
 		return -ENOTCONN;
 
-	BT_DBG("dlc %p mtu %d len %d", d, d->mtu, len);
+	pr_debug("dlc %p mtu %d len %d\n", d, d->mtu, len);
 
 	if (len > d->mtu)
 		return -EINVAL;
@@ -539,7 +540,7 @@ int rfcomm_dlc_send(struct rfcomm_dlc *d, struct sk_buff *skb)
 
 void __rfcomm_dlc_throttle(struct rfcomm_dlc *d)
 {
-	BT_DBG("dlc %p state %ld", d, d->state);
+	pr_debug("dlc %p state %ld\n", d, d->state);
 
 	if (!d->cfc) {
 		d->v24_sig |= RFCOMM_V24_FC;
@@ -550,7 +551,7 @@ void __rfcomm_dlc_throttle(struct rfcomm_dlc *d)
 
 void __rfcomm_dlc_unthrottle(struct rfcomm_dlc *d)
 {
-	BT_DBG("dlc %p state %ld", d, d->state);
+	pr_debug("dlc %p state %ld\n", d, d->state);
 
 	if (!d->cfc) {
 		d->v24_sig &= ~RFCOMM_V24_FC;
@@ -566,8 +567,8 @@ void __rfcomm_dlc_unthrottle(struct rfcomm_dlc *d)
  */
 int rfcomm_dlc_set_modem_status(struct rfcomm_dlc *d, u8 v24_sig)
 {
-	BT_DBG("dlc %p state %ld v24_sig 0x%x",
-			d, d->state, v24_sig);
+	pr_debug("dlc %p state %ld v24_sig 0x%x\n",
+		 d, d->state, v24_sig);
 
 	if (test_bit(RFCOMM_RX_THROTTLED, &d->flags))
 		v24_sig |= RFCOMM_V24_FC;
@@ -584,8 +585,8 @@ int rfcomm_dlc_set_modem_status(struct rfcomm_dlc *d, u8 v24_sig)
 
 int rfcomm_dlc_get_modem_status(struct rfcomm_dlc *d, u8 *v24_sig)
 {
-	BT_DBG("dlc %p state %ld v24_sig 0x%x",
-			d, d->state, d->v24_sig);
+	pr_debug("dlc %p state %ld v24_sig 0x%x\n",
+		 d, d->state, d->v24_sig);
 
 	*v24_sig = d->v24_sig;
 	return 0;
@@ -599,7 +600,7 @@ static struct rfcomm_session *rfcomm_session_add(struct socket *sock, int state)
 	if (!s)
 		return NULL;
 
-	BT_DBG("session %p sock %p", s, sock);
+	pr_debug("session %p sock %p\n", s, sock);
 
 	setup_timer(&s->timer, rfcomm_session_timeout, (unsigned long) s);
 
@@ -627,7 +628,7 @@ static void rfcomm_session_del(struct rfcomm_session *s)
 {
 	int state = s->state;
 
-	BT_DBG("session %p state %ld", s, s->state);
+	pr_debug("session %p state %ld\n", s, s->state);
 
 	list_del(&s->list);
 
@@ -663,7 +664,7 @@ static void rfcomm_session_close(struct rfcomm_session *s, int err)
 	struct rfcomm_dlc *d;
 	struct list_head *p, *n;
 
-	BT_DBG("session %p state %ld err %d", s, s->state, err);
+	pr_debug("session %p state %ld err %d\n", s, s->state, err);
 
 	rfcomm_session_hold(s);
 
@@ -690,7 +691,7 @@ static struct rfcomm_session *rfcomm_session_create(bdaddr_t *src,
 	struct socket *sock;
 	struct sock *sk;
 
-	BT_DBG("%s %s", batostr(src), batostr(dst));
+	pr_debug("%s %s\n", batostr(src), batostr(dst));
 
 	*err = rfcomm_l2sock_create(&sock);
 	if (*err < 0)
@@ -752,7 +753,7 @@ static int rfcomm_send_frame(struct rfcomm_session *s, u8 *data, int len)
 	struct kvec iv = { data, len };
 	struct msghdr msg;
 
-	BT_DBG("session %p len %d", s, len);
+	pr_debug("session %p len %d\n", s, len);
 
 	memset(&msg, 0, sizeof(msg));
 
@@ -761,7 +762,7 @@ static int rfcomm_send_frame(struct rfcomm_session *s, u8 *data, int len)
 
 static int rfcomm_send_cmd(struct rfcomm_session *s, struct rfcomm_cmd *cmd)
 {
-	BT_DBG("%p cmd %u", s, cmd->ctrl);
+	pr_debug("%p cmd %u\n", s, cmd->ctrl);
 
 	return rfcomm_send_frame(s, (void *) cmd, sizeof(*cmd));
 }
@@ -770,7 +771,7 @@ static int rfcomm_send_sabm(struct rfcomm_session *s, u8 dlci)
 {
 	struct rfcomm_cmd cmd;
 
-	BT_DBG("%p dlci %d", s, dlci);
+	pr_debug("%p dlci %d\n", s, dlci);
 
 	cmd.addr = __addr(s->initiator, dlci);
 	cmd.ctrl = __ctrl(RFCOMM_SABM, 1);
@@ -784,7 +785,7 @@ static int rfcomm_send_ua(struct rfcomm_session *s, u8 dlci)
 {
 	struct rfcomm_cmd cmd;
 
-	BT_DBG("%p dlci %d", s, dlci);
+	pr_debug("%p dlci %d\n", s, dlci);
 
 	cmd.addr = __addr(!s->initiator, dlci);
 	cmd.ctrl = __ctrl(RFCOMM_UA, 1);
@@ -798,7 +799,7 @@ static int rfcomm_send_disc(struct rfcomm_session *s, u8 dlci)
 {
 	struct rfcomm_cmd cmd;
 
-	BT_DBG("%p dlci %d", s, dlci);
+	pr_debug("%p dlci %d\n", s, dlci);
 
 	cmd.addr = __addr(s->initiator, dlci);
 	cmd.ctrl = __ctrl(RFCOMM_DISC, 1);
@@ -813,7 +814,7 @@ static int rfcomm_queue_disc(struct rfcomm_dlc *d)
 	struct rfcomm_cmd *cmd;
 	struct sk_buff *skb;
 
-	BT_DBG("dlc %p dlci %d", d, d->dlci);
+	pr_debug("dlc %p dlci %d\n", d, d->dlci);
 
 	skb = alloc_skb(sizeof(*cmd), GFP_KERNEL);
 	if (!skb)
@@ -834,7 +835,7 @@ static int rfcomm_send_dm(struct rfcomm_session *s, u8 dlci)
 {
 	struct rfcomm_cmd cmd;
 
-	BT_DBG("%p dlci %d", s, dlci);
+	pr_debug("%p dlci %d\n", s, dlci);
 
 	cmd.addr = __addr(!s->initiator, dlci);
 	cmd.ctrl = __ctrl(RFCOMM_DM, 1);
@@ -850,7 +851,7 @@ static int rfcomm_send_nsc(struct rfcomm_session *s, int cr, u8 type)
 	struct rfcomm_mcc *mcc;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d type %d", s, cr, type);
+	pr_debug("%p cr %d type %d\n", s, cr, type);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -876,7 +877,7 @@ static int rfcomm_send_pn(struct rfcomm_session *s, int cr, struct rfcomm_dlc *d
 	struct rfcomm_pn  *pn;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d dlci %d mtu %d", s, cr, d->dlci, d->mtu);
+	pr_debug("%p cr %d dlci %d mtu %d\n", s, cr, d->dlci, d->mtu);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -921,10 +922,9 @@ int rfcomm_send_rpn(struct rfcomm_session *s, int cr, u8 dlci,
 	struct rfcomm_rpn *rpn;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d dlci %d bit_r 0x%x data_b 0x%x stop_b 0x%x parity 0x%x"
-			" flwc_s 0x%x xon_c 0x%x xoff_c 0x%x p_mask 0x%x",
-		s, cr, dlci, bit_rate, data_bits, stop_bits, parity,
-		flow_ctrl_settings, xon_char, xoff_char, param_mask);
+	pr_debug("%p cr %d dlci %d bit_r 0x%x data_b 0x%x stop_b 0x%x parity 0x%x flwc_s 0x%x xon_c 0x%x xoff_c 0x%x p_mask 0x%x\n",
+		 s, cr, dlci, bit_rate, data_bits, stop_bits, parity,
+		 flow_ctrl_settings, xon_char, xoff_char, param_mask);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -956,7 +956,7 @@ static int rfcomm_send_rls(struct rfcomm_session *s, int cr, u8 dlci, u8 status)
 	struct rfcomm_rls *rls;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d status 0x%x", s, cr, status);
+	pr_debug("%p cr %d status 0x%x\n", s, cr, status);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -983,7 +983,7 @@ static int rfcomm_send_msc(struct rfcomm_session *s, int cr, u8 dlci, u8 v24_sig
 	struct rfcomm_msc *msc;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d v24 0x%x", s, cr, v24_sig);
+	pr_debug("%p cr %d v24 0x%x\n", s, cr, v24_sig);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -1009,7 +1009,7 @@ static int rfcomm_send_fcoff(struct rfcomm_session *s, int cr)
 	struct rfcomm_mcc *mcc;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d", s, cr);
+	pr_debug("%p cr %d\n", s, cr);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -1031,7 +1031,7 @@ static int rfcomm_send_fcon(struct rfcomm_session *s, int cr)
 	struct rfcomm_mcc *mcc;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p cr %d", s, cr);
+	pr_debug("%p cr %d\n", s, cr);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = __addr(s->initiator, 0);
@@ -1057,7 +1057,7 @@ static int rfcomm_send_test(struct rfcomm_session *s, int cr, u8 *pattern, int l
 	if (len > 125)
 		return -EINVAL;
 
-	BT_DBG("%p cr %d", s, cr);
+	pr_debug("%p cr %d\n", s, cr);
 
 	hdr[0] = __addr(s->initiator, 0);
 	hdr[1] = __ctrl(RFCOMM_UIH, 0);
@@ -1084,7 +1084,7 @@ static int rfcomm_send_credits(struct rfcomm_session *s, u8 addr, u8 credits)
 	struct rfcomm_hdr *hdr;
 	u8 buf[16], *ptr = buf;
 
-	BT_DBG("%p addr %d credits %d", s, addr, credits);
+	pr_debug("%p addr %d credits %d\n", s, addr, credits);
 
 	hdr = (void *) ptr; ptr += sizeof(*hdr);
 	hdr->addr = addr;
@@ -1121,7 +1121,7 @@ static void rfcomm_make_uih(struct sk_buff *skb, u8 addr)
 /* ---- RFCOMM frame reception ---- */
 static int rfcomm_recv_ua(struct rfcomm_session *s, u8 dlci)
 {
-	BT_DBG("session %p state %ld dlci %d", s, s->state, dlci);
+	pr_debug("session %p state %ld dlci %d\n", s, s->state, dlci);
 
 	if (dlci) {
 		/* Data channel */
@@ -1186,7 +1186,7 @@ static int rfcomm_recv_dm(struct rfcomm_session *s, u8 dlci)
 {
 	int err = 0;
 
-	BT_DBG("session %p state %ld dlci %d", s, s->state, dlci);
+	pr_debug("session %p state %ld dlci %d\n", s, s->state, dlci);
 
 	if (dlci) {
 		/* Data DLC */
@@ -1216,7 +1216,7 @@ static int rfcomm_recv_disc(struct rfcomm_session *s, u8 dlci)
 {
 	int err = 0;
 
-	BT_DBG("session %p state %ld dlci %d", s, s->state, dlci);
+	pr_debug("session %p state %ld dlci %d\n", s, s->state, dlci);
 
 	if (dlci) {
 		struct rfcomm_dlc *d = rfcomm_dlc_get(s, dlci);
@@ -1253,7 +1253,7 @@ void rfcomm_dlc_accept(struct rfcomm_dlc *d)
 	struct sock *sk = d->session->sock->sk;
 	struct l2cap_conn *conn = l2cap_pi(sk)->chan->conn;
 
-	BT_DBG("dlc %p", d);
+	pr_debug("dlc %p\n", d);
 
 	rfcomm_send_ua(d->session, d->dlci);
 
@@ -1294,7 +1294,7 @@ static int rfcomm_recv_sabm(struct rfcomm_session *s, u8 dlci)
 	struct rfcomm_dlc *d;
 	u8 channel;
 
-	BT_DBG("session %p state %ld dlci %d", s, s->state, dlci);
+	pr_debug("session %p state %ld dlci %d\n", s, s->state, dlci);
 
 	if (!dlci) {
 		rfcomm_send_ua(s, 0);
@@ -1335,8 +1335,8 @@ static int rfcomm_apply_pn(struct rfcomm_dlc *d, int cr, struct rfcomm_pn *pn)
 {
 	struct rfcomm_session *s = d->session;
 
-	BT_DBG("dlc %p state %ld dlci %d mtu %d fc 0x%x credits %d",
-			d, d->state, d->dlci, pn->mtu, pn->flow_ctrl, pn->credits);
+	pr_debug("dlc %p state %ld dlci %d mtu %d fc 0x%x credits %d\n",
+		 d, d->state, d->dlci, pn->mtu, pn->flow_ctrl, pn->credits);
 
 	if ((pn->flow_ctrl == 0xf0 && s->cfc != RFCOMM_CFC_DISABLED) ||
 						pn->flow_ctrl == 0xe0) {
@@ -1366,7 +1366,7 @@ static int rfcomm_recv_pn(struct rfcomm_session *s, int cr, struct sk_buff *skb)
 	struct rfcomm_dlc *d;
 	u8 dlci = pn->dlci;
 
-	BT_DBG("session %p state %ld dlci %d", s, s->state, dlci);
+	pr_debug("session %p state %ld dlci %d\n", s, s->state, dlci);
 
 	if (!dlci)
 		return 0;
@@ -1426,9 +1426,10 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	u8 xoff_char = 0;
 	u16 rpn_mask = RFCOMM_RPN_PM_ALL;
 
-	BT_DBG("dlci %d cr %d len 0x%x bitr 0x%x line 0x%x flow 0x%x xonc 0x%x xoffc 0x%x pm 0x%x",
-		dlci, cr, len, rpn->bit_rate, rpn->line_settings, rpn->flow_ctrl,
-		rpn->xon_char, rpn->xoff_char, rpn->param_mask);
+	pr_debug("dlci %d cr %d len 0x%x bitr 0x%x line 0x%x flow 0x%x xonc 0x%x xoffc 0x%x pm 0x%x\n",
+		 dlci, cr, len, rpn->bit_rate, rpn->line_settings,
+		 rpn->flow_ctrl, rpn->xon_char, rpn->xoff_char,
+		 rpn->param_mask);
 
 	if (!cr)
 		return 0;
@@ -1451,7 +1452,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_BITRATE)) {
 		bit_rate = rpn->bit_rate;
 		if (bit_rate > RFCOMM_RPN_BR_230400) {
-			BT_DBG("RPN bit rate mismatch 0x%x", bit_rate);
+			pr_debug("RPN bit rate mismatch 0x%x\n", bit_rate);
 			bit_rate = RFCOMM_RPN_BR_9600;
 			rpn_mask ^= RFCOMM_RPN_PM_BITRATE;
 		}
@@ -1460,7 +1461,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_DATA)) {
 		data_bits = __get_rpn_data_bits(rpn->line_settings);
 		if (data_bits != RFCOMM_RPN_DATA_8) {
-			BT_DBG("RPN data bits mismatch 0x%x", data_bits);
+			pr_debug("RPN data bits mismatch 0x%x\n", data_bits);
 			data_bits = RFCOMM_RPN_DATA_8;
 			rpn_mask ^= RFCOMM_RPN_PM_DATA;
 		}
@@ -1469,7 +1470,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_STOP)) {
 		stop_bits = __get_rpn_stop_bits(rpn->line_settings);
 		if (stop_bits != RFCOMM_RPN_STOP_1) {
-			BT_DBG("RPN stop bits mismatch 0x%x", stop_bits);
+			pr_debug("RPN stop bits mismatch 0x%x\n", stop_bits);
 			stop_bits = RFCOMM_RPN_STOP_1;
 			rpn_mask ^= RFCOMM_RPN_PM_STOP;
 		}
@@ -1478,7 +1479,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_PARITY)) {
 		parity = __get_rpn_parity(rpn->line_settings);
 		if (parity != RFCOMM_RPN_PARITY_NONE) {
-			BT_DBG("RPN parity mismatch 0x%x", parity);
+			pr_debug("RPN parity mismatch 0x%x\n", parity);
 			parity = RFCOMM_RPN_PARITY_NONE;
 			rpn_mask ^= RFCOMM_RPN_PM_PARITY;
 		}
@@ -1487,7 +1488,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_FLOW)) {
 		flow_ctrl = rpn->flow_ctrl;
 		if (flow_ctrl != RFCOMM_RPN_FLOW_NONE) {
-			BT_DBG("RPN flow ctrl mismatch 0x%x", flow_ctrl);
+			pr_debug("RPN flow ctrl mismatch 0x%x\n", flow_ctrl);
 			flow_ctrl = RFCOMM_RPN_FLOW_NONE;
 			rpn_mask ^= RFCOMM_RPN_PM_FLOW;
 		}
@@ -1496,7 +1497,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_XON)) {
 		xon_char = rpn->xon_char;
 		if (xon_char != RFCOMM_RPN_XON_CHAR) {
-			BT_DBG("RPN XON char mismatch 0x%x", xon_char);
+			pr_debug("RPN XON char mismatch 0x%x\n", xon_char);
 			xon_char = RFCOMM_RPN_XON_CHAR;
 			rpn_mask ^= RFCOMM_RPN_PM_XON;
 		}
@@ -1505,7 +1506,7 @@ static int rfcomm_recv_rpn(struct rfcomm_session *s, int cr, int len, struct sk_
 	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_XOFF)) {
 		xoff_char = rpn->xoff_char;
 		if (xoff_char != RFCOMM_RPN_XOFF_CHAR) {
-			BT_DBG("RPN XOFF char mismatch 0x%x", xoff_char);
+			pr_debug("RPN XOFF char mismatch 0x%x\n", xoff_char);
 			xoff_char = RFCOMM_RPN_XOFF_CHAR;
 			rpn_mask ^= RFCOMM_RPN_PM_XOFF;
 		}
@@ -1523,7 +1524,7 @@ static int rfcomm_recv_rls(struct rfcomm_session *s, int cr, struct sk_buff *skb
 	struct rfcomm_rls *rls = (void *) skb->data;
 	u8 dlci = __get_dlci(rls->dlci);
 
-	BT_DBG("dlci %d cr %d status 0x%x", dlci, cr, rls->status);
+	pr_debug("dlci %d cr %d status 0x%x\n", dlci, cr, rls->status);
 
 	if (!cr)
 		return 0;
@@ -1543,7 +1544,7 @@ static int rfcomm_recv_msc(struct rfcomm_session *s, int cr, struct sk_buff *skb
 	struct rfcomm_dlc *d;
 	u8 dlci = __get_dlci(msc->dlci);
 
-	BT_DBG("dlci %d cr %d v24 0x%x", dlci, cr, msc->v24_sig);
+	pr_debug("dlci %d cr %d v24 0x%x\n", dlci, cr, msc->v24_sig);
 
 	d = rfcomm_dlc_get(s, dlci);
 	if (!d)
@@ -1582,7 +1583,7 @@ static int rfcomm_recv_mcc(struct rfcomm_session *s, struct sk_buff *skb)
 	type = __get_mcc_type(mcc->type);
 	len  = __get_mcc_len(mcc->len);
 
-	BT_DBG("%p type 0x%x cr %d", s, type, cr);
+	pr_debug("%p type 0x%x cr %d\n", s, type, cr);
 
 	skb_pull(skb, 2);
 
@@ -1637,7 +1638,8 @@ static int rfcomm_recv_data(struct rfcomm_session *s, u8 dlci, int pf, struct sk
 {
 	struct rfcomm_dlc *d;
 
-	BT_DBG("session %p state %ld dlci %d pf %d", s, s->state, dlci, pf);
+	pr_debug("session %p state %ld dlci %d pf %d\n",
+		 s, s->state, dlci, pf);
 
 	d = rfcomm_dlc_get(s, dlci);
 	if (!d) {
@@ -1731,7 +1733,7 @@ static void rfcomm_process_connect(struct rfcomm_session *s)
 	struct rfcomm_dlc *d;
 	struct list_head *p, *n;
 
-	BT_DBG("session %p state %ld", s, s->state);
+	pr_debug("session %p state %ld\n", s, s->state);
 
 	list_for_each_safe(p, n, &s->dlcs) {
 		d = list_entry(p, struct rfcomm_dlc, list);
@@ -1755,8 +1757,8 @@ static inline int rfcomm_process_tx(struct rfcomm_dlc *d)
 	struct sk_buff *skb;
 	int err;
 
-	BT_DBG("dlc %p state %ld cfc %d rx_credits %d tx_credits %d",
-			d, d->state, d->cfc, d->rx_credits, d->tx_credits);
+	pr_debug("dlc %p state %ld cfc %d rx_credits %d tx_credits %d\n",
+		 d, d->state, d->cfc, d->rx_credits, d->tx_credits);
 
 	/* Send pending MSC */
 	if (test_and_clear_bit(RFCOMM_MSC_PENDING, &d->flags))
@@ -1803,7 +1805,7 @@ static inline void rfcomm_process_dlcs(struct rfcomm_session *s)
 	struct rfcomm_dlc *d;
 	struct list_head *p, *n;
 
-	BT_DBG("session %p state %ld", s, s->state);
+	pr_debug("session %p state %ld\n", s, s->state);
 
 	list_for_each_safe(p, n, &s->dlcs) {
 		d = list_entry(p, struct rfcomm_dlc, list);
@@ -1864,7 +1866,8 @@ static inline void rfcomm_process_rx(struct rfcomm_session *s)
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
 
-	BT_DBG("session %p state %ld qlen %d", s, s->state, skb_queue_len(&sk->sk_receive_queue));
+	pr_debug("session %p state %ld qlen %d\n",
+		 s, s->state, skb_queue_len(&sk->sk_receive_queue));
 
 	/* Get data directly from socket receive queue without copying it. */
 	while ((skb = skb_dequeue(&sk->sk_receive_queue))) {
@@ -1893,7 +1896,7 @@ static inline void rfcomm_accept_connection(struct rfcomm_session *s)
 	if (list_empty(&bt_sk(sock->sk)->accept_q))
 		return;
 
-	BT_DBG("session %p", s);
+	pr_debug("session %p\n", s);
 
 	err = kernel_accept(sock, &nsock, O_NONBLOCK);
 	if (err < 0)
@@ -1921,7 +1924,7 @@ static inline void rfcomm_check_connection(struct rfcomm_session *s)
 {
 	struct sock *sk = s->sock->sk;
 
-	BT_DBG("%p state %ld", s, s->state);
+	pr_debug("%p state %ld\n", s, s->state);
 
 	switch (sk->sk_state) {
 	case BT_CONNECTED:
@@ -2039,7 +2042,7 @@ static void rfcomm_kill_listener(void)
 	struct rfcomm_session *s;
 	struct list_head *p, *n;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	list_for_each_safe(p, n, &session_list) {
 		s = list_entry(p, struct rfcomm_session, list);
@@ -2049,7 +2052,7 @@ static void rfcomm_kill_listener(void)
 
 static int rfcomm_run(void *unused)
 {
-	BT_DBG("");
+	pr_debug("\n");
 
 	set_user_nice(current, -10);
 
@@ -2079,7 +2082,8 @@ static void rfcomm_security_cfm(struct hci_conn *conn, u8 status, u8 encrypt)
 	struct rfcomm_dlc *d;
 	struct list_head *p, *n;
 
-	BT_DBG("conn %p status 0x%02x encrypt 0x%02x", conn, status, encrypt);
+	pr_debug("conn %p status 0x%02x encrypt 0x%02x\n",
+		 conn, status, encrypt);
 
 	s = rfcomm_session_get(&conn->hdev->bdaddr, &conn->dst);
 	if (!s)
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index ed9f596..0706bda4 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -88,7 +88,7 @@ static void rfcomm_sk_state_change(struct rfcomm_dlc *d, int err)
 	if (!sk)
 		return;
 
-	BT_DBG("dlc %p state %ld err %d", d, d->state, err);
+	pr_debug("dlc %p state %ld err %d\n", d, d->state, err);
 
 	local_irq_save(flags);
 	bh_lock_sock(sk);
@@ -172,7 +172,7 @@ static void rfcomm_sock_destruct(struct sock *sk)
 {
 	struct rfcomm_dlc *d = rfcomm_pi(sk)->dlc;
 
-	BT_DBG("sk %p dlc %p", sk, d);
+	pr_debug("sk %p dlc %p\n", sk, d);
 
 	skb_queue_purge(&sk->sk_receive_queue);
 	skb_queue_purge(&sk->sk_write_queue);
@@ -192,7 +192,7 @@ static void rfcomm_sock_cleanup_listen(struct sock *parent)
 {
 	struct sock *sk;
 
-	BT_DBG("parent %p", parent);
+	pr_debug("parent %p\n", parent);
 
 	/* Close not yet accepted dlcs */
 	while ((sk = bt_accept_dequeue(parent, NULL))) {
@@ -212,7 +212,8 @@ static void rfcomm_sock_kill(struct sock *sk)
 	if (!sock_flag(sk, SOCK_ZAPPED) || sk->sk_socket)
 		return;
 
-	BT_DBG("sk %p state %d refcnt %d", sk, sk->sk_state, atomic_read(&sk->sk_refcnt));
+	pr_debug("sk %p state %d refcnt %d\n",
+		 sk, sk->sk_state, atomic_read(&sk->sk_refcnt));
 
 	/* Kill poor orphan */
 	bt_sock_unlink(&rfcomm_sk_list, sk);
@@ -224,7 +225,7 @@ static void __rfcomm_sock_close(struct sock *sk)
 {
 	struct rfcomm_dlc *d = rfcomm_pi(sk)->dlc;
 
-	BT_DBG("sk %p state %d socket %p", sk, sk->sk_state, sk->sk_socket);
+	pr_debug("sk %p state %d socket %p\n", sk, sk->sk_state, sk->sk_socket);
 
 	switch (sk->sk_state) {
 	case BT_LISTEN:
@@ -257,7 +258,7 @@ static void rfcomm_sock_init(struct sock *sk, struct sock *parent)
 {
 	struct rfcomm_pinfo *pi = rfcomm_pi(sk);
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (parent) {
 		sk->sk_type = parent->sk_type;
@@ -321,7 +322,7 @@ static struct sock *rfcomm_sock_alloc(struct net *net, struct socket *sock, int
 
 	bt_sock_link(&rfcomm_sk_list, sk);
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 	return sk;
 }
 
@@ -330,7 +331,7 @@ static int rfcomm_sock_create(struct net *net, struct socket *sock,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	pr_debug("sock %p\n", sock);
 
 	sock->state = SS_UNCONNECTED;
 
@@ -353,7 +354,7 @@ static int rfcomm_sock_bind(struct socket *sock, struct sockaddr *addr, int addr
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sk %p %s", sk, batostr(&sa->rc_bdaddr));
+	pr_debug("sk %p %s\n", sk, batostr(&sa->rc_bdaddr));
 
 	if (!addr || addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
@@ -395,7 +396,7 @@ static int rfcomm_sock_connect(struct socket *sock, struct sockaddr *addr, int a
 	struct rfcomm_dlc *d = rfcomm_pi(sk)->dlc;
 	int err = 0;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (alen < sizeof(struct sockaddr_rc) ||
 	    addr->sa_family != AF_BLUETOOTH)
@@ -435,7 +436,7 @@ static int rfcomm_sock_listen(struct socket *sock, int backlog)
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sk %p backlog %d", sk, backlog);
+	pr_debug("sk %p backlog %d\n", sk, backlog);
 
 	lock_sock(sk);
 
@@ -495,7 +496,7 @@ static int rfcomm_sock_accept(struct socket *sock, struct socket *newsock, int f
 
 	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
 
-	BT_DBG("sk %p timeo %ld", sk, timeo);
+	pr_debug("sk %p timeo %ld\n", sk, timeo);
 
 	/* Wait for an incoming connection. (wake-one). */
 	add_wait_queue_exclusive(sk_sleep(sk), &wait);
@@ -533,7 +534,7 @@ static int rfcomm_sock_accept(struct socket *sock, struct socket *newsock, int f
 
 	newsock->state = SS_CONNECTED;
 
-	BT_DBG("new socket %p", nsk);
+	pr_debug("new socket %p\n", nsk);
 
 done:
 	release_sock(sk);
@@ -545,7 +546,7 @@ static int rfcomm_sock_getname(struct socket *sock, struct sockaddr *addr, int *
 	struct sockaddr_rc *sa = (struct sockaddr_rc *) addr;
 	struct sock *sk = sock->sk;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	sa->rc_family  = AF_BLUETOOTH;
 	sa->rc_channel = rfcomm_pi(sk)->channel;
@@ -575,7 +576,7 @@ static int rfcomm_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (sk->sk_shutdown & SEND_SHUTDOWN)
 		return -EPIPE;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	lock_sock(sk);
 
@@ -650,7 +651,7 @@ static int rfcomm_sock_setsockopt_old(struct socket *sock, int optname, char __u
 	int err = 0;
 	u32 opt;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	lock_sock(sk);
 
@@ -688,7 +689,7 @@ static int rfcomm_sock_setsockopt(struct socket *sock, int level, int optname, c
 	size_t len;
 	u32 opt;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (level == SOL_RFCOMM)
 		return rfcomm_sock_setsockopt_old(sock, optname, optval, optlen);
@@ -752,7 +753,7 @@ static int rfcomm_sock_getsockopt_old(struct socket *sock, int optname, char __u
 	int len, err = 0;
 	u32 opt;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (get_user(len, optlen))
 		return -EFAULT;
@@ -816,7 +817,7 @@ static int rfcomm_sock_getsockopt(struct socket *sock, int level, int optname, c
 	struct bt_security sec;
 	int len, err = 0;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (level == SOL_RFCOMM)
 		return rfcomm_sock_getsockopt_old(sock, optname, optval, optlen);
@@ -869,7 +870,7 @@ static int rfcomm_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned lon
 	struct sock *sk __maybe_unused = sock->sk;
 	int err;
 
-	BT_DBG("sk %p cmd %x arg %lx", sk, cmd, arg);
+	pr_debug("sk %p cmd %x arg %lx\n", sk, cmd, arg);
 
 	err = bt_sock_ioctl(sock, cmd, arg);
 
@@ -891,7 +892,7 @@ static int rfcomm_sock_shutdown(struct socket *sock, int how)
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -913,7 +914,7 @@ static int rfcomm_sock_release(struct socket *sock)
 	struct sock *sk = sock->sk;
 	int err;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -935,7 +936,7 @@ int rfcomm_connect_ind(struct rfcomm_session *s, u8 channel, struct rfcomm_dlc *
 	bdaddr_t src, dst;
 	int result = 0;
 
-	BT_DBG("session %p channel %d", s, channel);
+	pr_debug("session %p channel %d\n", s, channel);
 
 	rfcomm_session_getaddr(s, &src, &dst);
 
@@ -948,7 +949,7 @@ int rfcomm_connect_ind(struct rfcomm_session *s, u8 channel, struct rfcomm_dlc *
 
 	/* Check for backlog size */
 	if (sk_acceptq_is_full(parent)) {
-		BT_DBG("backlog full %d", parent->sk_ack_backlog);
+		pr_debug("backlog full %d\n", parent->sk_ack_backlog);
 		goto done;
 	}
 
diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index 6c3f3b8..f845e7e 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -89,7 +89,7 @@ static void rfcomm_dev_destruct(struct rfcomm_dev *dev)
 {
 	struct rfcomm_dlc *dlc = dev->dlc;
 
-	BT_DBG("dev %p dlc %p", dev, dlc);
+	pr_debug("dev %p dlc %p\n", dev, dlc);
 
 	/* Refcount should only hit zero when called from rfcomm_dev_del()
 	   which will have taken us off the list. Everything else are
@@ -199,7 +199,7 @@ static int rfcomm_dev_add(struct rfcomm_dev_req *req, struct rfcomm_dlc *dlc)
 	struct list_head *head = &rfcomm_dev_list, *p;
 	int err = 0;
 
-	BT_DBG("id %d channel %d", req->dev_id, req->channel);
+	pr_debug("id %d channel %d\n", req->dev_id, req->channel);
 
 	dev = kzalloc(sizeof(struct rfcomm_dev), GFP_KERNEL);
 	if (!dev)
@@ -320,7 +320,7 @@ free:
 
 static void rfcomm_dev_del(struct rfcomm_dev *dev)
 {
-	BT_DBG("dev %p", dev);
+	pr_debug("dev %p\n", dev);
 
 	BUG_ON(test_and_set_bit(RFCOMM_TTY_RELEASED, &dev->flags));
 
@@ -384,7 +384,7 @@ static int rfcomm_create_dev(struct sock *sk, void __user *arg)
 	if (copy_from_user(&req, arg, sizeof(req)))
 		return -EFAULT;
 
-	BT_DBG("sk %p dev_id %d flags 0x%x", sk, req.dev_id, req.flags);
+	pr_debug("sk %p dev_id %d flags 0x%x\n", sk, req.dev_id, req.flags);
 
 	if (req.flags != NOCAP_FLAGS && !capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -425,7 +425,7 @@ static int rfcomm_release_dev(void __user *arg)
 	if (copy_from_user(&req, arg, sizeof(req)))
 		return -EFAULT;
 
-	BT_DBG("dev_id %d flags 0x%x", req.dev_id, req.flags);
+	pr_debug("dev_id %d flags 0x%x\n", req.dev_id, req.flags);
 
 	dev = rfcomm_dev_get(req.dev_id);
 	if (!dev)
@@ -457,7 +457,7 @@ static int rfcomm_get_dev_list(void __user *arg)
 	int n = 0, size, err;
 	u16 dev_num;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	if (get_user(dev_num, (u16 __user *) arg))
 		return -EFAULT;
@@ -505,7 +505,7 @@ static int rfcomm_get_dev_info(void __user *arg)
 	struct rfcomm_dev_info di;
 	int err = 0;
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	if (copy_from_user(&di, arg, sizeof(di)))
 		return -EFAULT;
@@ -529,7 +529,7 @@ static int rfcomm_get_dev_info(void __user *arg)
 
 int rfcomm_dev_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 {
-	BT_DBG("cmd %d arg %p", cmd, arg);
+	pr_debug("cmd %d arg %p\n", cmd, arg);
 
 	switch (cmd) {
 	case RFCOMMCREATEDEV:
@@ -565,7 +565,7 @@ static void rfcomm_dev_data_ready(struct rfcomm_dlc *dlc, struct sk_buff *skb)
 		return;
 	}
 
-	BT_DBG("dlc %p tty %p len %d", dlc, tty, skb->len);
+	pr_debug("dlc %p tty %p len %d\n", dlc, tty, skb->len);
 
 	tty_insert_flip_string(tty, skb->data, skb->len);
 	tty_flip_buffer_push(tty);
@@ -579,7 +579,7 @@ static void rfcomm_dev_state_change(struct rfcomm_dlc *dlc, int err)
 	if (!dev)
 		return;
 
-	BT_DBG("dlc %p dev %p err %d", dlc, dev, err);
+	pr_debug("dlc %p dev %p err %d\n", dlc, dev, err);
 
 	dev->err = err;
 	wake_up_interruptible(&dev->wait);
@@ -615,7 +615,7 @@ static void rfcomm_dev_modem_status(struct rfcomm_dlc *dlc, u8 v24_sig)
 	if (!dev)
 		return;
 
-	BT_DBG("dlc %p dev %p v24_sig 0x%02x", dlc, dev, v24_sig);
+	pr_debug("dlc %p dev %p v24_sig 0x%02x\n", dlc, dev, v24_sig);
 
 	if ((dev->modem_status & TIOCM_CD) && !(v24_sig & RFCOMM_V24_DV)) {
 		if (dev->tty && !C_CLOCAL(dev->tty))
@@ -638,7 +638,7 @@ static void rfcomm_tty_wakeup(struct work_struct *work)
 	if (!tty)
 		return;
 
-	BT_DBG("dev %p tty %p", dev, tty);
+	pr_debug("dev %p tty %p\n", dev, tty);
 	tty_wakeup(tty);
 }
 
@@ -651,7 +651,7 @@ static void rfcomm_tty_copy_pending(struct rfcomm_dev *dev)
 	if (!tty)
 		return;
 
-	BT_DBG("dev %p tty %p", dev, tty);
+	pr_debug("dev %p tty %p\n", dev, tty);
 
 	rfcomm_dlc_lock(dev->dlc);
 
@@ -675,7 +675,7 @@ static int rfcomm_tty_open(struct tty_struct *tty, struct file *filp)
 
 	id = tty->index;
 
-	BT_DBG("tty %p id %d", tty, id);
+	pr_debug("tty %p id %d\n", tty, id);
 
 	/* We don't leak this refcount. For reasons which are not entirely
 	   clear, the TTY layer will call our ->close() method even if the
@@ -685,8 +685,9 @@ static int rfcomm_tty_open(struct tty_struct *tty, struct file *filp)
 	if (!dev)
 		return -ENODEV;
 
-	BT_DBG("dev %p dst %s channel %d opened %d", dev, batostr(&dev->dst),
-				dev->channel, atomic_read(&dev->opened));
+	pr_debug("dev %p dst %s channel %d opened %d\n",
+		 dev, batostr(&dev->dst), dev->channel,
+		 atomic_read(&dev->opened));
 
 	if (atomic_inc_return(&dev->opened) > 1)
 		return 0;
@@ -747,8 +748,8 @@ static void rfcomm_tty_close(struct tty_struct *tty, struct file *filp)
 	if (!dev)
 		return;
 
-	BT_DBG("tty %p dev %p dlc %p opened %d", tty, dev, dev->dlc,
-						atomic_read(&dev->opened));
+	pr_debug("tty %p dev %p dlc %p opened %d\n",
+		 tty, dev, dev->dlc, atomic_read(&dev->opened));
 
 	if (atomic_dec_and_test(&dev->opened)) {
 		if (dev->tty_dev->parent)
@@ -784,7 +785,7 @@ static int rfcomm_tty_write(struct tty_struct *tty, const unsigned char *buf, in
 	struct sk_buff *skb;
 	int err = 0, sent = 0, size;
 
-	BT_DBG("tty %p count %d", tty, count);
+	pr_debug("tty %p count %d\n", tty, count);
 
 	while (count) {
 		size = min_t(uint, count, dlc->mtu);
@@ -816,7 +817,7 @@ static int rfcomm_tty_write_room(struct tty_struct *tty)
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 	int room;
 
-	BT_DBG("tty %p", tty);
+	pr_debug("tty %p\n", tty);
 
 	if (!dev || !dev->dlc)
 		return 0;
@@ -830,19 +831,19 @@ static int rfcomm_tty_write_room(struct tty_struct *tty)
 
 static int rfcomm_tty_ioctl(struct tty_struct *tty, unsigned int cmd, unsigned long arg)
 {
-	BT_DBG("tty %p cmd 0x%02x", tty, cmd);
+	pr_debug("tty %p cmd 0x%02x\n", tty, cmd);
 
 	switch (cmd) {
 	case TCGETS:
-		BT_DBG("TCGETS is not supported");
+		pr_debug("TCGETS is not supported\n");
 		return -ENOIOCTLCMD;
 
 	case TCSETS:
-		BT_DBG("TCSETS is not supported");
+		pr_debug("TCSETS is not supported\n");
 		return -ENOIOCTLCMD;
 
 	case TIOCMIWAIT:
-		BT_DBG("TIOCMIWAIT");
+		pr_debug("TIOCMIWAIT\n");
 		break;
 
 	case TIOCGSERIAL:
@@ -884,52 +885,52 @@ static void rfcomm_tty_set_termios(struct tty_struct *tty, struct ktermios *old)
 
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p termios %p", tty, old);
+	pr_debug("tty %p termios %p\n", tty, old);
 
 	if (!dev || !dev->dlc || !dev->dlc->session)
 		return;
 
 	/* Handle turning off CRTSCTS */
 	if ((old->c_cflag & CRTSCTS) && !(new->c_cflag & CRTSCTS))
-		BT_DBG("Turning off CRTSCTS unsupported");
+		pr_debug("Turning off CRTSCTS unsupported\n");
 
 	/* Parity on/off and when on, odd/even */
 	if (((old->c_cflag & PARENB) != (new->c_cflag & PARENB)) ||
 			((old->c_cflag & PARODD) != (new->c_cflag & PARODD))) {
 		changes |= RFCOMM_RPN_PM_PARITY;
-		BT_DBG("Parity change detected.");
+		pr_debug("Parity change detected\n");
 	}
 
 	/* Mark and space parity are not supported! */
 	if (new->c_cflag & PARENB) {
 		if (new->c_cflag & PARODD) {
-			BT_DBG("Parity is ODD");
+			pr_debug("Parity is ODD\n");
 			parity = RFCOMM_RPN_PARITY_ODD;
 		} else {
-			BT_DBG("Parity is EVEN");
+			pr_debug("Parity is EVEN\n");
 			parity = RFCOMM_RPN_PARITY_EVEN;
 		}
 	} else {
-		BT_DBG("Parity is OFF");
+		pr_debug("Parity is OFF\n");
 		parity = RFCOMM_RPN_PARITY_NONE;
 	}
 
 	/* Setting the x_on / x_off characters */
 	if (old->c_cc[VSTOP] != new->c_cc[VSTOP]) {
-		BT_DBG("XOFF custom");
+		pr_debug("XOFF custom\n");
 		x_on = new->c_cc[VSTOP];
 		changes |= RFCOMM_RPN_PM_XON;
 	} else {
-		BT_DBG("XOFF default");
+		pr_debug("XOFF default\n");
 		x_on = RFCOMM_RPN_XON_CHAR;
 	}
 
 	if (old->c_cc[VSTART] != new->c_cc[VSTART]) {
-		BT_DBG("XON custom");
+		pr_debug("XON custom\n");
 		x_off = new->c_cc[VSTART];
 		changes |= RFCOMM_RPN_PM_XOFF;
 	} else {
-		BT_DBG("XON default");
+		pr_debug("XON default\n");
 		x_off = RFCOMM_RPN_XOFF_CHAR;
 	}
 
@@ -1016,7 +1017,7 @@ static void rfcomm_tty_throttle(struct tty_struct *tty)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p dev %p", tty, dev);
+	pr_debug("tty %p dev %p\n", tty, dev);
 
 	rfcomm_dlc_throttle(dev->dlc);
 }
@@ -1025,7 +1026,7 @@ static void rfcomm_tty_unthrottle(struct tty_struct *tty)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p dev %p", tty, dev);
+	pr_debug("tty %p dev %p\n", tty, dev);
 
 	rfcomm_dlc_unthrottle(dev->dlc);
 }
@@ -1034,7 +1035,7 @@ static int rfcomm_tty_chars_in_buffer(struct tty_struct *tty)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p dev %p", tty, dev);
+	pr_debug("tty %p dev %p\n", tty, dev);
 
 	if (!dev || !dev->dlc)
 		return 0;
@@ -1049,7 +1050,7 @@ static void rfcomm_tty_flush_buffer(struct tty_struct *tty)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p dev %p", tty, dev);
+	pr_debug("tty %p dev %p\n", tty, dev);
 
 	if (!dev || !dev->dlc)
 		return;
@@ -1060,19 +1061,19 @@ static void rfcomm_tty_flush_buffer(struct tty_struct *tty)
 
 static void rfcomm_tty_send_xchar(struct tty_struct *tty, char ch)
 {
-	BT_DBG("tty %p ch %c", tty, ch);
+	pr_debug("tty %p ch %c\n", tty, ch);
 }
 
 static void rfcomm_tty_wait_until_sent(struct tty_struct *tty, int timeout)
 {
-	BT_DBG("tty %p timeout %d", tty, timeout);
+	pr_debug("tty %p timeout %d\n", tty, timeout);
 }
 
 static void rfcomm_tty_hangup(struct tty_struct *tty)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p dev %p", tty, dev);
+	pr_debug("tty %p dev %p\n", tty, dev);
 
 	if (!dev)
 		return;
@@ -1091,7 +1092,7 @@ static int rfcomm_tty_tiocmget(struct tty_struct *tty)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
 
-	BT_DBG("tty %p dev %p", tty, dev);
+	pr_debug("tty %p dev %p\n", tty, dev);
 
 	return dev->modem_status;
 }
@@ -1102,7 +1103,8 @@ static int rfcomm_tty_tiocmset(struct tty_struct *tty, unsigned int set, unsigne
 	struct rfcomm_dlc *dlc = dev->dlc;
 	u8 v24_sig;
 
-	BT_DBG("tty %p dev %p set 0x%02x clear 0x%02x", tty, dev, set, clear);
+	pr_debug("tty %p dev %p set 0x%02x clear 0x%02x\n",
+		 tty, dev, set, clear);
 
 	rfcomm_dlc_get_modem_status(dlc, &v24_sig);
 
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 1b70109..aeb91e0 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -72,7 +72,7 @@ static void sco_sock_timeout(unsigned long arg)
 {
 	struct sock *sk = (struct sock *) arg;
 
-	BT_DBG("sock %p state %d", sk, sk->sk_state);
+	pr_debug("sock %p state %d\n", sk, sk->sk_state);
 
 	bh_lock_sock(sk);
 	sk->sk_err = ETIMEDOUT;
@@ -85,13 +85,13 @@ static void sco_sock_timeout(unsigned long arg)
 
 static void sco_sock_set_timer(struct sock *sk, long timeout)
 {
-	BT_DBG("sock %p state %d timeout %ld", sk, sk->sk_state, timeout);
+	pr_debug("sock %p state %d timeout %ld\n", sk, sk->sk_state, timeout);
 	sk_reset_timer(sk, &sk->sk_timer, jiffies + timeout);
 }
 
 static void sco_sock_clear_timer(struct sock *sk)
 {
-	BT_DBG("sock %p state %d", sk, sk->sk_state);
+	pr_debug("sock %p state %d\n", sk, sk->sk_state);
 	sk_stop_timer(sk, &sk->sk_timer);
 }
 
@@ -121,7 +121,7 @@ static struct sco_conn *sco_conn_add(struct hci_conn *hcon, __u8 status)
 	else
 		conn->mtu = 60;
 
-	BT_DBG("hcon %p conn %p", hcon, conn);
+	pr_debug("hcon %p conn %p\n", hcon, conn);
 
 	return conn;
 }
@@ -143,7 +143,7 @@ static int sco_conn_del(struct hci_conn *hcon, int err)
 	if (!conn)
 		return 0;
 
-	BT_DBG("hcon %p conn %p, err %d", hcon, conn, err);
+	pr_debug("hcon %p conn %p, err %d\n", hcon, conn, err);
 
 	/* Kill socket */
 	sk = sco_chan_get(conn);
@@ -183,7 +183,7 @@ static int sco_connect(struct sock *sk)
 	struct hci_dev  *hdev;
 	int err, type;
 
-	BT_DBG("%s -> %s", batostr(src), batostr(dst));
+	pr_debug("%s -> %s\n", batostr(src), batostr(dst));
 
 	hdev = hci_get_route(dst, src);
 	if (!hdev)
@@ -240,7 +240,7 @@ static inline int sco_send_frame(struct sock *sk, struct msghdr *msg, int len)
 	if (len > conn->mtu)
 		return -EINVAL;
 
-	BT_DBG("sk %p len %d", sk, len);
+	pr_debug("sk %p len %d\n", sk, len);
 
 	count = min_t(unsigned int, conn->mtu, len);
 	skb = bt_skb_send_alloc(sk, count,
@@ -265,7 +265,7 @@ static inline void sco_recv_frame(struct sco_conn *conn, struct sk_buff *skb)
 	if (!sk)
 		goto drop;
 
-	BT_DBG("sk %p len %d", sk, skb->len);
+	pr_debug("sk %p len %d\n", sk, skb->len);
 
 	if (sk->sk_state != BT_CONNECTED)
 		goto drop;
@@ -321,7 +321,7 @@ static struct sock *sco_get_sock_listen(bdaddr_t *src)
 
 static void sco_sock_destruct(struct sock *sk)
 {
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	skb_queue_purge(&sk->sk_receive_queue);
 	skb_queue_purge(&sk->sk_write_queue);
@@ -331,7 +331,7 @@ static void sco_sock_cleanup_listen(struct sock *parent)
 {
 	struct sock *sk;
 
-	BT_DBG("parent %p", parent);
+	pr_debug("parent %p\n", parent);
 
 	/* Close not yet accepted channels */
 	while ((sk = bt_accept_dequeue(parent, NULL))) {
@@ -351,7 +351,7 @@ static void sco_sock_kill(struct sock *sk)
 	if (!sock_flag(sk, SOCK_ZAPPED) || sk->sk_socket)
 		return;
 
-	BT_DBG("sk %p state %d", sk, sk->sk_state);
+	pr_debug("sk %p state %d\n", sk, sk->sk_state);
 
 	/* Kill poor orphan */
 	bt_sock_unlink(&sco_sk_list, sk);
@@ -361,7 +361,7 @@ static void sco_sock_kill(struct sock *sk)
 
 static void __sco_sock_close(struct sock *sk)
 {
-	BT_DBG("sk %p state %d socket %p", sk, sk->sk_state, sk->sk_socket);
+	pr_debug("sk %p state %d socket %p\n", sk, sk->sk_state, sk->sk_socket);
 
 	switch (sk->sk_state) {
 	case BT_LISTEN:
@@ -402,7 +402,7 @@ static void sco_sock_close(struct sock *sk)
 
 static void sco_sock_init(struct sock *sk, struct sock *parent)
 {
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (parent) {
 		sk->sk_type = parent->sk_type;
@@ -446,7 +446,7 @@ static int sco_sock_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	BT_DBG("sock %p", sock);
+	pr_debug("sock %p\n", sock);
 
 	sock->state = SS_UNCONNECTED;
 
@@ -470,7 +470,7 @@ static int sco_sock_bind(struct socket *sock, struct sockaddr *addr, int addr_le
 	bdaddr_t *src = &sa->sco_bdaddr;
 	int err = 0;
 
-	BT_DBG("sk %p %s", sk, batostr(&sa->sco_bdaddr));
+	pr_debug("sk %p %s\n", sk, batostr(&sa->sco_bdaddr));
 
 	if (!addr || addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
@@ -506,7 +506,7 @@ static int sco_sock_connect(struct socket *sock, struct sockaddr *addr, int alen
 	int err = 0;
 
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (alen < sizeof(struct sockaddr_sco) ||
 	    addr->sa_family != AF_BLUETOOTH)
@@ -540,7 +540,7 @@ static int sco_sock_listen(struct socket *sock, int backlog)
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sk %p backlog %d", sk, backlog);
+	pr_debug("sk %p backlog %d\n", sk, backlog);
 
 	lock_sock(sk);
 
@@ -569,7 +569,7 @@ static int sco_sock_accept(struct socket *sock, struct socket *newsock, int flag
 
 	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
 
-	BT_DBG("sk %p timeo %ld", sk, timeo);
+	pr_debug("sk %p timeo %ld\n", sk, timeo);
 
 	/* Wait for an incoming connection. (wake-one). */
 	add_wait_queue_exclusive(sk_sleep(sk), &wait);
@@ -607,7 +607,7 @@ static int sco_sock_accept(struct socket *sock, struct socket *newsock, int flag
 
 	newsock->state = SS_CONNECTED;
 
-	BT_DBG("new socket %p", ch);
+	pr_debug("new socket %p\n", ch);
 
 done:
 	release_sock(sk);
@@ -619,7 +619,7 @@ static int sco_sock_getname(struct socket *sock, struct sockaddr *addr, int *len
 	struct sockaddr_sco *sa = (struct sockaddr_sco *) addr;
 	struct sock *sk = sock->sk;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	addr->sa_family = AF_BLUETOOTH;
 	*len = sizeof(struct sockaddr_sco);
@@ -638,7 +638,7 @@ static int sco_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	int err;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	err = sock_error(sk);
 	if (err)
@@ -663,7 +663,7 @@ static int sco_sock_setsockopt(struct socket *sock, int level, int optname, char
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	lock_sock(sk);
 
@@ -684,7 +684,7 @@ static int sco_sock_getsockopt_old(struct socket *sock, int optname, char __user
 	struct sco_conninfo cinfo;
 	int len, err = 0;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (get_user(len, optlen))
 		return -EFAULT;
@@ -700,7 +700,7 @@ static int sco_sock_getsockopt_old(struct socket *sock, int optname, char __user
 
 		opts.mtu = sco_pi(sk)->conn->mtu;
 
-		BT_DBG("mtu %d", opts.mtu);
+		pr_debug("mtu %d\n", opts.mtu);
 
 		len = min_t(unsigned int, len, sizeof(opts));
 		if (copy_to_user(optval, (char *)&opts, len))
@@ -738,7 +738,7 @@ static int sco_sock_getsockopt(struct socket *sock, int level, int optname, char
 	struct sock *sk = sock->sk;
 	int len, err = 0;
 
-	BT_DBG("sk %p", sk);
+	pr_debug("sk %p\n", sk);
 
 	if (level == SOL_SCO)
 		return sco_sock_getsockopt_old(sock, optname, optval, optlen);
@@ -763,7 +763,7 @@ static int sco_sock_shutdown(struct socket *sock, int how)
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -787,7 +787,7 @@ static int sco_sock_release(struct socket *sock)
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sock %p, sk %p", sock, sk);
+	pr_debug("sock %p, sk %p\n", sock, sk);
 
 	if (!sk)
 		return 0;
@@ -807,7 +807,7 @@ static int sco_sock_release(struct socket *sock)
 
 static void __sco_chan_add(struct sco_conn *conn, struct sock *sk, struct sock *parent)
 {
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	sco_pi(sk)->conn = conn;
 	conn->sk = sk;
@@ -824,7 +824,7 @@ static void sco_chan_del(struct sock *sk, int err)
 
 	conn = sco_pi(sk)->conn;
 
-	BT_DBG("sk %p, conn %p, err %d", sk, conn, err);
+	pr_debug("sk %p, conn %p, err %d\n", sk, conn, err);
 
 	if (conn) {
 		sco_conn_lock(conn);
@@ -848,7 +848,7 @@ static void sco_conn_ready(struct sco_conn *conn)
 	struct sock *parent;
 	struct sock *sk = conn->sk;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	sco_conn_lock(conn);
 
@@ -899,7 +899,7 @@ int sco_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr)
 	struct hlist_node *node;
 	int lm = 0;
 
-	BT_DBG("hdev %s, bdaddr %s", hdev->name, batostr(bdaddr));
+	pr_debug("hdev %s, bdaddr %s\n", hdev->name, batostr(bdaddr));
 
 	/* Find listening sockets */
 	read_lock(&sco_sk_list.lock);
@@ -920,7 +920,8 @@ int sco_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr)
 
 int sco_connect_cfm(struct hci_conn *hcon, __u8 status)
 {
-	BT_DBG("hcon %p bdaddr %s status %d", hcon, batostr(&hcon->dst), status);
+	pr_debug("hcon %p bdaddr %s status %d\n",
+		 hcon, batostr(&hcon->dst), status);
 	if (!status) {
 		struct sco_conn *conn;
 
@@ -935,7 +936,7 @@ int sco_connect_cfm(struct hci_conn *hcon, __u8 status)
 
 int sco_disconn_cfm(struct hci_conn *hcon, __u8 reason)
 {
-	BT_DBG("hcon %p reason %d", hcon, reason);
+	pr_debug("hcon %p reason %d\n", hcon, reason);
 
 	sco_conn_del(hcon, bt_to_errno(reason));
 	return 0;
@@ -948,7 +949,7 @@ int sco_recv_scodata(struct hci_conn *hcon, struct sk_buff *skb)
 	if (!conn)
 		goto drop;
 
-	BT_DBG("conn %p len %d", conn, skb->len);
+	pr_debug("conn %p len %d\n", conn, skb->len);
 
 	if (skb->len) {
 		sco_recv_frame(conn, skb);
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index a92a606..0fec083 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -177,7 +177,7 @@ static void smp_send_cmd(struct l2cap_conn *conn, u8 code, u16 len, void *data)
 {
 	struct sk_buff *skb = smp_build_cmd(conn, code, len, data);
 
-	BT_DBG("code 0x%2.2x", code);
+	pr_debug("code 0x%2.2x\n", code);
 
 	if (!skb)
 		return;
@@ -295,7 +295,8 @@ static int tk_request(struct l2cap_conn *conn, u8 remote_oob, u8 auth,
 	memset(smp->tk, 0, sizeof(smp->tk));
 	clear_bit(SMP_FLAG_TK_VALID, &smp->smp_flags);
 
-	BT_DBG("tk_request: auth:%d lcl:%d rem:%d", auth, local_io, remote_io);
+	pr_debug("tk_request: auth:%d lcl:%d rem:%d\n",
+		 auth, local_io, remote_io);
 
 	/* If neither side wants MITM, use JUST WORKS */
 	/* If either side has unknown io_caps, use JUST WORKS */
@@ -340,7 +341,7 @@ static int tk_request(struct l2cap_conn *conn, u8 remote_oob, u8 auth,
 		passkey %= 1000000;
 		put_unaligned_le32(passkey, key);
 		swap128(key, smp->tk);
-		BT_DBG("PassKey: %d", passkey);
+		pr_debug("PassKey: %d\n", passkey);
 	}
 
 	hci_dev_lock(hcon->hdev);
@@ -365,7 +366,7 @@ static void confirm_work(struct work_struct *work)
 	int ret;
 	u8 res[16], reason;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	tfm = crypto_alloc_blkcipher("ecb(aes)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm)) {
@@ -413,7 +414,7 @@ static void random_work(struct work_struct *work)
 		goto error;
 	}
 
-	BT_DBG("conn %p %s", conn, conn->hcon->out ? "master" : "slave");
+	pr_debug("conn %p %s\n", conn, conn->hcon->out ? "master" : "slave");
 
 	if (hcon->out)
 		ret = smp_c1(tfm, smp->tk, smp->rrnd, smp->preq, smp->prsp, 0,
@@ -524,7 +525,7 @@ int smp_user_confirm_reply(struct hci_conn *hcon, u16 mgmt_op, __le32 passkey)
 	u32 value;
 	u8 key[16];
 
-	BT_DBG("");
+	pr_debug("\n");
 
 	if (!conn)
 		return -ENOTCONN;
@@ -535,7 +536,7 @@ int smp_user_confirm_reply(struct hci_conn *hcon, u16 mgmt_op, __le32 passkey)
 	case MGMT_OP_USER_PASSKEY_REPLY:
 		value = le32_to_cpu(passkey);
 		memset(key, 0, sizeof(key));
-		BT_DBG("PassKey: %d", value);
+		pr_debug("PassKey: %d\n", value);
 		put_unaligned_le32(value, key);
 		swap128(key, smp->tk);
 		/* Fall Through */
@@ -566,7 +567,7 @@ static u8 smp_cmd_pairing_req(struct l2cap_conn *conn, struct sk_buff *skb)
 	u8 auth = SMP_AUTH_NONE;
 	int ret;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	if (conn->hcon->link_mode & HCI_LM_MASTER)
 		return SMP_CMD_NOTSUPP;
@@ -615,7 +616,7 @@ static u8 smp_cmd_pairing_rsp(struct l2cap_conn *conn, struct sk_buff *skb)
 	u8 key_size, auth = SMP_AUTH_NONE;
 	int ret;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	if (!(conn->hcon->link_mode & HCI_LM_MASTER))
 		return SMP_CMD_NOTSUPP;
@@ -661,7 +662,7 @@ static u8 smp_cmd_pairing_confirm(struct l2cap_conn *conn, struct sk_buff *skb)
 	struct smp_chan *smp = conn->smp_chan;
 	struct hci_dev *hdev = conn->hcon->hdev;
 
-	BT_DBG("conn %p %s", conn, conn->hcon->out ? "master" : "slave");
+	pr_debug("conn %p %s\n", conn, conn->hcon->out ? "master" : "slave");
 
 	memcpy(smp->pcnf, skb->data, sizeof(smp->pcnf));
 	skb_pull(skb, sizeof(smp->pcnf));
@@ -686,7 +687,7 @@ static u8 smp_cmd_pairing_random(struct l2cap_conn *conn, struct sk_buff *skb)
 	struct smp_chan *smp = conn->smp_chan;
 	struct hci_dev *hdev = conn->hcon->hdev;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	swap128(skb->data, smp->rrnd);
 	skb_pull(skb, sizeof(smp->rrnd));
@@ -726,7 +727,7 @@ static u8 smp_cmd_security_req(struct l2cap_conn *conn, struct sk_buff *skb)
 	struct hci_conn *hcon = conn->hcon;
 	struct smp_chan *smp;
 
-	BT_DBG("conn %p", conn);
+	pr_debug("conn %p\n", conn);
 
 	hcon->pending_sec_level = authreq_to_seclevel(rp->auth_req);
 
@@ -757,7 +758,7 @@ int smp_conn_security(struct l2cap_conn *conn, __u8 sec_level)
 	struct smp_chan *smp = conn->smp_chan;
 	__u8 authreq;
 
-	BT_DBG("conn %p hcon %p level 0x%2.2x", conn, hcon, sec_level);
+	pr_debug("conn %p hcon %p level 0x%2.2x\n", conn, hcon, sec_level);
 
 	if (!lmp_host_le_capable(hcon->hdev))
 		return 1;
@@ -885,7 +886,7 @@ int smp_sig_channel(struct l2cap_conn *conn, struct sk_buff *skb)
 		break;
 
 	default:
-		BT_DBG("Unknown command code 0x%2.2x", code);
+		pr_debug("Unknown command code 0x%2.2x\n", code);
 
 		reason = SMP_CMD_NOTSUPP;
 		err = -EOPNOTSUPP;
@@ -906,7 +907,7 @@ int smp_distribute_keys(struct l2cap_conn *conn, __u8 force)
 	struct smp_chan *smp = conn->smp_chan;
 	__u8 *keydist;
 
-	BT_DBG("conn %p force %d", conn, force);
+	pr_debug("conn %p force %d\n", conn, force);
 
 	if (!test_bit(HCI_CONN_LE_SMP_PEND, &conn->hcon->pend))
 		return 0;
@@ -928,7 +929,7 @@ int smp_distribute_keys(struct l2cap_conn *conn, __u8 force)
 	}
 
 
-	BT_DBG("keydist 0x%x", *keydist);
+	pr_debug("keydist 0x%x\n", *keydist);
 
 	if (*keydist & SMP_DIST_ENC_KEY) {
 		struct smp_cmd_encrypt_info enc;
-- 
1.7.8.111.gad25c.dirty
