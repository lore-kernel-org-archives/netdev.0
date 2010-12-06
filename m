From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] use total_highpages when calculating lowmem-only
	 allocation sizes (netlink)
Date: Mon, 06 Dec 2010 16:43:35 +0000
Message-ID: <4CFD20C70200007800026284@vpn.id2.novell.com>
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
 net/netlink/af_netlink.c          |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

--- linux-2.6.37-rc4/net/netlink/af_netlink.c
+++ 2.6.37-rc4-use-totalhigh_pages/net/netlink/af_netlink.c
@@ -30,6 +30,7 @@
 #include <linux/sched.h>
 #include <linux/errno.h>
 #include <linux/string.h>
+#include <linux/highmem.h>
 #include <linux/stat.h>
 #include <linux/socket.h>
 #include <linux/un.h>
@@ -2127,10 +2128,11 @@ static int __init netlink_proto_init(voi
 	if (!nl_table)
 		goto panic;
 
-	if (totalram_pages >= (128 * 1024))
-		limit = totalram_pages >> (21 - PAGE_SHIFT);
+	limit = totalram_pages - totalhigh_pages;
+	if (limit >= (128 * 1024))
+		limit >>= 21 - PAGE_SHIFT;
 	else
-		limit = totalram_pages >> (23 - PAGE_SHIFT);
+		limit >>= 23 - PAGE_SHIFT;
 
 	order = get_bitmask_order(limit) - 1 + PAGE_SHIFT;
 	limit = (1UL << order) / sizeof(struct hlist_head);



