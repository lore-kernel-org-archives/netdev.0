From: akpm@linux-foundation.org
Subject: [patch 2/8] Use menuconfig objects: DCCP
Date: Wed, 23 May 2007 14:35:49 -0700
Message-ID: <200705232135.l4NLZoeh000651@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jengelh@linux01.gwdg.de, acme@conectiva.com.br, jengelh@gmx.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:32774 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756509AbXEWVhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 17:37:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@linux01.gwdg.de>

Use menuconfigs instead of menus, so the whole menu can be disabled at once
instead of going through all options.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/dccp/Kconfig |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff -puN net/dccp/Kconfig~use-menuconfig-objects-dccp net/dccp/Kconfig
--- a/net/dccp/Kconfig~use-menuconfig-objects-dccp
+++ a/net/dccp/Kconfig
@@ -1,8 +1,6 @@
-menu "DCCP Configuration (EXPERIMENTAL)"
-	depends on INET && EXPERIMENTAL
-
-config IP_DCCP
+menuconfig IP_DCCP
 	tristate "The DCCP Protocol (EXPERIMENTAL)"
+	depends on INET && EXPERIMENTAL
 	---help---
 	  Datagram Congestion Control Protocol (RFC 4340)
 
@@ -19,19 +17,20 @@ config IP_DCCP
 
 	  If in doubt, say N.
 
+if IP_DCCP
+
 config INET_DCCP_DIAG
-	depends on IP_DCCP && INET_DIAG
+	depends on INET_DIAG
 	def_tristate y if (IP_DCCP = y && INET_DIAG = y)
 	def_tristate m
 
 config IP_DCCP_ACKVEC
-	depends on IP_DCCP
 	bool
 
 source "net/dccp/ccids/Kconfig"
 
 menu "DCCP Kernel Hacking"
-	depends on IP_DCCP && DEBUG_KERNEL=y
+	depends on DEBUG_KERNEL=y
 
 config IP_DCCP_DEBUG
 	bool "DCCP debug messages"
@@ -61,4 +60,4 @@ config NET_DCCPPROBE
 
 endmenu
 
-endmenu
+endif # IP_DDCP
_
