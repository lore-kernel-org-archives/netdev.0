From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next] sctp: no need to check assoc id before calling sctp_assoc_set_id
Date: Sat, 10 Jun 2017 15:27:12 +0800
Message-ID: <ea556c7733c5bf63532ce35186e4bc7a519bf858.1497079632.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35648 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751797AbdFJH1V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 03:27:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_assoc_set_id does the assoc id check in the beginning when
processing dupcookie, no need to do the same check before calling
it.

v1->v2:
  fix some typo errs Marcelo pointed in changelog.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/associola.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 288c5e0..72b07dd 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1181,12 +1181,8 @@ void sctp_assoc_update(struct sctp_association *asoc,
 		if (sctp_state(asoc, COOKIE_WAIT))
 			sctp_stream_update(&asoc->stream, &new->stream);
 
-		if (!asoc->assoc_id) {
-			/* get a new association id since we don't have one
-			 * yet.
-			 */
-			sctp_assoc_set_id(asoc, GFP_ATOMIC);
-		}
+		/* get a new assoc id if we don't have one yet. */
+		sctp_assoc_set_id(asoc, GFP_ATOMIC);
 	}
 
 	/* SCTP-AUTH: Save the peer parameters from the new associations
-- 
2.1.0
