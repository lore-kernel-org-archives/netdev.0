From: akpm@linux-foundation.org
Subject: [patch 4/8] Use menuconfig objects: SCTP
Date: Wed, 23 May 2007 14:35:54 -0700
Message-ID: <200705232135.l4NLZsK9000661@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jengelh@linux01.gwdg.de, jengelh@gmx.de, sri@us.ibm.com,
	vladislav.yasevich@hp.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:47751 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756100AbXEWVgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 17:36:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@linux01.gwdg.de>

Use menuconfigs instead of menus, so the whole menu can be disabled at once
instead of going through all options.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
Cc: Sridhar Samudrala <sri@us.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sctp/Kconfig |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff -puN net/sctp/Kconfig~use-menuconfig-objects-sctp net/sctp/Kconfig
--- a/net/sctp/Kconfig~use-menuconfig-objects-sctp
+++ a/net/sctp/Kconfig
@@ -2,11 +2,9 @@
 # SCTP configuration
 #
 
-menu "SCTP Configuration (EXPERIMENTAL)"
-	depends on INET && EXPERIMENTAL
-
-config IP_SCTP
+menuconfig IP_SCTP
 	tristate "The SCTP Protocol (EXPERIMENTAL)"
+	depends on INET && EXPERIMENTAL
 	depends on IPV6 || IPV6=n
 	select CRYPTO if SCTP_HMAC_SHA1 || SCTP_HMAC_MD5
 	select CRYPTO_HMAC if SCTP_HMAC_SHA1 || SCTP_HMAC_MD5
@@ -36,9 +34,10 @@ config IP_SCTP
 
 	  If in doubt, say N.
 
+if IP_SCTP
+
 config SCTP_DBG_MSG
 	bool "SCTP: Debug messages"
-	depends on IP_SCTP
 	help
 	  If you say Y, this will enable verbose debugging messages. 
 
@@ -47,7 +46,6 @@ config SCTP_DBG_MSG
 
 config SCTP_DBG_OBJCNT
 	bool "SCTP: Debug object counts"
-	depends on IP_SCTP
 	help
 	  If you say Y, this will enable debugging support for counting the 
 	  type of objects that are currently allocated.  This is useful for 
@@ -59,7 +57,6 @@ config SCTP_DBG_OBJCNT
 
 choice
 	prompt "SCTP: Cookie HMAC Algorithm"
-	depends on IP_SCTP
 	default SCTP_HMAC_MD5
 	help
 	  HMAC algorithm to be used during association initialization.  It
@@ -86,4 +83,5 @@ config SCTP_HMAC_MD5
 	  advised to use either HMAC-MD5 or HMAC-SHA1.
 
 endchoice
-endmenu
+
+endif # IP_SCTP
_
