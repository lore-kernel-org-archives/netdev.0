From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: Disable local bh's when grabing qdisc_tree_lock in tc_dump_tfilter
Date: Sun, 08 Aug 2004 16:53:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41163E5E.8060004@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050805040004020103010103"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050805040004020103010103
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I missed this one when fixing locking in __qdisc_destroy.


--------------050805040004020103010103
Content-Type: text/x-patch;
 name="tc_dump_tfilter-bh.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tc_dump_tfilter-bh.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/08 14:15:49+02:00 kaber@kaber.coreworks.de 
#   [PKT_SCHED]: Disable local bh's when grabing qdisc_tree_lock in tc_dump_tfilter
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_api.c
#   2004/08/08 14:15:30+02:00 kaber@kaber.coreworks.de +2 -2
#   [PKT_SCHED]: Disable local bh's when grabing qdisc_tree_lock in tc_dump_tfilter
# 
diff -Nru a/net/sched/cls_api.c b/net/sched/cls_api.c
--- a/net/sched/cls_api.c	2004-08-08 14:17:46 +02:00
+++ b/net/sched/cls_api.c	2004-08-08 14:17:46 +02:00
@@ -387,7 +387,7 @@
 	if ((dev = dev_get_by_index(tcm->tcm_ifindex)) == NULL)
 		return skb->len;
 
-	read_lock(&qdisc_tree_lock);
+	read_lock_bh(&qdisc_tree_lock);
 	if (!tcm->tcm_parent)
 		q = dev->qdisc_sleeping;
 	else
@@ -444,7 +444,7 @@
 	if (cl)
 		cops->put(q, cl);
 out:
-	read_unlock(&qdisc_tree_lock);
+	read_unlock_bh(&qdisc_tree_lock);
 	dev_put(dev);
 	return skb->len;
 }

--------------050805040004020103010103--
