From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: xfrm6: move define/ifdef check order and add a Kconfig option
Date: Mon, 3 Jul 2006 21:42:33 -0700
Message-ID: <20060703214233.fa202523.rdunlap@xenotime.net>
References: <20060702143611.dffe7b15.rdunlap@xenotime.net>
	<20060703.194655.38711929.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:52663 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1750859AbWGDEjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 00:39:48 -0400
Received: from midway.site ([71.245.108.25]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 3 Jul 2006 21:39:46 -0700
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060703.194655.38711929.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 03 Jul 2006 19:46:55 -0700 (PDT) David Miller wrote:

> Yes, indeed.  Nothing named CONFIG_* should be defined explicitly
> by the source files, only through Kconfig.
> 
> I would rather address that than apply this patch.

by adding a Kconfig option or not?  This patch adds one.


From: Randy Dunlap <rdunlap@xenotime.net>

Convert CONFIG_IPV6_XFRM6_TUNNEL_DEBUG (not a Kconfig option)
to CONFIG_INET6_XFRM6_TUNNEL_DEBUG, which is a Kconfig option.

Then #define XFRM6_TUNNEL_SPI_MAGIC before it is first used.

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 net/ipv6/Kconfig        |    6 ++++++
 net/ipv6/xfrm6_tunnel.c |    7 ++-----
 2 files changed, 8 insertions(+), 5 deletions(-)

--- linux-2617-g20.orig/net/ipv6/xfrm6_tunnel.c
+++ linux-2617-g20/net/ipv6/xfrm6_tunnel.c
@@ -31,8 +31,9 @@
 #include <linux/icmpv6.h>
 #include <linux/mutex.h>
 
-#ifdef CONFIG_IPV6_XFRM6_TUNNEL_DEBUG
+#ifdef CONFIG_INET6_XFRM_TUNNEL_DEBUG
 # define X6TDEBUG	3
+# define XFRM6_TUNNEL_SPI_MAGIC 0xdeadbeef
 #else
 # define X6TDEBUG	1
 #endif
@@ -67,10 +68,6 @@ struct xfrm6_tunnel_spi {
 #endif
 };
 
-#ifdef CONFIG_IPV6_XFRM6_TUNNEL_DEBUG
-# define XFRM6_TUNNEL_SPI_MAGIC 0xdeadbeef
-#endif
-
 static DEFINE_RWLOCK(xfrm6_tunnel_spi_lock);
 
 static u32 xfrm6_tunnel_spi;
--- linux-2617-g20.orig/net/ipv6/Kconfig
+++ linux-2617-g20/net/ipv6/Kconfig
@@ -106,6 +106,12 @@ config INET6_TUNNEL
 	tristate
 	default n
 
+config INET6_XFRM_TUNNEL_DEBUG
+	bool "IPv6: xfrm tunnel debug"
+	depends on INET6_XFRM_TUNNEL
+	---help---
+	  Enable IPv6 tunnel debug code.
+
 config INET6_XFRM_MODE_TRANSPORT
 	tristate "IPv6: IPsec transport mode"
 	depends on IPV6



---
