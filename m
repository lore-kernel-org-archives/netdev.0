From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 4/9] wext: remove options
Date: Tue, 24 Apr 2007 20:07:36 +0200
Message-ID: <20070424180848.394200000@sipsolutions.net>
References: <20070424180732.371620000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=wext-remove-options.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch kills the two options in wext that are required to be enabled
anyway because they influence the userspace API.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

---
 net/wireless/wext.c |   15 ---------------
 1 file changed, 15 deletions(-)

--- net-2.6.22.orig/net/wireless/wext.c	2007-04-24 18:59:13.258804911 +0200
+++ net-2.6.22/net/wireless/wext.c	2007-04-24 18:59:34.138804911 +0200
@@ -101,12 +101,6 @@
 
 #include <asm/uaccess.h>		/* copy_to_user() */
 
-/**************************** CONSTANTS ****************************/
-
-/* Options */
-#define WE_EVENT_RTNETLINK	/* Propagate events using RtNetlink */
-#define WE_SET_EVENT		/* Generate an event on some set commands */
-
 /************************* GLOBAL VARIABLES *************************/
 /*
  * You should not use global variables, because of re-entrancy.
@@ -741,12 +735,10 @@ static int ioctl_standard_call(struct ne
 		/* No extra arguments. Trivial to handle */
 		ret = handler(dev, &info, &(iwr->u), NULL);
 
-#ifdef WE_SET_EVENT
 		/* Generate an event to notify listeners of the change */
 		if ((descr->flags & IW_DESCR_FLAG_EVENT) &&
 		   ((ret == 0) || (ret == -EIWCOMMIT)))
 			wireless_send_event(dev, cmd, &(iwr->u), NULL);
-#endif	/* WE_SET_EVENT */
 	} else {
 		char *	extra;
 		int	extra_size;
@@ -859,7 +851,6 @@ static int ioctl_standard_call(struct ne
 				ret =  -EFAULT;
 		}
 
-#ifdef WE_SET_EVENT
 		/* Generate an event to notify listeners of the change */
 		if ((descr->flags & IW_DESCR_FLAG_EVENT) &&
 		   ((ret == 0) || (ret == -EIWCOMMIT))) {
@@ -871,7 +862,6 @@ static int ioctl_standard_call(struct ne
 				wireless_send_event(dev, cmd, &(iwr->u),
 						    extra);
 		}
-#endif	/* WE_SET_EVENT */
 
 		/* Cleanup - I told you it wasn't that long ;-) */
 		kfree(extra);
@@ -1121,7 +1111,6 @@ int wext_handle_ioctl(struct ifreq *ifr,
  * Most often, the event will be propagated through rtnetlink
  */
 
-#ifdef WE_EVENT_RTNETLINK
 /* ---------------------------------------------------------------- */
 /*
  * Locking...
@@ -1225,8 +1214,6 @@ static inline void rtmsg_iwinfo(struct n
 	tasklet_schedule(&wireless_nlevent_tasklet);
 }
 
-#endif	/* WE_EVENT_RTNETLINK */
-
 /* ---------------------------------------------------------------- */
 /*
  * Main event dispatcher. Called from other parts and drivers.
@@ -1305,10 +1292,8 @@ void wireless_send_event(struct net_devi
 	if (extra != NULL)
 		memcpy(((char *) event) + hdr_len, extra, extra_len);
 
-#ifdef WE_EVENT_RTNETLINK
 	/* Send via the RtNetlink event channel */
 	rtmsg_iwinfo(dev, (char *) event, event_len);
-#endif	/* WE_EVENT_RTNETLINK */
 
 	/* Cleanup */
 	kfree(event);

--
