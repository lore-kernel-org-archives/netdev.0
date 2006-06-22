From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 4/32] [TIPC] Corrected potential misuse of tipc_media_addr structure.
Date: Thu, 22 Jun 2006 15:59:17 +0200
Message-ID: <11509847853933-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:39610 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030285AbWFVN7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:50 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 include/net/tipc/tipc_bearer.h |   12 ++++++++++--
 net/tipc/eth_media.c           |    4 +++-
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/net/tipc/tipc_bearer.h b/include/net/tipc/tipc_bearer.h
index 098607c..e07136d 100644
--- a/include/net/tipc/tipc_bearer.h
+++ b/include/net/tipc/tipc_bearer.h
@@ -49,10 +49,18 @@ #include <linux/spinlock.h>
 
 #define TIPC_MEDIA_TYPE_ETH	1
 
+/* 
+ * Destination address structure used by TIPC bearers when sending messages
+ * 
+ * IMPORTANT: The fields of this structure MUST be stored using the specified
+ * byte order indicated below, as the structure is exchanged between nodes
+ * as part of a link setup process.
+ */
+
 struct tipc_media_addr {
-	__u32  type;
+	__u32  type;			/* bearer type (network byte order) */
 	union {
-		__u8   eth_addr[6];	/* Ethernet bearer */ 
+		__u8   eth_addr[6];	/* 48 bit Ethernet addr (byte array) */ 
 #if 0
 		/* Prototypes for other possible bearer types */
 
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index b646619..3ecb100 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -254,7 +254,9 @@ int tipc_eth_media_start(void)
 	if (eth_started)
 		return -EINVAL;
 
-	memset(&bcast_addr, 0xff, sizeof(bcast_addr));
+	bcast_addr.type = htonl(TIPC_MEDIA_TYPE_ETH);
+	memset(&bcast_addr.dev_addr, 0xff, ETH_ALEN);
+
 	memset(eth_bearers, 0, sizeof(eth_bearers));
 
 	res = tipc_register_media(TIPC_MEDIA_TYPE_ETH, "eth",
-- 
1.4.0

