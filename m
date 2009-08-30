From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 43/47] Bluetooth: Add USB autosuspend support to btusb driver
Date: Sun, 30 Aug 2009 01:50:57 -0700
Message-ID: <7bee549e197c9c0e92b89857a409675c1d5e9dff.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
 <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
 <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
 <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
 <dcf47f3bc798888f9ea40b9f626d669dc62086bf.1251621661.git.marcel@holtmann.org>
 <9666fb356da78a5ec28403197d72e8cd6aa16424.1251621661.git.marcel@holtmann.org>
 <60dee5ccd789ee8a380eee802b6cb24c52123428.1251621661.git.marcel@holtmann.org>
 <91d697302b291205171840bfe84c1563e171acb2.1251621661.git.marcel@holtmann.org>
 <e0721f99ba33d13a88746732be2d74ca805abf55.1251621661.git.marcel@holtmann.org>
 <9374253ffe609f2d70dd5ae280182cb6f08fef08.1251621661.git.marcel@holtmann.org>
 <3318b2362bf0528be77123c480249663557dfbfc.1251621661.git.marcel@holtmann.org>
 <5959809ded86e267c1a95fb44738a224c30d3434.1251621661.git.marcel@holtmann.org>
 <a6a67efd7088702fdbbb780c5a3f8e1a74e77b63.1251621661.git.marcel@holtmann.org>
 <52d18347dfb61519aa0f58fe1759edd3ad8c4e36.1251621661.git.marcel@holtmann.org>
 <44dd46de325c4d47abfd1361e5d84a548edb8e42.1251621661.git.marcel@holtmann.org>
 <c6b03cf986eab00e20d0dbc852b233bb83472138.1251621661.git.marcel@holtmann.org>
 <65c7c4918450f8c4545ccb02a9c7a3d77e073535.1251621661.git.marcel@holtmann.org>
 <f2fcfcd670257236ebf2088bbdf26f6a8ef459fe.1251621661.git.marcel@holtmann.org>
 <22121fc9152ca8f25a2d790860832ccb6a414c4d.1251621661.git.marcel@holtmann.org>
 <1c2acffb76d4bc5fd27c4ea55cc27ad8ead10f9a.1251621661.git.marcel@holtmann.org>
 <c74e560cd0101455f1889515e1527e4c2e266113.1251621661.git.marcel@holtmann.org>
 <30afb5b2aa83adf4f69e5090d48e1bb04b64c58a.1251621661.git.marcel@holtmann.org>
 <e90bac061b17cd81bd0df30606c64f4543bf5ca0.1251621661.git.marcel@holtmann.org>
 <6840ed0770d79b9bb0800e5e026a067040ef18f5.1251621661.git.marcel@holtmann.org>
 <fcc203c30d72dde82692f6b761a80e5ca5fdd8fa.1251621661.git.marcel@holtmann.org>
 <8f17154f1f70fcc6faa31ac82164fcf7f0599f38.1251621661.git.marcel@holtmann.org>
 <ef54fd937fbd5ebaeb023818524565bd526a5f36.1251621661.git.marcel@holtmann.org>
 <9e726b17422bade75fba94e625cd35fd1353e682.1251621661.git.marcel@holtmann.org>
 <e686219a64fee9be9ce438dc3f040cd71ddd168a.1251621661.git.marcel@holtmann.org>
 <1b7bf4edca0fdbad70c44e139f4cfebd6759de81.1251621661.git.marcel@holtmann.org>
 <d2e353f7c3c5fbb3add0341c10ae167ee745d23b.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53339 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317AbZH3Iwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:42 -0400
In-Reply-To: <d2e353f7c3c5fbb3add0341c10ae167ee745d23b.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>

This patch adds support of USB autosuspend to the btusb driver.

If the device doesn't support remote wakeup, simple support based on
up/down is provided. If the device supports remote wakeup, additional
support for autosuspend while the interface is up is provided. This is
done by queueing URBs in an anchor structure and waking the device up
from a work queue on sending. Reception triggers remote wakeup.

The last busy facility of the USB autosuspend code is used. To close
a race between autosuspend and transmission, a counter of ongoing
transmissions is maintained.

Add #ifdefs for CONFIG_PM as necessary.

Signed-off-by: Oliver Neukum <oliver@neukum.org>
Tested-by: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btusb.c |  194 ++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 174 insertions(+), 20 deletions(-)

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 124db8c..7ba91aa 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -35,7 +35,7 @@
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
 
-#define VERSION "0.5"
+#define VERSION "0.6"
 
 static int ignore_dga;
 static int ignore_csr;
@@ -145,6 +145,7 @@ static struct usb_device_id blacklist_table[] = {
 #define BTUSB_INTR_RUNNING	0
 #define BTUSB_BULK_RUNNING	1
 #define BTUSB_ISOC_RUNNING	2
+#define BTUSB_SUSPENDING	3
 
 struct btusb_data {
 	struct hci_dev       *hdev;
@@ -157,11 +158,15 @@ struct btusb_data {
 	unsigned long flags;
 
 	struct work_struct work;
+	struct work_struct waker;
 
 	struct usb_anchor tx_anchor;
 	struct usb_anchor intr_anchor;
 	struct usb_anchor bulk_anchor;
 	struct usb_anchor isoc_anchor;
+	struct usb_anchor deferred;
+	int tx_in_flight;
+	spinlock_t txlock;
 
 	struct usb_endpoint_descriptor *intr_ep;
 	struct usb_endpoint_descriptor *bulk_tx_ep;
@@ -174,8 +179,23 @@ struct btusb_data {
 	unsigned int sco_num;
 	int isoc_altsetting;
 	int suspend_count;
+	int did_iso_resume:1;
 };
 
+static int inc_tx(struct btusb_data *data)
+{
+	unsigned long flags;
+	int rv;
+
+	spin_lock_irqsave(&data->txlock, flags);
+	rv = test_bit(BTUSB_SUSPENDING, &data->flags);
+	if (!rv)
+		data->tx_in_flight++;
+	spin_unlock_irqrestore(&data->txlock, flags);
+
+	return rv;
+}
+
 static void btusb_intr_complete(struct urb *urb)
 {
 	struct hci_dev *hdev = urb->context;
@@ -202,6 +222,7 @@ static void btusb_intr_complete(struct urb *urb)
 	if (!test_bit(BTUSB_INTR_RUNNING, &data->flags))
 		return;
 
+	usb_mark_last_busy(data->udev);
 	usb_anchor_urb(urb, &data->intr_anchor);
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
@@ -325,6 +346,7 @@ static int btusb_submit_bulk_urb(struct hci_dev *hdev, gfp_t mem_flags)
 
 	urb->transfer_flags |= URB_FREE_BUFFER;
 
+	usb_mark_last_busy(data->udev);
 	usb_anchor_urb(urb, &data->bulk_anchor);
 
 	err = usb_submit_urb(urb, mem_flags);
@@ -463,6 +485,33 @@ static void btusb_tx_complete(struct urb *urb)
 {
 	struct sk_buff *skb = urb->context;
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
+	struct btusb_data *data = hdev->driver_data;
+
+	BT_DBG("%s urb %p status %d count %d", hdev->name,
+					urb, urb->status, urb->actual_length);
+
+	if (!test_bit(HCI_RUNNING, &hdev->flags))
+		goto done;
+
+	if (!urb->status)
+		hdev->stat.byte_tx += urb->transfer_buffer_length;
+	else
+		hdev->stat.err_tx++;
+
+done:
+	spin_lock(&data->txlock);
+	data->tx_in_flight--;
+	spin_unlock(&data->txlock);
+
+	kfree(urb->setup_packet);
+
+	kfree_skb(skb);
+}
+
+static void btusb_isoc_tx_complete(struct urb *urb)
+{
+	struct sk_buff *skb = urb->context;
+	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 
 	BT_DBG("%s urb %p status %d count %d", hdev->name,
 					urb, urb->status, urb->actual_length);
@@ -488,11 +537,17 @@ static int btusb_open(struct hci_dev *hdev)
 
 	BT_DBG("%s", hdev->name);
 
+	err = usb_autopm_get_interface(data->intf);
+	if (err < 0)
+		return err;
+
+	data->intf->needs_remote_wakeup = 1;
+
 	if (test_and_set_bit(HCI_RUNNING, &hdev->flags))
-		return 0;
+		goto done;
 
 	if (test_and_set_bit(BTUSB_INTR_RUNNING, &data->flags))
-		return 0;
+		goto done;
 
 	err = btusb_submit_intr_urb(hdev, GFP_KERNEL);
 	if (err < 0)
@@ -507,17 +562,28 @@ static int btusb_open(struct hci_dev *hdev)
 	set_bit(BTUSB_BULK_RUNNING, &data->flags);
 	btusb_submit_bulk_urb(hdev, GFP_KERNEL);
 
+done:
+	usb_autopm_put_interface(data->intf);
 	return 0;
 
 failed:
 	clear_bit(BTUSB_INTR_RUNNING, &data->flags);
 	clear_bit(HCI_RUNNING, &hdev->flags);
+	usb_autopm_put_interface(data->intf);
 	return err;
 }
 
+static void btusb_stop_traffic(struct btusb_data *data)
+{
+	usb_kill_anchored_urbs(&data->intr_anchor);
+	usb_kill_anchored_urbs(&data->bulk_anchor);
+	usb_kill_anchored_urbs(&data->isoc_anchor);
+}
+
 static int btusb_close(struct hci_dev *hdev)
 {
 	struct btusb_data *data = hdev->driver_data;
+	int err;
 
 	BT_DBG("%s", hdev->name);
 
@@ -527,13 +593,16 @@ static int btusb_close(struct hci_dev *hdev)
 	cancel_work_sync(&data->work);
 
 	clear_bit(BTUSB_ISOC_RUNNING, &data->flags);
-	usb_kill_anchored_urbs(&data->isoc_anchor);
-
 	clear_bit(BTUSB_BULK_RUNNING, &data->flags);
-	usb_kill_anchored_urbs(&data->bulk_anchor);
-
 	clear_bit(BTUSB_INTR_RUNNING, &data->flags);
-	usb_kill_anchored_urbs(&data->intr_anchor);
+
+	btusb_stop_traffic(data);
+	err = usb_autopm_get_interface(data->intf);
+	if (err < 0)
+		return 0;
+
+	data->intf->needs_remote_wakeup = 0;
+	usb_autopm_put_interface(data->intf);
 
 	return 0;
 }
@@ -620,7 +689,7 @@ static int btusb_send_frame(struct sk_buff *skb)
 		urb->dev      = data->udev;
 		urb->pipe     = pipe;
 		urb->context  = skb;
-		urb->complete = btusb_tx_complete;
+		urb->complete = btusb_isoc_tx_complete;
 		urb->interval = data->isoc_tx_ep->bInterval;
 
 		urb->transfer_flags  = URB_ISO_ASAP;
@@ -631,12 +700,21 @@ static int btusb_send_frame(struct sk_buff *skb)
 				le16_to_cpu(data->isoc_tx_ep->wMaxPacketSize));
 
 		hdev->stat.sco_tx++;
-		break;
+		goto skip_waking;
 
 	default:
 		return -EILSEQ;
 	}
 
+	err = inc_tx(data);
+	if (err) {
+		usb_anchor_urb(urb, &data->deferred);
+		schedule_work(&data->waker);
+		err = 0;
+		goto done;
+	}
+
+skip_waking:
 	usb_anchor_urb(urb, &data->tx_anchor);
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
@@ -644,10 +722,13 @@ static int btusb_send_frame(struct sk_buff *skb)
 		BT_ERR("%s urb %p submission failed", hdev->name, urb);
 		kfree(urb->setup_packet);
 		usb_unanchor_urb(urb);
+	} else {
+		usb_mark_last_busy(data->udev);
 	}
 
 	usb_free_urb(urb);
 
+done:
 	return err;
 }
 
@@ -719,8 +800,19 @@ static void btusb_work(struct work_struct *work)
 {
 	struct btusb_data *data = container_of(work, struct btusb_data, work);
 	struct hci_dev *hdev = data->hdev;
+	int err;
 
 	if (hdev->conn_hash.sco_num > 0) {
+		if (!data->did_iso_resume) {
+			err = usb_autopm_get_interface(data->isoc);
+			if (err < 0) {
+				clear_bit(BTUSB_ISOC_RUNNING, &data->flags);
+				usb_kill_anchored_urbs(&data->isoc_anchor);
+				return;
+			}
+
+			data->did_iso_resume = 1;
+		}
 		if (data->isoc_altsetting != 2) {
 			clear_bit(BTUSB_ISOC_RUNNING, &data->flags);
 			usb_kill_anchored_urbs(&data->isoc_anchor);
@@ -740,9 +832,25 @@ static void btusb_work(struct work_struct *work)
 		usb_kill_anchored_urbs(&data->isoc_anchor);
 
 		__set_isoc_interface(hdev, 0);
+		if (data->did_iso_resume) {
+			data->did_iso_resume = 0;
+			usb_autopm_put_interface(data->isoc);
+		}
 	}
 }
 
+static void btusb_waker(struct work_struct *work)
+{
+	struct btusb_data *data = container_of(work, struct btusb_data, waker);
+	int err;
+
+	err = usb_autopm_get_interface(data->intf);
+	if (err < 0)
+		return;
+
+	usb_autopm_put_interface(data->intf);
+}
+
 static int btusb_probe(struct usb_interface *intf,
 				const struct usb_device_id *id)
 {
@@ -812,11 +920,14 @@ static int btusb_probe(struct usb_interface *intf,
 	spin_lock_init(&data->lock);
 
 	INIT_WORK(&data->work, btusb_work);
+	INIT_WORK(&data->waker, btusb_waker);
+	spin_lock_init(&data->txlock);
 
 	init_usb_anchor(&data->tx_anchor);
 	init_usb_anchor(&data->intr_anchor);
 	init_usb_anchor(&data->bulk_anchor);
 	init_usb_anchor(&data->isoc_anchor);
+	init_usb_anchor(&data->deferred);
 
 	hdev = hci_alloc_dev();
 	if (!hdev) {
@@ -941,6 +1052,7 @@ static void btusb_disconnect(struct usb_interface *intf)
 	hci_free_dev(hdev);
 }
 
+#ifdef CONFIG_PM
 static int btusb_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct btusb_data *data = usb_get_intfdata(intf);
@@ -950,22 +1062,44 @@ static int btusb_suspend(struct usb_interface *intf, pm_message_t message)
 	if (data->suspend_count++)
 		return 0;
 
+	spin_lock_irq(&data->txlock);
+	if (!(interface_to_usbdev(intf)->auto_pm && data->tx_in_flight)) {
+		set_bit(BTUSB_SUSPENDING, &data->flags);
+		spin_unlock_irq(&data->txlock);
+	} else {
+		spin_unlock_irq(&data->txlock);
+		data->suspend_count--;
+		return -EBUSY;
+	}
+
 	cancel_work_sync(&data->work);
 
+	btusb_stop_traffic(data);
 	usb_kill_anchored_urbs(&data->tx_anchor);
 
-	usb_kill_anchored_urbs(&data->isoc_anchor);
-	usb_kill_anchored_urbs(&data->bulk_anchor);
-	usb_kill_anchored_urbs(&data->intr_anchor);
-
 	return 0;
 }
 
+static void play_deferred(struct btusb_data *data)
+{
+	struct urb *urb;
+	int err;
+
+	while ((urb = usb_get_from_anchor(&data->deferred))) {
+		err = usb_submit_urb(urb, GFP_ATOMIC);
+		if (err < 0)
+			break;
+
+		data->tx_in_flight++;
+	}
+	usb_scuttle_anchored_urbs(&data->deferred);
+}
+
 static int btusb_resume(struct usb_interface *intf)
 {
 	struct btusb_data *data = usb_get_intfdata(intf);
 	struct hci_dev *hdev = data->hdev;
-	int err;
+	int err = 0;
 
 	BT_DBG("intf %p", intf);
 
@@ -973,13 +1107,13 @@ static int btusb_resume(struct usb_interface *intf)
 		return 0;
 
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
-		return 0;
+		goto done;
 
 	if (test_bit(BTUSB_INTR_RUNNING, &data->flags)) {
 		err = btusb_submit_intr_urb(hdev, GFP_NOIO);
 		if (err < 0) {
 			clear_bit(BTUSB_INTR_RUNNING, &data->flags);
-			return err;
+			goto failed;
 		}
 	}
 
@@ -987,9 +1121,10 @@ static int btusb_resume(struct usb_interface *intf)
 		err = btusb_submit_bulk_urb(hdev, GFP_NOIO);
 		if (err < 0) {
 			clear_bit(BTUSB_BULK_RUNNING, &data->flags);
-			return err;
-		} else
-			btusb_submit_bulk_urb(hdev, GFP_NOIO);
+			goto failed;
+		}
+
+		btusb_submit_bulk_urb(hdev, GFP_NOIO);
 	}
 
 	if (test_bit(BTUSB_ISOC_RUNNING, &data->flags)) {
@@ -999,16 +1134,35 @@ static int btusb_resume(struct usb_interface *intf)
 			btusb_submit_isoc_urb(hdev, GFP_NOIO);
 	}
 
+	spin_lock_irq(&data->txlock);
+	play_deferred(data);
+	clear_bit(BTUSB_SUSPENDING, &data->flags);
+	spin_unlock_irq(&data->txlock);
+	schedule_work(&data->work);
+
 	return 0;
+
+failed:
+	usb_scuttle_anchored_urbs(&data->deferred);
+done:
+	spin_lock_irq(&data->txlock);
+	clear_bit(BTUSB_SUSPENDING, &data->flags);
+	spin_unlock_irq(&data->txlock);
+
+	return err;
 }
+#endif
 
 static struct usb_driver btusb_driver = {
 	.name		= "btusb",
 	.probe		= btusb_probe,
 	.disconnect	= btusb_disconnect,
+#ifdef CONFIG_PM
 	.suspend	= btusb_suspend,
 	.resume		= btusb_resume,
+#endif
 	.id_table	= btusb_table,
+	.supports_autosuspend = 1,
 };
 
 static int __init btusb_init(void)
-- 
1.6.2.5

