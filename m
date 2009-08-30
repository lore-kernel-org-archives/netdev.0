From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 33/47] Bluetooth: Initial support for retransmission of packets with REJ frames
Date: Sun, 30 Aug 2009 01:50:47 -0700
Message-ID: <30afb5b2aa83adf4f69e5090d48e1bb04b64c58a.1251621661.git.marcel@holtmann.org>
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
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53324 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203AbZH3Iwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:30 -0400
In-Reply-To: <c74e560cd0101455f1889515e1527e4c2e266113.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

When receiving an I-frame with unexpected txSeq, receiver side start the
recovery procedure by sending a REJ S-frame to the transmitter side. So
the transmitter can re-send the lost I-frame.

This patch just adds a basic support for retransmission, it doesn't
mean that ERTM now has full support for packet retransmission.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |    1 +
 net/bluetooth/l2cap.c         |   57 +++++++++++++++++++++++++++++++----------
 2 files changed, 44 insertions(+), 14 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 0afde8d..a1d8ec4 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -351,6 +351,7 @@ struct l2cap_pinfo {
 #define L2CAP_CONF_MAX_CONF_RSP 2
 
 #define L2CAP_CONN_SAR_SDU         0x01
+#define L2CAP_CONN_UNDER_REJ       0x02
 
 static inline int l2cap_tx_window_full(struct sock *sk)
 {
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 167e025..35e9f5b 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2951,22 +2951,36 @@ static inline int l2cap_data_channel_iframe(struct sock *sk, u16 rx_control, str
 
 	BT_DBG("sk %p rx_control 0x%4.4x len %d", sk, rx_control, skb->len);
 
-	if (tx_seq != pi->expected_tx_seq)
-		return -EINVAL;
+	if (tx_seq == pi->expected_tx_seq) {
+		if (pi->conn_state & L2CAP_CONN_UNDER_REJ)
+			pi->conn_state &= ~L2CAP_CONN_UNDER_REJ;
 
-	err = l2cap_sar_reassembly_sdu(sk, skb, rx_control);
-	if (err < 0)
-		return err;
+		err = l2cap_sar_reassembly_sdu(sk, skb, rx_control);
+		if (err < 0)
+			return err;
+
+		pi->expected_tx_seq = (pi->expected_tx_seq + 1) % 64;
+		pi->num_to_ack = (pi->num_to_ack + 1) % L2CAP_DEFAULT_NUM_TO_ACK;
+		if (pi->num_to_ack == L2CAP_DEFAULT_NUM_TO_ACK - 1) {
+			tx_control |= L2CAP_SUPER_RCV_READY;
+			tx_control |= pi->expected_tx_seq << L2CAP_CTRL_REQSEQ_SHIFT;
+			goto send;
+		}
+	} else {
+		/* Unexpected txSeq. Send a REJ S-frame */
+		kfree_skb(skb);
+		if (!(pi->conn_state & L2CAP_CONN_UNDER_REJ)) {
+			tx_control |= L2CAP_SUPER_REJECT;
+			tx_control |= pi->expected_tx_seq << L2CAP_CTRL_REQSEQ_SHIFT;
+			pi->conn_state |= L2CAP_CONN_UNDER_REJ;
 
-	pi->expected_tx_seq = (pi->expected_tx_seq + 1) % 64;
-	pi->num_to_ack = (pi->num_to_ack + 1) % L2CAP_DEFAULT_NUM_TO_ACK;
-	if (pi->num_to_ack == L2CAP_DEFAULT_NUM_TO_ACK - 1) {
-		tx_control |= L2CAP_CTRL_FRAME_TYPE;
-		tx_control |= L2CAP_SUPER_RCV_READY;
-		tx_control |= pi->expected_tx_seq << L2CAP_CTRL_REQSEQ_SHIFT;
-		err = l2cap_send_sframe(pi, tx_control);
+			goto send;
+		}
 	}
-	return err;
+	return 0;
+
+send:
+	return l2cap_send_sframe(pi, tx_control);
 }
 
 static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, struct sk_buff *skb)
@@ -2982,8 +2996,18 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 		l2cap_ertm_send(sk);
 		break;
 
-	case L2CAP_SUPER_RCV_NOT_READY:
 	case L2CAP_SUPER_REJECT:
+		pi->expected_ack_seq = __get_reqseq(rx_control);
+		l2cap_drop_acked_frames(sk);
+
+		sk->sk_send_head = TX_QUEUE(sk)->next;
+		pi->next_tx_seq = pi->expected_ack_seq;
+
+		l2cap_ertm_send(sk);
+
+		break;
+
+	case L2CAP_SUPER_RCV_NOT_READY:
 	case L2CAP_SUPER_SELECT_REJECT:
 		break;
 	}
@@ -3030,6 +3054,11 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 		if (__is_sar_start(control))
 			len -= 2;
 
+		/*
+		 * We can just drop the corrupted I-frame here.
+		 * Receiver will miss it and start proper recovery
+		 * procedures and ask retransmission.
+		 */
 		if (len > L2CAP_DEFAULT_MAX_PDU_SIZE)
 			goto drop;
 
-- 
1.6.2.5

