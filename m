From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6]: Missing dev_put in qdisc_create error path
Date: Sun, 22 Aug 2004 14:42:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <412894BB.9090906@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060307060803070800080802"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060307060803070800080802
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes missing dev_puts in qdisc_create and
qdisc_create_dflt error paths.

Regards
Patrick


--------------060307060803070800080802
Content-Type: text/x-patch;
 name="02-2.6-dev-leaks.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02-2.6-dev-leaks.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/22 14:33:26+02:00 kaber@coreworks.de 
#   [PKT_SCHED]: Missing dev_put in error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_generic.c
#   2004/08/22 14:33:06+02:00 kaber@coreworks.de +1 -0
#   [PKT_SCHED]: Missing dev_put in error path
# 
# net/sched/sch_api.c
#   2004/08/22 14:33:06+02:00 kaber@coreworks.de +3 -1
#   [PKT_SCHED]: Missing dev_put in error path
# 
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-08-22 14:34:34 +02:00
+++ b/net/sched/sch_api.c	2004-08-22 14:34:34 +02:00
@@ -441,7 +441,7 @@
 		handle = qdisc_alloc_handle(dev);
 		err = -ENOMEM;
 		if (handle == 0)
-			goto err_out2;
+			goto err_out3;
 	}
 
 	if (handle == TC_H_INGRESS)
@@ -464,6 +464,8 @@
 #endif
 		return sch;
 	}
+err_out3:
+	dev_put(dev);
 err_out2:
 	module_put(ops->owner);
 err_out:
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-08-22 14:34:34 +02:00
+++ b/net/sched/sch_generic.c	2004-08-22 14:34:34 +02:00
@@ -415,6 +415,7 @@
 	if (!ops->init || ops->init(sch, NULL) == 0)
 		return sch;
 
+	dev_put(dev);
 	kfree(p);
 	return NULL;
 }

--------------060307060803070800080802--
