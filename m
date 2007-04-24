From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 3/9] wext: remove dead debug code
Date: Tue, 24 Apr 2007 20:07:35 +0200
Message-ID: <20070424180847.982382000@sipsolutions.net>
References: <20070424180732.371620000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	jt@hpl.hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:33749 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993151AbXDZJky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 05:40:54 -0400
Content-Disposition: inline; filename=remove-wext-debug.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch kills a whole bunch of code that can only ever be used by
defining some things in wext.c. Also, the things that are printed are
mostly useless since the API is fairly well-tested.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 net/wireless/wext.c |   92 ----------------------------------------------------
 1 file changed, 92 deletions(-)

--- net-2.6.22.orig/net/wireless/wext.c	2007-04-24 18:58:07.738804911 +0200
+++ net-2.6.22/net/wireless/wext.c	2007-04-24 18:59:00.998804911 +0200
@@ -103,11 +103,6 @@
 
 /**************************** CONSTANTS ****************************/
 
-/* Debugging stuff */
-#undef WE_IOCTL_DEBUG		/* Debug IOCTL API */
-#undef WE_EVENT_DEBUG		/* Debug Event dispatcher */
-#undef WE_SPY_DEBUG		/* Debug enhanced spy support */
-
 /* Options */
 #define WE_EVENT_RTNETLINK	/* Propagate events using RtNetlink */
 #define WE_SET_EVENT		/* Generate an event on some set commands */
@@ -736,12 +731,6 @@ static int ioctl_standard_call(struct ne
 		return -EOPNOTSUPP;
 	descr = &(standard_ioctl[cmd - SIOCIWFIRST]);
 
-#ifdef WE_IOCTL_DEBUG
-	printk(KERN_DEBUG "%s (WE) : Found standard handler for 0x%04X\n",
-	       ifr->ifr_name, cmd);
-	printk(KERN_DEBUG "%s (WE) : Header type : %d, Token type : %d, size : %d, token : %d\n", dev->name, descr->header_type, descr->token_type, descr->token_size, descr->max_tokens);
-#endif	/* WE_IOCTL_DEBUG */
-
 	/* Prepare the call */
 	info.cmd = cmd;
 	info.flags = 0;
@@ -832,11 +821,6 @@ static int ioctl_standard_call(struct ne
 			}
 		}
 
-#ifdef WE_IOCTL_DEBUG
-		printk(KERN_DEBUG "%s (WE) : Malloc %d bytes\n",
-		       dev->name, extra_size);
-#endif	/* WE_IOCTL_DEBUG */
-
 		/* Create the kernel buffer */
 		/*    kzalloc ensures NULL-termination for essid_compat */
 		extra = kzalloc(extra_size, GFP_KERNEL);
@@ -853,11 +837,6 @@ static int ioctl_standard_call(struct ne
 				kfree(extra);
 				return -EFAULT;
 			}
-#ifdef WE_IOCTL_DEBUG
-			printk(KERN_DEBUG "%s (WE) : Got %d bytes\n",
-			       dev->name,
-			       iwr->u.data.length * descr->token_size);
-#endif	/* WE_IOCTL_DEBUG */
 		}
 
 		/* Call the handler */
@@ -878,11 +857,6 @@ static int ioctl_standard_call(struct ne
 					   descr->token_size);
 			if (err)
 				ret =  -EFAULT;
-#ifdef WE_IOCTL_DEBUG
-			printk(KERN_DEBUG "%s (WE) : Wrote %d bytes\n",
-			       dev->name,
-			       iwr->u.data.length * descr->token_size);
-#endif	/* WE_IOCTL_DEBUG */
 		}
 
 #ifdef WE_SET_EVENT
@@ -947,16 +921,6 @@ static inline int ioctl_private_call(str
 			break;
 		}
 
-#ifdef WE_IOCTL_DEBUG
-	printk(KERN_DEBUG "%s (WE) : Found private handler for 0x%04X\n",
-	       ifr->ifr_name, cmd);
-	if (descr) {
-		printk(KERN_DEBUG "%s (WE) : Name %s, set %X, get %X\n",
-		       dev->name, descr->name,
-		       descr->set_args, descr->get_args);
-	}
-#endif	/* WE_IOCTL_DEBUG */
-
 	/* Compute the size of the set/get arguments */
 	if (descr != NULL) {
 		if (IW_IS_SET(cmd)) {
@@ -1013,11 +977,6 @@ static inline int ioctl_private_call(str
 				return -EFAULT;
 		}
 
-#ifdef WE_IOCTL_DEBUG
-		printk(KERN_DEBUG "%s (WE) : Malloc %d bytes\n",
-		       dev->name, extra_size);
-#endif	/* WE_IOCTL_DEBUG */
-
 		/* Always allocate for max space. Easier, and won't last
 		 * long... */
 		extra = kmalloc(extra_size, GFP_KERNEL);
@@ -1033,10 +992,6 @@ static inline int ioctl_private_call(str
 				kfree(extra);
 				return -EFAULT;
 			}
-#ifdef WE_IOCTL_DEBUG
-			printk(KERN_DEBUG "%s (WE) : Got %d elem\n",
-			       dev->name, iwr->u.data.length);
-#endif	/* WE_IOCTL_DEBUG */
 		}
 
 		/* Call the handler */
@@ -1056,10 +1011,6 @@ static inline int ioctl_private_call(str
 					   extra_size);
 			if (err)
 				ret =  -EFAULT;
-#ifdef WE_IOCTL_DEBUG
-			printk(KERN_DEBUG "%s (WE) : Wrote %d elem\n",
-			       dev->name, iwr->u.data.length);
-#endif	/* WE_IOCTL_DEBUG */
 		}
 
 		/* Cleanup - I told you it wasn't that long ;-) */
@@ -1319,11 +1270,6 @@ void wireless_send_event(struct net_devi
 		       dev->name, cmd);
 		return;
 	}
-#ifdef WE_EVENT_DEBUG
-	printk(KERN_DEBUG "%s (WE) : Got event 0x%04X\n",
-	       dev->name, cmd);
-	printk(KERN_DEBUG "%s (WE) : Header type : %d, Token type : %d, size : %d, token : %d\n", dev->name, descr->header_type, descr->token_type, descr->token_size, descr->max_tokens);
-#endif	/* WE_EVENT_DEBUG */
 
 	/* Check extra parameters and set extra_len */
 	if (descr->header_type == IW_HEADER_TYPE_POINT) {
@@ -1341,19 +1287,12 @@ void wireless_send_event(struct net_devi
 			extra_len = wrqu->data.length * descr->token_size;
 		/* Always at an offset in wrqu */
 		wrqu_off = IW_EV_POINT_OFF;
-#ifdef WE_EVENT_DEBUG
-		printk(KERN_DEBUG "%s (WE) : Event 0x%04X, tokens %d, extra_len %d\n", dev->name, cmd, wrqu->data.length, extra_len);
-#endif	/* WE_EVENT_DEBUG */
 	}
 
 	/* Total length of the event */
 	hdr_len = event_type_size[descr->header_type];
 	event_len = hdr_len + extra_len;
 
-#ifdef WE_EVENT_DEBUG
-	printk(KERN_DEBUG "%s (WE) : Event 0x%04X, hdr_len %d, wrqu_off %d, event_len %d\n", dev->name, cmd, hdr_len, wrqu_off, event_len);
-#endif	/* WE_EVENT_DEBUG */
-
 	/* Create temporary buffer to hold the event */
 	event = kmalloc(event_len, GFP_ATOMIC);
 	if (event == NULL)
@@ -1443,19 +1382,6 @@ int iw_handler_set_spy(struct net_device
 		/* Reset stats */
 		memset(spydata->spy_stat, 0,
 		       sizeof(struct iw_quality) * IW_MAX_SPY);
-
-#ifdef WE_SPY_DEBUG
-		printk(KERN_DEBUG "iw_handler_set_spy() :  wireless_data %p, spydata %p, num %d\n", dev->wireless_data, spydata, wrqu->data.length);
-		for (i = 0; i < wrqu->data.length; i++)
-			printk(KERN_DEBUG
-			       "%02X:%02X:%02X:%02X:%02X:%02X \n",
-			       spydata->spy_address[i][0],
-			       spydata->spy_address[i][1],
-			       spydata->spy_address[i][2],
-			       spydata->spy_address[i][3],
-			       spydata->spy_address[i][4],
-			       spydata->spy_address[i][5]);
-#endif	/* WE_SPY_DEBUG */
 	}
 
 	/* Make sure above is updated before re-enabling */
@@ -1525,10 +1451,6 @@ int iw_handler_set_thrspy(struct net_dev
 	/* Clear flag */
 	memset(spydata->spy_thr_under, '\0', sizeof(spydata->spy_thr_under));
 
-#ifdef WE_SPY_DEBUG
-	printk(KERN_DEBUG "iw_handler_set_thrspy() :  low %d ; high %d\n", spydata->spy_thr_low.level, spydata->spy_thr_high.level);
-#endif	/* WE_SPY_DEBUG */
-
 	return 0;
 }
 
@@ -1579,16 +1501,6 @@ static void iw_send_thrspy_event(struct 
 	memcpy(&(threshold.low), &(spydata->spy_thr_low),
 	       2 * sizeof(struct iw_quality));
 
-#ifdef WE_SPY_DEBUG
-	printk(KERN_DEBUG "iw_send_thrspy_event() : address %02X:%02X:%02X:%02X:%02X:%02X, level %d, up = %d\n",
-	       threshold.addr.sa_data[0],
-	       threshold.addr.sa_data[1],
-	       threshold.addr.sa_data[2],
-	       threshold.addr.sa_data[3],
-	       threshold.addr.sa_data[4],
-	       threshold.addr.sa_data[5], threshold.qual.level);
-#endif	/* WE_SPY_DEBUG */
-
 	/* Send event to user space */
 	wireless_send_event(dev, SIOCGIWTHRSPY, &wrqu, (char *) &threshold);
 }
@@ -1612,10 +1524,6 @@ void wireless_spy_update(struct net_devi
 	if (!spydata)
 		return;
 
-#ifdef WE_SPY_DEBUG
-	printk(KERN_DEBUG "wireless_spy_update() :  wireless_data %p, spydata %p, address %02X:%02X:%02X:%02X:%02X:%02X\n", dev->wireless_data, spydata, address[0], address[1], address[2], address[3], address[4], address[5]);
-#endif	/* WE_SPY_DEBUG */
-
 	/* Update all records that match */
 	for (i = 0; i < spydata->spy_number; i++)
 		if (!compare_ether_addr(address, spydata->spy_address[i])) {

--

