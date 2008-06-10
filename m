From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 6/7] dccp: Bug in initial acknowledgment number assignment
Date: Tue, 10 Jun 2008 13:53:42 +0100
Message-ID: <1213102423-27486-7-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_bug_fixes_for_net-2.6>
 <1213102423-27486-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1213102423-27486-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1213102423-27486-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1213102423-27486-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1213102423-27486-5-git-send-email-gerrit@erg.abdn.ac.uk>
 <1213102423-27486-6-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:37419 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753740AbYFJMxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 08:53:54 -0400
In-Reply-To: <1213102423-27486-6-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Step 8.5 in RFC 4340 says for the newly cloned socket

           Initialize S.GAR := S.ISS,

but what in fact the code (minisocks.c) does is

           Initialize S.GAR := S.ISR,

which is wrong (typo?) -- fixed by the patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/minisocks.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -165,12 +165,12 @@ out_free:
 		/* See dccp_v4_conn_request */
 		newdmsk->dccpms_sequence_window = req->rcv_wnd;
 
-		newdp->dccps_gar = newdp->dccps_isr = dreq->dreq_isr;
-		dccp_update_gsr(newsk, dreq->dreq_isr);
-
-		newdp->dccps_iss = dreq->dreq_iss;
+		newdp->dccps_gar = newdp->dccps_iss = dreq->dreq_iss;
 		dccp_update_gss(newsk, dreq->dreq_iss);
 
+		newdp->dccps_isr = dreq->dreq_isr;
+		dccp_update_gsr(newsk, dreq->dreq_isr);
+
 		/*
 		 * SWL and AWL are initially adjusted so that they are not less than
 		 * the initial Sequence Numbers received and sent, respectively:
