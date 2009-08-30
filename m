From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 03/47] Bluetooth: Improve USB driver throughput by increasing the frame size
Date: Sun, 30 Aug 2009 01:50:17 -0700
Message-ID: <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53266 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbZH3Ivx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:51:53 -0400
In-Reply-To: <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vikram Kandukuri <vkandukuri@atheros.com>

This patch increases the receive buffer size to HCI_MAX_FRAME_SIZE
which improves the RX throughput considerably.

Tested against BRM/Atheros/CSR USB Dongles with PAN profile using
iperf and chariot. This gave significant (around 40%) increase
in performance (increased from 0.8 to 1.5 Mb/s in Sheld room)

Signed-off-by: Vikram Kandukuri <vikram.kandukuri@atheros.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btusb.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index e70c57e..124db8c 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -301,7 +301,7 @@ static int btusb_submit_bulk_urb(struct hci_dev *hdev, gfp_t mem_flags)
 	struct urb *urb;
 	unsigned char *buf;
 	unsigned int pipe;
-	int err, size;
+	int err, size = HCI_MAX_FRAME_SIZE;
 
 	BT_DBG("%s", hdev->name);
 
@@ -312,8 +312,6 @@ static int btusb_submit_bulk_urb(struct hci_dev *hdev, gfp_t mem_flags)
 	if (!urb)
 		return -ENOMEM;
 
-	size = le16_to_cpu(data->bulk_rx_ep->wMaxPacketSize);
-
 	buf = kmalloc(size, mem_flags);
 	if (!buf) {
 		usb_free_urb(urb);
-- 
1.6.2.5

