From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 4/5]: remove unneccessary checks for qdisc->dev
Date: Tue, 03 Aug 2004 17:25:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410FAE65.6010802@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070305030108050302020103"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070305030108050302020103
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

qdisc->dev is always valid, this patch removes a couple of unneccessary 
checks.


--------------070305030108050302020103
Content-Type: text/x-patch;
 name="04-qdisc-dev-checks.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04-qdisc-dev-checks.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/03 01:28:36+02:00 kaber@coreworks.de 
#   [PKT_SCHED]: remove unneccessary checks for qdisc->dev
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_generic.c
#   2004/08/03 01:28:15+02:00 kaber@coreworks.de +1 -2
#   [PKT_SCHED]: remove unneccessary checks for qdisc->dev
# 
# net/sched/sch_api.c
#   2004/08/03 01:28:15+02:00 kaber@coreworks.de +2 -2
#   [PKT_SCHED]: remove unneccessary checks for qdisc->dev
# 
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-08-03 01:30:00 +02:00
+++ b/net/sched/sch_api.c	2004-08-03 01:30:00 +02:00
@@ -753,7 +753,7 @@
 	nlh->nlmsg_flags = flags;
 	tcm = NLMSG_DATA(nlh);
 	tcm->tcm_family = AF_UNSPEC;
-	tcm->tcm_ifindex = q->dev ? q->dev->ifindex : 0;
+	tcm->tcm_ifindex = q->dev->ifindex;
 	tcm->tcm_parent = clid;
 	tcm->tcm_handle = q->handle;
 	tcm->tcm_info = atomic_read(&q->refcnt);
@@ -970,7 +970,7 @@
 	nlh->nlmsg_flags = flags;
 	tcm = NLMSG_DATA(nlh);
 	tcm->tcm_family = AF_UNSPEC;
-	tcm->tcm_ifindex = q->dev ? q->dev->ifindex : 0;
+	tcm->tcm_ifindex = q->dev->ifindex;
 	tcm->tcm_parent = q->handle;
 	tcm->tcm_handle = q->handle;
 	tcm->tcm_info = 0;
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-08-03 01:30:00 +02:00
+++ b/net/sched/sch_generic.c	2004-08-03 01:30:00 +02:00
@@ -443,8 +443,7 @@
 	write_unlock(&qdisc_tree_lock);
 	module_put(ops->owner);
 
-	if (qdisc->dev)
-		dev_put(qdisc->dev);
+	dev_put(qdisc->dev);
 	if (!(qdisc->flags&TCQ_F_BUILTIN))
 		kfree(qdisc);
 }

--------------070305030108050302020103--
