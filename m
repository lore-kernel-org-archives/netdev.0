From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] tipc: use kconfig to limit numeric ranges
Date: Thu, 24 Dec 2009 22:26:48 -0500
Message-ID: <20091225032956.4556.69130.sendpatchset@localhost.localdomain>
Cc: "David S. Miller" <davem@davemloft.net>,
	Allan Stephens <allan.stephens@windriver.com>,
	netdev@vger.kernel.org, Per Liden <per.liden@ericsson.com>,
	tipc-discussion@lists.sourceforge.net,
	Amerigo Wang <amwang@redhat.com>, akpm@linux-foundation.org,
	Jon Maloy <jon.maloy@ericsson.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41240 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750809AbZLYD1V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Dec 2009 22:27:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can rely on kconfig to limit these numbers,
no need to limit them at compile time/run time.

Users who modify these numbers manually should
be responsible for themself. :)

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Per Liden <per.liden@ericsson.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Allan Stephens <allan.stephens@windriver.com>
Cc: David S. Miller <davem@davemloft.net>

---
diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index 3b30d11..dafbd53 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -33,6 +33,7 @@ config TIPC_ADVANCED
 config TIPC_ZONES
 	int "Maximum number of zones in network"
 	depends on TIPC_ADVANCED
+	range 1 255
 	default "3"
 	help
 	 Max number of zones inside TIPC network. Max supported value 
@@ -44,10 +45,10 @@ config TIPC_ZONES
 config TIPC_CLUSTERS
 	int "Maximum number of clusters in a zone"
 	depends on TIPC_ADVANCED
+	range 1 1
 	default "1"
 	help
-          ***Only 1 (one cluster in a zone) is supported by current code.
-          Any value set here will be overridden.***
+          ***Only 1 (one cluster in a zone) is supported by current code.***
 
           (Max number of clusters inside TIPC zone. Max supported 
           value is 4095 clusters, minimum is 1.
@@ -59,6 +60,7 @@ config TIPC_CLUSTERS
 config TIPC_NODES
 	int "Maximum number of nodes in cluster"
 	depends on TIPC_ADVANCED
+	range 8 2047
 	default "255"
 	help
 	  Maximum number of nodes inside a TIPC cluster. Maximum 
@@ -70,6 +72,7 @@ config TIPC_NODES
 config TIPC_SLAVE_NODES
 	int "Maximum number of slave nodes in cluster"
 	depends on TIPC_ADVANCED
+	range 0 2047
 	default "0"
 	help
           ***This capability is not supported by current code.***
@@ -83,6 +86,7 @@ config TIPC_SLAVE_NODES
 config TIPC_PORTS
 	int "Maximum number of ports in a node"
 	depends on TIPC_ADVANCED
+	range 217 65536
 	default "8191"
 	help
 	  Maximum number of ports within a node. Maximum 
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 3256bd7..52c571f 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -189,11 +189,11 @@ static int __init tipc_init(void)
 	tipc_remote_management = 1;
 	tipc_max_publications = 10000;
 	tipc_max_subscriptions = 2000;
-	tipc_max_ports = delimit(CONFIG_TIPC_PORTS, 127, 65536);
-	tipc_max_zones = delimit(CONFIG_TIPC_ZONES, 1, 255);
-	tipc_max_clusters = delimit(CONFIG_TIPC_CLUSTERS, 1, 1);
-	tipc_max_nodes = delimit(CONFIG_TIPC_NODES, 8, 2047);
-	tipc_max_slaves = delimit(CONFIG_TIPC_SLAVE_NODES, 0, 2047);
+	tipc_max_ports = CONFIG_TIPC_PORTS;
+	tipc_max_zones = CONFIG_TIPC_ZONES;
+	tipc_max_clusters = CONFIG_TIPC_CLUSTERS;
+	tipc_max_nodes = CONFIG_TIPC_NODES;
+	tipc_max_slaves = CONFIG_TIPC_SLAVE_NODES;
 	tipc_net_id = 4711;
 
 	if ((res = tipc_core_start()))
