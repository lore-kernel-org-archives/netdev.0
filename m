From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/16] tipc: Relocate trivial link status functions to header file
Date: Tue, 11 May 2010 20:30:11 -0400
Message-ID: <c6d04742cfda323e05a3c56ecd3899df6a87a593.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35237 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753573Ab0ELAaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:30 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UTwh000113
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:30 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Rather than live in link.c where they can only be used in that file alone,
these helper routines are better served by being in link.h

Relocated are the following:

	link_working_working
	link_working_unknown
	link_reset_unknown
	link_reset_reset
	link_blocked
	link_congested

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |    2 +-
 net/tipc/link.c     |   30 ------------------------------
 net/tipc/link.h     |   35 +++++++++++++++++++++++++++++++++++
 3 files changed, 36 insertions(+), 31 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 74b7d1e..ce1390a 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -224,7 +224,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 			memcpy(addr, &media_addr, sizeof(*addr));
 			tipc_link_reset(link);
 		}
-		link_fully_up = (link->state == WORKING_WORKING);
+		link_fully_up = link_working_working(link);
 		spin_unlock_bh(&n_ptr->lock);
 		if ((type == DSC_RESP_MSG) || link_fully_up)
 			return;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 441b26a..e8320bf 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -202,36 +202,6 @@ static unsigned int align(unsigned int i)
 	return (i + 3) & ~3u;
 }
 
-static int link_working_working(struct link *l_ptr)
-{
-	return (l_ptr->state == WORKING_WORKING);
-}
-
-static int link_working_unknown(struct link *l_ptr)
-{
-	return (l_ptr->state == WORKING_UNKNOWN);
-}
-
-static int link_reset_unknown(struct link *l_ptr)
-{
-	return (l_ptr->state == RESET_UNKNOWN);
-}
-
-static int link_reset_reset(struct link *l_ptr)
-{
-	return (l_ptr->state == RESET_RESET);
-}
-
-static int link_blocked(struct link *l_ptr)
-{
-	return (l_ptr->exp_msg_count || l_ptr->blocked);
-}
-
-static int link_congested(struct link *l_ptr)
-{
-	return (l_ptr->out_queue_size >= l_ptr->queue_limit[0]);
-}
-
 static void link_init_max_pkt(struct link *l_ptr)
 {
 	u32 max_pkt;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 6a51e38..2e5385c 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -292,4 +292,39 @@ static inline u32 lesser(u32 left, u32 right)
 	return less_eq(left, right) ? left : right;
 }
 
+
+/*
+ * Link status checking routines
+ */
+
+static inline int link_working_working(struct link *l_ptr)
+{
+	return (l_ptr->state == WORKING_WORKING);
+}
+
+static inline int link_working_unknown(struct link *l_ptr)
+{
+	return (l_ptr->state == WORKING_UNKNOWN);
+}
+
+static inline int link_reset_unknown(struct link *l_ptr)
+{
+	return (l_ptr->state == RESET_UNKNOWN);
+}
+
+static inline int link_reset_reset(struct link *l_ptr)
+{
+	return (l_ptr->state == RESET_RESET);
+}
+
+static inline int link_blocked(struct link *l_ptr)
+{
+	return (l_ptr->exp_msg_count || l_ptr->blocked);
+}
+
+static inline int link_congested(struct link *l_ptr)
+{
+	return (l_ptr->out_queue_size >= l_ptr->queue_limit[0]);
+}
+
 #endif
-- 
1.7.1.rc2

