From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH net-2.6] [TIPC]: Increase buffer header to support worst-case device
Date: Thu,  8 May 2008 20:34:02 -0400
Message-ID: <1210293242-13387-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60600 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317AbYEIAiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:38:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch increases the headroom TIPC reserves in each sk_buff
to accommodate the largest possible link level device header.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.h |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 325404f..5a0e487 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -279,15 +279,14 @@ static inline void k_term_timer(struct timer_list *timer)
 /*
  * TIPC message buffer code
  *
- * TIPC message buffer headroom reserves space for a link-level header
- * (in case the message is sent off-node),
- * while ensuring TIPC header is word aligned for quicker access
+ * TIPC message buffer headroom reserves space for the worst-case
+ * link-level device header (in case the message is sent off-node).
  *
- * The largest header currently supported is 18 bytes, which is used when
- * the standard 14 byte Ethernet header has 4 added bytes for VLAN info
+ * Note: Headroom should be a multiple of 4 to ensure the TIPC header fields
+ *       are word aligned for quicker access
  */
 
-#define BUF_HEADROOM 20u
+#define BUF_HEADROOM LL_MAX_HEADER
 
 struct tipc_skb_cb {
 	void *handle;
-- 
1.5.3.2

