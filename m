From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2][INET] (resend) Move the reqsk_queue_yank_listen_sk from
 header
Date: Thu, 15 Nov 2007 11:43:01 +0300
Message-ID: <473C0695.9030000@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38574 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756971AbXKOIoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 03:44:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function is used in the net/core/request_sock.c only.
No need in keeping it in the header file.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 0a954ee..cff4608 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -124,18 +124,6 @@ struct request_sock_queue {
 extern int reqsk_queue_alloc(struct request_sock_queue *queue,
 			     unsigned int nr_table_entries);
 
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
index dd78b85..45aed75 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -93,6 +93,19 @@ void __reqsk_queue_destroy(struct request_sock_queue *queue)
 
 EXPORT_SYMBOL(__reqsk_queue_destroy);
 
+static inline struct listen_sock *reqsk_queue_yank_listen_sk(
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
 void reqsk_queue_destroy(struct request_sock_queue *queue)
 {
 	/* make all the listen_opt local to us */
