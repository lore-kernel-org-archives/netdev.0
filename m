From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 7/8] Use SLAB_PANIC when creating critical slab cache
Date: Sun, 14 Nov 2004 12:24:49 -0800
Message-ID: <20041114122449.E2357@build.pdx.osdl.net>
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

===== net/ipv6/route.c 1.101 vs edited =====
--- 1.101/net/ipv6/route.c	2004-11-11 15:07:25 -08:00
+++ edited/net/ipv6/route.c	2004-11-14 11:56:41 -08:00
@@ -2069,12 +2069,9 @@ void __init ip6_route_init(void)
 	struct proc_dir_entry *p;
 
 	ip6_dst_ops.kmem_cachep = kmem_cache_create("ip6_dst_cache",
-						     sizeof(struct rt6_info),
-						     0, SLAB_HWCACHE_ALIGN,
-						     NULL, NULL);
-	if (!ip6_dst_ops.kmem_cachep)
-		panic("cannot create ip6_dst_cache");
-
+						  sizeof(struct rt6_info), 0,
+						  SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+						  NULL, NULL);
 	fib6_init();
 #ifdef 	CONFIG_PROC_FS
 	p = proc_net_create("ipv6_route", 0, rt6_proc_info);
