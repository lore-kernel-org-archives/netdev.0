From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 4/17]: Check TCA_ACT_KIND payload size _before_
 copying it
Date: Thu, 30 Dec 2004 04:39:33 +0100
Message-ID: <41D37875.5020103@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070503010905070807000800"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070503010905070807000800
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Fix payload size checks like this one:

-                       sprintf(act_name, "%s", (char*)RTA_DATA(kind));
-                       if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
-                               printk("Action %s bad\n", 
(char*)RTA_DATA(kind))


--------------070503010905070807000800
Content-Type: text/x-patch;
 name="04.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 01:45:41+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Check TCA_ACT_KIND payload size _before_ copying it
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2004/12/30 01:45:35+01:00 kaber@coreworks.de +6 -14
#   [PKT_SCHED]: Check TCA_ACT_KIND payload size _before_ copying it
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2004-12-30 04:01:10 +01:00
+++ b/net/sched/act_api.c	2004-12-30 04:01:10 +01:00
@@ -288,11 +288,9 @@
 			goto err_out;
 		kind = tb[TCA_ACT_KIND-1];
 		if (kind != NULL) {
-			sprintf(act_name, "%s", (char*)RTA_DATA(kind));
-			if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
-				printk("Action %s bad\n", (char*)RTA_DATA(kind));
+			if (RTA_PAYLOAD(kind) >= IFNAMSIZ)
 				goto err_out;
-			}
+			sprintf(act_name, "%s", (char*)RTA_DATA(kind));
 		} else {
 			printk("Action bad kind\n");
 			goto err_out;
@@ -503,12 +501,9 @@
 		goto err_out;
 	kind = tb[TCA_ACT_KIND-1];
 	if (kind != NULL) {
-		sprintf(act_name, "%s", (char*)RTA_DATA(kind));
-		if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
-			printk("tcf_action_get_1: action %s bad\n",
-			       (char*)RTA_DATA(kind));
+		if (RTA_PAYLOAD(kind) >= IFNAMSIZ)
 			goto err_out;
-		}
+		sprintf(act_name, "%s", (char*)RTA_DATA(kind));
 	} else {
 		printk("tcf_action_get_1: action bad kind\n");
 		goto err_out;
@@ -567,12 +562,9 @@
 	struct tc_action_ops *a_o = NULL;
 
 	if (kind != NULL) {
-		sprintf(act_name, "%s", (char*)RTA_DATA(kind));
-		if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
-			printk("get_ao: action %s bad\n",
-			       (char*)RTA_DATA(kind));
+		if (RTA_PAYLOAD(kind) >= IFNAMSIZ)
 			return NULL;
-		}
+		sprintf(act_name, "%s", (char*)RTA_DATA(kind));
 	} else {
 		printk("get_ao: action bad kind\n");
 		return NULL;

--------------070503010905070807000800--
