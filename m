From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 3/8] Use SLAB_PANIC when creating critical slab cache
Date: Sun, 14 Nov 2004 12:21:47 -0800
Message-ID: <20041114122147.A2357@build.pdx.osdl.net>
References: <20041114121837.X2357@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20041114121837.X2357@build.pdx.osdl.net>; from chrisw@osdl.org on Sun, Nov 14, 2004 at 12:18:37PM -0800
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use SLAB_PANIC when creating a critical slab cache.

Signed-off-by: Chris Wright <chrisw@osdl.org>

===== net/decnet/dn_route.c 1.29 vs edited =====
--- 1.29/net/decnet/dn_route.c	2004-11-09 16:44:25 -08:00
+++ edited/net/decnet/dn_route.c	2004-11-10 17:48:58 -08:00
@@ -1778,12 +1778,9 @@ void __init dn_route_init(void)
 	int i, goal, order;
 
 	dn_dst_ops.kmem_cachep = kmem_cache_create("dn_dst_cache",
-						   sizeof(struct dn_route),
-						   0, SLAB_HWCACHE_ALIGN,
-						   NULL, NULL);
-
-	if (!dn_dst_ops.kmem_cachep)
-		panic("DECnet: Failed to allocate dn_dst_cache\n");
+						  sizeof(struct dn_route), 0,
+						  SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+						  NULL, NULL);
 
 	init_timer(&dn_route_timer);
 	dn_route_timer.function = dn_dst_check_expire;
