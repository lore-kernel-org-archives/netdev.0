From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 5/6]: tcf_exts: rate_tlv is optional
Date: Tue, 11 Jan 2005 22:46:32 +0100
Message-ID: <41E44938.3070402@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050003070005030004030600"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050003070005030004030600
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

rate_tlv is optional, fixes using actions/policer without a rate estimator.



--------------050003070005030004030600
Content-Type: text/x-patch;
 name="05.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="05.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/11 22:12:44+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: tcf_exts: rate_tlv is optional
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_api.c
#   2005/01/11 22:12:34+01:00 kaber@coreworks.de +3 -3
#   [PKT_SCHED]: tcf_exts: rate_tlv is optional
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/cls_api.c b/net/sched/cls_api.c
--- a/net/sched/cls_api.c	2005-01-11 22:32:25 +01:00
+++ b/net/sched/cls_api.c	2005-01-11 22:32:25 +01:00
@@ -479,7 +479,7 @@
 	int err;
 	struct tc_action *act;
 
-	if (map->police && tb[map->police-1] && rate_tlv) {
+	if (map->police && tb[map->police-1]) {
 		act = tcf_action_init_1(tb[map->police-1], rate_tlv, "police",
 			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
 		if (act == NULL)
@@ -487,7 +487,7 @@
 
 		act->type = TCA_OLD_COMPAT;
 		exts->action = act;
-	} else if (map->action && tb[map->action-1] && rate_tlv) {
+	} else if (map->action && tb[map->action-1]) {
 		act = tcf_action_init(tb[map->action-1], rate_tlv, NULL,
 			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
 		if (act == NULL)
@@ -496,7 +496,7 @@
 		exts->action = act;
 	}
 #elif defined CONFIG_NET_CLS_POLICE
-	if (map->police && tb[map->police-1] && rate_tlv) {
+	if (map->police && tb[map->police-1]) {
 		struct tcf_police *p;
 		
 		p = tcf_police_locate(tb[map->police-1], rate_tlv);

--------------050003070005030004030600--
