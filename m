From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 1/8] Use SLAB_PANIC when creating critical slab cache
Date: Sun, 14 Nov 2004 12:20:00 -0800
Message-ID: <20041114122000.Y2357@build.pdx.osdl.net>
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

===== net/core/flow.c 1.20 vs edited =====
--- 1.20/net/core/flow.c	2004-03-16 18:10:10 -08:00
+++ edited/net/core/flow.c	2004-10-29 14:22:54 -07:00
@@ -343,11 +343,8 @@ static int __init flow_cache_init(void)
 
 	flow_cachep = kmem_cache_create("flow_cache",
 					sizeof(struct flow_cache_entry),
-					0, SLAB_HWCACHE_ALIGN,
+					0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					NULL, NULL);
-
-	if (!flow_cachep)
-		panic("NET: failed to allocate flow cache slab\n");
 
 	flow_hash_shift = 10;
 	flow_lwm = 2 * flow_hash_size;
