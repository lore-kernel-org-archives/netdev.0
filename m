From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v8] net: isdn - set name assign type
Date: Thu, 17 Jul 2014 00:43:09 +0200
Message-ID: <1405550594-11786-2-git-send-email-teg@jklm.no>
References: <1405550594-11786-1-git-send-email-teg@jklm.no>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>, Karsten Keil <isdn@linux-pingi.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405550594-11786-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Karsten Keil <isdn@linux-pingi.de>
---

This patch goes on top of net-next.

 drivers/isdn/i4l/isdn_common.c |  4 ++--
 drivers/isdn/i4l/isdn_net.c    | 10 +++++-----
 drivers/isdn/i4l/isdn_net.h    |  4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_common.c b/drivers/isdn/i4l/isdn_common.c
index 9b856e1..67840ca 100644
--- a/drivers/isdn/i4l/isdn_common.c
+++ b/drivers/isdn/i4l/isdn_common.c
@@ -1364,7 +1364,7 @@ isdn_ioctl(struct file *file, uint cmd, ulong arg)
 			}
 			ret = mutex_lock_interruptible(&dev->mtx);
 			if (ret) return ret;
-			if ((s = isdn_net_new(s, NULL))) {
+			if ((s = isdn_net_new(s, NET_NAME_USER, NULL))) {
 				if (copy_to_user(argp, s, strlen(s) + 1)) {
 					ret = -EFAULT;
 				} else {
@@ -1383,7 +1383,7 @@ isdn_ioctl(struct file *file, uint cmd, ulong arg)
 				return -EINVAL;
 			ret = mutex_lock_interruptible(&dev->mtx);
 			if (ret) return ret;
-			if ((s = isdn_net_newslave(bname))) {
+			if ((s = isdn_net_newslave(bname, NET_NAME_USER))) {
 				if (copy_to_user(argp, s, strlen(s) + 1)) {
 					ret = -EFAULT;
 				} else {
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index c2ed624..d16fec0 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -2573,7 +2573,7 @@ static void _isdn_setup(struct net_device *dev)
  * Allocate a new network-interface and initialize its data structures.
  */
 char *
-isdn_net_new(char *name, struct net_device *master)
+isdn_net_new(char *name, unsigned char name_assign_type, struct net_device *master)
 {
 	isdn_net_dev *netdev;
 
@@ -2588,8 +2588,8 @@ isdn_net_new(char *name, struct net_device *master)
 		printk(KERN_WARNING "isdn_net: Could not allocate net-device\n");
 		return NULL;
 	}
-	netdev->dev = alloc_netdev(sizeof(isdn_net_local), name,
-				   NET_NAME_UNKNOWN, _isdn_setup);
+	netdev->dev = alloc_netdev(sizeof(isdn_net_local), name, name_assign_type,
+				   _isdn_setup);
 	if (!netdev->dev) {
 		printk(KERN_WARNING "isdn_net: Could not allocate network device\n");
 		kfree(netdev);
@@ -2637,7 +2637,7 @@ isdn_net_new(char *name, struct net_device *master)
 }
 
 char *
-isdn_net_newslave(char *parm)
+isdn_net_newslave(char *parm, unsigned char name_assign_type)
 {
 	char *p = strchr(parm, ',');
 	isdn_net_dev *n;
@@ -2658,7 +2658,7 @@ isdn_net_newslave(char *parm)
 		/* Master must not be started yet */
 		if (isdn_net_device_started(n))
 			return NULL;
-		return (isdn_net_new(newname, n->dev));
+		return (isdn_net_new(newname, name_assign_type, n->dev));
 	}
 	return NULL;
 }
diff --git a/drivers/isdn/i4l/isdn_net.h b/drivers/isdn/i4l/isdn_net.h
index cca6d68..99f0c47 100644
--- a/drivers/isdn/i4l/isdn_net.h
+++ b/drivers/isdn/i4l/isdn_net.h
@@ -31,8 +31,8 @@
 #define CISCO_SLARP_REPLY     1
 #define CISCO_SLARP_KEEPALIVE 2
 
-extern char *isdn_net_new(char *, struct net_device *);
-extern char *isdn_net_newslave(char *);
+extern char *isdn_net_new(char *, unsigned char, struct net_device *);
+extern char *isdn_net_newslave(char *, unsigned char);
 extern int isdn_net_rm(char *);
 extern int isdn_net_rmall(void);
 extern int isdn_net_stat_callback(int, isdn_ctrl *);
-- 
1.9.3
