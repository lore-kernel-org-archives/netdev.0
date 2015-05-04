From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 4/8] treewide: Use skb_push_uchar
Date: Mon,  4 May 2015 13:05:48 -0700
Message-ID: <d2649a2a4857c3ea56251c0e972a06db761afa80.1430769295.git.joe@perches.com>
References: <cover.1430769294.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0135.hostedemail.com ([216.40.44.135]:33140 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752551AbbEDUGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:06:13 -0400
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay08.hostedemail.com (Postfix) with ESMTP id D021F29DD79
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:11 +0000 (UTC)
Received: from joe-laptop.perches.com (pool-173-51-221-2.lsanca.fios.verizon.net [173.51.221.2])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:10 +0000 (UTC)
In-Reply-To: <cover.1430769294.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the uses of
        *skb_push(skb, 1) = <uchar>;
and
        memcpy(skb_push(skb, 1), &<uchar>, 1);

to the new skb_push_uchar(skb, <uchar>);

This will allow skb_push to return void * to avoid some casts.

Done via cocci script:

@@
expression skb;
expression e1;
@@

-	*skb_push(skb, 1) = e1;
+	skb_push_uchar(skb, e1);

@@
expression skb;
expression e1;
expression e2;
@@

-	memcpy(skb_push(skb, 1), &e1, e2);
+	skb_push_uchar(skb, e1);

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/bluetooth/bfusb.c                 |  2 +-
 drivers/bluetooth/bluecard_cs.c           |  2 +-
 drivers/bluetooth/bpa10x.c                |  2 +-
 drivers/bluetooth/bt3c_cs.c               |  2 +-
 drivers/bluetooth/btuart_cs.c             |  2 +-
 drivers/bluetooth/btwilink.c              |  2 +-
 drivers/bluetooth/hci_ath.c               |  2 +-
 drivers/bluetooth/hci_bcm.c               |  2 +-
 drivers/bluetooth/hci_bcsp.c              |  2 +-
 drivers/bluetooth/hci_h4.c                |  2 +-
 drivers/bluetooth/hci_ll.c                |  2 +-
 drivers/bluetooth/hci_vhci.c              |  2 +-
 drivers/media/radio/wl128x/fmdrv_common.c |  2 +-
 drivers/net/ppp/ppp_generic.c             |  2 +-
 drivers/nfc/microread/i2c.c               |  2 +-
 drivers/nfc/microread/microread.c         |  4 ++--
 drivers/nfc/pn544/i2c.c                   |  2 +-
 drivers/nfc/pn544/pn544.c                 |  8 ++++----
 drivers/nfc/st21nfca/i2c.c                |  4 ++--
 drivers/nfc/st21nfca/st21nfca.c           |  6 +++---
 drivers/nfc/st21nfca/st21nfca_dep.c       | 30 +++++++++++++++---------------
 drivers/nfc/st21nfcb/ndlc.c               |  2 +-
 net/ax25/af_ax25.c                        |  2 +-
 net/bluetooth/hci_sock.c                  |  2 +-
 net/dccp/options.c                        |  2 +-
 net/nfc/digital_technology.c              |  2 +-
 net/nfc/hci/core.c                        |  2 +-
 net/nfc/hci/llc_shdlc.c                   |  8 ++++----
 net/nfc/nci/hci.c                         |  4 ++--
 net/nfc/nci/spi.c                         |  4 ++--
 30 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/drivers/bluetooth/bfusb.c b/drivers/bluetooth/bfusb.c
index fcfb72e..db8c85c 100644
--- a/drivers/bluetooth/bfusb.c
+++ b/drivers/bluetooth/bfusb.c
@@ -495,7 +495,7 @@ static int bfusb_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 	};
 
 	/* Prepend skb with frame type */
-	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
+	skb_push_uchar(skb, bt_cb(skb)->pkt_type);
 
 	count = skb->len;
 
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index 95c931b..cabd7a6 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -679,7 +679,7 @@ static int bluecard_hci_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 	}
 
 	/* Prepend skb with frame type */
-	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
+	skb_push_uchar(skb, bt_cb(skb)->pkt_type);
 	skb_queue_tail(&(info->txq), skb);
 
 	bluecard_write_wakeup(info);
diff --git a/drivers/bluetooth/bpa10x.c b/drivers/bluetooth/bpa10x.c
index 8a31991..63c8911 100644
--- a/drivers/bluetooth/bpa10x.c
+++ b/drivers/bluetooth/bpa10x.c
@@ -370,7 +370,7 @@ static int bpa10x_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 		return -ENOMEM;
 
 	/* Prepend skb with frame type */
-	*skb_push(skb, 1) = bt_cb(skb)->pkt_type;
+	skb_push_uchar(skb, bt_cb(skb)->pkt_type);
 
 	switch (bt_cb(skb)->pkt_type) {
 	case HCI_COMMAND_PKT:
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index d6e402d..b24a247 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -434,7 +434,7 @@ static int bt3c_hci_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 	};
 
 	/* Prepend skb with frame type */
-	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
+	skb_push_uchar(skb, bt_cb(skb)->pkt_type);
 	skb_queue_tail(&(info->txq), skb);
 
 	spin_lock_irqsave(&(info->lock), flags);
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index a96d56c..570b4d2 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -443,7 +443,7 @@ static int btuart_hci_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 	}
 
 	/* Prepend skb with frame type */
-	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
+	skb_push_uchar(skb, bt_cb(skb)->pkt_type);
 	skb_queue_tail(&(info->txq), skb);
 
 	btuart_write_wakeup(info);
diff --git a/drivers/bluetooth/btwilink.c b/drivers/bluetooth/btwilink.c
index 55c135b..a6cfb67 100644
--- a/drivers/bluetooth/btwilink.c
+++ b/drivers/bluetooth/btwilink.c
@@ -262,7 +262,7 @@ static int ti_st_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 	hst = hci_get_drvdata(hdev);
 
 	/* Prepend skb with frame type */
-	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
+	skb_push_uchar(skb, bt_cb(skb)->pkt_type);
 
 	BT_DBG("%s: type %d len %d", hdev->name, bt_cb(skb)->pkt_type,
 			skb->len);
diff --git a/drivers/bluetooth/hci_ath.c b/drivers/bluetooth/hci_ath.c
index 1b3f864..07fc1a4 100644
--- a/drivers/bluetooth/hci_ath.c
+++ b/drivers/bluetooth/hci_ath.c
@@ -173,7 +173,7 @@ static int ath_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 	BT_DBG("hu %p skb %p", hu, skb);
 
 	/* Prepend skb with frame type */
-	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
+	skb_push_uchar(skb, bt_cb(skb)->pkt_type);
 
 	skb_queue_tail(&ath->txq, skb);
 	set_bit(HCI_UART_SENDING, &hu->tx_state);
diff --git a/drivers/bluetooth/hci_bcm.c b/drivers/bluetooth/hci_bcm.c
index 1ec0b4a..82fae56 100644
--- a/drivers/bluetooth/hci_bcm.c
+++ b/drivers/bluetooth/hci_bcm.c
@@ -117,7 +117,7 @@ static int bcm_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 	BT_DBG("hu %p skb %p", hu, skb);
 
 	/* Prepend skb with frame type */
-	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
+	skb_push_uchar(skb, bt_cb(skb)->pkt_type);
 	skb_queue_tail(&bcm->txq, skb);
 
 	return 0;
diff --git a/drivers/bluetooth/hci_bcsp.c b/drivers/bluetooth/hci_bcsp.c
index dc7dfa6..2ebf1cc 100644
--- a/drivers/bluetooth/hci_bcsp.c
+++ b/drivers/bluetooth/hci_bcsp.c
@@ -518,7 +518,7 @@ static void bcsp_complete_rx_pkt(struct hci_uart *hu)
 			if (hciextn) {
 				desc |= 0xc0;
 				skb_pull(bcsp->rx_skb, 4);
-				memcpy(skb_push(bcsp->rx_skb, 1), &desc, 1);
+				skb_push_uchar(bcsp->rx_skb, desc);
 
 				hdr.evt = 0xff;
 				hdr.plen = bcsp->rx_skb->len;
diff --git a/drivers/bluetooth/hci_h4.c b/drivers/bluetooth/hci_h4.c
index f7190f0..c4a5493 100644
--- a/drivers/bluetooth/hci_h4.c
+++ b/drivers/bluetooth/hci_h4.c
@@ -108,7 +108,7 @@ static int h4_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 	BT_DBG("hu %p skb %p", hu, skb);
 
 	/* Prepend skb with frame type */
-	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
+	skb_push_uchar(skb, bt_cb(skb)->pkt_type);
 	skb_queue_tail(&h4->txq, skb);
 
 	return 0;
diff --git a/drivers/bluetooth/hci_ll.c b/drivers/bluetooth/hci_ll.c
index 9ee24b0..68bdf3f 100644
--- a/drivers/bluetooth/hci_ll.c
+++ b/drivers/bluetooth/hci_ll.c
@@ -307,7 +307,7 @@ static int ll_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 	BT_DBG("hu %p skb %p", hu, skb);
 
 	/* Prepend skb with frame type */
-	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
+	skb_push_uchar(skb, bt_cb(skb)->pkt_type);
 
 	/* lock hcill state */
 	spin_lock_irqsave(&ll->hcill_lock, flags);
diff --git a/drivers/bluetooth/hci_vhci.c b/drivers/bluetooth/hci_vhci.c
index bae2000..627f76b 100644
--- a/drivers/bluetooth/hci_vhci.c
+++ b/drivers/bluetooth/hci_vhci.c
@@ -88,7 +88,7 @@ static int vhci_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		return -EBUSY;
 
-	memcpy(skb_push(skb, 1), &bt_cb(skb)->pkt_type, 1);
+	skb_push_uchar(skb, bt_cb(skb)->pkt_type);
 	skb_queue_tail(&data->readq, skb);
 
 	wake_up_interruptible(&data->read_wait);
diff --git a/drivers/media/radio/wl128x/fmdrv_common.c b/drivers/media/radio/wl128x/fmdrv_common.c
index 704397f..9fdcda6 100644
--- a/drivers/media/radio/wl128x/fmdrv_common.c
+++ b/drivers/media/radio/wl128x/fmdrv_common.c
@@ -1464,7 +1464,7 @@ static long fm_st_receive(void *arg, struct sk_buff *skb)
 		return -EINVAL;
 	}
 
-	memcpy(skb_push(skb, 1), &skb->cb[0], 1);
+	skb_push_uchar(skb, skb->cb[0]);
 	skb_queue_tail(&fmdev->rx_q, skb);
 	tasklet_schedule(&fmdev->rx_task);
 
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 9d15566..13d6f5d 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1972,7 +1972,7 @@ ppp_receive_mp_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 	 * Do protocol ID decompression on the first fragment of each packet.
 	 */
 	if ((PPP_MP_CB(skb)->BEbits & B) && (skb->data[0] & 1))
-		*skb_push(skb, 1) = 0;
+		skb_push_uchar(skb, 0);
 
 	/*
 	 * Expand sequence number to 32 bits, making it as close
diff --git a/drivers/nfc/microread/i2c.c b/drivers/nfc/microread/i2c.c
index 668160b..e175f8d 100644
--- a/drivers/nfc/microread/i2c.c
+++ b/drivers/nfc/microread/i2c.c
@@ -72,7 +72,7 @@ static void microread_i2c_add_len_crc(struct sk_buff *skb)
 	int len;
 
 	len = skb->len;
-	*skb_push(skb, 1) = len;
+	skb_push_uchar(skb, len);
 
 	for (i = 0; i < skb->len; i++)
 		crc = crc ^ skb->data[i];
diff --git a/drivers/nfc/microread/microread.c b/drivers/nfc/microread/microread.c
index 6dd0350..0437b3d 100644
--- a/drivers/nfc/microread/microread.c
+++ b/drivers/nfc/microread/microread.c
@@ -419,7 +419,7 @@ static int microread_im_transceive(struct nfc_hci_dev *hdev,
 	pr_info("data exchange to gate 0x%x\n", target->hci_reader_gate);
 
 	if (target->hci_reader_gate == MICROREAD_GATE_ID_P2P_INITIATOR) {
-		*skb_push(skb, 1) = 0;
+		skb_push_uchar(skb, 0);
 
 		return nfc_hci_send_event(hdev, target->hci_reader_gate,
 				     MICROREAD_EVT_P2P_INITIATOR_EXCHANGE_TO_RF,
@@ -453,7 +453,7 @@ static int microread_im_transceive(struct nfc_hci_dev *hdev,
 		return 1;
 	}
 
-	*skb_push(skb, 1) = control_bits;
+	skb_push_uchar(skb, control_bits);
 
 	info->async_cb_type = MICROREAD_CB_TYPE_READER_ALL;
 	info->async_cb = cb;
diff --git a/drivers/nfc/pn544/i2c.c b/drivers/nfc/pn544/i2c.c
index 4fc9a78..ee05bfd 100644
--- a/drivers/nfc/pn544/i2c.c
+++ b/drivers/nfc/pn544/i2c.c
@@ -289,7 +289,7 @@ static void pn544_hci_i2c_add_len_crc(struct sk_buff *skb)
 	int len;
 
 	len = skb->len + 2;
-	*skb_push(skb, 1) = len;
+	skb_push_uchar(skb, len);
 
 	crc = crc_ccitt(0xffff, skb->data, skb->len);
 	crc = ~crc;
diff --git a/drivers/nfc/pn544/pn544.c b/drivers/nfc/pn544/pn544.c
index 12e819d..cb90e02 100644
--- a/drivers/nfc/pn544/pn544.c
+++ b/drivers/nfc/pn544/pn544.c
@@ -649,8 +649,8 @@ static int pn544_hci_im_transceive(struct nfc_hci_dev *hdev,
 		} else
 			return 1;
 	case PN544_RF_READER_F_GATE:
-		*skb_push(skb, 1) = 0;
-		*skb_push(skb, 1) = 0;
+		skb_push_uchar(skb, 0);
+		skb_push_uchar(skb, 0);
 
 		info->async_cb_type = PN544_CB_TYPE_READER_F;
 		info->async_cb = cb;
@@ -665,7 +665,7 @@ static int pn544_hci_im_transceive(struct nfc_hci_dev *hdev,
 					      PN544_JEWEL_RAW_CMD, skb->data,
 					      skb->len, cb, cb_context);
 	case PN544_RF_READER_NFCIP1_INITIATOR_GATE:
-		*skb_push(skb, 1) = 0;
+		skb_push_uchar(skb, 0);
 
 		return nfc_hci_send_event(hdev, target->hci_reader_gate,
 					PN544_HCI_EVT_SND_DATA, skb->data,
@@ -680,7 +680,7 @@ static int pn544_hci_tm_send(struct nfc_hci_dev *hdev, struct sk_buff *skb)
 	int r;
 
 	/* Set default false for multiple information chaining */
-	*skb_push(skb, 1) = 0;
+	skb_push_uchar(skb, 0);
 
 	r = nfc_hci_send_event(hdev, PN544_RF_READER_NFCIP1_TARGET_GATE,
 			       PN544_HCI_EVT_SND_DATA, skb->data, skb->len);
diff --git a/drivers/nfc/st21nfca/i2c.c b/drivers/nfc/st21nfca/i2c.c
index 5cb0772..2135591 100644
--- a/drivers/nfc/st21nfca/i2c.c
+++ b/drivers/nfc/st21nfca/i2c.c
@@ -177,7 +177,7 @@ static void st21nfca_hci_add_len_crc(struct sk_buff *skb)
 	u16 crc;
 	u8 tmp;
 
-	*skb_push(skb, 1) = 0;
+	skb_push_uchar(skb, 0);
 
 	crc = crc_ccitt(0xffff, skb->data, skb->len);
 	crc = ~crc;
@@ -223,7 +223,7 @@ static int st21nfca_hci_i2c_write(void *phy_id, struct sk_buff *skb)
 	/* add ST21NFCA_SOF_EOF on tail */
 	skb_put_uchar(skb, ST21NFCA_SOF_EOF);
 	/* add ST21NFCA_SOF_EOF on head */
-	*skb_push(skb, 1) = ST21NFCA_SOF_EOF;
+	skb_push_uchar(skb, ST21NFCA_SOF_EOF);
 
 	/*
 	 * Compute byte stuffing
diff --git a/drivers/nfc/st21nfca/st21nfca.c b/drivers/nfc/st21nfca/st21nfca.c
index d251f72..25b7c25 100644
--- a/drivers/nfc/st21nfca/st21nfca.c
+++ b/drivers/nfc/st21nfca/st21nfca.c
@@ -800,12 +800,12 @@ static int st21nfca_hci_im_transceive(struct nfc_hci_dev *hdev,
 		if (target->supported_protocols == NFC_PROTO_NFC_DEP_MASK)
 			return st21nfca_im_send_dep_req(hdev, skb);
 
-		*skb_push(skb, 1) = 0x1a;
+		skb_push_uchar(skb, 0x1a);
 		return nfc_hci_send_cmd_async(hdev, target->hci_reader_gate,
 					      ST21NFCA_WR_XCHG_DATA, skb->data,
 					      skb->len, cb, cb_context);
 	case ST21NFCA_RF_READER_14443_3_A_GATE:
-		*skb_push(skb, 1) = 0x1a;	/* CTR, see spec:10.2.2.1 */
+		skb_push_uchar(skb, 0x1a);	/* CTR, see spec:10.2.2.1 */
 
 		return nfc_hci_send_cmd_async(hdev, target->hci_reader_gate,
 					      ST21NFCA_WR_XCHG_DATA, skb->data,
@@ -815,7 +815,7 @@ static int st21nfca_hci_im_transceive(struct nfc_hci_dev *hdev,
 		info->async_cb = cb;
 		info->async_cb_context = cb_context;
 
-		*skb_push(skb, 1) = 0x17;
+		skb_push_uchar(skb, 0x17);
 
 		return nfc_hci_send_cmd_async(hdev, target->hci_reader_gate,
 					      ST21NFCA_WR_XCHG_DATA, skb->data,
diff --git a/drivers/nfc/st21nfca/st21nfca_dep.c b/drivers/nfc/st21nfca/st21nfca_dep.c
index 8882181..4a5e0c4 100644
--- a/drivers/nfc/st21nfca/st21nfca_dep.c
+++ b/drivers/nfc/st21nfca/st21nfca_dep.c
@@ -316,10 +316,10 @@ int st21nfca_tm_send_dep_res(struct nfc_hci_dev *hdev, struct sk_buff *skb)
 	int r;
 	struct st21nfca_hci_info *info = nfc_hci_get_clientdata(hdev);
 
-	*skb_push(skb, 1) = info->dep_info.curr_nfc_dep_pni;
-	*skb_push(skb, 1) = ST21NFCA_NFCIP1_DEP_RES;
-	*skb_push(skb, 1) = ST21NFCA_NFCIP1_RES;
-	*skb_push(skb, 1) = skb->len;
+	skb_push_uchar(skb, info->dep_info.curr_nfc_dep_pni);
+	skb_push_uchar(skb, ST21NFCA_NFCIP1_DEP_RES);
+	skb_push_uchar(skb, ST21NFCA_NFCIP1_RES);
+	skb_push_uchar(skb, skb->len);
 
 	r = nfc_hci_send_event(hdev, ST21NFCA_RF_CARD_F_GATE,
 			ST21NFCA_EVT_SEND_DATA, skb->data, skb->len);
@@ -466,7 +466,7 @@ static void st21nfca_im_send_psl_req(struct nfc_hci_dev *hdev, u8 did, u8 bsi,
 	psl_req->brs = (0x30 & bsi << 4) | (bri & 0x03);
 	psl_req->fsl = lri;
 
-	*skb_push(skb, 1) = info->dep_info.to | 0x10;
+	skb_push_uchar(skb, info->dep_info.to | 0x10);
 
 	st21nfca_im_send_pdu(info, skb);
 }
@@ -568,7 +568,7 @@ int st21nfca_im_send_atr_req(struct nfc_hci_dev *hdev, u8 *gb, size_t gb_len)
 	}
 	atr_req->length = sizeof(struct st21nfca_atr_req) + hdev->gb_len;
 
-	*skb_push(skb, 1) = info->dep_info.to | 0x10; /* timeout */
+	skb_push_uchar(skb, info->dep_info.to | 0x10); /* timeout */
 
 	info->async_cb_type = ST21NFCA_CB_TYPE_READER_F;
 	info->async_cb_context = info;
@@ -629,10 +629,10 @@ static void st21nfca_im_recv_dep_res_cb(void *context, struct sk_buff *skb,
 		case ST21NFCA_NFC_DEP_PFB_SUPERVISOR_PDU:
 			pr_err("Received a SUPERVISOR PDU\n");
 			skb_pull(skb, size);
-			*skb_push(skb, 1) = ST21NFCA_NFCIP1_DEP_REQ;
-			*skb_push(skb, 1) = ST21NFCA_NFCIP1_REQ;
-			*skb_push(skb, 1) = skb->len;
-			*skb_push(skb, 1) = info->dep_info.to | 0x10;
+			skb_push_uchar(skb, ST21NFCA_NFCIP1_DEP_REQ);
+			skb_push_uchar(skb, ST21NFCA_NFCIP1_REQ);
+			skb_push_uchar(skb, skb->len);
+			skb_push_uchar(skb, info->dep_info.to | 0x10);
 
 			st21nfca_im_send_pdu(info, skb);
 			break;
@@ -655,12 +655,12 @@ int st21nfca_im_send_dep_req(struct nfc_hci_dev *hdev, struct sk_buff *skb)
 	info->async_cb_context = info;
 	info->async_cb = st21nfca_im_recv_dep_res_cb;
 
-	*skb_push(skb, 1) = info->dep_info.curr_nfc_dep_pni;
-	*skb_push(skb, 1) = ST21NFCA_NFCIP1_DEP_REQ;
-	*skb_push(skb, 1) = ST21NFCA_NFCIP1_REQ;
-	*skb_push(skb, 1) = skb->len;
+	skb_push_uchar(skb, info->dep_info.curr_nfc_dep_pni);
+	skb_push_uchar(skb, ST21NFCA_NFCIP1_DEP_REQ);
+	skb_push_uchar(skb, ST21NFCA_NFCIP1_REQ);
+	skb_push_uchar(skb, skb->len);
 
-	*skb_push(skb, 1) = info->dep_info.to | 0x10;
+	skb_push_uchar(skb, info->dep_info.to | 0x10);
 
 	return nfc_hci_send_cmd_async(hdev, ST21NFCA_RF_READER_F_GATE,
 				      ST21NFCA_WR_XCHG_DATA,
diff --git a/drivers/nfc/st21nfcb/ndlc.c b/drivers/nfc/st21nfcb/ndlc.c
index 6014b58..6ed9314 100644
--- a/drivers/nfc/st21nfcb/ndlc.c
+++ b/drivers/nfc/st21nfcb/ndlc.c
@@ -76,7 +76,7 @@ int ndlc_send(struct llt_ndlc *ndlc, struct sk_buff *skb)
 	u8 pcb = PCB_TYPE_DATAFRAME | PCB_DATAFRAME_RETRANSMIT_NO |
 		PCB_FRAME_CRC_INFO_NOTPRESENT;
 
-	*skb_push(skb, 1) = pcb;
+	skb_push_uchar(skb, pcb);
 	skb_queue_tail(&ndlc->send_q, skb);
 
 	schedule_work(&ndlc->sm_work);
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 330c1f4..9aa4ab7 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1558,7 +1558,7 @@ static int ax25_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 	/* Add the PID if one is not supplied by the user in the skb */
 	if (!ax25->pidincl)
-		*skb_push(skb, 1) = sk->sk_protocol;
+		skb_push_uchar(skb, sk->sk_protocol);
 
 	if (sk->sk_type == SOCK_SEQPACKET) {
 		/* Connected mode sockets go via the LAPB machine */
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 56f9edb..7b4f65b 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -194,7 +194,7 @@ void hci_send_to_sock(struct hci_dev *hdev, struct sk_buff *skb)
 				continue;
 
 			/* Put type byte before the data */
-			memcpy(skb_push(skb_copy, 1), &bt_cb(skb)->pkt_type, 1);
+			skb_push_uchar(skb_copy, bt_cb(skb)->pkt_type);
 		}
 
 		nskb = skb_clone(skb_copy, GFP_ATOMIC);
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 9bce318..832dbac 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -484,7 +484,7 @@ int dccp_insert_option_mandatory(struct sk_buff *skb)
 		return -1;
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len++;
-	*skb_push(skb, 1) = DCCPO_MANDATORY;
+	skb_push_uchar(skb, DCCPO_MANDATORY);
 	return 0;
 }
 
diff --git a/net/nfc/digital_technology.c b/net/nfc/digital_technology.c
index cebd666..dbae4b8 100644
--- a/net/nfc/digital_technology.c
+++ b/net/nfc/digital_technology.c
@@ -830,7 +830,7 @@ int digital_in_send_sensf_req(struct nfc_digital_dev *ddev, u8 rf_tech)
 	sensf_req->rc = 0;
 	sensf_req->tsn = 0;
 
-	*skb_push(skb, 1) = size + 1;
+	skb_push_uchar(skb, size + 1);
 
 	if (!DIGITAL_DRV_CAPS_IN_CRC(ddev))
 		digital_skb_add_crc_f(skb);
diff --git a/net/nfc/hci/core.c b/net/nfc/hci/core.c
index ad1e939..a134e35 100644
--- a/net/nfc/hci/core.c
+++ b/net/nfc/hci/core.c
@@ -726,7 +726,7 @@ static int hci_transceive(struct nfc_dev *nfc_dev, struct nfc_target *target,
 				break;
 		}
 
-		*skb_push(skb, 1) = 0;	/* CTR, see spec:10.2.2.1 */
+		skb_push_uchar(skb, 0);	/* CTR, see spec:10.2.2.1 */
 
 		hdev->async_cb_type = HCI_CB_TYPE_TRANSCEIVE;
 		hdev->async_cb = cb;
diff --git a/net/nfc/hci/llc_shdlc.c b/net/nfc/hci/llc_shdlc.c
index a2b0acd..c9e7820 100644
--- a/net/nfc/hci/llc_shdlc.c
+++ b/net/nfc/hci/llc_shdlc.c
@@ -160,7 +160,7 @@ static int llc_shdlc_send_s_frame(struct llc_shdlc *shdlc,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	*skb_push(skb, 1) = SHDLC_CONTROL_HEAD_S | (sframe_type << 3) | nr;
+	skb_push_uchar(skb, SHDLC_CONTROL_HEAD_S | (sframe_type << 3) | nr);
 
 	r = shdlc->xmit_to_drv(shdlc->hdev, skb);
 
@@ -178,7 +178,7 @@ static int llc_shdlc_send_u_frame(struct llc_shdlc *shdlc,
 
 	pr_debug("uframe_modifier=%d\n", uframe_modifier);
 
-	*skb_push(skb, 1) = SHDLC_CONTROL_HEAD_U | uframe_modifier;
+	skb_push_uchar(skb, SHDLC_CONTROL_HEAD_U | uframe_modifier);
 
 	r = shdlc->xmit_to_drv(shdlc->hdev, skb);
 
@@ -551,8 +551,8 @@ static void llc_shdlc_handle_send_queue(struct llc_shdlc *shdlc)
 
 		skb = skb_dequeue(&shdlc->send_q);
 
-		*skb_push(skb, 1) = SHDLC_CONTROL_HEAD_I | (shdlc->ns << 3) |
-				    shdlc->nr;
+		skb_push_uchar(skb,
+			       SHDLC_CONTROL_HEAD_I | (shdlc->ns << 3) | shdlc->nr);
 
 		pr_debug("Sending I-Frame %d, waiting to rcv %d\n", shdlc->ns,
 			 shdlc->nr);
diff --git a/net/nfc/nci/hci.c b/net/nfc/nci/hci.c
index e98bdc3..404af43 100644
--- a/net/nfc/nci/hci.c
+++ b/net/nfc/nci/hci.c
@@ -152,7 +152,7 @@ static int nci_hci_send_data(struct nci_dev *ndev, u8 pipe,
 		return -ENOMEM;
 
 	skb_reserve(skb, 2 + NCI_DATA_HDR_SIZE);
-	*skb_push(skb, 1) = data_type;
+	skb_push_uchar(skb, data_type);
 
 	i = 0;
 	len = conn_info->max_pkt_payload_len;
@@ -167,7 +167,7 @@ static int nci_hci_send_data(struct nci_dev *ndev, u8 pipe,
 			len = conn_info->max_pkt_payload_len - skb->len - 1;
 		}
 
-		*skb_push(skb, 1) = cb;
+		skb_push_uchar(skb, cb);
 
 		if (len > 0)
 			memcpy(skb_put(skb, len), data + i, len);
diff --git a/net/nfc/nci/spi.c b/net/nfc/nci/spi.c
index a102e46..3319bac 100644
--- a/net/nfc/nci/spi.c
+++ b/net/nfc/nci/spi.c
@@ -231,8 +231,8 @@ static struct sk_buff *__nci_spi_read(struct nci_spi *nspi)
 		goto receive_error;
 
 	if (nspi->acknowledge_mode == NCI_SPI_CRC_ENABLED) {
-		*skb_push(skb, 1) = resp_hdr[1];
-		*skb_push(skb, 1) = resp_hdr[0];
+		skb_push_uchar(skb, resp_hdr[1]);
+		skb_push_uchar(skb, resp_hdr[0]);
 	}
 
 	return skb;
-- 
2.1.4
