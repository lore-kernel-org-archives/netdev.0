From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 15/47] Bluetooth: Some coding style cleanup for Marvell core driver
Date: Sun, 30 Aug 2009 01:50:29 -0700
Message-ID: <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
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
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53290 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851AbZH3IwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:09 -0400
In-Reply-To: <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell core Bluetooth driver has various weird casting and unneeded
braces in its code that makes it hard to read. Remove all of these to
make the code a little bit simpler.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_main.c |   97 ++++++++++++++++++---------------------
 1 files changed, 45 insertions(+), 52 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index b4f4445..db4fdb1 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -48,19 +48,18 @@ EXPORT_SYMBOL_GPL(btmrvl_interrupt);
 
 void btmrvl_check_evtpkt(struct btmrvl_private *priv, struct sk_buff *skb)
 {
-	struct hci_event_hdr *hdr = (struct hci_event_hdr *)skb->data;
+	struct hci_event_hdr *hdr = (void *) skb->data;
 	struct hci_ev_cmd_complete *ec;
 	u16 opcode, ocf;
 
 	BT_DBG("Enter");
 
 	if (hdr->evt == HCI_EV_CMD_COMPLETE) {
-		ec = (struct hci_ev_cmd_complete *)(skb->data +
-						    HCI_EVENT_HDR_SIZE);
+		ec = (void *) (skb->data + HCI_EVENT_HDR_SIZE);
 		opcode = __le16_to_cpu(ec->opcode);
 		ocf = hci_opcode_ocf(opcode);
-		if ((ocf == BT_CMD_MODULE_CFG_REQ) &&
-		    (priv->btmrvl_dev.sendcmdflag)) {
+		if (ocf == BT_CMD_MODULE_CFG_REQ &&
+					priv->btmrvl_dev.sendcmdflag) {
 			priv->btmrvl_dev.sendcmdflag = false;
 			priv->adapter->cmd_complete = true;
 			wake_up_interruptible(&priv->adapter->cmd_wait_q);
@@ -74,8 +73,8 @@ EXPORT_SYMBOL_GPL(btmrvl_check_evtpkt);
 int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 {
 	struct btmrvl_adapter *adapter = priv->adapter;
-	u8 ret = 0;
 	struct btmrvl_event *event;
+	u8 ret = 0;
 
 	BT_DBG("Enter");
 
@@ -103,7 +102,7 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 	case BT_CMD_HOST_SLEEP_CONFIG:
 		if (!event->data[3])
 			BT_DBG("gpio=%x, gap=%x", event->data[1],
-				event->data[2]);
+							event->data[2]);
 		else
 			BT_DBG("HSCFG command failed");
 		break;
@@ -121,12 +120,12 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 		break;
 
 	case BT_CMD_MODULE_CFG_REQ:
-		if ((priv->btmrvl_dev.sendcmdflag) &&
-			(event->data[1] == MODULE_BRINGUP_REQ)) {
+		if (priv->btmrvl_dev.sendcmdflag &&
+				event->data[1] == MODULE_BRINGUP_REQ) {
 			BT_DBG("EVENT:%s", (event->data[2]) ?
 				"Bring-up failed" : "Bring-up succeed");
-		} else if ((priv->btmrvl_dev.sendcmdflag) &&
-			(event->data[1] == MODULE_SHUTDOWN_REQ)) {
+		} else if (priv->btmrvl_dev.sendcmdflag &&
+				event->data[1] == MODULE_SHUTDOWN_REQ) {
 			BT_DBG("EVENT:%s", (event->data[2]) ?
 				"Shutdown failed" : "Shutdown succeed");
 		} else {
@@ -160,9 +159,9 @@ EXPORT_SYMBOL_GPL(btmrvl_process_event);
 
 int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 {
-	struct sk_buff *skb = NULL;
-	u8 ret = 0;
+	struct sk_buff *skb;
 	struct btmrvl_cmd *cmd;
+	u8 ret = 0;
 
 	BT_DBG("Enter");
 
@@ -181,7 +180,7 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 	bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
 
 	skb_put(skb, sizeof(*cmd));
-	skb->dev = (void *)priv->btmrvl_dev.hcidev;
+	skb->dev = (void *) priv->btmrvl_dev.hcidev;
 	skb_queue_head(&priv->adapter->tx_queue, skb);
 
 	priv->btmrvl_dev.sendcmdflag = true;
@@ -192,13 +191,12 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 
 	wake_up_interruptible(&priv->main_thread.wait_q);
 
-	if (!wait_event_interruptible_timeout(
-			priv->adapter->cmd_wait_q,
-			priv->adapter->cmd_complete,
-			msecs_to_jiffies(WAIT_UNTIL_CMD_RESP))) {
+	if (!wait_event_interruptible_timeout(priv->adapter->cmd_wait_q,
+				priv->adapter->cmd_complete,
+				msecs_to_jiffies(WAIT_UNTIL_CMD_RESP))) {
 		ret = -ETIMEDOUT;
 		BT_ERR("module_cfg_cmd(%x): timeout: %d",
-			subcmd, priv->btmrvl_dev.sendcmdflag);
+					subcmd, priv->btmrvl_dev.sendcmdflag);
 	}
 
 	BT_DBG("module cfg Command done");
@@ -212,9 +210,9 @@ EXPORT_SYMBOL_GPL(btmrvl_send_module_cfg_cmd);
 
 static int btmrvl_enable_hs(struct btmrvl_private *priv)
 {
-	struct sk_buff *skb = NULL;
-	u8 ret = 0;
+	struct sk_buff *skb;
 	struct btmrvl_cmd *cmd;
+	u8 ret = 0;
 
 	BT_DBG("Enter");
 
@@ -232,22 +230,20 @@ static int btmrvl_enable_hs(struct btmrvl_private *priv)
 	bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
 
 	skb_put(skb, sizeof(*cmd));
-	skb->dev = (void *)priv->btmrvl_dev.hcidev;
+	skb->dev = (void *) priv->btmrvl_dev.hcidev;
 	skb_queue_head(&priv->adapter->tx_queue, skb);
 
 	BT_DBG("Queue hs enable Command");
 
 	wake_up_interruptible(&priv->main_thread.wait_q);
 
-	if (!wait_event_interruptible_timeout(
-			priv->adapter->cmd_wait_q,
+	if (!wait_event_interruptible_timeout(priv->adapter->cmd_wait_q,
 			priv->adapter->hs_state,
 			msecs_to_jiffies(WAIT_UNTIL_HS_STATE_CHANGED))) {
 		ret = -ETIMEDOUT;
-		BT_ERR("timeout: %d, %d,%d",
-			priv->adapter->hs_state,
-			priv->adapter->ps_state,
-			priv->adapter->wakeup_tries);
+		BT_ERR("timeout: %d, %d,%d", priv->adapter->hs_state,
+						priv->adapter->ps_state,
+						priv->adapter->wakeup_tries);
 	}
 
 exit:
@@ -259,8 +255,8 @@ exit:
 int btmrvl_prepare_command(struct btmrvl_private *priv)
 {
 	struct sk_buff *skb = NULL;
-	u8 ret = 0;
 	struct btmrvl_cmd *cmd;
+	u8 ret = 0;
 
 	BT_DBG("Enter");
 
@@ -284,11 +280,11 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 		bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
 
 		skb_put(skb, sizeof(*cmd));
-		skb->dev = (void *)priv->btmrvl_dev.hcidev;
+		skb->dev = (void *) priv->btmrvl_dev.hcidev;
 		skb_queue_head(&priv->adapter->tx_queue, skb);
 
 		BT_DBG("Queue HSCFG Command, gpio=0x%x, gap=0x%x",
-		       cmd->data[0], cmd->data[1]);
+						cmd->data[0], cmd->data[1]);
 	}
 
 	if (priv->btmrvl_dev.pscmd) {
@@ -314,7 +310,7 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 		bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
 
 		skb_put(skb, sizeof(*cmd));
-		skb->dev = (void *)priv->btmrvl_dev.hcidev;
+		skb->dev = (void *) priv->btmrvl_dev.hcidev;
 		skb_queue_head(&priv->adapter->tx_queue, skb);
 
 		BT_DBG("Queue PSMODE Command:%d", cmd->data[0]);
@@ -350,7 +346,7 @@ static int btmrvl_tx_pkt(struct btmrvl_private *priv, struct sk_buff *skb)
 
 	if (!skb->len || ((skb->len + BTM_HEADER_LEN) > BTM_UPLD_SIZE)) {
 		BT_ERR("Tx Error: Bad skb length %d : %d",
-			skb->len, BTM_UPLD_SIZE);
+						skb->len, BTM_UPLD_SIZE);
 		BT_DBG("Leave");
 		return -EINVAL;
 	}
@@ -416,8 +412,8 @@ static void btmrvl_free_adapter(struct btmrvl_private *priv)
 	BT_DBG("Leave");
 }
 
-static int
-btmrvl_ioctl(struct hci_dev *hdev, unsigned int cmd, unsigned long arg)
+static int btmrvl_ioctl(struct hci_dev *hdev,
+				unsigned int cmd, unsigned long arg)
 {
 	BT_DBG("Enter");
 
@@ -435,7 +431,7 @@ static void btmrvl_destruct(struct hci_dev *hdev)
 
 static int btmrvl_send_frame(struct sk_buff *skb)
 {
-	struct hci_dev *hdev = (struct hci_dev *)skb->dev;
+	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 	struct btmrvl_private *priv = NULL;
 
 	BT_DBG("Enter: type=%d, len=%d", skb->pkt_type, skb->len);
@@ -446,11 +442,11 @@ static int btmrvl_send_frame(struct sk_buff *skb)
 		return -ENODEV;
 	}
 
-	priv = (struct btmrvl_private *)hdev->driver_data;
+	priv = (struct btmrvl_private *) hdev->driver_data;
 	if (!test_bit(HCI_RUNNING, &hdev->flags)) {
 		BT_ERR("Failed testing HCI_RUNING, flags=%lx", hdev->flags);
 		print_hex_dump_bytes("data: ", DUMP_PREFIX_OFFSET,
-					skb->data, skb->len);
+							skb->data, skb->len);
 		BT_DBG("Leave");
 		return -EBUSY;
 	}
@@ -480,8 +476,7 @@ static int btmrvl_send_frame(struct sk_buff *skb)
 
 static int btmrvl_flush(struct hci_dev *hdev)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) hdev->driver_data;
+	struct btmrvl_private *priv = hdev->driver_data;
 
 	BT_DBG("Enter");
 
@@ -494,8 +489,7 @@ static int btmrvl_flush(struct hci_dev *hdev)
 
 static int btmrvl_close(struct hci_dev *hdev)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) hdev->driver_data;
+	struct btmrvl_private *priv = hdev->driver_data;
 
 	BT_DBG("Enter");
 
@@ -547,9 +541,9 @@ static int btmrvl_service_main_thread(void *data)
 		set_current_state(TASK_INTERRUPTIBLE);
 
 		if (adapter->wakeup_tries ||
-		    ((!adapter->int_count) &&
-		     (!priv->btmrvl_dev.tx_dnld_rdy ||
-		      skb_queue_empty(&adapter->tx_queue)))) {
+				((!adapter->int_count) &&
+				(!priv->btmrvl_dev.tx_dnld_rdy ||
+				skb_queue_empty(&adapter->tx_queue)))) {
 			BT_DBG("main_thread is sleeping...");
 			schedule();
 		}
@@ -568,8 +562,8 @@ static int btmrvl_service_main_thread(void *data)
 		spin_lock_irqsave(&priv->driver_lock, flags);
 		if (adapter->int_count) {
 			adapter->int_count = 0;
-		} else if ((adapter->ps_state == PS_SLEEP) &&
-			   !skb_queue_empty(&adapter->tx_queue)) {
+		} else if (adapter->ps_state == PS_SLEEP &&
+					!skb_queue_empty(&adapter->tx_queue)) {
 			spin_unlock_irqrestore(&priv->driver_lock, flags);
 			adapter->wakeup_tries++;
 			priv->hw_wakeup_firmware(priv);
@@ -588,8 +582,7 @@ static int btmrvl_service_main_thread(void *data)
 			if (btmrvl_tx_pkt(priv, skb))
 				priv->btmrvl_dev.hcidev->stat.err_tx++;
 			else
-				priv->btmrvl_dev.hcidev->stat.byte_tx
-					+= skb->len;
+				priv->btmrvl_dev.hcidev->stat.byte_tx += skb->len;
 
 			kfree_skb(skb);
 		}
@@ -603,7 +596,7 @@ static int btmrvl_service_main_thread(void *data)
 struct btmrvl_private *btmrvl_add_card(void *card)
 {
 	struct hci_dev *hdev = NULL;
-	struct btmrvl_private *priv = NULL;
+	struct btmrvl_private *priv;
 	int ret;
 
 	BT_DBG("Enter");
@@ -634,7 +627,7 @@ struct btmrvl_private *btmrvl_add_card(void *card)
 
 	init_waitqueue_head(&priv->main_thread.wait_q);
 	priv->main_thread.task = kthread_run(btmrvl_service_main_thread,
-		&priv->main_thread, "btmrvl_main_service");
+				&priv->main_thread, "btmrvl_main_service");
 
 	priv->btmrvl_dev.hcidev = hdev;
 	priv->btmrvl_dev.card = card;
@@ -717,6 +710,6 @@ int btmrvl_remove_card(struct btmrvl_private *priv)
 EXPORT_SYMBOL_GPL(btmrvl_remove_card);
 
 MODULE_AUTHOR("Marvell International Ltd.");
-MODULE_DESCRIPTION("Marvell Bluetooth Driver v" VERSION);
+MODULE_DESCRIPTION("Marvell Bluetooth Driver ver" VERSION);
 MODULE_VERSION(VERSION);
 MODULE_LICENSE("GPL v2");
-- 
1.6.2.5

