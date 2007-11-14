From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2][INET] Move the reqsk_queue_yank_listen_sk from header
Date: Wed, 14 Nov 2007 21:11:06 +0300
Message-ID: <473B3A3A.70207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37264 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243AbXKNSNN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 13:13:13 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function is used in the net/core/request_sock.c only.
No need in keeping it in the header file.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 0a954ee..e80b53f 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -123,19 +123,6 @@ struct request_sock_queue {
 
 extern int reqsk_queue_alloc(struct request_sock_queue *queue,
 			     unsigned int nr_table_entries);
-
-static inline struct listen_sock *reqsk_queue_yank_listen_sk(struct request_sock_queue *queue)
-{
-	struct listen_sock *lopt;
-
-	write_lock_bh(&queue->syn_wait_lock);
-	lopt = queue->listen_opt;
-	queue->listen_opt = NULL;
-	write_unlock_bh(&queue->syn_wait_lock);
-
-	return lopt;
-}
-
 extern void __reqsk_queue_destroy(struct request_sock_queue *queue);
 extern void reqsk_queue_destroy(struct request_sock_queue *queue);
 
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 12a15f5..16b2ef0 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -71,6 +71,19 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 
 EXPORT_SYMBOL(reqsk_queue_alloc);
 
+static struct listen_sock *reqsk_queue_yank_listen_sk(
+		struct request_sock_queue *queue)
+{
+	struct listen_sock *lopt;
+
+	write_lock_bh(&queue->syn_wait_lock);
+	lopt = queue->listen_opt;
+	queue->listen_opt = NULL;
+	write_unlock_bh(&queue->syn_wait_lock);
+
+	return lopt;
+}
+
 void __reqsk_queue_destroy(struct request_sock_queue *queue)
 {
 	struct listen_sock *lopt = reqsk_queue_yank_listen_sk(queue);
-- 
1.5.3.4

