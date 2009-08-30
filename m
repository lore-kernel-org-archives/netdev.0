From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 36/47] Bluetooth: Add support for FCS option to L2CAP
Date: Sun, 30 Aug 2009 01:50:50 -0700
Message-ID: <fcc203c30d72dde82692f6b761a80e5ca5fdd8fa.1251621661.git.marcel@holtmann.org>
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
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53327 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219AbZH3Iwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:34 -0400
In-Reply-To: <6840ed0770d79b9bb0800e5e026a067040ef18f5.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

Implement CRC16 check for L2CAP packets. FCS is used by Streaming Mode and
Enhanced Retransmission Mode and is a extra check for the packet content.

Using CRC16 is the default, L2CAP won't use FCS only when both side send
a "No FCS" request.

Initially based on a patch from Nathan Holstein <nathan@lampreynetworks.com>

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |    2 +
 net/bluetooth/l2cap.c         |  101 ++++++++++++++++++++++++++++++++++++++---
 2 files changed, 97 insertions(+), 6 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 2cf7003..59b26bf 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -54,6 +54,7 @@ struct l2cap_options {
 	__u16 imtu;
 	__u16 flush_to;
 	__u8  mode;
+	__u8  fcs;
 };
 
 #define L2CAP_CONNINFO	0x02
@@ -348,6 +349,7 @@ struct l2cap_pinfo {
 #define L2CAP_CONF_MTU_DONE       0x08
 #define L2CAP_CONF_MODE_DONE      0x10
 #define L2CAP_CONF_CONNECT_PEND   0x20
+#define L2CAP_CONF_NO_FCS_RECV    0x40
 #define L2CAP_CONF_STATE2_DEVICE  0x80
 
 #define L2CAP_CONF_MAX_CONF_REQ 2
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 7f835e7..4c31900 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -41,6 +41,7 @@
 #include <linux/list.h>
 #include <linux/device.h>
 #include <linux/uaccess.h>
+#include <linux/crc16.h>
 #include <net/sock.h>
 
 #include <asm/system.h>
@@ -338,11 +339,14 @@ static inline int l2cap_send_sframe(struct l2cap_pinfo *pi, u16 control)
 	struct sk_buff *skb;
 	struct l2cap_hdr *lh;
 	struct l2cap_conn *conn = pi->conn;
-	int count;
+	int count, hlen = L2CAP_HDR_SIZE + 2;
+
+	if (pi->fcs == L2CAP_FCS_CRC16)
+		hlen += 2;
 
 	BT_DBG("pi %p, control 0x%2.2x", pi, control);
 
-	count = min_t(unsigned int, conn->mtu, L2CAP_HDR_SIZE + 2);
+	count = min_t(unsigned int, conn->mtu, hlen);
 	control |= L2CAP_CTRL_FRAME_TYPE;
 
 	skb = bt_skb_alloc(count, GFP_ATOMIC);
@@ -350,10 +354,15 @@ static inline int l2cap_send_sframe(struct l2cap_pinfo *pi, u16 control)
 		return -ENOMEM;
 
 	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
-	lh->len = cpu_to_le16(2);
+	lh->len = cpu_to_le16(hlen - L2CAP_HDR_SIZE);
 	lh->cid = cpu_to_le16(pi->dcid);
 	put_unaligned_le16(control, skb_put(skb, 2));
 
+	if (pi->fcs == L2CAP_FCS_CRC16) {
+		u16 fcs = crc16(0, (u8 *)lh, count - 2);
+		put_unaligned_le16(fcs, skb_put(skb, 2));
+	}
+
 	return hci_send_acl(pi->conn->hcon, skb, 0);
 }
 
@@ -1249,7 +1258,7 @@ static int l2cap_streaming_send(struct sock *sk)
 {
 	struct sk_buff *skb, *tx_skb;
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
-	u16 control;
+	u16 control, fcs;
 	int err;
 
 	while ((skb = sk->sk_send_head)) {
@@ -1259,6 +1268,11 @@ static int l2cap_streaming_send(struct sock *sk)
 		control |= pi->next_tx_seq << L2CAP_CTRL_TXSEQ_SHIFT;
 		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
 
+		if (l2cap_pi(sk)->fcs == L2CAP_FCS_CRC16) {
+			fcs = crc16(0, (u8 *)tx_skb->data, tx_skb->len - 2);
+			put_unaligned_le16(fcs, tx_skb->data + tx_skb->len - 2);
+		}
+
 		err = l2cap_do_send(sk, tx_skb);
 		if (err < 0) {
 			l2cap_send_disconn_req(pi->conn, sk);
@@ -1282,7 +1296,7 @@ static int l2cap_ertm_send(struct sock *sk)
 {
 	struct sk_buff *skb, *tx_skb;
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
-	u16 control;
+	u16 control, fcs;
 	int err;
 
 	if (pi->conn_state & L2CAP_CONN_WAIT_F)
@@ -1305,6 +1319,11 @@ static int l2cap_ertm_send(struct sock *sk)
 		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
 
 
+		if (l2cap_pi(sk)->fcs == L2CAP_FCS_CRC16) {
+			fcs = crc16(0, (u8 *)skb->data, tx_skb->len - 2);
+			put_unaligned_le16(fcs, skb->data + tx_skb->len - 2);
+		}
+
 		err = l2cap_do_send(sk, tx_skb);
 		if (err < 0) {
 			l2cap_send_disconn_req(pi->conn, sk);
@@ -1428,6 +1447,9 @@ static struct sk_buff *l2cap_create_iframe_pdu(struct sock *sk, struct msghdr *m
 	if (sdulen)
 		hlen += 2;
 
+	if (l2cap_pi(sk)->fcs == L2CAP_FCS_CRC16)
+		hlen += 2;
+
 	count = min_t(unsigned int, (conn->mtu - hlen), len);
 	skb = bt_skb_send_alloc(sk, count + hlen,
 			msg->msg_flags & MSG_DONTWAIT, &err);
@@ -1448,6 +1470,9 @@ static struct sk_buff *l2cap_create_iframe_pdu(struct sock *sk, struct msghdr *m
 		return ERR_PTR(err);
 	}
 
+	if (l2cap_pi(sk)->fcs == L2CAP_FCS_CRC16)
+		put_unaligned_le16(0, skb_put(skb, 2));
+
 	bt_cb(skb)->retries = 0;
 	return skb;
 }
@@ -1633,6 +1658,7 @@ static int l2cap_sock_setsockopt_old(struct socket *sock, int optname, char __us
 		opts.omtu     = l2cap_pi(sk)->omtu;
 		opts.flush_to = l2cap_pi(sk)->flush_to;
 		opts.mode     = l2cap_pi(sk)->mode;
+		opts.fcs      = l2cap_pi(sk)->fcs;
 
 		len = min_t(unsigned int, sizeof(opts), optlen);
 		if (copy_from_user((char *) &opts, optval, len)) {
@@ -1643,6 +1669,7 @@ static int l2cap_sock_setsockopt_old(struct socket *sock, int optname, char __us
 		l2cap_pi(sk)->imtu = opts.imtu;
 		l2cap_pi(sk)->omtu = opts.omtu;
 		l2cap_pi(sk)->mode = opts.mode;
+		l2cap_pi(sk)->fcs  = opts.fcs;
 		break;
 
 	case L2CAP_LM:
@@ -1756,6 +1783,7 @@ static int l2cap_sock_getsockopt_old(struct socket *sock, int optname, char __us
 		opts.omtu     = l2cap_pi(sk)->omtu;
 		opts.flush_to = l2cap_pi(sk)->flush_to;
 		opts.mode     = l2cap_pi(sk)->mode;
+		opts.fcs      = l2cap_pi(sk)->fcs;
 
 		len = min_t(unsigned int, len, sizeof(opts));
 		if (copy_to_user(optval, (char *) &opts, len))
@@ -2154,6 +2182,15 @@ done:
 
 		l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC,
 					sizeof(rfc), (unsigned long) &rfc);
+
+		if (!(pi->conn->feat_mask & L2CAP_FEAT_FCS))
+			break;
+
+		if (pi->fcs == L2CAP_FCS_NONE ||
+				pi->conf_state & L2CAP_CONF_NO_FCS_RECV) {
+			pi->fcs = L2CAP_FCS_NONE;
+			l2cap_add_conf_opt(&ptr, L2CAP_CONF_FCS, 1, pi->fcs);
+		}
 		break;
 
 	case L2CAP_MODE_STREAMING:
@@ -2166,6 +2203,15 @@ done:
 
 		l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC,
 					sizeof(rfc), (unsigned long) &rfc);
+
+		if (!(pi->conn->feat_mask & L2CAP_FEAT_FCS))
+			break;
+
+		if (pi->fcs == L2CAP_FCS_NONE ||
+				pi->conf_state & L2CAP_CONF_NO_FCS_RECV) {
+			pi->fcs = L2CAP_FCS_NONE;
+			l2cap_add_conf_opt(&ptr, L2CAP_CONF_FCS, 1, pi->fcs);
+		}
 		break;
 	}
 
@@ -2217,6 +2263,12 @@ static int l2cap_parse_conf_req(struct sock *sk, void *data)
 				memcpy(&rfc, (void *) val, olen);
 			break;
 
+		case L2CAP_CONF_FCS:
+			if (val == L2CAP_FCS_NONE)
+				pi->conf_state |= L2CAP_CONF_NO_FCS_RECV;
+
+			break;
+
 		default:
 			if (hint)
 				break;
@@ -2638,6 +2690,10 @@ static inline int l2cap_config_req(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 		goto unlock;
 
 	if (l2cap_pi(sk)->conf_state & L2CAP_CONF_INPUT_DONE) {
+		if (!(l2cap_pi(sk)->conf_state & L2CAP_CONF_NO_FCS_RECV)
+				|| l2cap_pi(sk)->fcs != L2CAP_FCS_NONE)
+			l2cap_pi(sk)->fcs = L2CAP_FCS_CRC16;
+
 		sk->sk_state = BT_CONNECTED;
 		l2cap_pi(sk)->next_tx_seq = 0;
 		l2cap_pi(sk)->expected_ack_seq = 0;
@@ -2722,6 +2778,10 @@ static inline int l2cap_config_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 	l2cap_pi(sk)->conf_state |= L2CAP_CONF_INPUT_DONE;
 
 	if (l2cap_pi(sk)->conf_state & L2CAP_CONF_OUTPUT_DONE) {
+		if (!(l2cap_pi(sk)->conf_state & L2CAP_CONF_NO_FCS_RECV)
+				|| l2cap_pi(sk)->fcs != L2CAP_FCS_NONE)
+			l2cap_pi(sk)->fcs = L2CAP_FCS_CRC16;
+
 		sk->sk_state = BT_CONNECTED;
 		l2cap_pi(sk)->expected_tx_seq = 0;
 		l2cap_pi(sk)->num_to_ack = 0;
@@ -2809,7 +2869,8 @@ static inline int l2cap_information_req(struct l2cap_conn *conn, struct l2cap_cm
 		rsp->type   = cpu_to_le16(L2CAP_IT_FEAT_MASK);
 		rsp->result = cpu_to_le16(L2CAP_IR_SUCCESS);
 		if (enable_ertm)
-			feat_mask |= L2CAP_FEAT_ERTM | L2CAP_FEAT_STREAMING;
+			feat_mask |= L2CAP_FEAT_ERTM | L2CAP_FEAT_STREAMING
+							 | L2CAP_FEAT_FCS;
 		put_unaligned(cpu_to_le32(feat_mask), (__le32 *) rsp->data);
 		l2cap_send_cmd(conn, cmd->ident,
 					L2CAP_INFO_RSP, sizeof(buf), buf);
@@ -2961,6 +3022,22 @@ static inline void l2cap_sig_channel(struct l2cap_conn *conn, struct sk_buff *sk
 	kfree_skb(skb);
 }
 
+static int l2cap_check_fcs(struct l2cap_pinfo *pi,  struct sk_buff *skb)
+{
+	u16 our_fcs, rcv_fcs;
+	int hdr_size = L2CAP_HDR_SIZE + 2;
+
+	if (pi->fcs == L2CAP_FCS_CRC16) {
+		skb_trim(skb, skb->len - 2);
+		rcv_fcs = get_unaligned_le16(skb->data + skb->len);
+		our_fcs = crc16(0, skb->data - hdr_size, skb->len + hdr_size);
+
+		if (our_fcs != rcv_fcs)
+			return -EINVAL;
+	}
+	return 0;
+}
+
 static int l2cap_sar_reassembly_sdu(struct sock *sk, struct sk_buff *skb, u16 control)
 {
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
@@ -3174,6 +3251,9 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 		if (__is_sar_start(control))
 			len -= 2;
 
+		if (pi->fcs == L2CAP_FCS_CRC16)
+			len -= 2;
+
 		/*
 		 * We can just drop the corrupted I-frame here.
 		 * Receiver will miss it and start proper recovery
@@ -3182,6 +3262,9 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 		if (len > L2CAP_DEFAULT_MAX_PDU_SIZE)
 			goto drop;
 
+		if (l2cap_check_fcs(pi, skb))
+			goto drop;
+
 		if (__is_iframe(control))
 			err = l2cap_data_channel_iframe(sk, control, skb);
 		else
@@ -3199,9 +3282,15 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 		if (__is_sar_start(control))
 			len -= 2;
 
+		if (pi->fcs == L2CAP_FCS_CRC16)
+			len -= 2;
+
 		if (len > L2CAP_DEFAULT_MAX_PDU_SIZE || __is_sframe(control))
 			goto drop;
 
+		if (l2cap_check_fcs(pi, skb))
+			goto drop;
+
 		tx_seq = __get_txseq(control);
 
 		if (pi->expected_tx_seq == tx_seq)
-- 
1.6.2.5

