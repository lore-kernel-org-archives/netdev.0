From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 4/9] Bluetooth: Convert controller hdev->type to hdev->bus
Date: Sat, 27 Feb 2010 23:38:33 +0100
Message-ID: <c13854cef4751000b968d4e8ac95796562d5b96f.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
 <8e5b2308489dbca27c104fc6a557d4c9348552e5.1267276098.git.marcel@holtmann.org>
 <8978111e2d148f75bd5e329a14600feadc567381.1267276098.git.marcel@holtmann.org>
 <10f7891f998e84acfa31ac9c5a0fea052c39ecb8.1267276098.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54694 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936365Ab0B0WkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 17:40:20 -0500
In-Reply-To: <10f7891f998e84acfa31ac9c5a0fea052c39ecb8.1267276098.git.marcel@holtmann.org>
In-Reply-To: <cover.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hdev->type is misnamed and should be actually hdev->bus instead. So
convert it now.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/bfusb.c        |    2 +-
 drivers/bluetooth/bluecard_cs.c  |    2 +-
 drivers/bluetooth/bpa10x.c       |    2 +-
 drivers/bluetooth/bt3c_cs.c      |    2 +-
 drivers/bluetooth/btmrvl_main.c  |    2 +-
 drivers/bluetooth/btsdio.c       |    2 +-
 drivers/bluetooth/btuart_cs.c    |    2 +-
 drivers/bluetooth/btusb.c        |    2 +-
 drivers/bluetooth/dtl1_cs.c      |    2 +-
 drivers/bluetooth/hci_ldisc.c    |    2 +-
 drivers/bluetooth/hci_vhci.c     |    2 +-
 include/net/bluetooth/hci.h      |    2 +-
 include/net/bluetooth/hci_core.h |    2 +-
 net/bluetooth/hci_core.c         |    8 ++++----
 net/bluetooth/hci_sysfs.c        |   16 ++++++++--------
 15 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/bluetooth/bfusb.c b/drivers/bluetooth/bfusb.c
index 2a00707..005919a 100644
--- a/drivers/bluetooth/bfusb.c
+++ b/drivers/bluetooth/bfusb.c
@@ -703,7 +703,7 @@ static int bfusb_probe(struct usb_interface *intf, const struct usb_device_id *i
 
 	data->hdev = hdev;
 
-	hdev->type = HCI_USB;
+	hdev->bus = HCI_USB;
 	hdev->driver_data = data;
 	SET_HCIDEV_DEV(hdev, &intf->dev);
 
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index c2cf811..d9bf87c 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -736,7 +736,7 @@ static int bluecard_open(bluecard_info_t *info)
 
 	info->hdev = hdev;
 
-	hdev->type = HCI_PCCARD;
+	hdev->bus = HCI_PCCARD;
 	hdev->driver_data = info;
 	SET_HCIDEV_DEV(hdev, &info->p_dev->dev);
 
diff --git a/drivers/bluetooth/bpa10x.c b/drivers/bluetooth/bpa10x.c
index c115285..d945cd1 100644
--- a/drivers/bluetooth/bpa10x.c
+++ b/drivers/bluetooth/bpa10x.c
@@ -469,7 +469,7 @@ static int bpa10x_probe(struct usb_interface *intf, const struct usb_device_id *
 		return -ENOMEM;
 	}
 
-	hdev->type = HCI_USB;
+	hdev->bus = HCI_USB;
 	hdev->driver_data = data;
 
 	data->hdev = hdev;
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 9f5926a..027cb8b 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -582,7 +582,7 @@ static int bt3c_open(bt3c_info_t *info)
 
 	info->hdev = hdev;
 
-	hdev->type = HCI_PCCARD;
+	hdev->bus = HCI_PCCARD;
 	hdev->driver_data = info;
 	SET_HCIDEV_DEV(hdev, &info->p_dev->dev);
 
diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index f97771c..53a43ad 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -563,7 +563,7 @@ struct btmrvl_private *btmrvl_add_card(void *card)
 
 	priv->btmrvl_dev.tx_dnld_rdy = true;
 
-	hdev->type = HCI_SDIO;
+	hdev->bus = HCI_SDIO;
 	hdev->open = btmrvl_open;
 	hdev->close = btmrvl_close;
 	hdev->flush = btmrvl_flush;
diff --git a/drivers/bluetooth/btsdio.c b/drivers/bluetooth/btsdio.c
index 7e29827..76e5127 100644
--- a/drivers/bluetooth/btsdio.c
+++ b/drivers/bluetooth/btsdio.c
@@ -326,7 +326,7 @@ static int btsdio_probe(struct sdio_func *func,
 		return -ENOMEM;
 	}
 
-	hdev->type = HCI_SDIO;
+	hdev->bus = HCI_SDIO;
 	hdev->driver_data = data;
 
 	data->hdev = hdev;
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 91c5230..60c0953 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -500,7 +500,7 @@ static int btuart_open(btuart_info_t *info)
 
 	info->hdev = hdev;
 
-	hdev->type = HCI_PCCARD;
+	hdev->bus = HCI_PCCARD;
 	hdev->driver_data = info;
 	SET_HCIDEV_DEV(hdev, &info->p_dev->dev);
 
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index a699f09..5d9cc53 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -939,7 +939,7 @@ static int btusb_probe(struct usb_interface *intf,
 		return -ENOMEM;
 	}
 
-	hdev->type = HCI_USB;
+	hdev->bus = HCI_USB;
 	hdev->driver_data = data;
 
 	data->hdev = hdev;
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 6975919..1778831 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -485,7 +485,7 @@ static int dtl1_open(dtl1_info_t *info)
 
 	info->hdev = hdev;
 
-	hdev->type = HCI_PCCARD;
+	hdev->bus = HCI_PCCARD;
 	hdev->driver_data = info;
 	SET_HCIDEV_DEV(hdev, &info->p_dev->dev);
 
diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_ldisc.c
index aa09193..76a1abb 100644
--- a/drivers/bluetooth/hci_ldisc.c
+++ b/drivers/bluetooth/hci_ldisc.c
@@ -383,7 +383,7 @@ static int hci_uart_register_dev(struct hci_uart *hu)
 
 	hu->hdev = hdev;
 
-	hdev->type = HCI_UART;
+	hdev->bus = HCI_UART;
 	hdev->driver_data = hu;
 
 	hdev->open  = hci_uart_open;
diff --git a/drivers/bluetooth/hci_vhci.c b/drivers/bluetooth/hci_vhci.c
index 7595274..bb0aefd 100644
--- a/drivers/bluetooth/hci_vhci.c
+++ b/drivers/bluetooth/hci_vhci.c
@@ -236,7 +236,7 @@ static int vhci_open(struct inode *inode, struct file *file)
 
 	data->hdev = hdev;
 
-	hdev->type = HCI_VIRTUAL;
+	hdev->bus = HCI_VIRTUAL;
 	hdev->driver_data = data;
 
 	hdev->open     = vhci_open_dev;
diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
index ed3aea1..3350a66 100644
--- a/include/net/bluetooth/hci.h
+++ b/include/net/bluetooth/hci.h
@@ -43,7 +43,7 @@
 #define HCI_NOTIFY_CONN_DEL		2
 #define HCI_NOTIFY_VOICE_SETTING	3
 
-/* HCI device types */
+/* HCI bus types */
 #define HCI_VIRTUAL	0
 #define HCI_USB		1
 #define HCI_PCCARD	2
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 7b86094..7e65885 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -70,7 +70,7 @@ struct hci_dev {
 	char		name[8];
 	unsigned long	flags;
 	__u16		id;
-	__u8		type;
+	__u8		bus;
 	bdaddr_t	bdaddr;
 	__u8		dev_name[248];
 	__u8		dev_class[3];
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 94ba349..4b62ed0 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -797,7 +797,7 @@ int hci_get_dev_info(void __user *arg)
 
 	strcpy(di.name, hdev->name);
 	di.bdaddr   = hdev->bdaddr;
-	di.type     = hdev->type;
+	di.type     = hdev->bus;
 	di.flags    = hdev->flags;
 	di.pkt_type = hdev->pkt_type;
 	di.acl_mtu  = hdev->acl_mtu;
@@ -869,8 +869,8 @@ int hci_register_dev(struct hci_dev *hdev)
 	struct list_head *head = &hci_dev_list, *p;
 	int i, id = 0;
 
-	BT_DBG("%p name %s type %d owner %p", hdev, hdev->name,
-						hdev->type, hdev->owner);
+	BT_DBG("%p name %s bus %d owner %p", hdev, hdev->name,
+						hdev->bus, hdev->owner);
 
 	if (!hdev->open || !hdev->close || !hdev->destruct)
 		return -EINVAL;
@@ -946,7 +946,7 @@ int hci_unregister_dev(struct hci_dev *hdev)
 {
 	int i;
 
-	BT_DBG("%p name %s type %d", hdev, hdev->name, hdev->type);
+	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
 
 	write_lock_bh(&hci_dev_list_lock);
 	list_del(&hdev->list);
diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index 2bc6f6a..9b5f376 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -166,9 +166,9 @@ void hci_conn_del_sysfs(struct hci_conn *conn)
 	queue_work(bt_workq, &conn->work_del);
 }
 
-static inline char *host_typetostr(int type)
+static inline char *host_bustostr(int bus)
 {
-	switch (type) {
+	switch (bus) {
 	case HCI_VIRTUAL:
 		return "VIRTUAL";
 	case HCI_USB:
@@ -188,10 +188,10 @@ static inline char *host_typetostr(int type)
 	}
 }
 
-static ssize_t show_type(struct device *dev, struct device_attribute *attr, char *buf)
+static ssize_t show_bus(struct device *dev, struct device_attribute *attr, char *buf)
 {
 	struct hci_dev *hdev = dev_get_drvdata(dev);
-	return sprintf(buf, "%s\n", host_typetostr(hdev->type));
+	return sprintf(buf, "%s\n", host_bustostr(hdev->bus));
 }
 
 static ssize_t show_name(struct device *dev, struct device_attribute *attr, char *buf)
@@ -355,7 +355,7 @@ static ssize_t store_sniff_min_interval(struct device *dev, struct device_attrib
 	return count;
 }
 
-static DEVICE_ATTR(type, S_IRUGO, show_type, NULL);
+static DEVICE_ATTR(bus, S_IRUGO, show_bus, NULL);
 static DEVICE_ATTR(name, S_IRUGO, show_name, NULL);
 static DEVICE_ATTR(class, S_IRUGO, show_class, NULL);
 static DEVICE_ATTR(address, S_IRUGO, show_address, NULL);
@@ -373,7 +373,7 @@ static DEVICE_ATTR(sniff_min_interval, S_IRUGO | S_IWUSR,
 				show_sniff_min_interval, store_sniff_min_interval);
 
 static struct attribute *bt_host_attrs[] = {
-	&dev_attr_type.attr,
+	&dev_attr_bus.attr,
 	&dev_attr_name.attr,
 	&dev_attr_class.attr,
 	&dev_attr_address.attr,
@@ -414,7 +414,7 @@ int hci_register_sysfs(struct hci_dev *hdev)
 	struct device *dev = &hdev->dev;
 	int err;
 
-	BT_DBG("%p name %s type %d", hdev, hdev->name, hdev->type);
+	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
 
 	dev->type = &bt_host;
 	dev->class = bt_class;
@@ -433,7 +433,7 @@ int hci_register_sysfs(struct hci_dev *hdev)
 
 void hci_unregister_sysfs(struct hci_dev *hdev)
 {
-	BT_DBG("%p name %s type %d", hdev, hdev->name, hdev->type);
+	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
 
 	device_del(&hdev->dev);
 }
-- 
1.6.6

