From: nicolas.dichtel@6wind.com
Subject: [PATCH] sctp: fix call to SCTP_CMD_PROCESS_SACK in sctp_cmd_interpreter()
Date: Mon, 15 Oct 2012 15:56:39 +0200
Message-ID: <1350309399-23422-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Zijie Pan <zijie.pan@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: linux-sctp@vger.kernel.org, vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49811 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219Ab2JONuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 09:50:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zijie Pan <zijie.pan@6wind.com>

Bug introduced by commit edfee0339e681a784ebacec7e8c2dc97dc6d2839
(sctp: check src addr when processing SACK to update transport state)

Signed-off-by: Zijie Pan <zijie.pan@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/sctp/sm_sideeffect.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 57f7de8..6773d78 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1642,8 +1642,9 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 					asoc->outqueue.outstanding_bytes;
 			sackh.num_gap_ack_blocks = 0;
 			sackh.num_dup_tsns = 0;
+			chunk->subh.sack_hdr = &sackh;
 			sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_SACK,
-					SCTP_SACKH(&sackh));
+					SCTP_CHUNK(chunk));
 			break;
 
 		case SCTP_CMD_DISCARD_PACKET:
-- 
1.7.12
