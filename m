From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 4/8] Use SLAB_PANIC when creating critical slab cache
Date: Sun, 14 Nov 2004 12:22:38 -0800
Message-ID: <20041114122238.B2357@build.pdx.osdl.net>
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

===== net/ipv4/inetpeer.c 1.9 vs edited =====
--- 1.9/net/ipv4/inetpeer.c	2004-02-23 15:09:14 -08:00
+++ edited/net/ipv4/inetpeer.c	2004-10-29 14:17:33 -07:00
@@ -126,11 +126,8 @@ void __init inet_initpeers(void)
 
 	peer_cachep = kmem_cache_create("inet_peer_cache",
 			sizeof(struct inet_peer),
-			0, SLAB_HWCACHE_ALIGN,
+			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 			NULL, NULL);
-
-	if (!peer_cachep)
-		panic("cannot create inet_peer_cache");
 
 	/* All the timers, started at system startup tend
 	   to synchronize. Perturb it a bit.
