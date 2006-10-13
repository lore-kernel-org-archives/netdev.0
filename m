From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 7/14] [TIPC] Add support for Ethernet VLANs
Date: Fri, 13 Oct 2006 13:37:48 +0200
Message-ID: <11607394753517-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:42656 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1751375AbWJMLiB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:01 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This patch enhances TIPC's Ethernet support to include VLAN interfaces.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/core.c |    2 +-
 net/tipc/core.h |    8 ++++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 0539a83..7f3f693 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -90,7 +90,7 @@ int tipc_random;
 atomic_t tipc_user_count = ATOMIC_INIT(0);
 
 const char tipc_alphabet[] = 
-	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_";
+	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.";
 
 /* configurable TIPC parameters */
 
diff --git a/net/tipc/core.h b/net/tipc/core.h
index e3a74a3..a0cc1d2 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -275,11 +275,15 @@ static inline void k_term_timer(struct t
 /*
  * TIPC message buffer code
  *
- * TIPC message buffer headroom leaves room for 14 byte Ethernet header, 
+ * TIPC message buffer headroom reserves space for a link-level header
+ * (in case the message is sent off-node), 
  * while ensuring TIPC header is word aligned for quicker access
+ *
+ * The largest header currently supported is 18 bytes, which is used when
+ * the standard 14 byte Ethernet header has 4 added bytes for VLAN info
  */
 
-#define BUF_HEADROOM 16u 
+#define BUF_HEADROOM 20u
 
 struct tipc_skb_cb {
 	void *handle;
-- 
1.4.1

