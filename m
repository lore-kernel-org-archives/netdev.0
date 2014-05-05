From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 03/24] net, diet: Decrease ip defrag hash tables and max length with BASE_SMALL
Date: Mon,  5 May 2014 15:25:52 -0700
Message-ID: <1399328773-6531-4-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58945 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933057AbaEEW0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 18:26:21 -0400
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

When CONFIG_BASE_SMALL is set only use 16 entries in the IP defrag
hash table. Also limit the max length of chains to 32 packets.

The sizes are somewhat arbitary and could be changed.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/net/inet_frag.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 6f59de9..a8c5948 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -41,6 +41,10 @@ struct inet_frag_queue {
 	struct netns_frags	*net;
 };
 
+#ifdef CONFIG_BASE_SMALL
+#define INETFRAGS_HASHSZ	16
+#define INETFRAGS_MAXDEPTH	32
+#else
 #define INETFRAGS_HASHSZ	1024
 
 /* averaged:
@@ -50,6 +54,8 @@ struct inet_frag_queue {
  */
 #define INETFRAGS_MAXDEPTH		128
 
+#endif
+
 struct inet_frag_bucket {
 	struct hlist_head	chain;
 	spinlock_t		chain_lock;
-- 
1.9.0
