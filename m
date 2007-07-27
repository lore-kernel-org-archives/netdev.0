From: Al Viro <viro@ftp.linux.org.uk>
Subject: [PATCH 2/4] l2cap: endianness annotations
Date: Fri, 27 Jul 2007 13:57:16 +0100
Message-ID: <E1IEPNc-0005SI-7n@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	marcel@holtmann.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:45156 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933399AbXG0M5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 08:57:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


no code changes, just documenting existing types

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/net/bluetooth/l2cap.h |   50 ++++++++++++++++++++--------------------
 net/bluetooth/l2cap.c         |   27 +++++++++++----------
 2 files changed, 39 insertions(+), 38 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 87df4e8..70e70f5 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -34,7 +34,7 @@
 /* L2CAP socket address */
 struct sockaddr_l2 {
 	sa_family_t	l2_family;
-	unsigned short	l2_psm;
+	__le16		l2_psm;
 	bdaddr_t	l2_bdaddr;
 };
 
@@ -76,32 +76,32 @@ struct l2cap_conninfo {
 
 /* L2CAP structures */
 struct l2cap_hdr {
-	__u16      len;
-	__u16      cid;
+	__le16     len;
+	__le16     cid;
 } __attribute__ ((packed));
 #define L2CAP_HDR_SIZE		4
 
 struct l2cap_cmd_hdr {
 	__u8       code;
 	__u8       ident;
-	__u16      len;
+	__le16     len;
 } __attribute__ ((packed));
 #define L2CAP_CMD_HDR_SIZE	4
 
 struct l2cap_cmd_rej {
-	__u16      reason;
+	__le16     reason;
 } __attribute__ ((packed));
 
 struct l2cap_conn_req {
-	__u16      psm;
-	__u16      scid;
+	__le16     psm;
+	__le16     scid;
 } __attribute__ ((packed));
 
 struct l2cap_conn_rsp {
-	__u16      dcid;
-	__u16      scid;
-	__u16      result;
-	__u16      status;
+	__le16     dcid;
+	__le16     scid;
+	__le16     result;
+	__le16     status;
 } __attribute__ ((packed));
 
 /* connect result */
@@ -117,15 +117,15 @@ struct l2cap_conn_rsp {
 #define L2CAP_CS_AUTHOR_PEND  0x0002
 
 struct l2cap_conf_req {
-	__u16      dcid;
-	__u16      flags;
+	__le16     dcid;
+	__le16     flags;
 	__u8       data[0];
 } __attribute__ ((packed));
 
 struct l2cap_conf_rsp {
-	__u16      scid;
-	__u16      flags;
-	__u16      result;
+	__le16     scid;
+	__le16     flags;
+	__le16     result;
 	__u8       data[0];
 } __attribute__ ((packed));
 
@@ -149,23 +149,23 @@ struct l2cap_conf_opt {
 #define L2CAP_CONF_MAX_SIZE	22
 
 struct l2cap_disconn_req {
-	__u16      dcid;
-	__u16      scid;
+	__le16     dcid;
+	__le16     scid;
 } __attribute__ ((packed));
 
 struct l2cap_disconn_rsp {
-	__u16      dcid;
-	__u16      scid;
+	__le16     dcid;
+	__le16     scid;
 } __attribute__ ((packed));
 
 struct l2cap_info_req {
-	__u16       type;
+	__le16      type;
 	__u8        data[0];
 } __attribute__ ((packed));
 
 struct l2cap_info_rsp {
-	__u16       type;
-	__u16       result;
+	__le16      type;
+	__le16      result;
 	__u8        data[0];
 } __attribute__ ((packed));
 
@@ -207,7 +207,7 @@ struct l2cap_conn {
 
 struct l2cap_pinfo {
 	struct bt_sock	bt;
-	__u16		psm;
+	__le16		psm;
 	__u16		dcid;
 	__u16		scid;
 
@@ -225,7 +225,7 @@ struct l2cap_pinfo {
 
 	__u8		ident;
 
-	__u16		sport;
+	__le16		sport;
 
 	struct l2cap_conn	*conn;
 	struct sock		*next_c;
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index b82cbdd..09126bf 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -353,7 +353,7 @@ static inline int l2cap_send_cmd(struct l2cap_conn *conn, u8 ident, u8 code, u16
 }
 
 /* ---- Socket interface ---- */
-static struct sock *__l2cap_get_sock_by_addr(u16 psm, bdaddr_t *src)
+static struct sock *__l2cap_get_sock_by_addr(__le16 psm, bdaddr_t *src)
 {
 	struct sock *sk;
 	struct hlist_node *node;
@@ -368,7 +368,7 @@ found:
 /* Find socket with psm and source bdaddr.
  * Returns closest match.
  */
-static struct sock *__l2cap_get_sock_by_psm(int state, u16 psm, bdaddr_t *src)
+static struct sock *__l2cap_get_sock_by_psm(int state, __le16 psm, bdaddr_t *src)
 {
 	struct sock *sk = NULL, *sk1 = NULL;
 	struct hlist_node *node;
@@ -392,7 +392,7 @@ static struct sock *__l2cap_get_sock_by_psm(int state, u16 psm, bdaddr_t *src)
 
 /* Find socket with given address (psm, src).
  * Returns locked socket */
-static inline struct sock *l2cap_get_sock_by_psm(int state, u16 psm, bdaddr_t *src)
+static inline struct sock *l2cap_get_sock_by_psm(int state, __le16 psm, bdaddr_t *src)
 {
 	struct sock *s;
 	read_lock(&l2cap_sk_list.lock);
@@ -586,7 +586,7 @@ static int l2cap_sock_bind(struct socket *sock, struct sockaddr *addr, int addr_
 		goto done;
 	}
 
-	if (la->l2_psm > 0 && btohs(la->l2_psm) < 0x1001 &&
+	if (la->l2_psm && btohs(la->l2_psm) < 0x1001 &&
 				!capable(CAP_NET_BIND_SERVICE)) {
 		err = -EACCES;
 		goto done;
@@ -873,7 +873,7 @@ static inline int l2cap_do_send(struct sock *sk, struct msghdr *msg, int len)
 	lh->len = cpu_to_le16(len + (hlen - L2CAP_HDR_SIZE));
 
 	if (sk->sk_type == SOCK_DGRAM)
-		put_unaligned(l2cap_pi(sk)->psm, (u16 *) skb_put(skb, 2));
+		put_unaligned(l2cap_pi(sk)->psm, (__le16 *) skb_put(skb, 2));
 
 	if (memcpy_fromiovec(skb_put(skb, count), msg->msg_iov, count)) {
 		err = -EFAULT;
@@ -1256,11 +1256,11 @@ static inline int l2cap_get_conf_opt(void **ptr, int *type, int *olen, unsigned
 		break;
 
 	case 2:
-		*val = __le16_to_cpu(*((u16 *)opt->val));
+		*val = __le16_to_cpu(*((__le16 *)opt->val));
 		break;
 
 	case 4:
-		*val = __le32_to_cpu(*((u32 *)opt->val));
+		*val = __le32_to_cpu(*((__le32 *)opt->val));
 		break;
 
 	default:
@@ -1287,11 +1287,11 @@ static void l2cap_add_conf_opt(void **ptr, u8 type, u8 len, unsigned long val)
 		break;
 
 	case 2:
-		*((u16 *) opt->val) = cpu_to_le16(val);
+		*((__le16 *) opt->val) = cpu_to_le16(val);
 		break;
 
 	case 4:
-		*((u32 *) opt->val) = cpu_to_le32(val);
+		*((__le32 *) opt->val) = cpu_to_le32(val);
 		break;
 
 	default:
@@ -1406,7 +1406,7 @@ static inline int l2cap_connect_req(struct l2cap_conn *conn, struct l2cap_cmd_hd
 	int result = 0, status = 0;
 
 	u16 dcid = 0, scid = __le16_to_cpu(req->scid);
-	u16 psm  = req->psm;
+	__le16 psm  = req->psm;
 
 	BT_DBG("psm 0x%2.2x scid 0x%4.4x", psm, scid);
 
@@ -1863,7 +1863,7 @@ done:
 	return 0;
 }
 
-static inline int l2cap_conless_channel(struct l2cap_conn *conn, u16 psm, struct sk_buff *skb)
+static inline int l2cap_conless_channel(struct l2cap_conn *conn, __le16 psm, struct sk_buff *skb)
 {
 	struct sock *sk;
 
@@ -1893,7 +1893,8 @@ done:
 static void l2cap_recv_frame(struct l2cap_conn *conn, struct sk_buff *skb)
 {
 	struct l2cap_hdr *lh = (void *) skb->data;
-	u16 cid, psm, len;
+	u16 cid, len;
+	__le16 psm;
 
 	skb_pull(skb, L2CAP_HDR_SIZE);
 	cid = __le16_to_cpu(lh->cid);
@@ -1907,7 +1908,7 @@ static void l2cap_recv_frame(struct l2cap_conn *conn, struct sk_buff *skb)
 		break;
 
 	case 0x0002:
-		psm = get_unaligned((u16 *) skb->data);
+		psm = get_unaligned((__le16 *) skb->data);
 		skb_pull(skb, 2);
 		l2cap_conless_channel(conn, psm, skb);
 		break;
-- 
1.5.3.GIT

