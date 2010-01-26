From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/21] net/atm/mpoa_proc.c: checkpatch cleanups
Date: Tue, 26 Jan 2010 13:40:11 -0800
Message-ID: <fc2aa1e2b6f138ff48cb88bad569f45787d60ce4.1264541549.git.joe@perches.com>
References: <cover.1264541547.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1487 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753953Ab0AZVkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 16:40:24 -0500
In-Reply-To: <cover.1264541547.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert #include <asm... to #include <linux...
Add printk argument verification to dprintk and ddprintk
Spacing cleanups
Mostly 80 column wrapped.
Removed unnecessary breaks after returns
Use %pI4 in seq_printf of IP address

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/mpoa_proc.c |   64 ++++++++++++++++++++++++--------------------------
 1 files changed, 31 insertions(+), 33 deletions(-)

diff --git a/net/atm/mpoa_proc.c b/net/atm/mpoa_proc.c
index 0603ab4..aae4a87 100644
--- a/net/atm/mpoa_proc.c
+++ b/net/atm/mpoa_proc.c
@@ -9,7 +9,7 @@
 #include <linux/proc_fs.h>
 #include <linux/time.h>
 #include <linux/seq_file.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/atmmpc.h>
 #include <linux/atm.h>
 #include "mpc.h"
@@ -21,9 +21,10 @@
  */
 
 #if 1
-#define dprintk printk   /* debug */
+#define dprintk(format, args...) printk(KERN_DEBUG format, ##args)   /* debug */
 #else
-#define dprintk(format,args...)
+#define dprintk(format, args...)			\
+	do { if (0) printk(KERN_DEBUG format, ##args); } while (0)
 #endif
 
 #define STAT_FILE_NAME "mpc"     /* Our statistic file's name */
@@ -52,42 +53,37 @@ static const struct file_operations mpc_file_operations = {
 /*
  * Returns the state of an ingress cache entry as a string
  */
-static const char *ingress_state_string(int state){
-	switch(state) {
+static const char *ingress_state_string(int state)
+{
+	switch (state) {
 	case INGRESS_RESOLVING:
 		return "resolving  ";
-		break;
 	case INGRESS_RESOLVED:
 		return "resolved   ";
-		break;
 	case INGRESS_INVALID:
 		return "invalid    ";
-		break;
 	case INGRESS_REFRESHING:
 		return "refreshing ";
-		break;
-	default:
-	       return "";
 	}
+
+	return "";
 }
 
 /*
  * Returns the state of an egress cache entry as a string
  */
-static const char *egress_state_string(int state){
-	switch(state) {
+static const char *egress_state_string(int state)
+{
+	switch (state) {
 	case EGRESS_RESOLVED:
 		return "resolved   ";
-		break;
 	case EGRESS_PURGE:
 		return "purge      ";
-		break;
 	case EGRESS_INVALID:
 		return "invalid    ";
-		break;
-	default:
-	       return "";
 	}
+
+	return "";
 }
 
 /*
@@ -124,7 +120,6 @@ static void mpc_stop(struct seq_file *m, void *v)
 static int mpc_show(struct seq_file *m, void *v)
 {
 	struct mpoa_client *mpc = v;
-	unsigned char *temp;
 	int i;
 	in_cache_entry *in_entry;
 	eg_cache_entry *eg_entry;
@@ -141,15 +136,17 @@ static int mpc_show(struct seq_file *m, void *v)
 	do_gettimeofday(&now);
 
 	for (in_entry = mpc->in_cache; in_entry; in_entry = in_entry->next) {
-		temp = (unsigned char *)&in_entry->ctrl_info.in_dst_ip;
-		sprintf(ip_string,"%d.%d.%d.%d", temp[0], temp[1], temp[2], temp[3]);
+		sprintf(ip_string, "%pI4", &in_entry->ctrl_info.in_dst_ip);
 		seq_printf(m, "%-16s%s%-14lu%-12u",
-			      ip_string,
-			      ingress_state_string(in_entry->entry_state),
-			      in_entry->ctrl_info.holding_time-(now.tv_sec-in_entry->tv.tv_sec),
-			      in_entry->packets_fwded);
+			   ip_string,
+			   ingress_state_string(in_entry->entry_state),
+			   in_entry->ctrl_info.holding_time -
+			   (now.tv_sec-in_entry->tv.tv_sec),
+			   in_entry->packets_fwded);
 		if (in_entry->shortcut)
-			seq_printf(m, "   %-3d  %-3d",in_entry->shortcut->vpi,in_entry->shortcut->vci);
+			seq_printf(m, "   %-3d  %-3d",
+				   in_entry->shortcut->vpi,
+				   in_entry->shortcut->vci);
 		seq_printf(m, "\n");
 	}
 
@@ -157,21 +154,23 @@ static int mpc_show(struct seq_file *m, void *v)
 	seq_printf(m, "Egress Entries:\nIngress MPC ATM addr\nCache-id        State      Holding time  Packets recvd  Latest IP addr   VPI VCI\n");
 	for (eg_entry = mpc->eg_cache; eg_entry; eg_entry = eg_entry->next) {
 		unsigned char *p = eg_entry->ctrl_info.in_MPC_data_ATM_addr;
-		for(i = 0; i < ATM_ESA_LEN; i++)
+		for (i = 0; i < ATM_ESA_LEN; i++)
 			seq_printf(m, "%02x", p[i]);
 		seq_printf(m, "\n%-16lu%s%-14lu%-15u",
 			   (unsigned long)ntohl(eg_entry->ctrl_info.cache_id),
 			   egress_state_string(eg_entry->entry_state),
-			   (eg_entry->ctrl_info.holding_time-(now.tv_sec-eg_entry->tv.tv_sec)),
+			   (eg_entry->ctrl_info.holding_time -
+			    (now.tv_sec-eg_entry->tv.tv_sec)),
 			   eg_entry->packets_rcvd);
 
 		/* latest IP address */
-		temp = (unsigned char *)&eg_entry->latest_ip_addr;
-		sprintf(ip_string, "%d.%d.%d.%d", temp[0], temp[1], temp[2], temp[3]);
+		sprintf(ip_string, "%pI4", &eg_entry->latest_ip_addr);
 		seq_printf(m, "%-16s", ip_string);
 
 		if (eg_entry->shortcut)
-			seq_printf(m, " %-3d %-3d",eg_entry->shortcut->vpi,eg_entry->shortcut->vci);
+			seq_printf(m, " %-3d %-3d",
+				   eg_entry->shortcut->vpi,
+				   eg_entry->shortcut->vci);
 		seq_printf(m, "\n");
 	}
 	seq_printf(m, "\n");
@@ -290,10 +289,9 @@ int mpc_proc_init(void)
  */
 void mpc_proc_clean(void)
 {
-	remove_proc_entry(STAT_FILE_NAME,atm_proc_root);
+	remove_proc_entry(STAT_FILE_NAME, atm_proc_root);
 }
 
-
 #endif /* CONFIG_PROC_FS */
 
 
-- 
1.6.6.rc0.57.gad7a

