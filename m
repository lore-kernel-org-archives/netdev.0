From: kaber@trash.net
Subject: [PATCH 1/5] netfilter: nf_conntrack: allow nf_ct_alloc_hashtable() to get highmem pages
Date: Wed,  3 Nov 2010 23:12:48 +0100
Message-ID: <1288822372-21245-2-git-send-email-kaber@trash.net>
References: <1288822372-21245-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1288822372-21245-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

commit ea781f197d6a8 (use SLAB_DESTROY_BY_RCU and get rid of call_rcu())
did a mistake in __vmalloc() call in nf_ct_alloc_hashtable().

I forgot to add __GFP_HIGHMEM, so pages were taken from LOWMEM only.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: stable@kernel.org
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 1eacf8d..27a5ea6 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1312,7 +1312,8 @@ void *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced, int nulls)
 	if (!hash) {
 		*vmalloced = 1;
 		printk(KERN_WARNING "nf_conntrack: falling back to vmalloc.\n");
-		hash = __vmalloc(sz, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
+		hash = __vmalloc(sz, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
+				 PAGE_KERNEL);
 	}
 
 	if (hash && nulls)
-- 
1.7.1

