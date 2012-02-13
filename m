From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] bluetooth: Use more current logging styles
Date: Sun, 12 Feb 2012 19:15:53 -0800
Message-ID: <44b8744770a55924c68f8ad0ca274816d2d6148f.1329102581.git.joe@perches.com>
References: <cover.1329102581.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1329102581.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make functions for bt_info and bt_err.
Remove now unused function bt_printk.
Convert uses of BT_INFO and BT_ERR to bt_info and bt_err.
Add newlines to uses of bt_info and bt_err.
Align arguments and coalesce formats.

Reduces object sizes a small amount.
(defconfig with bluetooth on and all bluetooth drivers)

$ size net/bluetooth/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 380796	  20072	 100200	 501068	  7a54c	net/bluetooth/built-in.o.allyesconfig.new
 381595	  20072	 100184	 501851	  7a85b	net/bluetooth/built-in.o.allyesconfig.old
 126328	   1388	    132	 127848	  1f368	net/bluetooth/built-in.o.defconfig.new
 126883	   1388	    132	 128403	  1f593	net/bluetooth/built-in.o.defconfig.old

$ size drivers/bluetooth/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 127606	   8956	  29484	 166046	  2889e	drivers/bluetooth/built-in.o.allyesconfig.new
 129540	   8956	  29524	 168020	  29054	drivers/bluetooth/built-in.o.allyesconfig.old
  53033	   3260	    156	  56449	   dc81	drivers/bluetooth/built-in.o.defconfig.new
  54390	   3260	    156	  57806	   e1ce	drivers/bluetooth/built-in.o.defconfig.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/bluetooth/ath3k.c          |   46 +++++++-------
 drivers/bluetooth/bcm203x.c        |   24 ++++----
 drivers/bluetooth/bfusb.c          |   67 +++++++++++---------
 drivers/bluetooth/bluecard_cs.c    |   17 +++---
 drivers/bluetooth/bpa10x.c         |   18 +++---
 drivers/bluetooth/bt3c_cs.c        |   36 ++++++-----
 drivers/bluetooth/btmrvl_debugfs.c |    2 +-
 drivers/bluetooth/btmrvl_main.c    |   39 ++++++------
 drivers/bluetooth/btmrvl_sdio.c    |  122 +++++++++++++++++-------------------
 drivers/bluetooth/btsdio.c         |    2 +-
 drivers/bluetooth/btuart_cs.c      |   23 ++++---
 drivers/bluetooth/btusb.c          |   38 ++++++------
 drivers/bluetooth/btwilink.c       |   29 ++++-----
 drivers/bluetooth/dtl1_cs.c        |   19 +++---
 drivers/bluetooth/hci_ath.c        |    6 +-
 drivers/bluetooth/hci_bcsp.c       |   50 ++++++++-------
 drivers/bluetooth/hci_h4.c         |    8 +-
 drivers/bluetooth/hci_ldisc.c      |   14 ++--
 drivers/bluetooth/hci_ll.c         |   33 ++++++----
 drivers/bluetooth/hci_vhci.c       |    6 +-
 include/net/bluetooth/bluetooth.h  |    9 +--
 include/net/bluetooth/hci_core.h   |    6 +-
 net/bluetooth/af_bluetooth.c       |    4 +-
 net/bluetooth/bnep/core.c          |    4 +-
 net/bluetooth/bnep/netdev.c        |    2 +-
 net/bluetooth/bnep/sock.c          |    4 +-
 net/bluetooth/cmtp/capi.c          |   19 +++---
 net/bluetooth/cmtp/core.c          |    8 +-
 net/bluetooth/cmtp/sock.c          |    4 +-
 net/bluetooth/hci_core.c           |   24 ++++----
 net/bluetooth/hci_event.c          |   16 +++---
 net/bluetooth/hci_sock.c           |    6 +-
 net/bluetooth/hci_sysfs.c          |    2 +-
 net/bluetooth/hidp/core.c          |   14 +++--
 net/bluetooth/hidp/sock.c          |    4 +-
 net/bluetooth/l2cap_core.c         |   32 +++++-----
 net/bluetooth/l2cap_sock.c         |    6 +-
 net/bluetooth/lib.c                |   25 +++++++-
 net/bluetooth/mgmt.c               |    6 +-
 net/bluetooth/rfcomm/core.c        |   16 +++---
 net/bluetooth/rfcomm/sock.c        |    8 +-
 net/bluetooth/rfcomm/tty.c         |   18 +++---
 net/bluetooth/sco.c                |    8 +-
 net/bluetooth/smp.c                |   14 ++--
 44 files changed, 445 insertions(+), 413 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index 07f14d1..f4511b2 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -108,7 +108,7 @@ static int ath3k_load_firmware(struct usb_device *udev,
 
 	send_buf = kmalloc(BULK_SIZE, GFP_KERNEL);
 	if (!send_buf) {
-		BT_ERR("Can't allocate memory chunk for firmware");
+		bt_err("Can't allocate memory chunk for firmware\n");
 		return -ENOMEM;
 	}
 
@@ -117,7 +117,7 @@ static int ath3k_load_firmware(struct usb_device *udev,
 				USB_REQ_DFU_DNLOAD,
 				USB_TYPE_VENDOR, 0, 0,
 				send_buf, 20, USB_CTRL_SET_TIMEOUT)) < 0) {
-		BT_ERR("Can't change to loading configuration err");
+		bt_err("Can't change to loading configuration err\n");
 		goto error;
 	}
 	sent += 20;
@@ -132,8 +132,8 @@ static int ath3k_load_firmware(struct usb_device *udev,
 					&len, 3000);
 
 		if (err || (len != size)) {
-			BT_ERR("Error in firmware loading err = %d,"
-				"len = %d, size = %d", err, len, size);
+			bt_err("Error in firmware loading err = %d, len = %d, size = %d\n",
+			       err, len, size);
 			goto error;
 		}
 
@@ -179,7 +179,7 @@ static int ath3k_load_fwfile(struct usb_device *udev,
 
 	send_buf = kmalloc(BULK_SIZE, GFP_KERNEL);
 	if (!send_buf) {
-		BT_ERR("Can't allocate memory chunk for firmware");
+		bt_err("Can't allocate memory chunk for firmware\n");
 		return -ENOMEM;
 	}
 
@@ -191,7 +191,7 @@ static int ath3k_load_fwfile(struct usb_device *udev,
 			USB_TYPE_VENDOR, 0, 0, send_buf,
 			size, USB_CTRL_SET_TIMEOUT);
 	if (ret < 0) {
-		BT_ERR("Can't change to loading configuration err");
+		bt_err("Can't change to loading configuration err\n");
 		kfree(send_buf);
 		return ret;
 	}
@@ -208,8 +208,8 @@ static int ath3k_load_fwfile(struct usb_device *udev,
 		err = usb_bulk_msg(udev, pipe, send_buf, size,
 					&len, 3000);
 		if (err || (len != size)) {
-			BT_ERR("Error in firmware loading err = %d,"
-				"len = %d, size = %d", err, len, size);
+			bt_err("Error in firmware loading err = %d, len = %d, size = %d\n",
+			       err, len, size);
 			kfree(send_buf);
 			return err;
 		}
@@ -238,7 +238,7 @@ static int ath3k_set_normal_mode(struct usb_device *udev)
 
 	ret = ath3k_get_state(udev, &fw_state);
 	if (ret < 0) {
-		BT_ERR("Can't get state to change to normal mode err");
+		bt_err("Can't get state to change to normal mode err\n");
 		return ret;
 	}
 
@@ -263,7 +263,7 @@ static int ath3k_load_patch(struct usb_device *udev)
 
 	ret = ath3k_get_state(udev, &fw_state);
 	if (ret < 0) {
-		BT_ERR("Can't get state to change to load ram patch err");
+		bt_err("Can't get state to change to load ram patch err\n");
 		return ret;
 	}
 
@@ -274,7 +274,7 @@ static int ath3k_load_patch(struct usb_device *udev)
 
 	ret = ath3k_get_version(udev, &fw_version);
 	if (ret < 0) {
-		BT_ERR("Can't get version to change to load ram patch err");
+		bt_err("Can't get version to change to load ram patch err\n");
 		return ret;
 	}
 
@@ -283,7 +283,7 @@ static int ath3k_load_patch(struct usb_device *udev)
 
 	ret = request_firmware(&firmware, filename, &udev->dev);
 	if (ret < 0) {
-		BT_ERR("Patch file not found %s", filename);
+		bt_err("Patch file not found %s\n", filename);
 		return ret;
 	}
 
@@ -293,7 +293,7 @@ static int ath3k_load_patch(struct usb_device *udev)
 
 	if ((pt_version.rom_version != fw_version.rom_version) ||
 		(pt_version.build_version <= fw_version.build_version)) {
-		BT_ERR("Patch file version did not match with firmware");
+		bt_err("Patch file version did not match with firmware\n");
 		release_firmware(firmware);
 		return -EINVAL;
 	}
@@ -314,13 +314,13 @@ static int ath3k_load_syscfg(struct usb_device *udev)
 
 	ret = ath3k_get_state(udev, &fw_state);
 	if (ret < 0) {
-		BT_ERR("Can't get state to change to load configration err");
+		bt_err("Can't get state to change to load configration err\n");
 		return -EBUSY;
 	}
 
 	ret = ath3k_get_version(udev, &fw_version);
 	if (ret < 0) {
-		BT_ERR("Can't get version to change to load ram patch err");
+		bt_err("Can't get version to change to load ram patch err\n");
 		return ret;
 	}
 
@@ -345,7 +345,7 @@ static int ath3k_load_syscfg(struct usb_device *udev)
 
 	ret = request_firmware(&firmware, filename, &udev->dev);
 	if (ret < 0) {
-		BT_ERR("Configuration file not found %s", filename);
+		bt_err("Configuration file not found %s\n", filename);
 		return ret;
 	}
 
@@ -384,17 +384,17 @@ static int ath3k_probe(struct usb_interface *intf,
 
 		ret = ath3k_load_patch(udev);
 		if (ret < 0) {
-			BT_ERR("Loading patch file failed");
+			bt_err("Loading patch file failed\n");
 			return ret;
 		}
 		ret = ath3k_load_syscfg(udev);
 		if (ret < 0) {
-			BT_ERR("Loading sysconfig file failed");
+			bt_err("Loading sysconfig file failed\n");
 			return ret;
 		}
 		ret = ath3k_set_normal_mode(udev);
 		if (ret < 0) {
-			BT_ERR("Set normal mode failed");
+			bt_err("Set normal mode failed\n");
 			return ret;
 		}
 		ath3k_switch_pid(udev);
@@ -404,11 +404,11 @@ static int ath3k_probe(struct usb_interface *intf,
 	ret = request_firmware(&firmware, ATH3K_FIRMWARE, &udev->dev);
 	if (ret < 0) {
 		if (ret == -ENOENT)
-			BT_ERR("Firmware file \"%s\" not found",
-							ATH3K_FIRMWARE);
+			bt_err("Firmware file \"%s\" not found\n",
+			       ATH3K_FIRMWARE);
 		else
-			BT_ERR("Firmware file \"%s\" request failed (err=%d)",
-							ATH3K_FIRMWARE, ret);
+			bt_err("Firmware file \"%s\" request failed (err=%d)\n",
+			       ATH3K_FIRMWARE, ret);
 		return ret;
 	}
 
diff --git a/drivers/bluetooth/bcm203x.c b/drivers/bluetooth/bcm203x.c
index 1e742a5..d30c94c 100644
--- a/drivers/bluetooth/bcm203x.c
+++ b/drivers/bluetooth/bcm203x.c
@@ -85,7 +85,7 @@ static void bcm203x_complete(struct urb *urb)
 	BT_DBG("udev %p urb %p", udev, urb);
 
 	if (urb->status) {
-		BT_ERR("URB failed with status %d", urb->status);
+		bt_err("URB failed with status %d\n", urb->status);
 		data->state = BCM203X_ERROR;
 		return;
 	}
@@ -110,12 +110,12 @@ static void bcm203x_complete(struct urb *urb)
 		data->state = BCM203X_CHECK_MEMORY;
 
 		if (usb_submit_urb(data->urb, GFP_ATOMIC) < 0)
-			BT_ERR("Can't submit URB");
+			bt_err("Can't submit URB\n");
 		break;
 
 	case BCM203X_CHECK_MEMORY:
 		if (data->buffer[0] != '#') {
-			BT_ERR("Memory select failed");
+			bt_err("Memory select failed\n");
 			data->state = BCM203X_ERROR;
 			break;
 		}
@@ -138,12 +138,12 @@ static void bcm203x_complete(struct urb *urb)
 		}
 
 		if (usb_submit_urb(data->urb, GFP_ATOMIC) < 0)
-			BT_ERR("Can't submit URB");
+			bt_err("Can't submit URB\n");
 		break;
 
 	case BCM203X_CHECK_FIRMWARE:
 		if (data->buffer[0] != '.') {
-			BT_ERR("Firmware loading failed");
+			bt_err("Firmware loading failed\n");
 			data->state = BCM203X_ERROR;
 			break;
 		}
@@ -162,7 +162,7 @@ static void bcm203x_work(struct work_struct *work)
 		return;
 
 	if (usb_submit_urb(data->urb, GFP_KERNEL) < 0)
-		BT_ERR("Can't submit URB");
+		bt_err("Can't submit URB\n");
 }
 
 static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id *id)
@@ -179,7 +179,7 @@ static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (!data) {
-		BT_ERR("Can't allocate memory for data structure");
+		bt_err("Can't allocate memory for data structure\n");
 		return -ENOMEM;
 	}
 
@@ -188,13 +188,13 @@ static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id
 
 	data->urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!data->urb) {
-		BT_ERR("Can't allocate URB");
+		bt_err("Can't allocate URB\n");
 		kfree(data);
 		return -ENOMEM;
 	}
 
 	if (request_firmware(&firmware, "BCM2033-MD.hex", &udev->dev) < 0) {
-		BT_ERR("Mini driver request failed");
+		bt_err("Mini driver request failed\n");
 		usb_free_urb(data->urb);
 		kfree(data);
 		return -EIO;
@@ -206,7 +206,7 @@ static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id
 
 	data->buffer = kmalloc(size, GFP_KERNEL);
 	if (!data->buffer) {
-		BT_ERR("Can't allocate memory for mini driver");
+		bt_err("Can't allocate memory for mini driver\n");
 		release_firmware(firmware);
 		usb_free_urb(data->urb);
 		kfree(data);
@@ -221,7 +221,7 @@ static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id
 	release_firmware(firmware);
 
 	if (request_firmware(&firmware, "BCM2033-FW.bin", &udev->dev) < 0) {
-		BT_ERR("Firmware request failed");
+		bt_err("Firmware request failed\n");
 		usb_free_urb(data->urb);
 		kfree(data->buffer);
 		kfree(data);
@@ -232,7 +232,7 @@ static int bcm203x_probe(struct usb_interface *intf, const struct usb_device_id
 
 	data->fw_data = kmemdup(firmware->data, firmware->size, GFP_KERNEL);
 	if (!data->fw_data) {
-		BT_ERR("Can't allocate memory for firmware image");
+		bt_err("Can't allocate memory for firmware image\n");
 		release_firmware(firmware);
 		usb_free_urb(data->urb);
 		kfree(data->buffer);
diff --git a/drivers/bluetooth/bfusb.c b/drivers/bluetooth/bfusb.c
index a323bae..0623fb2 100644
--- a/drivers/bluetooth/bfusb.c
+++ b/drivers/bluetooth/bfusb.c
@@ -145,8 +145,8 @@ static int bfusb_send_bulk(struct bfusb_data *data, struct sk_buff *skb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err) {
-		BT_ERR("%s bulk tx submit failed urb %p err %d", 
-					data->hdev->name, urb, err);
+		bt_err("%s bulk tx submit failed urb %p err %d\n",
+		       data->hdev->name, urb, err);
 		skb_unlink(skb, &data->pending_q);
 		usb_free_urb(urb);
 	} else
@@ -241,8 +241,8 @@ static int bfusb_rx_submit(struct bfusb_data *data, struct urb *urb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err) {
-		BT_ERR("%s bulk rx submit failed urb %p err %d",
-					data->hdev->name, urb, err);
+		bt_err("%s bulk rx submit failed urb %p err %d\n",
+		       data->hdev->name, urb, err);
 		skb_unlink(skb, &data->pending_q);
 		kfree_skb(skb);
 		usb_free_urb(urb);
@@ -256,7 +256,7 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 	BT_DBG("bfusb %p hdr 0x%02x data %p len %d", data, hdr, buf, len);
 
 	if (hdr & 0x10) {
-		BT_ERR("%s error in block", data->hdev->name);
+		bt_err("%s error in block\n", data->hdev->name);
 		kfree_skb(data->reassembly);
 		data->reassembly = NULL;
 		return -EIO;
@@ -268,13 +268,13 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 		int pkt_len = 0;
 
 		if (data->reassembly) {
-			BT_ERR("%s unexpected start block", data->hdev->name);
+			bt_err("%s unexpected start block\n", data->hdev->name);
 			kfree_skb(data->reassembly);
 			data->reassembly = NULL;
 		}
 
 		if (len < 1) {
-			BT_ERR("%s no packet type found", data->hdev->name);
+			bt_err("%s no packet type found\n", data->hdev->name);
 			return -EPROTO;
 		}
 
@@ -286,7 +286,8 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 				struct hci_event_hdr *hdr = (struct hci_event_hdr *) buf;
 				pkt_len = HCI_EVENT_HDR_SIZE + hdr->plen;
 			} else {
-				BT_ERR("%s event block is too short", data->hdev->name);
+				bt_err("%s event block is too short\n",
+				       data->hdev->name);
 				return -EILSEQ;
 			}
 			break;
@@ -296,7 +297,8 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 				struct hci_acl_hdr *hdr = (struct hci_acl_hdr *) buf;
 				pkt_len = HCI_ACL_HDR_SIZE + __le16_to_cpu(hdr->dlen);
 			} else {
-				BT_ERR("%s data block is too short", data->hdev->name);
+				bt_err("%s data block is too short\n",
+				       data->hdev->name);
 				return -EILSEQ;
 			}
 			break;
@@ -306,7 +308,8 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 				struct hci_sco_hdr *hdr = (struct hci_sco_hdr *) buf;
 				pkt_len = HCI_SCO_HDR_SIZE + hdr->dlen;
 			} else {
-				BT_ERR("%s audio block is too short", data->hdev->name);
+				bt_err("%s audio block is too short\n",
+				       data->hdev->name);
 				return -EILSEQ;
 			}
 			break;
@@ -314,7 +317,8 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 
 		skb = bt_skb_alloc(pkt_len, GFP_ATOMIC);
 		if (!skb) {
-			BT_ERR("%s no memory for the packet", data->hdev->name);
+			bt_err("%s no memory for the packet\n",
+			       data->hdev->name);
 			return -ENOMEM;
 		}
 
@@ -324,7 +328,8 @@ static inline int bfusb_recv_block(struct bfusb_data *data, int hdr, unsigned ch
 		data->reassembly = skb;
 	} else {
 		if (!data->reassembly) {
-			BT_ERR("%s unexpected continuation block", data->hdev->name);
+			bt_err("%s unexpected continuation block\n",
+			       data->hdev->name);
 			return -EIO;
 		}
 	}
@@ -376,8 +381,8 @@ static void bfusb_rx_complete(struct urb *urb)
 		}
 
 		if (count < len) {
-			BT_ERR("%s block extends over URB buffer ranges",
-					data->hdev->name);
+			bt_err("%s block extends over URB buffer ranges\n",
+			       data->hdev->name);
 		}
 
 		if ((hdr & 0xe1) == 0xc1)
@@ -401,8 +406,8 @@ resubmit:
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err) {
-		BT_ERR("%s bulk resubmit failed urb %p err %d",
-					data->hdev->name, urb, err);
+		bt_err("%s bulk resubmit failed urb %p err %d\n",
+		       data->hdev->name, urb, err);
 	}
 
 unlock:
@@ -476,7 +481,7 @@ static int bfusb_send_frame(struct sk_buff *skb)
 	BT_DBG("hdev %p skb %p type %d len %d", hdev, skb, bt_cb(skb)->pkt_type, skb->len);
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown HCI device (hdev=NULL)");
+		bt_err("Frame for unknown HCI device (hdev=NULL)\n");
 		return -ENODEV;
 	}
 
@@ -505,7 +510,7 @@ static int bfusb_send_frame(struct sk_buff *skb)
 	/* Max HCI frame size seems to be 1511 + 1 */
 	nskb = bt_skb_alloc(count + 32, GFP_ATOMIC);
 	if (!nskb) {
-		BT_ERR("Can't allocate memory for new packet");
+		bt_err("Can't allocate memory for new packet\n");
 		return -ENOMEM;
 	}
 
@@ -566,11 +571,11 @@ static int bfusb_load_firmware(struct bfusb_data *data,
 
 	BT_DBG("bfusb %p udev %p", data, data->udev);
 
-	BT_INFO("BlueFRITZ! USB loading firmware");
+	bt_info("BlueFRITZ! USB loading firmware\n");
 
 	buf = kmalloc(BFUSB_MAX_BLOCK_SIZE + 3, GFP_KERNEL);
 	if (!buf) {
-		BT_ERR("Can't allocate memory chunk for firmware");
+		bt_err("Can't allocate memory chunk for firmware\n");
 		return -ENOMEM;
 	}
 
@@ -578,7 +583,7 @@ static int bfusb_load_firmware(struct bfusb_data *data,
 
 	if (usb_control_msg(data->udev, pipe, USB_REQ_SET_CONFIGURATION,
 				0, 1, 0, NULL, 0, USB_CTRL_SET_TIMEOUT) < 0) {
-		BT_ERR("Can't change to loading configuration");
+		bt_err("Can't change to loading configuration\n");
 		kfree(buf);
 		return -EBUSY;
 	}
@@ -596,7 +601,7 @@ static int bfusb_load_firmware(struct bfusb_data *data,
 					&len, BFUSB_BLOCK_TIMEOUT);
 
 		if (err || (len != size)) {
-			BT_ERR("Error in firmware loading");
+			bt_err("Error in firmware loading\n");
 			goto error;
 		}
 
@@ -607,7 +612,7 @@ static int bfusb_load_firmware(struct bfusb_data *data,
 	err = usb_bulk_msg(data->udev, pipe, NULL, 0,
 					&len, BFUSB_BLOCK_TIMEOUT);
 	if (err < 0) {
-		BT_ERR("Error in null packet request");
+		bt_err("Error in null packet request\n");
 		goto error;
 	}
 
@@ -616,13 +621,13 @@ static int bfusb_load_firmware(struct bfusb_data *data,
 	err = usb_control_msg(data->udev, pipe, USB_REQ_SET_CONFIGURATION,
 				0, 2, 0, NULL, 0, USB_CTRL_SET_TIMEOUT);
 	if (err < 0) {
-		BT_ERR("Can't change to running configuration");
+		bt_err("Can't change to running configuration\n");
 		goto error;
 	}
 
 	data->udev->toggle[0] = data->udev->toggle[1] = 0;
 
-	BT_INFO("BlueFRITZ! USB device ready");
+	bt_info("BlueFRITZ! USB device ready\n");
 
 	kfree(buf);
 	return 0;
@@ -657,14 +662,14 @@ static int bfusb_probe(struct usb_interface *intf, const struct usb_device_id *i
 	bulk_in_ep  = &intf->cur_altsetting->endpoint[1];
 
 	if (!bulk_out_ep || !bulk_in_ep) {
-		BT_ERR("Bulk endpoints not found");
+		bt_err("Bulk endpoints not found\n");
 		goto done;
 	}
 
 	/* Initialize control structure and load firmware */
 	data = kzalloc(sizeof(struct bfusb_data), GFP_KERNEL);
 	if (!data) {
-		BT_ERR("Can't allocate memory for control structure");
+		bt_err("Can't allocate memory for control structure\n");
 		goto done;
 	}
 
@@ -682,14 +687,14 @@ static int bfusb_probe(struct usb_interface *intf, const struct usb_device_id *i
 	skb_queue_head_init(&data->completed_q);
 
 	if (request_firmware(&firmware, "bfubase.frm", &udev->dev) < 0) {
-		BT_ERR("Firmware request failed");
+		bt_err("Firmware request failed\n");
 		goto error;
 	}
 
 	BT_DBG("firmware data %p size %zu", firmware->data, firmware->size);
 
 	if (bfusb_load_firmware(data, firmware->data, firmware->size) < 0) {
-		BT_ERR("Firmware loading failed");
+		bt_err("Firmware loading failed\n");
 		goto release;
 	}
 
@@ -698,7 +703,7 @@ static int bfusb_probe(struct usb_interface *intf, const struct usb_device_id *i
 	/* Initialize and register HCI device */
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can't allocate HCI device");
+		bt_err("Can't allocate HCI device\n");
 		goto error;
 	}
 
@@ -718,7 +723,7 @@ static int bfusb_probe(struct usb_interface *intf, const struct usb_device_id *i
 	hdev->owner = THIS_MODULE;
 
 	if (hci_register_dev(hdev) < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device\n");
 		hci_free_dev(hdev);
 		goto error;
 	}
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index c6a0c61..cd25d9b 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -218,7 +218,7 @@ static int bluecard_write(unsigned int iobase, unsigned int offset, __u8 *buf, i
 static void bluecard_write_wakeup(bluecard_info_t *info)
 {
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device\n");
 		return;
 	}
 
@@ -374,7 +374,7 @@ static void bluecard_receive(bluecard_info_t *info, unsigned int offset)
 	int i, len;
 
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device\n");
 		return;
 	}
 
@@ -392,7 +392,7 @@ static void bluecard_receive(bluecard_info_t *info, unsigned int offset)
 			info->rx_state = RECV_WAIT_PACKET_TYPE;
 			info->rx_count = 0;
 			if (!(info->rx_skb = bt_skb_alloc(HCI_MAX_FRAME_SIZE, GFP_ATOMIC))) {
-				BT_ERR("Can't allocate mem for new packet");
+				bt_err("Can't allocate mem for new packet\n");
 				return;
 			}
 		}
@@ -434,7 +434,8 @@ static void bluecard_receive(bluecard_info_t *info, unsigned int offset)
 
 			default:
 				/* unknown packet */
-				BT_ERR("Unknown HCI packet with type 0x%02x received", bt_cb(info->rx_skb)->pkt_type);
+				bt_err("Unknown HCI packet with type 0x%02x received\n",
+				       bt_cb(info->rx_skb)->pkt_type);
 				info->hdev->stat.err_rx++;
 
 				kfree_skb(info->rx_skb);
@@ -568,7 +569,7 @@ static int bluecard_hci_set_baud_rate(struct hci_dev *hdev, int baud)
 	unsigned char cmd[] = { HCI_COMMAND_PKT, 0x09, 0xfc, 0x01, 0x03 };
 
 	if (!(skb = bt_skb_alloc(HCI_MAX_FRAME_SIZE, GFP_ATOMIC))) {
-		BT_ERR("Can't allocate mem for new packet");
+		bt_err("Can't allocate mem for new packet\n");
 		return -1;
 	}
 
@@ -663,7 +664,7 @@ static int bluecard_hci_send_frame(struct sk_buff *skb)
 	struct hci_dev *hdev = (struct hci_dev *)(skb->dev);
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown HCI device (hdev=NULL)");
+		bt_err("Frame for unknown HCI device (hdev=NULL)\n");
 		return -ENODEV;
 	}
 
@@ -727,7 +728,7 @@ static int bluecard_open(bluecard_info_t *info)
 	/* Initialize HCI device */
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can't allocate HCI device");
+		bt_err("Can't allocate HCI device\n");
 		return -ENOMEM;
 	}
 
@@ -815,7 +816,7 @@ static int bluecard_open(bluecard_info_t *info)
 
 	/* Register HCI device */
 	if (hci_register_dev(hdev) < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device\n");
 		info->hdev = NULL;
 		hci_free_dev(hdev);
 		return -ENODEV;
diff --git a/drivers/bluetooth/bpa10x.c b/drivers/bluetooth/bpa10x.c
index 6283160..e2f1458 100644
--- a/drivers/bluetooth/bpa10x.c
+++ b/drivers/bluetooth/bpa10x.c
@@ -125,7 +125,7 @@ static int bpa10x_recv(struct hci_dev *hdev, int queue, void *buf, int count)
 
 			skb = bt_skb_alloc(len, GFP_ATOMIC);
 			if (!skb) {
-				BT_ERR("%s no memory for packet", hdev->name);
+				bt_err("%s no memory for packet\n", hdev->name);
 				return -ENOMEM;
 			}
 
@@ -202,7 +202,7 @@ static void bpa10x_rx_complete(struct urb *urb)
 		if (bpa10x_recv(hdev, usb_pipebulk(urb->pipe),
 						urb->transfer_buffer,
 						urb->actual_length) < 0) {
-			BT_ERR("%s corrupted event packet", hdev->name);
+			bt_err("%s corrupted event packet\n", hdev->name);
 			hdev->stat.err_rx++;
 		}
 	}
@@ -211,8 +211,8 @@ static void bpa10x_rx_complete(struct urb *urb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
-		BT_ERR("%s urb %p failed to resubmit (%d)",
-						hdev->name, urb, -err);
+		bt_err("%s urb %p failed to resubmit (%d)\n",
+		       hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
 }
@@ -248,8 +248,8 @@ static inline int bpa10x_submit_intr_urb(struct hci_dev *hdev)
 
 	err = usb_submit_urb(urb, GFP_KERNEL);
 	if (err < 0) {
-		BT_ERR("%s urb %p submission failed (%d)",
-						hdev->name, urb, -err);
+		bt_err("%s urb %p submission failed (%d)\n",
+		       hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
 
@@ -289,8 +289,8 @@ static inline int bpa10x_submit_bulk_urb(struct hci_dev *hdev)
 
 	err = usb_submit_urb(urb, GFP_KERNEL);
 	if (err < 0) {
-		BT_ERR("%s urb %p submission failed (%d)",
-						hdev->name, urb, -err);
+		bt_err("%s urb %p submission failed (%d)\n",
+		       hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
 
@@ -422,7 +422,7 @@ static int bpa10x_send_frame(struct sk_buff *skb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
-		BT_ERR("%s urb %p submission failed", hdev->name, urb);
+		bt_err("%s urb %p submission failed\n", hdev->name, urb);
 		kfree(urb->setup_packet);
 		usb_unanchor_urb(urb);
 	}
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 0c97e5d..38f020b 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -179,7 +179,7 @@ static int bt3c_write(unsigned int iobase, int fifo_size, __u8 *buf, int len)
 static void bt3c_write_wakeup(bt3c_info_t *info)
 {
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device\n");
 		return;
 	}
 
@@ -204,7 +204,7 @@ static void bt3c_write_wakeup(bt3c_info_t *info)
 		len = bt3c_write(iobase, 256, skb->data, skb->len);
 
 		if (len != skb->len) {
-			BT_ERR("Very strange");
+			bt_err("Very strange\n");
 		}
 
 		kfree_skb(skb);
@@ -221,7 +221,7 @@ static void bt3c_receive(bt3c_info_t *info)
 	int size = 0, avail;
 
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device\n");
 		return;
 	}
 
@@ -240,7 +240,7 @@ static void bt3c_receive(bt3c_info_t *info)
 			info->rx_state = RECV_WAIT_PACKET_TYPE;
 			info->rx_count = 0;
 			if (!(info->rx_skb = bt_skb_alloc(HCI_MAX_FRAME_SIZE, GFP_ATOMIC))) {
-				BT_ERR("Can't allocate mem for new packet");
+				bt_err("Can't allocate mem for new packet\n");
 				return;
 			}
 		}
@@ -272,7 +272,8 @@ static void bt3c_receive(bt3c_info_t *info)
 
 			default:
 				/* Unknown packet */
-				BT_ERR("Unknown HCI packet with type 0x%02x received", bt_cb(info->rx_skb)->pkt_type);
+				bt_err("Unknown HCI packet with type 0x%02x received\n",
+				       bt_cb(info->rx_skb)->pkt_type);
 				info->hdev->stat.err_rx++;
 				clear_bit(HCI_RUNNING, &(info->hdev->flags));
 
@@ -355,17 +356,18 @@ static irqreturn_t bt3c_interrupt(int irq, void *dev_inst)
 		int stat = bt3c_read(iobase, 0x7001);
 
 		if ((stat & 0xff) == 0x7f) {
-			BT_ERR("Very strange (stat=0x%04x)", stat);
+			bt_err("Very strange (stat=0x%04x)\n", stat);
 		} else if ((stat & 0xff) != 0xff) {
 			if (stat & 0x0020) {
 				int status = bt3c_read(iobase, 0x7002) & 0x10;
-				BT_INFO("%s: Antenna %s", info->hdev->name,
-							status ? "out" : "in");
+				bt_info("%s: Antenna %s\n",
+					info->hdev->name,
+					status ? "out" : "in");
 			}
 			if (stat & 0x0001)
 				bt3c_receive(info);
 			if (stat & 0x0002) {
-				//BT_ERR("Ack (stat=0x%04x)", stat);
+				/*bt_err("Ack (stat=0x%04x)\n", stat);*/
 				clear_bit(XMIT_SENDING, &(info->tx_state));
 				bt3c_write_wakeup(info);
 			}
@@ -424,7 +426,7 @@ static int bt3c_hci_send_frame(struct sk_buff *skb)
 	unsigned long flags;
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown HCI device (hdev=NULL)");
+		bt_err("Frame for unknown HCI device (hdev=NULL)\n");
 		return -ENODEV;
 	}
 
@@ -494,7 +496,7 @@ static int bt3c_load_firmware(bt3c_info_t *info, const unsigned char *firmware,
 	/* Load */
 	while (count) {
 		if (ptr[0] != 'S') {
-			BT_ERR("Bad address in firmware");
+			bt_err("Bad address in firmware\n");
 			err = -EFAULT;
 			goto error;
 		}
@@ -518,7 +520,7 @@ static int bt3c_load_firmware(bt3c_info_t *info, const unsigned char *firmware,
 		}
 
 		if (((tmp + fcs) & 0xff) != 0xff) {
-			BT_ERR("Checksum error in firmware");
+			bt_err("Checksum error in firmware\n");
 			err = -EILSEQ;
 			goto error;
 		}
@@ -573,7 +575,7 @@ static int bt3c_open(bt3c_info_t *info)
 	/* Initialize HCI device */
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can't allocate HCI device");
+		bt_err("Can't allocate HCI device\n");
 		return -ENOMEM;
 	}
 
@@ -595,7 +597,7 @@ static int bt3c_open(bt3c_info_t *info)
 	/* Load firmware */
 	err = request_firmware(&firmware, "BT3CPCC.bin", &info->p_dev->dev);
 	if (err < 0) {
-		BT_ERR("Firmware request failed");
+		bt_err("Firmware request failed\n");
 		goto error;
 	}
 
@@ -604,7 +606,7 @@ static int bt3c_open(bt3c_info_t *info)
 	release_firmware(firmware);
 
 	if (err < 0) {
-		BT_ERR("Firmware loading failed");
+		bt_err("Firmware loading failed\n");
 		goto error;
 	}
 
@@ -614,7 +616,7 @@ static int bt3c_open(bt3c_info_t *info)
 	/* Register HCI device */
 	err = hci_register_dev(hdev);
 	if (err < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device\n");
 		goto error;
 	}
 
@@ -726,7 +728,7 @@ static int bt3c_config(struct pcmcia_device *link)
 	if (!pcmcia_loop_config(link, bt3c_check_config_notpicky, NULL))
 		goto found_port;
 
-	BT_ERR("No usable port range found");
+	bt_err("No usable port range found\n");
 	goto failed;
 
 found_port:
diff --git a/drivers/bluetooth/btmrvl_debugfs.c b/drivers/bluetooth/btmrvl_debugfs.c
index 8ecf4c6..7f1eb63 100644
--- a/drivers/bluetooth/btmrvl_debugfs.c
+++ b/drivers/bluetooth/btmrvl_debugfs.c
@@ -394,7 +394,7 @@ void btmrvl_debugfs_init(struct hci_dev *hdev)
 	priv->debugfs_data = dbg;
 
 	if (!dbg) {
-		BT_ERR("Can not allocate memory for btmrvl_debugfs_data.");
+		bt_err("Can not allocate memory for btmrvl_debugfs_data\n");
 		return;
 	}
 
diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index 6c3defa..0ccf84d 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -164,7 +164,7 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 
 	skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
 	if (skb == NULL) {
-		BT_ERR("No free skb");
+		bt_err("No free skb\n");
 		return -ENOMEM;
 	}
 
@@ -190,8 +190,8 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 				priv->adapter->cmd_complete,
 				msecs_to_jiffies(WAIT_UNTIL_CMD_RESP))) {
 		ret = -ETIMEDOUT;
-		BT_ERR("module_cfg_cmd(%x): timeout: %d",
-					subcmd, priv->btmrvl_dev.sendcmdflag);
+		bt_err("module_cfg_cmd(%x): timeout: %d\n",
+		       subcmd, priv->btmrvl_dev.sendcmdflag);
 	}
 
 	BT_DBG("module cfg Command done");
@@ -207,7 +207,7 @@ int btmrvl_enable_ps(struct btmrvl_private *priv)
 
 	skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
 	if (skb == NULL) {
-		BT_ERR("No free skb");
+		bt_err("No free skb\n");
 		return -ENOMEM;
 	}
 
@@ -240,7 +240,7 @@ static int btmrvl_enable_hs(struct btmrvl_private *priv)
 
 	skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
 	if (skb == NULL) {
-		BT_ERR("No free skb");
+		bt_err("No free skb\n");
 		return -ENOMEM;
 	}
 
@@ -261,9 +261,10 @@ static int btmrvl_enable_hs(struct btmrvl_private *priv)
 			priv->adapter->hs_state,
 			msecs_to_jiffies(WAIT_UNTIL_HS_STATE_CHANGED))) {
 		ret = -ETIMEDOUT;
-		BT_ERR("timeout: %d, %d,%d", priv->adapter->hs_state,
-						priv->adapter->ps_state,
-						priv->adapter->wakeup_tries);
+		bt_err("timeout: %d, %d,%d\n",
+		       priv->adapter->hs_state,
+		       priv->adapter->ps_state,
+		       priv->adapter->wakeup_tries);
 	}
 
 	return ret;
@@ -280,7 +281,7 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 
 		skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
 		if (skb == NULL) {
-			BT_ERR("No free skb");
+			bt_err("No free skb\n");
 			return -ENOMEM;
 		}
 
@@ -326,8 +327,8 @@ static int btmrvl_tx_pkt(struct btmrvl_private *priv, struct sk_buff *skb)
 		return -EINVAL;
 
 	if (!skb->len || ((skb->len + BTM_HEADER_LEN) > BTM_UPLD_SIZE)) {
-		BT_ERR("Tx Error: Bad skb length %d : %d",
-						skb->len, BTM_UPLD_SIZE);
+		bt_err("Tx Error: Bad skb length %d : %d\n",
+		       skb->len, BTM_UPLD_SIZE);
 		return -EINVAL;
 	}
 
@@ -336,8 +337,8 @@ static int btmrvl_tx_pkt(struct btmrvl_private *priv, struct sk_buff *skb)
 
 		skb = skb_realloc_headroom(skb, BTM_HEADER_LEN);
 		if (!skb) {
-			BT_ERR("Tx Error: realloc_headroom failed %d",
-				BTM_HEADER_LEN);
+			bt_err("Tx Error: realloc_headroom failed %d\n",
+			       BTM_HEADER_LEN);
 			skb = tmp;
 			return -EINVAL;
 		}
@@ -399,13 +400,13 @@ static int btmrvl_send_frame(struct sk_buff *skb)
 	BT_DBG("type=%d, len=%d", skb->pkt_type, skb->len);
 
 	if (!hdev || !hdev->driver_data) {
-		BT_ERR("Frame for unknown HCI device");
+		bt_err("Frame for unknown HCI device\n");
 		return -ENODEV;
 	}
 
 	priv = (struct btmrvl_private *) hdev->driver_data;
 	if (!test_bit(HCI_RUNNING, &hdev->flags)) {
-		BT_ERR("Failed testing HCI_RUNING, flags=%lx", hdev->flags);
+		bt_err("Failed testing HCI_RUNING, flags=%lx\n", hdev->flags);
 		print_hex_dump_bytes("data: ", DUMP_PREFIX_OFFSET,
 							skb->data, skb->len);
 		return -EBUSY;
@@ -541,7 +542,7 @@ int btmrvl_register_hdev(struct btmrvl_private *priv)
 
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can not allocate HCI device");
+		bt_err("Can not allocate HCI device\n");
 		goto err_hdev;
 	}
 
@@ -563,7 +564,7 @@ int btmrvl_register_hdev(struct btmrvl_private *priv)
 
 	ret = hci_register_dev(hdev);
 	if (ret < 0) {
-		BT_ERR("Can not register HCI device");
+		bt_err("Can not register HCI device\n");
 		goto err_hci_register_dev;
 	}
 
@@ -593,13 +594,13 @@ struct btmrvl_private *btmrvl_add_card(void *card)
 
 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
 	if (!priv) {
-		BT_ERR("Can not allocate priv");
+		bt_err("Can not allocate priv\n");
 		goto err_priv;
 	}
 
 	priv->adapter = kzalloc(sizeof(*priv->adapter), GFP_KERNEL);
 	if (!priv->adapter) {
-		BT_ERR("Allocate buffer for btmrvl_adapter failed!");
+		bt_err("Allocate buffer for btmrvl_adapter failed!\n");
 		goto err_adapter;
 	}
 
diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
index 27b74b0..ba5629b 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -170,7 +170,7 @@ static int btmrvl_sdio_enable_host_int_mask(struct btmrvl_sdio_card *card,
 
 	sdio_writeb(card->func, mask, card->reg->host_int_mask, &ret);
 	if (ret) {
-		BT_ERR("Unable to enable the host interrupt!");
+		bt_err("Unable to enable the host interrupt!\n");
 		ret = -EIO;
 	}
 
@@ -191,7 +191,7 @@ static int btmrvl_sdio_disable_host_int_mask(struct btmrvl_sdio_card *card,
 
 	sdio_writeb(card->func, host_int_mask, card->reg->host_int_mask, &ret);
 	if (ret < 0) {
-		BT_ERR("Unable to disable the host interrupt!");
+		bt_err("Unable to disable the host interrupt!\n");
 		return -EIO;
 	}
 
@@ -217,7 +217,7 @@ static int btmrvl_sdio_poll_card_status(struct btmrvl_sdio_card *card, u8 bits)
 	ret = -ETIMEDOUT;
 
 failed:
-	BT_ERR("FAILED! ret=%d", ret);
+	bt_err("FAILED! ret=%d\n", ret);
 
 	return ret;
 }
@@ -258,8 +258,8 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 	ret = request_firmware(&fw_helper, card->helper,
 						&card->func->dev);
 	if ((ret < 0) || !fw_helper) {
-		BT_ERR("request_firmware(helper) failed, error code = %d",
-									ret);
+		bt_err("request_firmware(helper) failed, error code = %d\n",
+		       ret);
 		ret = -ENOENT;
 		goto done;
 	}
@@ -274,8 +274,7 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 
 	tmphlprbuf = kzalloc(tmphlprbufsz, GFP_KERNEL);
 	if (!tmphlprbuf) {
-		BT_ERR("Unable to allocate buffer for helper."
-			" Terminating download");
+		bt_err("Unable to allocate buffer for helper - Terminating download\n");
 		ret = -ENOMEM;
 		goto done;
 	}
@@ -291,8 +290,8 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 		ret = btmrvl_sdio_poll_card_status(card,
 					    CARD_IO_READY | DN_LD_CARD_RDY);
 		if (ret < 0) {
-			BT_ERR("Helper download poll status timeout @ %d",
-				hlprblknow);
+			bt_err("Helper download poll status timeout @ %d\n",
+			       hlprblknow);
 			goto done;
 		}
 
@@ -316,8 +315,8 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 		ret = sdio_writesb(card->func, card->ioport, helperbuf,
 				FIRMWARE_TRANSFER_NBLOCK * SDIO_BLOCK_SIZE);
 		if (ret < 0) {
-			BT_ERR("IO error during helper download @ %d",
-				hlprblknow);
+			bt_err("IO error during helper download @ %d\n",
+			       hlprblknow);
 			goto done;
 		}
 
@@ -331,7 +330,7 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 	ret = sdio_writesb(card->func, card->ioport, helperbuf,
 							SDIO_BLOCK_SIZE);
 	if (ret < 0) {
-		BT_ERR("IO error in writing helper image EOF block");
+		bt_err("IO error in writing helper image EOF block\n");
 		goto done;
 	}
 
@@ -360,8 +359,8 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 	ret = request_firmware(&fw_firmware, card->firmware,
 							&card->func->dev);
 	if ((ret < 0) || !fw_firmware) {
-		BT_ERR("request_firmware(firmware) failed, error code = %d",
-									ret);
+		bt_err("request_firmware(firmware) failed, error code = %d\n",
+		       ret);
 		ret = -ENOENT;
 		goto done;
 	}
@@ -374,8 +373,7 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 	tmpfwbufsz = ALIGN_SZ(BTM_UPLD_SIZE, BTSDIO_DMA_ALIGN);
 	tmpfwbuf = kzalloc(tmpfwbufsz, GFP_KERNEL);
 	if (!tmpfwbuf) {
-		BT_ERR("Unable to allocate buffer for firmware."
-		       " Terminating download");
+		bt_err("Unable to allocate buffer for firmware - Terminating download\n");
 		ret = -ENOMEM;
 		goto done;
 	}
@@ -389,8 +387,8 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 		ret = btmrvl_sdio_poll_card_status(card,
 					CARD_IO_READY | DN_LD_CARD_RDY);
 		if (ret < 0) {
-			BT_ERR("FW download with helper poll status"
-						" timeout @ %d", offset);
+			bt_err("FW download with helper poll status timeout @ %d\n",
+			       offset);
 			goto done;
 		}
 
@@ -402,20 +400,16 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 			base0 = sdio_readb(card->func,
 					card->reg->sq_read_base_addr_a0, &ret);
 			if (ret) {
-				BT_ERR("BASE0 register read failed:"
-					" base0 = 0x%04X(%d)."
-					" Terminating download",
-					base0, base0);
+				bt_err("BASE0 register read failed: base0 = 0x%04X(%d) - Terminating download\n",
+				       base0, base0);
 				ret = -EIO;
 				goto done;
 			}
 			base1 = sdio_readb(card->func,
 					card->reg->sq_read_base_addr_a1, &ret);
 			if (ret) {
-				BT_ERR("BASE1 register read failed:"
-					" base1 = 0x%04X(%d)."
-					" Terminating download",
-					base1, base1);
+				bt_err("BASE1 register read failed: base1 = 0x%04X(%d) - Terminating download\n",
+				       base1, base1);
 				ret = -EIO;
 				goto done;
 			}
@@ -430,8 +424,8 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 		if (!len)
 			break;
 		else if (len > BTM_UPLD_SIZE) {
-			BT_ERR("FW download failure @%d, invalid length %d",
-								offset, len);
+			bt_err("FW download failure @%d, invalid length %d\n",
+			       offset, len);
 			ret = -EINVAL;
 			goto done;
 		}
@@ -441,13 +435,13 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 		if (len & BIT(0)) {
 			count++;
 			if (count > MAX_WRITE_IOMEM_RETRY) {
-				BT_ERR("FW download failure @%d, "
-					"over max retry count", offset);
+				bt_err("FW download failure @%d, over max retry count\n",
+				       offset);
 				ret = -EIO;
 				goto done;
 			}
-			BT_ERR("FW CRC error indicated by the helper: "
-				"len = 0x%04X, txlen = %d", len, txlen);
+			bt_err("FW CRC error indicated by the helper: len = 0x%04X, txlen = %d\n",
+			       len, txlen);
 			len &= ~BIT(0);
 			/* Set txlen to 0 so as to resend from same offset */
 			txlen = 0;
@@ -467,12 +461,12 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 						tx_blocks * blksz_dl);
 
 		if (ret < 0) {
-			BT_ERR("FW download, writesb(%d) failed @%d",
-							count, offset);
+			bt_err("FW download, writesb(%d) failed @%d\n",
+			       count, offset);
 			sdio_writeb(card->func, HOST_CMD53_FIN,
 						card->reg->cfg, &ret);
 			if (ret)
-				BT_ERR("writeb failed (CFG)");
+				bt_err("writeb failed (CFG)\n");
 		}
 
 		offset += txlen;
@@ -502,7 +496,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 	struct btmrvl_sdio_card *card = priv->btmrvl_dev.card;
 
 	if (!card || !card->func) {
-		BT_ERR("card or function is NULL!");
+		bt_err("card or function is NULL!\n");
 		ret = -EINVAL;
 		goto exit;
 	}
@@ -510,7 +504,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 	/* Read the length of data to be transferred */
 	ret = btmrvl_sdio_read_rx_len(card, &buf_len);
 	if (ret < 0) {
-		BT_ERR("read rx_len failed");
+		bt_err("read rx_len failed\n");
 		ret = -EIO;
 		goto exit;
 	}
@@ -520,7 +514,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 
 	if (buf_len <= SDIO_HEADER_LEN
 			|| (buf_block_len * blksz) > ALLOC_BUF_SIZE) {
-		BT_ERR("invalid packet length: %d", buf_len);
+		bt_err("invalid packet length: %d\n", buf_len);
 		ret = -EINVAL;
 		goto exit;
 	}
@@ -529,7 +523,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 	skb = bt_skb_alloc(buf_block_len * blksz + BTSDIO_DMA_ALIGN,
 								GFP_ATOMIC);
 	if (skb == NULL) {
-		BT_ERR("No free skb");
+		bt_err("No free skb\n");
 		goto exit;
 	}
 
@@ -545,7 +539,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 	ret = sdio_readsb(card->func, payload, card->ioport,
 			  buf_block_len * blksz);
 	if (ret < 0) {
-		BT_ERR("readsb failed: %d", ret);
+		bt_err("readsb failed: %d\n", ret);
 		ret = -EIO;
 		goto exit;
 	}
@@ -587,7 +581,7 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 		break;
 
 	default:
-		BT_ERR("Unknown packet type:%d", type);
+		bt_err("Unknown packet type:%d\n", type);
 		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, payload,
 						blksz * buf_block_len);
 
@@ -644,8 +638,8 @@ static void btmrvl_sdio_interrupt(struct sdio_func *func)
 
 	card = sdio_get_drvdata(func);
 	if (!card || !card->priv) {
-		BT_ERR("sbi_interrupt(%p) card or priv is "
-				"NULL, card=%p\n", func, card);
+		bt_err("sbi_interrupt(%p) card or priv is NULL, card=%p\n",
+		       func, card);
 		return;
 	}
 
@@ -653,7 +647,7 @@ static void btmrvl_sdio_interrupt(struct sdio_func *func)
 
 	ireg = sdio_readb(card->func, card->reg->host_intstatus, &ret);
 	if (ret) {
-		BT_ERR("sdio_readb: read int status register failed");
+		bt_err("sdio_readb: read int status register failed\n");
 		return;
 	}
 
@@ -669,7 +663,7 @@ static void btmrvl_sdio_interrupt(struct sdio_func *func)
 					UP_LD_HOST_INT_STATUS),
 				card->reg->host_intstatus, &ret);
 		if (ret) {
-			BT_ERR("sdio_writeb: clear int status register failed");
+			bt_err("sdio_writeb: clear int status register failed\n");
 			return;
 		}
 	}
@@ -688,7 +682,7 @@ static int btmrvl_sdio_register_dev(struct btmrvl_sdio_card *card)
 	int ret = 0;
 
 	if (!card || !card->func) {
-		BT_ERR("Error: card or function is NULL!");
+		bt_err("Error: card or function is NULL!\n");
 		ret = -EINVAL;
 		goto failed;
 	}
@@ -699,21 +693,21 @@ static int btmrvl_sdio_register_dev(struct btmrvl_sdio_card *card)
 
 	ret = sdio_enable_func(func);
 	if (ret) {
-		BT_ERR("sdio_enable_func() failed: ret=%d", ret);
+		bt_err("sdio_enable_func() failed: ret=%d\n", ret);
 		ret = -EIO;
 		goto release_host;
 	}
 
 	ret = sdio_claim_irq(func, btmrvl_sdio_interrupt);
 	if (ret) {
-		BT_ERR("sdio_claim_irq failed: ret=%d", ret);
+		bt_err("sdio_claim_irq failed: ret=%d\n", ret);
 		ret = -EIO;
 		goto disable_func;
 	}
 
 	ret = sdio_set_block_size(card->func, SDIO_BLOCK_SIZE);
 	if (ret) {
-		BT_ERR("cannot set SDIO block size");
+		bt_err("cannot set SDIO block size\n");
 		ret = -EIO;
 		goto release_irq;
 	}
@@ -823,7 +817,7 @@ static int btmrvl_sdio_host_to_card(struct btmrvl_private *priv,
 	int tmpbufsz;
 
 	if (!card || !card->func) {
-		BT_ERR("card or function is NULL!");
+		bt_err("card or function is NULL!\n");
 		return -EINVAL;
 	}
 
@@ -848,7 +842,7 @@ static int btmrvl_sdio_host_to_card(struct btmrvl_private *priv,
 				   buf_block_len * blksz);
 		if (ret < 0) {
 			i++;
-			BT_ERR("i=%d writesb failed: %d", i, ret);
+			bt_err("i=%d writesb failed: %d\n", i, ret);
 			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
 						payload, nb);
 			ret = -EIO;
@@ -873,7 +867,7 @@ static int btmrvl_sdio_download_fw(struct btmrvl_sdio_card *card)
 	int pollnum = MAX_POLL_TRIES;
 
 	if (!card || !card->func) {
-		BT_ERR("card or function is NULL!");
+		bt_err("card or function is NULL!\n");
 		return -EINVAL;
 	}
 	sdio_claim_host(card->func);
@@ -886,7 +880,7 @@ static int btmrvl_sdio_download_fw(struct btmrvl_sdio_card *card)
 	/* Check if other function driver is downloading the firmware */
 	fws0 = sdio_readb(card->func, card->reg->card_fw_status0, &ret);
 	if (ret) {
-		BT_ERR("Failed to read FW downloading status!");
+		bt_err("Failed to read FW downloading status!\n");
 		ret = -EIO;
 		goto done;
 	}
@@ -899,21 +893,21 @@ static int btmrvl_sdio_download_fw(struct btmrvl_sdio_card *card)
 		if (card->helper) {
 			ret = btmrvl_sdio_download_helper(card);
 			if (ret) {
-				BT_ERR("Failed to download helper!");
+				bt_err("Failed to download helper!\n");
 				ret = -EIO;
 				goto done;
 			}
 		}
 
 		if (btmrvl_sdio_download_fw_w_helper(card)) {
-			BT_ERR("Failed to download firmware!");
+			bt_err("Failed to download firmware!\n");
 			ret = -EIO;
 			goto done;
 		}
 	}
 
 	if (btmrvl_sdio_verify_fw_download(card, pollnum)) {
-		BT_ERR("FW failed to be active in time!");
+		bt_err("FW failed to be active in time!\n");
 		ret = -ETIMEDOUT;
 		goto done;
 	}
@@ -930,7 +924,7 @@ static int btmrvl_sdio_wakeup_fw(struct btmrvl_private *priv)
 	int ret = 0;
 
 	if (!card || !card->func) {
-		BT_ERR("card or function is NULL!");
+		bt_err("card or function is NULL!\n");
 		return -EINVAL;
 	}
 
@@ -952,8 +946,8 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 	struct btmrvl_private *priv = NULL;
 	struct btmrvl_sdio_card *card = NULL;
 
-	BT_INFO("vendor=0x%x, device=0x%x, class=%d, fn=%d",
-			id->vendor, id->device, id->class, func->num);
+	bt_info("vendor=0x%x, device=0x%x, class=%d, fn=%d\n",
+		id->vendor, id->device, id->class, func->num);
 
 	card = kzalloc(sizeof(*card), GFP_KERNEL);
 	if (!card) {
@@ -972,7 +966,7 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 	}
 
 	if (btmrvl_sdio_register_dev(card) < 0) {
-		BT_ERR("Failed to register BT device!");
+		bt_err("Failed to register BT device!\n");
 		ret = -ENODEV;
 		goto free_card;
 	}
@@ -981,7 +975,7 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 	btmrvl_sdio_disable_host_int(card);
 
 	if (btmrvl_sdio_download_fw(card)) {
-		BT_ERR("Downloading firmware failed!");
+		bt_err("Downloading firmware failed!\n");
 		ret = -ENODEV;
 		goto unreg_dev;
 	}
@@ -992,7 +986,7 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 
 	priv = btmrvl_add_card(card);
 	if (!priv) {
-		BT_ERR("Initializing card failed!");
+		bt_err("Initializing card failed!\n");
 		ret = -ENODEV;
 		goto disable_host_int;
 	}
@@ -1005,7 +999,7 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 	priv->hw_process_int_status = btmrvl_sdio_process_int_status;
 
 	if (btmrvl_register_hdev(priv)) {
-		BT_ERR("Register hdev failed!");
+		bt_err("Register hdev failed!\n");
 		ret = -ENODEV;
 		goto disable_host_int;
 	}
@@ -1058,7 +1052,7 @@ static struct sdio_driver bt_mrvl_sdio = {
 static int __init btmrvl_sdio_init_module(void)
 {
 	if (sdio_register_driver(&bt_mrvl_sdio) != 0) {
-		BT_ERR("SDIO Driver Registration Failed");
+		bt_err("SDIO Driver Registration Failed\n");
 		return -ENODEV;
 	}
 
diff --git a/drivers/bluetooth/btsdio.c b/drivers/bluetooth/btsdio.c
index 792e32d..a7368bc 100644
--- a/drivers/bluetooth/btsdio.c
+++ b/drivers/bluetooth/btsdio.c
@@ -389,7 +389,7 @@ static struct sdio_driver btsdio_driver = {
 
 static int __init btsdio_init(void)
 {
-	BT_INFO("Generic Bluetooth SDIO driver ver %s", VERSION);
+	bt_info("Generic Bluetooth SDIO driver ver %s\n", VERSION);
 
 	return sdio_register_driver(&btsdio_driver);
 }
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 200b3a2..ec0a80f 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -131,7 +131,7 @@ static int btuart_write(unsigned int iobase, int fifo_size, __u8 *buf, int len)
 static void btuart_write_wakeup(btuart_info_t *info)
 {
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device\n");
 		return;
 	}
 
@@ -178,7 +178,7 @@ static void btuart_receive(btuart_info_t *info)
 	int boguscount = 0;
 
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device\n");
 		return;
 	}
 
@@ -192,7 +192,7 @@ static void btuart_receive(btuart_info_t *info)
 			info->rx_state = RECV_WAIT_PACKET_TYPE;
 			info->rx_count = 0;
 			if (!(info->rx_skb = bt_skb_alloc(HCI_MAX_FRAME_SIZE, GFP_ATOMIC))) {
-				BT_ERR("Can't allocate mem for new packet");
+				bt_err("Can't allocate mem for new packet\n");
 				return;
 			}
 		}
@@ -221,7 +221,8 @@ static void btuart_receive(btuart_info_t *info)
 
 			default:
 				/* Unknown packet */
-				BT_ERR("Unknown HCI packet with type 0x%02x received", bt_cb(info->rx_skb)->pkt_type);
+				bt_err("Unknown HCI packet with type 0x%02x received\n",
+				       bt_cb(info->rx_skb)->pkt_type);
 				info->hdev->stat.err_rx++;
 				clear_bit(HCI_RUNNING, &(info->hdev->flags));
 
@@ -309,7 +310,7 @@ static irqreturn_t btuart_interrupt(int irq, void *dev_inst)
 
 		switch (iir) {
 		case UART_IIR_RLSI:
-			BT_ERR("RLSI");
+			bt_err("RLSI\n");
 			break;
 		case UART_IIR_RDI:
 			/* Receive interrupt */
@@ -322,7 +323,7 @@ static irqreturn_t btuart_interrupt(int irq, void *dev_inst)
 			}
 			break;
 		default:
-			BT_ERR("Unhandled IIR=%#x", iir);
+			bt_err("Unhandled IIR=%#x\n", iir);
 			break;
 		}
 
@@ -349,7 +350,7 @@ static void btuart_change_speed(btuart_info_t *info, unsigned int speed)
 	int divisor;
 
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device\n");
 		return;
 	}
 
@@ -431,7 +432,7 @@ static int btuart_hci_send_frame(struct sk_buff *skb)
 	struct hci_dev *hdev = (struct hci_dev *)(skb->dev);
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown HCI device (hdev=NULL)");
+		bt_err("Frame for unknown HCI device (hdev=NULL)\n");
 		return -ENODEV;
 	}
 
@@ -491,7 +492,7 @@ static int btuart_open(btuart_info_t *info)
 	/* Initialize HCI device */
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can't allocate HCI device");
+		bt_err("Can't allocate HCI device\n");
 		return -ENOMEM;
 	}
 
@@ -534,7 +535,7 @@ static int btuart_open(btuart_info_t *info)
 
 	/* Register HCI device */
 	if (hci_register_dev(hdev) < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device\n");
 		info->hdev = NULL;
 		hci_free_dev(hdev);
 		return -ENODEV;
@@ -655,7 +656,7 @@ static int btuart_config(struct pcmcia_device *link)
 	if (!pcmcia_loop_config(link, btuart_check_config_notpicky, NULL))
 		goto found_port;
 
-	BT_ERR("No usable port range found");
+	bt_err("No usable port range found\n");
 	goto failed;
 
 found_port:
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index e618cf1..7b7cdc8 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -258,7 +258,7 @@ static void btusb_intr_complete(struct urb *urb)
 		if (hci_recv_fragment(hdev, HCI_EVENT_PKT,
 						urb->transfer_buffer,
 						urb->actual_length) < 0) {
-			BT_ERR("%s corrupted event packet", hdev->name);
+			bt_err("%s corrupted event packet\n", hdev->name);
 			hdev->stat.err_rx++;
 		}
 	}
@@ -274,8 +274,8 @@ static void btusb_intr_complete(struct urb *urb)
 		/* -EPERM: urb is being killed;
 		 * -ENODEV: device got disconnected */
 		if (err != -EPERM && err != -ENODEV)
-			BT_ERR("%s urb %p failed to resubmit (%d)",
-						hdev->name, urb, -err);
+			bt_err("%s urb %p failed to resubmit (%d)\n",
+			       hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
 }
@@ -318,8 +318,8 @@ static int btusb_submit_intr_urb(struct hci_dev *hdev, gfp_t mem_flags)
 	err = usb_submit_urb(urb, mem_flags);
 	if (err < 0) {
 		if (err != -EPERM && err != -ENODEV)
-			BT_ERR("%s urb %p submission failed (%d)",
-						hdev->name, urb, -err);
+			bt_err("%s urb %p submission failed (%d)\n",
+			       hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
 
@@ -346,7 +346,7 @@ static void btusb_bulk_complete(struct urb *urb)
 		if (hci_recv_fragment(hdev, HCI_ACLDATA_PKT,
 						urb->transfer_buffer,
 						urb->actual_length) < 0) {
-			BT_ERR("%s corrupted ACL packet", hdev->name);
+			bt_err("%s corrupted ACL packet\n", hdev->name);
 			hdev->stat.err_rx++;
 		}
 	}
@@ -362,8 +362,8 @@ static void btusb_bulk_complete(struct urb *urb)
 		/* -EPERM: urb is being killed;
 		 * -ENODEV: device got disconnected */
 		if (err != -EPERM && err != -ENODEV)
-			BT_ERR("%s urb %p failed to resubmit (%d)",
-						hdev->name, urb, -err);
+			bt_err("%s urb %p failed to resubmit (%d)\n",
+			       hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
 }
@@ -404,8 +404,8 @@ static int btusb_submit_bulk_urb(struct hci_dev *hdev, gfp_t mem_flags)
 	err = usb_submit_urb(urb, mem_flags);
 	if (err < 0) {
 		if (err != -EPERM && err != -ENODEV)
-			BT_ERR("%s urb %p submission failed (%d)",
-						hdev->name, urb, -err);
+			bt_err("%s urb %p submission failed (%d)\n",
+			       hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
 
@@ -439,7 +439,7 @@ static void btusb_isoc_complete(struct urb *urb)
 			if (hci_recv_fragment(hdev, HCI_SCODATA_PKT,
 						urb->transfer_buffer + offset,
 								length) < 0) {
-				BT_ERR("%s corrupted SCO packet", hdev->name);
+				bt_err("%s corrupted SCO packet\n", hdev->name);
 				hdev->stat.err_rx++;
 			}
 		}
@@ -455,8 +455,8 @@ static void btusb_isoc_complete(struct urb *urb)
 		/* -EPERM: urb is being killed;
 		 * -ENODEV: device got disconnected */
 		if (err != -EPERM && err != -ENODEV)
-			BT_ERR("%s urb %p failed to resubmit (%d)",
-						hdev->name, urb, -err);
+			bt_err("%s urb %p failed to resubmit (%d)\n",
+			       hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
 }
@@ -523,8 +523,8 @@ static int btusb_submit_isoc_urb(struct hci_dev *hdev, gfp_t mem_flags)
 	err = usb_submit_urb(urb, mem_flags);
 	if (err < 0) {
 		if (err != -EPERM && err != -ENODEV)
-			BT_ERR("%s urb %p submission failed (%d)",
-						hdev->name, urb, -err);
+			bt_err("%s urb %p submission failed (%d)\n",
+			       hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
 
@@ -774,8 +774,8 @@ skip_waking:
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
 		if (err != -EPERM && err != -ENODEV)
-			BT_ERR("%s urb %p submission failed (%d)",
-						hdev->name, urb, -err);
+			bt_err("%s urb %p submission failed (%d)\n",
+			       hdev->name, urb, -err);
 		kfree(urb->setup_packet);
 		usb_unanchor_urb(urb);
 	} else {
@@ -820,7 +820,7 @@ static inline int __set_isoc_interface(struct hci_dev *hdev, int altsetting)
 
 	err = usb_set_interface(data->udev, 1, altsetting);
 	if (err < 0) {
-		BT_ERR("%s setting interface failed (%d)", hdev->name, -err);
+		bt_err("%s setting interface failed (%d)\n", hdev->name, -err);
 		return err;
 	}
 
@@ -844,7 +844,7 @@ static inline int __set_isoc_interface(struct hci_dev *hdev, int altsetting)
 	}
 
 	if (!data->isoc_tx_ep || !data->isoc_rx_ep) {
-		BT_ERR("%s invalid SCO descriptors", hdev->name);
+		bt_err("%s invalid SCO descriptors\n", hdev->name);
 		return -ENODEV;
 	}
 
diff --git a/drivers/bluetooth/btwilink.c b/drivers/bluetooth/btwilink.c
index b5f83b4..d69d796 100644
--- a/drivers/bluetooth/btwilink.c
+++ b/drivers/bluetooth/btwilink.c
@@ -113,7 +113,7 @@ static long st_receive(void *priv_data, struct sk_buff *skb)
 	/* Forward skb to HCI core layer */
 	err = hci_recv_frame(skb);
 	if (err < 0) {
-		BT_ERR("Unable to push skb to HCI core(%d)", err);
+		bt_err("Unable to push skb to HCI core(%d)\n", err);
 		return err;
 	}
 
@@ -184,7 +184,7 @@ static int ti_st_open(struct hci_dev *hdev)
 
 		if (err != -EINPROGRESS) {
 			clear_bit(HCI_RUNNING, &hdev->flags);
-			BT_ERR("st_register failed %d", err);
+			bt_err("st_register failed %d\n", err);
 			return err;
 		}
 
@@ -198,9 +198,8 @@ static int ti_st_open(struct hci_dev *hdev)
 			 msecs_to_jiffies(BT_REGISTER_TIMEOUT));
 		if (!timeleft) {
 			clear_bit(HCI_RUNNING, &hdev->flags);
-			BT_ERR("Timeout(%d sec),didn't get reg "
-					"completion signal from ST",
-					BT_REGISTER_TIMEOUT / 1000);
+			bt_err("Timeout(%d sec),didn't get reg completion signal from ST\n",
+			       BT_REGISTER_TIMEOUT / 1000);
 			return -ETIMEDOUT;
 		}
 
@@ -208,22 +207,22 @@ static int ti_st_open(struct hci_dev *hdev)
 		 * called with ERROR status? */
 		if (hst->reg_status != 0) {
 			clear_bit(HCI_RUNNING, &hdev->flags);
-			BT_ERR("ST registration completed with invalid "
-					"status %d", hst->reg_status);
+			bt_err("ST registration completed with invalid status %d\n",
+			       hst->reg_status);
 			return -EAGAIN;
 		}
 
 done:
 		hst->st_write = ti_st_proto[i].write;
 		if (!hst->st_write) {
-			BT_ERR("undefined ST write function");
+			bt_err("undefined ST write function\n");
 			clear_bit(HCI_RUNNING, &hdev->flags);
 			for (i = 0; i < MAX_BT_CHNL_IDS; i++) {
 				/* Undo registration with ST */
 				err = st_unregister(&ti_st_proto[i]);
 				if (err)
-					BT_ERR("st_unregister() failed with "
-							"error %d", err);
+					bt_err("st_unregister() failed with error %d\n",
+					       err);
 				hst->st_write = NULL;
 			}
 			return -EIO;
@@ -244,8 +243,8 @@ static int ti_st_close(struct hci_dev *hdev)
 	for (i = MAX_BT_CHNL_IDS-1; i >= 0; i--) {
 		err = st_unregister(&ti_st_proto[i]);
 		if (err)
-			BT_ERR("st_unregister(%d) failed with error %d",
-					ti_st_proto[i].chnl_id, err);
+			bt_err("st_unregister(%d) failed with error %d\n",
+			       ti_st_proto[i].chnl_id, err);
 	}
 
 	hst->st_write = NULL;
@@ -279,7 +278,7 @@ static int ti_st_send_frame(struct sk_buff *skb)
 	len = hst->st_write(skb);
 	if (len < 0) {
 		kfree_skb(skb);
-		BT_ERR("ST write failed (%ld)", len);
+		bt_err("ST write failed (%ld)\n", len);
 		/* Try Again, would only fail if UART has gone bad */
 		return -EAGAIN;
 	}
@@ -330,7 +329,7 @@ static int bt_ti_probe(struct platform_device *pdev)
 
 	err = hci_register_dev(hdev);
 	if (err < 0) {
-		BT_ERR("Can't register HCI device error %d", err);
+		bt_err("Can't register HCI device error %d\n", err);
 		kfree(hst);
 		hci_free_dev(hdev);
 		return err;
@@ -375,7 +374,7 @@ static struct platform_driver btwilink_driver = {
 /* ------- Module Init/Exit interfaces ------ */
 static int __init btwilink_init(void)
 {
-	BT_INFO("Bluetooth Driver for TI WiLink - Version %s", VERSION);
+	bt_info("Bluetooth Driver for TI WiLink - Version %s\n", VERSION);
 
 	return platform_driver_register(&btwilink_driver);
 }
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 969bb22..88ed345 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -133,7 +133,7 @@ static int dtl1_write(unsigned int iobase, int fifo_size, __u8 *buf, int len)
 static void dtl1_write_wakeup(dtl1_info_t *info)
 {
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device\n");
 		return;
 	}
 
@@ -209,7 +209,7 @@ static void dtl1_receive(dtl1_info_t *info)
 	int boguscount = 0;
 
 	if (!info) {
-		BT_ERR("Unknown device");
+		bt_err("Unknown device\n");
 		return;
 	}
 
@@ -221,7 +221,7 @@ static void dtl1_receive(dtl1_info_t *info)
 		/* Allocate packet */
 		if (info->rx_skb == NULL)
 			if (!(info->rx_skb = bt_skb_alloc(HCI_MAX_FRAME_SIZE, GFP_ATOMIC))) {
-				BT_ERR("Can't allocate mem for new packet");
+				bt_err("Can't allocate mem for new packet\n");
 				info->rx_state = RECV_WAIT_NSH;
 				info->rx_count = NSHL;
 				return;
@@ -266,7 +266,8 @@ static void dtl1_receive(dtl1_info_t *info)
 					break;
 				default:
 					/* unknown packet */
-					BT_ERR("Unknown HCI packet with type 0x%02x received", bt_cb(info->rx_skb)->pkt_type);
+					bt_err("Unknown HCI packet with type 0x%02x received\n",
+					       bt_cb(info->rx_skb)->pkt_type);
 					kfree_skb(info->rx_skb);
 					break;
 				}
@@ -313,7 +314,7 @@ static irqreturn_t dtl1_interrupt(int irq, void *dev_inst)
 
 		switch (iir) {
 		case UART_IIR_RLSI:
-			BT_ERR("RLSI");
+			bt_err("RLSI\n");
 			break;
 		case UART_IIR_RDI:
 			/* Receive interrupt */
@@ -326,7 +327,7 @@ static irqreturn_t dtl1_interrupt(int irq, void *dev_inst)
 			}
 			break;
 		default:
-			BT_ERR("Unhandled IIR=%#x", iir);
+			bt_err("Unhandled IIR=%#x\n", iir);
 			break;
 		}
 
@@ -395,7 +396,7 @@ static int dtl1_hci_send_frame(struct sk_buff *skb)
 	nsh_t nsh;
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown HCI device (hdev=NULL)");
+		bt_err("Frame for unknown HCI device (hdev=NULL)\n");
 		return -ENODEV;
 	}
 
@@ -476,7 +477,7 @@ static int dtl1_open(dtl1_info_t *info)
 	/* Initialize HCI device */
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can't allocate HCI device");
+		bt_err("Can't allocate HCI device\n");
 		return -ENOMEM;
 	}
 
@@ -520,7 +521,7 @@ static int dtl1_open(dtl1_info_t *info)
 
 	/* Register HCI device */
 	if (hci_register_dev(hdev) < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device\n");
 		info->hdev = NULL;
 		hci_free_dev(hdev);
 		return -ENODEV;
diff --git a/drivers/bluetooth/hci_ath.c b/drivers/bluetooth/hci_ath.c
index 4093935..2d025fa 100644
--- a/drivers/bluetooth/hci_ath.c
+++ b/drivers/bluetooth/hci_ath.c
@@ -205,7 +205,7 @@ static int ath_recv(struct hci_uart *hu, void *data, int count)
 
 	ret = hci_recv_stream_fragment(hu->hdev, data, count);
 	if (ret < 0) {
-		BT_ERR("Frame Reassembly Failed");
+		bt_err("Frame Reassembly Failed\n");
 		return ret;
 	}
 
@@ -227,9 +227,9 @@ int __init ath_init(void)
 	int err = hci_uart_register_proto(&athp);
 
 	if (!err)
-		BT_INFO("HCIATH3K protocol initialized");
+		bt_info("HCIATH3K protocol initialized\n");
 	else
-		BT_ERR("HCIATH3K protocol registration failed");
+		bt_err("HCIATH3K protocol registration failed\n");
 
 	return err;
 }
diff --git a/drivers/bluetooth/hci_bcsp.c b/drivers/bluetooth/hci_bcsp.c
index a767d4de..5042daa 100644
--- a/drivers/bluetooth/hci_bcsp.c
+++ b/drivers/bluetooth/hci_bcsp.c
@@ -152,7 +152,7 @@ static int bcsp_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 	struct bcsp_struct *bcsp = hu->priv;
 
 	if (skb->len > 0xFFF) {
-		BT_ERR("Packet too long");
+		bt_err("Packet too long\n");
 		kfree_skb(skb);
 		return 0;
 	}
@@ -168,7 +168,7 @@ static int bcsp_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 		break;
 
 	default:
-		BT_ERR("Unknown packet type");
+		bt_err("Unknown packet type\n");
 		kfree_skb(skb);
 		break;
 	}
@@ -206,7 +206,7 @@ static struct sk_buff *bcsp_prepare_pkt(struct bcsp_struct *bcsp, u8 *data,
 		rel = 0;	/* unreliable channel */
 		break;
 	default:
-		BT_ERR("Unknown packet type");
+		bt_err("Unknown packet type\n");
 		return NULL;
 	}
 
@@ -298,7 +298,7 @@ static struct sk_buff *bcsp_dequeue(struct hci_uart *hu)
 			return nskb;
 		} else {
 			skb_queue_head(&bcsp->unrel, skb);
-			BT_ERR("Could not dequeue pkt because alloc_skb failed");
+			bt_err("Could not dequeue pkt because alloc_skb failed\n");
 		}
 	}
 
@@ -317,7 +317,7 @@ static struct sk_buff *bcsp_dequeue(struct hci_uart *hu)
 			return nskb;
 		} else {
 			skb_queue_head(&bcsp->rel, skb);
-			BT_ERR("Could not dequeue pkt because alloc_skb failed");
+			bt_err("Could not dequeue pkt because alloc_skb failed\n");
 		}
 	}
 
@@ -365,7 +365,7 @@ static void bcsp_pkt_cull(struct bcsp_struct *bcsp)
 	}
 
 	if (bcsp->rxack != seqno)
-		BT_ERR("Peer acked invalid packet");
+		bt_err("Peer acked invalid packet\n");
 
 	BT_DBG("Removing %u pkts out of %u, up to seqno %u",
 	       pkts_to_be_removed, skb_queue_len(&bcsp->unack),
@@ -387,7 +387,8 @@ static void bcsp_pkt_cull(struct bcsp_struct *bcsp)
 	spin_unlock_irqrestore(&bcsp->unack.lock, flags);
 
 	if (i != pkts_to_be_removed)
-		BT_ERR("Removed only %u out of %u pkts", i, pkts_to_be_removed);
+		bt_err("Removed only %u out of %u pkts\n",
+		       i, pkts_to_be_removed);
 }
 
 /* Handle BCSP link-establishment packets. When we
@@ -417,7 +418,7 @@ static void bcsp_handle_le_pkt(struct hci_uart *hu)
 	/* Spot "sync" pkts. If we find one...disaster! */
 	else if (bcsp->rx_skb->data[1] >> 4 == 4 && bcsp->rx_skb->data[2] == 0 &&
 			!memcmp(&bcsp->rx_skb->data[4], sync_pkt, 4)) {
-		BT_ERR("Found a LE sync pkt, card has reset");
+		bt_err("Found a LE sync pkt, card has reset\n");
 	}
 }
 
@@ -461,7 +462,7 @@ static inline void bcsp_unslip_one_byte(struct bcsp_struct *bcsp, unsigned char
 			break;
 
 		default:
-			BT_ERR ("Invalid byte %02x after esc byte", byte);
+			bt_err("Invalid byte %02x after esc byte\n", byte);
 			kfree_skb(bcsp->rx_skb);
 			bcsp->rx_skb = NULL;
 			bcsp->rx_state = BCSP_W4_PKT_DELIMITER;
@@ -524,10 +525,10 @@ static void bcsp_complete_rx_pkt(struct hci_uart *hu)
 
 				hci_recv_frame(bcsp->rx_skb);
 			} else {
-				BT_ERR ("Packet for unknown channel (%u %s)",
-					bcsp->rx_skb->data[1] & 0x0f,
-					bcsp->rx_skb->data[0] & 0x80 ? 
-					"reliable" : "unreliable");
+				bt_err("Packet for unknown channel (%u %s)\n",
+				       bcsp->rx_skb->data[1] & 0x0f,
+				       bcsp->rx_skb->data[0] & 0x80 ?
+				       "reliable" : "unreliable");
 				kfree_skb(bcsp->rx_skb);
 			}
 		} else
@@ -561,7 +562,7 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 	while (count) {
 		if (bcsp->rx_count) {
 			if (*ptr == 0xc0) {
-				BT_ERR("Short BCSP packet");
+				bt_err("Short BCSP packet\n");
 				kfree_skb(bcsp->rx_skb);
 				bcsp->rx_state = BCSP_W4_PKT_START;
 				bcsp->rx_count = 0;
@@ -576,7 +577,7 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 		case BCSP_W4_BCSP_HDR:
 			if ((0xff & (u8) ~ (bcsp->rx_skb->data[0] + bcsp->rx_skb->data[1] +
 					bcsp->rx_skb->data[2])) != bcsp->rx_skb->data[3]) {
-				BT_ERR("Error in BCSP hdr checksum");
+				bt_err("Error in BCSP hdr checksum\n");
 				kfree_skb(bcsp->rx_skb);
 				bcsp->rx_state = BCSP_W4_PKT_DELIMITER;
 				bcsp->rx_count = 0;
@@ -584,8 +585,9 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 			}
 			if (bcsp->rx_skb->data[0] & 0x80	/* reliable pkt */
 			    		&& (bcsp->rx_skb->data[0] & 0x07) != bcsp->rxseq_txack) {
-				BT_ERR ("Out-of-order packet arrived, got %u expected %u",
-					bcsp->rx_skb->data[0] & 0x07, bcsp->rxseq_txack);
+				bt_err("Out-of-order packet arrived, got %u expected %u\n",
+				       bcsp->rx_skb->data[0] & 0x07,
+				       bcsp->rxseq_txack);
 
 				kfree_skb(bcsp->rx_skb);
 				bcsp->rx_state = BCSP_W4_PKT_DELIMITER;
@@ -607,9 +609,9 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 
 		case BCSP_W4_CRC:
 			if (bitrev16(bcsp->message_crc) != bscp_get_crc(bcsp)) {
-				BT_ERR ("Checksum failed: computed %04x received %04x",
-					bitrev16(bcsp->message_crc),
-					bscp_get_crc(bcsp));
+				bt_err("Checksum failed: computed %04x received %04x\n",
+				       bitrev16(bcsp->message_crc),
+				       bscp_get_crc(bcsp));
 
 				kfree_skb(bcsp->rx_skb);
 				bcsp->rx_state = BCSP_W4_PKT_DELIMITER;
@@ -626,7 +628,7 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 				bcsp->rx_state = BCSP_W4_PKT_START;
 				break;
 			default:
-				/*BT_ERR("Ignoring byte %02x", *ptr);*/
+				/*bt_err("Ignoring byte %02x\n", *ptr);*/
 				break;
 			}
 			ptr++; count--;
@@ -650,7 +652,7 @@ static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 
 				bcsp->rx_skb = bt_skb_alloc(0x1005, GFP_ATOMIC);
 				if (!bcsp->rx_skb) {
-					BT_ERR("Can't allocate mem for new packet");
+					bt_err("Can't allocate mem for new packet\n");
 					bcsp->rx_state = BCSP_W4_PKT_DELIMITER;
 					bcsp->rx_count = 0;
 					return 0;
@@ -744,9 +746,9 @@ int __init bcsp_init(void)
 	int err = hci_uart_register_proto(&bcsp);
 
 	if (!err)
-		BT_INFO("HCI BCSP protocol initialized");
+		bt_info("HCI BCSP protocol initialized\n");
 	else
-		BT_ERR("HCI BCSP protocol registration failed");
+		bt_err("HCI BCSP protocol registration failed\n");
 
 	return err;
 }
diff --git a/drivers/bluetooth/hci_h4.c b/drivers/bluetooth/hci_h4.c
index 2fcd8b3..0ffe638 100644
--- a/drivers/bluetooth/hci_h4.c
+++ b/drivers/bluetooth/hci_h4.c
@@ -133,7 +133,7 @@ static inline int h4_check_data_len(struct h4_struct *h4, int len)
 	if (!len) {
 		hci_recv_frame(h4->rx_skb);
 	} else if (len > room) {
-		BT_ERR("Data length is too large");
+		bt_err("Data length is too large\n");
 		kfree_skb(h4->rx_skb);
 	} else {
 		h4->rx_state = H4_W4_DATA;
@@ -155,7 +155,7 @@ static int h4_recv(struct hci_uart *hu, void *data, int count)
 
 	ret = hci_recv_stream_fragment(hu->hdev, data, count);
 	if (ret < 0) {
-		BT_ERR("Frame Reassembly Failed");
+		bt_err("Frame Reassembly Failed\n");
 		return ret;
 	}
 
@@ -183,9 +183,9 @@ int __init h4_init(void)
 	int err = hci_uart_register_proto(&h4p);
 
 	if (!err)
-		BT_INFO("HCI H4 protocol initialized");
+		bt_info("HCI H4 protocol initialized\n");
 	else
-		BT_ERR("HCI H4 protocol registration failed");
+		bt_err("HCI H4 protocol registration failed\n");
 
 	return err;
 }
diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_ldisc.c
index 0711448..c4bd312 100644
--- a/drivers/bluetooth/hci_ldisc.c
+++ b/drivers/bluetooth/hci_ldisc.c
@@ -213,7 +213,7 @@ static int hci_uart_send_frame(struct sk_buff *skb)
 	struct hci_uart *hu;
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown device (hdev=NULL)");
+		bt_err("Frame for unknown device (hdev=NULL)\n");
 		return -ENODEV;
 	}
 
@@ -267,7 +267,7 @@ static int hci_uart_tty_open(struct tty_struct *tty)
 		return -EOPNOTSUPP;
 
 	if (!(hu = kzalloc(sizeof(struct hci_uart), GFP_KERNEL))) {
-		BT_ERR("Can't allocate control structure");
+		bt_err("Can't allocate control structure\n");
 		return -ENFILE;
 	}
 
@@ -384,7 +384,7 @@ static int hci_uart_register_dev(struct hci_uart *hu)
 	/* Initialize and register HCI device */
 	hdev = hci_alloc_dev();
 	if (!hdev) {
-		BT_ERR("Can't allocate HCI device");
+		bt_err("Can't allocate HCI device\n");
 		return -ENOMEM;
 	}
 
@@ -409,7 +409,7 @@ static int hci_uart_register_dev(struct hci_uart *hu)
 		set_bit(HCI_QUIRK_RAW_DEVICE, &hdev->quirks);
 
 	if (hci_register_dev(hdev) < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device\n");
 		hci_free_dev(hdev);
 		return -ENODEV;
 	}
@@ -531,7 +531,7 @@ static int __init hci_uart_init(void)
 	static struct tty_ldisc_ops hci_uart_ldisc;
 	int err;
 
-	BT_INFO("HCI UART driver ver %s", VERSION);
+	bt_info("HCI UART driver ver %s\n", VERSION);
 
 	/* Register the tty discipline */
 
@@ -549,7 +549,7 @@ static int __init hci_uart_init(void)
 	hci_uart_ldisc.owner		= THIS_MODULE;
 
 	if ((err = tty_register_ldisc(N_HCI, &hci_uart_ldisc))) {
-		BT_ERR("HCI line discipline registration failed. (%d)", err);
+		bt_err("HCI line discipline registration failed. (%d)\n", err);
 		return err;
 	}
 
@@ -588,7 +588,7 @@ static void __exit hci_uart_exit(void)
 
 	/* Release tty registration of line discipline */
 	if ((err = tty_unregister_ldisc(N_HCI)))
-		BT_ERR("Can't unregister HCI line discipline (%d)", err);
+		bt_err("Can't unregister HCI line discipline (%d)\n", err);
 }
 
 module_init(hci_uart_init);
diff --git a/drivers/bluetooth/hci_ll.c b/drivers/bluetooth/hci_ll.c
index 7e4b435..7d21082 100644
--- a/drivers/bluetooth/hci_ll.c
+++ b/drivers/bluetooth/hci_ll.c
@@ -102,7 +102,7 @@ static int send_hcill_cmd(u8 cmd, struct hci_uart *hu)
 	/* allocate packet */
 	skb = bt_skb_alloc(1, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("cannot allocate memory for HCILL packet");
+		bt_err("cannot allocate memory for HCILL packet\n");
 		err = -ENOMEM;
 		goto out;
 	}
@@ -219,13 +219,14 @@ static void ll_device_want_to_wakeup(struct hci_uart *hu)
 	case HCILL_ASLEEP:
 		/* acknowledge device wake up */
 		if (send_hcill_cmd(HCILL_WAKE_UP_ACK, hu) < 0) {
-			BT_ERR("cannot acknowledge device wake up");
+			bt_err("cannot acknowledge device wake up\n");
 			goto out;
 		}
 		break;
 	default:
 		/* any other state is illegal */
-		BT_ERR("received HCILL_WAKE_UP_IND in state %ld", ll->hcill_state);
+		bt_err("received HCILL_WAKE_UP_IND in state %ld\n",
+		       ll->hcill_state);
 		break;
 	}
 
@@ -254,11 +255,12 @@ static void ll_device_want_to_sleep(struct hci_uart *hu)
 
 	/* sanity check */
 	if (ll->hcill_state != HCILL_AWAKE)
-		BT_ERR("ERR: HCILL_GO_TO_SLEEP_IND in state %ld", ll->hcill_state);
+		bt_err("ERR: HCILL_GO_TO_SLEEP_IND in state %ld\n",
+		       ll->hcill_state);
 
 	/* acknowledge device sleep */
 	if (send_hcill_cmd(HCILL_GO_TO_SLEEP_ACK, hu) < 0) {
-		BT_ERR("cannot acknowledge device sleep");
+		bt_err("cannot acknowledge device sleep\n");
 		goto out;
 	}
 
@@ -287,7 +289,8 @@ static void ll_device_woke_up(struct hci_uart *hu)
 
 	/* sanity check */
 	if (ll->hcill_state != HCILL_ASLEEP_TO_AWAKE)
-		BT_ERR("received HCILL_WAKE_UP_ACK in state %ld", ll->hcill_state);
+		bt_err("received HCILL_WAKE_UP_ACK in state %ld\n",
+		       ll->hcill_state);
 
 	/* send pending packets and change state to HCILL_AWAKE */
 	__ll_do_awake(ll);
@@ -325,7 +328,7 @@ static int ll_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 		skb_queue_tail(&ll->tx_wait_q, skb);
 		/* awake device */
 		if (send_hcill_cmd(HCILL_WAKE_UP_IND, hu) < 0) {
-			BT_ERR("cannot wake up device");
+			bt_err("cannot wake up device\n");
 			break;
 		}
 		ll->hcill_state = HCILL_ASLEEP_TO_AWAKE;
@@ -336,7 +339,8 @@ static int ll_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 		skb_queue_tail(&ll->tx_wait_q, skb);
 		break;
 	default:
-		BT_ERR("illegal hcill state: %ld (losing packet)", ll->hcill_state);
+		bt_err("illegal hcill state: %ld (losing packet)\n",
+		       ll->hcill_state);
 		kfree_skb(skb);
 		break;
 	}
@@ -355,7 +359,7 @@ static inline int ll_check_data_len(struct ll_struct *ll, int len)
 	if (!len) {
 		hci_recv_frame(ll->rx_skb);
 	} else if (len > room) {
-		BT_ERR("Data length is too large");
+		bt_err("Data length is too large\n");
 		kfree_skb(ll->rx_skb);
 	} else {
 		ll->rx_state = HCILL_W4_DATA;
@@ -460,7 +464,8 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 
 		case HCILL_GO_TO_SLEEP_ACK:
 			/* shouldn't happen */
-			BT_ERR("received HCILL_GO_TO_SLEEP_ACK (in state %ld)", ll->hcill_state);
+			bt_err("received HCILL_GO_TO_SLEEP_ACK (in state %ld)\n",
+			       ll->hcill_state);
 			ptr++; count--;
 			continue;
 
@@ -477,7 +482,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 			continue;
 
 		default:
-			BT_ERR("Unknown HCI packet type %2.2x", (__u8)*ptr);
+			bt_err("Unknown HCI packet type %2.2x\n", (__u8)*ptr);
 			hu->hdev->stat.err_rx++;
 			ptr++; count--;
 			continue;
@@ -488,7 +493,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 		/* Allocate packet */
 		ll->rx_skb = bt_skb_alloc(HCI_MAX_FRAME_SIZE, GFP_ATOMIC);
 		if (!ll->rx_skb) {
-			BT_ERR("Can't allocate mem for new packet");
+			bt_err("Can't allocate mem for new packet\n");
 			ll->rx_state = HCILL_W4_PACKET_TYPE;
 			ll->rx_count = 0;
 			return -ENOMEM;
@@ -522,9 +527,9 @@ int __init ll_init(void)
 	int err = hci_uart_register_proto(&llp);
 
 	if (!err)
-		BT_INFO("HCILL protocol initialized");
+		bt_info("HCILL protocol initialized\n");
 	else
-		BT_ERR("HCILL protocol registration failed");
+		bt_err("HCILL protocol registration failed\n");
 
 	return err;
 }
diff --git a/drivers/bluetooth/hci_vhci.c b/drivers/bluetooth/hci_vhci.c
index 2ed6ab1..291406c 100644
--- a/drivers/bluetooth/hci_vhci.c
+++ b/drivers/bluetooth/hci_vhci.c
@@ -86,7 +86,7 @@ static int vhci_send_frame(struct sk_buff *skb)
 	struct vhci_data *data;
 
 	if (!hdev) {
-		BT_ERR("Frame for unknown HCI device (hdev=NULL)");
+		bt_err("Frame for unknown HCI device (hdev=NULL)\n");
 		return -ENODEV;
 	}
 
@@ -253,7 +253,7 @@ static int vhci_open(struct inode *inode, struct file *file)
 	hdev->owner = THIS_MODULE;
 
 	if (hci_register_dev(hdev) < 0) {
-		BT_ERR("Can't register HCI device");
+		bt_err("Can't register HCI device\n");
 		kfree(data);
 		hci_free_dev(hdev);
 		return -EBUSY;
@@ -295,7 +295,7 @@ static struct miscdevice vhci_miscdev= {
 
 static int __init vhci_init(void)
 {
-	BT_INFO("Virtual HCI driver ver %s", VERSION);
+	bt_info("Virtual HCI driver ver %s\n", VERSION);
 
 	return misc_register(&vhci_miscdev);
 }
diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index abaad6e..f3d1990 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -109,11 +109,10 @@ struct bt_power {
  */
 #define BT_CHANNEL_POLICY_AMP_PREFERRED		2
 
-__printf(2, 3)
-int bt_printk(const char *level, const char *fmt, ...);
-
-#define BT_INFO(fmt, arg...)   bt_printk(KERN_INFO, pr_fmt(fmt), ##arg)
-#define BT_ERR(fmt, arg...)    bt_printk(KERN_ERR, pr_fmt(fmt), ##arg)
+__printf(1, 2)
+int bt_info(const char *fmt, ...);
+__printf(1, 2)
+int bt_err(const char *fmt, ...);
 #define BT_DBG(fmt, arg...)    pr_debug(fmt "\n", ##arg)
 
 /* Connection and socket states */
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index ea9231f..2a3cec5 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -691,7 +691,7 @@ static inline int hci_proto_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr,
 		return sco_connect_ind(hdev, bdaddr);
 
 	default:
-		BT_ERR("unknown link type %d", type);
+		bt_err("unknown link type %d\n", type);
 		return -EINVAL;
 	}
 }
@@ -710,7 +710,7 @@ static inline void hci_proto_connect_cfm(struct hci_conn *conn, __u8 status)
 		break;
 
 	default:
-		BT_ERR("unknown link type %d", conn->type);
+		bt_err("unknown link type %d\n", conn->type);
 		break;
 	}
 
@@ -740,7 +740,7 @@ static inline void hci_proto_disconn_cfm(struct hci_conn *conn, __u8 reason)
 		break;
 
 	default:
-		BT_ERR("unknown link type %d", conn->type);
+		bt_err("unknown link type %d\n", conn->type);
 		break;
 	}
 
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index ef92864..47226f2 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -554,7 +554,7 @@ static int __init bt_init(void)
 {
 	int err;
 
-	BT_INFO("Core ver %s", VERSION);
+	bt_info("Core ver %s\n", VERSION);
 
 	err = bt_sysfs_init();
 	if (err < 0)
@@ -566,7 +566,7 @@ static int __init bt_init(void)
 		return err;
 	}
 
-	BT_INFO("HCI device and connection manager initialized");
+	bt_info("HCI device and connection manager initialized\n");
 
 	err = hci_sock_init();
 	if (err < 0)
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index a779ec7..a98306e 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -718,9 +718,9 @@ static int __init bnep_init(void)
 	strcat(flt, "multicast");
 #endif
 
-	BT_INFO("BNEP (Ethernet Emulation) ver %s", VERSION);
+	bt_info("BNEP (Ethernet Emulation) ver %s\n", VERSION);
 	if (flt[0])
-		BT_INFO("BNEP filters: %s", flt);
+		bt_info("BNEP filters: %s\n", flt);
 
 	bnep_sock_init();
 	return 0;
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index bc40864..32c8204 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -70,7 +70,7 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 	size = sizeof(*r) + (BNEP_MAX_MULTICAST_FILTERS + 1) * ETH_ALEN * 2;
 	skb  = alloc_skb(size, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("%s Multicast list allocation failed", dev->name);
+		bt_err("%s Multicast list allocation failed\n", dev->name);
 		return;
 	}
 
diff --git a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
index 17800b1..916af88 100644
--- a/net/bluetooth/bnep/sock.c
+++ b/net/bluetooth/bnep/sock.c
@@ -245,7 +245,7 @@ int __init bnep_sock_init(void)
 	return 0;
 
 error:
-	BT_ERR("Can't register BNEP socket");
+	bt_err("Can't register BNEP socket\n");
 	proto_unregister(&bnep_proto);
 	return err;
 }
@@ -253,7 +253,7 @@ error:
 void __exit bnep_sock_cleanup(void)
 {
 	if (bt_sock_unregister(BTPROTO_BNEP) < 0)
-		BT_ERR("Can't unregister BNEP socket");
+		bt_err("Can't unregister BNEP socket\n");
 
 	proto_unregister(&bnep_proto);
 }
diff --git a/net/bluetooth/cmtp/capi.c b/net/bluetooth/cmtp/capi.c
index 50f0d13..b60e817 100644
--- a/net/bluetooth/cmtp/capi.c
+++ b/net/bluetooth/cmtp/capi.c
@@ -158,7 +158,7 @@ static void cmtp_send_interopmsg(struct cmtp_session *session,
 
 	skb = alloc_skb(CAPI_MSG_BASELEN + 6 + len, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("Can't allocate memory for interoperability packet");
+		bt_err("Can't allocate memory for interoperability packet\n");
 		return;
 	}
 
@@ -352,7 +352,7 @@ void cmtp_recv_capimsg(struct cmtp_session *session, struct sk_buff *skb)
 		appl = application->appl;
 		CAPIMSG_SETAPPID(skb->data, appl);
 	} else {
-		BT_ERR("Can't find application with id %d", appl);
+		bt_err("Can't find application with id %d\n", appl);
 		kfree_skb(skb);
 		return;
 	}
@@ -363,7 +363,7 @@ void cmtp_recv_capimsg(struct cmtp_session *session, struct sk_buff *skb)
 	}
 
 	if (!ctrl) {
-		BT_ERR("Can't find controller %d for message", session->num);
+		bt_err("Can't find controller %d for message\n", session->num);
 		kfree_skb(skb);
 		return;
 	}
@@ -404,7 +404,7 @@ static void cmtp_register_appl(struct capi_ctr *ctrl, __u16 appl, capi_register_
 
 	application = cmtp_application_add(session, appl);
 	if (!application) {
-		BT_ERR("Can't allocate memory for new application");
+		bt_err("Can't allocate memory for new application\n");
 		return;
 	}
 
@@ -468,7 +468,7 @@ static void cmtp_release_appl(struct capi_ctr *ctrl, __u16 appl)
 
 	application = cmtp_application_get(session, CMTP_APPLID, appl);
 	if (!application) {
-		BT_ERR("Can't find application");
+		bt_err("Can't find application\n");
 		return;
 	}
 
@@ -497,7 +497,7 @@ static u16 cmtp_send_message(struct capi_ctr *ctrl, struct sk_buff *skb)
 
 	application = cmtp_application_get(session, CMTP_APPLID, appl);
 	if ((!application) || (application->state != BT_CONNECTED)) {
-		BT_ERR("Can't find application with id %d", appl);
+		bt_err("Can't find application with id %d\n", appl);
 		return CAPI_ILLAPPNR;
 	}
 
@@ -565,7 +565,8 @@ int cmtp_attach_device(struct cmtp_session *session)
 	ret = wait_event_interruptible_timeout(session->wait,
 			session->ncontroller, CMTP_INTEROP_TIMEOUT);
 
-	BT_INFO("Found %d CAPI controller(s) on device %s", session->ncontroller, session->name);
+	bt_info("Found %d CAPI controller(s) on device %s\n",
+		session->ncontroller, session->name);
 
 	if (!ret)
 		return -ETIMEDOUT;
@@ -574,7 +575,7 @@ int cmtp_attach_device(struct cmtp_session *session)
 		return -ENODEV;
 
 	if (session->ncontroller > 1)
-		BT_INFO("Setting up only CAPI controller 1");
+		bt_info("Setting up only CAPI controller 1\n");
 
 	session->ctrl.owner      = THIS_MODULE;
 	session->ctrl.driverdata = session;
@@ -591,7 +592,7 @@ int cmtp_attach_device(struct cmtp_session *session)
 	session->ctrl.proc_fops = &cmtp_proc_fops;
 
 	if (attach_capi_ctr(&session->ctrl) < 0) {
-		BT_ERR("Can't attach new controller");
+		bt_err("Can't attach new controller\n");
 		return -EBUSY;
 	}
 
diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
index 6c9c1fd..b170dbe 100644
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -114,7 +114,7 @@ static inline void cmtp_add_msgpart(struct cmtp_session *session, int id, const
 
 	nskb = alloc_skb(size, GFP_ATOMIC);
 	if (!nskb) {
-		BT_ERR("Can't allocate memory for CAPI message");
+		bt_err("Can't allocate memory for CAPI message\n");
 		return;
 	}
 
@@ -158,7 +158,7 @@ static inline int cmtp_recv_frame(struct cmtp_session *session, struct sk_buff *
 		BT_DBG("hdr 0x%02x hdrlen %d len %d id %d", hdr, hdrlen, len, id);
 
 		if (hdrlen + len > skb->len) {
-			BT_ERR("Wrong size or header information in CMTP frame");
+			bt_err("Wrong size or header information in CMTP frame\n");
 			break;
 		}
 
@@ -216,7 +216,7 @@ static void cmtp_process_transmit(struct cmtp_session *session)
 
 	nskb = alloc_skb(session->mtu, GFP_ATOMIC);
 	if (!nskb) {
-		BT_ERR("Can't allocate memory for new frame");
+		bt_err("Can't allocate memory for new frame\n");
 		return;
 	}
 
@@ -478,7 +478,7 @@ int cmtp_get_conninfo(struct cmtp_conninfo *ci)
 
 static int __init cmtp_init(void)
 {
-	BT_INFO("CMTP (CAPI Emulation) ver %s", VERSION);
+	bt_info("CMTP (CAPI Emulation) ver %s\n", VERSION);
 
 	cmtp_init_sockets();
 
diff --git a/net/bluetooth/cmtp/sock.c b/net/bluetooth/cmtp/sock.c
index 3f2dd5c..921f045 100644
--- a/net/bluetooth/cmtp/sock.c
+++ b/net/bluetooth/cmtp/sock.c
@@ -239,7 +239,7 @@ int cmtp_init_sockets(void)
 	return 0;
 
 error:
-	BT_ERR("Can't register CMTP socket");
+	bt_err("Can't register CMTP socket\n");
 	proto_unregister(&cmtp_proto);
 	return err;
 }
@@ -247,7 +247,7 @@ error:
 void cmtp_cleanup_sockets(void)
 {
 	if (bt_sock_unregister(BTPROTO_CMTP) < 0)
-		BT_ERR("Can't unregister CMTP socket");
+		bt_err("Can't unregister CMTP socket\n");
 
 	proto_unregister(&cmtp_proto);
 }
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 9de9371..89bf2ac 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -278,7 +278,7 @@ static void hci_init_req(struct hci_dev *hdev, unsigned long opt)
 		break;
 
 	default:
-		BT_ERR("Unknown device type %d", hdev->dev_type);
+		bt_err("Unknown device type %d\n", hdev->dev_type);
 		break;
 	}
 
@@ -1233,7 +1233,7 @@ static void hci_cmd_timer(unsigned long arg)
 {
 	struct hci_dev *hdev = (void *) arg;
 
-	BT_ERR("%s command tx timeout", hdev->name);
+	bt_err("%s command tx timeout\n", hdev->name);
 	atomic_set(&hdev->cmd_cnt, 1);
 	queue_work(hdev->workqueue, &hdev->cmd_work);
 }
@@ -1885,7 +1885,7 @@ int hci_send_cmd(struct hci_dev *hdev, __u16 opcode, __u32 plen, void *param)
 
 	skb = bt_skb_alloc(len, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("%s no memory for command", hdev->name);
+		bt_err("%s no memory for command\n", hdev->name);
 		return -ENOMEM;
 	}
 
@@ -2072,7 +2072,7 @@ static inline struct hci_conn *hci_low_sent(struct hci_dev *hdev, __u8 type, int
 			break;
 		default:
 			cnt = 0;
-			BT_ERR("Unknown link type");
+			bt_err("Unknown link type\n");
 		}
 
 		q = cnt / num;
@@ -2089,15 +2089,15 @@ static inline void hci_link_tx_to(struct hci_dev *hdev, __u8 type)
 	struct hci_conn_hash *h = &hdev->conn_hash;
 	struct hci_conn *c;
 
-	BT_ERR("%s link tx timeout", hdev->name);
+	bt_err("%s link tx timeout\n", hdev->name);
 
 	rcu_read_lock();
 
 	/* Kill stalled connections */
 	list_for_each_entry_rcu(c, &h->list, list) {
 		if (c->type == type && c->sent) {
-			BT_ERR("%s killing stalled connection %s",
-				hdev->name, batostr(&c->dst));
+			bt_err("%s killing stalled connection %s\n",
+			       hdev->name, batostr(&c->dst));
 			hci_acl_disconn(c, 0x13);
 		}
 	}
@@ -2175,7 +2175,7 @@ static inline struct hci_chan *hci_chan_sent(struct hci_dev *hdev, __u8 type,
 		break;
 	default:
 		cnt = 0;
-		BT_ERR("Unknown link type");
+		bt_err("Unknown link type\n");
 	}
 
 	q = cnt / num;
@@ -2435,8 +2435,8 @@ static inline void hci_acldata_packet(struct hci_dev *hdev, struct sk_buff *skb)
 		l2cap_recv_acldata(conn, skb, flags);
 		return;
 	} else {
-		BT_ERR("%s ACL packet for unknown connection handle %d",
-			hdev->name, handle);
+		bt_err("%s ACL packet for unknown connection handle %d\n",
+		       hdev->name, handle);
 	}
 
 	kfree_skb(skb);
@@ -2466,8 +2466,8 @@ static inline void hci_scodata_packet(struct hci_dev *hdev, struct sk_buff *skb)
 		sco_recv_scodata(conn, skb);
 		return;
 	} else {
-		BT_ERR("%s SCO packet for unknown connection handle %d",
-			hdev->name, handle);
+		bt_err("%s SCO packet for unknown connection handle %d\n",
+		       hdev->name, handle);
 	}
 
 	kfree_skb(skb);
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 001307f..f78d608 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -1058,7 +1058,7 @@ static void hci_cc_le_set_scan_enable(struct hci_dev *hdev,
 		break;
 
 	default:
-		BT_ERR("Used reserved LE_Scan_Enable param %d", cp->enable);
+		bt_err("Used reserved LE_Scan_Enable param %d\n", cp->enable);
 		break;
 	}
 }
@@ -1156,7 +1156,7 @@ static inline void hci_cs_create_conn(struct hci_dev *hdev, __u8 status)
 				conn->out = 1;
 				conn->link_mode |= HCI_LM_MASTER;
 			} else
-				BT_ERR("No memory for new connection");
+				bt_err("No memory for new connection\n");
 		}
 	}
 
@@ -1480,7 +1480,7 @@ static void hci_cs_le_create_conn(struct hci_dev *hdev, __u8 status)
 				conn->dst_type = cp->peer_addr_type;
 				conn->out = 1;
 			} else {
-				BT_ERR("No memory for new connection");
+				bt_err("No memory for new connection\n");
 			}
 		}
 	}
@@ -1647,7 +1647,7 @@ static inline void hci_conn_request_evt(struct hci_dev *hdev, struct sk_buff *sk
 		if (!conn) {
 			conn = hci_conn_add(hdev, ev->link_type, &ev->bdaddr);
 			if (!conn) {
-				BT_ERR("No memory for new connection");
+				bt_err("No memory for new connection\n");
 				hci_dev_unlock(hdev);
 				return;
 			}
@@ -1744,7 +1744,7 @@ static inline void hci_auth_complete_evt(struct hci_dev *hdev, struct sk_buff *s
 	if (!ev->status) {
 		if (!(conn->ssp_mode > 0 && hdev->ssp_mode > 0) &&
 				test_bit(HCI_CONN_REAUTH_PEND,	&conn->pend)) {
-			BT_INFO("re-auth of legacy device is not possible.");
+			bt_info("re-auth of legacy device is not possible\n");
 		} else {
 			conn->link_mode |= HCI_LM_AUTH;
 			conn->sec_level = conn->pending_sec_level;
@@ -2272,7 +2272,7 @@ static inline void hci_num_comp_pkts_evt(struct hci_dev *hdev, struct sk_buff *s
 	int i;
 
 	if (hdev->flow_ctl_mode != HCI_FLOW_CTL_MODE_PACKET_BASED) {
-		BT_ERR("Wrong event for mode %d", hdev->flow_ctl_mode);
+		bt_err("Wrong event for mode %d\n", hdev->flow_ctl_mode);
 		return;
 	}
 
@@ -2324,7 +2324,7 @@ static inline void hci_num_comp_pkts_evt(struct hci_dev *hdev, struct sk_buff *s
 			break;
 
 		default:
-			BT_ERR("Unknown type %d conn %p", conn->type, conn);
+			bt_err("Unknown type %d conn %p\n", conn->type, conn);
 			break;
 		}
 	}
@@ -3003,7 +3003,7 @@ static inline void hci_le_conn_complete_evt(struct hci_dev *hdev, struct sk_buff
 	if (!conn) {
 		conn = hci_conn_add(hdev, LE_LINK, &ev->bdaddr);
 		if (!conn) {
-			BT_ERR("No memory for new connection");
+			bt_err("No memory for new connection\n");
 			hci_dev_unlock(hdev);
 			return;
 		}
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 0dcc962..15edd1f 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -808,12 +808,12 @@ int __init hci_sock_init(void)
 
 	hci_register_notifier(&hci_sock_nblock);
 
-	BT_INFO("HCI socket layer initialized");
+	bt_info("HCI socket layer initialized\n");
 
 	return 0;
 
 error:
-	BT_ERR("HCI socket registration failed");
+	bt_err("HCI socket registration failed\n");
 	proto_unregister(&hci_sk_proto);
 	return err;
 }
@@ -821,7 +821,7 @@ error:
 void hci_sock_cleanup(void)
 {
 	if (bt_sock_unregister(BTPROTO_HCI) < 0)
-		BT_ERR("HCI socket unregistration failed");
+		bt_err("HCI socket unregistration failed\n");
 
 	hci_unregister_notifier(&hci_sock_nblock);
 
diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index 5210956..11e23eb 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -123,7 +123,7 @@ void hci_conn_add_sysfs(struct hci_conn *conn)
 	dev_set_drvdata(&conn->dev, conn);
 
 	if (device_add(&conn->dev) < 0) {
-		BT_ERR("Failed to register connection device");
+		bt_err("Failed to register connection device\n");
 		return;
 	}
 
diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index d478be1..098383a 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -158,7 +158,7 @@ static int hidp_queue_event(struct hidp_session *session, struct input_dev *dev,
 
 	skb = alloc_skb(3, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("Can't allocate memory for new frame");
+		bt_err("Can't allocate memory for new frame\n");
 		return -ENOMEM;
 	}
 
@@ -211,14 +211,16 @@ static void hidp_input_report(struct hidp_session *session, struct sk_buff *skb)
 				if (hidp_keycode[keys[i]])
 					input_report_key(dev, hidp_keycode[keys[i]], 0);
 				else
-					BT_ERR("Unknown key (scancode %#x) released.", keys[i]);
+					bt_err("Unknown key (scancode %#x) released\n",
+					       keys[i]);
 			}
 
 			if (udata[i] > 3 && memscan(keys + 2, udata[i], 6) == keys + 8) {
 				if (hidp_keycode[udata[i]])
 					input_report_key(dev, hidp_keycode[udata[i]], 1);
 				else
-					BT_ERR("Unknown key (scancode %#x) pressed.", udata[i]);
+					bt_err("Unknown key (scancode %#x) pressed\n",
+					       udata[i]);
 			}
 		}
 
@@ -255,7 +257,7 @@ static int __hidp_send_ctrl_message(struct hidp_session *session,
 
 	skb = alloc_skb(size + 1, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("Can't allocate memory for new frame");
+		bt_err("Can't allocate memory for new frame\n");
 		return -ENOMEM;
 	}
 
@@ -289,7 +291,7 @@ static int hidp_queue_report(struct hidp_session *session,
 
 	skb = alloc_skb(size + 1, GFP_ATOMIC);
 	if (!skb) {
-		BT_ERR("Can't allocate memory for new frame");
+		bt_err("Can't allocate memory for new frame\n");
 		return -ENOMEM;
 	}
 
@@ -1209,7 +1211,7 @@ static int __init hidp_init(void)
 {
 	int ret;
 
-	BT_INFO("HIDP (Human Interface Emulation) ver %s", VERSION);
+	bt_info("HIDP (Human Interface Emulation) ver %s\n", VERSION);
 
 	ret = hid_register_driver(&hidp_driver);
 	if (ret)
diff --git a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
index 178ac7f..fbaaf1f 100644
--- a/net/bluetooth/hidp/sock.c
+++ b/net/bluetooth/hidp/sock.c
@@ -291,7 +291,7 @@ int __init hidp_init_sockets(void)
 	return 0;
 
 error:
-	BT_ERR("Can't register HIDP socket");
+	bt_err("Can't register HIDP socket\n");
 	proto_unregister(&hidp_proto);
 	return err;
 }
@@ -299,7 +299,7 @@ error:
 void __exit hidp_cleanup_sockets(void)
 {
 	if (bt_sock_unregister(BTPROTO_HIDP) < 0)
-		BT_ERR("Can't unregister HIDP socket");
+		bt_err("Can't unregister HIDP socket\n");
 
 	proto_unregister(&hidp_proto);
 }
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index faf0b11..0ce48f4 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -2551,7 +2551,7 @@ static void l2cap_conf_rfc_get(struct l2cap_chan *chan, void *rsp, int len)
 	rfc.monitor_timeout = cpu_to_le16(L2CAP_DEFAULT_MONITOR_TO);
 	rfc.max_pdu_size = cpu_to_le16(chan->imtu);
 
-	BT_ERR("Expected RFC option was not found, using defaults");
+	bt_err("Expected RFC option was not found, using defaults\n");
 
 done:
 	switch (rfc.mode) {
@@ -3454,7 +3454,7 @@ static inline int l2cap_bredr_sig_cmd(struct l2cap_conn *conn,
 		break;
 
 	default:
-		BT_ERR("Unknown BR/EDR signaling command 0x%2.2x", cmd->code);
+		bt_err("Unknown BR/EDR signaling command 0x%2.2x\n", cmd->code);
 		err = -EINVAL;
 		break;
 	}
@@ -3476,7 +3476,7 @@ static inline int l2cap_le_sig_cmd(struct l2cap_conn *conn,
 		return 0;
 
 	default:
-		BT_ERR("Unknown LE signaling command 0x%2.2x", cmd->code);
+		bt_err("Unknown LE signaling command 0x%2.2x\n", cmd->code);
 		return -EINVAL;
 	}
 }
@@ -3514,7 +3514,7 @@ static inline void l2cap_sig_channel(struct l2cap_conn *conn,
 		if (err) {
 			struct l2cap_cmd_rej_unk rej;
 
-			BT_ERR("Wrong link type (%d)", err);
+			bt_err("Wrong link type (%d)\n", err);
 
 			/* FIXME: Map err to a valid reason */
 			rej.reason = cpu_to_le16(L2CAP_REJ_NOT_UNDERSTOOD);
@@ -4186,7 +4186,7 @@ static int l2cap_ertm_data_rcv(struct sock *sk, struct sk_buff *skb)
 		l2cap_data_channel_iframe(chan, control, skb);
 	} else {
 		if (len != 0) {
-			BT_ERR("%d", len);
+			bt_err("%d\n", len);
 			l2cap_send_disconn_req(chan->conn, chan, ECONNRESET);
 			goto drop;
 		}
@@ -4606,7 +4606,7 @@ int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 flags)
 		int len;
 
 		if (conn->rx_len) {
-			BT_ERR("Unexpected start frame (len %d)", skb->len);
+			bt_err("Unexpected start frame (len %d)\n", skb->len);
 			kfree_skb(conn->rx_skb);
 			conn->rx_skb = NULL;
 			conn->rx_len = 0;
@@ -4615,7 +4615,7 @@ int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 flags)
 
 		/* Start fragment always begin with Basic L2CAP header */
 		if (skb->len < L2CAP_HDR_SIZE) {
-			BT_ERR("Frame is too short (len %d)", skb->len);
+			bt_err("Frame is too short (len %d)\n", skb->len);
 			l2cap_conn_unreliable(conn, ECOMM);
 			goto drop;
 		}
@@ -4633,8 +4633,8 @@ int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 flags)
 		BT_DBG("Start: total len %d, frag len %d", len, skb->len);
 
 		if (skb->len > len) {
-			BT_ERR("Frame is too long (len %d, expected len %d)",
-				skb->len, len);
+			bt_err("Frame is too long (len %d, expected len %d)\n",
+			       skb->len, len);
 			l2cap_conn_unreliable(conn, ECOMM);
 			goto drop;
 		}
@@ -4645,9 +4645,8 @@ int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 flags)
 			struct sock *sk = chan->sk;
 
 			if (chan->imtu < len - L2CAP_HDR_SIZE) {
-				BT_ERR("Frame exceeding recv MTU (len %d, "
-							"MTU %d)", len,
-							chan->imtu);
+				bt_err("Frame exceeding recv MTU (len %d, MTU %d)\n",
+				       len, chan->imtu);
 				release_sock(sk);
 				l2cap_conn_unreliable(conn, ECOMM);
 				goto drop;
@@ -4667,14 +4666,15 @@ int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 flags)
 		BT_DBG("Cont: frag len %d (expecting %d)", skb->len, conn->rx_len);
 
 		if (!conn->rx_len) {
-			BT_ERR("Unexpected continuation frame (len %d)", skb->len);
+			bt_err("Unexpected continuation frame (len %d)\n",
+			       skb->len);
 			l2cap_conn_unreliable(conn, ECOMM);
 			goto drop;
 		}
 
 		if (skb->len > conn->rx_len) {
-			BT_ERR("Fragment is too long (len %d, expected %d)",
-					skb->len, conn->rx_len);
+			bt_err("Fragment is too long (len %d, expected %d)\n",
+			       skb->len, conn->rx_len);
 			kfree_skb(conn->rx_skb);
 			conn->rx_skb = NULL;
 			conn->rx_len = 0;
@@ -4746,7 +4746,7 @@ int __init l2cap_init(void)
 		l2cap_debugfs = debugfs_create_file("l2cap", 0444,
 					bt_debugfs, NULL, &l2cap_debugfs_fops);
 		if (!l2cap_debugfs)
-			BT_ERR("Failed to create L2CAP debug file");
+			bt_err("Failed to create L2CAP debug file\n");
 	}
 
 	return 0;
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index c61d967..6740ea5 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -1084,12 +1084,12 @@ int __init l2cap_init_sockets(void)
 	if (err < 0)
 		goto error;
 
-	BT_INFO("L2CAP socket layer initialized");
+	bt_info("L2CAP socket layer initialized\n");
 
 	return 0;
 
 error:
-	BT_ERR("L2CAP socket registration failed");
+	bt_err("L2CAP socket registration failed\n");
 	proto_unregister(&l2cap_proto);
 	return err;
 }
@@ -1097,7 +1097,7 @@ error:
 void l2cap_cleanup_sockets(void)
 {
 	if (bt_sock_unregister(BTPROTO_L2CAP) < 0)
-		BT_ERR("L2CAP socket unregistration failed");
+		bt_err("L2CAP socket unregistration failed\n");
 
 	proto_unregister(&l2cap_proto);
 }
diff --git a/net/bluetooth/lib.c b/net/bluetooth/lib.c
index 86a6bed..66cc5ce 100644
--- a/net/bluetooth/lib.c
+++ b/net/bluetooth/lib.c
@@ -151,7 +151,7 @@ int bt_to_errno(__u16 code)
 }
 EXPORT_SYMBOL(bt_to_errno);
 
-int bt_printk(const char *level, const char *format, ...)
+int bt_info(const char *format, ...)
 {
 	struct va_format vaf;
 	va_list args;
@@ -162,10 +162,29 @@ int bt_printk(const char *level, const char *format, ...)
 	vaf.fmt = format;
 	vaf.va = &args;
 
-	r = printk("%sBluetooth: %pV\n", level, &vaf);
+	r = printk(KERN_INFO "Bluetooth: %pV", &vaf);
 
 	va_end(args);
 
 	return r;
 }
-EXPORT_SYMBOL(bt_printk);
+EXPORT_SYMBOL(bt_info);
+
+int bt_err(const char *format, ...)
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
+	r = printk(KERN_ERR "Bluetooth: %pV\n", &vaf);
+
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(bt_err);
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index bc8e59d..2ef9c26 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -1057,8 +1057,8 @@ static int load_link_keys(struct sock *sk, u16 index, unsigned char *data,
 	expected_len = sizeof(*cp) + key_count *
 					sizeof(struct mgmt_link_key_info);
 	if (expected_len != len) {
-		BT_ERR("load_link_keys: expected %u bytes, got %u bytes",
-							len, expected_len);
+		bt_err("load_link_keys: expected %u bytes, got %u bytes\n",
+		       len, expected_len);
 		return cmd_status(sk, index, MGMT_OP_LOAD_LINK_KEYS,
 						MGMT_STATUS_INVALID_PARAMS);
 	}
@@ -1366,7 +1366,7 @@ static int pin_code_reply(struct sock *sk, u16 index, unsigned char *data,
 	if (conn->pending_sec_level == BT_SECURITY_HIGH && cp->pin_len != 16) {
 		bacpy(&ncp.bdaddr, &cp->bdaddr);
 
-		BT_ERR("PIN code is not 16 bytes long");
+		bt_err("PIN code is not 16 bytes long\n");
 
 		err = send_pin_code_neg_reply(sk, index, hdev, &ncp);
 		if (err >= 0)
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 501649b..5b846ce 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -1620,7 +1620,7 @@ static int rfcomm_recv_mcc(struct rfcomm_session *s, struct sk_buff *skb)
 		break;
 
 	default:
-		BT_ERR("Unknown control type 0x%02x", type);
+		bt_err("Unknown control type 0x%02x\n", type);
 		rfcomm_send_nsc(s, cr, type);
 		break;
 	}
@@ -1673,7 +1673,7 @@ static int rfcomm_recv_frame(struct rfcomm_session *s, struct sk_buff *skb)
 	fcs = *(u8 *)skb_tail_pointer(skb);
 
 	if (__check_fcs(skb->data, type, fcs)) {
-		BT_ERR("bad checksum in packet");
+		bt_err("bad checksum in packet\n");
 		kfree_skb(skb);
 		return -EILSEQ;
 	}
@@ -1711,7 +1711,7 @@ static int rfcomm_recv_frame(struct rfcomm_session *s, struct sk_buff *skb)
 		break;
 
 	default:
-		BT_ERR("Unknown packet type 0x%02x", type);
+		bt_err("Unknown packet type 0x%02x\n", type);
 		break;
 	}
 	kfree_skb(skb);
@@ -1988,7 +1988,7 @@ static int rfcomm_add_listener(bdaddr_t *ba)
 	/* Create socket */
 	err = rfcomm_l2sock_create(&sock);
 	if (err < 0) {
-		BT_ERR("Create socket failed %d", err);
+		bt_err("Create socket failed %d\n", err);
 		return err;
 	}
 
@@ -1999,7 +1999,7 @@ static int rfcomm_add_listener(bdaddr_t *ba)
 	addr.l2_cid    = 0;
 	err = kernel_bind(sock, (struct sockaddr *) &addr, sizeof(addr));
 	if (err < 0) {
-		BT_ERR("Bind failed %d", err);
+		bt_err("Bind failed %d\n", err);
 		goto failed;
 	}
 
@@ -2012,7 +2012,7 @@ static int rfcomm_add_listener(bdaddr_t *ba)
 	/* Start listening on the socket */
 	err = kernel_listen(sock, 10);
 	if (err) {
-		BT_ERR("Listen failed %d", err);
+		bt_err("Listen failed %d\n", err);
 		goto failed;
 	}
 
@@ -2177,7 +2177,7 @@ static int __init rfcomm_init(void)
 		rfcomm_dlc_debugfs = debugfs_create_file("rfcomm_dlc", 0444,
 				bt_debugfs, NULL, &rfcomm_dlc_debugfs_fops);
 		if (!rfcomm_dlc_debugfs)
-			BT_ERR("Failed to create RFCOMM debug file");
+			bt_err("Failed to create RFCOMM debug file\n");
 	}
 
 	err = rfcomm_init_ttys();
@@ -2188,7 +2188,7 @@ static int __init rfcomm_init(void)
 	if (err < 0)
 		goto cleanup;
 
-	BT_INFO("RFCOMM ver %s", VERSION);
+	bt_info("RFCOMM ver %s\n", VERSION);
 
 	return 0;
 
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index f066678..41b0745 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -1052,15 +1052,15 @@ int __init rfcomm_init_sockets(void)
 		rfcomm_sock_debugfs = debugfs_create_file("rfcomm", 0444,
 				bt_debugfs, NULL, &rfcomm_sock_debugfs_fops);
 		if (!rfcomm_sock_debugfs)
-			BT_ERR("Failed to create RFCOMM debug file");
+			bt_err("Failed to create RFCOMM debug file\n");
 	}
 
-	BT_INFO("RFCOMM socket layer initialized");
+	bt_info("RFCOMM socket layer initialized\n");
 
 	return 0;
 
 error:
-	BT_ERR("RFCOMM socket layer registration failed");
+	bt_err("RFCOMM socket layer registration failed\n");
 	proto_unregister(&rfcomm_proto);
 	return err;
 }
@@ -1070,7 +1070,7 @@ void __exit rfcomm_cleanup_sockets(void)
 	debugfs_remove(rfcomm_sock_debugfs);
 
 	if (bt_sock_unregister(BTPROTO_RFCOMM) < 0)
-		BT_ERR("RFCOMM socket layer unregistration failed");
+		bt_err("RFCOMM socket layer unregistration failed\n");
 
 	proto_unregister(&rfcomm_proto);
 }
diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index a2d4f51..6c3f3b8 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -306,10 +306,10 @@ out:
 	dev_set_drvdata(dev->tty_dev, dev);
 
 	if (device_create_file(dev->tty_dev, &dev_attr_address) < 0)
-		BT_ERR("Failed to create address attribute");
+		bt_err("Failed to create address attribute\n");
 
 	if (device_create_file(dev->tty_dev, &dev_attr_channel) < 0)
-		BT_ERR("Failed to create channel attribute");
+		bt_err("Failed to create channel attribute\n");
 
 	return dev->id;
 
@@ -846,23 +846,23 @@ static int rfcomm_tty_ioctl(struct tty_struct *tty, unsigned int cmd, unsigned l
 		break;
 
 	case TIOCGSERIAL:
-		BT_ERR("TIOCGSERIAL is not supported");
+		bt_err("TIOCGSERIAL is not supported\n");
 		return -ENOIOCTLCMD;
 
 	case TIOCSSERIAL:
-		BT_ERR("TIOCSSERIAL is not supported");
+		bt_err("TIOCSSERIAL is not supported\n");
 		return -ENOIOCTLCMD;
 
 	case TIOCSERGSTRUCT:
-		BT_ERR("TIOCSERGSTRUCT is not supported");
+		bt_err("TIOCSERGSTRUCT is not supported\n");
 		return -ENOIOCTLCMD;
 
 	case TIOCSERGETLSR:
-		BT_ERR("TIOCSERGETLSR is not supported");
+		bt_err("TIOCSERGETLSR is not supported\n");
 		return -ENOIOCTLCMD;
 
 	case TIOCSERCONFIG:
-		BT_ERR("TIOCSERCONFIG is not supported");
+		bt_err("TIOCSERCONFIG is not supported\n");
 		return -ENOIOCTLCMD;
 
 	default:
@@ -1172,12 +1172,12 @@ int __init rfcomm_init_ttys(void)
 
 	error = tty_register_driver(rfcomm_tty_driver);
 	if (error) {
-		BT_ERR("Can't register RFCOMM TTY driver");
+		bt_err("Can't register RFCOMM TTY driver\n");
 		put_tty_driver(rfcomm_tty_driver);
 		return error;
 	}
 
-	BT_INFO("RFCOMM TTY layer initialized");
+	bt_info("RFCOMM TTY layer initialized\n");
 
 	return 0;
 }
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 8bf26d1..1b70109 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -1027,7 +1027,7 @@ int __init sco_init(void)
 
 	err = bt_sock_register(BTPROTO_SCO, &sco_sock_family_ops);
 	if (err < 0) {
-		BT_ERR("SCO socket registration failed");
+		bt_err("SCO socket registration failed\n");
 		goto error;
 	}
 
@@ -1035,10 +1035,10 @@ int __init sco_init(void)
 		sco_debugfs = debugfs_create_file("sco", 0444,
 					bt_debugfs, NULL, &sco_debugfs_fops);
 		if (!sco_debugfs)
-			BT_ERR("Failed to create SCO debug file");
+			bt_err("Failed to create SCO debug file\n");
 	}
 
-	BT_INFO("SCO socket layer initialized");
+	bt_info("SCO socket layer initialized\n");
 
 	return 0;
 
@@ -1052,7 +1052,7 @@ void __exit sco_exit(void)
 	debugfs_remove(sco_debugfs);
 
 	if (bt_sock_unregister(BTPROTO_SCO) < 0)
-		BT_ERR("SCO socket unregistration failed");
+		bt_err("SCO socket unregistration failed\n");
 
 	proto_unregister(&sco_proto);
 }
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 32c47de..a92a606 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -53,7 +53,7 @@ static int smp_e(struct crypto_blkcipher *tfm, const u8 *k, u8 *r)
 	unsigned char iv[128];
 
 	if (tfm == NULL) {
-		BT_ERR("tfm %p", tfm);
+		bt_err("tfm %p\n", tfm);
 		return -EINVAL;
 	}
 
@@ -62,7 +62,7 @@ static int smp_e(struct crypto_blkcipher *tfm, const u8 *k, u8 *r)
 
 	err = crypto_blkcipher_setkey(tfm, k, 16);
 	if (err) {
-		BT_ERR("cipher setkey failed: %d", err);
+		bt_err("cipher setkey failed: %d\n", err);
 		return err;
 	}
 
@@ -76,7 +76,7 @@ static int smp_e(struct crypto_blkcipher *tfm, const u8 *k, u8 *r)
 
 	err = crypto_blkcipher_encrypt(&desc, &sg, &sg, 16);
 	if (err)
-		BT_ERR("Encrypt data error %d", err);
+		bt_err("Encrypt data error %d\n", err);
 
 	return err;
 }
@@ -108,7 +108,7 @@ static int smp_c1(struct crypto_blkcipher *tfm, u8 k[16], u8 r[16],
 	/* res = e(k, res) */
 	err = smp_e(tfm, k, res);
 	if (err) {
-		BT_ERR("Encrypt data error");
+		bt_err("Encrypt data error\n");
 		return err;
 	}
 
@@ -118,7 +118,7 @@ static int smp_c1(struct crypto_blkcipher *tfm, u8 k[16], u8 r[16],
 	/* res = e(k, res) */
 	err = smp_e(tfm, k, res);
 	if (err)
-		BT_ERR("Encrypt data error");
+		bt_err("Encrypt data error\n");
 
 	return err;
 }
@@ -134,7 +134,7 @@ static int smp_s1(struct crypto_blkcipher *tfm, u8 k[16],
 
 	err = smp_e(tfm, k, _r);
 	if (err)
-		BT_ERR("Encrypt data error");
+		bt_err("Encrypt data error\n");
 
 	return err;
 }
@@ -431,7 +431,7 @@ static void random_work(struct work_struct *work)
 	swap128(res, confirm);
 
 	if (memcmp(smp->pcnf, confirm, sizeof(smp->pcnf)) != 0) {
-		BT_ERR("Pairing failed (confirmation values mismatch)");
+		bt_err("Pairing failed (confirmation values mismatch)\n");
 		reason = SMP_CONFIRM_FAILED;
 		goto error;
 	}
-- 
1.7.8.111.gad25c.dirty
