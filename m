From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 35/47] Bluetooth: Enable Streaming Mode for L2CAP
Date: Sun, 30 Aug 2009 01:50:49 -0700
Message-ID: <6840ed0770d79b9bb0800e5e026a067040ef18f5.1251621661.git.marcel@holtmann.org>
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
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53313 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbZH3Iwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:32 -0400
In-Reply-To: <e90bac061b17cd81bd0df30606c64f4543bf5ca0.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

Streaming Mode is helpful for the Bluetooth streaming based profiles, such
as A2DP. It doesn't have any error control or flow control.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   82 +++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 73 insertions(+), 9 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 97172f7..7f835e7 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1245,6 +1245,39 @@ static inline int l2cap_do_send(struct sock *sk, struct sk_buff *skb)
 	return err;
 }
 
+static int l2cap_streaming_send(struct sock *sk)
+{
+	struct sk_buff *skb, *tx_skb;
+	struct l2cap_pinfo *pi = l2cap_pi(sk);
+	u16 control;
+	int err;
+
+	while ((skb = sk->sk_send_head)) {
+		tx_skb = skb_clone(skb, GFP_ATOMIC);
+
+		control = get_unaligned_le16(tx_skb->data + L2CAP_HDR_SIZE);
+		control |= pi->next_tx_seq << L2CAP_CTRL_TXSEQ_SHIFT;
+		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
+
+		err = l2cap_do_send(sk, tx_skb);
+		if (err < 0) {
+			l2cap_send_disconn_req(pi->conn, sk);
+			return err;
+		}
+
+		pi->next_tx_seq = (pi->next_tx_seq + 1) % 64;
+
+		if (skb_queue_is_last(TX_QUEUE(sk), skb))
+			sk->sk_send_head = NULL;
+		else
+			sk->sk_send_head = skb_queue_next(TX_QUEUE(sk), skb);
+
+		skb = skb_dequeue(TX_QUEUE(sk));
+		kfree_skb(skb);
+	}
+	return 0;
+}
+
 static int l2cap_ertm_send(struct sock *sk)
 {
 	struct sk_buff *skb, *tx_skb;
@@ -1383,7 +1416,7 @@ static struct sk_buff *l2cap_create_basic_pdu(struct sock *sk, struct msghdr *ms
 	return skb;
 }
 
-static struct sk_buff *l2cap_create_ertm_pdu(struct sock *sk, struct msghdr *msg, size_t len, u16 control, u16 sdulen)
+static struct sk_buff *l2cap_create_iframe_pdu(struct sock *sk, struct msghdr *msg, size_t len, u16 control, u16 sdulen)
 {
 	struct l2cap_conn *conn = l2cap_pi(sk)->conn;
 	struct sk_buff *skb;
@@ -1429,7 +1462,7 @@ static inline int l2cap_sar_segment_sdu(struct sock *sk, struct msghdr *msg, siz
 
 	__skb_queue_head_init(&sar_queue);
 	control = L2CAP_SDU_START;
-	skb = l2cap_create_ertm_pdu(sk, msg, pi->max_pdu_size, control, len);
+	skb = l2cap_create_iframe_pdu(sk, msg, pi->max_pdu_size, control, len);
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
 
@@ -1449,7 +1482,7 @@ static inline int l2cap_sar_segment_sdu(struct sock *sk, struct msghdr *msg, siz
 			buflen = len;
 		}
 
-		skb = l2cap_create_ertm_pdu(sk, msg, buflen, control, 0);
+		skb = l2cap_create_iframe_pdu(sk, msg, buflen, control, 0);
 		if (IS_ERR(skb)) {
 			skb_queue_purge(&sar_queue);
 			return PTR_ERR(skb);
@@ -1518,10 +1551,11 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct ms
 		break;
 
 	case L2CAP_MODE_ERTM:
+	case L2CAP_MODE_STREAMING:
 		/* Entire SDU fits into one PDU */
 		if (len <= pi->max_pdu_size) {
 			control = L2CAP_SDU_UNSEGMENTED;
-			skb = l2cap_create_ertm_pdu(sk, msg, len, control, 0);
+			skb = l2cap_create_iframe_pdu(sk, msg, len, control, 0);
 			if (IS_ERR(skb)) {
 				err = PTR_ERR(skb);
 				goto done;
@@ -1536,7 +1570,11 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct ms
 				goto done;
 		}
 
-		err = l2cap_ertm_send(sk);
+		if (pi->mode == L2CAP_MODE_STREAMING)
+			err = l2cap_streaming_send(sk);
+		else
+			err = l2cap_ertm_send(sk);
+
 		if (!err)
 			err = len;
 		break;
@@ -2050,7 +2088,7 @@ static int l2cap_mode_supported(__u8 mode, __u32 feat_mask)
 {
 	u32 local_feat_mask = l2cap_feat_mask;
 	if (enable_ertm)
-		local_feat_mask |= L2CAP_FEAT_ERTM;
+		local_feat_mask |= L2CAP_FEAT_ERTM | L2CAP_FEAT_STREAMING;
 
 	switch (mode) {
 	case L2CAP_MODE_ERTM:
@@ -2771,7 +2809,7 @@ static inline int l2cap_information_req(struct l2cap_conn *conn, struct l2cap_cm
 		rsp->type   = cpu_to_le16(L2CAP_IT_FEAT_MASK);
 		rsp->result = cpu_to_le16(L2CAP_IR_SUCCESS);
 		if (enable_ertm)
-			feat_mask |= L2CAP_FEAT_ERTM;
+			feat_mask |= L2CAP_FEAT_ERTM | L2CAP_FEAT_STREAMING;
 		put_unaligned(cpu_to_le32(feat_mask), (__le32 *) rsp->data);
 		l2cap_send_cmd(conn, cmd->ident,
 					L2CAP_INFO_RSP, sizeof(buf), buf);
@@ -3096,7 +3134,9 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk_buff *skb)
 {
 	struct sock *sk;
+	struct l2cap_pinfo *pi;
 	u16 control, len;
+	u8 tx_seq;
 	int err;
 
 	sk = l2cap_get_chan_by_scid(&conn->chan_list, cid);
@@ -3105,19 +3145,21 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 		goto drop;
 	}
 
+	pi = l2cap_pi(sk);
+
 	BT_DBG("sk %p, len %d", sk, skb->len);
 
 	if (sk->sk_state != BT_CONNECTED)
 		goto drop;
 
-	switch (l2cap_pi(sk)->mode) {
+	switch (pi->mode) {
 	case L2CAP_MODE_BASIC:
 		/* If socket recv buffers overflows we drop data here
 		 * which is *bad* because L2CAP has to be reliable.
 		 * But we don't have any other choice. L2CAP doesn't
 		 * provide flow control mechanism. */
 
-		if (l2cap_pi(sk)->imtu < skb->len)
+		if (pi->imtu < skb->len)
 			goto drop;
 
 		if (!sock_queue_rcv_skb(sk, skb))
@@ -3149,6 +3191,28 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 			goto done;
 		break;
 
+	case L2CAP_MODE_STREAMING:
+		control = get_unaligned_le16(skb->data);
+		skb_pull(skb, 2);
+		len = skb->len;
+
+		if (__is_sar_start(control))
+			len -= 2;
+
+		if (len > L2CAP_DEFAULT_MAX_PDU_SIZE || __is_sframe(control))
+			goto drop;
+
+		tx_seq = __get_txseq(control);
+
+		if (pi->expected_tx_seq == tx_seq)
+			pi->expected_tx_seq = (pi->expected_tx_seq + 1) % 64;
+		else
+			pi->expected_tx_seq = tx_seq + 1;
+
+		err = l2cap_sar_reassembly_sdu(sk, skb, control);
+
+		goto done;
+
 	default:
 		BT_DBG("sk %p: bad mode 0x%2.2x", sk, l2cap_pi(sk)->mode);
 		break;
-- 
1.6.2.5

