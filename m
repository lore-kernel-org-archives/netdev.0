From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 3/6]: tc actions: disable bhs while lock is held
 in init path
Date: Tue, 11 Jan 2005 22:46:24 +0100
Message-ID: <41E44930.5040106@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080901000200000400060803"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080901000200000400060803
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The lock is also used in softirq context.



--------------080901000200000400060803
Content-Type: text/x-patch;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/11 20:32:35+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: tc actions: disable bhs while lock is held in init path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/police.c
#   2005/01/11 20:32:28+01:00 kaber@coreworks.de +2 -2
#   [PKT_SCHED]: tc actions: disable bhs while lock is held in init path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/mirred.c
#   2005/01/11 20:32:28+01:00 kaber@coreworks.de +2 -2
#   [PKT_SCHED]: tc actions: disable bhs while lock is held in init path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/mirred.c b/net/sched/mirred.c
--- a/net/sched/mirred.c	2005-01-11 22:32:15 +01:00
+++ b/net/sched/mirred.c	2005-01-11 22:32:15 +01:00
@@ -126,7 +126,7 @@
 		}
 	}
 
-	spin_lock(&p->lock);
+	spin_lock_bh(&p->lock);
 	p->action = parm->action;
 	p->eaction = parm->eaction;
 	if (parm->ifindex) {
@@ -137,7 +137,7 @@
 		dev_hold(dev);
 		p->ok_push = ok_push;
 	}
-	spin_unlock(&p->lock);
+	spin_unlock_bh(&p->lock);
 	if (ret == ACT_P_CREATED)
 		tcf_hash_insert(p);
 
diff -Nru a/net/sched/police.c b/net/sched/police.c
--- a/net/sched/police.c	2005-01-11 22:32:15 +01:00
+++ b/net/sched/police.c	2005-01-11 22:32:15 +01:00
@@ -224,7 +224,7 @@
 		}
 	}
 	/* No failure allowed after this point */
-	spin_lock(&p->lock);
+	spin_lock_bh(&p->lock);
 	if (R_tab != NULL) {
 		qdisc_put_rtab(p->R_tab);
 		p->R_tab = R_tab;
@@ -254,7 +254,7 @@
 		gen_replace_estimator(&p->bstats, &p->rate_est, p->stats_lock, est);
 #endif
 
-	spin_unlock(&p->lock);
+	spin_unlock_bh(&p->lock);
 	if (ret != ACT_P_CREATED)
 		return ret;
 

--------------080901000200000400060803--
