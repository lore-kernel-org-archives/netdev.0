From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/atm/resources.c: remove __free_atm_dev
Date: Fri, 25 Mar 2005 01:19:35 +0100
Message-ID: <20050325001935.GI3966@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: chas@cmf.nrl.navy.mil
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There's no need for a function that only calls kfree.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/atm/resources.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

--- linux-2.6.12-rc1-mm1-full/net/atm/resources.c.old	2005-03-23 18:21:31.000000000 +0100
+++ linux-2.6.12-rc1-mm1-full/net/atm/resources.c	2005-03-23 18:22:05.000000000 +0100
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
