From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 02/24] net, diet: Reduce NAPI hash table for CONFIG_BASE_SMALL
Date: Mon,  5 May 2014 15:25:51 -0700
Message-ID: <1399328773-6531-3-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39433 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933039AbaEEW0T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 18:26:19 -0400
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

For really small kernels, use only 3 bits for the hash table.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 net/core/dev.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d2c8a06..c6cbe69 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -175,7 +175,14 @@ EXPORT_SYMBOL(dev_base_lock);
 static DEFINE_SPINLOCK(napi_hash_lock);
 
 static unsigned int napi_gen_id;
-static DEFINE_HASHTABLE(napi_hash, 8);
+
+#ifdef CONFIG_BASE_SMALL
+#define NAPI_HASH_BITS 3
+#else
+#define NAPI_HASH_BITS 8
+#endif
+
+static DEFINE_HASHTABLE(napi_hash, NAPI_HASH_BITS);
 
 static seqcount_t devnet_rename_seq;
 
-- 
1.9.0
