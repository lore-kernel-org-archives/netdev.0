From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 05/64] Bluetooth: Trivial clean ups to SCO
Date: Mon, 10 May 2010 11:36:55 +0200
Message-ID: <b9dbdbc1f4404cba2e64939c30c87d59c9796e4e.1273484095.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
 <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
 <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
 <4f7ac1814ef6f0773e57ffd159a1dd57a3c80521.1273484095.git.marcel@holtmann.org>
 <0d861d8b8edd139a9b291cb262d08dec8dc3922d.1273484095.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53431 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755692Ab0EJJij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:39 -0400
In-Reply-To: <0d861d8b8edd139a9b291cb262d08dec8dc3922d.1273484095.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <padovan@profusion.mobi>

Remove extra braces and labels, break over column 80 lines, etc

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/sco.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 541b26e..4767928 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -165,11 +165,11 @@ static inline int sco_chan_add(struct sco_conn *conn, struct sock *sk, struct so
 	int err = 0;
 
 	sco_conn_lock(conn);
-	if (conn->sk) {
+	if (conn->sk)
 		err = -EBUSY;
-	} else {
+	else
 		__sco_chan_add(conn, sk, parent);
-	}
+
 	sco_conn_unlock(conn);
 	return err;
 }
@@ -241,21 +241,19 @@ static inline int sco_send_frame(struct sock *sk, struct msghdr *msg, int len)
 	BT_DBG("sk %p len %d", sk, len);
 
 	count = min_t(unsigned int, conn->mtu, len);
-	if (!(skb = bt_skb_send_alloc(sk, count, msg->msg_flags & MSG_DONTWAIT, &err)))
+	skb = bt_skb_send_alloc(sk, count,
+			msg->msg_flags & MSG_DONTWAIT, &err);
+	if (!skb)
 		return err;
 
 	if (memcpy_fromiovec(skb_put(skb, count), msg->msg_iov, count)) {
-		err = -EFAULT;
-		goto fail;
+		kfree_skb(skb);
+		return -EFAULT;
 	}
 
 	hci_send_sco(conn->hcon, skb);
 
 	return count;
-
-fail:
-	kfree_skb(skb);
-	return err;
 }
 
 static inline void sco_recv_frame(struct sco_conn *conn, struct sk_buff *skb)
@@ -625,7 +623,7 @@ static int sco_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 			    struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
-	int err = 0;
+	int err;
 
 	BT_DBG("sock %p, sk %p", sock, sk);
 
@@ -850,7 +848,8 @@ static void sco_conn_ready(struct sco_conn *conn)
 
 		bh_lock_sock(parent);
 
-		sk = sco_sock_alloc(sock_net(parent), NULL, BTPROTO_SCO, GFP_ATOMIC);
+		sk = sco_sock_alloc(sock_net(parent), NULL,
+				BTPROTO_SCO, GFP_ATOMIC);
 		if (!sk) {
 			bh_unlock_sock(parent);
 			goto done;
-- 
1.6.6.1

