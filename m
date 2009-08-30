From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 34/47] Bluetooth: Add support for Retransmission and Monitor Timers
Date: Sun, 30 Aug 2009 01:50:48 -0700
Message-ID: <e90bac061b17cd81bd0df30606c64f4543bf5ca0.1251621661.git.marcel@holtmann.org>
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
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53318 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214AbZH3Iwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:31 -0400
In-Reply-To: <30afb5b2aa83adf4f69e5090d48e1bb04b64c58a.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

L2CAP uses retransmission and monitor timers to inquiry the other side
about unacked I-frames. After sending each I-frame we (re)start the
retransmission timer. If it expires, we start a monitor timer that send a
S-frame with P bit set and wait for S-frame with F bit set. If monitor
timer expires, try again, at a maximum of L2CAP_DEFAULT_MAX_TX.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/bluetooth.h |    1 +
 include/net/bluetooth/l2cap.h     |   15 +++++-
 net/bluetooth/l2cap.c             |   86 +++++++++++++++++++++++++++++++++++--
 3 files changed, 95 insertions(+), 7 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 65a5cf8..b8b9a84 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -139,6 +139,7 @@ struct bt_skb_cb {
 	__u8 pkt_type;
 	__u8 incoming;
 	__u8 tx_seq;
+	__u8 retries;
 };
 #define bt_cb(skb) ((struct bt_skb_cb *)((skb)->cb))
 
diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index a1d8ec4..2cf7003 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -31,9 +31,9 @@
 #define L2CAP_DEFAULT_FLUSH_TO		0xffff
 #define L2CAP_DEFAULT_TX_WINDOW		63
 #define L2CAP_DEFAULT_NUM_TO_ACK        (L2CAP_DEFAULT_TX_WINDOW/5)
-#define L2CAP_DEFAULT_MAX_RECEIVE	1
-#define L2CAP_DEFAULT_RETRANS_TO	300    /* 300 milliseconds */
-#define L2CAP_DEFAULT_MONITOR_TO	1000   /* 1 second */
+#define L2CAP_DEFAULT_MAX_TX		3
+#define L2CAP_DEFAULT_RETRANS_TO	1000    /* 1 second */
+#define L2CAP_DEFAULT_MONITOR_TO	12000   /* 12 seconds */
 #define L2CAP_DEFAULT_MAX_PDU_SIZE	672
 
 #define L2CAP_CONN_TIMEOUT	(40000) /* 40 seconds */
@@ -318,6 +318,7 @@ struct l2cap_pinfo {
 	__u8		req_seq;
 	__u8		expected_tx_seq;
 	__u8		unacked_frames;
+	__u8		retry_count;
 	__u8		num_to_ack;
 	__u16		sdu_len;
 	__u16		partial_sdu_len;
@@ -333,6 +334,8 @@ struct l2cap_pinfo {
 
 	__le16		sport;
 
+	struct timer_list	retrans_timer;
+	struct timer_list	monitor_timer;
 	struct sk_buff_head	tx_queue;
 	struct l2cap_conn	*conn;
 	struct sock		*next_c;
@@ -352,6 +355,12 @@ struct l2cap_pinfo {
 
 #define L2CAP_CONN_SAR_SDU         0x01
 #define L2CAP_CONN_UNDER_REJ       0x02
+#define L2CAP_CONN_WAIT_F          0x04
+
+#define __mod_retrans_timer() mod_timer(&l2cap_pi(sk)->retrans_timer, \
+		jiffies +  msecs_to_jiffies(L2CAP_DEFAULT_RETRANS_TO));
+#define __mod_monitor_timer() mod_timer(&l2cap_pi(sk)->monitor_timer, \
+		jiffies + msecs_to_jiffies(L2CAP_DEFAULT_MONITOR_TO));
 
 static inline int l2cap_tx_window_full(struct sock *sk)
 {
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 35e9f5b..97172f7 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1178,6 +1178,39 @@ static int l2cap_sock_getname(struct socket *sock, struct sockaddr *addr, int *l
 	return 0;
 }
 
+static void l2cap_monitor_timeout(unsigned long arg)
+{
+	struct sock *sk = (void *) arg;
+	u16 control;
+
+	if (l2cap_pi(sk)->retry_count >= l2cap_pi(sk)->remote_max_tx) {
+		l2cap_send_disconn_req(l2cap_pi(sk)->conn, sk);
+		return;
+	}
+
+	l2cap_pi(sk)->retry_count++;
+	__mod_monitor_timer();
+
+	control = L2CAP_CTRL_POLL;
+	control |= L2CAP_SUPER_RCV_READY;
+	l2cap_send_sframe(l2cap_pi(sk), control);
+}
+
+static void l2cap_retrans_timeout(unsigned long arg)
+{
+	struct sock *sk = (void *) arg;
+	u16 control;
+
+	l2cap_pi(sk)->retry_count = 1;
+	__mod_monitor_timer();
+
+	l2cap_pi(sk)->conn_state |= L2CAP_CONN_WAIT_F;
+
+	control = L2CAP_CTRL_POLL;
+	control |= L2CAP_SUPER_RCV_READY;
+	l2cap_send_sframe(l2cap_pi(sk), control);
+}
+
 static void l2cap_drop_acked_frames(struct sock *sk)
 {
 	struct sk_buff *skb;
@@ -1192,6 +1225,9 @@ static void l2cap_drop_acked_frames(struct sock *sk)
 		l2cap_pi(sk)->unacked_frames--;
 	}
 
+	if (!l2cap_pi(sk)->unacked_frames)
+		del_timer(&l2cap_pi(sk)->retrans_timer);
+
 	return;
 }
 
@@ -1216,19 +1252,32 @@ static int l2cap_ertm_send(struct sock *sk)
 	u16 control;
 	int err;
 
+	if (pi->conn_state & L2CAP_CONN_WAIT_F)
+		return 0;
+
 	while ((skb = sk->sk_send_head) && (!l2cap_tx_window_full(sk))) {
 		tx_skb = skb_clone(skb, GFP_ATOMIC);
 
+		if (pi->remote_max_tx &&
+				bt_cb(skb)->retries == pi->remote_max_tx) {
+			l2cap_send_disconn_req(pi->conn, sk);
+			break;
+		}
+
+		bt_cb(skb)->retries++;
+
 		control = get_unaligned_le16(tx_skb->data + L2CAP_HDR_SIZE);
 		control |= (pi->req_seq << L2CAP_CTRL_REQSEQ_SHIFT)
 				| (pi->next_tx_seq << L2CAP_CTRL_TXSEQ_SHIFT);
 		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
 
+
 		err = l2cap_do_send(sk, tx_skb);
 		if (err < 0) {
 			l2cap_send_disconn_req(pi->conn, sk);
 			return err;
 		}
+		__mod_retrans_timer();
 
 		bt_cb(skb)->tx_seq = pi->next_tx_seq;
 		pi->next_tx_seq = (pi->next_tx_seq + 1) % 64;
@@ -1365,6 +1414,8 @@ static struct sk_buff *l2cap_create_ertm_pdu(struct sock *sk, struct msghdr *msg
 		kfree_skb(skb);
 		return ERR_PTR(err);
 	}
+
+	bt_cb(skb)->retries = 0;
 	return skb;
 }
 
@@ -2058,7 +2109,7 @@ done:
 	case L2CAP_MODE_ERTM:
 		rfc.mode            = L2CAP_MODE_ERTM;
 		rfc.txwin_size      = L2CAP_DEFAULT_TX_WINDOW;
-		rfc.max_transmit    = L2CAP_DEFAULT_MAX_RECEIVE;
+		rfc.max_transmit    = L2CAP_DEFAULT_MAX_TX;
 		rfc.retrans_timeout = 0;
 		rfc.monitor_timeout = 0;
 		rfc.max_pdu_size    = cpu_to_le16(L2CAP_DEFAULT_MAX_PDU_SIZE);
@@ -2553,6 +2604,12 @@ static inline int l2cap_config_req(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 		l2cap_pi(sk)->next_tx_seq = 0;
 		l2cap_pi(sk)->expected_ack_seq = 0;
 		l2cap_pi(sk)->unacked_frames = 0;
+
+		setup_timer(&l2cap_pi(sk)->retrans_timer,
+				l2cap_retrans_timeout, (unsigned long) sk);
+		setup_timer(&l2cap_pi(sk)->monitor_timer,
+				l2cap_monitor_timeout, (unsigned long) sk);
+
 		__skb_queue_head_init(TX_QUEUE(sk));
 		l2cap_chan_ready(sk);
 		goto unlock;
@@ -2662,6 +2719,8 @@ static inline int l2cap_disconnect_req(struct l2cap_conn *conn, struct l2cap_cmd
 	sk->sk_shutdown = SHUTDOWN_MASK;
 
 	skb_queue_purge(TX_QUEUE(sk));
+	del_timer(&l2cap_pi(sk)->retrans_timer);
+	del_timer(&l2cap_pi(sk)->monitor_timer);
 
 	l2cap_chan_del(sk, ECONNRESET);
 	bh_unlock_sock(sk);
@@ -2686,6 +2745,8 @@ static inline int l2cap_disconnect_rsp(struct l2cap_conn *conn, struct l2cap_cmd
 		return 0;
 
 	skb_queue_purge(TX_QUEUE(sk));
+	del_timer(&l2cap_pi(sk)->retrans_timer);
+	del_timer(&l2cap_pi(sk)->monitor_timer);
 
 	l2cap_chan_del(sk, 0);
 	bh_unlock_sock(sk);
@@ -2991,9 +3052,26 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 
 	switch (rx_control & L2CAP_CTRL_SUPERVISE) {
 	case L2CAP_SUPER_RCV_READY:
-		pi->expected_ack_seq = __get_reqseq(rx_control);
-		l2cap_drop_acked_frames(sk);
-		l2cap_ertm_send(sk);
+		if (rx_control & L2CAP_CTRL_POLL) {
+			u16 control = L2CAP_CTRL_FINAL;
+			control |= L2CAP_SUPER_RCV_READY;
+			l2cap_send_sframe(l2cap_pi(sk), control);
+		} else if (rx_control & L2CAP_CTRL_FINAL) {
+			if (!(pi->conn_state & L2CAP_CONN_WAIT_F))
+				break;
+
+			pi->conn_state &= ~L2CAP_CONN_WAIT_F;
+			del_timer(&pi->monitor_timer);
+
+			if (pi->unacked_frames > 0)
+				__mod_retrans_timer();
+		} else {
+			pi->expected_ack_seq = __get_reqseq(rx_control);
+			l2cap_drop_acked_frames(sk);
+			if (pi->unacked_frames > 0)
+				__mod_retrans_timer();
+			l2cap_ertm_send(sk);
+		}
 		break;
 
 	case L2CAP_SUPER_REJECT:
-- 
1.6.2.5

