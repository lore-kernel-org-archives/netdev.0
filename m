From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 37/47] Bluetooth: Add support for L2CAP SREJ exception
Date: Sun, 30 Aug 2009 01:50:51 -0700
Message-ID: <8f17154f1f70fcc6faa31ac82164fcf7f0599f38.1251621661.git.marcel@holtmann.org>
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
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53329 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753269AbZH3Iwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:35 -0400
In-Reply-To: <fcc203c30d72dde82692f6b761a80e5ca5fdd8fa.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

When L2CAP loses an I-frame we send a SREJ frame to the transmitter side
requesting the lost packet. This patch implement all Recv I-frame events
on SREJ_SENT state table except the ones that deal with SendRej (the REJ
exception at receiver side is yet not implemented).

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/bluetooth.h |    1 +
 include/net/bluetooth/l2cap.h     |   14 ++-
 net/bluetooth/l2cap.c             |  220 +++++++++++++++++++++++++++++++++----
 3 files changed, 210 insertions(+), 25 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index b8b9a84..718394e 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -140,6 +140,7 @@ struct bt_skb_cb {
 	__u8 incoming;
 	__u8 tx_seq;
 	__u8 retries;
+	__u8 sar;
 };
 #define bt_cb(skb) ((struct bt_skb_cb *)((skb)->cb))
 
diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 59b26bf..9f2126a 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -108,6 +108,7 @@ struct l2cap_conninfo {
 
 #define L2CAP_CTRL_TXSEQ_SHIFT      1
 #define L2CAP_CTRL_REQSEQ_SHIFT     8
+#define L2CAP_CTRL_SAR_SHIFT       14
 
 /* L2CAP Supervisory Function */
 #define L2CAP_SUPER_RCV_READY           0x0000
@@ -290,6 +291,13 @@ struct l2cap_conn {
 /* ----- L2CAP channel and socket info ----- */
 #define l2cap_pi(sk) ((struct l2cap_pinfo *) sk)
 #define TX_QUEUE(sk) (&l2cap_pi(sk)->tx_queue)
+#define SREJ_QUEUE(sk) (&l2cap_pi(sk)->srej_queue)
+#define SREJ_LIST(sk) (&l2cap_pi(sk)->srej_l.list)
+
+struct srej_list {
+	__u8	tx_seq;
+	struct list_head list;
+};
 
 struct l2cap_pinfo {
 	struct bt_sock	bt;
@@ -318,6 +326,8 @@ struct l2cap_pinfo {
 	__u8		expected_ack_seq;
 	__u8		req_seq;
 	__u8		expected_tx_seq;
+	__u8		buffer_seq;
+	__u8		buffer_seq_srej;
 	__u8		unacked_frames;
 	__u8		retry_count;
 	__u8		num_to_ack;
@@ -338,6 +348,8 @@ struct l2cap_pinfo {
 	struct timer_list	retrans_timer;
 	struct timer_list	monitor_timer;
 	struct sk_buff_head	tx_queue;
+	struct sk_buff_head	srej_queue;
+	struct srej_list	srej_l;
 	struct l2cap_conn	*conn;
 	struct sock		*next_c;
 	struct sock		*prev_c;
@@ -356,7 +368,7 @@ struct l2cap_pinfo {
 #define L2CAP_CONF_MAX_CONF_RSP 2
 
 #define L2CAP_CONN_SAR_SDU         0x01
-#define L2CAP_CONN_UNDER_REJ       0x02
+#define L2CAP_CONN_SREJ_SENT       0x02
 #define L2CAP_CONN_WAIT_F          0x04
 
 #define __mod_retrans_timer() mod_timer(&l2cap_pi(sk)->retrans_timer, \
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 4c31900..70aff92 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1292,6 +1292,50 @@ static int l2cap_streaming_send(struct sock *sk)
 	return 0;
 }
 
+static int l2cap_retransmit_frame(struct sock *sk, u8 tx_seq)
+{
+	struct l2cap_pinfo *pi = l2cap_pi(sk);
+	struct sk_buff *skb, *tx_skb;
+	u16 control, fcs;
+	int err;
+
+	skb = skb_peek(TX_QUEUE(sk));
+	do {
+		if (bt_cb(skb)->tx_seq != tx_seq) {
+			if (skb_queue_is_last(TX_QUEUE(sk), skb))
+				break;
+			skb = skb_queue_next(TX_QUEUE(sk), skb);
+			continue;
+		}
+
+		if (pi->remote_max_tx &&
+				bt_cb(skb)->retries == pi->remote_max_tx) {
+			l2cap_send_disconn_req(pi->conn, sk);
+			break;
+		}
+
+		tx_skb = skb_clone(skb, GFP_ATOMIC);
+		bt_cb(skb)->retries++;
+		control = get_unaligned_le16(tx_skb->data + L2CAP_HDR_SIZE);
+		control |= (pi->req_seq << L2CAP_CTRL_REQSEQ_SHIFT)
+				| (tx_seq << L2CAP_CTRL_TXSEQ_SHIFT);
+		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
+
+		if (l2cap_pi(sk)->fcs == L2CAP_FCS_CRC16) {
+			fcs = crc16(0, (u8 *)tx_skb->data, tx_skb->len - 2);
+			put_unaligned_le16(fcs, tx_skb->data + tx_skb->len - 2);
+		}
+
+		err = l2cap_do_send(sk, tx_skb);
+		if (err < 0) {
+			l2cap_send_disconn_req(pi->conn, sk);
+			return err;
+		}
+		break;
+	} while(1);
+	return 0;
+}
+
 static int l2cap_ertm_send(struct sock *sk)
 {
 	struct sk_buff *skb, *tx_skb;
@@ -2705,6 +2749,7 @@ static inline int l2cap_config_req(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 				l2cap_monitor_timeout, (unsigned long) sk);
 
 		__skb_queue_head_init(TX_QUEUE(sk));
+		__skb_queue_head_init(SREJ_QUEUE(sk));
 		l2cap_chan_ready(sk);
 		goto unlock;
 	}
@@ -2784,8 +2829,10 @@ static inline int l2cap_config_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 
 		sk->sk_state = BT_CONNECTED;
 		l2cap_pi(sk)->expected_tx_seq = 0;
+		l2cap_pi(sk)->buffer_seq = 0;
 		l2cap_pi(sk)->num_to_ack = 0;
 		__skb_queue_head_init(TX_QUEUE(sk));
+		__skb_queue_head_init(SREJ_QUEUE(sk));
 		l2cap_chan_ready(sk);
 	}
 
@@ -2817,6 +2864,7 @@ static inline int l2cap_disconnect_req(struct l2cap_conn *conn, struct l2cap_cmd
 	sk->sk_shutdown = SHUTDOWN_MASK;
 
 	skb_queue_purge(TX_QUEUE(sk));
+	skb_queue_purge(SREJ_QUEUE(sk));
 	del_timer(&l2cap_pi(sk)->retrans_timer);
 	del_timer(&l2cap_pi(sk)->monitor_timer);
 
@@ -2843,6 +2891,7 @@ static inline int l2cap_disconnect_rsp(struct l2cap_conn *conn, struct l2cap_cmd
 		return 0;
 
 	skb_queue_purge(TX_QUEUE(sk));
+	skb_queue_purge(SREJ_QUEUE(sk));
 	del_timer(&l2cap_pi(sk)->retrans_timer);
 	del_timer(&l2cap_pi(sk)->monitor_timer);
 
@@ -3038,6 +3087,33 @@ static int l2cap_check_fcs(struct l2cap_pinfo *pi,  struct sk_buff *skb)
 	return 0;
 }
 
+static void l2cap_add_to_srej_queue(struct sock *sk, struct sk_buff *skb, u8 tx_seq, u8 sar)
+{
+	struct sk_buff *next_skb;
+
+	bt_cb(skb)->tx_seq = tx_seq;
+	bt_cb(skb)->sar = sar;
+
+	next_skb = skb_peek(SREJ_QUEUE(sk));
+	if (!next_skb) {
+		__skb_queue_tail(SREJ_QUEUE(sk), skb);
+		return;
+	}
+
+	do {
+		if (bt_cb(next_skb)->tx_seq > tx_seq) {
+			__skb_queue_before(SREJ_QUEUE(sk), next_skb, skb);
+			return;
+		}
+
+		if (skb_queue_is_last(SREJ_QUEUE(sk), next_skb))
+			break;
+
+	} while((next_skb = skb_queue_next(SREJ_QUEUE(sk), next_skb)));
+
+	__skb_queue_tail(SREJ_QUEUE(sk), skb);
+}
+
 static int l2cap_sar_reassembly_sdu(struct sock *sk, struct sk_buff *skb, u16 control)
 {
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
@@ -3118,50 +3194,143 @@ static int l2cap_sar_reassembly_sdu(struct sock *sk, struct sk_buff *skb, u16 co
 	return err;
 }
 
+static void l2cap_check_srej_gap(struct sock *sk, u8 tx_seq)
+{
+	struct sk_buff *skb;
+	u16 control = 0;
+
+	while((skb = skb_peek(SREJ_QUEUE(sk)))) {
+		if (bt_cb(skb)->tx_seq != tx_seq)
+			break;
+
+		skb = skb_dequeue(SREJ_QUEUE(sk));
+		control |= bt_cb(skb)->sar << L2CAP_CTRL_SAR_SHIFT;
+		l2cap_sar_reassembly_sdu(sk, skb, control);
+		l2cap_pi(sk)->buffer_seq_srej =
+			(l2cap_pi(sk)->buffer_seq_srej + 1) % 64;
+		tx_seq++;
+	}
+}
+
+static void l2cap_resend_srejframe(struct sock *sk, u8 tx_seq)
+{
+	struct l2cap_pinfo *pi = l2cap_pi(sk);
+	struct srej_list *l, *tmp;
+	u16 control;
+
+	list_for_each_entry_safe(l,tmp, SREJ_LIST(sk), list) {
+		if (l->tx_seq == tx_seq) {
+			list_del(&l->list);
+			kfree(l);
+			return;
+		}
+		control = L2CAP_SUPER_SELECT_REJECT;
+		control |= l->tx_seq << L2CAP_CTRL_REQSEQ_SHIFT;
+		l2cap_send_sframe(pi, control);
+		list_del(&l->list);
+		list_add_tail(&l->list, SREJ_LIST(sk));
+	}
+}
+
+static void l2cap_send_srejframe(struct sock *sk, u8 tx_seq)
+{
+	struct l2cap_pinfo *pi = l2cap_pi(sk);
+	struct srej_list *new;
+	u16 control;
+
+	while (tx_seq != pi->expected_tx_seq) {
+		control = L2CAP_SUPER_SELECT_REJECT;
+		control |= pi->expected_tx_seq << L2CAP_CTRL_REQSEQ_SHIFT;
+		l2cap_send_sframe(pi, control);
+
+		new = kzalloc(sizeof(struct srej_list), GFP_ATOMIC);
+		new->tx_seq = pi->expected_tx_seq++;
+		list_add_tail(&new->list, SREJ_LIST(sk));
+	}
+	pi->expected_tx_seq++;
+}
+
 static inline int l2cap_data_channel_iframe(struct sock *sk, u16 rx_control, struct sk_buff *skb)
 {
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
 	u8 tx_seq = __get_txseq(rx_control);
 	u16 tx_control = 0;
+	u8 sar = rx_control >> L2CAP_CTRL_SAR_SHIFT;
 	int err = 0;
 
 	BT_DBG("sk %p rx_control 0x%4.4x len %d", sk, rx_control, skb->len);
 
-	if (tx_seq == pi->expected_tx_seq) {
-		if (pi->conn_state & L2CAP_CONN_UNDER_REJ)
-			pi->conn_state &= ~L2CAP_CONN_UNDER_REJ;
+	if (tx_seq == pi->expected_tx_seq)
+		goto expected;
 
-		err = l2cap_sar_reassembly_sdu(sk, skb, rx_control);
-		if (err < 0)
-			return err;
+	if (pi->conn_state & L2CAP_CONN_SREJ_SENT) {
+		struct srej_list *first;
 
-		pi->expected_tx_seq = (pi->expected_tx_seq + 1) % 64;
-		pi->num_to_ack = (pi->num_to_ack + 1) % L2CAP_DEFAULT_NUM_TO_ACK;
-		if (pi->num_to_ack == L2CAP_DEFAULT_NUM_TO_ACK - 1) {
-			tx_control |= L2CAP_SUPER_RCV_READY;
-			tx_control |= pi->expected_tx_seq << L2CAP_CTRL_REQSEQ_SHIFT;
-			goto send;
+		first = list_first_entry(SREJ_LIST(sk),
+				struct srej_list, list);
+		if (tx_seq == first->tx_seq) {
+			l2cap_add_to_srej_queue(sk, skb, tx_seq, sar);
+			l2cap_check_srej_gap(sk, tx_seq);
+
+			list_del(&first->list);
+			kfree(first);
+
+			if (list_empty(SREJ_LIST(sk))) {
+				pi->buffer_seq = pi->buffer_seq_srej;
+				pi->conn_state &= ~L2CAP_CONN_SREJ_SENT;
+			}
+		} else {
+			struct srej_list *l;
+			l2cap_add_to_srej_queue(sk, skb, tx_seq, sar);
+
+			list_for_each_entry(l, SREJ_LIST(sk), list) {
+				if (l->tx_seq == tx_seq) {
+					l2cap_resend_srejframe(sk, tx_seq);
+					return 0;
+				}
+			}
+			l2cap_send_srejframe(sk, tx_seq);
 		}
 	} else {
-		/* Unexpected txSeq. Send a REJ S-frame */
-		kfree_skb(skb);
-		if (!(pi->conn_state & L2CAP_CONN_UNDER_REJ)) {
-			tx_control |= L2CAP_SUPER_REJECT;
-			tx_control |= pi->expected_tx_seq << L2CAP_CTRL_REQSEQ_SHIFT;
-			pi->conn_state |= L2CAP_CONN_UNDER_REJ;
+		pi->conn_state |= L2CAP_CONN_SREJ_SENT;
 
-			goto send;
-		}
+		INIT_LIST_HEAD(SREJ_LIST(sk));
+		pi->buffer_seq_srej = pi->buffer_seq;
+
+		__skb_queue_head_init(SREJ_QUEUE(sk));
+		l2cap_add_to_srej_queue(sk, skb, tx_seq, sar);
+
+		l2cap_send_srejframe(sk, tx_seq);
 	}
 	return 0;
 
-send:
-	return l2cap_send_sframe(pi, tx_control);
+expected:
+	pi->expected_tx_seq = (pi->expected_tx_seq + 1) % 64;
+
+	if (pi->conn_state & L2CAP_CONN_SREJ_SENT) {
+		l2cap_add_to_srej_queue(sk, skb, tx_seq, sar);
+		return 0;
+	}
+
+	pi->buffer_seq = (pi->buffer_seq + 1) % 64;
+
+	err = l2cap_sar_reassembly_sdu(sk, skb, rx_control);
+	if (err < 0)
+		return err;
+
+	pi->num_to_ack = (pi->num_to_ack + 1) % L2CAP_DEFAULT_NUM_TO_ACK;
+	if (pi->num_to_ack == L2CAP_DEFAULT_NUM_TO_ACK - 1) {
+		tx_control |= L2CAP_SUPER_RCV_READY;
+		tx_control |= pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT;
+		l2cap_send_sframe(pi, tx_control);
+	}
+	return 0;
 }
 
 static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, struct sk_buff *skb)
 {
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
+	u8 tx_seq = __get_reqseq(rx_control);
 
 	BT_DBG("sk %p rx_control 0x%4.4x len %d", sk, rx_control, skb->len);
 
@@ -3181,7 +3350,7 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 			if (pi->unacked_frames > 0)
 				__mod_retrans_timer();
 		} else {
-			pi->expected_ack_seq = __get_reqseq(rx_control);
+			pi->expected_ack_seq = tx_seq;
 			l2cap_drop_acked_frames(sk);
 			if (pi->unacked_frames > 0)
 				__mod_retrans_timer();
@@ -3200,8 +3369,11 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 
 		break;
 
-	case L2CAP_SUPER_RCV_NOT_READY:
 	case L2CAP_SUPER_SELECT_REJECT:
+		l2cap_retransmit_frame(sk, tx_seq);
+		break;
+
+	case L2CAP_SUPER_RCV_NOT_READY:
 		break;
 	}
 
-- 
1.6.2.5

