From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: RESEND [PATCH 2/2] de4x5: Remove developer debug feature about set/clear
 promisc
Date: Tue, 22 Jul 2008 13:13:18 +0800
Message-ID: <48856C6E.5090706@cn.fujitsu.com>
References: <48856C0B.7090602@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@parisc-linux.org>,
	NETDEV <netdev@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54592 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750869AbYGVFOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 01:14:49 -0400
In-Reply-To: <48856C0B.7090602@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFF_PROMISC flag shouldn't be set or cleared by drivers, because
whether device be promisc mode is decided by how many upper layer
callers being referenced to it.
And the promisc changing feature of de4x5 ioctl is developer debug
feature, we can remove it now.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Acked-by: Grant Grundler <grundler@parisc-linux.org>
---
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index bc30c6e..617ef41 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -5514,22 +5514,6 @@ de4x5_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	netif_wake_queue(dev);                      /* Unlock the TX ring */
 	break;
 
-    case DE4X5_SET_PROM:             /* Set Promiscuous Mode */
-	if (!capable(CAP_NET_ADMIN)) return -EPERM;
-	omr = inl(DE4X5_OMR);
-	omr |= OMR_PR;
-	outl(omr, DE4X5_OMR);
-	dev->flags |= IFF_PROMISC;
-	break;
-
-    case DE4X5_CLR_PROM:             /* Clear Promiscuous Mode */
-	if (!capable(CAP_NET_ADMIN)) return -EPERM;
-	omr = inl(DE4X5_OMR);
-	omr &= ~OMR_PR;
-	outl(omr, DE4X5_OMR);
-	dev->flags &= ~IFF_PROMISC;
-	break;
-
     case DE4X5_SAY_BOO:              /* Say "Boo!" to the kernel log file */
 	if (!capable(CAP_NET_ADMIN)) return -EPERM;
 	printk("%s: Boo!\n", dev->name);
diff --git a/drivers/net/tulip/de4x5.h b/drivers/net/tulip/de4x5.h
index f5f33b3..9f28774 100644
--- a/drivers/net/tulip/de4x5.h
+++ b/drivers/net/tulip/de4x5.h
@@ -1004,8 +1004,7 @@ struct de4x5_ioctl {
 */
 #define DE4X5_GET_HWADDR	0x01 /* Get the hardware address */
 #define DE4X5_SET_HWADDR	0x02 /* Set the hardware address */
-#define DE4X5_SET_PROM  	0x03 /* Set Promiscuous Mode */
-#define DE4X5_CLR_PROM  	0x04 /* Clear Promiscuous Mode */
+/* 0x03 and 0x04 were used before and are obsoleted now. Don't use them. */
 #define DE4X5_SAY_BOO	        0x05 /* Say "Boo!" to the kernel log file */
 #define DE4X5_GET_MCA   	0x06 /* Get a multicast address */
 #define DE4X5_SET_MCA   	0x07 /* Set a multicast address */


