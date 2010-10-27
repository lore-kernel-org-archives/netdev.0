From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] conntrack: allow nf_ct_alloc_hashtable() to get highmem
 pages
Date: Wed, 27 Oct 2010 11:09:15 +0200
Message-ID: <1288170555.2709.63.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, stable@kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42759 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755088Ab0J0JJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 05:09:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ea781f197d6a8 (use SLAB_DESTROY_BY_RCU and get rid of call_rcu())
did a mistake in __vmalloc() call in nf_ct_alloc_hashtable().

I forgot to add __GFP_HIGHMEM, so pages were taken from LOWMEM only.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netfilter/nf_conntrack_core.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

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


