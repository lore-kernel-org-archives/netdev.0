From: Jan Wang <bbw725@163.com>
Subject: [PATCH 1/1] Signed-off-by: Jan Wang <bbw725@163.com>
Date: Sun, 11 Dec 2016 23:31:52 +0800
Message-ID: <1481470312-8497-1-git-send-email-bbw725@163.com>
Cc: netdev@vger.kernel.org, Jan Wang <bbw725@163.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:43742 "EHLO m12-11.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932088AbcLKPbj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 11 Dec 2016 10:31:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[net]: Missing init queue tail

Accept queue tail doesn't initialize NULL.
Though looks like no harm, unify it with reqsk_queue_remove(
it will initialize tail to NULL when empty).

Signed-off-by: Jan Wang <bbw725@163.com>
---
 net/core/request_sock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 5d26056..1392bab 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -47,6 +47,7 @@ void reqsk_queue_alloc(struct request_sock_queue *queue)
 	queue->fastopenq.qlen = 0;
 
 	queue->rskq_accept_head = NULL;
+	queue->rskq_accept_tail = NULL;
 }
 
 /*
-- 
2.1.4
