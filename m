From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 6/6][CORE] Remove the empty net_table
Date: Sat, 01 Dec 2007 16:11:28 +0300
Message-ID: <47515D80.4000208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55381 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751566AbXLANLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 08:11:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have removed all the entries from this table (core_table,
ipv4_table and tr_table), so now we can safely drop it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/net.h b/include/linux/net.h
index f95f12c..c414d90 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -337,7 +337,6 @@ static const struct proto_ops name##_ops = {			\
 
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
-extern ctl_table net_table[];
 extern int net_msg_cost;
 extern int net_msg_burst;
 #endif
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 946a01c..894a177 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -199,14 +199,6 @@ static struct ctl_table root_table[] = {
 		.mode		= 0555,
 		.child		= vm_table,
 	},
-#ifdef CONFIG_NET
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= net_table,
-	},
-#endif
 	{
 		.ctl_name	= CTL_FS,
 		.procname	= "fs",
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 16ad14b..665e856 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -30,10 +30,6 @@
 #include <linux/if_tr.h>
 #endif
 
-struct ctl_table net_table[] = {
-	{ 0 },
-};
-
 static struct list_head *
 net_ctl_header_lookup(struct ctl_table_root *root, struct nsproxy *namespaces)
 {
-- 
1.5.3.4

