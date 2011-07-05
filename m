From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 6/6] batman-adv: Replace version info instead of appending them
Date: Tue,  5 Jul 2011 15:44:00 +0200
Message-ID: <1309873440-11704-7-git-send-email-lindner_marek@yahoo.de>
References: <1309873440-11704-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm7.bullet.mail.ukl.yahoo.com ([217.146.182.248]:39954 "HELO
	nm7.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751372Ab1GENo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 09:44:29 -0400
In-Reply-To: <1309873440-11704-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The version number of modules build outside of the tree can get revision
numbers added. This is useful to give hints about the revision of a
distribution package and the used patchset. The prepended source number or
branch name doesn't add any additional information which would help to identify
problems and can therefore be omitted.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/gateway_client.c |    5 ++---
 net/batman-adv/main.c           |    9 ++-------
 net/batman-adv/main.h           |   11 +++--------
 net/batman-adv/originator.c     |    5 ++---
 4 files changed, 9 insertions(+), 21 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 8b25b52..056180e 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -487,10 +487,9 @@ int gw_client_seq_print_text(struct seq_file *seq, void *offset)
 	}
 
 	seq_printf(seq, "      %-12s (%s/%i) %17s [%10s]: gw_class ... "
-		   "[B.A.T.M.A.N. adv %s%s, MainIF/MAC: %s/%pM (%s)]\n",
+		   "[B.A.T.M.A.N. adv %s, MainIF/MAC: %s/%pM (%s)]\n",
 		   "Gateway", "#", TQ_MAX_VALUE, "Nexthop",
-		   "outgoingIF", SOURCE_VERSION, REVISION_VERSION_STR,
-		   primary_if->net_dev->name,
+		   "outgoingIF", SOURCE_VERSION, primary_if->net_dev->name,
 		   primary_if->net_dev->dev_addr, net_dev->name);
 
 	rcu_read_lock();
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index e367e69..b0f9068 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -58,9 +58,8 @@ static int __init batman_init(void)
 
 	register_netdevice_notifier(&hard_if_notifier);
 
-	pr_info("B.A.T.M.A.N. advanced %s%s (compatibility version %i) "
-		"loaded\n", SOURCE_VERSION, REVISION_VERSION_STR,
-		COMPAT_VERSION);
+	pr_info("B.A.T.M.A.N. advanced %s (compatibility version %i) "
+		"loaded\n", SOURCE_VERSION, COMPAT_VERSION);
 
 	return 0;
 }
@@ -184,8 +183,4 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR(DRIVER_AUTHOR);
 MODULE_DESCRIPTION(DRIVER_DESC);
 MODULE_SUPPORTED_DEVICE(DRIVER_DEVICE);
-#ifdef REVISION_VERSION
-MODULE_VERSION(SOURCE_VERSION "-" REVISION_VERSION);
-#else
 MODULE_VERSION(SOURCE_VERSION);
-#endif
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 4f293b5..a6df61a 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -27,8 +27,9 @@
 #define DRIVER_DESC   "B.A.T.M.A.N. advanced"
 #define DRIVER_DEVICE "batman-adv"
 
-#define SOURCE_VERSION "next"
-
+#ifndef SOURCE_VERSION
+#define SOURCE_VERSION "2011.3.0"
+#endif
 
 /* B.A.T.M.A.N. parameters */
 
@@ -144,12 +145,6 @@ enum dbg_level {
 #include <linux/seq_file.h>
 #include "types.h"
 
-#ifndef REVISION_VERSION
-#define REVISION_VERSION_STR ""
-#else
-#define REVISION_VERSION_STR " "REVISION_VERSION
-#endif
-
 extern struct list_head hardif_list;
 
 extern unsigned char broadcast_addr[];
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 338b3c5..4cc94d4 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -430,9 +430,8 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 		goto out;
 	}
 
-	seq_printf(seq, "[B.A.T.M.A.N. adv %s%s, MainIF/MAC: %s/%pM (%s)]\n",
-		   SOURCE_VERSION, REVISION_VERSION_STR,
-		   primary_if->net_dev->name,
+	seq_printf(seq, "[B.A.T.M.A.N. adv %s, MainIF/MAC: %s/%pM (%s)]\n",
+		   SOURCE_VERSION, primary_if->net_dev->name,
 		   primary_if->net_dev->dev_addr, net_dev->name);
 	seq_printf(seq, "  %-15s %s (%s/%i) %17s [%10s]: %20s ...\n",
 		   "Originator", "last-seen", "#", TQ_MAX_VALUE, "Nexthop",
-- 
1.7.5.3

