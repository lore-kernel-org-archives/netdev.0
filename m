From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH] xfrm: make xfrm_algo.c a module
Date: Wed, 09 May 2012 08:53:51 +0100
Message-ID: <4FAA3EAF02000078000826E4@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:56502 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754521Ab2EII52 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:2:2>);
	Wed, 9 May 2012 04:57:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By making this a standalone config option (selected as needed),
selecting CRYPTO from here rather than from XFRM (which is boolean)
allows the core crypto code to become a module again even when XFRM=y.

Signed-off-by: Jan Beulich <jbeulich@suse.com>

---
 net/ipv4/Kconfig     |    4 ++--
 net/ipv6/Kconfig     |    4 ++--
 net/xfrm/Kconfig     |   13 +++++++++----
 net/xfrm/Makefile    |    3 ++-
 net/xfrm/xfrm_algo.c |    5 ++---
 5 files changed, 17 insertions(+), 12 deletions(-)

--- 3.4-rc6/net/ipv4/Kconfig
+++ 3.4-rc6-xfrm-algo-module/net/ipv4/Kconfig
@@ -312,7 +312,7 @@ config SYN_COOKIES
 
 config INET_AH
 	tristate "IP: AH transformation"
-	select XFRM
+	select XFRM_ALGO
 	select CRYPTO
 	select CRYPTO_HMAC
 	select CRYPTO_MD5
@@ -324,7 +324,7 @@ config INET_AH
 
 config INET_ESP
 	tristate "IP: ESP transformation"
-	select XFRM
+	select XFRM_ALGO
 	select CRYPTO
 	select CRYPTO_AUTHENC
 	select CRYPTO_HMAC
--- 3.4-rc6/net/ipv6/Kconfig
+++ 3.4-rc6-xfrm-algo-module/net/ipv6/Kconfig
@@ -69,7 +69,7 @@ config IPV6_OPTIMISTIC_DAD
 
 config INET6_AH
 	tristate "IPv6: AH transformation"
-	select XFRM
+	select XFRM_ALGO
 	select CRYPTO
 	select CRYPTO_HMAC
 	select CRYPTO_MD5
@@ -81,7 +81,7 @@ config INET6_AH
 
 config INET6_ESP
 	tristate "IPv6: ESP transformation"
-	select XFRM
+	select XFRM_ALGO
 	select CRYPTO
 	select CRYPTO_AUTHENC
 	select CRYPTO_HMAC
--- 3.4-rc6/net/xfrm/Kconfig
+++ 3.4-rc6-xfrm-algo-module/net/xfrm/Kconfig
@@ -3,12 +3,17 @@
 #
 config XFRM
        bool
-       select CRYPTO
        depends on NET
 
+config XFRM_ALGO
+	tristate
+	select XFRM
+	select CRYPTO
+
 config XFRM_USER
 	tristate "Transformation user configuration interface"
-	depends on INET && XFRM
+	depends on INET
+	select XFRM_ALGO
 	---help---
 	  Support for Transformation(XFRM) user configuration interface
 	  like IPsec used by native Linux tools.
@@ -48,13 +53,13 @@ config XFRM_STATISTICS
 
 config XFRM_IPCOMP
 	tristate
-	select XFRM
+	select XFRM_ALGO
 	select CRYPTO
 	select CRYPTO_DEFLATE
 
 config NET_KEY
 	tristate "PF_KEY sockets"
-	select XFRM
+	select XFRM_ALGO
 	---help---
 	  PF_KEYv2 socket family, compatible to KAME ones.
 	  They are required if you are going to use IPsec tools ported
--- 3.4-rc6/net/xfrm/Makefile
+++ 3.4-rc6-xfrm-algo-module/net/xfrm/Makefile
@@ -3,8 +3,9 @@
 #
 
 obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_hash.o \
-		      xfrm_input.o xfrm_output.o xfrm_algo.o \
+		      xfrm_input.o xfrm_output.o \
 		      xfrm_sysctl.o xfrm_replay.o
 obj-$(CONFIG_XFRM_STATISTICS) += xfrm_proc.o
+obj-$(CONFIG_XFRM_ALGO) += xfrm_algo.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
 obj-$(CONFIG_XFRM_IPCOMP) += xfrm_ipcomp.o
--- 3.4-rc6/net/xfrm/xfrm_algo.c
+++ 3.4-rc6-xfrm-algo-module/net/xfrm/xfrm_algo.c
@@ -15,9 +15,6 @@
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>
 #include <net/xfrm.h>
-#if defined(CONFIG_INET_AH) || defined(CONFIG_INET_AH_MODULE) || defined(CONFIG_INET6_AH) || defined(CONFIG_INET6_AH_MODULE)
-#include <net/ah.h>
-#endif
 #if defined(CONFIG_INET_ESP) || defined(CONFIG_INET_ESP_MODULE) || defined(CONFIG_INET6_ESP) || defined(CONFIG_INET6_ESP_MODULE)
 #include <net/esp.h>
 #endif
@@ -752,3 +749,5 @@ void *pskb_put(struct sk_buff *skb, stru
 }
 EXPORT_SYMBOL_GPL(pskb_put);
 #endif
+
+MODULE_LICENSE("GPL");
