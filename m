From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/3] dccp: fix return value for sequence-invalid packets
Date: Fri,  7 Jan 2011 12:35:28 +0100
Message-ID: <1294400130-5604-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: <0110107112837.GA5315@gerrit.erg.abdn.ac.uk>
 <1294400130-5604-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Samuel Jero <sj323707@ohio.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:57438 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751983Ab1AGLfk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jan 2011 06:35:40 -0500
In-Reply-To: <1294400130-5604-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Jero <sj323707@ohio.edu>

Currently dccp_check_seqno returns 0 (indicating a valid packet) if the
acknowledgment number is out of bounds and the sync that RFC 4340 mandates at
this point is currently being rate-limited. This function should return -1,
indicating an invalid packet.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -260,7 +260,7 @@ static int dccp_check_seqno(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (time_before(now, (dp->dccps_rate_last +
 				      sysctl_dccp_sync_ratelimit)))
-			return 0;
+			return -1;
 
 		DCCP_WARN("Step 6 failed for %s packet, "
 			  "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "
