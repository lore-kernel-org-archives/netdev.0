From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 21/47] Bluetooth: Remove Enter/Leave debug statements from Marvell driver
Date: Sun, 30 Aug 2009 01:50:35 -0700
Message-ID: <9374253ffe609f2d70dd5ae280182cb6f08fef08.1251621661.git.marcel@holtmann.org>
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
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53302 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981AbZH3IwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:16 -0400
In-Reply-To: <e0721f99ba33d13a88746732be2d74ca805abf55.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell Bluetooth driver is full of Enter/Leave debug statements and
all of them are really pointless and only clutter the code. Seems to be
some left-overs when they ported the driver from Windows. For the Linux
driver lets remove these.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_main.c |  107 +++---------------------------
 drivers/bluetooth/btmrvl_sdio.c |  135 ++++-----------------------------------
 2 files changed, 23 insertions(+), 219 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index bbc4446..e605563 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -32,8 +32,6 @@
  */
 void btmrvl_interrupt(struct btmrvl_private *priv)
 {
-	BT_DBG("Enter");
-
 	priv->adapter->ps_state = PS_AWAKE;
 
 	priv->adapter->wakeup_tries = 0;
@@ -41,8 +39,6 @@ void btmrvl_interrupt(struct btmrvl_private *priv)
 	priv->adapter->int_count++;
 
 	wake_up_interruptible(&priv->main_thread.wait_q);
-
-	BT_DBG("Leave");
 }
 EXPORT_SYMBOL_GPL(btmrvl_interrupt);
 
@@ -52,8 +48,6 @@ void btmrvl_check_evtpkt(struct btmrvl_private *priv, struct sk_buff *skb)
 	struct hci_ev_cmd_complete *ec;
 	u16 opcode, ocf;
 
-	BT_DBG("Enter");
-
 	if (hdr->evt == HCI_EV_CMD_COMPLETE) {
 		ec = (void *) (skb->data + HCI_EVENT_HDR_SIZE);
 		opcode = __le16_to_cpu(ec->opcode);
@@ -65,8 +59,6 @@ void btmrvl_check_evtpkt(struct btmrvl_private *priv, struct sk_buff *skb)
 			wake_up_interruptible(&priv->adapter->cmd_wait_q);
 		}
 	}
-
-	BT_DBG("Leave");
 }
 EXPORT_SYMBOL_GPL(btmrvl_check_evtpkt);
 
@@ -76,8 +68,6 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb)
 	struct btmrvl_event *event;
 	u8 ret = 0;
 
-	BT_DBG("Enter");
-
 	event = (struct btmrvl_event *) skb->data;
 	if (event->ec != 0xff) {
 		BT_DBG("Not Marvell Event=%x", event->ec);
@@ -151,8 +141,6 @@ exit:
 	if (!ret)
 		kfree_skb(skb);
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 EXPORT_SYMBOL_GPL(btmrvl_process_event);
@@ -161,15 +149,12 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 {
 	struct sk_buff *skb;
 	struct btmrvl_cmd *cmd;
-	u8 ret = 0;
-
-	BT_DBG("Enter");
+	int ret = 0;
 
 	skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
 	if (skb == NULL) {
 		BT_ERR("No free skb");
-		ret = -ENOMEM;
-		goto exit;
+		return -ENOMEM;
 	}
 
 	cmd = (struct btmrvl_cmd *) skb_put(skb, sizeof(*cmd));
@@ -200,9 +185,6 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 
 	BT_DBG("module cfg Command done");
 
-exit:
-	BT_DBG("Leave");
-
 	return ret;
 }
 EXPORT_SYMBOL_GPL(btmrvl_send_module_cfg_cmd);
@@ -211,15 +193,12 @@ static int btmrvl_enable_hs(struct btmrvl_private *priv)
 {
 	struct sk_buff *skb;
 	struct btmrvl_cmd *cmd;
-	u8 ret = 0;
-
-	BT_DBG("Enter");
+	int ret = 0;
 
 	skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
 	if (skb == NULL) {
 		BT_ERR("No free skb");
-		ret = -ENOMEM;
-		goto exit;
+		return -ENOMEM;
 	}
 
 	cmd = (struct btmrvl_cmd *) skb_put(skb, sizeof(*cmd));
@@ -244,9 +223,6 @@ static int btmrvl_enable_hs(struct btmrvl_private *priv)
 						priv->adapter->wakeup_tries);
 	}
 
-exit:
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -254,9 +230,7 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 {
 	struct sk_buff *skb = NULL;
 	struct btmrvl_cmd *cmd;
-	u8 ret = 0;
-
-	BT_DBG("Enter");
+	int ret = 0;
 
 	if (priv->btmrvl_dev.hscfgcmd) {
 		priv->btmrvl_dev.hscfgcmd = 0;
@@ -264,8 +238,7 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 		skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
 		if (skb == NULL) {
 			BT_ERR("No free skb");
-			ret = -ENOMEM;
-			goto exit;
+			return -ENOMEM;
 		}
 
 		cmd = (struct btmrvl_cmd *) skb_put(skb, sizeof(*cmd));
@@ -289,8 +262,7 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 		skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
 		if (skb == NULL) {
 			BT_ERR("No free skb");
-			ret = -ENOMEM;
-			goto exit;
+			return -ENOMEM;
 		}
 
 		cmd = (struct btmrvl_cmd *) skb_put(skb, sizeof(*cmd));
@@ -321,27 +293,19 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 		}
 	}
 
-exit:
-	BT_DBG("Leave");
-
 	return ret;
 }
 
 static int btmrvl_tx_pkt(struct btmrvl_private *priv, struct sk_buff *skb)
 {
-	u8 ret = 0;
+	int ret = 0;
 
-	BT_DBG("Enter");
-
-	if (!skb || !skb->data) {
-		BT_DBG("Leave");
+	if (!skb || !skb->data)
 		return -EINVAL;
-	}
 
 	if (!skb->len || ((skb->len + BTM_HEADER_LEN) > BTM_UPLD_SIZE)) {
 		BT_ERR("Tx Error: Bad skb length %d : %d",
 						skb->len, BTM_UPLD_SIZE);
-		BT_DBG("Leave");
 		return -EINVAL;
 	}
 
@@ -353,7 +317,6 @@ static int btmrvl_tx_pkt(struct btmrvl_private *priv, struct sk_buff *skb)
 			BT_ERR("Tx Error: realloc_headroom failed %d",
 				BTM_HEADER_LEN);
 			skb = tmp;
-			BT_DBG("Leave");
 			return -EINVAL;
 		}
 
@@ -375,52 +338,35 @@ static int btmrvl_tx_pkt(struct btmrvl_private *priv, struct sk_buff *skb)
 	if (priv->hw_host_to_card)
 		ret = priv->hw_host_to_card(priv, skb->data, skb->len);
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
 static void btmrvl_init_adapter(struct btmrvl_private *priv)
 {
-	BT_DBG("Enter");
-
 	skb_queue_head_init(&priv->adapter->tx_queue);
 
 	priv->adapter->ps_state = PS_AWAKE;
 
 	init_waitqueue_head(&priv->adapter->cmd_wait_q);
-
-	BT_DBG("Leave");
 }
 
 static void btmrvl_free_adapter(struct btmrvl_private *priv)
 {
-	BT_DBG("Enter");
-
 	skb_queue_purge(&priv->adapter->tx_queue);
 
 	kfree(priv->adapter);
 
 	priv->adapter = NULL;
-
-	BT_DBG("Leave");
 }
 
 static int btmrvl_ioctl(struct hci_dev *hdev,
 				unsigned int cmd, unsigned long arg)
 {
-	BT_DBG("Enter");
-
-	BT_DBG("Leave");
-
 	return -ENOIOCTLCMD;
 }
 
 static void btmrvl_destruct(struct hci_dev *hdev)
 {
-	BT_DBG("Enter");
-
-	BT_DBG("Leave");
 }
 
 static int btmrvl_send_frame(struct sk_buff *skb)
@@ -428,11 +374,10 @@ static int btmrvl_send_frame(struct sk_buff *skb)
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 	struct btmrvl_private *priv = NULL;
 
-	BT_DBG("Enter: type=%d, len=%d", skb->pkt_type, skb->len);
+	BT_DBG("type=%d, len=%d", skb->pkt_type, skb->len);
 
 	if (!hdev || !hdev->driver_data) {
 		BT_ERR("Frame for unknown HCI device");
-		BT_DBG("Leave");
 		return -ENODEV;
 	}
 
@@ -441,7 +386,6 @@ static int btmrvl_send_frame(struct sk_buff *skb)
 		BT_ERR("Failed testing HCI_RUNING, flags=%lx", hdev->flags);
 		print_hex_dump_bytes("data: ", DUMP_PREFIX_OFFSET,
 							skb->data, skb->len);
-		BT_DBG("Leave");
 		return -EBUSY;
 	}
 
@@ -463,8 +407,6 @@ static int btmrvl_send_frame(struct sk_buff *skb)
 
 	wake_up_interruptible(&priv->main_thread.wait_q);
 
-	BT_DBG("Leave");
-
 	return 0;
 }
 
@@ -472,12 +414,8 @@ static int btmrvl_flush(struct hci_dev *hdev)
 {
 	struct btmrvl_private *priv = hdev->driver_data;
 
-	BT_DBG("Enter");
-
 	skb_queue_purge(&priv->adapter->tx_queue);
 
-	BT_DBG("Leave");
-
 	return 0;
 }
 
@@ -485,28 +423,18 @@ static int btmrvl_close(struct hci_dev *hdev)
 {
 	struct btmrvl_private *priv = hdev->driver_data;
 
-	BT_DBG("Enter");
-
-	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags)) {
-		BT_DBG("Leave");
+	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
-	}
 
 	skb_queue_purge(&priv->adapter->tx_queue);
 
-	BT_DBG("Leave");
-
 	return 0;
 }
 
 static int btmrvl_open(struct hci_dev *hdev)
 {
-	BT_DBG("Enter");
-
 	set_bit(HCI_RUNNING, &hdev->flags);
 
-	BT_DBG("Leave");
-
 	return 0;
 }
 
@@ -523,8 +451,6 @@ static int btmrvl_service_main_thread(void *data)
 	struct sk_buff *skb;
 	ulong flags;
 
-	BT_DBG("Enter");
-
 	init_waitqueue_entry(&wait, current);
 
 	current->flags |= PF_NOFREEZE;
@@ -582,8 +508,6 @@ static int btmrvl_service_main_thread(void *data)
 		}
 	}
 
-	BT_DBG("Leave");
-
 	return 0;
 }
 
@@ -593,8 +517,6 @@ struct btmrvl_private *btmrvl_add_card(void *card)
 	struct btmrvl_private *priv;
 	int ret;
 
-	BT_DBG("Enter");
-
 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
 	if (!priv) {
 		BT_ERR("Can not allocate priv");
@@ -649,7 +571,6 @@ struct btmrvl_private *btmrvl_add_card(void *card)
 	btmrvl_debugfs_init(hdev);
 #endif
 
-	BT_DBG("Leave");
 	return priv;
 
 err_hci_register_dev:
@@ -665,8 +586,6 @@ err_adapter:
 	kfree(priv);
 
 err_priv:
-	BT_DBG("Leave");
-
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(btmrvl_add_card);
@@ -675,8 +594,6 @@ int btmrvl_remove_card(struct btmrvl_private *priv)
 {
 	struct hci_dev *hdev;
 
-	BT_DBG("Enter");
-
 	hdev = priv->btmrvl_dev.hcidev;
 
 	wake_up_interruptible(&priv->adapter->cmd_wait_q);
@@ -697,8 +614,6 @@ int btmrvl_remove_card(struct btmrvl_private *priv)
 
 	kfree(priv);
 
-	BT_DBG("Leave");
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(btmrvl_remove_card);
diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
index 7638f62..224af53 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -67,23 +67,17 @@ static int btmrvl_sdio_get_rx_unit(struct btmrvl_sdio_card *card)
 	u8 reg;
 	int ret;
 
-	BT_DBG("Enter");
-
 	reg = sdio_readb(card->func, CARD_RX_UNIT_REG, &ret);
 	if (!ret)
 		card->rx_unit = reg;
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
 static int btmrvl_sdio_read_fw_status(struct btmrvl_sdio_card *card, u16 *dat)
 {
-	int ret;
 	u8 fws0, fws1;
-
-	BT_DBG("Enter");
+	int ret;
 
 	*dat = 0;
 
@@ -92,31 +86,23 @@ static int btmrvl_sdio_read_fw_status(struct btmrvl_sdio_card *card, u16 *dat)
 	if (!ret)
 		fws1 = sdio_readb(card->func, CARD_FW_STATUS1_REG, &ret);
 
-	if (ret) {
-		BT_DBG("Leave");
+	if (ret)
 		return -EIO;
-	}
 
 	*dat = (((u16) fws1) << 8) | fws0;
 
-	BT_DBG("Leave");
-
 	return 0;
 }
 
 static int btmrvl_sdio_read_rx_len(struct btmrvl_sdio_card *card, u16 *dat)
 {
-	int ret;
 	u8 reg;
-
-	BT_DBG("Enter");
+	int ret;
 
 	reg = sdio_readb(card->func, CARD_RX_LEN_REG, &ret);
 	if (!ret)
 		*dat = (u16) reg << card->rx_unit;
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -125,64 +111,48 @@ static int btmrvl_sdio_enable_host_int_mask(struct btmrvl_sdio_card *card,
 {
 	int ret;
 
-	BT_DBG("Enter");
-
 	sdio_writeb(card->func, mask, HOST_INT_MASK_REG, &ret);
 	if (ret) {
 		BT_ERR("Unable to enable the host interrupt!");
 		ret = -EIO;
 	}
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
 static int btmrvl_sdio_disable_host_int_mask(struct btmrvl_sdio_card *card,
 								u8 mask)
 {
-	int ret;
 	u8 host_int_mask;
-
-	BT_DBG("Enter");
+	int ret;
 
 	host_int_mask = sdio_readb(card->func, HOST_INT_MASK_REG, &ret);
-	if (ret) {
-		ret = -EIO;
-		goto done;
-	}
+	if (ret)
+		return -EIO;
 
 	host_int_mask &= ~mask;
 
 	sdio_writeb(card->func, host_int_mask, HOST_INT_MASK_REG, &ret);
 	if (ret < 0) {
 		BT_ERR("Unable to disable the host interrupt!");
-		ret = -EIO;
-		goto done;
+		return -EIO;
 	}
 
-	ret = 0;
-
-done:
-	BT_DBG("Leave");
-
-	return ret;
+	return 0;
 }
 
 static int btmrvl_sdio_poll_card_status(struct btmrvl_sdio_card *card, u8 bits)
 {
 	unsigned int tries;
-	int ret;
 	u8 status;
-
-	BT_DBG("Enter");
+	int ret;
 
 	for (tries = 0; tries < MAX_POLL_TRIES * 1000; tries++) {
 		status = sdio_readb(card->func, CARD_STATUS_REG, &ret);
 		if (ret)
 			goto failed;
 		if ((status & bits) == bits)
-			goto done;
+			return ret;
 
 		udelay(1);
 	}
@@ -192,9 +162,6 @@ static int btmrvl_sdio_poll_card_status(struct btmrvl_sdio_card *card, u8 bits)
 failed:
 	BT_ERR("FAILED! ret=%d", ret);
 
-done:
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -205,8 +172,6 @@ static int btmrvl_sdio_verify_fw_download(struct btmrvl_sdio_card *card,
 	u16 firmwarestat;
 	unsigned int tries;
 
-	BT_DBG("Enter");
-
 	 /* Wait for firmware to become ready */
 	for (tries = 0; tries < pollnum; tries++) {
 		if (btmrvl_sdio_read_fw_status(card, &firmwarestat) < 0)
@@ -220,8 +185,6 @@ static int btmrvl_sdio_verify_fw_download(struct btmrvl_sdio_card *card,
 		}
 	}
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -235,8 +198,6 @@ static int btmrvl_sdio_download_helper(struct btmrvl_sdio_card *card)
 	u8 *helperbuf;
 	u32 tx_len;
 
-	BT_DBG("Enter");
-
 	ret = request_firmware(&fw_helper, card->helper,
 						&card->func->dev);
 	if ((ret < 0) || !fw_helper) {
@@ -326,8 +287,6 @@ done:
 	if (fw_helper)
 		release_firmware(fw_helper);
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -343,8 +302,6 @@ static int btmrvl_sdio_download_fw_w_helper(struct btmrvl_sdio_card *card)
 	u16 len;
 	int txlen = 0, tx_blocks = 0, count = 0;
 
-	BT_DBG("Enter");
-
 	ret = request_firmware(&fw_firmware, card->firmware,
 							&card->func->dev);
 	if ((ret < 0) || !fw_firmware) {
@@ -479,8 +436,6 @@ done:
 	if (fw_firmware)
 		release_firmware(fw_firmware);
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -494,8 +449,6 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 	struct hci_dev *hdev = priv->btmrvl_dev.hcidev;
 	struct btmrvl_sdio_card *card = priv->btmrvl_dev.card;
 
-	BT_DBG("Enter");
-
 	if (!card || !card->func) {
 		BT_ERR("card or function is NULL!");
 		ret = -EINVAL;
@@ -596,8 +549,6 @@ exit:
 			kfree_skb(skb);
 	}
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -607,8 +558,6 @@ static int btmrvl_sdio_get_int_status(struct btmrvl_private *priv, u8 * ireg)
 	u8 sdio_ireg = 0;
 	struct btmrvl_sdio_card *card = priv->btmrvl_dev.card;
 
-	BT_DBG("Enter");
-
 	*ireg = 0;
 
 	sdio_ireg = sdio_readb(card->func, HOST_INTSTATUS_REG, &ret);
@@ -653,8 +602,6 @@ static int btmrvl_sdio_get_int_status(struct btmrvl_private *priv, u8 * ireg)
 	ret = 0;
 
 done:
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -665,8 +612,6 @@ static void btmrvl_sdio_interrupt(struct sdio_func *func)
 	struct btmrvl_sdio_card *card;
 	u8 ireg = 0;
 
-	BT_DBG("Enter");
-
 	card = sdio_get_drvdata(func);
 	if (card && card->priv) {
 		priv = card->priv;
@@ -679,8 +624,6 @@ static void btmrvl_sdio_interrupt(struct sdio_func *func)
 
 		btmrvl_interrupt(priv);
 	}
-
-	BT_DBG("Leave");
 }
 
 static int btmrvl_sdio_register_dev(struct btmrvl_sdio_card *card)
@@ -689,8 +632,6 @@ static int btmrvl_sdio_register_dev(struct btmrvl_sdio_card *card)
 	u8 reg;
 	int ret = 0;
 
-	BT_DBG("Enter");
-
 	if (!card || !card->func) {
 		BT_ERR("Error: card or function is NULL!");
 		ret = -EINVAL;
@@ -752,7 +693,6 @@ static int btmrvl_sdio_register_dev(struct btmrvl_sdio_card *card)
 
 	sdio_release_host(func);
 
-	BT_DBG("Leave");
 	return 0;
 
 release_irq:
@@ -765,14 +705,11 @@ release_host:
 	sdio_release_host(func);
 
 failed:
-	BT_DBG("Leave");
 	return ret;
 }
 
 static int btmrvl_sdio_unregister_dev(struct btmrvl_sdio_card *card)
 {
-	BT_DBG("Enter");
-
 	if (card && card->func) {
 		sdio_claim_host(card->func);
 		sdio_release_irq(card->func);
@@ -781,8 +718,6 @@ static int btmrvl_sdio_unregister_dev(struct btmrvl_sdio_card *card)
 		sdio_set_drvdata(card->func, NULL);
 	}
 
-	BT_DBG("Leave");
-
 	return 0;
 }
 
@@ -790,12 +725,8 @@ static int btmrvl_sdio_enable_host_int(struct btmrvl_sdio_card *card)
 {
 	int ret;
 
-	BT_DBG("Enter");
-
-	if (!card || !card->func) {
-		BT_DBG("Leave");
+	if (!card || !card->func)
 		return -EINVAL;
-	}
 
 	sdio_claim_host(card->func);
 
@@ -805,8 +736,6 @@ static int btmrvl_sdio_enable_host_int(struct btmrvl_sdio_card *card)
 
 	sdio_release_host(card->func);
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -814,12 +743,8 @@ static int btmrvl_sdio_disable_host_int(struct btmrvl_sdio_card *card)
 {
 	int ret;
 
-	BT_DBG("Enter");
-
-	if (!card || !card->func) {
-		BT_DBG("Leave");
+	if (!card || !card->func)
 		return -EINVAL;
-	}
 
 	sdio_claim_host(card->func);
 
@@ -827,8 +752,6 @@ static int btmrvl_sdio_disable_host_int(struct btmrvl_sdio_card *card)
 
 	sdio_release_host(card->func);
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -844,11 +767,8 @@ static int btmrvl_sdio_host_to_card(struct btmrvl_private *priv,
 	void *tmpbuf = NULL;
 	int tmpbufsz;
 
-	BT_DBG("Enter");
-
 	if (!card || !card->func) {
 		BT_ERR("card or function is NULL!");
-		BT_DBG("Leave");
 		return -EINVAL;
 	}
 
@@ -886,8 +806,6 @@ static int btmrvl_sdio_host_to_card(struct btmrvl_private *priv,
 exit:
 	sdio_release_host(card->func);
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -895,11 +813,8 @@ static int btmrvl_sdio_download_fw(struct btmrvl_sdio_card *card)
 {
 	int ret = 0;
 
-	BT_DBG("Enter");
-
 	if (!card || !card->func) {
 		BT_ERR("card or function is NULL!");
-		BT_DBG("Leave");
 		return -EINVAL;
 	}
 	sdio_claim_host(card->func);
@@ -931,8 +846,6 @@ static int btmrvl_sdio_download_fw(struct btmrvl_sdio_card *card)
 done:
 	sdio_release_host(card->func);
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -941,11 +854,8 @@ static int btmrvl_sdio_wakeup_fw(struct btmrvl_private *priv)
 	struct btmrvl_sdio_card *card = priv->btmrvl_dev.card;
 	int ret = 0;
 
-	BT_DBG("Enter");
-
 	if (!card || !card->func) {
 		BT_ERR("card or function is NULL!");
-		BT_DBG("Leave");
 		return -EINVAL;
 	}
 
@@ -957,8 +867,6 @@ static int btmrvl_sdio_wakeup_fw(struct btmrvl_private *priv)
 
 	BT_DBG("wake up firmware");
 
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -969,8 +877,6 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 	struct btmrvl_private *priv = NULL;
 	struct btmrvl_sdio_card *card = NULL;
 
-	BT_DBG("Enter");
-
 	BT_INFO("vendor=0x%x, device=0x%x, class=%d, fn=%d",
 			id->vendor, id->device, id->class, func->num);
 
@@ -1022,8 +928,6 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 
 	btmrvl_send_module_cfg_cmd(priv, MODULE_BRINGUP_REQ);
 
-	BT_DBG("Leave");
-
 	return 0;
 
 disable_host_int:
@@ -1033,8 +937,6 @@ unreg_dev:
 free_card:
 	kfree(card);
 done:
-	BT_DBG("Leave");
-
 	return ret;
 }
 
@@ -1042,8 +944,6 @@ static void btmrvl_sdio_remove(struct sdio_func *func)
 {
 	struct btmrvl_sdio_card *card;
 
-	BT_DBG("Enter");
-
 	if (func) {
 		card = sdio_get_drvdata(func);
 		if (card) {
@@ -1061,8 +961,6 @@ static void btmrvl_sdio_remove(struct sdio_func *func)
 			kfree(card);
 		}
 	}
-
-	BT_DBG("Leave");
 }
 
 static struct sdio_driver bt_mrvl_sdio = {
@@ -1074,32 +972,23 @@ static struct sdio_driver bt_mrvl_sdio = {
 
 static int btmrvl_sdio_init_module(void)
 {
-	BT_DBG("Enter");
-
 	if (sdio_register_driver(&bt_mrvl_sdio) != 0) {
 		BT_ERR("SDIO Driver Registration Failed");
-		BT_DBG("Leave");
 		return -ENODEV;
 	}
 
 	/* Clear the flag in case user removes the card. */
 	user_rmmod = 0;
 
-	BT_DBG("Leave");
-
 	return 0;
 }
 
 static void btmrvl_sdio_exit_module(void)
 {
-	BT_DBG("Enter");
-
 	/* Set the flag as user is removing this module. */
 	user_rmmod = 1;
 
 	sdio_unregister_driver(&bt_mrvl_sdio);
-
-	BT_DBG("Leave");
 }
 
 module_init(btmrvl_sdio_init_module);
-- 
1.6.2.5

