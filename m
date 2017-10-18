From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] dql: make dql_init return void
Date: Tue, 17 Oct 2017 17:16:52 -0700
Message-ID: <20171018001652.23740-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: Tom Herbert <tom@herbertland.com>,
        Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:56778 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753182AbdJRAQ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 20:16:57 -0400
Received: by mail-pf0-f177.google.com with SMTP id b85so2562494pfj.13
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 17:16:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dql_init always returned 0, and the only place that uses it
in network core code didn't care about the return value anyway.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 include/linux/dynamic_queue_limits.h | 2 +-
 lib/dynamic_queue_limits.c           | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/dynamic_queue_limits.h b/include/linux/dynamic_queue_limits.h
index a4be70398ce1..f69f98541953 100644
--- a/include/linux/dynamic_queue_limits.h
+++ b/include/linux/dynamic_queue_limits.h
@@ -98,7 +98,7 @@ void dql_completed(struct dql *dql, unsigned int count);
 void dql_reset(struct dql *dql);
 
 /* Initialize dql state */
-int dql_init(struct dql *dql, unsigned hold_time);
+void dql_init(struct dql *dql, unsigned int hold_time);
 
 #endif /* _KERNEL_ */
 
diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
index f346715e2255..dbe61c4c2a97 100644
--- a/lib/dynamic_queue_limits.c
+++ b/lib/dynamic_queue_limits.c
@@ -127,12 +127,11 @@ void dql_reset(struct dql *dql)
 }
 EXPORT_SYMBOL(dql_reset);
 
-int dql_init(struct dql *dql, unsigned hold_time)
+void dql_init(struct dql *dql, unsigned int hold_time)
 {
 	dql->max_limit = DQL_MAX_LIMIT;
 	dql->min_limit = 0;
 	dql->slack_hold_time = hold_time;
 	dql_reset(dql);
-	return 0;
 }
 EXPORT_SYMBOL(dql_init);
-- 
2.11.0
