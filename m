From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net 1/2] ethtool: Use values instead of bit flags for RSS hash function
Date: Sun, 26 Apr 2015 17:36:05 +0300
Message-ID: <1430058966-24046-2-git-send-email-amirv@mellanox.com>
References: <1430058966-24046-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:50993 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751335AbbDZOgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Apr 2015 10:36:43 -0400
In-Reply-To: <1430058966-24046-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RX indirection hash function is eight bits. Using more than one hash
function doesn't make sense, therefore using this field as a value
instead of a bit flag.
Moving from bit flags into value shouldn't introduce any backward
compatibility issues, since currently there are only 2 functions,
therfore the actual value in the field hfunc is the same like before 1
for Toeplitz and 2 for XOR.

Fixes: 892311f ("ethtool: Support for configurable RSS hash function")
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 include/linux/ethtool.h | 9 ++-------
 net/core/ethtool.c      | 4 ++--
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 653dc9c..d19f31a 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -60,8 +60,8 @@ enum ethtool_phys_id_state {
 };
 
 enum {
-	ETH_RSS_HASH_TOP_BIT, /* Configurable RSS hash function - Toeplitz */
-	ETH_RSS_HASH_XOR_BIT, /* Configurable RSS hash function - Xor */
+	ETH_RSS_HASH_TOP = 1, /* Configurable RSS hash function - Toeplitz */
+	ETH_RSS_HASH_XOR = 2, /* Configurable RSS hash function - Xor */
 
 	/*
 	 * Add your fresh new hash function bits above and remember to update
@@ -70,11 +70,6 @@ enum {
 	ETH_RSS_HASH_FUNCS_COUNT
 };
 
-#define __ETH_RSS_HASH_BIT(bit)	((u32)1 << (bit))
-#define __ETH_RSS_HASH(name)	__ETH_RSS_HASH_BIT(ETH_RSS_HASH_##name##_BIT)
-
-#define ETH_RSS_HASH_TOP	__ETH_RSS_HASH(TOP)
-#define ETH_RSS_HASH_XOR	__ETH_RSS_HASH(XOR)
 
 #define ETH_RSS_HASH_UNKNOWN	0
 #define ETH_RSS_HASH_NO_CHANGE	0
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1d00b89..1a1db95 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -103,8 +103,8 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 
 static const char
 rss_hash_func_strings[ETH_RSS_HASH_FUNCS_COUNT][ETH_GSTRING_LEN] = {
-	[ETH_RSS_HASH_TOP_BIT] =	"toeplitz",
-	[ETH_RSS_HASH_XOR_BIT] =	"xor",
+	[ETH_RSS_HASH_TOP] =		"toeplitz",
+	[ETH_RSS_HASH_XOR] =		"xor",
 };
 
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
-- 
1.9.3
