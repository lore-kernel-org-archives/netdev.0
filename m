From: Don Fry <pcnet32@verizon.net>
Subject: [PATCH] pcnet32:  remove compile warnings in non-napi mode
Date: Wed, 17 Oct 2007 16:10:10 -0700
Message-ID: <1192662610.5312.1.camel@Linux.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:60490 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480AbXJQXTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 19:19:10 -0400
Received: from [192.168.1.2] ([71.117.241.192])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JQ2002T6WNZ1EO6@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 17 Oct 2007 18:16:48 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove compile warning when in non-napi mode.

Signed-off-by:  Don Fry <pcnet32@verizon.net>
---
--- linux-2.6.23-git7/drivers/net/napi.pcnet32.c	2007-10-17 15:56:15.000000000 -0700
+++ linux-2.6.23-git7/drivers/net/pcnet32.c	2007-10-17 16:00:44.000000000 -0700
@@ -442,7 +442,9 @@ static struct pcnet32_access pcnet32_dwi
 
 static void pcnet32_netif_stop(struct net_device *dev)
 {
+#ifdef CONFIG_PCNET32_NAPI
 	struct pcnet32_private *lp = netdev_priv(dev);
+#endif
 	dev->trans_start = jiffies;
 #ifdef CONFIG_PCNET32_NAPI
 	napi_disable(&lp->napi);
@@ -452,7 +454,9 @@ static void pcnet32_netif_stop(struct ne
 
 static void pcnet32_netif_start(struct net_device *dev)
 {
+#ifdef CONFIG_PCNET32_NAPI
 	struct pcnet32_private *lp = netdev_priv(dev);
+#endif
 	netif_wake_queue(dev);
 #ifdef CONFIG_PCNET32_NAPI
 	napi_enable(&lp->napi);


