From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: donot reset the overall_error_count in SHUTDOWN_RECEIVE state
Date: Wed, 19 Aug 2015 12:38:03 +0800
Message-ID: <9750de643075d301d80229898eacb0d921349f73.1439959083.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, tgraf@infradead.org, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36489 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbbHSEiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 00:38:09 -0400
Received: by pawq9 with SMTP id q9so51301704paw.3
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 21:38:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f8d960524 fix the 0 peer.rwnd issue in SHUTDOWN_PENING state
through not reseting the overall_error_count when recevie a heartbeat,
but the same issue also exists in SHUTDOWN_RECEIVE state.

Fixes: f8d960524 ("sctp: Enforce retransmission limit during shutdown")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_sideeffect.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index fef2acd..85e6f03 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -702,7 +702,7 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 	 * outstanding data and rely on the retransmission limit be reached
 	 * to shutdown the association.
 	 */
-	if (t->asoc->state != SCTP_STATE_SHUTDOWN_PENDING)
+	if (t->asoc->state < SCTP_STATE_SHUTDOWN_PENDING)
 		t->asoc->overall_error_count = 0;
 
 	/* Clear the hb_sent flag to signal that we had a good
-- 
2.1.0
