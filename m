From: akpm@linux-foundation.org
Subject: [patch 5/8] Use menuconfig objects: TIPC
Date: Wed, 23 May 2007 14:35:55 -0700
Message-ID: <200705232135.l4NLZtKJ000664@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jengelh@linux01.gwdg.de, allan.stephens@windriver.com,
	jengelh@gmx.de, jon.maloy@ericsson.com, per.liden@ericsson.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:34727 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756067AbXEWVgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 17:36:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@linux01.gwdg.de>

Use menuconfigs instead of menus, so the whole menu can be disabled at once
instead of going through all options.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
Cc: Per Liden <per.liden@ericsson.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/tipc/Kconfig |   24 +++++++++++-------------
 1 files changed, 11 insertions(+), 13 deletions(-)

diff -puN net/tipc/Kconfig~use-menuconfig-objects-tipc net/tipc/Kconfig
--- a/net/tipc/Kconfig~use-menuconfig-objects-tipc
+++ a/net/tipc/Kconfig
@@ -2,11 +2,9 @@
 # TIPC configuration
 #
 
-menu "TIPC Configuration (EXPERIMENTAL)"
-	depends on INET && EXPERIMENTAL
-
-config TIPC
+menuconfig TIPC
 	tristate "The TIPC Protocol (EXPERIMENTAL)"
+	depends on INET && EXPERIMENTAL
 	---help---
 	  The Transparent Inter Process Communication (TIPC) protocol is
 	  specially designed for intra cluster communication. This protocol
@@ -22,9 +20,10 @@ config TIPC
 
 	  If in doubt, say N.
 
+if TIPC
+
 config TIPC_ADVANCED
 	bool "TIPC: Advanced configuration"
-	depends on TIPC
 	default n
 	help
 	  Saying Y here will open some advanced configuration
@@ -33,7 +32,7 @@ config TIPC_ADVANCED
 
 config TIPC_ZONES
 	int "Maximum number of zones in network"
-	depends on TIPC && TIPC_ADVANCED
+	depends on TIPC_ADVANCED
 	default "3"
 	help
 	 Max number of zones inside TIPC network. Max supported value 
@@ -44,7 +43,7 @@ config TIPC_ZONES
 
 config TIPC_CLUSTERS
 	int "Maximum number of clusters in a zone"
-	depends on TIPC && TIPC_ADVANCED
+	depends on TIPC_ADVANCED
 	default "1"
 	help
           ***Only 1 (one cluster in a zone) is supported by current code.
@@ -59,7 +58,7 @@ config TIPC_CLUSTERS
 
 config TIPC_NODES
 	int "Maximum number of nodes in cluster"
-	depends on TIPC && TIPC_ADVANCED
+	depends on TIPC_ADVANCED
 	default "255"
 	help
 	  Maximum number of nodes inside a TIPC cluster. Maximum 
@@ -70,7 +69,7 @@ config TIPC_NODES
 
 config TIPC_SLAVE_NODES
 	int "Maximum number of slave nodes in cluster"
-	depends on TIPC && TIPC_ADVANCED
+	depends on TIPC_ADVANCED
 	default "0"
 	help
           ***This capability is not supported by current code.***
@@ -83,7 +82,7 @@ config TIPC_SLAVE_NODES
 
 config TIPC_PORTS
 	int "Maximum number of ports in a node"
-	depends on TIPC && TIPC_ADVANCED
+	depends on TIPC_ADVANCED
 	default "8191"
 	help
 	  Maximum number of ports within a node. Maximum 
@@ -94,7 +93,7 @@ config TIPC_PORTS
 
 config TIPC_LOG
 	int "Size of log buffer"
-	depends on TIPC && TIPC_ADVANCED
+	depends on TIPC_ADVANCED
 	default 0
 	help
  	  Size (in bytes) of TIPC's internal log buffer, which records the
@@ -106,7 +105,6 @@ config TIPC_LOG
 
 config TIPC_DEBUG
 	bool "Enable debugging support"
-	depends on TIPC
 	default n
 	help
  	  This will enable debugging of TIPC.
@@ -114,4 +112,4 @@ config TIPC_DEBUG
 	  Only say Y here if you are having trouble with TIPC.  It will
 	  enable the display of detailed information about what is going on.
 
-endmenu
+endif # TIPC
_
