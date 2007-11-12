From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 11/14] SCTP: Fix PR-SCTP to deliver all the accumulated ordered chunks
Date: Mon, 12 Nov 2007 11:38:26 -0500
Message-ID: <11948855172698-git-send-email-vladislav.yasevich@hp.com>
References: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:35613 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754479AbXKLQij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 11:38:39 -0500
In-Reply-To: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a small bug when we process a FWD-TSN.  We'll deliver
anything upto the current next expected SSN.  However, if the
next expected is already in the queue, it will take another
chunk to trigger its delivery.  The fix is to simply check
the current queued SSN is the next expected one.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/ulpqueue.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 4be92d0..4908041 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -862,7 +862,7 @@ static inline void sctp_ulpq_reap_ordered(struct sctp_ulpq *ulpq, __u16 sid)
 			continue;
 
 		/* see if this ssn has been marked by skipping */
-		if (!SSN_lt(cssn, sctp_ssn_peek(in, csid)))
+		if (!SSN_lte(cssn, sctp_ssn_peek(in, csid)))
 			break;
 
 		__skb_unlink(pos, &ulpq->lobby);
-- 
1.5.2.4

