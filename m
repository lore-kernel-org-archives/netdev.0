From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] xfrm6: move define/ifdef check order
Date: Sun, 2 Jul 2006 14:36:11 -0700
Message-ID: <20060702143611.dffe7b15.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:47282 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1750897AbWGBVd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jul 2006 17:33:26 -0400
Received: from midway.site ([71.245.108.25]) by xenotime.net for <netdev@vger.kernel.org>; Sun, 2 Jul 2006 14:33:24 -0700
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

The first check for #ifdef XFRM6_TUNNEL_SPI_MAGIC needs to come after
the optional #define of it, otherwise the variable won't be there
for the rest of the code to use.

Shouldn't that CONFIG_IPV6_XFRM6_TUNNEL_DEBUG be part of Kconfig
or have its name changed?

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 net/ipv6/xfrm6_tunnel.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

--- linux-2617-g20.orig/net/ipv6/xfrm6_tunnel.c
+++ linux-2617-g20/net/ipv6/xfrm6_tunnel.c
@@ -52,6 +52,10 @@
 # define X6TPRINTK3	X6TNOPRINTK
 #endif
 
+#ifdef CONFIG_IPV6_XFRM6_TUNNEL_DEBUG
+# define XFRM6_TUNNEL_SPI_MAGIC 0xdeadbeef
+#endif
+
 /*
  * xfrm_tunnel_spi things are for allocating unique id ("spi") 
  * per xfrm_address_t.
@@ -67,10 +71,6 @@ struct xfrm6_tunnel_spi {
 #endif
 };
 
-#ifdef CONFIG_IPV6_XFRM6_TUNNEL_DEBUG
-# define XFRM6_TUNNEL_SPI_MAGIC 0xdeadbeef
-#endif
-
 static DEFINE_RWLOCK(xfrm6_tunnel_spi_lock);
 
 static u32 xfrm6_tunnel_spi;


---
