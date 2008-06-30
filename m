From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v3 [PATCH 2/2] de4x5: Remove developer debug feature about set/clear
 promisc
Date: Mon, 30 Jun 2008 11:24:33 +0800
Message-ID: <486851F1.1080808@cn.fujitsu.com>
References: <485BC7BA.60406@cn.fujitsu.com> <485F8332.6010203@trash.net> <485FA635.4090903@cn.fujitsu.com> <485FA962.5060704@trash.net> <485FB6D1.7000604@cn.fujitsu.com> <485FB8B1.8020000@trash.net> <4860478B.2080109@cn.fujitsu.com> <20080624051029.GB19434@colo.lackof.org> <48608887.6000102@cn.fujitsu.com> <48643F0C.9020408@cn.fujitsu.com> <20080628175241.GA12265@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>, kyle@parisc-linux.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53454 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751554AbYF3D2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jun 2008 23:28:52 -0400
In-Reply-To: <20080628175241.GA12265@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler said the following on 2008-6-29 1:52:
>> @@ -1004,8 +1004,8 @@ struct de4x5_ioctl {
>>  */
>>  #define DE4X5_GET_HWADDR	0x01 /* Get the hardware address */
>>  #define DE4X5_SET_HWADDR	0x02 /* Set the hardware address */
>> -#define DE4X5_SET_PROM  	0x03 /* Set Promiscuous Mode */
>> -#define DE4X5_CLR_PROM  	0x04 /* Clear Promiscuous Mode */
>> +#define DE4X5_SET_PROM  	0x03 /* Obsoleted. Set Promiscuous Mode */
>> +#define DE4X5_CLR_PROM  	0x04 /* Obsoleted. Clear Promiscuous Mode */
> 
> Please just remove them. If the kernel isn't going to provide the
> functionality, I'd rather any apps that attempt to use it break
> when they compile (vs later when they try to be run).

OK. I removed the macros, but left comment to prevent people from reusing
the code 0x03 and 0x04.

---
IFF_PROMISC flag shouldn't be set or cleared by drivers, because
whether device be promisc mode is decided by how many upper layer
callers being referenced to it.
And the promisc changing feature of de4x5 ioctl is developer debug
feature, we can remove it now.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
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


