From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] use total_highpages when calculating lowmem-only
	 allocation sizes (netfilter)
Date: Mon, 06 Dec 2010 16:43:18 +0000
Message-ID: <4CFD20B60200007800026281@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <akpm@linux-foundation.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For those (large) table allocations that come only from lowmem, the
total amount of memory shouldn't really matter.

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 net/netfilter/nf_conntrack_core.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

--- linux-2.6.37-rc4/net/netfilter/nf_conntrack_core.c
+++ 2.6.37-rc4-use-totalhigh_pages/net/netfilter/nf_conntrack_core.c
@@ -17,6 +17,7 @@
 #include <linux/sched.h>
 #include <linux/skbuff.h>
 #include <linux/proc_fs.h>
+#include <linux/highmem.h>
 #include <linux/vmalloc.h>
 #include <linux/stddef.h>
 #include <linux/slab.h>
@@ -1398,10 +1399,12 @@ static int nf_conntrack_init_init_net(vo
 	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
 	 * machine has 512 buckets. >= 1GB machines have 16384 buckets. */
 	if (!nf_conntrack_htable_size) {
+		unsigned long nr_pages = totalram_pages - totalhigh_pages;
+
 		nf_conntrack_htable_size
-			= (((totalram_pages << PAGE_SHIFT) / 16384)
+			= (((nr_pages << PAGE_SHIFT) / 16384)
 			   / sizeof(struct hlist_head));
-		if (totalram_pages > (1024 * 1024 * 1024 / PAGE_SIZE))
+		if (nr_pages > (1024 * 1024 * 1024 / PAGE_SIZE))
 			nf_conntrack_htable_size = 16384;
 		if (nf_conntrack_htable_size < 32)
 			nf_conntrack_htable_size = 32;



