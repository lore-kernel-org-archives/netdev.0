From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 8/8] Use SLAB_PANIC when creating critical slab cache
Date: Sun, 14 Nov 2004 12:25:21 -0800
Message-ID: <20041114122521.F2357@build.pdx.osdl.net>
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

===== net/xfrm/xfrm_input.c 1.13 vs edited =====
--- 1.13/net/xfrm/xfrm_input.c	2003-07-27 19:22:27 -07:00
+++ edited/net/xfrm/xfrm_input.c	2004-10-29 14:57:20 -07:00
@@ -78,8 +78,6 @@ void __init xfrm_input_init(void)
 {
 	secpath_cachep = kmem_cache_create("secpath_cache",
 					   sizeof(struct sec_path),
-					   0, SLAB_HWCACHE_ALIGN,
+					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL, NULL);
-	if (!secpath_cachep)
-		panic("XFRM: failed to allocate secpath_cache\n");
 }
