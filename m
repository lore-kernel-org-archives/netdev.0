From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] allow ip_tables.h to be used from userspace
Date: Tue, 5 Dec 2006 10:29:27 -0800
Message-ID: <20061205102927.4f1ef22f@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devl@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:34059 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968598AbWLES3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 13:29:36 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The xtables version of ip_tables.h was no longer usable (in sanitized form)
by iproute2 and other applications because sparse annotations had crept
in.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 include/linux/netfilter_ipv4/ip_tables.h |    4 ++--
 net/ipv4/netfilter/ip_tables.c           |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index 4f06dad..0640c6c 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -21,8 +21,8 @@ #include <linux/types.h>
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/skbuff.h>
-#endif
 #include <linux/compiler.h>
+#endif
 #include <linux/netfilter_ipv4.h>
 
 #include <linux/netfilter/x_tables.h>
@@ -194,7 +194,7 @@ struct ipt_replace
 	/* Number of counters (must be equal to current number of entries). */
 	unsigned int num_counters;
 	/* The old entries' counters. */
-	struct xt_counters __user *counters;
+	struct xt_counters *counters;
 
 	/* The entries (hang off end: not really an array). */
 	struct ipt_entry entries[0];
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 8a45543..e75d467 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1238,8 +1238,8 @@ do_replace(void __user *user, unsigned i
 	duprintf("ip_tables: Translated table\n");
 
 	ret = __do_replace(tmp.name, tmp.valid_hooks,
-			      newinfo, tmp.num_counters,
-			      tmp.counters);
+			   newinfo, tmp.num_counters,
+			   (void __user *) tmp.counters);
 	if (ret)
 		goto free_newinfo_untrans;
 	return 0;
-- 
1.4.1

