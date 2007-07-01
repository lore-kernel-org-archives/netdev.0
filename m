From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 2/4] [IrDA] Monitor mode
Date: Mon, 02 Jul 2007 01:14:29 +0300
Message-ID: <20070701221705.413124168@sortiz.org>
References: <20070701221427.101308704@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=IrDA-monitor-mode.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Through the IrDA netlink set mode command, we switch to IrDA monitor mode,
where one IrLAP instance receives all the packets on the media, without ever
responding to them.

Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>

Index: net-2.6-quilt/include/linux/irda.h
===================================================================
--- net-2.6-quilt.orig/include/linux/irda.h	2007-05-12 03:04:09.000000000 +0300
+++ net-2.6-quilt/include/linux/irda.h	2007-05-12 03:07:41.000000000 +0300
@@ -242,6 +242,7 @@
 /* IrDA modes */
 #define IRDA_MODE_PRIMARY   0x1
 #define IRDA_MODE_SECONDARY 0x2
+#define IRDA_MODE_MONITOR   0x4
 
 #endif /* KERNEL_IRDA_H */
 
Index: net-2.6-quilt/net/irda/irlap_frame.c
===================================================================
--- net-2.6-quilt.orig/net/irda/irlap_frame.c	2007-05-12 03:02:16.000000000 +0300
+++ net-2.6-quilt/net/irda/irlap_frame.c	2007-05-12 03:07:41.000000000 +0300
@@ -101,6 +101,13 @@
 
 	irlap_insert_info(self, skb);
 
+ 	if (unlikely(self->mode & IRDA_MODE_MONITOR)) {
+ 		IRDA_DEBUG(3, "%s(): %s is in monitor mode\n", __FUNCTION__,
+ 			   self->netdev->name);
+ 		dev_kfree_skb(skb);
+ 		return;
+ 	}
+
 	dev_queue_xmit(skb);
 }
 

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
