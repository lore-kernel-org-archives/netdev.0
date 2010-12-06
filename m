From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] use total_highpages when calculating lowmem-only
	 allocation sizes (decnet)
Date: Mon, 06 Dec 2010 16:43:04 +0000
Message-ID: <4CFD20A8020000780002627E@vpn.id2.novell.com>
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
 net/decnet/dn_route.c             |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-2.6.37-rc4/net/decnet/dn_route.c
+++ 2.6.37-rc4-use-totalhigh_pages/net/decnet/dn_route.c
@@ -69,6 +69,7 @@
 #include <linux/slab.h>
 #include <net/sock.h>
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/init.h>
@@ -1762,7 +1763,7 @@ void __init dn_route_init(void)
 	dn_route_timer.expires = jiffies + decnet_dst_gc_interval * HZ;
 	add_timer(&dn_route_timer);
 
-	goal = totalram_pages >> (26 - PAGE_SHIFT);
+	goal = (totalram_pages - totalhigh_pages) >> (26 - PAGE_SHIFT);
 
 	for(order = 0; (1UL << order) < goal; order++)
 		/* NOTHING */;



