From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 5/8] Use SLAB_PANIC when creating critical slab cache
Date: Sun, 14 Nov 2004 12:23:18 -0800
Message-ID: <20041114122318.C2357@build.pdx.osdl.net>
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

===== net/ipv4/ipmr.c 1.45 vs edited =====
--- 1.45/net/ipv4/ipmr.c	2004-07-20 14:55:34 -07:00
+++ edited/net/ipv4/ipmr.c	2004-10-29 14:11:57 -07:00
@@ -1885,11 +1885,8 @@ void __init ip_mr_init(void)
 {
 	mrt_cachep = kmem_cache_create("ip_mrt_cache",
 				       sizeof(struct mfc_cache),
-				       0, SLAB_HWCACHE_ALIGN,
+				       0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 				       NULL, NULL);
-	if (!mrt_cachep)
-		panic("cannot allocate ip_mrt_cache");
-
 	init_timer(&ipmr_expire_timer);
 	ipmr_expire_timer.function=ipmr_expire_process;
 	register_netdevice_notifier(&ip_mr_notifier);
