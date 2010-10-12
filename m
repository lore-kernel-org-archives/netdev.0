From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 6/6] dccp: cosmetics - warning format
Date: Tue, 12 Oct 2010 07:15:51 +0200
Message-ID: <1286860551-6809-7-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_misc_fixes_and_helper_functions___a_set_of_six_patches_sent_today>
 <1286860551-6809-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1286860551-6809-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1286860551-6809-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1286860551-6809-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1286860551-6809-5-git-send-email-gerrit@erg.abdn.ac.uk>
 <1286860551-6809-6-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:43506 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752009Ab0JLFQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Oct 2010 01:16:01 -0400
In-Reply-To: <1286860551-6809-6-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This  omits the redundant "DCCP:" in warning messages, since DCCP_WARN() already
echoes the function name, avoiding messages like

   kernel: [10988.766503] dccp_close: DCCP: ABORT -- 209 bytes unread

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |    2 +-
 net/dccp/proto.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -259,7 +259,7 @@ static int dccp_check_seqno(struct sock *sk, struct sk_buff *skb)
 				      sysctl_dccp_sync_ratelimit)))
 			return 0;
 
-		DCCP_WARN("DCCP: Step 6 failed for %s packet, "
+		DCCP_WARN("Step 6 failed for %s packet, "
 			  "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "
 			  "(P.ackno %s or LAWL(%llu) <= P.ackno(%llu) <= S.AWH(%llu), "
 			  "sending SYNC...\n",  dccp_packet_name(dh->dccph_type),
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -944,7 +944,7 @@ void dccp_close(struct sock *sk, long timeout)
 
 	if (data_was_unread) {
 		/* Unread data was tossed, send an appropriate Reset Code */
-		DCCP_WARN("DCCP: ABORT -- %u bytes unread\n", data_was_unread);
+		DCCP_WARN("ABORT with %u bytes unread\n", data_was_unread);
 		dccp_send_reset(sk, DCCP_RESET_CODE_ABORTED);
 		dccp_set_state(sk, DCCP_CLOSED);
 	} else if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime) {
