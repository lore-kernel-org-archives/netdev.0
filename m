From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 5/22]: act_api.c: remove unnecessary initializations
Date: Mon, 10 Jan 2005 20:37:51 +0100
Message-ID: <41E2D98F.7050405@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050805080104040606000706"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050805080104040606000706
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------050805080104040606000706
Content-Type: text/x-patch;
 name="05.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="05.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/09 22:52:33+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: act_api.c: remove unnecessary initializations
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/09 22:52:25+01:00 kaber@coreworks.de +10 -13
#   [PKT_SCHED]: act_api.c: remove unnecessary initializations
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-10 06:22:01 +01:00
+++ b/net/sched/act_api.c	2005-01-10 06:22:01 +01:00
@@ -274,7 +274,7 @@
 	struct tc_action_ops *a_o;
 	char act_name[4 + IFNAMSIZ + 1];
 	struct rtattr *tb[TCA_ACT_MAX+1];
-	struct rtattr *kind = NULL;
+	struct rtattr *kind;
 
 	*err = -EINVAL;
 
@@ -494,7 +494,7 @@
 	struct tc_action_ops *a_o;
 	char act_name[4 + IFNAMSIZ + 1];
 	struct rtattr *tb[TCA_ACT_MAX+1];
-	struct rtattr *kind = NULL;
+	struct rtattr *kind;
 	int index;
 	int err = -EINVAL;
 
@@ -563,7 +563,7 @@
 static struct tc_action_ops *get_ao(struct rtattr *kind, struct tc_action *a)
 {
 	char act_name[4 + IFNAMSIZ + 1];
-	struct tc_action_ops *a_o = NULL;
+	struct tc_action_ops *a_o;
 
 	if (kind != NULL) {
 		sprintf(act_name, "%s", (char*)RTA_DATA(kind));
@@ -596,7 +596,7 @@
 
 static struct tc_action *create_a(int i)
 {
-	struct tc_action *act = NULL;
+	struct tc_action *act;
 
 	act = kmalloc(sizeof(*act), GFP_KERNEL);
 	if (act == NULL) {
@@ -617,7 +617,7 @@
 	struct netlink_callback dcb;
 	struct rtattr *x;
 	struct rtattr *tb[TCA_ACT_MAX+1];
-	struct rtattr *kind = NULL;
+	struct rtattr *kind;
 	struct tc_action *a = create_a(0);
 	int err = -EINVAL;
 
@@ -677,9 +677,8 @@
 static int
 tca_action_gd(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int event)
 {
-	int s = 0;
 	int i, ret = 0;
-	struct tc_action *act = NULL;
+	struct tc_action *act;
 	struct rtattr *tb[TCA_ACT_MAX_PRIO+1];
 	struct tc_action *a = NULL, *a_s = NULL;
 
@@ -707,10 +706,8 @@
 		} else
 			a = act;
 
-		if (!s) {
-			s = 1;
+		if (a_s == NULL)
 			a_s = a;
-		}
 
 		ret = tcf_action_get_1(tb[i], act, n, pid);
 		if (ret < 0) {
@@ -800,8 +797,8 @@
 tcf_action_add(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int ovr)
 {
 	int ret = 0;
-	struct tc_action *act = NULL;
-	struct tc_action *a = NULL;
+	struct tc_action *act;
+	struct tc_action *a;
 	u32 seq = n->nlmsg_seq;
 
 	act = tcf_action_init(rta, NULL, NULL, ovr, 0, &ret);
@@ -865,7 +862,7 @@
 	struct rtattr *tb1, *tb2[TCA_ACT_MAX+1];
 	struct rtattr *tb[TCA_ACT_MAX_PRIO + 1];
 	struct rtattr *rta[TCAA_MAX + 1];
-	struct rtattr *kind = NULL;
+	struct rtattr *kind;
 	int min_len = NLMSG_LENGTH(sizeof(struct tcamsg));
 	int attrlen = n->nlmsg_len - NLMSG_ALIGN(min_len);
 	struct rtattr *attr = (void *) n + NLMSG_ALIGN(min_len);

--------------050805080104040606000706--
