From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/9) freenetdev - net/* drivers
Date: Tue, 19 Aug 2003 12:21:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819122143.3d6d5cf9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace kfree with free_netdev in cleanup routines
of protocols and network pseudo drivers.

diff -Nru a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
--- a/net/wanrouter/wanmain.c	Tue Aug 19 09:04:32 2003
+++ b/net/wanrouter/wanmain.c	Tue Aug 19 09:04:32 2003
@@ -908,7 +908,7 @@
 
 	unregister_netdev(dev);
 
-	kfree(dev);
+	free_netdev(dev);
 
 	return 0;
 }
diff -Nru a/net/sched/sch_teql.c b/net/sched/sch_teql.c
--- a/net/sched/sch_teql.c	Tue Aug 19 09:04:31 2003
+++ b/net/sched/sch_teql.c	Tue Aug 19 09:04:31 2003
@@ -498,7 +498,7 @@
 
 		unregister_qdisc(&master->qops);
 		unregister_netdev(master->dev);
-		kfree(master->dev);
+		free_netdev(master->dev);
 	}
 	spin_unlock(&master_dev_lock);
 }
diff -Nru a/net/rose/af_rose.c b/net/rose/af_rose.c
--- a/net/rose/af_rose.c	Tue Aug 19 09:04:31 2003
+++ b/net/rose/af_rose.c	Tue Aug 19 09:04:31 2003
@@ -1580,7 +1580,7 @@
 
 		if (dev) {
 			unregister_netdev(dev);
-			kfree(dev);
+			free_netdev(dev);
 		}
 	}
 
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	Tue Aug 19 09:04:31 2003
+++ b/net/atm/br2684.c	Tue Aug 19 09:04:31 2003
@@ -793,7 +793,7 @@
 		brdev = list_entry_brdev(br2684_devs.next);
 		unregister_netdev(&brdev->net_dev);
 		list_del(&brdev->br2684_devs);
-		kfree(brdev);
+		free_netdev(brdev);
 	}
 }
 
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Tue Aug 19 09:04:32 2003
+++ b/net/atm/clip.c	Tue Aug 19 09:04:32 2003
@@ -786,7 +786,7 @@
 	while (dev) {
 		next = PRIV(dev)->next;
 		unregister_netdev(dev);
-		kfree(dev);
+		free_netdev(dev);
 		dev = next;
 	}
 	if (start_timer == 0) del_timer(&idle_timer);
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Tue Aug 19 09:04:31 2003
+++ b/net/atm/lec.c	Tue Aug 19 09:04:31 2003
@@ -864,7 +864,7 @@
                 if (dev_lec[i] != NULL) {
                         priv = (struct lec_priv *)dev_lec[i]->priv;
 			unregister_netdev(dev_lec[i]);
-                        kfree(dev_lec[i]);
+                        free_netdev(dev_lec[i]);
                         dev_lec[i] = NULL;
                 }
         }
