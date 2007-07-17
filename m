From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] NI5010: Handle multicast frames.
Date: Tue, 17 Jul 2007 13:45:50 +0900 (JST)
Message-ID: <20070717.134550.69551576.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48112 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbXGQEpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 00:45:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 3d5b423..22a3b3d 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -670,14 +670,10 @@ static void ni5010_set_multicast_list(struct net_device *dev)
 
 	PRINTK2((KERN_DEBUG "%s: entering set_multicast_list\n", dev->name));
 
-	if (dev->flags&IFF_PROMISC || dev->flags&IFF_ALLMULTI) {
+	if (dev->flags&IFF_PROMISC || dev->flags&IFF_ALLMULTI || dev->mc_list) {
 		dev->flags |= IFF_PROMISC;
 		outb(RMD_PROMISC, EDLC_RMODE); /* Enable promiscuous mode */
 		PRINTK((KERN_DEBUG "%s: Entering promiscuous mode\n", dev->name));
-	} else if (dev->mc_list) {
-		/* Sorry, multicast not supported */
-		PRINTK((KERN_DEBUG "%s: No multicast, entering broadcast mode\n", dev->name));
-		outb(RMD_BROADCAST, EDLC_RMODE);
 	} else {
 		PRINTK((KERN_DEBUG "%s: Entering broadcast mode\n", dev->name));
 		outb(RMD_BROADCAST, EDLC_RMODE);  /* Disable promiscuous mode, use normal mode */

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
