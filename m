From: John Levon <levon@movementarian.org>
Subject: [PATCH] ATM - kill __free_atm_dev()
Date: Fri, 5 Sep 2003 18:12:23 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905171223.GA37920@compsoc.man.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-atm-general@lists.sourceforge.net, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Apply the "Levonov abstraction penalty" - the wrapping of kfree()
is pure obfuscation.

regards
john


diff -Naurp -X dontdiff linux-cvs/net/atm/resources.c linux-fixes/net/atm/resources.c
--- linux-cvs/net/atm/resources.c	2003-06-23 23:08:56.000000000 +0100
+++ linux-fixes/net/atm/resources.c	2003-09-05 18:35:02.000000000 +0100
@@ -42,11 +42,6 @@ static struct atm_dev *__alloc_atm_dev(c
 	return dev;
 }
 
-static void __free_atm_dev(struct atm_dev *dev)
-{
-	kfree(dev);
-}
-
 static struct atm_dev *__atm_dev_lookup(int number)
 {
 	struct atm_dev *dev;
@@ -88,7 +83,7 @@ struct atm_dev *atm_dev_register(const c
 		if ((inuse = __atm_dev_lookup(number))) {
 			atm_dev_put(inuse);
 			spin_unlock(&atm_dev_lock);
-			__free_atm_dev(dev);
+			kfree(dev);
 			return NULL;
 		}
 		dev->number = number;
@@ -119,7 +114,7 @@ struct atm_dev *atm_dev_register(const c
 			spin_lock(&atm_dev_lock);
 			list_del(&dev->dev_list);
 			spin_unlock(&atm_dev_lock);
-			__free_atm_dev(dev);
+			kfree(dev);
 			return NULL;
 		}
 	}
@@ -154,7 +149,7 @@ void atm_dev_deregister(struct atm_dev *
                 }
         }
 
-	__free_atm_dev(dev);
+	kfree(dev);
 }
 
 void shutdown_atm_dev(struct atm_dev *dev)
