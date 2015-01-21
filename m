From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH] rhashtable: fix rht_for_each_entry_safe() endless loop
Date: Wed, 21 Jan 2015 11:12:13 +0000
Message-ID: <1421838733-16495-1-git-send-email-kaber@trash.net>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52797 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbbAULMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 06:12:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"next" is not updated, causing an endless loop for buckets with more than
one element.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/rhashtable.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 9570832..83944f9 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -260,7 +260,9 @@ void rhashtable_destroy(struct rhashtable *ht);
 	     next = !rht_is_a_nulls(pos) ?				    \
 		       rht_dereference_bucket(pos->next, tbl, hash) : NULL; \
 	     (!rht_is_a_nulls(pos)) && rht_entry(tpos, pos, member);	    \
-	     pos = next)
+	     pos = next,						    \
+	     next = !rht_is_a_nulls(pos) ?				    \
+		       rht_dereference_bucket(pos->next, tbl, hash) : NULL)
 
 /**
  * rht_for_each_rcu_continue - continue iterating over rcu hash chain
-- 
2.1.0
