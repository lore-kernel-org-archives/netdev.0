From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/9) freenetdev -  pcmcia drivers
Date: Tue, 19 Aug 2003 12:18:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819121823.2667a2aa.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace kfree with free_netdev 

diff -Nru a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
--- a/drivers/net/pcmcia/3c574_cs.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/net/pcmcia/3c574_cs.c	Tue Aug 19 09:04:31 2003
@@ -384,9 +384,11 @@
 
 	/* Unlink device structure, free bits */
 	*linkp = link->next;
-	if (link->dev)
+	if (link->dev) {
 		unregister_netdev(dev);
-	kfree(dev);
+		free_netdev(dev);
+	} else 
+		kfree(dev);
 
 } /* tc574_detach */
 
diff -Nru a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
--- a/drivers/net/pcmcia/3c589_cs.c	Tue Aug 19 09:04:32 2003
+++ b/drivers/net/pcmcia/3c589_cs.c	Tue Aug 19 09:04:32 2003
@@ -308,9 +308,11 @@
     
     /* Unlink device structure, free bits */
     *linkp = link->next;
-    if (link->dev)
+    if (link->dev) {
 	unregister_netdev(dev);
-    kfree(dev);
+	free_netdev(dev);
+    } else
+        kfree(dev);
     
 } /* tc589_detach */
 
diff -Nru a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
--- a/drivers/net/pcmcia/axnet_cs.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/net/pcmcia/axnet_cs.c	Tue Aug 19 09:04:31 2003
@@ -267,9 +267,11 @@
 
     /* Unlink device structure, free bits */
     *linkp = link->next;
-    if (link->dev)
+    if (link->dev) {
 	unregister_netdev(&info->dev);
-    kfree(info);
+	free_netdev(&info->dev);
+    } else
+	kfree(info);
 
 } /* axnet_detach */
 
diff -Nru a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
--- a/drivers/net/pcmcia/com20020_cs.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/net/pcmcia/com20020_cs.c	Tue Aug 19 09:04:31 2003
@@ -329,7 +329,7 @@
 	    
 	    DEBUG(1,"kfree...\n");
 	    kfree(dev->priv);
-	    kfree(dev);
+	    free_netdev(dev);
 	}
 	DEBUG(1,"kfree2...\n");
 	kfree(info);
diff -Nru a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
--- a/drivers/net/pcmcia/fmvj18x_cs.c	Tue Aug 19 09:04:32 2003
+++ b/drivers/net/pcmcia/fmvj18x_cs.c	Tue Aug 19 09:04:32 2003
@@ -365,9 +365,11 @@
     
     /* Unlink device structure, free pieces */
     *linkp = link->next;
-    if (link->dev)
+    if (link->dev) {
 	unregister_netdev(dev);
-    kfree(dev);
+	free_netdev(dev);
+    } else
+    	kfree(dev);
     
 } /* fmvj18x_detach */
 
diff -Nru a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
--- a/drivers/net/pcmcia/ibmtr_cs.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/net/pcmcia/ibmtr_cs.c	Tue Aug 19 09:04:31 2003
@@ -306,7 +306,7 @@
     /* Unlink device structure, free bits */
     *linkp = link->next;
     unregister_netdev(dev);
-    kfree(dev);
+    free_netdev(dev);
 } /* ibmtr_detach */
 
 /*======================================================================
diff -Nru a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
--- a/drivers/net/pcmcia/nmclan_cs.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/net/pcmcia/nmclan_cs.c	Tue Aug 19 09:04:31 2003
@@ -579,9 +579,11 @@
 
     /* Unlink device structure, free bits */
     *linkp = link->next;
-    if (link->dev)
+    if (link->dev) {
 	unregister_netdev(dev);
-    kfree(dev);
+	free_netdev(dev);
+    } else
+	kfree(dev);
 
 } /* nmclan_detach */
 
diff -Nru a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
--- a/drivers/net/pcmcia/pcnet_cs.c	Tue Aug 19 09:04:32 2003
+++ b/drivers/net/pcmcia/pcnet_cs.c	Tue Aug 19 09:04:32 2003
@@ -367,9 +367,11 @@
 
     /* Unlink device structure, free bits */
     *linkp = link->next;
-    if (link->dev)
+    if (link->dev) {
 	unregister_netdev(&info->dev);
-    kfree(info);
+	free_netdev(&info->dev);
+    } else
+	 kfree(info);
 
 } /* pcnet_detach */
 
diff -Nru a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
--- a/drivers/net/pcmcia/smc91c92_cs.c	Tue Aug 19 09:04:32 2003
+++ b/drivers/net/pcmcia/smc91c92_cs.c	Tue Aug 19 09:04:32 2003
@@ -443,9 +443,11 @@
 
     /* Unlink device structure, free bits */
     *linkp = link->next;
-    if (link->dev)
+    if (link->dev) {
 	unregister_netdev(dev);
-    kfree(dev);
+	free_netdev(dev);
+    } else
+	kfree(dev);
 
 } /* smc91c92_detach */
 
diff -Nru a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
--- a/drivers/net/pcmcia/xirc2ps_cs.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/net/pcmcia/xirc2ps_cs.c	Tue Aug 19 09:04:31 2003
@@ -699,9 +699,11 @@
 
     /* Unlink device structure, free it */
     *linkp = link->next;
-    if (link->dev)
+    if (link->dev) {
 	unregister_netdev(dev);
-    kfree(dev);
+	free_netdev(dev);
+    } else
+	kfree(dev);
 
 } /* xirc2ps_detach */
 
