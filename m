From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 2/7]: Remove useless variable in tc_ctl_tfilter
Date: Sun, 03 Oct 2004 23:12:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41606B55.8010105@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030605040500090404080507"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030605040500090404080507
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Remove useless variable that confused me.



--------------030605040500090404080507
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/03 20:29:51+02:00 kaber@coreworks.de 
#   [NET_SCHED]: Remove useless variable in tc_ctl_tfilter
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_api.c
#   2004/10/03 20:29:23+02:00 kaber@coreworks.de +4 -4
#   [NET_SCHED]: Remove useless variable in tc_ctl_tfilter
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/cls_api.c b/net/sched/cls_api.c
--- a/net/sched/cls_api.c	2004-10-03 22:18:34 +02:00
+++ b/net/sched/cls_api.c	2004-10-03 22:18:34 +02:00
@@ -139,7 +139,7 @@
 	struct tcf_proto_ops *tp_ops;
 	struct Qdisc_class_ops *cops;
 	unsigned long cl = 0;
-	unsigned long fh, fh_s;
+	unsigned long fh;
 	int err;
 
 	if (prio == 0) {
@@ -249,7 +249,7 @@
 	} else if (tca[TCA_KIND-1] && rtattr_strcmp(tca[TCA_KIND-1], tp->ops->kind))
 		goto errout;
 
-	fh_s = fh = tp->ops->get(tp, t->tcm_handle);
+	fh = tp->ops->get(tp, t->tcm_handle);
 
 	if (fh == 0) {
 		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
@@ -257,7 +257,7 @@
 			*back = tp->next;
 			qdisc_unlock_tree(dev);
 
-			tfilter_notify(skb, n, tp, fh_s, RTM_DELTFILTER);
+			tfilter_notify(skb, n, tp, fh, RTM_DELTFILTER);
 			tcf_destroy(tp);
 			err = 0;
 			goto errout;
@@ -276,7 +276,7 @@
 		case RTM_DELTFILTER:
 			err = tp->ops->delete(tp, fh);
 			if (err == 0)
-				tfilter_notify(skb, n, tp, fh_s, RTM_DELTFILTER);
+				tfilter_notify(skb, n, tp, fh, RTM_DELTFILTER);
 			goto errout;
 		case RTM_GETTFILTER:
 			err = tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);

--------------030605040500090404080507--
