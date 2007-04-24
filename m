From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 8/9] wext: misc code cleanups
Date: Tue, 24 Apr 2007 20:07:40 +0200
Message-ID: <20070424180850.362164000@sipsolutions.net>
References: <20070424180732.371620000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=wext-misc.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Just a few things that didn't fit in with the other patches.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

---
 net/wireless/wext.c |   28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

--- net-2.6.22.orig/net/wireless/wext.c	2007-04-24 19:18:49.198804911 +0200
+++ net-2.6.22/net/wireless/wext.c	2007-04-24 19:25:46.768804911 +0200
@@ -476,7 +476,7 @@ static struct iw_statistics *get_wireles
 		return dev->wireless_handlers->get_wireless_stats(dev);
 
 	/* Not found */
-	return (struct iw_statistics *) NULL;
+	return NULL;
 }
 
 /* ---------------------------------------------------------------- */
@@ -501,11 +501,11 @@ static struct iw_statistics *get_wireles
 static int call_commit_handler(struct net_device *dev)
 {
 	if ((netif_running(dev)) &&
-	   (dev->wireless_handlers->standard[0] != NULL)) {
+	   (dev->wireless_handlers->standard[0] != NULL))
 		/* Call the commit handler on the driver */
 		return dev->wireless_handlers->standard[0](dev, NULL,
 							   NULL, NULL);
-	} else
+	else
 		return 0;		/* Command completed successfully */
 }
 
@@ -554,8 +554,7 @@ static int iw_handler_get_iwstats(struct
 	struct iw_statistics *stats;
 
 	stats = get_wireless_stats(dev);
-	if (stats != (struct iw_statistics *) NULL) {
-
+	if (stats) {
 		/* Copy statistics to extra */
 		memcpy(extra, stats, sizeof(struct iw_statistics));
 		wrqu->data.length = sizeof(struct iw_statistics);
@@ -814,9 +813,8 @@ static int ioctl_standard_call(struct ne
 		/* Create the kernel buffer */
 		/*    kzalloc ensures NULL-termination for essid_compat */
 		extra = kzalloc(extra_size, GFP_KERNEL);
-		if (extra == NULL) {
+		if (extra == NULL)
 			return -ENOMEM;
-		}
 
 		/* If it is a SET, get all the extra data in here */
 		if (IW_IS_SET(cmd) && (iwr->u.data.length != 0)) {
@@ -957,18 +955,14 @@ static int ioctl_private_call(struct net
 			if (iwr->u.data.length > (descr->set_args &
 						 IW_PRIV_SIZE_MASK))
 				return -E2BIG;
-		} else {
-			/* Check NULL pointer */
-			if (iwr->u.data.pointer == NULL)
-				return -EFAULT;
-		}
+		} else if (iwr->u.data.pointer == NULL)
+			return -EFAULT;
 
 		/* Always allocate for max space. Easier, and won't last
 		 * long... */
 		extra = kmalloc(extra_size, GFP_KERNEL);
-		if (extra == NULL) {
+		if (extra == NULL)
 			return -ENOMEM;
-		}
 
 		/* If it is a SET, get all the extra data in here */
 		if (IW_IS_SET(cmd) && (iwr->u.data.length != 0)) {
@@ -1259,7 +1253,7 @@ void wireless_send_event(struct net_devi
 	event->len = event_len;
 	event->cmd = cmd;
 	memcpy(&event->u, ((char *) wrqu) + wrqu_off, hdr_len - IW_EV_LCP_LEN);
-	if (extra != NULL)
+	if (extra)
 		memcpy(((char *) event) + hdr_len, extra, extra_len);
 
 	/* Send via the RtNetlink event channel */
@@ -1290,11 +1284,11 @@ EXPORT_SYMBOL(wireless_send_event);
  * Because this is called on the Rx path via wireless_spy_update(),
  * we want it to be efficient...
  */
-static inline struct iw_spy_data * get_spydata(struct net_device *dev)
+static inline struct iw_spy_data *get_spydata(struct net_device *dev)
 {
 	/* This is the new way */
 	if (dev->wireless_data)
-		return(dev->wireless_data->spy_data);
+		return dev->wireless_data->spy_data;
 	return NULL;
 }
 

--
