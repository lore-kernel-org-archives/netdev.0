From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/3] [SCTP]: Correctly handle AUTH parameters in unexpected INIT
Date: Fri,  4 Jan 2008 14:45:45 -0500
Message-ID: <1199475946-11103-3-git-send-email-vladislav.yasevich@hp.com>
References: <1199475946-11103-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:13683 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbYADTob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 14:44:31 -0500
In-Reply-To: <1199475946-11103-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When processing an unexpected INIT chunk, we do not need to
do any preservation of the old AUTH parameters.  In fact,
doing such preservations will nullify AUTH and allow connection
stealing.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_statefuns.c |   22 ----------------------
 1 files changed, 0 insertions(+), 22 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 5fb8477..d247ed4 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1309,26 +1309,6 @@ static void sctp_tietags_populate(struct sctp_association *new_asoc,
 	new_asoc->c.initial_tsn         = asoc->c.initial_tsn;
 }
 
-static void sctp_auth_params_populate(struct sctp_association *new_asoc,
-				    const struct sctp_association *asoc)
-{
-	/* Only perform this if AUTH extension is enabled */
-	if (!sctp_auth_enable)
-		return;
-
-	/* We need to provide the same parameter information as
-	 * was in the original INIT.  This means that we need to copy
-	 * the HMACS, CHUNKS, and RANDOM parameter from the original
-	 * assocaition.
-	 */
-	memcpy(new_asoc->c.auth_random, asoc->c.auth_random,
-		sizeof(asoc->c.auth_random));
-	memcpy(new_asoc->c.auth_hmacs, asoc->c.auth_hmacs,
-		sizeof(asoc->c.auth_hmacs));
-	memcpy(new_asoc->c.auth_chunks, asoc->c.auth_chunks,
-		sizeof(asoc->c.auth_chunks));
-}
-
 /*
  * Compare vtag/tietag values to determine unexpected COOKIE-ECHO
  * handling action.
@@ -1486,8 +1466,6 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 
 	sctp_tietags_populate(new_asoc, asoc);
 
-	sctp_auth_params_populate(new_asoc, asoc);
-
 	/* B) "Z" shall respond immediately with an INIT ACK chunk.  */
 
 	/* If there are errors need to be reported for unknown parameters,
-- 
1.5.3.5

