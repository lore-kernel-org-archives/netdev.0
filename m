From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 2/8] Use SLAB_PANIC when creating critical slab cache
Date: Sun, 14 Nov 2004 12:20:48 -0800
Message-ID: <20041114122048.Z2357@build.pdx.osdl.net>
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

===== net/core/skbuff.c 1.39 vs edited =====
--- 1.39/net/core/skbuff.c	2004-10-19 21:56:24 -07:00
+++ edited/net/core/skbuff.c	2004-10-29 14:23:43 -07:00
@@ -1430,10 +1430,8 @@ void __init skb_init(void)
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
 					      sizeof(struct sk_buff),
 					      0,
-					      SLAB_HWCACHE_ALIGN,
+					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					      NULL, NULL);
-	if (!skbuff_head_cache)
-		panic("cannot create skbuff cache");
 }
 
 EXPORT_SYMBOL(___pskb_trim);
