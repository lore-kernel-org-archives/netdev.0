From: Chris Larson <clarson@mvista.com>
Subject: [PATCH 1/2] net: in the first call to neigh_seq_next, call neigh_get_first, not neigh_get_idx.
Date: Fri,  1 Aug 2008 14:49:48 -0700
Message-ID: <1217627389-9653-1-git-send-email-clarson@mvista.com>
Cc: Chris Larson <clarson@mvista.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:20631 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760219AbYHAVtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 17:49:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

neigh_seq_next won't be called both with *pos > 0 && v == SEQ_START_TOKEN,
so there's no point calling neigh_get_idx when we're on the start token,
just call neigh_get_first directly.

Signed-off-by: Chris Larson <clarson@mvista.com>
---
 net/core/neighbour.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f62c8af..a57de75 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2385,7 +2385,7 @@ void *neigh_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	void *rc;
 
 	if (v == SEQ_START_TOKEN) {
-		rc = neigh_get_idx(seq, pos);
+		rc = neigh_get_first(seq);
 		goto out;
 	}
 
-- 
1.5.5.1.147.g867f

