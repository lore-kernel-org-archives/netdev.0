From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/3][ATM]: net/atm/resources.c: remove __free_atm_dev
Date: Sun, 10 Apr 2005 11:26:48 -0400
Message-ID: <200504101526.j3AFQlPS007582@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/04/10 10:36:30-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: net/atm/resources.c: remove __free_atm_dev
#   
#   Signed-off-by: Adrian Bunk <bunk@stusta.de>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/resources.c
#   2005/04/10 10:36:11-04:00 chas@relax.cmf.nrl.navy.mil +3 -8
#   [ATM]: net/atm/resources.c: remove __free_atm_dev
#   
#   Signed-off-by: Adrian Bunk <bunk@stusta.de>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/net/atm/resources.c b/net/atm/resources.c
--- a/net/atm/resources.c	2005-04-10 11:14:12 -04:00
+++ b/net/atm/resources.c	2005-04-10 11:14:12 -04:00
@@ -44,11 +44,6 @@
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
@@ -90,7 +85,7 @@
 		if ((inuse = __atm_dev_lookup(number))) {
 			atm_dev_put(inuse);
 			spin_unlock(&atm_dev_lock);
-			__free_atm_dev(dev);
+			kfree(dev);
 			return NULL;
 		}
 		dev->number = number;
@@ -119,7 +114,7 @@
 		spin_lock(&atm_dev_lock);
 		list_del(&dev->dev_list);
 		spin_unlock(&atm_dev_lock);
-		__free_atm_dev(dev);
+		kfree(dev);
 		return NULL;
 	}
 
@@ -148,7 +143,7 @@
                 }
         }
 
-	__free_atm_dev(dev);
+	kfree(dev);
 }
 
 void shutdown_atm_dev(struct atm_dev *dev)
