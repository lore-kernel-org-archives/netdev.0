From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 8/9] net: sctp: sctp_ulpq: remove 'malloced' struct member
Date: Tue, 16 Apr 2013 23:07:17 +0200
Message-ID: <1366146438-8815-9-git-send-email-dborkman@redhat.com>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30470 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965376Ab3DPVHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 17:07:42 -0400
In-Reply-To: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The structure sctp_ulpq is embedded into sctp_association and never
separately allocated, also ulpq->malloced is always 0, so that
kfree() is never called. Therefore, remove this code.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/ulpqueue.h | 1 -
 net/sctp/ulpqueue.c         | 3 ---
 2 files changed, 4 deletions(-)

diff --git a/include/net/sctp/ulpqueue.h b/include/net/sctp/ulpqueue.h
index ff1b8ba7..00e50ba 100644
--- a/include/net/sctp/ulpqueue.h
+++ b/include/net/sctp/ulpqueue.h
@@ -49,7 +49,6 @@
 
 /* A structure to carry information to the ULP (e.g. Sockets API) */
 struct sctp_ulpq {
-	char malloced;
 	char pd_mode;
 	struct sctp_association *asoc;
 	struct sk_buff_head reasm;
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 0fd5b3d..04e3d47 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -68,7 +68,6 @@ struct sctp_ulpq *sctp_ulpq_init(struct sctp_ulpq *ulpq,
 	skb_queue_head_init(&ulpq->reasm);
 	skb_queue_head_init(&ulpq->lobby);
 	ulpq->pd_mode  = 0;
-	ulpq->malloced = 0;
 
 	return ulpq;
 }
@@ -96,8 +95,6 @@ void sctp_ulpq_flush(struct sctp_ulpq *ulpq)
 void sctp_ulpq_free(struct sctp_ulpq *ulpq)
 {
 	sctp_ulpq_flush(ulpq);
-	if (ulpq->malloced)
-		kfree(ulpq);
 }
 
 /* Process an incoming DATA chunk.  */
-- 
1.7.11.7
