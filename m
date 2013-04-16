From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 5/9] net: sctp: outqueue: simplify sctp_outq_uncork function
Date: Tue, 16 Apr 2013 23:07:14 +0200
Message-ID: <1366146438-8815-6-git-send-email-dborkman@redhat.com>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65085 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965351Ab3DPVHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 17:07:34 -0400
In-Reply-To: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a minor edit to simplify the function. No need for this
error variable here.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/outqueue.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index d4c137e..32a4625 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -701,11 +701,10 @@ redo:
 /* Cork the outqueue so queued chunks are really queued. */
 int sctp_outq_uncork(struct sctp_outq *q)
 {
-	int error = 0;
 	if (q->cork)
 		q->cork = 0;
-	error = sctp_outq_flush(q, 0);
-	return error;
+
+	return sctp_outq_flush(q, 0);
 }
 
 
-- 
1.7.11.7
