From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.4]: Don't try to destroy builtin qdiscs
Date: Fri, 05 Nov 2004 20:46:31 +0100
Message-ID: <418BD897.5000409@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030606070008030700090802"
Cc: Thomas Graf <tgraf@suug.ch>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030606070008030700090802
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Backported from Thomas's patch, we also need this for 2.4.





--------------030606070008030700090802
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/05 20:44:30+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Don't try to destroy builtin qdiscs
#   
#   Backported from Thomas Graf's fix for 2.6.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_generic.c
#   2004/11/05 20:44:28+01:00 kaber@coreworks.de +3 -3
#   [PKT_SCHED]: Don't try to destroy builtin qdiscs
#   
#   Backported from Thomas Graf's fix for 2.6.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-11-05 20:44:43 +01:00
+++ b/net/sched/sch_generic.c	2004-11-05 20:44:43 +01:00
@@ -423,7 +423,8 @@
 {
 	struct Qdisc_ops *ops = qdisc->ops;
 
-	if (!atomic_dec_and_test(&qdisc->refcnt))
+	if (qdisc->flags&TCQ_F_BUILTIN ||
+	    !atomic_dec_and_test(&qdisc->refcnt))
 		return;
 	list_del(&qdisc->list);
 #ifdef CONFIG_NET_ESTIMATOR
@@ -433,8 +434,7 @@
 		ops->reset(qdisc);
 	if (ops->destroy)
 		ops->destroy(qdisc);
-	if (!(qdisc->flags&TCQ_F_BUILTIN))
-		kfree(qdisc);
+	kfree(qdisc);
 }
 
 

--------------030606070008030700090802--
