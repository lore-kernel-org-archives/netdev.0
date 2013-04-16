From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/9] net: sctp: sctp_outq: remove 'malloced' from its struct
Date: Tue, 16 Apr 2013 23:07:12 +0200
Message-ID: <1366146438-8815-4-git-send-email-dborkman@redhat.com>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35872 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965351Ab3DPVH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 17:07:29 -0400
In-Reply-To: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_outq is embedded into sctp_association, and thus never
kmalloced in any way. Also, malloced is always 0, thus kfree()
is never called. Therefore, remove that dead piece of code.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/structs.h | 3 ---
 net/sctp/outqueue.c        | 6 ------
 2 files changed, 9 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 125a19c..73fd5de 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1059,9 +1059,6 @@ struct sctp_outq {
 
 	/* Is this structure empty?  */
 	char empty;
-
-	/* Are we kfree()able? */
-	char malloced;
 };
 
 void sctp_outq_init(struct sctp_association *, struct sctp_outq *);
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 01dca75..d4c137e 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -217,8 +217,6 @@ void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
 	q->outstanding_bytes = 0;
 	q->empty = 1;
 	q->cork  = 0;
-
-	q->malloced = 0;
 	q->out_qlen = 0;
 }
 
@@ -295,10 +293,6 @@ void sctp_outq_free(struct sctp_outq *q)
 {
 	/* Throw away leftover chunks. */
 	__sctp_outq_teardown(q);
-
-	/* If we were kmalloc()'d, free the memory.  */
-	if (q->malloced)
-		kfree(q);
 }
 
 /* Put a new chunk in an sctp_outq.  */
-- 
1.7.11.7
