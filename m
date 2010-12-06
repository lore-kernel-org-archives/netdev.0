From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] use total_highpages when calculating lowmem-only
	 allocation sizes (dccp)
Date: Mon, 06 Dec 2010 16:42:46 +0000
Message-ID: <4CFD2096020000780002627B@vpn.id2.novell.com>
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
 net/dccp/proto.c                  |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

--- linux-2.6.37-rc4/net/dccp/proto.c
+++ 2.6.37-rc4-use-totalhigh_pages/net/dccp/proto.c
@@ -14,6 +14,7 @@
 #include <linux/types.h>
 #include <linux/sched.h>
 #include <linux/kernel.h>
+#include <linux/highmem.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/in.h>
@@ -1068,10 +1069,11 @@ static int __init dccp_init(void)
 	 *
 	 * The methodology is similar to that of the buffer cache.
 	 */
-	if (totalram_pages >= (128 * 1024))
-		goal = totalram_pages >> (21 - PAGE_SHIFT);
+	goal = totalram_pages - totalhigh_pages;
+	if (goal >= (128 * 1024))
+		goal >>= 21 - PAGE_SHIFT;
 	else
-		goal = totalram_pages >> (23 - PAGE_SHIFT);
+		goal >>= 23 - PAGE_SHIFT;
 
 	if (thash_entries)
 		goal = (thash_entries *



