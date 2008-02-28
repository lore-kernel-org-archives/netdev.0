From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/4] [SCTP]: Correctly set the length of sctp_assoc_change notification
Date: Thu, 28 Feb 2008 16:52:38 -0500
Message-ID: <1204235561-19993-2-git-send-email-vladislav.yasevich@hp.com>
References: <1204235561-19993-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:37163 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785AbYB1VwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 16:52:18 -0500
In-Reply-To: <1204235561-19993-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_assoc_change notification may contain the data from a received
ABORT chunk.  Set the length correctly to account for that.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/ulpevent.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index e27b11f..b43f1f1 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -206,7 +206,7 @@ struct sctp_ulpevent  *sctp_ulpevent_make_assoc_change(
 	 * This field is the total length of the notification data, including
 	 * the notification header.
 	 */
-	sac->sac_length = sizeof(struct sctp_assoc_change);
+	sac->sac_length = skb->len;
 
 	/* Socket Extensions for SCTP
 	 * 5.3.1.1 SCTP_ASSOC_CHANGE
-- 
1.5.3.5

