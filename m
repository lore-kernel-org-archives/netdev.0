From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 6/8] Use SLAB_PANIC when creating critical slab cache
Date: Sun, 14 Nov 2004 12:24:00 -0800
Message-ID: <20041114122400.D2357@build.pdx.osdl.net>
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

===== net/ipv6/ip6_fib.c 1.33 vs edited =====
--- 1.33/net/ipv6/ip6_fib.c	2004-11-09 22:57:03 -08:00
+++ edited/net/ipv6/ip6_fib.c	2004-11-14 11:56:01 -08:00
@@ -1242,10 +1242,8 @@ void __init fib6_init(void)
 {
 	fib6_node_kmem = kmem_cache_create("fib6_nodes",
 					   sizeof(struct fib6_node),
-					   0, SLAB_HWCACHE_ALIGN,
+					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL, NULL);
-	if (!fib6_node_kmem)
-		panic("cannot create fib6_nodes cache");
 }
 
 void __exit fib6_gc_cleanup(void)
