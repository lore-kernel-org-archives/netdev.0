From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 2/8] treewide: Use skb_put_uchar
Date: Mon,  4 May 2015 13:05:46 -0700
Message-ID: <78edbe37c0b86372b13b4e47ab96d60481093f18.1430769295.git.joe@perches.com>
References: <cover.1430769294.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0025.hostedemail.com ([216.40.44.25]:47573 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752543AbbEDUGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:06:08 -0400
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay07.hostedemail.com (Postfix) with ESMTP id CAA73C1F81
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:07 +0000 (UTC)
Received: from joe-laptop.perches.com (pool-173-51-221-2.lsanca.fios.verizon.net [173.51.221.2])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:06 +0000 (UTC)
In-Reply-To: <cover.1430769294.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the uses of
	*skb_put(skb, 1) = <uchar>;
and
	memcpy(skb_put(skb, 1), &<uchar>, 1);

to the new skb_put_uchar(skb, <uchar>);

This will allow skb_put to return void * to avoid some casts.

Done via cocci script:
@@
expression skb;
expression e1;
@@

-	*skb_put(skb, 1) = e1;
+	skb_put_uchar(skb, e1);

@@
expression skb;
expression e1;
expression e2;
@@

-	memcpy(skb_put(skb, 1), &e1, e2);
+	skb_put_uchar(skb, e1);

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/bluetooth/bluecard_cs.c   |  2 +-
 drivers/bluetooth/bt3c_cs.c       |  2 +-
 drivers/bluetooth/btuart_cs.c     |  2 +-
 drivers/bluetooth/btusb.c         |  2 +-
 drivers/bluetooth/dtl1_cs.c       |  4 ++--
 drivers/bluetooth/hci_bcsp.c      | 10 +++++-----
 drivers/bluetooth/hci_h5.c        |  4 ++--
 drivers/bluetooth/hci_vhci.c      |  4 ++--
 drivers/net/usb/cdc_ncm.c         |  2 +-
 drivers/net/usb/net1080.c         |  2 +-
 drivers/net/usb/zaurus.c          |  8 ++++----
 drivers/nfc/microread/i2c.c       |  4 ++--
 drivers/nfc/microread/microread.c |  4 ++--
 drivers/nfc/pn533.c               | 30 +++++++++++++++---------------
 drivers/nfc/pn544/i2c.c           |  6 +++---
 drivers/nfc/port100.c             |  4 ++--
 drivers/nfc/st21nfca/i2c.c        |  6 +++---
 net/bluetooth/hidp/core.c         |  2 +-
 net/decnet/dn_nsp_out.c           | 12 ++++++------
 net/nfc/digital_core.c            |  4 ++--
 net/nfc/digital_dep.c             |  2 +-
 net/nfc/digital_technology.c      | 12 ++++++------
 net/nfc/hci/core.c                |  2 +-
 net/nfc/hci/llc_shdlc.c           |  4 ++--
 net/nfc/llcp_commands.c           |  2 +-
 net/nfc/nci/hci.c                 |  2 +-
 net/nfc/nci/spi.c                 |  8 ++++----
 27 files changed, 73 insertions(+), 73 deletions(-)

diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index 35e63aa..95c931b 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -447,7 +447,7 @@ static void bluecard_receive(struct bluecard_info *info,
 
 		} else {
 
-			*skb_put(info->rx_skb, 1) = buf[i];
+			skb_put_uchar(info->rx_skb, buf[i]);
 			info->rx_count--;
 
 			if (info->rx_count == 0) {
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 4f7e8d4..d6e402d 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -285,7 +285,7 @@ static void bt3c_receive(struct bt3c_info *info)
 
 			__u8 x = inb(iobase + DATA_L);
 
-			*skb_put(info->rx_skb, 1) = x;
+			skb_put_uchar(info->rx_skb, x);
 			inb(iobase + DATA_H);
 			info->rx_count--;
 
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index abb4d21..a96d56c 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -233,7 +233,7 @@ static void btuart_receive(struct btuart_info *info)
 
 		} else {
 
-			*skb_put(info->rx_skb, 1) = inb(iobase + UART_RX);
+			skb_put_uchar(info->rx_skb, inb(iobase + UART_RX));
 			info->rx_count--;
 
 			if (info->rx_count == 0) {
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index de7b236..fbc9fb9 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -1726,7 +1726,7 @@ static int inject_cmd_complete(struct hci_dev *hdev, __u16 opcode)
 	evt->ncmd = 0x01;
 	evt->opcode = cpu_to_le16(opcode);
 
-	*skb_put(skb, 1) = 0x00;
+	skb_put_uchar(skb, 0x00);
 
 	bt_cb(skb)->pkt_type = HCI_EVENT_PKT;
 
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 78e10f0..b3631c5 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -226,7 +226,7 @@ static void dtl1_receive(struct dtl1_info *info)
 			}
 		}
 
-		*skb_put(info->rx_skb, 1) = inb(iobase + UART_RX);
+		skb_put_uchar(info->rx_skb, inb(iobase + UART_RX));
 		nsh = (struct nsh *)info->rx_skb->data;
 
 		info->rx_count--;
@@ -418,7 +418,7 @@ static int dtl1_hci_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 	skb_reserve(s, NSHL);
 	skb_copy_from_linear_data(skb, skb_put(s, skb->len), skb->len);
 	if (skb->len & 0x0001)
-		*skb_put(s, 1) = 0;	/* PAD */
+		skb_put_uchar(s, 0);	/* PAD */
 
 	/* Prepend skb with Nokia frame header and queue */
 	memcpy(skb_push(s, NSHL), &nsh, NSHL);
diff --git a/drivers/bluetooth/hci_bcsp.c b/drivers/bluetooth/hci_bcsp.c
index dc8e3d4..dc7dfa6 100644
--- a/drivers/bluetooth/hci_bcsp.c
+++ b/drivers/bluetooth/hci_bcsp.c
@@ -125,7 +125,7 @@ static void bcsp_slip_msgdelim(struct sk_buff *skb)
 {
 	const char pkt_delim = 0xc0;
 
-	memcpy(skb_put(skb, 1), &pkt_delim, 1);
+	skb_put_uchar(skb, pkt_delim);
 }
 
 static void bcsp_slip_one_byte(struct sk_buff *skb, u8 c)
@@ -141,7 +141,7 @@ static void bcsp_slip_one_byte(struct sk_buff *skb, u8 c)
 		memcpy(skb_put(skb, 2), &esc_db, 2);
 		break;
 	default:
-		memcpy(skb_put(skb, 1), &c, 1);
+		skb_put_uchar(skb, c);
 	}
 }
 
@@ -435,7 +435,7 @@ static inline void bcsp_unslip_one_byte(struct bcsp_struct *bcsp, unsigned char
 			bcsp->rx_esc_state = BCSP_ESCSTATE_ESC;
 			break;
 		default:
-			memcpy(skb_put(bcsp->rx_skb, 1), &byte, 1);
+			skb_put_uchar(bcsp->rx_skb, byte);
 			if ((bcsp->rx_skb-> data[0] & 0x40) != 0 && 
 					bcsp->rx_state != BCSP_W4_CRC)
 				bcsp_crc_update(&bcsp->message_crc, byte);
@@ -446,7 +446,7 @@ static inline void bcsp_unslip_one_byte(struct bcsp_struct *bcsp, unsigned char
 	case BCSP_ESCSTATE_ESC:
 		switch (byte) {
 		case 0xdc:
-			memcpy(skb_put(bcsp->rx_skb, 1), &c0, 1);
+			skb_put_uchar(bcsp->rx_skb, c0);
 			if ((bcsp->rx_skb-> data[0] & 0x40) != 0 && 
 					bcsp->rx_state != BCSP_W4_CRC)
 				bcsp_crc_update(&bcsp-> message_crc, 0xc0);
@@ -455,7 +455,7 @@ static inline void bcsp_unslip_one_byte(struct bcsp_struct *bcsp, unsigned char
 			break;
 
 		case 0xdd:
-			memcpy(skb_put(bcsp->rx_skb, 1), &db, 1);
+			skb_put_uchar(bcsp->rx_skb, db);
 			if ((bcsp->rx_skb-> data[0] & 0x40) != 0 && 
 					bcsp->rx_state != BCSP_W4_CRC) 
 				bcsp_crc_update(&bcsp-> message_crc, 0xdb);
diff --git a/drivers/bluetooth/hci_h5.c b/drivers/bluetooth/hci_h5.c
index 3455cec..429fbb2 100644
--- a/drivers/bluetooth/hci_h5.c
+++ b/drivers/bluetooth/hci_h5.c
@@ -585,7 +585,7 @@ static void h5_slip_delim(struct sk_buff *skb)
 {
 	const char delim = SLIP_DELIMITER;
 
-	memcpy(skb_put(skb, 1), &delim, 1);
+	skb_put_uchar(skb, delim);
 }
 
 static void h5_slip_one_byte(struct sk_buff *skb, u8 c)
@@ -601,7 +601,7 @@ static void h5_slip_one_byte(struct sk_buff *skb, u8 c)
 		memcpy(skb_put(skb, 2), &esc_esc, 2);
 		break;
 	default:
-		memcpy(skb_put(skb, 1), &c, 1);
+		skb_put_uchar(skb, c);
 	}
 }
 
diff --git a/drivers/bluetooth/hci_vhci.c b/drivers/bluetooth/hci_vhci.c
index 6653473..bae2000 100644
--- a/drivers/bluetooth/hci_vhci.c
+++ b/drivers/bluetooth/hci_vhci.c
@@ -150,8 +150,8 @@ static int vhci_create_device(struct vhci_data *data, __u8 opcode)
 
 	bt_cb(skb)->pkt_type = HCI_VENDOR_PKT;
 
-	*skb_put(skb, 1) = 0xff;
-	*skb_put(skb, 1) = opcode;
+	skb_put_uchar(skb, 0xff);
+	skb_put_uchar(skb, opcode);
 	put_unaligned_le16(hdev->id, skb_put(skb, 2));
 	skb_queue_tail(&data->readq, skb);
 
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index c3e4da9..f57c3a5 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1164,7 +1164,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 		memset(skb_put(skb_out, ctx->tx_max - skb_out->len), 0,
 		       ctx->tx_max - skb_out->len);
 	else if (skb_out->len < ctx->tx_max && (skb_out->len % dev->maxpacket) == 0)
-		*skb_put(skb_out, 1) = 0;	/* force short packet */
+		skb_put_uchar(skb_out, 0);	/* force short packet */
 
 	/* set final frame length */
 	nth16 = (struct usb_cdc_ncm_nth16 *)skb_out->data;
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 4cbdb13..384d736 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -482,7 +482,7 @@ encapsulate:
 
 	/* maybe pad; then trailer */
 	if (!((skb->len + sizeof *trailer) & 0x01))
-		*skb_put(skb, 1) = PAD_BYTE;
+		skb_put_uchar(skb, PAD_BYTE);
 	trailer = (struct nc_trailer *) skb_put(skb, sizeof *trailer);
 	put_unaligned(header->packet_id, &trailer->packet_id);
 #if 0
diff --git a/drivers/net/usb/zaurus.c b/drivers/net/usb/zaurus.c
index 6aaa6eb..96cf99a 100644
--- a/drivers/net/usb/zaurus.c
+++ b/drivers/net/usb/zaurus.c
@@ -74,10 +74,10 @@ done:
 		fcs = crc32_le(~0, skb->data, skb->len);
 		fcs = ~fcs;
 
-		*skb_put (skb, 1) = fcs       & 0xff;
-		*skb_put (skb, 1) = (fcs>> 8) & 0xff;
-		*skb_put (skb, 1) = (fcs>>16) & 0xff;
-		*skb_put (skb, 1) = (fcs>>24) & 0xff;
+		skb_put_uchar(skb, fcs);
+		skb_put_uchar(skb, fcs >> 8);
+		skb_put_uchar(skb, fcs >> 16);
+		skb_put_uchar(skb, fcs >> 24);
 	}
 	return skb;
 }
diff --git a/drivers/nfc/microread/i2c.c b/drivers/nfc/microread/i2c.c
index 661e2c8..668160b 100644
--- a/drivers/nfc/microread/i2c.c
+++ b/drivers/nfc/microread/i2c.c
@@ -77,7 +77,7 @@ static void microread_i2c_add_len_crc(struct sk_buff *skb)
 	for (i = 0; i < skb->len; i++)
 		crc = crc ^ skb->data[i];
 
-	*skb_put(skb, 1) = crc;
+	skb_put_uchar(skb, crc);
 }
 
 static void microread_i2c_remove_len_crc(struct sk_buff *skb)
@@ -175,7 +175,7 @@ static int microread_i2c_read(struct microread_i2c_phy *phy,
 		goto flush;
 	}
 
-	*skb_put(*skb, 1) = len;
+	skb_put_uchar(*skb, len);
 
 	r = i2c_master_recv(client, skb_put(*skb, len), len);
 	if (r != len) {
diff --git a/drivers/nfc/microread/microread.c b/drivers/nfc/microread/microread.c
index f454dc6..6dd0350 100644
--- a/drivers/nfc/microread/microread.c
+++ b/drivers/nfc/microread/microread.c
@@ -441,8 +441,8 @@ static int microread_im_transceive(struct nfc_hci_dev *hdev,
 
 		crc = crc_ccitt(0xffff, skb->data, skb->len);
 		crc = ~crc;
-		*skb_put(skb, 1) = crc & 0xff;
-		*skb_put(skb, 1) = crc >> 8;
+		skb_put_uchar(skb, crc & 0xff);
+		skb_put_uchar(skb, crc >> 8);
 		break;
 	case MICROREAD_GATE_ID_MREAD_NFC_T3:
 		control_bits = 0xDB;
diff --git a/drivers/nfc/pn533.c b/drivers/nfc/pn533.c
index a03e4eb..8d9c396 100644
--- a/drivers/nfc/pn533.c
+++ b/drivers/nfc/pn533.c
@@ -1587,7 +1587,7 @@ static struct sk_buff *pn533_alloc_poll_tg_frame(struct pn533 *dev)
 		return NULL;
 
 	/* DEP support only */
-	*skb_put(skb, 1) = PN533_INIT_TARGET_DEP;
+	skb_put_uchar(skb, PN533_INIT_TARGET_DEP);
 
 	/* MIFARE params */
 	memcpy(skb_put(skb, 6), mifare_params, 6);
@@ -1603,13 +1603,13 @@ static struct sk_buff *pn533_alloc_poll_tg_frame(struct pn533 *dev)
 	memcpy(nfcid3, felica, 8);
 
 	/* General bytes */
-	*skb_put(skb, 1) = gbytes_len;
+	skb_put_uchar(skb, gbytes_len);
 
 	gb = skb_put(skb, gbytes_len);
 	memcpy(gb, gbytes, gbytes_len);
 
 	/* Len Tk */
-	*skb_put(skb, 1) = 0;
+	skb_put_uchar(skb, 0);
 
 	return skb;
 }
@@ -1844,8 +1844,8 @@ static void pn533_wq_rf(struct work_struct *work)
 	if (!skb)
 		return;
 
-	*skb_put(skb, 1) = PN533_CFGITEM_RF_FIELD;
-	*skb_put(skb, 1) = PN533_CFGITEM_RF_FIELD_AUTO_RFCA;
+	skb_put_uchar(skb, PN533_CFGITEM_RF_FIELD);
+	skb_put_uchar(skb, PN533_CFGITEM_RF_FIELD_AUTO_RFCA);
 
 	rc = pn533_send_cmd_async(dev, PN533_CMD_RF_CONFIGURATION, skb,
 				  pn533_rf_complete, NULL);
@@ -1941,8 +1941,8 @@ static int pn533_poll_dep(struct nfc_dev *nfc_dev)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = 0x01;  /* Active */
-	*skb_put(skb, 1) = 0x02;  /* 424 kbps */
+	skb_put_uchar(skb, 0x01);  /* Active */
+	skb_put_uchar(skb, 0x02);  /* 424 kbps */
 
 	next = skb_put(skb, 1);  /* Next */
 	*next = 0;
@@ -2190,8 +2190,8 @@ static int pn533_activate_target_nfcdep(struct pn533 *dev)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, sizeof(u8)) = 1; /* TG */
-	*skb_put(skb, sizeof(u8)) = 0; /* Next */
+	skb_put_uchar(skb, 1);	/* TG */
+	skb_put_uchar(skb, 0);	/* Next */
 
 	resp = pn533_send_cmd_sync(dev, PN533_CMD_IN_ATR, skb);
 	if (IS_ERR(resp))
@@ -2284,7 +2284,7 @@ static void pn533_deactivate_target(struct nfc_dev *nfc_dev,
 	if (!skb)
 		return;
 
-	*skb_put(skb, 1) = 1; /* TG*/
+	skb_put_uchar(skb, 1); /* TG*/
 
 	resp = pn533_send_cmd_sync(dev, PN533_CMD_IN_RELEASE, skb);
 	if (IS_ERR(resp))
@@ -2400,8 +2400,8 @@ static int pn533_dep_link_up(struct nfc_dev *nfc_dev, struct nfc_target *target,
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = !comm_mode;  /* ActPass */
-	*skb_put(skb, 1) = 0x02;  /* 424 kbps */
+	skb_put_uchar(skb, !comm_mode);  /* ActPass */
+	skb_put_uchar(skb, 0x02);  /* 424 kbps */
 
 	next = skb_put(skb, 1);  /* Next */
 	*next = 0;
@@ -2782,7 +2782,7 @@ static void pn533_wq_mi_recv(struct work_struct *work)
 			break;
 		}
 	default:
-		*skb_put(skb, sizeof(u8)) =  1; /*TG*/
+		skb_put_uchar(skb, 1);	/*TG*/
 
 		rc = pn533_send_cmd_direct_async(dev,
 						 PN533_CMD_IN_DATA_EXCHANGE,
@@ -2877,7 +2877,7 @@ static int pn533_set_configuration(struct pn533 *dev, u8 cfgitem, u8 *cfgdata,
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, sizeof(cfgitem)) = cfgitem;
+	skb_put_uchar(skb, cfgitem);
 	memcpy(skb_put(skb, cfgdata_len), cfgdata, cfgdata_len);
 
 	resp = pn533_send_cmd_sync(dev, PN533_CMD_RF_CONFIGURATION, skb);
@@ -2922,7 +2922,7 @@ static int pn533_pasori_fw_reset(struct pn533 *dev)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, sizeof(u8)) = 0x1;
+	skb_put_uchar(skb, 0x1);
 
 	resp = pn533_send_cmd_sync(dev, 0x18, skb);
 	if (IS_ERR(resp))
diff --git a/drivers/nfc/pn544/i2c.c b/drivers/nfc/pn544/i2c.c
index 6fd986f..4fc9a78 100644
--- a/drivers/nfc/pn544/i2c.c
+++ b/drivers/nfc/pn544/i2c.c
@@ -293,8 +293,8 @@ static void pn544_hci_i2c_add_len_crc(struct sk_buff *skb)
 
 	crc = crc_ccitt(0xffff, skb->data, skb->len);
 	crc = ~crc;
-	*skb_put(skb, 1) = crc & 0xff;
-	*skb_put(skb, 1) = crc >> 8;
+	skb_put_uchar(skb, crc & 0xff);
+	skb_put_uchar(skb, crc >> 8);
 }
 
 static void pn544_hci_i2c_remove_len_crc(struct sk_buff *skb)
@@ -397,7 +397,7 @@ static int pn544_hci_i2c_read(struct pn544_i2c_phy *phy, struct sk_buff **skb)
 		goto flush;
 	}
 
-	*skb_put(*skb, 1) = len;
+	skb_put_uchar(*skb, len);
 
 	r = i2c_master_recv(client, skb_put(*skb, len), len);
 	if (r != len) {
diff --git a/drivers/nfc/port100.c b/drivers/nfc/port100.c
index 87d5099..a86ea8f 100644
--- a/drivers/nfc/port100.c
+++ b/drivers/nfc/port100.c
@@ -915,7 +915,7 @@ static int port100_set_command_type(struct port100 *dev, u8 command_type)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, sizeof(u8)) = command_type;
+	skb_put_uchar(skb, command_type);
 
 	resp = port100_send_cmd_sync(dev, PORT100_CMD_SET_COMMAND_TYPE, skb);
 	if (IS_ERR(resp))
@@ -983,7 +983,7 @@ static int port100_switch_rf(struct nfc_digital_dev *ddev, bool on)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = on ? 1 : 0;
+	skb_put_uchar(skb, on ? 1 : 0);
 
 	resp = port100_send_cmd_sync(dev, PORT100_CMD_SWITCH_RF, skb);
 
diff --git a/drivers/nfc/st21nfca/i2c.c b/drivers/nfc/st21nfca/i2c.c
index a321439..5cb0772 100644
--- a/drivers/nfc/st21nfca/i2c.c
+++ b/drivers/nfc/st21nfca/i2c.c
@@ -183,10 +183,10 @@ static void st21nfca_hci_add_len_crc(struct sk_buff *skb)
 	crc = ~crc;
 
 	tmp = crc & 0x00ff;
-	*skb_put(skb, 1) = tmp;
+	skb_put_uchar(skb, tmp);
 
 	tmp = (crc >> 8) & 0x00ff;
-	*skb_put(skb, 1) = tmp;
+	skb_put_uchar(skb, tmp);
 }
 
 static void st21nfca_hci_remove_len_crc(struct sk_buff *skb)
@@ -221,7 +221,7 @@ static int st21nfca_hci_i2c_write(void *phy_id, struct sk_buff *skb)
 	st21nfca_hci_add_len_crc(skb);
 
 	/* add ST21NFCA_SOF_EOF on tail */
-	*skb_put(skb, 1) = ST21NFCA_SOF_EOF;
+	skb_put_uchar(skb, ST21NFCA_SOF_EOF);
 	/* add ST21NFCA_SOF_EOF on head */
 	*skb_push(skb, 1) = ST21NFCA_SOF_EOF;
 
diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 9070dfd..4656a86 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -112,7 +112,7 @@ static int hidp_send_message(struct hidp_session *session, struct socket *sock,
 		return -ENOMEM;
 	}
 
-	*skb_put(skb, 1) = hdr;
+	skb_put_uchar(skb, hdr);
 	if (data && size > 0)
 		memcpy(skb_put(skb, size), data, size);
 
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 1aaa51e..62364f7 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -530,7 +530,7 @@ void dn_send_conn_conf(struct sock *sk, gfp_t gfp)
 	msg->info = scp->info_loc;
 	msg->segsize = cpu_to_le16(scp->segsize_loc);
 
-	*skb_put(skb,1) = len;
+	skb_put_uchar(skb, len);
 
 	if (len > 0)
 		memcpy(skb_put(skb, len), scp->conndata_out.opt_data, len);
@@ -686,25 +686,25 @@ void dn_nsp_send_conninit(struct sock *sk, unsigned char msgflg)
 	if (scp->peer.sdn_flags & SDF_UICPROXY)
 		menuver |= DN_MENUVER_UIC;
 
-	*skb_put(skb, 1) = menuver;	/* Menu Version		*/
+	skb_put_uchar(skb, menuver);	/* Menu Version		*/
 
 	aux = scp->accessdata.acc_userl;
-	*skb_put(skb, 1) = aux;
+	skb_put_uchar(skb, aux);
 	if (aux > 0)
 		memcpy(skb_put(skb, aux), scp->accessdata.acc_user, aux);
 
 	aux = scp->accessdata.acc_passl;
-	*skb_put(skb, 1) = aux;
+	skb_put_uchar(skb, aux);
 	if (aux > 0)
 		memcpy(skb_put(skb, aux), scp->accessdata.acc_pass, aux);
 
 	aux = scp->accessdata.acc_accl;
-	*skb_put(skb, 1) = aux;
+	skb_put_uchar(skb, aux);
 	if (aux > 0)
 		memcpy(skb_put(skb, aux), scp->accessdata.acc_acc, aux);
 
 	aux = (__u8)le16_to_cpu(scp->conndata_out.opt_optl);
-	*skb_put(skb, 1) = aux;
+	skb_put_uchar(skb, aux);
 	if (aux > 0)
 		memcpy(skb_put(skb, aux), scp->conndata_out.opt_data, aux);
 
diff --git a/net/nfc/digital_core.c b/net/nfc/digital_core.c
index 009bcf3..bfcb40d 100644
--- a/net/nfc/digital_core.c
+++ b/net/nfc/digital_core.c
@@ -70,8 +70,8 @@ void digital_skb_add_crc(struct sk_buff *skb, crc_func_t crc_func, u16 init,
 	if (msb_first)
 		crc = __fswab16(crc);
 
-	*skb_put(skb, 1) = crc & 0xFF;
-	*skb_put(skb, 1) = (crc >> 8) & 0xFF;
+	skb_put_uchar(skb, crc & 0xFF);
+	skb_put_uchar(skb, (crc >> 8) & 0xFF);
 }
 
 int digital_skb_check_crc(struct sk_buff *skb, crc_func_t crc_func,
diff --git a/net/nfc/digital_dep.c b/net/nfc/digital_dep.c
index f72be74..608c3d7 100644
--- a/net/nfc/digital_dep.c
+++ b/net/nfc/digital_dep.c
@@ -612,7 +612,7 @@ static int digital_in_send_rtox(struct nfc_digital_dev *ddev,
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = rtox;
+	skb_put_uchar(skb, rtox);
 
 	skb_push(skb, sizeof(struct digital_dep_req_res));
 
diff --git a/net/nfc/digital_technology.c b/net/nfc/digital_technology.c
index fb58ed2d..cebd666 100644
--- a/net/nfc/digital_technology.c
+++ b/net/nfc/digital_technology.c
@@ -266,8 +266,8 @@ static int digital_in_send_rats(struct nfc_digital_dev *ddev,
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = DIGITAL_RATS_BYTE1;
-	*skb_put(skb, 1) = DIGITAL_RATS_PARAM;
+	skb_put_uchar(skb, DIGITAL_RATS_BYTE1);
+	skb_put_uchar(skb, DIGITAL_RATS_PARAM);
 
 	rc = digital_in_send_cmd(ddev, skb, 30, digital_in_recv_ats,
 				 target);
@@ -470,8 +470,8 @@ static int digital_in_send_sdd_req(struct nfc_digital_dev *ddev,
 	else
 		sel_cmd = DIGITAL_CMD_SEL_REQ_CL3;
 
-	*skb_put(skb, sizeof(u8)) = sel_cmd;
-	*skb_put(skb, sizeof(u8)) = DIGITAL_SDD_REQ_SEL_PAR;
+	skb_put_uchar(skb, sel_cmd);
+	skb_put_uchar(skb, DIGITAL_SDD_REQ_SEL_PAR);
 
 	return digital_in_send_cmd(ddev, skb, 30, digital_in_recv_sdd_res,
 				   target);
@@ -541,7 +541,7 @@ int digital_in_send_sens_req(struct nfc_digital_dev *ddev, u8 rf_tech)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, sizeof(u8)) = DIGITAL_CMD_SENS_REQ;
+	skb_put_uchar(skb, DIGITAL_CMD_SENS_REQ);
 
 	rc = digital_in_send_cmd(ddev, skb, 30, digital_in_recv_sens_res, NULL);
 	if (rc)
@@ -939,7 +939,7 @@ static int digital_tg_send_sel_res(struct nfc_digital_dev *ddev)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = DIGITAL_SEL_RES_NFC_DEP;
+	skb_put_uchar(skb, DIGITAL_SEL_RES_NFC_DEP);
 
 	if (!DIGITAL_DRV_CAPS_TG_CRC(ddev))
 		digital_skb_add_crc_a(skb);
diff --git a/net/nfc/hci/core.c b/net/nfc/hci/core.c
index 6e061da..ad1e939 100644
--- a/net/nfc/hci/core.c
+++ b/net/nfc/hci/core.c
@@ -873,7 +873,7 @@ static void nfc_hci_recv_from_llc(struct nfc_hci_dev *hdev, struct sk_buff *skb)
 			return;
 		}
 
-		*skb_put(hcp_skb, NFC_HCI_HCP_PACKET_HEADER_LEN) = pipe;
+		skb_put_uchar(hcp_skb, pipe);
 
 		skb_queue_walk(&hdev->rx_hcp_frags, frag_skb) {
 			msg_len = frag_skb->len - NFC_HCI_HCP_PACKET_HEADER_LEN;
diff --git a/net/nfc/hci/llc_shdlc.c b/net/nfc/hci/llc_shdlc.c
index 401c7e2..a2b0acd 100644
--- a/net/nfc/hci/llc_shdlc.c
+++ b/net/nfc/hci/llc_shdlc.c
@@ -382,8 +382,8 @@ static int llc_shdlc_connect_initiate(struct llc_shdlc *shdlc)
 	if (skb == NULL)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = SHDLC_MAX_WINDOW;
-	*skb_put(skb, 1) = SHDLC_SREJ_SUPPORT ? 1 : 0;
+	skb_put_uchar(skb, SHDLC_MAX_WINDOW);
+	skb_put_uchar(skb, SHDLC_SREJ_SUPPORT ? 1 : 0);
 
 	return llc_shdlc_send_u_frame(shdlc, skb, U_FRAME_RSET);
 }
diff --git a/net/nfc/llcp_commands.c b/net/nfc/llcp_commands.c
index 3621a90..743b398 100644
--- a/net/nfc/llcp_commands.c
+++ b/net/nfc/llcp_commands.c
@@ -623,7 +623,7 @@ int nfc_llcp_send_dm(struct nfc_llcp_local *local, u8 ssap, u8 dsap, u8 reason)
 
 	skb = llcp_add_header(skb, dsap, ssap, LLCP_PDU_DM);
 
-	memcpy(skb_put(skb, 1), &reason, 1);
+	skb_put_uchar(skb, reason);
 
 	skb_queue_head(&local->tx_queue, skb);
 
diff --git a/net/nfc/nci/hci.c b/net/nfc/nci/hci.c
index ed54ec5..e98bdc3 100644
--- a/net/nfc/nci/hci.c
+++ b/net/nfc/nci/hci.c
@@ -431,7 +431,7 @@ void nci_hci_data_received_cb(void *context,
 			return;
 		}
 
-		*skb_put(hcp_skb, NCI_HCI_HCP_PACKET_HEADER_LEN) = pipe;
+		skb_put_uchar(hcp_skb, pipe);
 
 		skb_queue_walk(&ndev->hci_dev->rx_hcp_frags, frag_skb) {
 		       msg_len = frag_skb->len - NCI_HCI_HCP_PACKET_HEADER_LEN;
diff --git a/net/nfc/nci/spi.c b/net/nfc/nci/spi.c
index ec250e7..a102e46 100644
--- a/net/nfc/nci/spi.c
+++ b/net/nfc/nci/spi.c
@@ -83,8 +83,8 @@ int nci_spi_send(struct nci_spi *nspi,
 		u16 crc;
 
 		crc = crc_ccitt(CRC_INIT, skb->data, skb->len);
-		*skb_put(skb, 1) = crc >> 8;
-		*skb_put(skb, 1) = crc & 0xFF;
+		skb_put_uchar(skb, crc >> 8);
+		skb_put_uchar(skb, crc & 0xFF);
 	}
 
 	if (write_handshake_completion)	{
@@ -168,8 +168,8 @@ static int send_acknowledge(struct nci_spi *nspi, u8 acknowledge)
 	hdr[3] = 0;
 
 	crc = crc_ccitt(CRC_INIT, skb->data, skb->len);
-	*skb_put(skb, 1) = crc >> 8;
-	*skb_put(skb, 1) = crc & 0xFF;
+	skb_put_uchar(skb, crc >> 8);
+	skb_put_uchar(skb, crc & 0xFF);
 
 	ret = __nci_spi_send(nspi, skb, 0);
 
-- 
2.1.4
