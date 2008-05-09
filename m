From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH net-2.6] [TIPC]: Increase buffer headroom to support gianfar
Date: Thu,  8 May 2008 20:07:55 -0400
Message-ID: <1210291675-5234-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52531 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317AbYEIAMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:12:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch increases the headroom TIPC reserves in each sk_buff
to 24 bytes, due to the 8 byte FCB used by gianfar.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.h |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 325404f..cc6eca1 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -280,14 +280,20 @@ static inline void k_term_timer(struct timer_list *timer)
  * TIPC message buffer code
  *
  * TIPC message buffer headroom reserves space for a link-level header
- * (in case the message is sent off-node),
- * while ensuring TIPC header is word aligned for quicker access
+ * (in case the message is sent off-node).
  *
- * The largest header currently supported is 18 bytes, which is used when
- * the standard 14 byte Ethernet header has 4 added bytes for VLAN info
+ * Headroom is currently set to 24 bytes to facilitate support of
+ * the following header formats:
+ *
+ * - Ethernet header (14 bytes)
+ * - Ethernet header + VLAN info (14 + 4 bytes)
+ * - Ethernet header + gianfar FCB info (14 + 8 bytes)
+ *
+ * Note: Headroom is always a multiple of 4 to ensure the TIPC header fields
+ *       are word aligned for quicker access
  */
 
-#define BUF_HEADROOM 20u
+#define BUF_HEADROOM 24u
 
 struct tipc_skb_cb {
 	void *handle;
-- 
1.5.3.2

