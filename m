From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH net-next-2.6] tipc: Clean up configuration file
Date: Tue, 19 Jan 2010 14:10:05 -0500
Message-ID: <1263928205-31788-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54608 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755173Ab0ASSjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 13:39:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses a number of minor (mostly cosmetic) issues relating
to the configuration of TIPC, including the following:

- Corrects range limits for maximum number of ports per node
- Adds missing range limits for size of log buffer
- Removes configuration setting relating to unsupported slave node capability
- Standardizes description and help text wording for configuration settings
- Removes unneeded blank spaces

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/Kconfig |   73 ++++++++++++++++++++----------------------------------
 1 files changed, 27 insertions(+), 46 deletions(-)

diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index dafbd53..b74f78d 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -10,7 +10,7 @@ menuconfig TIPC
 	  specially designed for intra cluster communication. This protocol
 	  originates from Ericsson where it has been used in carrier grade
 	  cluster applications for many years.
-	
+
 	  For more information about TIPC, see http://tipc.sourceforge.net.
 
 	  This protocol support is also available as a module ( = code which
@@ -23,24 +23,23 @@ menuconfig TIPC
 if TIPC
 
 config TIPC_ADVANCED
-	bool "TIPC: Advanced configuration"
+	bool "Advanced TIPC configuration"
 	default n
 	help
-	  Saying Y here will open some advanced configuration
-          for TIPC. Most users do not need to bother, so if
-          unsure, just say N.
+	  Saying Y here will open some advanced configuration for TIPC.
+	  Most users do not need to bother; if unsure, just say N.
 
 config TIPC_ZONES
-	int "Maximum number of zones in network"
+	int "Maximum number of zones in a network"
 	depends on TIPC_ADVANCED
 	range 1 255
 	default "3"
 	help
-	 Max number of zones inside TIPC network. Max supported value 
-         is 255 zones, minimum is 1
+	  Specifies how many zones can be supported in a TIPC network.
+	  Can range from 1 to 255 zones; default is 3.
 
-	 Default is 3 zones in a network; setting this to higher
-	 allows more zones but might use more memory.
+	  Setting this to a smaller value saves some memory;
+	  setting it to a higher value allows for more zones.
 
 config TIPC_CLUSTERS
 	int "Maximum number of clusters in a zone"
@@ -48,70 +47,52 @@ config TIPC_CLUSTERS
 	range 1 1
 	default "1"
 	help
-          ***Only 1 (one cluster in a zone) is supported by current code.***
-
-          (Max number of clusters inside TIPC zone. Max supported 
-          value is 4095 clusters, minimum is 1.
+	  Specifies how many clusters can be supported in a TIPC zone.
 
-	  Default is 1; setting this to smaller value might save 
-          some memory, setting it to higher
-	  allows more clusters and might consume more memory.)
+	  *** Currently TIPC only supports a single cluster per zone. ***
 
 config TIPC_NODES
-	int "Maximum number of nodes in cluster"
+	int "Maximum number of nodes in a cluster"
 	depends on TIPC_ADVANCED
 	range 8 2047
 	default "255"
 	help
-	  Maximum number of nodes inside a TIPC cluster. Maximum 
-          supported value is 2047 nodes, minimum is 8. 
-
-	  Setting this to a smaller value saves some memory, 
-	  setting it to higher allows more nodes.
-
-config TIPC_SLAVE_NODES
-	int "Maximum number of slave nodes in cluster"
-	depends on TIPC_ADVANCED
-	range 0 2047
-	default "0"
-	help
-          ***This capability is not supported by current code.***
-	  
-	  Maximum number of slave nodes inside a TIPC cluster. Maximum 
-          supported value is 2047 nodes, minimum is 0. 
+	  Specifies how many nodes can be supported in a TIPC cluster.
+	  Can range from 8 to 2047 nodes; default is 255.
 
-	  Setting this to a smaller value saves some memory, 
-	  setting it to higher allows more nodes.
+	  Setting this to a smaller value saves some memory;
+	  setting it to higher allows for more nodes.
 
 config TIPC_PORTS
 	int "Maximum number of ports in a node"
 	depends on TIPC_ADVANCED
-	range 217 65536
+	range 127 65535
 	default "8191"
 	help
-	  Maximum number of ports within a node. Maximum 
-          supported value is 64535 nodes, minimum is 127. 
+	  Specifies how many ports can be supported by a node.
+	  Can range from 127 to 65535 ports; default is 8191.
 
 	  Setting this to a smaller value saves some memory, 
-	  setting it to higher allows more ports.
+	  setting it to higher allows for more ports.
 
 config TIPC_LOG
 	int "Size of log buffer"
 	depends on TIPC_ADVANCED
-	default 0
+	range 0 32768
+	default "0"
 	help
- 	  Size (in bytes) of TIPC's internal log buffer, which records the
-	  occurrence of significant events.  Maximum supported value
-	  is 32768 bytes, minimum is 0.
+	  Size (in bytes) of TIPC's internal log buffer, which records the
+	  occurrence of significant events.  Can range from 0 to 32768 bytes;
+	  default is 0.
 
 	  There is no need to enable the log buffer unless the node will be
 	  managed remotely via TIPC.
 
 config TIPC_DEBUG
-	bool "Enable debugging support"
+	bool "Enable debug messages"
 	default n
 	help
- 	  This will enable debugging of TIPC.
+	  This enables debugging of TIPC.
 
 	  Only say Y here if you are having trouble with TIPC.  It will
 	  enable the display of detailed information about what is going on.
-- 
1.5.4.3

