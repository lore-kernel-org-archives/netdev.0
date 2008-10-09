From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 2/3] sctp: Fix SNMP number of SCTP_MIB_ABORTED during violation handling.
Date: Thu,  9 Oct 2008 09:29:34 -0400
Message-ID: <1223558975-1550-4-git-send-email-vladislav.yasevich@hp.com>
References: <1223558975-1550-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:16822 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758579AbYJIN3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 09:29:40 -0400
In-Reply-To: <1223558975-1550-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If ABORT chunks require authentication and a protocol violation
is triggered, we do not tear down the association.  Subsequently,
we should not increment SCTP_MIB_ABORTED.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_statefuns.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 1588d06..f5094f1 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4188,11 +4188,10 @@ static sctp_disposition_t sctp_sf_abort_violation(
 		SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
 	}
 
-discard:
-	sctp_sf_pdiscard(ep, asoc, SCTP_ST_CHUNK(0), arg, commands);
-
 	SCTP_INC_STATS(SCTP_MIB_ABORTEDS);
 
+discard:
+	sctp_sf_pdiscard(ep, asoc, SCTP_ST_CHUNK(0), arg, commands);
 	return SCTP_DISPOSITION_ABORT;
 
 nomem_pkt:
@@ -4265,12 +4264,10 @@ static sctp_disposition_t sctp_sf_violation_paramlen(
 	sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
 			SCTP_PERR(SCTP_ERROR_PROTO_VIOLATION));
 	SCTP_DEC_STATS(SCTP_MIB_CURRESTAB);
+	SCTP_INC_STATS(SCTP_MIB_ABORTEDS);
 
 discard:
 	sctp_sf_pdiscard(ep, asoc, SCTP_ST_CHUNK(0), arg, commands);
-
-	SCTP_INC_STATS(SCTP_MIB_ABORTEDS);
-
 	return SCTP_DISPOSITION_ABORT;
 nomem:
 	return SCTP_DISPOSITION_NOMEM;
-- 
1.5.3.5

