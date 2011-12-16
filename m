From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: two vzalloc() cleanups
Date: Fri, 16 Dec 2011 22:17:35 +0100
Message-ID: <1324070255.2621.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41922 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760696Ab1LPVRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 16:17:42 -0500
Received: by werm1 with SMTP id m1so611998wer.19
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 13:17:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use vzalloc() helper now instead of __vmalloc() trick

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netfilter/nf_conntrack_core.c |    3 +--
 net/tipc/ref.c                    |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 7202b06..80bfb7c 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1342,8 +1342,7 @@ void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls)
 					get_order(sz));
 	if (!hash) {
 		printk(KERN_WARNING "nf_conntrack: falling back to vmalloc.\n");
-		hash = __vmalloc(sz, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
-				 PAGE_KERNEL);
+		hash = vzalloc(sz);
 	}
 
 	if (hash && nulls)
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 8311689..9e37b78 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -110,8 +110,7 @@ int tipc_ref_table_init(u32 requested_size, u32 start)
 
 	/* allocate table & mark all entries as uninitialized */
 
-	table = __vmalloc(actual_size * sizeof(struct reference),
-			  GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
+	table = vzalloc(actual_size * sizeof(struct reference));
 	if (table == NULL)
 		return -ENOMEM;
 
