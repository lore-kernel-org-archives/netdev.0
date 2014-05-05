From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 04/24] net, diet: Make FIB hash tables smaller with CONFIG_BASE_SMALL
Date: Mon,  5 May 2014 15:25:53 -0700
Message-ID: <1399328773-6531-5-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58940 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933053AbaEEW0U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 18:26:20 -0400
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

Just make the FIB hash tables much smaller for small
kernel.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/net/ip_fib.h     | 5 +++++
 net/ipv4/fib_semantics.c | 4 ++++
 2 files changed, 9 insertions(+)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 9922093..cbe60cd 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -65,7 +65,11 @@ struct fnhe_hash_bucket {
 	struct fib_nh_exception __rcu	*chain;
 };
 
+#ifdef CONFIG_BASE_SMALL
+#define FNHE_HASH_SIZE		16
+#else
 #define FNHE_HASH_SIZE		2048
+#endif
 #define FNHE_RECLAIM_DEPTH	5
 
 struct fib_nh {
@@ -162,6 +166,7 @@ struct fib_result_nl {
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 #define FIB_TABLE_HASHSZ 256
 #else
+/* Can we use 1 for BASE_SMALL? */
 #define FIB_TABLE_HASHSZ 2
 #endif
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 8a043f0..c3d4e4d 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -51,7 +51,11 @@ static struct hlist_head *fib_info_laddrhash;
 static unsigned int fib_info_hash_size;
 static unsigned int fib_info_cnt;
 
+#ifdef CONFIG_BASE_SMALL
+#define DEVINDEX_HASHBITS 2
+#else
 #define DEVINDEX_HASHBITS 8
+#endif
 #define DEVINDEX_HASHSIZE (1U << DEVINDEX_HASHBITS)
 static struct hlist_head fib_info_devhash[DEVINDEX_HASHSIZE];
 
-- 
1.9.0
