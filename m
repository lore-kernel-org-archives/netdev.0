From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next] sctp: no need to check asoc_id before calling sctp_assoc_set_id
Date: Tue, 23 May 2017 14:30:32 +0800
Message-ID: <8ccb4ee656bcdfa790e4f3ee919bb300e4adc4cc.1495521032.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34960 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752502AbdEWGam (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 02:30:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_assoc_set_id has already done the asoc_id check in the beginning
when processing dupcook, no need to do the same check before calling
it.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/associola.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index a9708da..ce2a3ec 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1181,12 +1181,8 @@ void sctp_assoc_update(struct sctp_association *asoc,
 			new->stream = NULL;
 		}
 
-		if (!asoc->assoc_id) {
-			/* get a new association id since we don't have one
-			 * yet.
-			 */
-			sctp_assoc_set_id(asoc, GFP_ATOMIC);
-		}
+		/* get a new association id if we don't have one yet. */
+		sctp_assoc_set_id(asoc, GFP_ATOMIC);
 	}
 
 	/* SCTP-AUTH: Save the peer parameters from the new associations
-- 
2.1.0
